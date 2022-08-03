

import SwiftUI

struct LandmarkInAreaRuleView: View {
    
    @EnvironmentObject var sportManager:SportsManager
    // 关节点在区域内
    
    @State var landmarkTypeInArea = LandmarkType.LeftAnkle
    @State var leftTopX = 0.0
    @State var leftTopY = 0.0
    @State var rightBottomX = 0.0
    @State var rightBottomY = 0.0
    @State var landmarkInAreaToggle = false
    @State var landmarkInAreaWarning = ""
    @State var satisfyWarning = false

    
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
    
    func setInitData() {
        if landmarkInAreaToggle {
            if let imageSize = sportManager.findFirstSportState()?.image?.imageSize {
                self.sportManager.setRuleLandmarkInArea(landmarkType: landmarkTypeInArea, imageSize: Point2D(x: imageSize.width, y: imageSize.height), warning: landmarkInAreaWarning, satisfyWarning: satisfyWarning)
            }
            
        }
    }
    
    func resetInitData() {
        if landmarkInAreaToggle {
            sportManager.updateRuleLandmarkInArea(landmarkType: landmarkTypeInArea, warning: landmarkInAreaWarning, satisfyWarning: satisfyWarning)
            
        }
    }
    
    
    
    func updateLocalData() {
        if landmarkInAreaToggle {
            if let imageSize = sportManager.findFirstSportState()?.image?.imageSize,
               let area = sportManager.getRuleLandmarkInArea(), !area.area.isEmpty {
                leftTopX = area.area[0].x/imageSize.width
                leftTopY = area.area[0].y/imageSize.height
                rightBottomX = area.area[2].x/imageSize.width
                rightBottomY = area.area[2].y/imageSize.height
            
        }
        }
    }
        
        func updateRemoteData() {
            if landmarkInAreaToggle {
                if self.leftTopX < self.rightBottomX && self.leftTopY < self.rightBottomY {
                    sportManager.updateRuleLandmarkInArea(area: initArea)
                }
            }
        }
    
    func toggleOff() {
        landmarkTypeInArea = self.sportManager.findSelectedSegment()!.landmarkTypes.first!
        leftTopX = 0.0
        leftTopY = 0.0
        rightBottomX = 0.0
        rightBottomY = 0.0
        landmarkInAreaWarning = ""
        satisfyWarning = false

    }
    
    
    var body: some View {
        VStack {
            Toggle("关节点在区域", isOn: $landmarkInAreaToggle.didSet{ isOn in
                if isOn {
                    setInitData()
                    updateLocalData()
                    
                }else {
                    self.sportManager.setRuleLandmarkInArea(landmarkinArea: nil)
                    toggleOff()
                }
                
            })
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $landmarkInAreaWarning) { flag in
                        if !flag {
                            resetInitData()
                        }
                        
                    }
                    Spacer()
                    Toggle("规则满足时提示", isOn: $satisfyWarning.didSet{ _ in
                        resetInitData()
                    })
                }
                HStack {
                    Text("当前关节:")
                    Picker("当前关节", selection: $landmarkTypeInArea.didSet{ _ in
                        resetInitData()
                        updateLocalData()
                    }) {
                        ForEach(self.sportManager.findSelectedSegment()!.landmarkTypes) { landmarkType in
                            Text(landmarkType.rawValue).tag(landmarkType)
                        }
                    }
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
            }.disabled(!landmarkInAreaToggle)
        }
        .onAppear{
            if let imageSize = sportManager.findFirstSportState()?.image?.imageSize,
               let area = sportManager.getRuleLandmarkInArea(), !area.area.isEmpty {
                landmarkTypeInArea = area.landmarkType
                leftTopX = area.area[0].x/imageSize.width
                leftTopY = area.area[0].y/imageSize.height
                rightBottomX = area.area[2].x/imageSize.width
                rightBottomY = area.area[2].y/imageSize.height
                landmarkInAreaWarning = area.warning
                satisfyWarning = area.satisfyWarning ?? false
                
                landmarkInAreaToggle = true
            }else {
                self.landmarkTypeInArea = self.sportManager.findSelectedSegment()!.landmarkTypes.first!
            }
        }
    }
}

