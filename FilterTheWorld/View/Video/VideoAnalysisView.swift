

import SwiftUI
import AVKit

struct VideoAnalysisView: View {
    
    
    struct StaticValue {
        static let angleTextOffsetY: CGFloat = -20
        static let angleImageSize: CGFloat = 35
    }
    
    @StateObject var videoManager = VideoManager()
    @State var mediaFlag = false
    @State var videoUrl:URL?
    @State var frame: CIImage?
    
    @State var framesPerSeconds = 10.0
    @State var framesPerGenerator = 0.0
    
    var body: some View {
        VStack {
            if let ciImage = frame {
                FrameView(uiImage: UIImage(ciImage: ciImage))
            }
            
            VStack {
                
                Slider(
                    value: $framesPerSeconds,
                    in: 1...30,
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
                                self.framesPerSeconds = min(30, self.framesPerSeconds + 1)
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
                
                
                    
                    Slider(
                        value: $framesPerGenerator,
                        in: 0...10,
                        step: 1,
                        label: {
                            Text("单次生成图片数")
                        },
                        minimumValueLabel: {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                                .onTapGesture {
                                    self.framesPerGenerator = max(0, self.framesPerGenerator - 1)
                                }
                        },
                        maximumValueLabel: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                                .onTapGesture {
                                    self.framesPerGenerator = min(30, self.framesPerGenerator + 1)
                                }
                        },
                        
                        onEditingChanged: { _ in
    //                        if !flag {
    //                            updateRemoteData()
    //                        }
    //
                            
                        }).background(content: {
                            Text("\(self.framesPerGenerator)")
                                .offset(y: StaticValue.angleTextOffsetY)
                                .foregroundColor( .black)
                            
                        })
            }
            
            
        }.sheet(isPresented: $mediaFlag,
                onDismiss: {
             if let videoUrl = videoUrl {
//                 videoManager.initAssetOutput(videoUrl: videoUrl)
             }
             
         }) {
             MediaPicker(mediaType: .videos, image: Binding.constant(nil), video: $videoUrl)
         }
         .onAppear{
             
         }
    }
}

struct VideoAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        VideoAnalysisView()
    }
}
