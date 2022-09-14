

import SwiftUI

struct ObjectToObjectRuleView: View {
    
    var objectToObject: ObjectToObject
    
    @EnvironmentObject var sportManager: SportsManager
    
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    @State var changeStateClear = true


    @State var fromAxis = CoordinateAxis.X
//    此处id为label
    @State var fromObjectPosition = ObjectPosition.middle
    @State var toObjectId = ""
    @State var toObjectPosition = ObjectPosition.middle
  
    @State var toLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var toAxis = CoordinateAxis.X
    @State var lowerBound = 0.0
    @State var upperBound = 0.0
    
    @State var isRelativeToObject = false


    func updateLocalData() {
        let objectToObject = sportManager.getRuleObjectToObject(id: objectToObject.id)
        lowerBound = objectToObject.lowerBound
        upperBound = objectToObject.upperBound
    }
    
    func updateRemoteData() {
        sportManager.updateRuleObjectToObject(fromAxis: fromAxis,fromObjectPosition: fromObjectPosition,toObjectId: toObjectId, toObjectPosition: toObjectPosition, toLandmarkSegmentType: toLandmarkSegmentType, toAxis: toAxis,     lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: objectToObject.id, isRelativeToObject: isRelativeToObject)

    }
    

    var body: some View {
        VStack {
            
            HStack {
                Text("物体相对物体位置")
                Spacer()
                Toggle(isOn: $changeStateClear.didSet{ _ in
                    updateRemoteData()
                }, label: {
                    Text("状态切换清除提示").frame(maxWidth: .infinity, alignment: .trailing)
                })
                Toggle(isOn: $isRelativeToObject.didSet { _ in
                    updateRemoteData()
                    updateLocalData()
                    
                }, label: {
                    Text("相对当前物体").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Button(action: {
                    sportManager.removeRuleObjectToObject(id: objectToObject.id)
                }) {
                    Text("删除")
                }.padding([.vertical, .leading])
            }
            
            VStack {
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
                
                
                
                HStack {
                    
                    HStack {
                        HStack {
                            
                            Text("位置")
                            Picker("位置", selection: $fromObjectPosition.didSet{ _ in
                                updateRemoteData()
                                updateLocalData()
                                
                            }) {
                                ForEach(ObjectPosition.allCases) { position in
                                    Text(position.rawValue).tag(position)
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
                        }
                        
                        HStack {
                            Text("物体")
                            Picker("物体", selection: $toObjectId.didSet{ _ in
                                updateRemoteData()
                                updateLocalData()
                                
                            }) {
                                ForEach(sportManager.findSelectedObjects()) { object in
                                    Text(object.label).tag(object.label)
                                }
                            }
                            Text("/")
                            Picker("位置", selection: $toObjectPosition.didSet{ _ in
                                updateRemoteData()
                                updateLocalData()
                                
                            }) {
                                ForEach(ObjectPosition.allCases) { position in
                                    Text(position.rawValue).tag(position)
                                }
                            }
                        }
                        
                        
                    }
                    Spacer()
                    HStack {
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
                    }.disabled(isRelativeToObject)
                    
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
        }.onAppear{
            let objectToObject = sportManager.getRuleObjectToObject(id: objectToObject.id)
            warningContent = objectToObject.warning.content
            triggeredWhenRuleMet = objectToObject.warning.triggeredWhenRuleMet
            delayTime = objectToObject.warning.delayTime
            changeStateClear = objectToObject.warning.changeStateClear == true
            
            fromAxis = objectToObject.fromPosition.axis
            fromObjectPosition = objectToObject.fromPosition.position
            toObjectId = objectToObject.toPosition.id
            toObjectPosition = objectToObject.toPosition.position
            
            toLandmarkSegmentType = objectToObject.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
            toAxis = objectToObject.toLandmarkSegmentToAxis.axis
            
            lowerBound = objectToObject.lowerBound
            upperBound = objectToObject.upperBound
            
            isRelativeToObject = objectToObject.isRelativeToObject

        }
        
    }
}


