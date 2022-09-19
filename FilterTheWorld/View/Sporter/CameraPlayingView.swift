

import SwiftUI



struct CameraPlayingView: View {
    @Binding var sport: Sport
    
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    @EnvironmentObject var sportGround: SportsGround
    @EnvironmentObject var cameraPlaying: CameraViewModel
    @Environment(\.presentationMode) var presentationMode
    var skipFrequency = 4
    @State var frameCount = 0

    
    var body: some View {
        let uiImage = imageAnalysis.sportData.frame
        ZStack {
            FrameView(uiImage: uiImage) //uiImage
                .scaledToFit()
                .overlay {
                    GeometryReader { geometry in
                        ZStack {
                            PosesViewForSportsGround(poses: imageAnalysis.sportData.frameData.poses, imageSize: uiImage.size, viewSize: geometry.size)
                            ObjectsViewForSportsGround(objects: imageAnalysis.sportData.frameData.objects, imageSize: uiImage.size, viewSize: geometry.size)
                            RectViewForSporter(viewSize: geometry.size)
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
                }        }

        .onChange(of: cameraPlaying.frame, perform: { frame in
            if let frame = frame {
                if imageAnalysis.cachedFrames.count > 5 && frameCount % skipFrequency == 0 {
                    return
                }
                if frameCount > 1000000 {
                    frameCount = 0
                }
                
                let uiImage = UIImage(cgImage: frame)
                imageAnalysis.imageAnalysis(image: uiImage, request: nil, currentTime: Date().timeIntervalSince1970)
            }
            
        })
        .onChange(of: imageAnalysis.sportData.frame, perform: { _ in
            let poses = imageAnalysis.sportData.frameData.poses
            let ropes = imageAnalysis.sportData.frameData.objects.filter{ object in
                object.label == ObjectLabel.BASKETBALL.rawValue
            }
            
            let human = imageAnalysis.sportData.frameData.objects.filter{ object in
                object.label == ObjectLabel.POSE.rawValue
            }
            
            if !sportGround.sporters.isEmpty && !poses.isEmpty {
                
                sportGround.play(poseMap: poses.first!.landmarksMaps, object: ropes.first, targetObject: human.first, frameSize: uiImage.size.point2d, currentTime: imageAnalysis.sportData.frameData.currentTime)
                self.sportGround.objectWillChange.send()

            }
            
        }).navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading:
                Button(action : { self.presentationMode.wrappedValue.dismiss()
//                    sportGround.addSporter(sport: controlSport)
//                    cameraPlaying.startCamera()
//                    print("start camera 1.........")
                }){
                    Text("Cancel")
                }
                )
        
    }
}


