

import SwiftUI

struct LandmarkInAreaView: View {
    
    @EnvironmentObject var sportManager:SportsManager
    // 关节点在区域内
    
    @State var landmarkTypeInArea: LandmarkType = LandmarkType.LeftAnkle
    @State var leftTopX = 0.0
    @State var leftTopY = 0.0
    @State var rightBottomX = 0.0
    @State var rightBottomY = 0.0
    @State var landmarkInAreaToggle = false
    @State var landmarkInAreaWarning = ""
    var landmarkInAreaTextColor : Color {
        return (self.leftTopX < self.rightBottomX && self.leftTopY < self.rightBottomY) ? .black : .red
    }
    
    var initArea: [Point2D] {
        if let imageSize = sportManager.findFirstSportState()?.image?.imageSize {
            let firstPoint = Point2D(x: leftTopX*imageSize.width, y: leftTopY * imageSize.height)
            let secondPoint = Point2D(x: rightBottomX*imageSize.width, y: leftTopY * imageSize.height)
            let thirdPoint = Point2D(x: rightBottomX*imageSize.width, y: rightBottomY * imageSize.height)
            let fourthPoint = Point2D(x: leftTopX*imageSize.width, y: rightBottomY * imageSize.height)
            
            return [firstPoint, secondPoint, thirdPoint, fourthPoint]
        }
        return []
    }
    
    func updateArea() {
        let area = initArea
        if !area.isEmpty {
            sportManager.updateSportStateRule(firstPoint: area[0], secondPoint: area[1], thirdPoint: area[2], fourthPoint: area[3])
        }
        
    }
    
    
    var body: some View {
        VStack {
            Toggle("关节点在区域", isOn: $landmarkInAreaToggle.didSet{ isOn in
                if isOn {
                    self.sportManager.setLandmarkArea(landmarkinArea: LandmarkInArea(landmarkType: self.landmarkTypeInArea, area: initArea))
                }else {
                    self.sportManager.setLandmarkArea(landmarkinArea: nil)
                }
                
            })
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $landmarkInAreaWarning)
                }
                HStack {
                    Text("当前关节:")
                    Picker("当前关节", selection: $landmarkTypeInArea.didSet{ _ in
                            if leftTopX < rightBottomX && leftTopY < rightBottomY {
                                self.sportManager.setLandmarkArea(landmarkinArea: LandmarkInArea(landmarkType: self.landmarkTypeInArea, area: initArea))
                                
                            }else {
                                self.sportManager.setLandmarkArea(landmarkinArea: LandmarkInArea(landmarkType: self.landmarkTypeInArea, area: []))
                            }
                    }) {
                        ForEach(self.sportManager.findselectedSegment()!.landmarkTypes) { landmarkType in
                            Text(landmarkType.rawValue).tag(landmarkType)
                        }
                    }
                    Text("区域:")
                    VStack {
                        HStack {
                            TextField("leftTopX", value: $leftTopX, formatter: formatter)
                                .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            TextField("leftTopY", value: $leftTopY, formatter: formatter)
                                .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        HStack {
                            TextField("rightBottomX", value: $rightBottomX, formatter: formatter)
                                .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            
                            TextField("rightBottomY", value: $rightBottomY, formatter: formatter)
                                .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                    }
            }
            .disabled(!landmarkInAreaToggle)
                
            }
        }
        .onChange(of:landmarkInAreaWarning, perform: { _ in
            self.sportManager.updateSportStateRule(landmarkType: self.landmarkTypeInArea, landmarkInAreaWarning: self.landmarkInAreaWarning)
        })
        .onChange(of: self.leftTopX) { _ in
            if leftTopX < rightBottomX {
                updateArea()
            }
        }
        .onChange(of: self.leftTopY) {  _ in
            if leftTopY < rightBottomY {
                updateArea()
            }
            
        }
        .onChange(of: self.rightBottomX) { _ in
            if leftTopX < rightBottomX {
                updateArea()
            }
            
        }
        .onChange(of: self.rightBottomY) {  _ in
            if leftTopY < rightBottomY {
                updateArea()
            }
        }.onAppear{
            if let imageSize = sportManager.findFirstSportState()?.image?.imageSize,
               let area = sportManager.findCurrentLandmarkArea(), !area.area.isEmpty {
                landmarkTypeInArea = area.landmarkType
                leftTopX = area.area[0].x/imageSize.width
                leftTopY = area.area[0].y/imageSize.height
                rightBottomX = area.area[2].x/imageSize.width
                rightBottomY = area.area[2].y/imageSize.height
                landmarkInAreaWarning = area.warning
                landmarkInAreaToggle = true
            }else {
                self.landmarkTypeInArea = self.sportManager.findselectedSegment()!.landmarkTypes.first!
            }
        }
    }
}

