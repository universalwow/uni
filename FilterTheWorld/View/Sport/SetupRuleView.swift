

import SwiftUI

struct SetupLandmarkSegmentRuleView: View {
    @State var clearBackground = false
    
    @EnvironmentObject var sportManager: SportsManager
    @State var showingOptions = false
    
    var body: some View {
        VStack {
            HStack {
                Text(self.sportManager.currentSportStateRuleId ?? "请选择关节对")
                    .foregroundColor(self.sportManager.currentSportStateRuleId != nil ? .black : .red)
                Spacer()
                
                Button("添加规则") {
                                showingOptions = true
                }.confirmationDialog("选择关节对规则", isPresented: $showingOptions, titleVisibility: .visible) {
                    Button(action: {
                        sportManager.addRuleLandmarkSegmentAngle()
                    }) {
                        Text("关节对角度")
                    }

                    Button(action: {
                        sportManager.addRuleLandmarkSegmentLength()
                    }) {
                        Text("关节对长度")
                    }

                    Button(action: {
                        sportManager.addRuleAngleToLandmarkSegment()
                    }) {
                        Text("相对关节对角度")
                    }
                    Button(action: {
                        sportManager.addRuleLandmarkSegmentToStateAngle()
                    }) {
                        Text("关节对(相对状态)角度")
                    }
                    
                    Button(action: {
                        sportManager.addRuleLandmarkSegmentToStateDistance()
                    }) {
                        Text("关节对(相对状态)长度*")
                    }
                }
                
                Button(action: {
                    clearBackground.toggle()
                }) {
                    Text(clearBackground ? "恢复背景" : "清除背景")
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack {
        
                    
                    ForEach(sportManager.getRuleLandmarkSegmentAngles()) { angle in
                        LandmarkSegmentAngleRuleView(angle: angle)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleAngleToLandmarkSegments()) { angle in
                        AngleToLandmarkSegmentRuleView(angle: angle)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleLandmarkSegmentLengths()) { length in
                        LandmarkSegmentLengthRuleView(landmarkSegmentLength: length)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleLandmarkSegmentToStateAngles()) { angle in
                        LandmarkSegmentToStateAngleRuleView(landmarkSegmentToStateAngle: angle)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleLandmarkSegmentToStateDistances()) { distance in
                        LandmarkSegmentToStateDistanceRuleView(landmarkSegmentToStateDistance: distance)
                        Divider()
                    }

                }
                Spacer()
            }
            
        }.padding()
        .background(BackgroundClearView(clearBackground: $clearBackground))
    }
}


struct SetupLandmarkRuleView: View {
    @State var clearBackground = false
    
    @EnvironmentObject var sportManager: SportsManager
    @State var showingOptions = false

    var body: some View {
        VStack {
            HStack {
                Text(self.sportManager.currentSportStateRuleId ?? "请选择关节对")
                    .foregroundColor(self.sportManager.currentSportStateRuleId != nil ? .black : .red)
                Spacer()
                Button("添加规则") {
                                showingOptions = true
                }.confirmationDialog("选择关节规则", isPresented: $showingOptions, titleVisibility: .visible) {

       
                        Button(action: {
                            sportManager.addRuleDistanceToLandmark()
                        }) {
                            Text("相对关节距离")
                        }
                    
                    Button(action: {
                        sportManager.addRuleAngleToLandmark()
                    }) {
                        Text("相对关节角度")
                    }
                    
                    Button(action: {
                        sportManager.addRuleLandmarkToStateDistance()
                    }) {
                        Text("关节(相对状态)位移")
                    }
                    
                    Button(action: {
                        sportManager.addRuleLandmarkToStateAngle()
                    }) {
                        Text("关节自身(相对状态)角度")
                    }

                }
                
                Button(action: {
                    clearBackground.toggle()
                }) {
                    Text(clearBackground ? "恢复背景" : "清除背景")
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack {

                    
                    ForEach(sportManager.getRuleDistanceToLandmarks()) { distanceToLandmark in
                        DistanceToLandmarkRuleView(distanceToLandmark: distanceToLandmark)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleAngleToLandmarks()) { angleToLandmark in
                        AngleToLandmarkRuleView(angleToLandmark: angleToLandmark)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleLandmarkToStateDistances()) { landmarkToStateDistance in
                        LandmarkToStateDistanceRuleView(landmarkToStateDistance: landmarkToStateDistance)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleLandmarkToStateAngles()) { landmarkToStateAngle in
                        LandmarkToStateAngleRuleView(landmarkToStateAngle: landmarkToStateAngle)
                        Divider()
                    }
                    
               
                    
                    
                }
                
                Spacer()
            }
            
            
            
        }.padding()
        .background(BackgroundClearView(clearBackground: $clearBackground))
    }
}


struct SetupLandmarkMergeRuleView: View {
    @State var clearBackground = false
    
