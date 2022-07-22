

import SwiftUI

struct SetupRuleView: View {
    
    
    
 
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
                    Group {
                        LandmarkSegmentAngleRuleView()
                        Divider()
                        AngleToLandmarkSegmentRuleView()
                        Divider()
                    }
                    
                    LandmarkSegmentRelativeLengthRuleView()
                    Divider()
                    LandmarkInAreaRuleView()
                    Divider()
                    ObjectToLandmarkRuleView()
                    Divider()
                    ObjectToObjectRuleView()
                    
                }
                VStack {
                    Divider()
                    ToStateLandmarkRuleView()
                    Divider()
                    LandmarkToSelfRuleView()
                    Divider()
                    ObjectToSelfRuleView()
                }
                
                
                Spacer()
            }
            
            
            
        }.padding()
        .background(BackgroundClearView(clearBackground: $clearBackground))
    }
}

struct SetupRuleView_Previews: PreviewProvider {
    static var previews: some View {
        SetupRuleView()
    }
}
