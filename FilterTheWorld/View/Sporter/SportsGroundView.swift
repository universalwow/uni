

import SwiftUI

struct SportsGroundView: View {
    @EnvironmentObject var sportGround: SportsGround
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    @EnvironmentObject var cameraPlaying: CameraViewModel
    
    @State private var loading = false
    @Namespace var ns
    @State private var selection = UUID()
    @State private var selectionSubmited: UUID?
    @State private var lastScoreTime = 0.0

    var controlSport: Sport = SportsGround.allSports.first(where: { sport in
        sport.name == "控制手势"
    })!
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                ScrollView([.vertical]) {
                    LazyVGrid(columns: [GridItem(),GridItem(),GridItem(),GridItem()]) {
                        ForEach(sportGround.sports) { sport in
                            NavigationLink(destination:
                                            CameraPlayingView(sport: Binding.constant(sport))
                                            .navigationTitle(Text("\(sport.name)-\(sport.sportClass!.rawValue)-\(sport.sportPeriod!.rawValue)"))
                                            .navigationBarTitleDisplayMode(.inline)
                                            .onDisappear {
                                                sportGround.addSporter(sport: controlSport)
                                                cameraPlaying.startCamera()
                                                print("start camera 1.........")
                                                    },
                                tag: sport.id, selection: $selectionSubmited
                            ) {
                                CardView(card: Card(
                                    content: sport.name,
                                    sportClass: sport.sportClass ?? .None,
                                    sportPeriod: sport.sportPeriod ?? .None,
                                    backColor: .green))
                                .matchedGeometryEffect(id: sport.id, in: ns)
                                
                            }
                        }
                    }
                    .padding([.top, .horizontal], 10)
                    .background(
                        Rectangle().stroke(Color.red, lineWidth: 5)
                            .matchedGeometryEffect(id: selection, in: ns, isSource: false)
                    )
                    Text("\(sportGround.sporters.first?.scoreTimes.count ?? -1)/\(imageAnalysis.cachedFrames.count)\n\(self.selection)").font(.largeTitle)
                }.navigationBarTitle("")
                    .navigationBarHidden(true)
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding()
                    .foregroundColor(.yellow)
                    .rotationEffect(self.loading ?  Angle(degrees: 0) : Angle(degrees: 360))
                    .onTapGesture {
                        withAnimation(Animation.linear(duration: 1)) {
                            self.loading.toggle()
                        }
                        sportGround.updateSports()
                    }
            }
            
            
        }.navigationViewStyle(.stack)
            .onAppear(perform: {
                if !sportGround.sports.isEmpty {
                    self.selection = sportGround.sports[0].id
                }
                sportGround.addSporter(sport: controlSport)
                cameraPlaying.startCamera()
                print("start camera 0.........")

            })

            .onDisappear(perform: {
                cameraPlaying.stopCamera()
                print("stop camera 1.........")
            })
            .onChange(of: cameraPlaying.frame, perform: { frame in
                if imageAnalysis.cachedFrames.count < 5 {
                    if let frame = frame {
                        print("sportGround-1")
                        let uiImage = UIImage(cgImage: frame)
                        imageAnalysis.imageAnalysisForViewChange(image: uiImage, request: nil, currentTime: Date().timeIntervalSince1970)
                    }
                }
                
                
            })
            .onChange(of: imageAnalysis.sportData.frame, perform: { _ in
                let poses = imageAnalysis.sportData.frameData.poses
                
                print("sportGround- \(sportGround.sporters.isEmpty)\(poses.isEmpty)  \(sportGround.sporters.first?.scoreTimes.count)")
                
                if !sportGround.sporters.isEmpty && !poses.isEmpty {
                    
                    DispatchQueue.main.async {
                        sportGround.play(poseMap: poses.first!.landmarksMaps, object: nil, targetObject: nil, frameSize: imageAnalysis.sportData.frame.size.point2d, currentTime: imageAnalysis.sportData.frameData.currentTime)
                        
                        let afterPlayScoreTimes = sportGround.sporters[0].scoreTimes
            

                        if afterPlayScoreTimes.count > 1 {
                            let stateId = afterPlayScoreTimes.last!.0
                            let scoreTime = afterPlayScoreTimes.last!.1
                            
                            if scoreTime <= lastScoreTime {
                                return
                            }
                            
        //                    4：左 5： 右 6：上 7：下 8：进入
                            
                            let sportSize = sportGround.sports.count
                            var currentIndex = sportGround.sports.firstIndex(where: { sport in
                                sport.id == selection
                            })!
                            print("stateId \(stateId) - currentIndex \(currentIndex)")

                            if stateId == 4 {
                                if currentIndex > 0 {
                                    currentIndex = currentIndex - 1
                                    lastScoreTime = scoreTime
                                }
                            } else if stateId == 5 {
                                if currentIndex < sportSize - 1 {
                                    currentIndex = currentIndex + 1
                                    lastScoreTime = scoreTime

                                }
                            } else if stateId == 6 {
                                if currentIndex - 4 >= 0 {
                                    currentIndex = currentIndex - 4
                                    lastScoreTime = scoreTime

                                }
                            } else if stateId == 7 {
                                if currentIndex + 4 <= sportSize - 1 {
                                    currentIndex = currentIndex + 4
                                    lastScoreTime = scoreTime

                                }
                            } else if stateId == 8 {
                                selectionSubmited = self.selection
                            }
                            
                            withAnimation(.easeInOut(duration: 1.0)) {
                                self.selection = sportGround.sports[currentIndex].id
                            }
                        }
                    }
                }
            })
            
    }
}


