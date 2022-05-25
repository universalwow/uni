

import SwiftUI

struct LandmarkSegmentRelativeLengthRuleView: View {
    
    @EnvironmentObject var sportManager: SportsManager
    
    //相对长度
    @State var currentAxis : CoordinateAxis = .X
    @State var relativeAxis : CoordinateAxis = .X
    @State var relativelandmarkSegmentType: LandmarkTypeSegment = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    
    @State var minRelativeLength = 0.0
    @State var maxRelativeLength = 0.0
    
    @State var relativeLengthToggle = false
    @State var relativeLengthWarning = ""
    
    func resetInitData() {
        if relativeLengthToggle {
            let relativeSegment = self.sportManager.findlandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
            sportManager.updateCurrentSportStateRule(fromAxis: currentAxis, toAxis: relativeAxis, relativeSegment: relativeSegment, warning: relativeLengthWarning)
        }

    }
    func setInitData() {
        if relativeLengthToggle {
            let relativeSegment = self.sportManager.findlandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
            sportManager.setSportStateRuleLength(fromAxis: currentAxis, relativeSegment: relativeSegment, toAxis: relativeAxis)
        }
        
    }
    
    func toggleOff() {
        currentAxis = .X
        relativeAxis = .X
        relativelandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
        minRelativeLength = 0.0
        maxRelativeLength = 0.0
        relativeLengthWarning = ""
    }
    
    func updateLocalLength() {
        if relativeLengthToggle {
            let length = sportManager.getCurrentSportStateRuleLength(fromAxis: currentAxis)!
            minRelativeLength = length.lowerBound
            maxRelativeLength = length.upperBound
            print("2 \(minRelativeLength)  - \(maxRelativeLength)")
        }
        
    }
    
    func updateRemoveLength() {
        if relativeLengthToggle {
            self.sportManager.updateSportStateRule(axis: currentAxis, lowerBound: minRelativeLength , upperBound: maxRelativeLength)

        }
    }
    
    var body : some View {
        VStack {
            Toggle("关节对相对值", isOn: $relativeLengthToggle.didSet{ isOn in
                    if isOn {
                        
                        setInitData()
                        updateLocalLength()
             
                    }else {
                        self.sportManager.removeSportStateRuleLength(fromAxis: currentAxis)
                        toggleOff()
                        
                    }
            })
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $relativeLengthWarning, onEditingChanged: { flag in
                        if !flag {
                            resetInitData()
                        }
                        
                    })
                }
                HStack {
                    Text("当前轴")
                    Picker("当前轴", selection: $currentAxis.didSet { _ in
                                                    setInitData()
                                                    updateLocalLength()
                                                    
                                                }) {
                        ForEach(CoordinateAxis.allCases) { axis in
                            Text(axis.rawValue).tag(axis)
                        }
                    }
                    Spacer()
                    Text("相对关节对")
                    Picker("相对关节对", selection: $relativelandmarkSegmentType.didSet{ _ in
                        print("相对关节对")
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
                    TextField("最小值", value: $minRelativeLength, formatter: formatter,onEditingChanged: { flag in
                        if !flag {
                            print("0 \(minRelativeLength)  - \(maxRelativeLength)")
                            updateRemoveLength()
                        }
                        
                    })
                        .foregroundColor(self.maxRelativeLength >= self.minRelativeLength ? .black : .red)
                    
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    Spacer()
                    Text("最大值:")
                    
                    TextField("最大值", value: $maxRelativeLength, formatter: formatter, onEditingChanged: { flag in
                        if !flag {
                            print("1 \(minRelativeLength)  - \(maxRelativeLength)")
                            updateRemoveLength()
                        }
                        
                    })
                        .foregroundColor(self.maxRelativeLength >= self.minRelativeLength ? .black : .red)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                }
            }
            .disabled(!relativeLengthToggle)
            
        }
        .onAppear{
//            存在时加载
            if let length = sportManager.getCurrentSportStateRuleLength(fromAxis: currentAxis) {
                self.currentAxis = length.from.axis
                self.relativeAxis = length.to.axis
                self.relativelandmarkSegmentType = length.to.landmarkSegment.landmarkSegmentType
                self.minRelativeLength = length.lowerBound
                self.maxRelativeLength = length.upperBound
                self.relativeLengthWarning = length.warning
                self.relativeLengthToggle = true
            }
        }
    }
    
}