    @EnvironmentObject var sportManager: SportsManager
    @State var showingOptions = false

    var body: some View {
        VStack {
            HStack {
                Text(self.sportManager.currentSportStateRuleId ?? "请选择关节对")
                    .foregroundColor(self.sportManager.currentSportStateRuleId != nil ? .black : .red)
                Spacer()
                Button("添加规则") {
                                showingOptions = true
                }.confirmationDialog("选择关节规则", isPresented: $showingOptions, titleVisibility: .visible) {
                    
                    Button(action: {
                        sportManager.addRuleLandmarkToStateDistanceMerge()
                    }) {
                        Text("关节(相对状态)位移")
                    }

                }
                
                Button(action: {
                    clearBackground.toggle()
                }) {
                    Text(clearBackground ? "恢复背景" : "清除背景")
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack {
                    
                    ForEach(sportManager.getRuleLandmarkToStateDistancesMerge()) { landmarkToStateDistance in
                        LandmarkToStateDistanceMergeRuleView(landmarkToStateDistance: landmarkToStateDistance)
                        Divider()
                    }
                    
                }
                
                Spacer()
            }
            
            
            
        }.padding()
        .background(BackgroundClearView(clearBackground: $clearBackground))
    }
}


struct SetupObservationRuleView: View {
    @State var clearBackground = false
    
    @EnvironmentObject var sportManager: SportsManager
    @State var showingOptions = false

    var body: some View {
        VStack {
            HStack {
                Text(self.sportManager.currentSportStateRuleId ?? "请选择物体")
                    .foregroundColor(self.sportManager.currentSportStateRuleId != nil ? .black : .red)
                Spacer()
                Button("添加规则") {
                    showingOptions = true
                }.confirmationDialog("选择物体规则", isPresented: $showingOptions, titleVisibility: .visible) {
                    Button(action: {
                        sportManager.addRuleObjectToLandmark()
                    }) {
                        Text("物体相对关节点位置")
                    }

                    Button(action: {
                        sportManager.addRuleObjectToObject()
                    }) {
                        Text("物体相对物体位置")
                    }

                    Button(action: {
                        sportManager.addRuleObjectToStateDistance()
                    }) {
                        Text("物体位移(相对状态)")
                    }
                    
                    Button(action: {
                        sportManager.addRuleObjectToStateAngle()
                    }) {
                        Text("物体角度(相对状态)")
                    }
                    
                    

                }
                Button(action: {
                    clearBackground.toggle()
                }) {
                    Text(clearBackground ? "恢复背景" : "清除背景")
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack {
  
                    
                    ForEach(sportManager.getRuleObjectToLandmarks()) { objectToLandmark in
                        ObjectToLandmarkRuleView(objectToLandmark: objectToLandmark)
                        Divider()
                    }
                    
                    
                    ForEach(sportManager.getRuleObjectToObjects()) { objectToObject in
                        ObjectToObjectRuleView(objectToObject: objectToObject)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleObjectToStateDistances()) { objectToStateDistance in
                        ObjectToStateDistanceRuleView(objectToStateDistance: objectToStateDistance)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleObjectToStateAngles()) { objectToStateAngle in
                        ObjectToStateAngleRuleView(objectToStateAngle: objectToStateAngle)
                        Divider()
                    }
                    
                    
                    
                }
                
                Spacer()
            }
            
            
            
        }.padding()
        .background(BackgroundClearView(clearBackground: $clearBackground))
    }
}



struct SetupFixedAreaRuleView: View {
    @State var clearBackground = false
    
    @EnvironmentObject var sportManager: SportsManager
    @State var showingOptions = false
    
    @State var width: Double = 0.1
    @State var heightToWidthRatio = 1.0
    @State var centerX:Double = 0
    @State var centerY: Double = 0
    @State var content: String = ""
    

    

    
    private func updateRemoteData() {
        sportManager.updateFixedArea(width: width, heightToWidthRatio: heightToWidthRatio, centerX: centerX, centerY: centerY, content: content)
        
      
    }
    

