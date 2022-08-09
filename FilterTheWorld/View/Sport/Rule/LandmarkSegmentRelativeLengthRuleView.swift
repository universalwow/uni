

import SwiftUI

struct LandmarkSegmentRelativeLengthRuleView: View {
    
    @EnvironmentObject var sportManager: SportsManager
    
    //相对长度
    @State var currentAxis : CoordinateAxis = .X
    @State var relativeAxis : CoordinateAxis = .X
    @State var relativelandmarkSegmentType: LandmarkTypeSegment = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    
    @State var minRelativeLength = 0.0
    @State var maxRelativeLength = 0.0
    
    @State var toggle = false
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0

    
    func setInitData() {
        if toggle {
            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
         
            sportManager.setRuleLandmarkSegmentLength(fromAxis: currentAxis, relativeSegment: relativeSegment, toAxis: relativeAxis, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime)
        }
    }
    
    func resetInitData() {
        if toggle {
            let relativeSegment = self.sportManager.findLandmarkSegment(landmarkTypeSegment: relativelandmarkSegmentType)
            sportManager.updateRuleLandmarkSegmentLength(fromAxis: currentAxis, relativeSegment: relativeSegment, toAxis: relativeAxis, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime)
    
        }

    }
    
    
    func toggleOff() {
        currentAxis = .X
        relativeAxis = .X
        relativelandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
        minRelativeLength = 0.0
        maxRelativeLength = 0.0
        warningContent = ""
        triggeredWhenRuleMet = false
        delayTime = 2.0

    }
    
    func updateLocalData() {
        if toggle {
            let length = sportManager.getRuleLandmarkSegmentLength()!
            minRelativeLength = length.lowerBound
            maxRelativeLength = length.upperBound
            print("2 \(minRelativeLength)  - \(maxRelativeLength)")
        }
        
    }
    
    func updateRemoteData() {
        if toggle {
            self.sportManager.updateRuleLandmarkSegmentLength(lowerBound: minRelativeLength , upperBound: maxRelativeLength)

        }
    }
    
    var body : some View {
        VStack {
            Toggle("关节对相对值", isOn: $toggle.didSet{ isOn in
                    if isOn {
                        
                        setInitData()
                        updateLocalData()
             
                    }else {
                    sportManager.setRuleLandmarkSegmentLength(length: nil)
                    toggleOff()
                        
                    }
            })
            VStack{
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
                HStack {
                    Text("当前轴")
                    Picker("当前轴", selection: $currentAxis.didSet { _ in
                                                    resetInitData()
                                                    updateLocalData()
                                                    
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
                        updateLocalData()
                        
                    }) {
                        ForEach(LandmarkType.landmarkSegmentTypesForSetRule) { landmarkSegmentType in
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
                
                HStack {
                    Text("最小值:")
                    TextField("最小值", value: $minRelativeLength, formatter: formatter,onEditingChanged: { flag in
                        if !flag {
                            print("0 \(minRelativeLength)  - \(maxRelativeLength)")
                            updateRemoteData()
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
                            updateRemoteData()
                        }
                        
                    })
                        .foregroundColor(self.maxRelativeLength >= self.minRelativeLength ? .black : .red)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                }
            }
            .disabled(!toggle)
        }
        .onAppear{
//            存在时加载
            if let length = sportManager.getRuleLandmarkSegmentLength() {
                self.currentAxis = length.from.axis
                self.relativeAxis = length.to.axis
                self.relativelandmarkSegmentType = length.to.landmarkSegment.landmarkSegmentType
                self.minRelativeLength = length.lowerBound
                self.maxRelativeLength = length.upperBound
                self.warningContent = length.warning.content
                self.triggeredWhenRuleMet = length.warning.triggeredWhenRuleMet
                self.delayTime = length.warning.delayTime
                self.toggle = true
            }
        }
    }
    
}

