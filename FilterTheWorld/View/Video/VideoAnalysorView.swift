

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
    @EnvironmentObject var sportGround: SportsGround
    
    
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
    
    
    @State var framesPerSeconds = 20.0
    @State var fps = 25.0
    @State var framesPerGenerator = 0.0
    @State var stopAnalysis = true
    
    @State private var offset: CGSize = .zero
    @GestureState private var offsetState: CGSize = .zero
    
    @State var currentSportIndex: Int = 0
    
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
        let uiImage = imageAnalysis.sportData.frame

        VStack {
            //
            FrameView(uiImage: uiImage) //uiImage
                .scaledToFit()
                .overlay{
                    GeometryReader { geometry in
                        ZStack {
                            PosesViewForSportsGround(poses: imageAnalysis.sportData.frameData.poses, imageSize: uiImage.size, viewSize: geometry.size)
                            ObjectsViewForSportsGround(objects: imageAnalysis.sportData.frameData.objects, imageSize: uiImage.size, viewSize: geometry.size)
                            SporterView()
//                                    .clipped()
                        }
                    }
                }

            
            Spacer()
            
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
                        .onEnded { value in
                            self.scrollViewContentOffset = max(self.scrollViewContentOffset - value.translation.width, 0.0)
                        }
                )
            
            
            HStack {
                HStack {
                    Text("时间:\(secondToStandardedTime)")
                    Text("缓存:\(imageAnalysis.cachedFrames.count)")
                }
                Spacer()
                Slider(
                    value: $framesPerSeconds,
                    in: 1...StaticValue.maxFramesPerSecond,
                    step: 1,
                    label: {
                        Text("最小速率")
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
                        
                    }).background(content: {
                        Text("速率:\(self.framesPerSeconds)")
                            .offset(y: StaticValue.angleTextOffsetY)
                            .foregroundColor( .black)
                        
                    })
                
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
                        
                    }).background(content: {
                        Text("帧率:\(self.fps)")
                            .offset(y: StaticValue.angleTextOffsetY)
                            .foregroundColor( .black)
                        
                    })
                
            }
            HStack {
                Picker("选择项目", selection: $currentSportIndex) {
                    ForEach(sportGround.sports.indices, id: \.self) { sportIndex in
                        Text("\(sportGround.sports[sportIndex].name)/\(sportGround.sports[sportIndex].sportClass.rawValue)/\(sportGround.sports[sportIndex].sportPeriod.rawValue)").tag(sportIndex)
                    }
                }
                
                Button(action: {
                    if self.stopAnalysis {
                        sportGround.updateSports()

                    }
                }) {
                    Text("更新")
                }
                
                Button(action: {
                    if !sportGround.sports.isEmpty {
                        print("运动员准备")
                        self.stopAnalysis = true
                        self.scrollViewContentOffset = 0.0
                        videoManager.getFrame(time: self.scrollOffset/self.frameWidth)
                        imageAnalysis.reinit()
                        if let frame = self.videoManager.frame {
                            imageAnalysis.imageAnalysis(image: UIImage(cgImage: frame, scale: 1,orientation: orientation).fixedOrientation()!, request: nil, currentTime: self.scrollOffset/self.frameWidth)
                        }
                        

                        sportGround.addSporter(sport: sportGround.sports[currentSportIndex])
                        
                    }
                }) {
                    Text("准备")
                }
                
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
                    Text("旋转")
                }
                
                
                Button(action: {
                    if let frame = self.videoManager.frame {
                        imageAnalysis.imageAnalysis(image: UIImage(cgImage: frame, scale: 1,orientation: orientation).fixedOrientation()!, request: nil, currentTime: 0.0)
                    }
                    
                }) {
                    Text("分析图片")
                }
                
                Button(action: {
                    if !stopAnalysis {
                        return
                    }
                    
                    self.stopAnalysis = false
                    if let _ = videoUrl {
                        DispatchQueue.global(qos: .userInitiated).async {
                            
                            while !self.stopAnalysis && self.scrollOffset < self.frameWidth*CGFloat(self.videoManager.allFrames.count) && self.scrollOffset >= 0 {
                                
                                Thread.sleep(forTimeInterval: 1/self.framesPerSeconds)
                                
                                
                                videoManager.getFrame(time: self.scrollOffset/self.frameWidth)
                                DispatchQueue.main.async {
                                    let uiImage = UIImage(cgImage: videoManager.frame!, scale: 1,orientation: orientation).fixedOrientation()!
                                    imageAnalysis.imageAnalysis(image: uiImage, request: nil, currentTime: self.scrollOffset/self.frameWidth)
                                    let poses = imageAnalysis.sportData.frameData.poses
                                    let ropes = imageAnalysis.sportData.frameData.objects.filter{ object in
                                        object.label == ObjectLabel.BASKETBALL.rawValue
                                    }
                         
                                    
                                    if !sportGround.sporters.isEmpty && !poses.isEmpty {
                                        
                                        sportGround.play(poseMap: poses.first!.landmarksMaps, object: ropes.first, targetObject: nil, frameSize: uiImage.size.point2d, currentTime: self.scrollOffset/self.frameWidth)
                                        self.sportGround.objectWillChange.send()
                                    }
                                }
                                
                                
                                
                                DispatchQueue.main.async {
                                    self.scrollViewContentOffset = self.scrollViewContentOffset + self.frameWidth / self.fps
                                    print("currentIndex-3 \(self.scrollOffset/self.frameWidth)")
                                    
                                }
                            }
                            DispatchQueue.main.async {
                                if !self.stopAnalysis {
                                    self.stopAnalysis = true
                                    sportGround.saveSportReport(endTime: self.scrollOffset/self.frameWidth)
                                    self.scrollViewContentOffset = 0
                                }
                            }
                            
                        }
                        
                    }

                }) {
                    Text("分析视频")
                }
                
                Button(action: {
                    if !self.stopAnalysis {
                        self.stopAnalysis = true
                        sportGround.saveSportReport(endTime: self.scrollOffset/self.frameWidth)
                    }
                }) {
                    Text("停止")
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
//        .onChange(of: stopAnalysis, perform: { flag in
//            if flag {
//                sportGround.clearWarning()
//            }
//        })

        .onChange(of: currentSportIndex) { _ in
            print("currentsport \(currentSportIndex)")
        }
//        .onChange(of: self.scrollOffset) { newValue in
//            if self.frameWidth > 0 &&  newValue >= 0 {
//                videoManager.getFrame(time: newValue/self.frameWidth)
//                let uiImage = UIImage(cgImage: videoManager.frame!, scale: 1,orientation: orientation).fixedOrientation()!
//                imageAnalysis.imageAnalysis(image: uiImage, request: nil, currentTime: newValue/self.frameWidth)
//                let poses = imageAnalysis.sportData.frameData.poses
//                let ropes = imageAnalysis.objects.filter{ object in
//                    object.label == ObjectLabel.BASKETBALL.rawValue
//                }
//                print("currentIndex-2 \(newValue/self.frameWidth)")
//
//                if !sportGround.sporters.isEmpty && !poses.isEmpty {
//
//                    sportGround.play(poseMap: poses.first!.landmarksMaps, object: ropes.first, targetObject: nil, frameSize: uiImage.size.point2d, currentTime: newValue/self.frameWidth)
//                }
//            }
//
//        }
        
        
    }
}

