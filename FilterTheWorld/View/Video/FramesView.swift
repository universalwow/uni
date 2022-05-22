

import SwiftUI



extension FramesView {
    var frameWidth: CGFloat {
        if self.videoManager.frames.count > 0 {
            
            return StaticValue.imageHeight/(CGFloat(self.videoManager.frames[0].height)/CGFloat(self.videoManager.frames[0].width))
        }
        return 0.0
        
    }
}

struct FramesView: View {
    
    
    struct StaticValue {
        static let imageHeight:CGFloat = 50
        
    }
    
    
    @StateObject var videoManager = VideoManager()
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    
    
    @State var mediaFlag = false
    
    @State var videoUrl:URL?
    
    @State private var scrollViewContentOffset = CGFloat(0) // Content offset available to use
    
    var body: some View {
        VStack {
            FrameView(cgImage: self.videoManager.frame)
                .scaledToFit()
                .overlay{
                    if let frame = self.videoManager.frame {
                        GeometryReader { geometry in
                            ZStack {
                                PosesView(poses: imageAnalysis.sportData.frameData.poses, imageSize: CGSize(width: frame.width, height: frame.height), viewSize: geometry.size)
                                ObjectsView(objects: imageAnalysis.objects, imageSize: CGSize(width: frame.width, height: frame.height), viewSize: geometry.size)
                            }
                            
                        }
                        
                    }
                    
                    
                }
            Spacer()
            
            TrackableScrollView([.horizontal], showIndicators: false, contentOffset: $scrollViewContentOffset) {
                HStack(spacing: 0) {
                    ForEach(videoManager.frames.indices, id: \.self) {frameIndex in
                        Image(uiImage: UIImage(cgImage: videoManager.frames[frameIndex]))
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
                
                
                Button(action: {
                    if let frame = self.videoManager.frame {
                        imageAnalysis.imageAnalysis(image: UIImage(cgImage: frame), request: nil, currentTime: 0.0)
                    }
                    
                }) {
                    Text("分析图片")
                }
            }.padding()
        }
        .padding()
        .sheet(isPresented: $mediaFlag,
               onDismiss: {
            if let videoUrl = videoUrl {
                videoManager.generatorFrames(videoUrl: videoUrl, framePerSecond: 1.0)
            }
            
        }) {
            MediaPicker(mediaType: .videos, image: Binding.constant(nil), video: $videoUrl)
        }
        .onChange(of: self.scrollViewContentOffset) { newValue in
            if self.frameWidth > 0 &&  self.scrollViewContentOffset >= 0 {
                videoManager.getFrame(time: self.scrollViewContentOffset/self.frameWidth)
            }
            
        }
        
        .onAppear{
            videoManager.generatorFrames(videoUrl: nil, framePerSecond: 1.0)
            //            videoManager.getFrame(time: 1)
        }
        
    }
}

struct FramesView_Previews: PreviewProvider {
    static var previews: some View {
        FramesView()
    }
}
