

import SwiftUI

struct ObjectToLandmarkRuleView: View {
    
    @EnvironmentObject var sportManager: SportsManager
    @State var toggle = false
    
    @State var currentAxis = CoordinateAxis.X
    @State var lowerBound = 0.0
    @State var upperBound = 0.0
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0

    //    此处的id是label
    @State var objectId = ""
    @State var objectPosition = ObjectPosition.middle
    @State var toLandmarkType = LandmarkType.LeftShoulder
    @State var toLandmarkSegmentAxis = CoordinateAxis.X
    @State var toLandmarkSegmentType =  LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    
    func setInitData() {
        let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: toLandmarkSegmentType)
        sportManager.setRuleObjectToLandmark(
            fromAxis: currentAxis,
            landmarkType: toLandmarkType,
            objectId: objectId,
            objectPosition: objectPosition,
            landmarkSegment: relativeSegment,
            toAxis: toLandmarkSegmentAxis, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime)

        
    }

    func resetInitData(){
        if toggle {
            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: toLandmarkSegmentType)
            sportManager.updateRuleObjectToLandmark(
                fromAxis: currentAxis,
                landmarkType: toLandmarkType,
                objectId: objectId,
                objectPosition: objectPosition,
                landmarkSegment: relativeSegment,
                toAxis: toLandmarkSegmentAxis, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime)

         
        }
    }
    
    func updateLocalData() {
        if toggle {
            let objectToLandmark = sportManager.getRuleObjectToLandmark()!
            lowerBound = objectToLandmark.lowerBound
            upperBound = objectToLandmark.upperBound
        }
    }
    
    func updateRemoteData() {
        if toggle {
            sportManager.updateRuleObjectToLandmark(lowerBound: lowerBound, upperBound: upperBound)
        }
    }
    
    func toggleOff() {
        currentAxis = CoordinateAxis.X
        lowerBound = 0.0
        upperBound = 0.0
        warningContent = ""
        triggeredWhenRuleMet = false
        delayTime = 2.0
        
        objectId = sportManager.findSelectedObjects().first!.label
        objectPosition = ObjectPosition.middle
        toLandmarkType = sportManager.findSelectedSegment()!.landmarkTypes.first!
        toLandmarkSegmentAxis = CoordinateAxis.X
        toLandmarkSegmentType =  LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    }
    
    var body: some View {
        VStack {
            Toggle("物体相对于关节位置", isOn: $toggle.didSet{ isOn in
                if isOn {
                    setInitData()
                    updateLocalData()
                }else{
                    sportManager.setRuleObjectToLandmark(objectToLandmark: nil)
                    toggleOff()
                }
                
            })
            VStack {
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
//                MARK: 有多个物体时，迁移规则可能出错 重新选择关键帧也会导致识别到的物体顺序或者多余而出错
                
                HStack {
                    Text("物体")
                    Picker("物体", selection: $objectId.didSet{ _ in
                        resetInitData()
                        updateLocalData()
                        
                    }) {
                        ForEach(sportManager.findSelectedObjects()) { object in
                            Text(object.label).tag(object.label)
                        }
                    }
                    Spacer()
                    Text("位置")
                    Picker("位置", selection: $objectPosition.didSet{ _ in
                        resetInitData()
                        updateLocalData()
                        
                    }) {
                        ForEach(ObjectPosition.allCases) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    Text("当前轴")
                    Picker("当前轴", selection: $currentAxis.didSet { _ in
                        resetInitData()
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
                        resetInitData()
                        updateLocalData()
                        
                    }) {
                        ForEach(self.sportManager.findSelectedSegment()!.landmarkTypes) { landmarkType in
                            Text(landmarkType.rawValue).tag(landmarkType)
                        }
                    }
                    Spacer()

                    Text("相对关节对")
                    Picker("相对关节对", selection: $toLandmarkSegmentType.didSet{ _ in
                        resetInitData()
                        updateLocalData()
                        
                    }) {
                        ForEach(LandmarkType.landmarkSegmentTypes) { landmarkSegmentType in
                            Text(landmarkSegmentType.id).tag(landmarkSegmentType)
                        }
                    }
                    
                    
                    Text("相对轴")
                    Picker("相对轴", selection: $toLandmarkSegmentAxis.didSet{ _ in
                        resetInitData()
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
                
                
            }.disabled(!toggle)
        }.onAppear{
            if let objectToLandmark = sportManager.getRuleObjectToLandmark() {
                lowerBound = objectToLandmark.lowerBound
                upperBound = objectToLandmark.upperBound
                warningContent = objectToLandmark.warning.content
                triggeredWhenRuleMet = objectToLandmark.warning.triggeredWhenRuleMet
                delayTime = objectToLandmark.warning.delayTime

                currentAxis = objectToLandmark.fromAxis
                objectId = objectToLandmark.fromPosition.id
                objectPosition = objectToLandmark.fromPosition.position
                toLandmarkType = objectToLandmark.toLandmark.landmarkType
                toLandmarkSegmentAxis = objectToLandmark.toLandmarkSegmentToAxis.axis
                toLandmarkSegmentType = objectToLandmark.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
                toggle = true
                
                
            } else {
                self.toLandmarkType = sportManager.findSelectedSegment()!.landmarkTypes.first!
                if let object = sportManager.findSelectedObjects().first {
                    objectId = object.label

                }
            }
        }
    }
}

struct ObjectToLandmarkRuleView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectToLandmarkRuleView()
    }
}
