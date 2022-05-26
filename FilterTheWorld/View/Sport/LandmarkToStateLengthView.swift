

import SwiftUI

struct LandmarkToStateLengthView: View {
    
    @EnvironmentObject var sportManager: SportsManager
    
    @State var landmarkToStateToggle = false
    @State var landmarkToStateWarning = ""
    @State var landmarkTypeToState = LandmarkType.LeftAnkle
    @State var currentAxis = CoordinateAxis.X
    @State var relativelandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var relativeAxis = CoordinateAxis.X
    @State var minRelativeLength: Double = 0.0
    @State var maxRelativeLength: Double = 0.0
    @State var relativeToState = SportState.startState.id
    
    
    func resetInitData() {
        if landmarkToStateToggle {
            let relativeSegment = self.sportManager.findlandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
            sportManager.updateSportStateRuleMutiFrame(fromAxis: currentAxis, landmarkType: landmarkTypeToState, stateId: relativeToState, landmarkSegment: relativeSegment, toAxis: relativeAxis, warning: landmarkToStateWarning)
        }
       
    }
    
    func setInitData() {
        if landmarkToStateToggle {
            let relativeSegment = self.sportManager.findlandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
            sportManager.setSportStateRuleMultiFrameLength(fromAxis: currentAxis, relativeSegment: relativeSegment, toAxis: relativeAxis, toStateId: relativeToState)
        }

    }
    
    func updateLocalLength() {
        if landmarkToStateToggle {
            let length = sportManager.getCurrentSportStateRuleMultiFrameLength(fromAxis: currentAxis)!
            minRelativeLength = length.lowerBound
            maxRelativeLength = length.upperBound
        }
 
    }
    
    func updateRemoveLength() {
        if landmarkToStateToggle {
            sportManager.updateCurrentRuleMultiFrame(axis: currentAxis, lowerBound: minRelativeLength, upperBound: maxRelativeLength)
        }
    }
    
    
    func toggleOff() {
        landmarkToStateWarning = ""
        landmarkTypeToState =  sportManager.findselectedSegment()!.landmarkTypes.first!
        currentAxis = CoordinateAxis.X
        relativelandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
        relativeAxis = CoordinateAxis.X
        minRelativeLength = 0.0
        maxRelativeLength = 0.0
        relativeToState = SportState.startState.id
    }
    
    var body: some View {
        VStack {
            Toggle("关节相对状态位移", isOn: $landmarkToStateToggle.didSet { isOn in
                if isOn {
                    setInitData()
                    updateLocalLength()
                } else {
                    sportManager.removeSportStateRuleLengthMutiFrame(fromAxis: currentAxis)
                    toggleOff()
                }
                
            })
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $landmarkToStateWarning) { flag in
                        if !flag {
                            resetInitData()
                        }
                        
                    }
                }
                VStack {
                    HStack {
                        Text("当前关节:")
                        Picker("当前关节", selection: $landmarkTypeToState.didSet{ _ in
                            resetInitData()
                            updateLocalLength()
                            
                        }) {
                            ForEach(self.sportManager.findselectedSegment()!.landmarkTypes) { landmarkType in
                                Text(landmarkType.rawValue).tag(landmarkType)
                            }
                        }
                        
                        Spacer()

                        Text("当前轴")
                        Picker("当前轴", selection: $currentAxis.didSet { _ in
//                            resetInitData()
//                            updateLocalLength()
                            setInitData()
                            updateLocalLength()
                            
                        }) {
                            ForEach(CoordinateAxis.allCases) { axis in
                                Text(axis.rawValue).tag(axis)
                            }
                        }
                    }
                    
                    HStack {
                        Text("相对状态")
                        Picker("相对状态", selection: $relativeToState.didSet{ _ in
                            print("相对状态-------\(relativeToState)")
                            resetInitData()
                            updateLocalLength()
                        }) {
                            ForEach(sportManager.findFirstSport()!.allStates) { state in
                                Text(state.name).tag(state.id)
                            }
                        }
                        Spacer()

                        Text("相对关节对")
                        Picker("相对关节对", selection: $relativelandmarkSegmentType.didSet{ _ in
                            resetInitData()
                            updateLocalLength()
                            
                        }) {
                            ForEach(LandmarkType.landmarkSegmentTypes) { landmarkSegmentType in
                                Text(landmarkSegmentType.id).tag(landmarkSegmentType)
                            }
                        }
                        
                        Text("相对轴")
                        Picker("相对轴", selection: $relativeAxis.didSet{ _ in
                            resetInitData()
                            updateLocalLength()
                        }) {
                            ForEach(CoordinateAxis.allCases) { axis in
                                Text(axis.rawValue).tag(axis)
                            }
                        }
                    }
                    HStack {
                        Text("最小值:")
                        TextField("最小值", value: $minRelativeLength, formatter: formatter) { flag in
                            if !flag {
                                updateRemoveLength()

                            }
                            
                        }
                            .foregroundColor(self.maxRelativeLength >= self.minRelativeLength ? .black : .red)
                        
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        Spacer()
                        Text("最大值:")
                        TextField("最大值", value: $maxRelativeLength, formatter: formatter){ flag in
                            if !flag {
                                updateRemoveLength()

                            }
                            
                        }
                            .foregroundColor(self.maxRelativeLength >= self.minRelativeLength ? .black : .red)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        
                    }
                    
                }
                
            }.disabled(!landmarkToStateToggle)
        }
        .onAppear{
            if let length = sportManager.getCurrentSportStateRuleMultiFrameLength(fromAxis: currentAxis) {
                landmarkToStateToggle = true
                landmarkToStateWarning = length.warning
                landmarkTypeToState = length.fromLandmarkToAxis.landmark.landmarkType
                currentAxis = length.fromLandmarkToAxis.axis
                relativelandmarkSegmentType = length.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
                relativeAxis = length.toLandmarkSegmentToAxis.axis
                relativeToState = length.toStateId
                minRelativeLength = length.lowerBound
                maxRelativeLength = length.upperBound
            }else {
                self.landmarkTypeToState = self.sportManager.findselectedSegment()!.landmarkTypes.first!
            }
            
        }
    }
}

struct LandmarkToStateLengthView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkToStateLengthView()
    }
}
