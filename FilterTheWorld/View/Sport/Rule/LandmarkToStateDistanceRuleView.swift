

import SwiftUI

struct LandmarkToStateDistanceRuleView: View {
    var landmarkToStateDistance: LandmarkToStateDistance
    
    @EnvironmentObject var sportManager: SportsManager
    
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    @State var changeStateClear = true

    @State var fromAxis = CoordinateAxis.X
    @State var toLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var toAxis = CoordinateAxis.X
    
    @State var toStateId = SportState.startState.id
    @State var isRelativeToExtremeDirection = false
    @State var defaultSatisfy = false
    @State var extremeDirection = ExtremeDirection.MinX

    @State var lowerBound: Double = 0.0
    @State var upperBound: Double = 0.0
    @State var toLandmarkType = LandmarkType.LeftShoulder
    
    @State var toStateToggle: Bool = false
    @State var toLastFrameToggle: Bool = false
    
    
    func updateLocalData() {
        let length = sportManager.getRuleLandmarkToStateDistance(id: landmarkToStateDistance.id)
        lowerBound = length.lowerBound
        upperBound = length.upperBound
        
        switch fromAxis {
        case .X:
            if lowerBound > 0 {
                extremeDirection = .MinX
            } else {
                extremeDirection = .MaxX
            }
        case .Y:
            if lowerBound > 0 {
                extremeDirection = .MinY
            } else {
                extremeDirection = .MaxY
            }
        case .XY:
            break
        }
 
    }
    
