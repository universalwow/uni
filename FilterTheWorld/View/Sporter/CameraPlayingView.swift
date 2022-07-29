

import SwiftUI



struct CameraPlayingView: View {
    @Binding var sport: Sport
    
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    @EnvironmentObject var sportGround: SportsGround
    @EnvironmentObject var cameraPlaying: CameraViewModel
    
    
    var body: some View {
        let uiImage = imageAnalysis.sportData.frame
        ZStack {
            if uiImage.size.width > 0 {
                FrameView(uiImage: imageAnalysis.sportData.frame) //uiImage
                    .scaledToFit()
                    .overlay{
                        GeometryReader { geometry in
                            ZStack {
                                PosesViewForSportsGround(poses: imageAnalysis.sportData.frameData.poses, imageSize: uiImage.size, viewSize: geometry.size)
                                ObjectsViewForSportsGround(objects: imageAnalysis.objects, imageSize: uiImage.size, viewSize: geometry.size)
                                SporterView()
                                VStack(alignment: .leading) {
                                    Spacer()
                                    HStack {
                                        Text("缓存:\(imageAnalysis.cachedFrames.count)")
                                            .font(.largeTitle)
                                        Spacer()
                                    }
                                }
                                
                                
                            }
                        }
                    }
                    
                } else {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                }
        }.onAppear(perform: {
            cameraPlaying.startCamera()
            sportGround.addSporter(sport: sport)
            print("start camera.........\(sport.name)- \(sport.scoreTimeLimit ?? 0)")

        })
        .onDisappear(perform: {
            cameraPlaying.stopCamera()
            print("stop camera.........")
        })
        .onChange(of: cameraPlaying.frame, perform: { frame in
            if let frame = frame {
                let uiImage = UIImage(cgImage: frame)
                imageAnalysis.imageAnalysis(image: uiImage, request: nil, currentTime: Date().timeIntervalSince1970)
            }
            
        })
        .onChange(of: imageAnalysis.sportData.frame, perform: { _ in
            let poses = imageAnalysis.sportData.frameData.poses
            let ropes = imageAnalysis.objects.filter{ object in
                object.label == ObjectLabel.ROPE.rawValue
            }
            print("sportGround \(sportGround.sporters.isEmpty)  \(poses.isEmpty)  \(ropes.isEmpty) \(sportGround.sporters.first?.scoreTimes.count)")
            
            if !sportGround.sporters.isEmpty && !poses.isEmpty {
                
                sportGround.play(poseMap: poses.first!.landmarksMaps, object: ropes.first, targetObject: nil, frameSize: uiImage.size.point2d, currentTime: imageAnalysis.sportData.frameData.currentTime)
            }
            
        })
        
    }
}


