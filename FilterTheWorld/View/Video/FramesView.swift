

import SwiftUI
import AVFAudio



extension FramesView {
    var frameWidth: CGFloat {
        if self.videoManager.allFrames.count > 0 {
            
            return StaticValue.imageHeight/(CGFloat(self.videoManager.allFrames[0].height)/CGFloat(self.videoManager.allFrames[0].width))
        }
        return 0.0
        
    }
}

struct FramesView: View {
    
    struct StaticValue {
        static let imageHeight:CGFloat = 50
        static let actionWidth: CGFloat = 200
        static let actionHeight: CGFloat = 300
    }
    
    
    @StateObject var videoManager = VideoManager()
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    @EnvironmentObject var sportManager:SportsManager
    
    @State var mediaFlag = false
    
    @State var videoUrl:URL?
    
    
    @State private var scrollViewContentOffset = CGFloat(0) // Content offset available to use
    
    @State private var selectedPoseIndex = -1
    
    @State private var showSelectorAction = false
    
    @State private var orientation = UIImage.Orientation.up
    
    var poseSelector: some View {
        VStack {
            Picker("选择人", selection: $selectedPoseIndex) {
                ForEach(self.imageAnalysis.sportData.frameData.poses.indices, id: \.self) { poseIndex in
                    Text("Pose \(poseIndex)").tag(poseIndex)
                }
                Text("Invalid \(self.imageAnalysis.sportData.frameData.poses.count)")
                    .tag(self.imageAnalysis.sportData.frameData.poses.count)
            }
            Spacer()
            Button(action: {
                self.sportManager.updateSportState(
                    image: self.imageAnalysis.sportData.frame,
                    humanPose: self.imageAnalysis.selectedHumanPose())                
                
            }) {
                Text("保存 \(self.selectedPoseIndex)")
            }
        }
    }
    
