
import SwiftUI


struct RuleView: View {
    @EnvironmentObject var sportManager:SportsManager
    
    @State var selectedLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var showSetupRule = false
    
    var body: some View {
        VStack {
            let state = sportManager.findFirstSportState()!
            let pngImage = state.image!
            FrameView(uiImage: UIImage(data: pngImage.photo)!)
                .scaledToFit()
                .overlay{
                    GeometryReader { geometry in
                        ZStack {
                            PosesViewForSetupRule(landmarkSegments: state.landmarkSegments, imageSize: pngImage.imageSize, viewSize: geometry.size)
                            ObjectsViewForSetupRule(objects: state.objects, imageSize: pngImage.imageSize, viewSize: geometry.size)
                            RectView(viewSize: geometry.size)
                            
                            
                        }
                        
                    }
                    
                    
                }
            Spacer()
            
            HStack {
                Image(systemName: "figure.wave")
                Picker("选择关节对", selection: $selectedLandmarkSegmentType) {
                    ForEach(LandmarkType.landmarkSegmentTypesForSetRule) { landmarkSegment in
                        Text(landmarkSegment.id).tag(landmarkSegment)
                    }
                }
                Button(action: {
                    self.showSetupRule = true
                    sportManager.setStateRule()
                }) {
                    Text("设置规则")
                }
                Spacer()
            }
            
        }.padding()
        .onChange(of: self.selectedLandmarkSegmentType) { _ in
            sportManager.setCurrentSportStateRule(landmarkSegmentType: selectedLandmarkSegmentType)
        }
        .sheet(isPresented: self.$showSetupRule) {
            SetupRuleView()
        }.onAppear{
            sportManager.setCurrentSportStateRule(landmarkSegmentType: selectedLandmarkSegmentType)
        }
    }
}

