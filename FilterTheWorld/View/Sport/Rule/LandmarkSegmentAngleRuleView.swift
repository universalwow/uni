

import SwiftUI





struct LandmarkSegmentAngleRuleView: View {
    @EnvironmentObject var sportManager:SportsManager
    
    struct ImageButton: View {
        var systemName:String
        var body: some View {
            ZStack {
                Capsule().fill(Color.green)
                
                Image(systemName: systemName)
                    .resizable()
                    .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                    .foregroundColor(.white)
                    
                
            }.frame(width: StaticValue.angleImageSize*2, height: StaticValue.angleImageSize)
            
        }
    }
    
    struct StaticValue {
        static let angleTextOffsetY: CGFloat = -20
        static let angleImageSize: CGFloat = 35
    }
    
    @State var minAngle = 0.0
    @State var maxAngle = 0.0
    @State var warning = ""
    @State var satisfyWarning = false

    @State var angleToggle = false
    
    
    
    
    func toggleOff() {
        minAngle = 0.0
        maxAngle = 0.0
        warning = ""
        satisfyWarning = false
    }
    
    func setInitData() {
        if angleToggle {
            let landmarkSegment = sportManager.findSelectedSegment()!
            sportManager.setRuleLandmarkSegmentAngle(landmarkSegment: landmarkSegment, warning: warning, satisfyWarning: satisfyWarning)
        }
    }
    
    func resetInitData() {
        if angleToggle {
            let landmarkSegment = sportManager.findSelectedSegment()!
            sportManager.updateRuleLandmarkSegmentAngle(landmarkSegment: landmarkSegment, warning: warning, satisfyWarning: satisfyWarning)
        }
    }
    
    
    func updateLocalData() {
        let angle = sportManager.getRuleLandmarkSegmentAngle()!
        minAngle = angle.lowerBound
        maxAngle = angle.upperBound
    }
    
    func updateRemoteData() {
        if angleToggle {
            sportManager.updateRuleLandmarkSegmentAngle(lowerBound: minAngle, upperBound: maxAngle, warning: warning)
        }
        
    }
    
    //角度
    var minAngleslider: some View {
        HStack {
            Slider(
                value: $minAngle,
                in: 0...360,
                step: 1,
                label: {
                    Text("最小角度")
                },
                minimumValueLabel: {
                    ImageButton(systemName: "minus.circle.fill")
//                        .resizable()
//                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
                            self.minAngle = max(0, self.minAngle - 1)
                            updateRemoteData()
                            
                        }
                },
                maximumValueLabel: {
                    ImageButton(systemName: "plus.circle.fill")
//                        .resizable()
//                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
                            
                            self.minAngle = min(360, self.minAngle + 1)
                            updateRemoteData()
                        }
                },
                
                onEditingChanged: { flag in
                    if !flag {
                        updateRemoteData()
                    }
                    
                    
                }).background(content: {
                    Text("\(self.minAngle.roundedString(number: 0))")
                        .offset(y: StaticValue.angleTextOffsetY)
                        .foregroundColor(self.maxAngle > self.minAngle ? .black : .red)
                    
                })
        }
        
    }
    
    var maxAngleslider: some View {
        HStack {
            Slider(
                value: $maxAngle,
                in: 0...360,
                step: 1,
                label: {
                    Text("最大角度")
                },
                minimumValueLabel: {
                    ImageButton(systemName: "minus.circle.fill")
//                        .resizable()
//                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
                            self.maxAngle = max(0, self.maxAngle - 1)
                            updateRemoteData()
                            
                        }
                },
                maximumValueLabel: {
                    ImageButton(systemName: "plus.circle.fill")
//                        .resizable()
//                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
                            self.maxAngle = min(360, self.maxAngle + 1)
                            updateRemoteData()
                            
                        }
                },
                onEditingChanged: { flag in
                    if !flag {
                        updateRemoteData()
                    }
                }).background(content: {
                    Text("\(self.maxAngle.roundedString(number: 0))")
                        .offset(y: StaticValue.angleTextOffsetY)
                        .foregroundColor(self.maxAngle > self.minAngle ? .black : .red)
                    
                })
        }
        
    }
    
    
    var body: some View {
        VStack {
            Toggle("角度", isOn: $angleToggle.didSet{ isOn in
                if isOn {
                    setInitData()
                    updateLocalData()
                    
                }else{
                    sportManager.setRuleLandmarkSegmentAngle(angle: nil)
                    toggleOff()
                }
                
            })
            VStack {
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $warning) { flag in
                        if !flag {
                            updateRemoteData()
                        }
                        
                    }
                    Spacer()
                    Toggle("规则满足时提示", isOn: $satisfyWarning.didSet{ _ in
                        resetInitData()
                    })
                    
                }
                HStack {
                    Text("最小角度")
                        .onTapGesture {
                            self.minAngle = max(0, self.minAngle - 1)
                            
                        }
                    minAngleslider
                }
                HStack {
                    Text("最大角度")
                        .onTapGesture {
                            self.maxAngle = max(0, self.maxAngle - 1)
                            
                        }
                    maxAngleslider
                }
            }.disabled(!angleToggle)
            
        }
        
        .onAppear(perform: {
            if let angle = sportManager.getRuleLandmarkSegmentAngle() {
                self.minAngle = angle.lowerBound
                self.maxAngle = angle.upperBound
                self.warning = angle.warning
                self.satisfyWarning = angle.satisfyWarning ?? false
                self.angleToggle = true
            }
        })
    }
}


