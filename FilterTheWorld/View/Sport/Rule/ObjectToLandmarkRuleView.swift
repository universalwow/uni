

import SwiftUI

struct ObjectToLandmarkRuleView: View {
    var objectToLandmark: ObjectToLandmark
    
    @EnvironmentObject var sportManager: SportsManager
    
    @State var lowerBound = 0.0
    @State var upperBound = 0.0
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0

    //    此处的id是label
    @State var objectPosition = ObjectPosition.middle
    @State var fromAxis = CoordinateAxis.X

    @State var toLandmarkType = LandmarkType.LeftShoulder
    @State var toAxis = CoordinateAxis.X
    @State var toLandmarkSegmentType =  LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    


    
    func updateLocalData() {
        let objectToLandmark = sportManager.getRuleObjectToLandmark(id: objectToLandmark.id)
        lowerBound = objectToLandmark.lowerBound
        upperBound = objectToLandmark.upperBound
    }
    
    func updateRemoteData() {
        sportManager.updateRuleObjectToLandmark(objectPosition: objectPosition,
                                                fromAxis: fromAxis,
                                                toLandmarkType: toLandmarkType,
                                                toLandmarkSegmentType: toLandmarkSegmentType,
                                                toAxis: toAxis,
                                                lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: objectToLandmark.id)

    }
    

    
    var body: some View {
        VStack {
            HStack {
                Text("物体相对关节位置")
                Spacer()
                Button(action: {
                    sportManager.removeRuleObjectToLandmark(id: objectToLandmark.id)

                }) {
                    Text("删除")
                }.padding()
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

                    Toggle("规则满足时提示", isOn: $triggeredWhenRuleMet.didSet{ _ in
                        updateRemoteData()
                    })
                }
//                MARK: 有多个物体时，迁移规则可能出错 重新选择关键帧也会导致识别到的物体顺序或者多余而出错
                
                HStack {
                    Spacer()
                    Text("位置")
                    Picker("位置", selection: $objectPosition.didSet{ _ in
                        updateRemoteData()
                        updateLocalData()
                        
                    }) {
                        ForEach(ObjectPosition.allCases) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    Text("当前轴")
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
                    Text("当前关节:")
                    Picker("当前关节", selection: $toLandmarkType.didSet{ _ in
                        updateRemoteData()
                        updateLocalData()
                        
                    }) {
                        ForEach(LandmarkType.allCases) { landmarkType in
                            Text(landmarkType.rawValue).tag(landmarkType)
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
                    
                    
                    Text("相对轴")
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
        }.onAppear{
            let objectToLandmark = sportManager.getRuleObjectToLandmark(id: objectToLandmark.id)
            lowerBound = objectToLandmark.lowerBound
            upperBound = objectToLandmark.upperBound
            
            warningContent = objectToLandmark.warning.content
            triggeredWhenRuleMet = objectToLandmark.warning.triggeredWhenRuleMet
            delayTime = objectToLandmark.warning.delayTime

            fromAxis = objectToLandmark.fromAxis
            objectPosition = objectToLandmark.fromPosition.position
            toLandmarkType = objectToLandmark.toLandmark.landmarkType
            toAxis = objectToLandmark.toLandmarkSegmentToAxis.axis
            toLandmarkSegmentType = objectToLandmark.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
        }
    }
}

