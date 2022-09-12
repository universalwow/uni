

import SwiftUI

struct LandmarkSegmentToStateAngleRuleView: View {
    var landmarkSegmentToStateAngle: LandmarkSegmentToStateAngle
    
    @EnvironmentObject var sportManager: SportsManager
    
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    
    @State var toStateId = SportState.startState.id
    @State var isRelativeToExtremeDirection = false
    @State var extremeDirection = ExtremeDirection.MinX

    @State var lowerBound: Double = 0.0
    @State var upperBound: Double = 0.0
    

 
    
    func updateLocalData() {
        let length = sportManager.getRuleLandmarkSegmentToStateAngle(id: landmarkSegmentToStateAngle.id)
        lowerBound = length.lowerBound
        upperBound = length.upperBound
 
    }
    
    func updateRemoteData() {
        sportManager.updateRuleLandmarkSegmentToStateAngle(
                                               toStateId: toStateId,
                                                      isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                               extremeDirection: extremeDirection,
                                               lowerBound: lowerBound, upperBound: upperBound,
                                               warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: landmarkSegmentToStateAngle.id)

    }
    

    
    var body: some View {
        VStack {
            
            HStack {
                Text("关节对自身(相对状态)角度")
                Spacer()
                
                Toggle(isOn: $isRelativeToExtremeDirection.didSet { _ in
                    updateRemoteData()
                }, label: {
                    Text("相对极值").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Text("极值选择")
                Picker("极值选择", selection: $extremeDirection.didSet{ _ in
                    updateRemoteData()

                }) {
                    ForEach(ExtremeDirection.allCases) { direction in
                        Text(direction.rawValue).tag(direction)
                    }
                }.disabled(!isRelativeToExtremeDirection)
                
                Button(action: {
                    sportManager.removeRuleLandmarkSegmentToStateAngle(id: landmarkSegmentToStateAngle.id)

                }) {
                    Text("删除")
                }.padding([.vertical, .leading])
            }
            
            VStack{
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
                    Toggle("规则满足时提示", isOn: $triggeredWhenRuleMet.didSet{ _ in
                        updateRemoteData()
                    })
                }
                HStack {
                    Text("相对状态")
                    Picker("相对状态", selection: $toStateId.didSet{ _ in
                        updateRemoteData()
                        updateLocalData()
                    }) {
                        ForEach(sportManager.findFirstSport()!.allHasKeyFrameStates) { state in
                            Text(state.name).tag(state.id)
                        }
                    }
                    
                    Text("最小值:")
                    TextField("最小值", value: $lowerBound, formatter: formatter) { flag in
                        if !flag {
                            updateRemoteData()

                        }
                        
                    }
                        .foregroundColor(self.upperBound >= self.lowerBound ? .black : .red)
                    
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    Spacer()
                    Text("最大值:")
                    TextField("最大值", value: $upperBound, formatter: formatter){ flag in
                        if !flag {
                            updateRemoteData()

                        }
                        
                    }
                        .foregroundColor(self.upperBound >= self.lowerBound ? .black : .red)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                }
                
            }
        }
        .onAppear{
            let length = sportManager.getRuleLandmarkSegmentToStateAngle(id: landmarkSegmentToStateAngle.id)
            warningContent = length.warning.content
            triggeredWhenRuleMet = length.warning.triggeredWhenRuleMet
            delayTime = length.warning.delayTime

            toStateId = length.toStateId
            isRelativeToExtremeDirection = length.isRelativeToExtremeDirection
            extremeDirection = length.extremeDirection
            lowerBound = length.lowerBound
            upperBound = length.upperBound
            
        }
    }
}


