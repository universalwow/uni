

import SwiftUI

struct SetupRuleView: View {
    
    
    
    @EnvironmentObject var sportManager: SportsManager
    @State var clearBackground = false
    
    
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
            
            ScrollView {
                LandmarkAngleRuleView()
                Divider()
                VStack {
                    LandmarkSegmentRelativeLengthRuleView(currentAxis: .X)
                    Divider()
                    LandmarkSegmentRelativeLengthRuleView(currentAxis: .Y)
                    Divider()
                    LandmarkSegmentRelativeLengthRuleView(currentAxis: .XY)
                }
                Divider()
                LandmarkInAreaView()
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
