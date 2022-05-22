

import SwiftUI



struct FramesView: View {
    @ObservedObject var videoManager = VideoManager()
    
    
    @State var mediaFlag = false
    
    @State var videoUrl:URL?
    
    
    var body: some View {
        VStack {
            FrameView(cgImage: nil)
                .scaledToFit()
            Spacer()
            ScrollView([.horizontal]) {
                HStack(spacing: 0) {
                    ForEach(videoManager.frames.indices, id: \.self) {frameIndex in
                        Image(uiImage: UIImage(cgImage: videoManager.frames[frameIndex]))
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                        
                    }
                    
                }
            }
            HStack {
                Text("当前视频: \(self.videoUrl?.path ?? "nil")")
                
            }
            HStack {
                Button(action: {
                    self.mediaFlag = true
                    
                }) {
                    Text("选择视频")
                }
                Button(action: {
                    
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
