

import SwiftUI

struct ObjectToStateExtremeRuleView: View {
    var objectToStateExtreme: ObjectToStateExtreme
    
    @EnvironmentObject var sportManager: SportsManager
    
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0

    @State var fromAxis = CoordinateAxis.X
    @State var fromObjectPosition = ObjectPosition.middle
    
    @State var toLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var toAxis = CoordinateAxis.X
    
    @State var toStateId = SportState.startState.id
    @State var isRelativeToExtremeDirection = false
    @State var extremeDirection = ExtremeDirection.MinX
    @State var isRelativeToObject = false


    @State var lowerBound: Double = 0.0
    @State var upperBound: Double = 0.0
    
 
    
    func updateLocalData() {
        let length = sportManager.getRuleObjectToStateExtreme(id: objectToStateExtreme.id)
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
        sportManager.updateRuleObjectToStateExtreme(fromAxis: fromAxis,
                                               toStateId: toStateId,
                                                      fromPosition: fromObjectPosition,
                                                      isRelativeToObject: isRelativeToObject,
                                                      isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                               extremeDirection: extremeDirection,
                                               toLandmarkSegmentType: toLandmarkSegmentType,
                                               toAxis: toAxis,
                                               lowerBound: lowerBound, upperBound: upperBound,
                                               warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: objectToStateExtreme.id)

    }
    

    
    var body: some View {
        VStack {
            
            HStack {
                Text("物体自身(相对状态)位移")
                Spacer()
                
                Spacer()
                Toggle(isOn: $isRelativeToObject.didSet { _ in
                    updateRemoteData()
                    updateLocalData()
                    
                }, label: {
                    Text("相对当前物体").frame(maxWidth: .infinity, alignment: .trailing)
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
                    sportManager.removeRuleObjectToStateExtreme(id: objectToStateExtreme.id)

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
                    Toggle("规则满足时提示", isOn: $triggeredWhenRuleMet.didSet{ _ in
                        updateRemoteData()
                    })
                }
                VStack {

                    
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
                        
                        Text("相对状态")
                        Picker("相对状态", selection: $toStateId.didSet{ _ in
                            print("相对状态-------\(toStateId)")
                            updateRemoteData()
                            updateLocalData()
                        }) {
                            ForEach(sportManager.findFirstSport()!.allHasKeyFrameStates) { state in
                                Text(state.name).tag(state.id)
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
                
            }
        }
        .onAppear{
            let length = sportManager.getRuleObjectToStateExtreme(id: objectToStateExtreme.id)
            
            fromAxis = length.fromPosition.axis
            fromObjectPosition = length.fromPosition.position
            
            warningContent = length.warning.content
            triggeredWhenRuleMet = length.warning.triggeredWhenRuleMet
            delayTime = length.warning.delayTime
                            
            toLandmarkSegmentType = length.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
            toAxis = length.toLandmarkSegmentToAxis.axis
            toStateId = length.toStateId
            isRelativeToExtremeDirection = length.isRelativeToExtremeDirection
            extremeDirection = length.extremeDirection
            isRelativeToObject = length.isRelativeToObject
            lowerBound = length.lowerBound
            upperBound = length.upperBound
            
        }
    }
}


