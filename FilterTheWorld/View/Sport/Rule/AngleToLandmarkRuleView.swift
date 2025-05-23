

import SwiftUI



struct AngleToLandmarkRuleView: View {
    var angleToLandmark: AngleToLandmark
    
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
    
    @State var lowerBound = 0.0
    @State var upperBound = 0.0
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    @State var changeStateClear = true
    
    @State var toLandmarkType = LandmarkType.LeftShoulder
    
    
    func updateLocalData() {
        let angle = sportManager.getRuleAngleToLandmark(id: angleToLandmark.id)
        lowerBound = angle.lowerBound
        upperBound = angle.upperBound
    }
    
    func updateRemoteData() {
        sportManager.updateRuleAngleToLandmark(warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, lowerBound: lowerBound, upperBound: upperBound, toLandmarkType: toLandmarkType, id: angleToLandmark.id)
    }
    
    //角度
    var minAngleslider: some View {
        HStack {
            Slider(
                value: $lowerBound,
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
                            self.lowerBound = max(0, self.lowerBound - 1)
                            updateRemoteData()
                            
                        }
                },
                maximumValueLabel: {
                    ImageButton(systemName: "plus.circle.fill")
//                        .resizable()
//                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
                            
                            self.lowerBound = min(360, self.lowerBound + 1)
                            updateRemoteData()
                        }
                },
                
                onEditingChanged: { flag in
                    if !flag {
                        updateRemoteData()
                    }
                }).background(content: {
                    Text("\(self.lowerBound.roundedString(number: 0))")
                        .offset(y: StaticValue.angleTextOffsetY)
                        .foregroundColor(self.upperBound > self.lowerBound ? .black : .red)
                    
                })
        }
        
    }
    
    var maxAngleslider: some View {
        HStack {
            Slider(
                value: $upperBound,
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
                            self.upperBound = max(0, self.upperBound - 1)
                            updateRemoteData()
                            
                        }
                },
                maximumValueLabel: {
                    ImageButton(systemName: "plus.circle.fill")
//                        .resizable()
//                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
                            self.upperBound = min(360, self.upperBound + 1)
                            updateRemoteData()
                            
                        }
                },
                onEditingChanged: { flag in
                    if !flag {
                        updateRemoteData()
                    }
                }).background(content: {
                    Text("\(self.upperBound.roundedString(number: 0))")
                        .offset(y: StaticValue.angleTextOffsetY)
                        .foregroundColor(self.upperBound > self.lowerBound ? .black : .red)
                    
                })
        }
        
    }
    
    
    var body: some View {
        VStack {
            
            HStack {
                Text("关节对角度")
                Spacer()
                Toggle(isOn: $changeStateClear.didSet{ _ in
                    updateRemoteData()
                }, label: {
                    Text("状态切换清除提示").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Text("相对关节")
                Picker("相对关节", selection: $toLandmarkType.didSet{ _ in
                    updateRemoteData()
                    updateLocalData()
                    
                }) {
                    ForEach(LandmarkType.allCases) { _landmarkType in
                        Text(_landmarkType.id).tag(_landmarkType)
                    }
                }

                
                Button(action: {
                    sportManager.removeRuleAngleToLandmark(id: angleToLandmark.id)

                }) {
                    Text("删除")
                }.padding([.vertical, .leading])
            }

            VStack {
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $warningContent) { flag in
                        if !flag {
                            updateRemoteData()
                        }
                        
                    }
                    Spacer()
                    Text("延迟(s):")
                    TextField("延迟时长", value: $delayTime, formatter: formatter,onEditingChanged: { flag in
                        if !flag {
                            updateRemoteData()
                        }
                        
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    
                    Toggle(isOn: $triggeredWhenRuleMet.didSet{ _ in
                        updateRemoteData()
                    }, label: {
                        Text("规则满足时提示").frame(maxWidth: .infinity, alignment: .trailing)
                    })
                    
                }
                HStack {
                    Text("最小角度")
                        .onTapGesture {
                            self.lowerBound = max(0, self.lowerBound - 1)
                            
                        }
                    minAngleslider
                }
                HStack {
                    Text("最大角度")
                        .onTapGesture {
                            self.upperBound = max(0, self.upperBound - 1)
                            
                        }
                    maxAngleslider
                }
            }
            
        }
        
        .onAppear(perform: {
            let angle = sportManager.getRuleAngleToLandmark(id: angleToLandmark.id)
            self.lowerBound = angle.lowerBound
            self.upperBound = angle.upperBound
            
            self.warningContent = angle.warning.content
            self.triggeredWhenRuleMet = angle.warning.triggeredWhenRuleMet
            self.delayTime = angle.warning.delayTime
            changeStateClear = angle.warning.changeStateClear == true
            
            self.toLandmarkType = angle.toLandmark.landmarkType
        })
    }
}


