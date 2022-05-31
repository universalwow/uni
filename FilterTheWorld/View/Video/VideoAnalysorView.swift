

import SwiftUI
import AVFAudio



extension VideoAnalysorView {
    var frameWidth: CGFloat {
        if self.videoManager.allFrames.count > 0 {
            
            return StaticValue.imageHeight/(CGFloat(self.videoManager.allFrames[0].height)/CGFloat(self.videoManager.allFrames[0].width))
        }
        return 0.0
        
    }
}

struct VideoAnalysorView: View {
    
    struct StaticValue {
        static let imageHeight:CGFloat = 50
        static let actionWidth: CGFloat = 200
        static let actionHeight: CGFloat = 300
        static let angleTextOffsetY: CGFloat = -20
        static let angleImageSize: CGFloat = 35
        static let maxFramesPerSecond = 60.0
    }
    
    
    @StateObject var videoManager = VideoManager()
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    
    @State var mediaFlag = false
    
    @State var videoUrl:URL?
    
    
    @State private var scrollViewContentOffset = CGFloat(0)
    // Content offset available to use
    var scrollOffset : CGFloat {
        self.scrollViewContentOffset - offsetState.width
    }
    
    @State private var selectedPoseIndex = -1
    
    @State private var showSelectorAction = false
    
    @State private var orientation = UIImage.Orientation.up
    
    
    @State var framesPerSeconds = 10.0
    @State var fps = 10.0
    @State var framesPerGenerator = 0.0
    @State var stopAnalysis = false
    
    @State private var offset: CGSize = .zero
    @GestureState private var offsetState: CGSize = .zero

    
    var secondToStandardedTime:String {
        if self.frameWidth > 0 && self.scrollOffset >= 0.0 {
            let second = Double(self.scrollOffset/self.frameWidth)
            let minutes = Int(floor(second/60))
            let seconds = Int(floor(second - CGFloat(minutes*60)))
            let macroSeconds = Int((second - floor(second)) * 1000)
            return "\(minutes):\(seconds).\(macroSeconds)"
        }else {
            return "00:00.000"
        }
        
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
            
//            TrackableScrollView([.horizontal], showIndicators: false, contentOffset: $scrollViewContentOffset) {
//                HStack(spacing: 0) {
//                    ForEach(videoManager.allFrames.indices, id: \.self) {frameIndex in
//                        Image(uiImage: UIImage(cgImage: videoManager.allFrames[frameIndex]))
//                            .resizable()
//                            .scaledToFit()
//                    }
//
//                }
//
//            }
//            .frame(height: StaticValue.imageHeight)
//                .background(.green)
            
            
            HStack(spacing: 0) {
                Color.green.overlay{
                    GeometryReader { _ in
                        HStack(spacing: 0) {
                            ForEach(videoManager.allFrames.indices, id: \.self) {frameIndex in
                                Image(uiImage: UIImage(cgImage: videoManager.allFrames[frameIndex]))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: frameWidth, height: StaticValue.imageHeight)
                                    
                            }
                        }
                            .offset(x: -self.scrollOffset, y: 0)
                    }
                    
                    
                    
                }
            }.frame(height: StaticValue.imageHeight)
                .clipped()
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .updating($offsetState) { value, state, transaction in
                            state = value.translation
                        }

//                                   .onChanged { value in
//
//                                       self.offset = value.translation
//                                   }
                        .onEnded { value in
                            self.scrollViewContentOffset = max(self.scrollViewContentOffset - value.translation.width, 0.0)
                                   }
                )
            
            
            HStack {
                Text("速率(每秒钟播放的图片数)")
                Slider(
                    value: $framesPerSeconds,
                    in: 1...StaticValue.maxFramesPerSecond,
                    step: 1,
                    label: {
                        Text("最小帧率")
                    },
                    minimumValueLabel: {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                            .onTapGesture {
                                self.framesPerSeconds = max(1, self.framesPerSeconds - 1)
                            }
                    },
                    maximumValueLabel: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                            .onTapGesture {
                                self.framesPerSeconds = min(StaticValue.maxFramesPerSecond, self.framesPerSeconds + 1)
                            }
                    },
                    
                    onEditingChanged: { _ in
//                        if !flag {
//                            updateRemoteData()
//                        }
//
                        
                    }).background(content: {
                        Text("\(self.framesPerSeconds)")
                            .offset(y: StaticValue.angleTextOffsetY)
                            .foregroundColor( .black)
                        
                    })
                
                
                Text("帧率(每秒抽取的帧数)")
                Slider(
                    value: $fps,
                    in: 1...StaticValue.maxFramesPerSecond,
                    step: 1,
                    label: {
                        Text("最小帧率")
                    },
                    minimumValueLabel: {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                            .onTapGesture {
                                self.fps = max(1, self.fps - 1)
                            }
                    },
                    maximumValueLabel: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                            .onTapGesture {
                                self.fps = min(StaticValue.maxFramesPerSecond, self.fps + 1)
                            }
                    },
                    
                    onEditingChanged: { _ in
//                        if !flag {
//                            updateRemoteData()
//                        }
//
                        
                    }).background(content: {
                        Text("\(self.fps)")
                            .offset(y: StaticValue.angleTextOffsetY)
                            .foregroundColor( .black)
                        
                    })
                
            }
            HStack {
                Text("当前位置  \(secondToStandardedTime)")
                Text("缓存帧数  \(imageAnalysis.cachedFrames.count)")
                Spacer()
                Button(action: {
                    self.mediaFlag = true
                    
                }) {
                    Text("选择视频")
                }
                
                
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
                    self.stopAnalysis = false
                    if let _ = videoUrl {
                        DispatchQueue.global(qos: .userInitiated).async {

                            while !self.stopAnalysis && self.scrollOffset < self.frameWidth*CGFloat(self.videoManager.allFrames.count) && self.scrollOffset >= 0 {
                                Thread.sleep(forTimeInterval: 1/self.framesPerSeconds)
                                DispatchQueue.main.async {
                                    self.scrollViewContentOffset = self.scrollViewContentOffset + self.frameWidth / self.fps
                                }
                            }
                            DispatchQueue.main.async {
                                if !self.stopAnalysis {
                                    self.scrollViewContentOffset = 0
                                }
                            }
                            
                            
                            
                        }
                        

                    }
                    
                
                    
                }) {
                    Text("分析视频")
                }
                
                Button(action: {
                    self.stopAnalysis = true
                }) {
                    Text("停止分析")
                }
                
                
                
                
                
                
                
            }.padding()
        }
        .padding()
        
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
        .onChange(of: self.scrollOffset) { newValue in
            if self.frameWidth > 0 &&  self.scrollOffset >= 0 {
                videoManager.getFrame(time: self.scrollOffset/self.frameWidth)
            }
            
        }
        
        
    }
}

