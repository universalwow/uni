

import SwiftUI

struct LandmarkAngleRuleView: View {
    @EnvironmentObject var sportManager:SportsManager
    
    struct StaticValue {
        static let angleTextOffsetY: CGFloat = -20
        static let angleImageSize: CGFloat = 35
    }
    
    @State var minAngle = 0.0
    @State var maxAngle = 0.0
    @State var angleWarning = ""
    @State var angleToggle = false
    
    
    
    func toggleOff() {
        minAngle = 0.0
        maxAngle = 0.0
        angleWarning = ""
    }
    
    func setInitData() {
        if angleToggle {
            let landmarkSegment = sportManager.findselectedSegment()!
            sportManager.setCurrentSportStateRuleAngle(angle: AngleRange(lowerBound: landmarkSegment.angle2d, upperBound: landmarkSegment.angle2d))
            minAngle = landmarkSegment.angle2d
            maxAngle = landmarkSegment.angle2d
            
        }
        
    }
    
    func updateRemoteData() {
        if angleToggle {
            sportManager.setCurrentSportStateRuleAngle(angle: AngleRange(lowerBound: self.minAngle, upperBound: self.maxAngle, warning: angleWarning))
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
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
                            self.minAngle = max(0, self.minAngle - 1)
                            updateRemoteData()

                        }
                },
                maximumValueLabel: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
                            self.minAngle = min(360, self.minAngle + 1)
                            updateRemoteData()
                        }
                },
                
                onEditingChanged: { flag in
                    print("---------\(flag)")
                    if !flag {
                        updateRemoteData()
                    }
                    
                    
                }).background(content: {
                    Text("\(self.minAngle)")
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
                    Text("最小角度")
                },
                minimumValueLabel: {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
                            self.maxAngle = max(0, self.maxAngle - 1)
                            updateRemoteData()

                        }
                },
                maximumValueLabel: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                    
                        .onTapGesture {
                            self.maxAngle = min(360, self.maxAngle + 1)
                            updateRemoteData()
                            
                        }
                },
                onEditingChanged: { flag in
                    print("1---------\(flag)")
                    if !flag {
                        updateRemoteData()
                    }
                }).background(content: {
                    Text("\(self.maxAngle)")
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
                    
                }else{
                    sportManager.setCurrentSportStateRuleAngle(angle: nil)
                    toggleOff()
                }
                
            })
            VStack {
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $angleWarning) { flag in
                        if !flag {
                            updateRemoteData()
                        }
                        
                    }
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
            if let angle = sportManager.getCurrentSportStateRuleAngle() {
                self.angleToggle = true
                self.minAngle = angle.lowerBound
                self.maxAngle = angle.upperBound
                self.angleWarning = angle.warning
                
            }
        })
    }
}


