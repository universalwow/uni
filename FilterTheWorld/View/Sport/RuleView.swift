
import SwiftUI
import AlertToast



struct RuleView: View {
    @EnvironmentObject var sportManager:SportsManager
    
    @State var selectedLandmarkSegmentType = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    @State var selectedLandmarkType = LandmarkType.LeftShoulder
    @State var selectedObject = ObjectLabel.POSE.rawValue
    @State var selectedFixedArea = "1"
    @State var selectedDynamicArea = "1"
    @State var ruleClass = RuleClass.LandmarkSegment
    
    
    @State var showSetupRule = false
    @State var showToast = false
    
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
                
                Picker("选择关节", selection: $selectedLandmarkType) {
                    ForEach(LandmarkType.allCases) { landmarkType in
                        Text(landmarkType.id).tag(landmarkType)
                    }
                }
                
                Picker("选择物体", selection: $selectedObject.didSet( { _ in
                    ruleClass = .Observation
                    sportManager.setCurrentSportStateRule(objectLabel: self.selectedObject, ruleClass: ruleClass)
                })) {
                    ForEach(sportManager.findSelectedObjects()) { object in
                        Text(object.label).tag(object.label)
                    }
                }

                
                Picker("选择固定区域", selection: $selectedFixedArea.didSet( { _ in
                    ruleClass = .FixedArea
                    sportManager.setCurrentSportStateRule(objectLabel: self.selectedFixedArea, ruleClass: ruleClass)
                    
                })) {
                    ForEach(sportManager.findFixedAreasForSport()) { area in
                        Text(area.id).tag(area.id)
                    }
                }
                
                Picker("选择动态区域", selection: $selectedDynamicArea.didSet( { _ in
                    ruleClass = .DynamicArea
                    sportManager.setCurrentSportStateRule(objectLabel: self.selectedDynamicArea, ruleClass: ruleClass)
                    
                })) {
                    ForEach(sportManager.findDynamicAreasForSport()) { area in
                        Text(area.id).tag(area.id)
                    }
                }
                
                
                
                Button(action: {
                    if sportManager.setRule() {
                        self.showSetupRule = true
                    } else {
                        self.showToast = true
                    }
                    
                    
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
//        .onChange(of: sportManager.currentSportStateRuleClass, perform: {
//            ruleClass =
//        })
//        .onChange(of: self.selectedObject) { _ in
//
//        }
        .sheet(isPresented: self.$showSetupRule) {
            
            switch sportManager.currentSportStateRuleClass {
            case .LandmarkSegment:
                SetupLandmarkSegmentRuleView()
                
            case .Landmark:
                SetupLandmarkRuleView()
            case .Observation:
                SetupObservationRuleView()
            case .FixedArea:
//                SetupAreaRuleView()
                SetupFixedAreaRuleView()
            case .DynamicArea:
//                SetupAreaRuleView()
                SetupDynamicAreaRuleView()
            }
            
            
        }.toast(isPresenting: self.$showToast, duration: 2, tapToDismiss: false, offsetY: 0, alert: {
            AlertToast(displayMode: .alert, type: .error(.red), title: "请选择要设置的规则")
        })
       
     
//        .alert(isPresented: self.$showToast, content: {
//            Alert(title: Text("请选择要设置的规则"))
//        })
        
//        .onAppear{
//            sportManager.setCurrentSportStateRule(landmarkSegmentType: selectedLandmarkSegmentType, ruleClass: ruleClass)
//        }
    }
}

