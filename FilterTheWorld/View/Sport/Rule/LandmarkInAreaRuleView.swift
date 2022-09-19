

import SwiftUI

struct LandmarkInAreaRuleView: View {
    
    var landmarkInArea: LandmarkInArea
    
    @EnvironmentObject var sportManager:SportsManager
    // 关节点在区域内
    
    @State var leftTopX = 0.0
    @State var leftTopY = 0.0
    @State var rightBottomX = 0.0
    @State var rightBottomY = 0.0
    
    @State var isDynamicArea = false
    @State var width: Double = 0.1
    @State var heightToWidthRatio = 1.0
        
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    @State var changeStateClear = true
    

    
    var landmarkInAreaTextColor : Color {
        return (self.leftTopX < self.rightBottomX && self.leftTopY < self.rightBottomY) ? .black : .red
    }
    
    var initArea: [Point2D] {
        let area = sportManager.getRuleLandmarkInArea(id: landmarkInArea.id)
        let imageSize = area.imageSize
        
        let firstPoint = Point2D(x: leftTopX*imageSize.width, y: leftTopY * imageSize.height)
        let secondPoint = Point2D(x: rightBottomX*imageSize.width, y: leftTopY * imageSize.height)
        let thirdPoint = Point2D(x: rightBottomX*imageSize.width, y: rightBottomY * imageSize.height)
        let fourthPoint = Point2D(x: leftTopX*imageSize.width, y: rightBottomY * imageSize.height)
        return [firstPoint, secondPoint, thirdPoint, fourthPoint]
    }
    
    func updateLocalData() {
        let area = sportManager.getRuleLandmarkInArea(id: landmarkInArea.id)
        let imageSize = area.imageSize
        
        leftTopX = area.area[0].x/imageSize.width
        leftTopY = area.area[0].y/imageSize.height
        rightBottomX = area.area[2].x/imageSize.width
        rightBottomY = area.area[2].y/imageSize.height
    }
        
        func updateRemoteData() {
            if self.leftTopX <= self.rightBottomX && self.leftTopY <= self.rightBottomY {
                sportManager.updateRuleLandmarkInArea(area: initArea, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, isDynamicArea: isDynamicArea,
                                                      width: width, heightToWidthRatio: heightToWidthRatio, id: landmarkInArea.id)
            }
        }
    

    
    
