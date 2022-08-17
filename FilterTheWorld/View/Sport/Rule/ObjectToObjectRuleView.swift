//
//
//import SwiftUI
//
//struct ObjectToObjectRuleView: View {
//    @EnvironmentObject var sportManager: SportsManager
//    
//    @State var toggle = false
//    
//    
//    @State var warningContent = ""
//    @State var triggeredWhenRuleMet = false
//    @State var delayTime: Double = 2.0
//
//
//    @State var currentAxis = CoordinateAxis.X
////    此处id为label
//    @State var fromObjectId = ""
//    @State var fromObjectPosition = ObjectPosition.middle
//    @State var toObjectId = ""
//    @State var toObjectPosition = ObjectPosition.middle
//  
//    @State var toLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
//    @State var toLandmarkSegmentAxis = CoordinateAxis.X
//    @State var lowerBound = 0.0
//    @State var upperBound = 0.0
//    
//    
//    func setInitData() {
//        if toggle {
//            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: toLandmarkSegmentType)
//            sportManager.setRuleObjectToObject(
//                fromAxis: currentAxis, fromObjectId: fromObjectId, fromObjectPosition: fromObjectPosition, toObjectId: toObjectId, toObjectPosition: toObjectPosition, relativeSegment: relativeSegment, toAxis: toLandmarkSegmentAxis,
//                warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime)
//        }
//    }
//    func resetInitData() {
//        if toggle {
//            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: toLandmarkSegmentType)
//            sportManager.updateRuleObjectToObject(
//                fromAxis: currentAxis, fromObjectId: fromObjectId, fromObjectPosition: fromObjectPosition, toObjectId: toObjectId, toObjectPosition: toObjectPosition, relativeSegment: relativeSegment, toAxis: toLandmarkSegmentAxis, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime)
//        }
//        
//    }
//    func updateLocalData() {
//        if toggle {
//            let objectToObject = sportManager.getRuleObjectToObject()!
//            lowerBound = objectToObject.lowerBound
//            upperBound = objectToObject.upperBound
//        }
//    }
//    
//    func updateRemoteData() {
//        if toggle {
//            sportManager.updateRuleObjectToObject(lowerBound: lowerBound, upperBound: upperBound)
//        }
//    }
//    
//    func toggleOf() {
//        warningContent = ""
//        triggeredWhenRuleMet = false
//        delayTime = 2.0
//        
//        fromObjectId = sportManager.findSelectedObjects().first!.label
//        fromObjectPosition = ObjectPosition.middle
//        toObjectId = sportManager.findSelectedObjects().first!.label
//        toObjectPosition = ObjectPosition.middle
//        currentAxis = CoordinateAxis.X
//        toLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
//        toLandmarkSegmentAxis = CoordinateAxis.X
//        lowerBound = 0.0
//        upperBound = 0.0
//    }
//    
//    
//    var body: some View {
//        VStack {
//            Toggle("物体位置相对物体位置", isOn: $toggle.didSet { isOn in
//                if isOn {
//                    setInitData()
//                    updateLocalData()
//                    
//                } else {
//                    sportManager.setRuleObjectToObject(objectToObject: nil)
//                    toggleOf()
//                }
//            
//                
//            })
//            VStack {
//                HStack {
//                    Text("提醒:")
//                    TextField("提醒...", text: $warningContent, onEditingChanged: { flag in
//                        if !flag {
//                            resetInitData()
//                        }
//                    })
//                    
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
//                    
//                    Toggle("规则满足时提示", isOn: $triggeredWhenRuleMet.didSet{ _ in
//                        resetInitData()
//                    })
//                }
//                
//                HStack {
//                    HStack {
//                        Text("物体A")
//                        Picker("物体", selection: $fromObjectId.didSet{ _ in
//                            resetInitData()
//                            updateLocalData()
//                            
//                        }) {
//                            ForEach(sportManager.findSelectedObjects()) { object in
//                                Text(object.label).tag(object.label)
//                            }
//                        }
//                        Text("位置")
//                        Picker("位置", selection: $fromObjectPosition.didSet{ _ in
//                            resetInitData()
//                            updateLocalData()
//                            
//                        }) {
//                            ForEach(ObjectPosition.allCases) { position in
//                                Text(position.rawValue).tag(position)
//                            }
//                        }
//                        Text("轴")
//                        Picker("当前轴", selection: $currentAxis.didSet { _ in
//                            resetInitData()
//                            updateLocalData()
//                            
//                        }) {
//                            ForEach(CoordinateAxis.allCases) { axis in
//                                Text(axis.rawValue).tag(axis)
//                            }
//                        }
//                    }
//                    Spacer()
//                    
//                    HStack {
//                        Text("物体B")
//                        Picker("物体", selection: $toObjectId.didSet{ _ in
//                            resetInitData()
//                            updateLocalData()
//                            
//                        }) {
//                            ForEach(sportManager.findSelectedObjects()) { object in
//                                Text(object.label).tag(object.label)
//                            }
//                        }
//                        Text("位置")
//                        Picker("位置", selection: $toObjectPosition.didSet{ _ in
//                            resetInitData()
//                            updateLocalData()
//                            
//                        }) {
//                            ForEach(ObjectPosition.allCases) { position in
//                                Text(position.rawValue).tag(position)
//                            }
//                        }
//                    }
//                    
//                    
//                }
//                
//                HStack {
//                    
//
//                    Text("相对关节对")
//                    Picker("相对关节对", selection: $toLandmarkSegmentType.didSet{ _ in
//                        resetInitData()
//                        updateLocalData()
//                        
//                    }) {
//                        ForEach(LandmarkType.landmarkSegmentTypes) { landmarkSegmentType in
//                            Text(landmarkSegmentType.id).tag(landmarkSegmentType)
//                        }
//                    }
//                    
//                    Spacer()
//                    
//                    Text("相对轴")
//                    Picker("相对轴", selection: $toLandmarkSegmentAxis.didSet{ _ in
//                        resetInitData()
//                        updateLocalData()
//                    }) {
//                        ForEach(CoordinateAxis.allCases) { axis in
//                            Text(axis.rawValue).tag(axis)
//                        }
//                    }
//                    
//                    
//                    
//                }
//                
//                HStack {
//                    Text("最小值:")
//                    TextField("最小值", value: $lowerBound, formatter: formatter) { flag in
//                        if !flag {
//                            updateRemoteData()
//                        }
//                    }
//                    .foregroundColor(self.upperBound >= self.lowerBound ? .black : .red)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .keyboardType(.decimalPad)
//                    Spacer()
//                    Text("最大值:")
//                    TextField("最大值", value: $upperBound, formatter: formatter){ flag in
//                        if !flag {
//                            updateRemoteData()
//                        }
//                    }
//                        .foregroundColor(self.upperBound >= self.lowerBound ? .black : .red)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .keyboardType(.decimalPad)
//                    
//                }
//                
//            }.disabled(!toggle)
//        }.onAppear{
//            if let objectToObject = sportManager.getRuleObjectToObject() {
//                warningContent = objectToObject.warning.content
//                triggeredWhenRuleMet = objectToObject.warning.triggeredWhenRuleMet
//                delayTime = objectToObject.warning.delayTime
//                
//                fromObjectId = objectToObject.fromPosition.id
//                fromObjectPosition = objectToObject.fromPosition.position
//                toObjectId = objectToObject.toPosition.id
//                toObjectPosition = objectToObject.toPosition.position
//                currentAxis = objectToObject.fromAxis
//                toLandmarkSegmentType = objectToObject.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
//                toLandmarkSegmentAxis = objectToObject.toLandmarkSegmentToAxis.axis
//                lowerBound = objectToObject.lowerBound
//                upperBound = objectToObject.upperBound
//                toggle = true
//                
//            }else{
//                if let object = sportManager.findSelectedObjects().first {
//                    fromObjectId = object.label
//                    toObjectId = object.label
//                }
//                
//            }
//        }
//        
//    }
//}
//
//struct ObjectToObjectRuleView_Previews: PreviewProvider {
//    static var previews: some View {
//        ObjectToObjectRuleView()
//    }
//}