    var objectsSelector: some View {
        VStack {
            
            MultiSelector(items: self.$imageAnalysis.objects) { object in
                HStack {
                    Text(object.id)
                    Spacer()
                    if object.selected {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Spacer()
            
            Button(action: {
                self.sportManager.updateSportState(
                    image: self.imageAnalysis.sportData.frame,
                    objects: self.imageAnalysis.selectedObjects())
                
            }) {
                Text("保存")
            }
        }
    }
    
    @State var poseSelectorFlag = false
    @State var objectSelectorFlag = false
    func poseBojectActionSheet() -> ActionSheet {
        
        let poseSelector = ActionSheet.Button.default(Text("Pose")) {
            poseSelectorFlag = true
            
        }
        let objectSelector = ActionSheet.Button.default(Text("Object")) {
            objectSelectorFlag = true
            
        }
        
        let buttons: [ActionSheet.Button] = [poseSelector, objectSelector, .cancel()]
        
        return ActionSheet(title: Text("功能列表"),
                           message: Text("选择功能"),
                           buttons: buttons)
    }
    
    var body: some View {
        VStack {
            if let frame = self.videoManager.frame {
                let uiImage = UIImage(cgImage: frame, scale: 1, orientation: orientation).fixedOrientation()!
                FrameView(uiImage: uiImage)
                    .scaledToFit()
                    .overlay{
                        GeometryReader { geometry in
                            ZStack {
                                PosesView(poses: imageAnalysis.sportData.frameData.poses, imageSize: uiImage.size, viewSize: geometry.size)
                                ObjectsView(objects: imageAnalysis.objects, imageSize: uiImage.size, viewSize: geometry.size)
                            }
                        }
                    }
            }else {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
            }
            
            
            Spacer()
            
            TrackableScrollView([.horizontal], showIndicators: false, contentOffset: $scrollViewContentOffset) {
                HStack(spacing: 0) {
                    ForEach(videoManager.allFrames.indices, id: \.self) {frameIndex in
                        Image(uiImage: UIImage(cgImage: videoManager.allFrames[frameIndex]))
                            .resizable()
                            .scaledToFit()
                    }
                    
                }
                
            }.frame(height: StaticValue.imageHeight)
                .background(.green)
            
            HStack {
                Text("当前视频: \(self.videoUrl?.path ?? "nil")")
                Text("当前位置  \(self.scrollViewContentOffset)")
                
            }
            HStack {
                Button(action: {
                    self.mediaFlag = true
                    
                }) {
                    Text("选择视频")
                }
                
//                Picker("旋转旋转方向", selection: $orientation) {
//                    ForEach(Image.Orientation.allCases) { direction in
//                        Text(direction.rawValue).tag(direction)
//                    }
//                }
                
                Button(action: {
                    switch self.orientation {
                    case .up:
                        self.orientation = .right
                    case .right:
                        self.orientation = .down
                    case .down:
                        self.orientation = .left
                    case .left:
                        self.orientation = .up
                    
                    default: break
                        
                
                    }
                    

                }) {
                    Text("旋转图片")
                }
                
                
                Button(action: {
                    if let frame = self.videoManager.frame {
                        imageAnalysis.imageAnalysis(image: UIImage(cgImage: frame, scale: 1,orientation: orientation).fixedOrientation()!, request: nil, currentTime: 0.0)
                    }
                    
                }) {
                    Text("分析图片")
                }
                
                Button(action: {
                    if self.imageAnalysis.sportData.frameData.poses.count > 1 ||
                        self.imageAnalysis.objects.count > 1 {
                        if !showSelectorAction && !self.poseSelectorFlag && !self.objectSelectorFlag {
                            showSelectorAction = true
                        }
                        
                    }else {
                        print("选择人/框-------------")
                    }
                    print("选择人/框------------- \(self.imageAnalysis.sportData.frameData.poses.count)/\(self.imageAnalysis.objects.count) - \(self.showSelectorAction) - \(self.poseSelectorFlag) - \(self.objectSelectorFlag)")
                    
                }) {
                    Text("选择人/框")
                }
                
                
                
                
                
            }.padding()
        }
        .padding()
        .actionSheet(isPresented: self.$showSelectorAction) {
            poseBojectActionSheet()
        }
        .popover(isPresented: self.$poseSelectorFlag) {
            poseSelector
                .frame(width: StaticValue.actionWidth, height: StaticValue.actionHeight)
                .padding()
        }
        .popover(isPresented: self.$objectSelectorFlag) {
            objectsSelector
                .frame(width: StaticValue.actionWidth, height: StaticValue.actionHeight)
                .padding()
        }
        .sheet(isPresented: $mediaFlag,
               onDismiss: {
            if let videoUrl = videoUrl {
                
                videoManager.generatorAllFrames(videoUrl: videoUrl, fps: 1.0)
                selectedPoseIndex = -1
            }
            
        }) {
            MediaPicker(mediaType: .videos, image: Binding.constant(nil), video: $videoUrl)
        }
        .onChange(of:self.selectedPoseIndex){ _ in
            if self.imageAnalysis.sportData.frameData.poses.indices.contains(self.selectedPoseIndex) {
                self.imageAnalysis.selectHumanPose(
                    selectedHumanPose: self.imageAnalysis.sportData.frameData.poses[selectedPoseIndex]
                )
            }else{
                print("------------------------invalid \(self.selectedPoseIndex)")
                self.imageAnalysis.selectHumanPose(
                    selectedHumanPose: nil
                )
            }
        }
        .onChange(of: self.scrollViewContentOffset) { newValue in
            if self.frameWidth > 0 &&  self.scrollViewContentOffset >= 0 {
                videoManager.getFrame(time: self.scrollViewContentOffset/self.frameWidth)
            }
            
        }
//        .onChange(of: imageAnalysis.sportData.frameData.poses) { newValue in
//            if newValue.count > 0 {
//                self.selectedPoseIndex = 0
//            }else {
//                self.selectedPoseIndex = -1
//            }
//        }
        
        
    }
}

struct FramesView_Previews: PreviewProvider {
    static var previews: some View {
        FramesView()
    }
}
