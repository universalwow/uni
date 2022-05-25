

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
                            //                            self.minAngle = min(min(0, self.minAngle - 1), self.maxAngle)
                            self.minAngle = max(0, self.minAngle - 1)
                        }
                },
                maximumValueLabel: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
                            //                            self.minAngle = min(min(360, self.minAngle + 1), self.maxAngle)
                            self.minAngle = min(360, self.minAngle + 1)
                        }
                },
                onEditingChanged: { _ in
                    //                    self.minAngle = min(self.minAngle, self.maxAngle)
                    //                    self.minAngle = min(self.minAngle, self.maxAngle)
                    
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
                            //                            self.maxAngle = max(min(0, self.maxAngle - 1),self.minAngle)
                            self.maxAngle = max(0, self.maxAngle - 1)
                            
                        }
                },
                maximumValueLabel: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                    
                        .onTapGesture {
                            //                            self.maxAngle = max(min(360, self.maxAngle + 1), self.minAngle)
                            self.maxAngle = min(360, self.maxAngle + 1)
                            
                        }
                },
                onEditingChanged: { _ in
                    //                    self.maxAngle = max(self.minAngle, self.maxAngle)
                }).background(content: {
                    Text("\(self.maxAngle)")
                        .offset(y: StaticValue.angleTextOffsetY)
                        .foregroundColor(self.maxAngle > self.minAngle ? .black : .red)
                    
                })
        }
        
    }
    
    
    var body: some View {
        VStack {
            Toggle("角度", isOn: $angleToggle.didSet{ _ in
                if angleToggle {
                    let landmarkSegment = sportManager.findselectedSegment()!
                    sportManager.setCurrentSportStateRuleAngle(angle: AngleRange(lowerBound: landmarkSegment.angle2d, upperBound: landmarkSegment.angle2d))
                    minAngle = landmarkSegment.angle2d
                    maxAngle = landmarkSegment.angle2d
                }else{
                    sportManager.setCurrentSportStateRuleAngle(angle: nil)
                }
                
            })
            VStack {
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $angleWarning) { flag in
                        if !flag {
                            sportManager.setCurrentSportStateRuleAngle(angle: AngleRange(lowerBound: self.minAngle, upperBound: self.maxAngle, warning: angleWarning))
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
                            //                            self.maxAngle = max(min(0, self.maxAngle - 1),self.minAngle)
                            self.maxAngle = max(0, self.maxAngle - 1)
                            
                        }
                    maxAngleslider
                }
            }.disabled(!angleToggle)
            
        }.onChange(of: minAngle) { _ in
            sportManager.setCurrentSportStateRuleAngle(angle: AngleRange(lowerBound: self.minAngle, upperBound: self.maxAngle, warning: angleWarning))
        }
        .onChange(of: maxAngle) { _ in
            sportManager.setCurrentSportStateRuleAngle(angle: AngleRange(lowerBound: self.minAngle, upperBound: self.maxAngle, warning: angleWarning))
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


