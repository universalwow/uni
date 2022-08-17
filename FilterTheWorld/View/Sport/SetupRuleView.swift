

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

                    
                    
                
//
//                    AngleToLandmarkSegmentRuleView()
//                    Divider()
//                    LandmarkSegmentRelativeLengthRuleView()
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
            
//            ScrollView(showsIndicators: false) {
//                VStack {
//                    LandmarkInAreaRuleView()
//                    Divider()
//                    ToStateLandmarkRuleView()
//                    Divider()
//                    LandmarkToSelfRuleView()
//                }
//                
//                Spacer()
//            }
            
            
            
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
            
//            ScrollView(showsIndicators: false) {
//                VStack {
//                    ObjectToLandmarkRuleView()
//                    Divider()
//                    ObjectToObjectRuleView()
//                    Divider()
//                    ObjectToSelfRuleView()
//                    
//                }
//                
//                Spacer()
//            }
            
            
            
        }.padding()
        .background(BackgroundClearView(clearBackground: $clearBackground))
    }
}

