

import SwiftUI


struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    /// While animating, SwiftUI changes the old input value to the new target value using this property. This value is set to the old value until the animation completes.
    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    /// The target value for which we're observing. This value is directly set once the animation starts. During animation, `animatableData` will hold the oldValue and is only updated to the target value once the animation completes.
    private var targetValue: Value

    /// The completion callback which is called once the animation completes.
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        targetValue = observedValue
    }

    /// Verifies whether the current animation is finished and calls the completion callback if true.
    private func notifyCompletionIfFinished() {
        print("animatableData \(animatableData)")
        guard animatableData == targetValue else { return }

        /// Dispatching is needed to take the next runloop for the completion callback.
        /// This prevents errors like "Modifying state during view update, this will cause undefined behavior."
        DispatchQueue.main.async {
            self.completion()
        }
    }

    func body(content: Content) -> some View {
        /// We're not really modifying the view so we can directly return the original input value.
        return content
    }
}


struct OffsetEffect: AnimatableModifier {
    var offset: CGFloat

    var animatableData: CGFloat {
        get {
            print("offset get \(offset)")

            return offset
        } set {
            
            print("offset set \(newValue) \(offset)")
            if newValue < offset {
                offset = newValue
            }
            
        }
    }

    func body(content: Content) -> some View {
        content
    }
}

struct WarningText: View {
    
    @Binding var warning: Warning

    @State private var offset: CGFloat = 0
    @Binding var childViewSize: CGSize
    
    var body: some View {
        
        Text(warning.content)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(warning.isScoreWarning == false ? .green : .red))
            .offset(x: 0, y: offset)
//                .modifier(OffsetEffect(offset: offset))
            .modifier(AnimationCompletionObserverModifier(observedValue: offset, completion: {
                self.warning = Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2)

            }))
            .onChange(of: self.warning, perform: { text in
                if warning.content != "" {
                self.offset = self.childViewSize.height * 3
                
                withAnimation(.linear(duration: Double(4))) {
                    self.offset = self.childViewSize.height * -3
                }
            }
            
        })
        .onChange(of: self.childViewSize, perform: { _ in
            self.offset = self.childViewSize.height * 3
        })
        .onAppear(perform: {
            self.offset = self.childViewSize.height * 3
        })
        
            
            
    }

}

struct WarningTest: View {
    @EnvironmentObject var sportGround: SportsGround

    @State var childViewSize: CGSize = .zero
    @State var first = Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2)
    @State var second = Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2)
    @State var third = Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2)
    @State var fourth = Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2)
    @State var five = Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2)

    @State var timer = Timer.publish(every: 1, on: .main, in: .default)
        .autoconnect()
      
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading){
                HStack {
                    ZStack(alignment: .leading) {
                        ChildSizeReader(size: $childViewSize) {
                            Text("我想不通")
                                .padding()
                                .font(.largeTitle)
                        }.opacity(0)
                        
                        WarningText(warning: $first, childViewSize: $childViewSize)
                        WarningText(warning: $second, childViewSize: $childViewSize)
                        WarningText(warning: $third, childViewSize: $childViewSize)
                        WarningText(warning: $fourth, childViewSize: $childViewSize)
                        WarningText(warning: $five, childViewSize: $childViewSize)
                        
                    }
                    Spacer()
                }
                
            }
            .font(.largeTitle)
            .frame(height:childViewSize.height*4)
            .clipped()

        }
        .onDisappear(perform: {
            timer.upstream.connect().cancel()
        })
        .onAppear(perform: {
            timer = timer.upstream.autoconnect()

        })
        .onReceive(timer, perform: { time in
            print("warning... 9 \(sportGround.warnings)")
            if !sportGround.warnings.isEmpty {
                let warning = sportGround.warnings.removeFirst()
            
                if ![first, second, third, fourth, five].contains(where: { _warning in
                    _warning.content == warning.content
                    
                }) {
                    
                    print("warning 8 \(warning.content)")
                    if first.content == "" {
                        first = warning
                    } else if second.content == "" {
                        second = warning
                    }else if third.content == "" {
                        third = warning
                    }else if fourth.content == "" {
                        fourth = warning
                    }else if five.content == "" {
                        five = warning
                    }
                }
            }
            
        })
        
    }
}

struct WarningTest_Previews: PreviewProvider {
    static var previews: some View {
        WarningTest()
    }
}
