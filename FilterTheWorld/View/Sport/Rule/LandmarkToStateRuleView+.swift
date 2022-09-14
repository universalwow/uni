

import SwiftUI

struct LandmarkToStateRuleView: View {
    var landmarkToState: LandmarkToState
    
    @EnvironmentObject var sportManager: SportsManager
    
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    @State var changeStateClear = true

    
    @State var fromAxis = CoordinateAxis.X
    @State var toLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var toAxis = CoordinateAxis.X
    
    @State var toStateId = SportState.startState.id

    @State var lowerBound: Double = 0.0
    @State var upperBound: Double = 0.0
    

 
    
    func updateLocalData() {
//        let length = sportManager.getRuleLandmarkToState(id: landmarkToState.id)
//        lowerBound = length.lowerBound
//        upperBound = length.upperBound
 
    }
    
    func updateRemoteData() {
//        sportManager.updateRuleLandmarkToState(fromAxis: fromAxis,
//                                               toStateId: toStateId,
//                                               toLandmarkSegmentType: toLandmarkSegmentType,
//                                               toAxis: toAxis,
//                                               lowerBound: lowerBound, upperBound: upperBound,
//                                               warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: landmarkToState.id)

    }
    

    
    var body: some View {
        VStack {
            
            HStack {
                Text("关节自身(相对状态)位移")
                Spacer()
                Button(action: {
//                    sportManager.removeRuleLandmarkToState(id: landmarkToState.id)

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
                VStack {

                    
                    HStack {
                        Text("当前轴")
                        Picker("当前轴", selection: $fromAxis.didSet { _ in

                            updateRemoteData()
                            updateLocalData()
                            
                        }) {
                            ForEach(CoordinateAxis.allCases) { axis in
                                Text(axis.rawValue).tag(axis)
                            }
                        }
                        
                        Text("相对状态")
                        Picker("相对状态", selection: $toStateId.didSet{ _ in
                            print("相对状态-------\(toStateId)")
                            updateRemoteData()
                            updateLocalData()
                        }) {
                            ForEach(sportManager.findFirstSport()!.allHasKeyFrameStates) { state in
                                Text(state.name).tag(state.id)
                            }
                        }
                        Spacer()

                        Text("相对关节对")
                        Picker("相对关节对", selection: $toLandmarkSegmentType.didSet{ _ in
                            updateRemoteData()
                            updateLocalData()
                            
                        }) {
                            ForEach(LandmarkType.landmarkSegmentTypes) { landmarkSegmentType in
                                Text(landmarkSegmentType.id).tag(landmarkSegmentType)
                            }
                        }
                        
                        Text("/")
                        Picker("相对轴", selection: $toAxis.didSet{ _ in
                            updateRemoteData()
                            updateLocalData()
                        }) {
                            ForEach(CoordinateAxis.allCases) { axis in
                                Text(axis.rawValue).tag(axis)
                            }
                        }
                    }
                    HStack {
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
        }
        .onAppear{
//            let length = sportManager.getRuleLandmarkToState(id: landmarkToState.id)
//            warningContent = length.warning.content
//            triggeredWhenRuleMet = length.warning.triggeredWhenRuleMet
//            delayTime = length.warning.delayTime
//
//            fromAxis = length.fromLandmarkToAxis.axis
//            toLandmarkSegmentType = length.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
//            toAxis = length.toLandmarkSegmentToAxis.axis
//            toStateId = length.toStateId
//            lowerBound = length.lowerBound
//            upperBound = length.upperBound
            
        }
    }
}


