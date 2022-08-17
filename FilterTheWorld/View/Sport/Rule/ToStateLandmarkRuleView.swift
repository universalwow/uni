//
//
//import SwiftUI
//
//struct ToStateLandmarkRuleView: View {
//    
//    @EnvironmentObject var sportManager: SportsManager
//    
//    @State var toggle = false
//    
//    @State var warningContent = ""
//    @State var triggeredWhenRuleMet = false
//    @State var delayTime: Double = 2.0
//
//    @State var landmarkTypeToState = LandmarkType.LeftAnkle
//    @State var currentAxis = CoordinateAxis.X
//    @State var relativelandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
//    @State var relativeAxis = CoordinateAxis.X
//    @State var minRelativeLength: Double = 0.0
//    @State var maxRelativeLength: Double = 0.0
//    @State var relativeToState = SportState.startState.id
//    
//    
//    func setInitData() {
//        if toggle {
//            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
//            sportManager.setRuleToStateLandmark(toStateId: relativeToState, fromAxis: currentAxis, relativeSegment: relativeSegment, toAxis: relativeAxis,
//                                                warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime)
//        }
//
//    }
//    
//    func resetInitData() {
//        if toggle {
//            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
//            sportManager.updateRuleToStateLandmark(stateId: relativeToState, fromAxis: currentAxis, landmarkType: landmarkTypeToState,  landmarkSegment: relativeSegment, toAxis: relativeAxis,warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime)
//        }
//       
//    }
// 
//    
//    func updateLocalData() {
//        if toggle {
//            let length = sportManager.getRuleToStateLandmark()!
//            minRelativeLength = length.lowerBound
//            maxRelativeLength = length.upperBound
//        }
// 
//    }
//    
//    func updateRemoteData() {
//        if toggle {
//            sportManager.updateRuleToStateLandmark(lowerBound: minRelativeLength, upperBound: maxRelativeLength)
//        }
//    }
//    
//    
//    func toggleOff() {
//        warningContent = ""
//        triggeredWhenRuleMet = false
//        delayTime = 2.0
//        
//        landmarkTypeToState =  sportManager.findSelectedSegment()!.landmarkTypes.first!
//        currentAxis = CoordinateAxis.X
//        relativelandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
//        relativeAxis = CoordinateAxis.X
//        minRelativeLength = 0.0
//        maxRelativeLength = 0.0
//        relativeToState = sportManager.findFirstSport()!.allHasKeyFrameStates.first!.id
//    }
//    
//    var body: some View {
//        VStack {
//            Toggle("关节相对状态位移", isOn: $toggle.didSet { isOn in
//                if isOn {
//                    setInitData()
//                    updateLocalData()
//                } else {
//                    sportManager.setRuleToStateLandmark(toStateLandmark: nil)
//                    toggleOff()
//                }
//                
//            })
//            VStack{
//                HStack {
//                    Text("提醒:")
//                    TextField("提醒...", text: $warningContent) { flag in
//                        if !flag {
//                            resetInitData()
//                        }
//                        
//                    }
//                    Spacer()
//                    Text("延迟(s):")
//                    TextField("延迟时长", value: $delayTime, formatter: formatter,onEditingChanged: { flag in
//                        if !flag {
//                            resetInitData()
//                        }
//                        
//                    })
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .keyboardType(.decimalPad)
//                    Toggle("规则满足时提示", isOn: $triggeredWhenRuleMet.didSet{ _ in
//                        resetInitData()
//                    })
//                }
//                VStack {
//                    HStack {
//                        Text("当前关节:")
//                        Picker("当前关节", selection: $landmarkTypeToState.didSet{ _ in
//                            resetInitData()
//                            updateLocalData()
//                            
//                        }) {
//                            ForEach(self.sportManager.findSelectedSegment()!.landmarkTypes) { landmarkType in
//                                Text(landmarkType.rawValue).tag(landmarkType)
//                            }
//                        }
//                        
//                        Spacer()
//
//                        Text("当前轴")
//                        Picker("当前轴", selection: $currentAxis.didSet { _ in
//
//                            resetInitData()
//                            updateLocalData()
//                            
//                        }) {
//                            ForEach(CoordinateAxis.allCases) { axis in
//                                Text(axis.rawValue).tag(axis)
//                            }
//                        }
//                    }
//                    
//                    HStack {
//                        Text("相对状态")
//                        Picker("相对状态", selection: $relativeToState.didSet{ _ in
//                            print("相对状态-------\(relativeToState)")
//                            resetInitData()
//                            updateLocalData()
//                        }) {
//                            ForEach(sportManager.findFirstSport()!.allHasKeyFrameStates) { state in
//                                Text(state.name).tag(state.id)
//                            }
//                        }
//                        Spacer()
//
//                        Text("相对关节对")
//                        Picker("相对关节对", selection: $relativelandmarkSegmentType.didSet{ _ in
//                            resetInitData()
//                            updateLocalData()
//                            
//                        }) {
//                            ForEach(LandmarkType.landmarkSegmentTypes) { landmarkSegmentType in
//                                Text(landmarkSegmentType.id).tag(landmarkSegmentType)
//                            }
//                        }
//                        
//                        Text("相对轴")
//                        Picker("相对轴", selection: $relativeAxis.didSet{ _ in
//                            resetInitData()
//                            updateLocalData()
//                        }) {
//                            ForEach(CoordinateAxis.allCases) { axis in
//                                Text(axis.rawValue).tag(axis)
//                            }
//                        }
//                    }
//                    HStack {
//                        Text("最小值:")
//                        TextField("最小值", value: $minRelativeLength, formatter: formatter) { flag in
//                            if !flag {
//                                updateRemoteData()
//
//                            }
//                            
//                        }
//                            .foregroundColor(self.maxRelativeLength >= self.minRelativeLength ? .black : .red)
//                        
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .keyboardType(.decimalPad)
//                        Spacer()
//                        Text("最大值:")
//                        TextField("最大值", value: $maxRelativeLength, formatter: formatter){ flag in
//                            if !flag {
//                                updateRemoteData()
//
//                            }
//                            
//                        }
//                            .foregroundColor(self.maxRelativeLength >= self.minRelativeLength ? .black : .red)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .keyboardType(.decimalPad)
//                        
//                    }
//                    
//                }
//                
//            }.disabled(!toggle)
//        }
//        .onAppear{
//            if let length = sportManager.getRuleToStateLandmark() {
//                warningContent = length.warning.content
//                triggeredWhenRuleMet = length.warning.triggeredWhenRuleMet
//                delayTime = length.warning.delayTime
//                                
//                landmarkTypeToState = length.fromLandmarkToAxis.landmark.landmarkType
//                currentAxis = length.fromLandmarkToAxis.axis
//                relativelandmarkSegmentType = length.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
//                relativeAxis = length.toLandmarkSegmentToAxis.axis
//                relativeToState = length.toStateId
//                minRelativeLength = length.lowerBound
//                maxRelativeLength = length.upperBound
//                toggle = true
//
//            }else {
//                self.landmarkTypeToState = self.sportManager.findSelectedSegment()!.landmarkTypes.first!
//                relativeToState = sportManager.findFirstSport()!.allHasKeyFrameStates.first!.id
//            }
//            
//        }
//    }
//}
//
//struct LandmarkToStateLengthView_Previews: PreviewProvider {
//    static var previews: some View {
//        ToStateLandmarkRuleView()
//    }
//}
