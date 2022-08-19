

import SwiftUI

struct SetupLandmarkSegmentRuleView: View {
    @State var clearBackground = false
    
    @EnvironmentObject var sportManager: SportsManager
    
    var body: some View {
        VStack {
            HStack {
                Text(self.sportManager.currentSportStateRuleId ?? "请选择关节对")
                    .foregroundColor(self.sportManager.currentSportStateRuleId != nil ? .black : .red)
                Spacer()
                Button(action: {
                    clearBackground.toggle()
                }) {
                    Text(clearBackground ? "恢复背景" : "清除背景")
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack{
                        Spacer()
                        Button(action: {
                            sportManager.addRuleLandmarkSegmentAngle()
                        }) {
                            Text("添加关节对角度规则")
                        }
                    }.padding()
                    
                    ForEach(sportManager.getRuleLandmarkSegmentAngles()) { angle in
                        LandmarkSegmentAngleRuleView(angle: angle)
                        Divider()
                    }
                    
                    HStack{
                        Spacer()
                        Button(action: {
                            sportManager.addRuleAngleToLandmarkSegment()
                        }) {
                            Text("添加相对关节对角度规则")
                        }
                    }.padding()
                    ForEach(sportManager.getRuleAngleToLandmarkSegments()) { angle in
                        AngleToLandmarkSegmentRuleView(angle: angle)
                        Divider()
                    }

                    
                    HStack{
                        Spacer()
                        Button(action: {
                            sportManager.addRuleLandmarkSegmentLength()
                        }) {
                            Text("添加关节对长度规则")
                        }
                    }.padding()
                    
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
    
    var body: some View {
        VStack {
            HStack {
                Text(self.sportManager.currentSportStateRuleId ?? "请选择关节对")
                    .foregroundColor(self.sportManager.currentSportStateRuleId != nil ? .black : .red)
                Spacer()
                Button(action: {
                    clearBackground.toggle()
                }) {
                    Text(clearBackground ? "恢复背景" : "清除背景")
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack{
                        Spacer()
                        Button(action: {
                            sportManager.addRuleLandmarkToSelf()
                        }) {
                            Text("添加关节相对自身位移规则")
                        }
                    }.padding()
                    
                    ForEach(sportManager.getRuleLandmarkToSelfs()) { landmarkToSelf in
                        LandmarkToSelfRuleView(landmarkToSelf: landmarkToSelf)
                        Divider()
                    }
                    
                    HStack{
                        Spacer()
                        Button(action: {
                            sportManager.addRuleLandmarkToState()
                        }) {
                            Text("添加关节自身(相对状态)位移规则")
                        }
                    }.padding()
                    
                    ForEach(sportManager.getRuleLandmarkToStates()) { landmarkToState in
                        LandmarkToStateRuleView(landmarkToState: landmarkToState)
                        Divider()
                    }
                    
                    HStack{
                        Spacer()
                        Button(action: {
                            sportManager.addRuleLandmarkInArea()
                        }) {
                            Text("添加关节在区域内规则")
                        }
                    }.padding()
                    
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
    
    var body: some View {
        VStack {
            HStack {
                Text(self.sportManager.currentSportStateRuleId ?? "请选择物体")
                    .foregroundColor(self.sportManager.currentSportStateRuleId != nil ? .black : .red)
                Spacer()
                Button(action: {
                    clearBackground.toggle()
                }) {
                    Text(clearBackground ? "恢复背景" : "清除背景")
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack{
                        Spacer()
                        Button(action: {
                            sportManager.addRuleObjectToLandmark()
                        }) {
                            Text("添加物体相对关节点位置规则")
                        }
                    }.padding()
                    
                    ForEach(sportManager.getRuleObjectToLandmarks()) { objectToLandmark in
                        ObjectToLandmarkRuleView(objectToLandmark: objectToLandmark)
                        Divider()
                    }
                    
                    HStack{
                        Spacer()
                        Button(action: {
                            sportManager.addRuleObjectToObject()
                        }) {
                            Text("添加物体相对物体位置规则")
                        }
                    }.padding()
                    
                    ForEach(sportManager.getRuleObjectToObjects()) { objectToObject in
                        ObjectToObjectRuleView(objectToObject: objectToObject)
                        Divider()
                    }
                    
                    
                    HStack{
                        Spacer()
                        Button(action: {
                            sportManager.addRuleObjectToSelf()
                        }) {
                            Text("添加物体相对自身位移规则")
                        }
                    }.padding()
                    
                    ForEach(sportManager.getRuleObjectToSelfs()) { objectToSelf in
                        ObjectToSelfRuleView(objectToSelf: objectToSelf)
                        Divider()
                    }
                    
                    
                    
                }
                
                Spacer()
            }
            
            
            
        }.padding()
        .background(BackgroundClearView(clearBackground: $clearBackground))
    }
}

