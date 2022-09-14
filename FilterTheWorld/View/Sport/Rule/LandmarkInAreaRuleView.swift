

import SwiftUI

struct LandmarkInAreaRuleView: View {
    
    var landmarkInArea: LandmarkInArea
    
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
            if self.leftTopX < self.rightBottomX && self.leftTopY < self.rightBottomY {
                sportManager.updateRuleLandmarkInArea(area: initArea, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: landmarkInArea.id)
            }
        }
    

    
    
    var body: some View {
        VStack {
            
            HStack {
                Text("关节在区域内")
                Spacer()
                
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
                    
                    Text("区域:")
                    VStack {
                        HStack {
                            TextField("leftTopX", value: $leftTopX, formatter: formatter) {flag in
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
        .onAppear{
            let area = sportManager.getRuleLandmarkInArea(id: landmarkInArea.id)
            let imageSize = area.imageSize
            leftTopX = area.area[0].x/imageSize.width
            leftTopY = area.area[0].y/imageSize.height
            rightBottomX = area.area[2].x/imageSize.width
            rightBottomY = area.area[2].y/imageSize.height
            warningContent = area.warning.content
            triggeredWhenRuleMet = area.warning.triggeredWhenRuleMet
            delayTime = area.warning.delayTime
            changeStateClear = area.warning.changeStateClear == true
        }
    }
}

