

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
                        Text("添加关节对角度规则")
                    }

                    Button(action: {
                        sportManager.addRuleLandmarkSegmentLength()
                    }) {
                        Text("添加关节对长度规则")
                    }

                    Button(action: {
                        sportManager.addRuleAngleToLandmarkSegment()
                    }) {
                        Text("添加相对关节对角度规则")
                    }
                    Button("取消", role: .cancel) {
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
//                        Button(action: {
//                            sportManager.addRuleLandmarkToSelf()
//                        }) {
//                            Text("添加关节相对自身位移规则")
//                        }
//
//                        Button(action: {
//                            sportManager.addRuleLandmarkToState()
//                        }) {
//                            Text("添加关节自身(相对状态)位移规则")
//                        }
                    
                    Button(action: {
                        sportManager.addRuleAngleToLandmark()
                    }) {
                        Text("添加相对关节角度规则")
                    }
                    
                    Button(action: {
                        sportManager.addRuleLandmarkToStateExtreme()
                    }) {
                        Text("添加关节自身(相对状态)位移规则")
                    }

                        Button(action: {
                            sportManager.addRuleLandmarkInArea()
                        }) {
                            Text("添加关节在区域内规则")
                        }
                        Button("取消", role: .cancel) {
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

//                    ForEach(sportManager.getRuleLandmarkToSelfs()) { landmarkToSelf in
//                        LandmarkToSelfRuleView(landmarkToSelf: landmarkToSelf)
//                        Divider()
//                    }
//
//                    ForEach(sportManager.getRuleLandmarkToStates()) { landmarkToState in
//                        LandmarkToStateRuleView(landmarkToState: landmarkToState)
//                        Divider()
//                    }
                    
                    ForEach(sportManager.getRuleAngleToLandmarks()) { angleToLandmark in
                        AngleToLandmarkRuleView(angleToLandmark: angleToLandmark)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleLandmarkToStateExtremes()) { landmarkToStateExtreme in
                        LandmarkToStateExtremeRuleView(landmarkToStateExtreme: landmarkToStateExtreme)
                        Divider()
                    }
                    
                    ForEach(sportManager.getRuleLandmarkInAreas()) { landmarkInArea in
                        LandmarkInAreaRuleView(landmarkInArea: landmarkInArea)
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
                        Text("添加物体相对关节点位置规则")
                    }

                    Button(action: {
                        sportManager.addRuleObjectToObject()
                    }) {
                        Text("添加物体相对物体位置规则")
                    }

                    Button(action: {
                        sportManager.addRuleObjectToStateExtreme()
                    }) {
                        Text("添加物体位移(相对状态)规则")
                    }
                    
                    Button("取消", role: .cancel) {
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
                    
                    
//                    ForEach(sportManager.getRuleObjectToSelfs()) { objectToSelf in
//                        ObjectToSelfRuleView(objectToSelf: objectToSelf)
//                        Divider()
//                    }
                    
                    ForEach(sportManager.getRuleObjectToStateExtremes()) { objectToState in
                        ObjectToStateExtremeRuleView(objectToStateExtreme: objectToState)
                        Divider()
                    }
                    
                    
                    
                }
                
                Spacer()
            }
            
            
            
        }.padding()
        .background(BackgroundClearView(clearBackground: $clearBackground))
    }
}