    var body: some View {
        VStack {
            
            HStack {
                Text("关节在区域内")
                Spacer()
                
                Toggle(isOn: $isDynamicArea.didSet{ _ in
                    updateRemoteData()
                }, label: {
                    Text("动态生成区域").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Toggle(isOn: $changeStateClear.didSet{ _ in
                    updateRemoteData()
                }, label: {
                    Text("状态切换清除提示").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Button(action: {
                    sportManager.removeRuleLandmarkInArea(id: landmarkInArea.id)

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
                
                HStack {
                    
                    
                    
                    HStack {
                        Text("宽度:\n高宽比:")
                        VStack {
                            
                            TextField("区域宽度", value: $width, formatter: formatter,onEditingChanged: { flag in
                                if !flag {
                                    updateRemoteData()
                                }

                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            
                            TextField("高宽比", value: $heightToWidthRatio, formatter: formatter,onEditingChanged: { flag in
                                if !flag {
                                    updateRemoteData()
                                }

                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        }
                    }.disabled(!isDynamicArea)
                    
                    
                    HStack {
                        
                        Text("\(isDynamicArea ? "限制" : "")区域:\n左上\n右下")
                        VStack {
                            HStack {
                                TextField("leftTopX", value: $leftTopX, formatter: formatter) { flag in
                                    if !flag {
                                        updateRemoteData()
                                    }
                                    
                                }
                                .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                TextField("leftTopY", value: $leftTopY, formatter: formatter) {flag in
                                    if !flag {
                                        updateRemoteData()
                                    }
    
                                }
                                .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            }
                            HStack {
                                TextField("rightBottomX", value: $rightBottomX, formatter: formatter) {flag in
                                    if !flag {
                                        updateRemoteData()
                                    }
                                    
                                }
                                .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                
                                TextField("rightBottomY", value: $rightBottomY, formatter: formatter){flag in
                                    if !flag {
                                        updateRemoteData()
                                    }
                                    
                                }
                                
                                .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            }
                        }
                    }
                    
                    
                    
                }
                
                
            }
        }
        .onAppear{
            let area = sportManager.getRuleLandmarkInArea(id: landmarkInArea.id)
            let imageSize = area.imageSize

            warningContent = area.warning.content
            triggeredWhenRuleMet = area.warning.triggeredWhenRuleMet
            delayTime = area.warning.delayTime
            changeStateClear = area.warning.changeStateClear == true
            isDynamicArea = area.isDynamicArea ?? false
            if isDynamicArea {
                leftTopX = area.limitedArea![0].x/imageSize.width
                leftTopY = area.limitedArea![0].y/imageSize.height
                rightBottomX = area.limitedArea![2].x/imageSize.width
                rightBottomY = area.limitedArea![2].y/imageSize.height
                
            } else {
                leftTopX = area.area[0].x/imageSize.width
                leftTopY = area.area[0].y/imageSize.height
                rightBottomX = area.area[2].x/imageSize.width
                rightBottomY = area.area[2].y/imageSize.height
            
            }

            width = area.width ?? 0.1
            heightToWidthRatio = area.heightToWidthRatio ?? 1.0
            
        }
    }
}


struct LandmarkInAreaRuleForAreaRuleView: View {
    
    var landmarkInArea: LandmarkInAreaForAreaRule
    
    @EnvironmentObject var sportManager:SportsManager
    // 关节点在区域内
    
    @State var leftTopX = 0.0
    @State var leftTopY = 0.0
    @State var rightBottomX = 0.0
    @State var rightBottomY = 0.0
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0
    @State var changeStateClear = true
    
    @State var landmarkType = LandmarkType.LeftAnkle
//    @Binding var isDynamicArea: Bool
    
    
    var landmarkInAreaTextColor : Color {
        return (self.leftTopX < self.rightBottomX && self.leftTopY < self.rightBottomY) ? .black : .red
    }
    
    var initArea: [Point2D] {
        let area = sportManager.getRuleLandmarkInAreaForAreaRule(id: landmarkInArea.id)
        let imageSize = area.imageSize
        
        let firstPoint = Point2D(x: leftTopX*imageSize.width, y: leftTopY * imageSize.height)
        let secondPoint = Point2D(x: rightBottomX*imageSize.width, y: leftTopY * imageSize.height)
        let thirdPoint = Point2D(x: rightBottomX*imageSize.width, y: rightBottomY * imageSize.height)
        let fourthPoint = Point2D(x: leftTopX*imageSize.width, y: rightBottomY * imageSize.height)
        return [firstPoint, secondPoint, thirdPoint, fourthPoint]
    }
    
    func updateLocalData() {
        let area = sportManager.getRuleLandmarkInAreaForAreaRule(id: landmarkInArea.id)
        let imageSize = area.imageSize
        
        leftTopX = area.area[0].x/imageSize.width
        leftTopY = area.area[0].y/imageSize.height
        rightBottomX = area.area[2].x/imageSize.width
        rightBottomY = area.area[2].y/imageSize.height
    }
        
        func updateRemoteData() {
            if self.leftTopX <= self.rightBottomX && self.leftTopY <= self.rightBottomY {
                sportManager.updateRuleLandmarkInAreaForAreaRule(area: initArea, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, landmarkType: landmarkType, id: landmarkInArea.id)
            }
        }
    

    
    
    var body: some View {
        VStack {
            
            HStack {
                Text("关节在区域内")
                Spacer()

                Picker("选择关节", selection: $landmarkType.didSet { _ in
                    updateLocalData()

                    updateRemoteData()
                
          
                    
                }) {
                    ForEach(LandmarkType.allCases) { _landmarkType in
                        Text(_landmarkType.id).tag(_landmarkType)
                    }
                }
                
                Toggle(isOn: $changeStateClear.didSet{ _ in
                    updateRemoteData()
                }, label: {
                    Text("状态切换清除提示").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
                Button(action: {
                    sportManager.removeRuleLandmarkInAreaForAreaRule(id: landmarkInArea.id)

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
                
                HStack {
                    Text("区域:\n左上\n右下")
                    VStack {
                        HStack {
                            TextField("leftTopX", value: $leftTopX, formatter: formatter) { flag in
//                                if !flag && !isDynamicArea {
//                                    updateRemoteData()
//                                }
                                
                            }
                            .foregroundColor(landmarkInAreaTextColor)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            TextField("leftTopY", value: $leftTopY, formatter: formatter) {flag in
//                                if !flag && !isDynamicArea {
//                                    updateRemoteData()
//                                }
                                
                            }
                            .foregroundColor(landmarkInAreaTextColor)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        }
                        HStack {
                            TextField("rightBottomX", value: $rightBottomX, formatter: formatter) {flag in
//                                if !flag && !isDynamicArea {
//                                    updateRemoteData()
//                                }
//
                            }
                            .foregroundColor(landmarkInAreaTextColor)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            
                            TextField("rightBottomY", value: $rightBottomY, formatter: formatter){flag in
//                                if !flag && !isDynamicArea {
//                                    updateRemoteData()
//                                }
                                
                            }
                            
                            .foregroundColor(landmarkInAreaTextColor)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        }
                    }
                }.disabled(false)
                
                
            }
        }
        .onAppear{
            let area = sportManager.getRuleLandmarkInAreaForAreaRule(id: landmarkInArea.id)
            let imageSize = area.imageSize
            leftTopX = area.area[0].x/imageSize.width
            leftTopY = area.area[0].y/imageSize.height
            rightBottomX = area.area[2].x/imageSize.width
            rightBottomY = area.area[2].y/imageSize.height
            warningContent = area.warning.content
            triggeredWhenRuleMet = area.warning.triggeredWhenRuleMet
            delayTime = area.warning.delayTime
            changeStateClear = area.warning.changeStateClear == true
            landmarkType = area.landmark.landmarkType

            
        }
    }
}


