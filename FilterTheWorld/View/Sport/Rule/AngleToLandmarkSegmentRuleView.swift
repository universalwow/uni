

import SwiftUI

struct AngleToLandmarkSegmentRuleView : View {
    
    @EnvironmentObject var sportManager: SportsManager
    

    @State var relativelandmarkSegmentType: LandmarkTypeSegment = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    
    @State var lowerBound = 0.0
    @State var upperBound = 0.0
    
    @State var toggle = false
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    
    func setInitData() {
        if toggle {
            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
            sportManager.setRuleAngleToLandmarkSegment(relativeSegment: relativeSegment,  warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime)
      
        }
    }
    
    func resetInitData() {
        if toggle {
            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
            
            sportManager.updateRuleAngleToLandmarkSegment(relativeSegment: relativeSegment,  warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime)

        }

    }
    
    
    func toggleOff() {

        relativelandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
        lowerBound = 0.0
        upperBound = 0.0
        warningContent = ""
        triggeredWhenRuleMet = false
        delayTime = 2.0
    }
    
    func updateLocalData() {
        if toggle {
            let angleToLandmarkSegment = sportManager.getRuleAngleToLandmarkSegment()!
            lowerBound = angleToLandmarkSegment.lowerBound
            upperBound = angleToLandmarkSegment.upperBound
            print("2 \(lowerBound)  - \(upperBound)")
        }
        
    }
    
    func updateRemoteData() {
        if toggle {
            self.sportManager.updateRuleAngleToLandmarkSegment(lowerBound: lowerBound, upperBound: upperBound)

        }
    }
    
    var body : some View {
        VStack {
            Toggle("关节对相对角度", isOn: $toggle.didSet{ isOn in
                    if isOn {
                        
                        setInitData()
                        updateLocalData()
             
                    }else {
                    sportManager.setRuleAngleToLandmarkSegment(angleToLandmarkSegment: nil)
                    toggleOff()
                        
                    }
            })
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $warningContent, onEditingChanged: { flag in
                        if !flag {
                            resetInitData()
                        }
                        
                    })
                    Spacer()
                    Text("延迟(s):")
                    TextField("延迟时长", value: $delayTime, formatter: formatter,onEditingChanged: { flag in
                        if !flag {
                            resetInitData()
                        }
                        
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    
                    Toggle("规则满足时提示", isOn: $triggeredWhenRuleMet.didSet{ _ in
                        resetInitData()
                    })
                }
                HStack {
                    Text("相对关节对")
                    Picker("相对关节对", selection: $relativelandmarkSegmentType.didSet{ _ in
                        print("相对关节对")
                        resetInitData()
                        updateLocalData()
                        
                    }) {
                        ForEach(LandmarkType.landmarkSegmentTypesForSetRule) { landmarkSegmentType in
                            Text(landmarkSegmentType.id).tag(landmarkSegmentType)
                        }
                    }
                    Spacer()
                    
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
            .disabled(!toggle)
        }
        .onAppear{
//            存在时加载
            if let angleToLandmarkSegment = sportManager.getRuleAngleToLandmarkSegment() {
                
                self.relativelandmarkSegmentType = angleToLandmarkSegment.to.landmarkSegmentType
                self.lowerBound = angleToLandmarkSegment.lowerBound
                self.upperBound = angleToLandmarkSegment.upperBound
                self.warningContent = angleToLandmarkSegment.warning.content
                self.triggeredWhenRuleMet = angleToLandmarkSegment.warning.triggeredWhenRuleMet
                self.delayTime = angleToLandmarkSegment.warning.delayTime

                self.toggle = true
                
            }
        }
    }
    
}

