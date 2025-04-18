

import SwiftUI

struct LandmarkSegmentToStateDistanceRuleView: View {
    var landmarkSegmentToStateDistance: LandmarkSegmentToStateDistance
    
    @EnvironmentObject var sportManager: SportsManager
    
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    @State var changeStateClear = true
    
    @State var fromAxis: CoordinateAxis = .XY
    
    @State var toStateId = SportState.startState.id
    @State var isRelativeToExtremeDirection = false
    @State var extremeDirection = ExtremeDirection.MinX

    @State var lowerBound: Double = 0.0
    @State var upperBound: Double = 0.0
    

 
    
    func updateLocalData() {
        let length = sportManager.getRuleLandmarkSegmentToStateDistance(id: landmarkSegmentToStateDistance.id)
        lowerBound = length.lowerBound
        upperBound = length.upperBound
 
    }
    
    func updateRemoteData() {
        sportManager.updateRuleLandmarkSegmentToStateDistance(
            fromAxis: fromAxis,
                                               toStateId: toStateId,
                                                      isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                               extremeDirection: extremeDirection,
                                               lowerBound: lowerBound, upperBound: upperBound,
            warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: landmarkSegmentToStateDistance.id)

    }
    

    
    var body: some View {
        VStack {
            
            HStack {
                Text("自身(相对状态)距离")
                Spacer()
                Toggle(isOn: $changeStateClear.didSet{ _ in
                    updateRemoteData()
                }, label: {
                    Text("状态切换清除提示").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
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
                    sportManager.removeRuleLandmarkSegmentToStateDistance(id: landmarkSegmentToStateDistance.id)

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
                    Toggle(isOn: $triggeredWhenRuleMet.didSet{ _ in
                        updateRemoteData()
                    }, label: {
                        Text("规则满足时提示").frame(maxWidth: .infinity, alignment: .trailing)
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
                    
                    Text("/")
                    Picker("当前轴", selection: $fromAxis.didSet { _ in
                        updateRemoteData()
                        updateLocalData()
                                                    
                                                }) {
                        ForEach(CoordinateAxis.allCases) { axis in
                            Text(axis.rawValue).tag(axis)
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
            let length = sportManager.getRuleLandmarkSegmentToStateDistance(id: landmarkSegmentToStateDistance.id)
            warningContent = length.warning.content
            triggeredWhenRuleMet = length.warning.triggeredWhenRuleMet
            delayTime = length.warning.delayTime
            changeStateClear = length.warning.changeStateClear == true
            
            fromAxis = length.fromAxis
            toStateId = length.toStateId
            isRelativeToExtremeDirection = length.isRelativeToExtremeDirection
            extremeDirection = length.extremeDirection
            lowerBound = length.lowerBound
            upperBound = length.upperBound
            
        }
    }
}