    var body: some View {
        VStack {
            HStack {
                Text( self.sportManager.currentSportStateRuleId != nil ? "\(self.sportManager.currentSportStateRuleId!)" : "请选择区域")
                    .foregroundColor(self.sportManager.currentSportStateRuleId != nil ? .black : .red)
                Spacer()
                
                TextField("区域内容", text: $content) { flag in
                    if !flag {
                        updateRemoteData()
                    }
                    
                }
                
                Button("添加规则") {
                    showingOptions = true
                }.confirmationDialog("选择区域规则", isPresented: $showingOptions, titleVisibility: .visible) {
                    Button(action: {
                        sportManager.addRuleLandmarkInFixedAreaForAreaRule()
                    }) {
                        Text("关节在区域内")
                    }
                }
                
                Button(action: {
                    clearBackground.toggle()
                }) {
                    Text(clearBackground ? "恢复背景" : "清除背景")
                }
            }
            HStack {
                Text("宽度/高宽比\n中心点")
                HStack {
                    
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
                    
                    TextField("中心X", value: $centerX, formatter: formatter,onEditingChanged: { flag in
                        if !flag {
                            updateRemoteData()
                        }

                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    TextField("中心Y", value: $centerY, formatter: formatter,onEditingChanged: { flag in
                        if !flag {
                            updateRemoteData()
                        }

                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                }
            }
            
            
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(sportManager.getRuleLandmarkInFixedAreasForAreaRule()) { landmarkInArea in
                        LandmarkInFixedAreaRuleView(landmarkInArea: landmarkInArea)
                        Divider()
                    }
                }
                
                Spacer()
            }
            
            
            
        }.padding()
        
        .background(BackgroundClearView(clearBackground: $clearBackground))
        .onAppear(perform: {
            let area = sportManager.getFixedArea()!
            width = area.width
            heightToWidthRatio = area.heightToWidthRatio
            centerX = area.center.x
            centerY = area.center.y
            content = area.content ?? ""

        })
    }
}

struct SetupDynamicAreaRuleView: View {
    @State var clearBackground = false
    
    @EnvironmentObject var sportManager: SportsManager
    @State var showingOptions = false
    
    @State var width: Double = 0.1
    @State var heightToWidthRatio = 1.0

    
    @State var leftTopX = 0.0
    @State var leftTopY = 0.0
    @State var rightBottomX = 0.0
    @State var rightBottomY = 0.0
    
    @State var content = ""

    
    private func updateRemoteData() {
        if leftTopX <= rightBottomX && leftTopY <= rightBottomY {
            sportManager.updateDynamicArea(width: width, heightToWidthRatio: heightToWidthRatio, leftTopX: leftTopX, leftTopY: leftTopY, rightBottomX: rightBottomX, rightBottomY: rightBottomY, content: content)
        }
       
    }
    

    var body: some View {
        VStack {
            HStack {
                Text( self.sportManager.currentSportStateRuleId != nil ? "\(self.sportManager.currentSportStateRuleId!)" : "请选择区域")
                    .foregroundColor(self.sportManager.currentSportStateRuleId != nil ? .black : .red)
                Spacer()
                
                TextField("区域内容", text: $content) { flag in
                    if !flag {
                        updateRemoteData()
                    }
                    
                }
                
                Button("添加规则") {
                    showingOptions = true
                }.confirmationDialog("选择区域规则", isPresented: $showingOptions, titleVisibility: .visible) {
                    Button(action: {
                        sportManager.addRuleLandmarkInDynamicAreaForAreaRule()
                    }) {
                        Text("关节在区域内")
                    }
                }
                
                Button(action: {
                    clearBackground.toggle()
                }) {
                    Text(clearBackground ? "恢复背景" : "清除背景")
                }
            }
            
            HStack {
                HStack {
                    Text("宽度/高宽比\n中心点")
                    VStack {
                        HStack {
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

                    }
                    
                }
                
                HStack {
                    
                    Text("限制区域:\n左上\n右下")
                    VStack {
                        HStack {
                            TextField("leftTopX", value: $leftTopX, formatter: formatter) { flag in
                                if !flag {
                                    updateRemoteData()
                                }
                                
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            TextField("leftTopY", value: $leftTopY, formatter: formatter) {flag in
                                if !flag {
                                    updateRemoteData()
                                }
                                
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        }
                        HStack {
                            TextField("rightBottomX", value: $rightBottomX, formatter: formatter) {flag in
                                if !flag {
                                    updateRemoteData()
                                }
                                
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            
                            TextField("rightBottomY", value: $rightBottomY, formatter: formatter){flag in
                                if !flag {
                                    updateRemoteData()
                                }
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        }
                    }
                }
            }
            
            
            
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(sportManager.getRuleLandmarkInDynamicAreas()) { landmarkInArea in
                        LandmarkInDynamicAreaRuleView(landmarkInArea: landmarkInArea)
                        Divider()
                    }
                }
                
                Spacer()
            }
            
            
            
        }.padding()
        
        .background(BackgroundClearView(clearBackground: $clearBackground))
        .onAppear(perform: {
            let area = sportManager.getDynamicArea()!
            width = area.width
            heightToWidthRatio = area.heightToWidthRatio
            leftTopX = area.limitedArea[0]
            leftTopY = area.limitedArea[1]
            rightBottomX = area.limitedArea[2]
            rightBottomY = area.limitedArea[3]
            content = area.content ?? ""


        })
    }
}




