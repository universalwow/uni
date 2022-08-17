
import SwiftUI


struct RuleView: View {
    @EnvironmentObject var sportManager:SportsManager
    
    @State var selectedLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var selectedLandmarkType = LandmarkType.LeftShoulder
    @State var selectedObject = ObjectLabel.POSE.rawValue
    @State var ruleClass = RuleClass.LandmarkSegment
    
    @State var showSetupRule = false
    
    var body: some View {
        VStack {
            let state = sportManager.findFirstState()!
             let pngImage = state.image!
            FrameView(uiImage: UIImage(data: pngImage.photo)!)
                .scaledToFit()
                .overlay{
                    GeometryReader { geometry in
                        ZStack {
                            PosesViewForSetupRule(imageSize: pngImage.imageSize, viewSize: geometry.size)
                            ObjectsViewForSetupRule(imageSize: pngImage.imageSize, viewSize: geometry.size)
//                            RectView(viewSize: geometry.size)
                            
                            
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
                
                Picker("选择关节", selection: $selectedLandmarkType) {
                    ForEach(LandmarkType.allCases) { landmarkType in
                        Text(landmarkType.id).tag(landmarkType)
                    }
                }
                
                Picker("选择物体", selection: $selectedObject) {
                    ForEach(sportManager.findSelectedObjects()) { object in
                        Text(object.label).tag(object.label)
                    }
                }
                
                
                Button(action: {
                    self.showSetupRule = true
                    sportManager.setRule()
                }) {
                    Text("设置规则")
                }
                Spacer()
            }
            
        }.padding()
        .onChange(of: self.selectedLandmarkSegmentType) { _ in
            ruleClass = .LandmarkSegment
            sportManager.setCurrentSportStateRule(landmarkSegmentType: selectedLandmarkSegmentType,ruleClass: ruleClass)
        }
        .onChange(of: self.selectedLandmarkType) { _ in
            ruleClass = .Landmark
            sportManager.setCurrentSportStateRule(landmarkType: self.selectedLandmarkType, ruleClass: ruleClass)
        }
        .onChange(of: self.selectedObject) { _ in
            ruleClass = .Observation
            sportManager.setCurrentSportStateRule(objectLabel: self.selectedObject, ruleClass: ruleClass)
        }
        .sheet(isPresented: self.$showSetupRule) {
            
            switch ruleClass {
            case .LandmarkSegment:
                SetupLandmarkSegmentRuleView()
                
            case .Landmark:
//                SetupLandmarkRuleView()
                EmptyView()
            case .Observation:
//                SetupObservationRuleView()
                EmptyView()
            }
            
            
        }.onAppear{
            sportManager.setCurrentSportStateRule(landmarkSegmentType: selectedLandmarkSegmentType, ruleClass: ruleClass)
        }
    }
}

