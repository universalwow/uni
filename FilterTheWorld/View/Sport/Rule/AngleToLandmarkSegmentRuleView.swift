

import SwiftUI

struct AngleToLandmarkSegmentRuleView : View {
    var angle: AngleToLandmarkSegment
    
    @EnvironmentObject var sportManager: SportsManager
    
    @State var tolandmarkSegmentType: LandmarkTypeSegment = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    
    @State var lowerBound = 0.0
    @State var upperBound = 0.0
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    @State var changeStateClear = true
    
        
    func updateLocalData() {
        let angleToLandmarkSegment = sportManager.getRuleAngleToLandmarkSegment(id: angle.id)
        lowerBound = angleToLandmarkSegment.lowerBound
        upperBound = angleToLandmarkSegment.upperBound
        
    }
    
    func updateRemoteData() {
        self.sportManager.updateRuleAngleToLandmarkSegment(tolandmarkSegmentType: tolandmarkSegmentType, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: angle.id)

    }
    
    var body : some View {
        VStack {
            HStack {
                Text("相对角度")
                Spacer()
                
                Toggle(isOn: $changeStateClear.didSet{ _ in
                    updateRemoteData()
                }, label: {
                    Text("状态切换清除提示").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Button(action: {
                    sportManager.removeRuleAngleToLandmarkSegment(id: angle.id)

                }) {
                    Text("删除")
                }.padding([.vertical, .leading])
            }
            
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $warningContent, onEditingChanged: { flag in
                        if !flag {
                            updateRemoteData()
                        }
                        
                    })
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
                Spacer()
                HStack {
                    Text("相对关节对")
                    Picker("相对关节对", selection: $tolandmarkSegmentType.didSet{ _ in
                        updateRemoteData()
                        updateLocalData()
                        
                    }) {
                        ForEach(LandmarkType.landmarkSegmentTypesForSetRule) { landmarkSegmentType in
                            Text(landmarkSegmentType.id).tag(landmarkSegmentType)
                        }
                    }
        
                    
                    HStack {
                        Text("最小值:")
                        TextField("最小值", value: $lowerBound, formatter: formatter,onEditingChanged: { flag in
                            if !flag {
                                print("0 \(lowerBound)  - \(upperBound)")
                                updateRemoteData()
                            }
                            
                        })
                            .foregroundColor(self.upperBound >= self.lowerBound ? .black : .red)
                        
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        Spacer()
                        Text("最大值:")
                        
                        TextField("最大值", value: $upperBound, formatter: formatter, onEditingChanged: { flag in
                            if !flag {
                                print("1 \(lowerBound)  - \(upperBound)")
                                updateRemoteData()
                            }
                            
                        })
                            .foregroundColor(self.upperBound >= self.lowerBound ? .black : .red)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        
                    }
                }
                
                
            }
        }
        .onAppear{
//            存在时加载
            let angleToLandmarkSegment = sportManager.getRuleAngleToLandmarkSegment(id: angle.id)
            self.tolandmarkSegmentType = angleToLandmarkSegment.to.landmarkSegmentType
            self.lowerBound = angleToLandmarkSegment.lowerBound
            self.upperBound = angleToLandmarkSegment.upperBound
            self.warningContent = angleToLandmarkSegment.warning.content
            self.triggeredWhenRuleMet = angleToLandmarkSegment.warning.triggeredWhenRuleMet
            self.delayTime = angleToLandmarkSegment.warning.delayTime
            self.changeStateClear = angleToLandmarkSegment.warning.changeStateClear == true
        }
    }
    
}

