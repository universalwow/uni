
import SwiftUI

struct RuleView: View {
    @EnvironmentObject var sportManager:SportsManager
    
    @State var selectedLandmarkSegment = LandmarkSegment.initValue()
    @State var showSetupRule = false
    
    var body: some View {
        VStack {
            let state = sportManager.findFirstSportState()!
            let pngImage = state.image!
            let cgImage = UIImage(data: pngImage.photo)!.cgImage
            FrameView(cgImage: cgImage)
                .scaledToFit()
                .overlay{
                    GeometryReader { geometry in
                        ZStack {
                            PosesViewForSetupRule(landmarkSegments: state.landmarkSegments, imageSize: pngImage.imageSize, viewSize: geometry.size)
                            
                            ObjectsViewForSetupRule(objects: state.objects, imageSize: pngImage.imageSize, viewSize: geometry.size)
                        }
                        
                    }
                    
                    
                }
            Spacer()
            
            HStack {
                Image(systemName: "figure.wave")
                Picker("选择关节对", selection: $selectedLandmarkSegment) {
                    ForEach(state.landmarkSegments) { landmarkSegment in
                        Text(landmarkSegment.id).tag(landmarkSegment)
                    }
                }
                Button(action: {
                    self.showSetupRule = true
                }) {
                    Text("设置规则")
                }
                Spacer()
            }
            
        }.padding()
            .onChange(of: self.selectedLandmarkSegment) { _ in
                sportManager.setCurrentSportStateRule(landmarkSegment: selectedLandmarkSegment)
            }
            .sheet(isPresented: self.$showSetupRule) {
                SetupRuleView()
            }
    }
}

