

import SwiftUI

struct LandmarkSegmentLengthRuleView: View {
    var landmarkSegmentLength: LandmarkSegmentLength
    
    @EnvironmentObject var sportManager: SportsManager
    
    //相对长度
    @State var fromAxis : CoordinateAxis = .X
    @State var toAxis : CoordinateAxis = .X
    @State var tolandmarkSegmentType: LandmarkTypeSegment = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    
    @State var lowerBound = 0.0
    @State var upperBound = 0.0
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    @State var changeStateClear = true
    
    
    func updateLocalData() {
        let length = sportManager.getRuleLandmarkSegmentLength(id: landmarkSegmentLength.id)
        lowerBound = length.lowerBound
        upperBound = length.upperBound
        
    }
    
    func updateRemoteData() {
        self.sportManager.updateRuleLandmarkSegmentLength(fromAxis: fromAxis, tolandmarkSegmentType: tolandmarkSegmentType, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: landmarkSegmentLength.id)
    }
    
    var body : some View {
        VStack {
            
            HStack {
                Text("长度")
                Spacer()
                
                
                Toggle(isOn: $changeStateClear.didSet{ _ in
                    updateRemoteData()
                }, label: {
                    Text("状态切换清除提示").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Button(action: {
                    sportManager.removeRuleLandmarkSegmentLength(id: landmarkSegmentLength.id)

                }) {
                    Text("删除")
                }.padding([.vertical, .leading])
            }
            
            VStack{
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
                    Text("当前轴")
                    Picker("当前轴", selection: $fromAxis.didSet { _ in
                        updateRemoteData()
                        updateLocalData()
                                                    
                                                }) {
                        ForEach(CoordinateAxis.allCases) { axis in
                            Text(axis.rawValue).tag(axis)
                        }
                    }
                    Spacer()
                    Text("相对关节对")
                    Picker("相对关节对", selection: $tolandmarkSegmentType.didSet{ _ in
                        updateRemoteData()
                        updateLocalData()
                        
                    }) {
                        ForEach(LandmarkType.landmarkSegmentTypesForSetRule) { landmarkSegmentType in
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
                    TextField("最小值", value: $lowerBound, formatter: formatter,onEditingChanged: { flag in
                        if !flag {
                            print("0 \(lowerBound)  - \(upperBound)")
                            updateRemoteData()
                        }
                        
                    })
                        .foregroundColor(self.upperBound >= self.lowerBound ? .black : .red)
                    
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    Spacer()
                    Text("最大值:")
                    
                    TextField("最大值", value: $upperBound, formatter: formatter, onEditingChanged: { flag in
                        if !flag {
                            print("1 \(lowerBound)  - \(upperBound)")
                            updateRemoteData()
                        }
                        
                    })
                        .foregroundColor(self.upperBound >= self.lowerBound ? .black : .red)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                }
            }

        }
        .onAppear{
//            存在时加载
            let length = sportManager.getRuleLandmarkSegmentLength(id: landmarkSegmentLength.id)
            self.fromAxis = length.from.axis
            self.toAxis = length.to.axis
            self.tolandmarkSegmentType = length.to.landmarkSegment.landmarkSegmentType
            self.lowerBound = length.lowerBound
            self.upperBound = length.upperBound
            self.warningContent = length.warning.content
            self.triggeredWhenRuleMet = length.warning.triggeredWhenRuleMet
            self.delayTime = length.warning.delayTime
            self.changeStateClear = length.warning.changeStateClear == true
        }
    }
    
}