    func updateRemoteData() {
        sportManager.updateRuleLandmarkToStateDistance(fromAxis: fromAxis,
                                               toStateId: toStateId,
                                                       toLandmarkType: toLandmarkType,
                                                       
                                                      isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                               extremeDirection: extremeDirection,
                                               toLandmarkSegmentType: toLandmarkSegmentType,
                                               toAxis: toAxis,
                                               lowerBound: lowerBound, upperBound: upperBound,
                                                       warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: landmarkToStateDistance.id, defaultSatisfy: defaultSatisfy, toStateToggle: toStateToggle, toLastFrameToggle: toLastFrameToggle)

    }
    

    
    var body: some View {
        VStack {
            
            HStack {
                Text("关节(相对状态)位移")
                Spacer()
                
                Toggle(isOn: $changeStateClear.didSet{ _ in
                    updateRemoteData()
                }, label: {
                    Text("状态切换清除提示").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Toggle(isOn: $isRelativeToExtremeDirection.didSet { _ in
                    updateRemoteData()
                }, label: {
                    Text("相对极值").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Text("极值选择")
                Picker("极值选择", selection: $extremeDirection.didSet{ _ in
                    updateRemoteData()

                }) {
                    ForEach(ExtremeDirection.allCases) { direction in
                        Text(direction.rawValue).tag(direction)
                    }
                }.disabled(!isRelativeToExtremeDirection)
                
                Button(action: {
                    sportManager.removeRuleLandmarkToStateDistance(id: landmarkToStateDistance.id)

                }) {
                    Text("删除")
                }.padding([.vertical, .leading])
            }
            
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $warningContent) { flag in
                        if !flag {
                            updateRemoteData()
                        }
                        
                    }
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
                VStack {

                    
                    HStack {
                        Text("当前轴")
                        Picker("当前轴", selection: $fromAxis.didSet { _ in

                            updateRemoteData()
                            updateLocalData()
                            
                        }) {
                            ForEach(CoordinateAxis.allCases) { axis in
                                Text(axis.rawValue).tag(axis)
                            }
                        }
                        
                        Text("状态/关节")
                        Picker("相对状态", selection: $toStateId.didSet{ _ in
                            print("相对状态-------\(toStateId)")
                            updateRemoteData()
                            updateLocalData()
                        }) {
                            ForEach(sportManager.findFirstSport()!.allHasKeyFrameStates) { state in
                                Text(state.name).tag(state.id)
                            }
                        }
                        Picker("相对关节", selection: $toLandmarkType.didSet{ _ in
                            updateRemoteData()
                            updateLocalData()
                            
                        }) {
                            ForEach(LandmarkType.allCases) { landmarkType in
                                Text(landmarkType.rawValue).tag(landmarkType)
                            }
                        }
                        
                        Spacer()

                        Text("关节对")
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
                        
                        Toggle(isOn: $defaultSatisfy.didSet { _ in
                            updateRemoteData()
                        }, label: {
                            Text("默认满足").frame(maxWidth: .infinity, alignment: .trailing)
                        })
                        
                    }
                    
                    HStack {
                        Toggle(isOn: $toStateToggle.didSet { _ in
                            updateRemoteData()
                        }, label: {
                            Text("状态开关").frame(maxWidth: .infinity, alignment: .trailing)
                        })
                        Spacer()
                        Toggle(isOn: $toLastFrameToggle.didSet { _ in
                            updateRemoteData()
                        }, label: {
                            Text("帧开关").frame(maxWidth: .infinity, alignment: .trailing)
                        })
                                                
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                    }
                    
                }
                
            }
        }
        .onAppear{
            let length = sportManager.getRuleLandmarkToStateDistance(id: landmarkToStateDistance.id)
            warningContent = length.warning.content
            triggeredWhenRuleMet = length.warning.triggeredWhenRuleMet
            delayTime = length.warning.delayTime
            changeStateClear = length.warning.changeStateClear == true
                            
            fromAxis = length.fromLandmarkToAxis.axis
            toLandmarkSegmentType = length.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
            toAxis = length.toLandmarkSegmentToAxis.axis
            toStateId = length.toStateId
            isRelativeToExtremeDirection = length.isRelativeToExtremeDirection
            extremeDirection = length.extremeDirection
            lowerBound = length.lowerBound
            upperBound = length.upperBound
            defaultSatisfy = length.defaultSatisfy ?? true
            toLandmarkType = length.toLandmarkToAxis.landmark.landmarkType
            
            toStateToggle = length.toStateToggle ?? false
            toLastFrameToggle = length.toLastFrameToggle ?? false
            
        }
    }
}


struct LandmarkToStateDistanceMergeRuleView: View {
    var landmarkToStateDistance: LandmarkToStateDistance
    
    @EnvironmentObject var sportManager: SportsManager
    
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    @State var changeStateClear = true

    @State var fromAxis = CoordinateAxis.X
    @State var toLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var toAxis = CoordinateAxis.X
    
    @State var toStateId = SportState.startState.id
    @State var isRelativeToExtremeDirection = false
    @State var defaultSatisfy = false
    @State var extremeDirection = ExtremeDirection.MinX

    @State var lowerBound: Double = 0.0
    @State var upperBound: Double = 0.0
    @State var toLandmarkType = LandmarkType.LeftShoulder

    @State var toStateToggle: Bool = false
    @State var toLastFrameToggle: Bool = false
    @State var weight: Double = 1
 
    
    func updateLocalData() {
        let length = sportManager.getRuleLandmarkToStateDistanceMerge(id: landmarkToStateDistance.id)
        lowerBound = length.lowerBound
        upperBound = length.upperBound
        
        switch fromAxis {
        case .X:
            if lowerBound > 0 {
                extremeDirection = .MinX
            } else {
                extremeDirection = .MaxX
            }
        case .Y:
            if lowerBound > 0 {
                extremeDirection = .MinY
            } else {
                extremeDirection = .MaxY
            }
        case .XY:
            break
        }
 
    }
    
    func updateRemoteData() {
        sportManager.updateRuleLandmarkToStateDistanceMerge(fromAxis: fromAxis,
                                               toStateId: toStateId,
                                                       toLandmarkType: toLandmarkType,
                                                       
                                                      isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                               extremeDirection: extremeDirection,
                                               toLandmarkSegmentType: toLandmarkSegmentType,
                                               toAxis: toAxis,
                                               lowerBound: lowerBound, upperBound: upperBound,
                                                            warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: landmarkToStateDistance.id, defaultSatisfy: defaultSatisfy, toStateToggle: toStateToggle, toLastFrameToggle: toLastFrameToggle, weight: weight)

    }
    

    
    var body: some View {
        VStack {
            
            HStack {
                Text("关节(相对状态)位移")
                Spacer()
                
                Toggle(isOn: $changeStateClear.didSet{ _ in
                    updateRemoteData()
                }, label: {
                    Text("状态切换清除提示").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Toggle(isOn: $isRelativeToExtremeDirection.didSet { _ in
                    updateRemoteData()
                }, label: {
                    Text("相对极值").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Text("极值选择")
                Picker("极值选择", selection: $extremeDirection.didSet{ _ in
                    updateRemoteData()

                }) {
                    ForEach(ExtremeDirection.allCases) { direction in
                        Text(direction.rawValue).tag(direction)
                    }
                }.disabled(!isRelativeToExtremeDirection)
                
                Button(action: {
                    sportManager.removeRuleLandmarkToStateDistanceMerge(id: landmarkToStateDistance.id)

                }) {
                    Text("删除")
                }.padding([.vertical, .leading])
            }
            
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $warningContent) { flag in
                        if !flag {
                            updateRemoteData()
                        }
                        
                    }
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
                VStack {

                    
                    HStack {
                        Text("当前轴")
                        Picker("当前轴", selection: $fromAxis.didSet { _ in

                            updateRemoteData()
                            updateLocalData()
                            
                        }) {
                            ForEach(CoordinateAxis.allCases) { axis in
                                Text(axis.rawValue).tag(axis)
                            }
                        }
                        
                        Text("状态/关节")
                        Picker("相对状态", selection: $toStateId.didSet{ _ in
                            print("相对状态-------\(toStateId)")
                            updateRemoteData()
                            updateLocalData()
                        }) {
                            ForEach(sportManager.findFirstSport()!.allHasKeyFrameStates) { state in
                                Text(state.name).tag(state.id)
                            }
                        }
                        Picker("相对关节", selection: $toLandmarkType.didSet{ _ in
                            updateRemoteData()
                            updateLocalData()
                            
                        }) {
                            ForEach(LandmarkType.allCases) { landmarkType in
                                Text(landmarkType.rawValue).tag(landmarkType)
                            }
                        }
                        
                        Spacer()

                        Text("关节对")
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
                        
                        Toggle(isOn: $defaultSatisfy.didSet { _ in
                            updateRemoteData()
                        }, label: {
                            Text("默认满足").frame(maxWidth: .infinity, alignment: .trailing)
                        })
                        
                    }
                    
                }
                
                HStack {
                    Toggle(isOn: $toStateToggle.didSet { _ in
                        updateRemoteData()
                    }, label: {
                        Text("状态开关").frame(maxWidth: .infinity, alignment: .trailing)
                    })
                    Spacer()
                    Toggle(isOn: $toLastFrameToggle.didSet { _ in
                        updateRemoteData()
                    }, label: {
                        Text("帧开关").frame(maxWidth: .infinity, alignment: .trailing)
                    })
                    
                    Text("权重:")
                    TextField("权重值", value: $weight, formatter: formatter) { flag in
                        if !flag {
                            updateRemoteData()

                        }
                        
                    }
                    .foregroundColor(.black)
                    
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
            }
        }
        .onAppear{
            let length = sportManager.getRuleLandmarkToStateDistanceMerge(id: landmarkToStateDistance.id)
            warningContent = length.warning.content
            triggeredWhenRuleMet = length.warning.triggeredWhenRuleMet
            delayTime = length.warning.delayTime
            changeStateClear = length.warning.changeStateClear == true
                            
            fromAxis = length.fromLandmarkToAxis.axis
            toLandmarkSegmentType = length.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
            toAxis = length.toLandmarkSegmentToAxis.axis
            toStateId = length.toStateId
            isRelativeToExtremeDirection = length.isRelativeToExtremeDirection
            extremeDirection = length.extremeDirection
            lowerBound = length.lowerBound
            upperBound = length.upperBound
            defaultSatisfy = length.defaultSatisfy ?? true
            toLandmarkType = length.toLandmarkToAxis.landmark.landmarkType
            
            toStateToggle = length.toStateToggle ?? false
            toLastFrameToggle = length.toLastFrameToggle ?? false
            weight = length.weight ?? 1
            
        }
    }
}



