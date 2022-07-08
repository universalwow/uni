

import SwiftUI

/*
 * 物体与上一状态相比相对自身位移
 */

struct LandmarkToSelfRuleView: View {
    
    @EnvironmentObject var sportManager: SportsManager
    
    @State var toggle = false
    @State var warning = ""
    @State var landmarkType = LandmarkType.LeftAnkle
    @State var direction = Direction.UP
    @State var relativelandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var relativeAxis = CoordinateAxis.X
    @State var xLowerBound = 0.0
    @State var yLowerBound = 0.0
    
    
    func setInitData() {
        if toggle {
            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)

            sportManager.setRuleLandmarkToSelf(landmarkType: landmarkType, direction: direction, toLandmarkSegment: relativeSegment, toAxis: relativeAxis, xLowerBound: xLowerBound, yLowerBound: yLowerBound, warning: warning)
         
        }

    }
    
    func resetInitData() {
        if toggle {
            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
            sportManager.updateRuleLandmarkToSelf(landmarkType: landmarkType, direction: direction, toLandmarkSegment: relativeSegment, toAxis: relativeAxis, xLowerBound: xLowerBound, yLowerBound: yLowerBound, warning: warning)
        }
       
    }
 
    
    func updateLocalData() {
        if toggle {

        }
 
    }
    
    func updateRemoteData() {
        if toggle {
            sportManager.updateRuleLandmarkToSelf(xLowerBound: xLowerBound, yLowerBound: yLowerBound)
        }
    }
    
    
    func toggleOff() {
        warning = ""
        landmarkType = LandmarkType.LeftAnkle
        direction = Direction.UP
        relativelandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
        relativeAxis = CoordinateAxis.X
        xLowerBound = 0.0
        yLowerBound = 0.0
    }
    
    var body: some View {
        VStack {
            Toggle("关节相对自身位移", isOn: $toggle.didSet { isOn in
                if isOn {
                    setInitData()
                    updateLocalData()
                } else {
                    sportManager.setRuleLandmarkToSelf(landmarkToSelf: nil)
                    toggleOff()
                }
                
            })
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $warning) { flag in
                        if !flag {
                            resetInitData()
                        }
                        
                    }
                }
                VStack {
                    HStack {
                        Text("关节")
                        Picker("关节", selection: $landmarkType.didSet{ _ in
                            resetInitData()
                            updateLocalData()
                            
                        }) {
                            ForEach(LandmarkType.allCases) { _landmarkType in
                                Text(_landmarkType.rawValue).tag(_landmarkType)
                            }
                        }
                        Spacer()
                        Text("方向")
                        Picker("方向", selection: $direction.didSet{ _ in
                            resetInitData()
                            updateLocalData()
                            
                        }) {
                            ForEach(Direction.allCases) { direction in
                                Text(direction.rawValue).tag(direction)
                            }
                        }
                        Spacer()
                        
                        HStack {
                            Text("相对关节对")
                            Picker("相对关节对", selection: $relativelandmarkSegmentType.didSet{ _ in
                                resetInitData()
                                updateLocalData()
                                
                            }) {
                                ForEach(LandmarkType.landmarkSegmentTypes) { landmarkSegmentType in
                                    Text(landmarkSegmentType.id).tag(landmarkSegmentType)
                                }
                            }
                            
                            Text("相对轴")
                            Picker("相对轴", selection: $relativeAxis.didSet{ _ in
                                resetInitData()
                                updateLocalData()
                            }) {
                                ForEach(CoordinateAxis.allCases) { axis in
                                    Text(axis.rawValue).tag(axis)
                                }
                            }
                        }
                        
                        
                        
                    }
                    
                    
                    HStack {
                        Text("X最小值:")
                        TextField("X最小值", value: $xLowerBound, formatter: formatter) { flag in
                            if !flag {
                                updateRemoteData()

                            }
                            
                        }
                            .foregroundColor(.black)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        Spacer()
                        Text("Y最小值:")
                        TextField("Y最小值", value: $yLowerBound, formatter: formatter) { flag in
                            if !flag {
                                updateRemoteData()
                            }
                            
                        }
                            .foregroundColor(.black)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                }
                
            }.disabled(!toggle)
        }
        .onAppear{
            if let landmarkToSelf = sportManager.getRuleLandmarkToSelf() {
                warning = landmarkToSelf.warning
                landmarkType = landmarkToSelf.landmarkType
                direction = landmarkToSelf.toDirection
                relativelandmarkSegmentType = landmarkToSelf.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
                relativeAxis = landmarkToSelf.toLandmarkSegmentToAxis.axis
                
                xLowerBound = landmarkToSelf.xLowerBound
                yLowerBound = landmarkToSelf.yLowerBound
                
                toggle = true

            }else {
                
            }
            
        }
    }
}

