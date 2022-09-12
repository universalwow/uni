

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
                        sportManager.addRuleLandmarkInArea()
                    }) {
                        Text("关节在区域内")
                        
                    }
       
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
                        Text("关节自身(相对状态)位移")
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

                    
                    ForEach(sportManager.getRuleLandmarkInAreas()) { landmarkInArea in
                        LandmarkInAreaRuleView(landmarkInArea: landmarkInArea)
                        Divider()
                    }
                    
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

