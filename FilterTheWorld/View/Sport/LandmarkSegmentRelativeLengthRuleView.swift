

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
    

    var body : some View {
        VStack {
            Toggle("关节对相对值:", isOn: $relativeLengthToggle.didSet{ isOn in
                    if isOn {
                        let relativeSegment = self.sportManager.findlandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
                        sportManager.setSportStateRuleLength(fromAxis: currentAxis, relativeSegment: relativeSegment, toAxis: relativeAxis)
                        let length = sportManager.getCurrentSportStateRuleLength(fromAxis: currentAxis)!
                        minRelativeLength = length.lowerBound
                        maxRelativeLength = length.upperBound
             
                    }else {
                        self.sportManager.removeSportStateRuleLength(fromAxis: currentAxis)
                    }
            })
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $relativeLengthWarning)
                }
                HStack {
                    Text("当前轴")
                    Text(currentAxis.rawValue)
//                    Picker("当前轴", selection: $currentAxis) {
//                        ForEach(CoordinateAxis.allCases) { axis in
//                            Text(axis.rawValue).tag(axis)
//                        }
//                    }.disabled(true)
                    Spacer()
                    Text("相对关节对")
                    Picker("相对关节对", selection: $relativelandmarkSegmentType.didSet{ _ in
                        let relativeSegment = self.sportManager.findlandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
                        sportManager.updateCurrentSportStateRule(fromAxis: currentAxis, toAxis: relativeAxis, relativeSegment: relativeSegment, warning: relativeLengthWarning)
                        let length = sportManager.getCurrentSportStateRuleLength(fromAxis: currentAxis)!
                        minRelativeLength = length.lowerBound
                        maxRelativeLength = length.upperBound
                        
                    }) {
                        ForEach(LandmarkType.landmarkSegmentTypes) { landmarkSegmentType in
                            Text(landmarkSegmentType.id).tag(landmarkSegmentType)
                        }
                    }
                    
                    Text("相对轴")
                    Picker("相对轴", selection: $relativeAxis.didSet{ _ in
                        let relativeSegment = self.sportManager.findlandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
                        sportManager.updateCurrentSportStateRule(fromAxis: currentAxis, toAxis: relativeAxis, relativeSegment: relativeSegment, warning: relativeLengthWarning)
                        let length = sportManager.getCurrentSportStateRuleLength(fromAxis: currentAxis)!
                        minRelativeLength = length.lowerBound
                        maxRelativeLength = length.upperBound
                    }) {
                        ForEach(CoordinateAxis.allCases) { axis in
                            Text(axis.rawValue).tag(axis)
                        }
                    }
                }
                
                HStack {
                    Text("最小值:")
                    TextField("最小值", value: $minRelativeLength, formatter: formatter)
                        .foregroundColor(self.maxRelativeLength > self.minRelativeLength ? .black : .red)
                    
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    Spacer()
                    Text("最大值:")
                    TextField("最大值", value: $maxRelativeLength, formatter: formatter)
                        .foregroundColor(self.maxRelativeLength > self.minRelativeLength ? .black : .red)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                }
            }
            .disabled(!relativeLengthToggle)
            
        }.onChange(of: relativeLengthWarning) { _ in
            let relativeSegment = self.sportManager.findlandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
            sportManager.updateCurrentSportStateRule(fromAxis: currentAxis, toAxis: relativeAxis, relativeSegment: relativeSegment, warning: relativeLengthWarning)
            
        }.onChange(of: minRelativeLength) { _ in
            print("\(minRelativeLength) - \(maxRelativeLength)")
            self.sportManager.updateSportStateRule(axis: currentAxis, lowerBound: minRelativeLength, upperBound: maxRelativeLength)
        }
        .onChange(of: maxRelativeLength) { _ in
            print("\(minRelativeLength) - \(maxRelativeLength)")
            self.sportManager.updateSportStateRule(axis: currentAxis, lowerBound: minRelativeLength, upperBound: maxRelativeLength)
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

