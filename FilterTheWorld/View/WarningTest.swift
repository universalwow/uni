

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
    
    @Binding var text: String

    @State private var offset: CGFloat = 0
    @Binding var childViewSize: CGSize
    
    var body: some View {
        
        Text(text)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(.green))
            .offset(x: 0, y: offset)
//                .modifier(OffsetEffect(offset: offset))
            .modifier(AnimationCompletionObserverModifier(observedValue: offset, completion: {
                self.text = ""

            }))
            .onChange(of: self.text, perform: { text in
            if text != "" {
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
    @State var first = ""
    @State var second = ""
    @State var third = ""
    @State var fourth = ""
    @State var five = ""
    let totalCount = 0..<5

    
    @State var timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
      

    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading){
                HStack {
                    ZStack {
                        ChildSizeReader(size: $childViewSize) {
                            Text("我想不通")
                                .padding()
                                .font(.largeTitle)
                        }.opacity(0)
                        
                        
                        WarningText(text: $first, childViewSize: $childViewSize)
                        WarningText(text: $second, childViewSize: $childViewSize)
                        WarningText(text: $third, childViewSize: $childViewSize)
                        WarningText(text: $fourth, childViewSize: $childViewSize)
                        WarningText(text: $five, childViewSize: $childViewSize)
                        
                    }
                    Spacer()
                }
                
            }
            .font(.largeTitle)
            .frame(height:childViewSize.height*4)
//            .background(Color.green)
            .clipped()

        }
        .onReceive(timer, perform: { time in
            print("warning... 9 \(sportGround.warnings)")
            if !sportGround.warnings.isEmpty {
                let warning = sportGround.warnings.removeFirst()
            
                if ![first, second, third, fourth, five].contains(warning) {
                    
                    print("warning 8 \(warning)")
                    if first == "" {
                        first = "\(warning)"
                    } else if second == "" {
                        second = "\(warning)"
                    }else if third == "" {
                        third = "\(warning)"
                    }else if fourth == "" {
                        fourth = "\(warning)"
                    }else if five == "" {
                        five = "\(warning)"
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
