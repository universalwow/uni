

import SwiftUI

struct LandmarkSegmentAngleRuleView: View {
    @EnvironmentObject var sportManager:SportsManager
    
    struct StaticValue {
        static let angleTextOffsetY: CGFloat = -20
        static let angleImageSize: CGFloat = 35
    }
    
    @State var minAngle = 0.0
    @State var maxAngle = 0.0
    @State var warning = ""
    @State var angleToggle = false
    
    
    
    func toggleOff() {
        minAngle = 0.0
        maxAngle = 0.0
        warning = ""
    }
    
    func setInitData() {
        if angleToggle {
            let landmarkSegment = sportManager.findSelectedSegment()!
            sportManager.setRuleLandmarkSegmentAngle(landmarkSegment: landmarkSegment, warning: warning)
        }
    }
    
    func resetInitData() {
        if angleToggle {
            let landmarkSegment = sportManager.findSelectedSegment()!
            sportManager.updateRuleLandmarkSegmentAngle(landmarkSegment: landmarkSegment, warning: warning)
        }
    }
    
    
    func updateLocalData() {
        let angle = sportManager.getRuleLandmarkSegmentAngle()!
        minAngle = angle.lowerBound
        maxAngle = angle.upperBound
    }
    
    func updateRemoteData() {
        if angleToggle {
            sportManager.updateRuleLandmarkSegmentAngle(lowerBound: minAngle, upperBound: maxAngle)
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
                self.angleToggle = true
            }
        })
    }
}


