

import SwiftUI

/*
 * 关节点相对自身位移
 */

struct LandmarkToSelfRuleView: View {
    var landmarkToSelf: LandmarkToSelf

    @EnvironmentObject var sportManager: SportsManager


    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0

    @State var direction = Direction.UP
    @State var toLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var toAxis = CoordinateAxis.X
    @State var xLowerBound = 0.0
    @State var yLowerBound = 0.0






    func updateLocalData() {

    }

    func updateRemoteData() {
        sportManager.updateRuleLandmarkToSelf(direction: direction, toLandmarkSegmentType: toLandmarkSegmentType, toAxis: toAxis, xLowerBound: xLowerBound, yLowerBound: yLowerBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: landmarkToSelf.id)

    }

    var body: some View {
        VStack {
            HStack {
                Text("关节对相对自身位移")
                Spacer()
                Button(action: {
                    sportManager.removeRuleLandmarkToSelf(id: landmarkToSelf.id)

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
                        Text("方向")
                        Picker("方向", selection: $direction.didSet{ _ in
                            updateRemoteData()
                            updateLocalData()

                        }) {
                            ForEach(Direction.allCases) { direction in
                                Text(direction.rawValue).tag(direction)
                            }
                        }
                        
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

            }
        }
        .onAppear{
                let landmarkToSelf = sportManager.getRuleLandmarkToSelf(id: landmarkToSelf.id)
                warningContent = landmarkToSelf.warning.content
                triggeredWhenRuleMet = landmarkToSelf.warning.triggeredWhenRuleMet
                delayTime = landmarkToSelf.warning.delayTime

                direction = landmarkToSelf.toDirection
            toLandmarkSegmentType = landmarkToSelf.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType
                toAxis = landmarkToSelf.toLandmarkSegmentToAxis.axis

                xLowerBound = landmarkToSelf.xLowerBound
                yLowerBound = landmarkToSelf.yLowerBound

        }
    }
}

