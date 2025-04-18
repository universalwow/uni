

import SwiftUI

struct SportsGroundView: View {
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    @EnvironmentObject var sportGround: SportsGround
    @EnvironmentObject var cameraPlaying: CameraViewModel
    
    @State private var loading = false
    @Namespace var ns
    @State private var selection = 0
    @State private var selectionSubmited: Int?
    @State private var lastScoreTime = 0.0
    @State private var currentState = 1
    @State private var showControlGestureView = false
    @State private var cameraIsOn = false
    

    @State var controlSport: Sport?
    @State var lastPoseMap: PoseMap? = nil
    
    var body: some View {
        
        ScrollViewReader{ scrollView in
            NavigationView {
                ZStack(alignment: .topTrailing) {
                  
                    ScrollView([.vertical]) {
                        LazyVGrid(columns: [GridItem(),GridItem(),GridItem(),GridItem()]) {
                            ForEach(sportGround.sports.indices, id: \.self) { sportIndex in
                                let sport = sportGround.sports[sportIndex]
                                NavigationLink(destination:
                                                CameraPlayingView(sport: Binding.constant(sport))
                                                .navigationTitle(Text("\(sport.name)-\(sport.sportClass.rawValue)-\(sport.sportPeriod.rawValue)"))
                                                .navigationBarTitleDisplayMode(.inline)
                                                .onAppear(perform: {
                                                    if !cameraIsOn {
                                                        cameraPlaying.startCamera()
                                                    }
                                                    sportGround.addSporter(sport: sport)
                                                    print("start camera.........\(sport.name)- \(sport.scoreTimeLimit)")

                                                })
                                                .onDisappear {
                                                    if !cameraIsOn {
                                                        cameraPlaying.stopCamera()
                                                    }
                                                    sportGround.saveSportReport(endTime: Date().timeIntervalSince1970)
                                                    if let controlSport = controlSport {
                                                        sportGround.addSporter(sport: controlSport)
                                                    }
                                                },
                                    tag: sportIndex, selection: $selectionSubmited
                                ) {
                                    CardView(card: Card(
                                        content: sport.name,
                                        sportClass: sport.sportClass,
                                        sportPeriod: sport.sportPeriod,
                                        sportDiscrete: sport.sportDiscrete ?? .None,
                                        isGestureController: sport.isGestureController,
                                        interactionType: sport.interactionType,
                                        backColor: .green))
                                    .matchedGeometryEffect(id: sportIndex, in: ns)
                                    
                                }
                            }
                        }
                        .padding([.top, .horizontal], 10)
                        .background(
                            Rectangle().stroke(currentState == 6 ? Color.yellow : Color.red , lineWidth: 10)
                                .matchedGeometryEffect(id: selection, in: ns, isSource: false)
                        )
                        Text("成绩数:\(sportGround.sporters.first?.scoreTimes.count ?? -1)/项目索引:\(self.selection)/阻塞帧:\(imageAnalysis.cachedFrames.count)").font(.largeTitle)
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    HStack {
                        Button(action: {
                            showControlGestureView = true
                        }, label: {
                            Text("控制手势")
                        }).confirmationDialog("控制手势", isPresented: $showControlGestureView, titleVisibility: .visible) {
                            Button("\(cameraIsOn ? "关闭" : "打开") 摄像头") {
                                cameraIsOn.toggle()
                            }
                            
                            ForEach(sportGround.allGrstureControllerSports, content: {
                                sport in
                                
                                Button(action: {
                                    controlSport = sport
                                    sportGround.addSporter(sport: controlSport!)
                                }, label: {
                                    Text("\(sport.sportFullName)\(controlSport?.id == sport.id ? ">" : "")")
                                    
                                })
                                
                            })
                            
                            Button("取消", role: .cancel) { }

                        }
                        
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
                    
                }
                
                
            }.navigationViewStyle(.stack)
                .onAppear(perform: {
                    if !sportGround.sports.isEmpty {
                        self.selection = 0
                    }

                    if let controlSport = controlSport {
                        sportGround.addSporter(sport: controlSport)
                    }
                    if cameraIsOn {
                        cameraPlaying.startCamera()
                        print("start camera 0.........")
                    }
                    

                })
                .onChange(of: cameraIsOn, perform: { _ in
                    if cameraIsOn {
                        cameraPlaying.startCamera()
                    }else{
                        cameraPlaying.stopCamera()
                    }
                    
                })

                .onDisappear(perform: {
                    if cameraIsOn {
                        cameraPlaying.stopCamera()
                        print("stop camera 1.........")
                    }
                   
                })
                .onChange(of: cameraPlaying.frame, perform: { frame in
                    if selectionSubmited != nil {
                        return
                    }
                    if imageAnalysis.cachedFrames.count < 5 {
                        if let frame = frame {
                            print("sportGround-1")
                            let uiImage = UIImage(cgImage: frame)
                            imageAnalysis.imageAnalysisForViewChange(image: uiImage, request: nil, currentTime: Date().timeIntervalSince1970)
                        }
                    }
                    
                    
                })
                .onChange(of: imageAnalysis.sportData.frame, perform: { _ in
                    if selectionSubmited != nil && !cameraIsOn {
                        return
                    }
                    let poses = imageAnalysis.sportData.frameData.poses
                    
                    print("sportGround- \(selectionSubmited ?? -1)")
                    
                    if !sportGround.sporters.isEmpty && !poses.isEmpty && sportGround.sporters[0].sport.isGestureController == true {
                        DispatchQueue.main.async {
                            if lastPoseMap == nil {
                                lastPoseMap = poses.first!.landmarksMaps
                            }
                            sportGround.play(poseMap: poses.first!.landmarksMaps, lastPoseMap: lastPoseMap!, objects: [], frameSize: imageAnalysis.sportData.frame.size.point2d, currentTime: imageAnalysis.sportData.frameData.currentTime)
                            lastPoseMap = poses.first!.landmarksMaps
                            self.sportGround.objectWillChange.send()
                            
                            let afterPlayScoreTimes = sportGround.sporters[0].scoreTimes
                            currentState = sportGround.sporters[0].currentStateTime.stateId

                            if afterPlayScoreTimes.count > 0 {
                                
                                let stateId = afterPlayScoreTimes.last!.stateId
                                
                                let scoreTime = afterPlayScoreTimes.last!.time
                                
                                if scoreTime <= lastScoreTime {
                                    return
                                }
                                
            //                    7：左 8： 右 9：上 10：下 11：进入
                                
                                let sportSize = sportGround.sports.count
                                var currentIndex = selection
                                print("stateId \(stateId) - currentIndex \(currentIndex)")

                                if stateId == 7 {
                                    if currentIndex > 0 {
                                        currentIndex = currentIndex - 1
                                        lastScoreTime = scoreTime
                                    }
                                } else if stateId == 8 {
                                    if currentIndex < sportSize - 1 {
                                        currentIndex = currentIndex + 1
                                        lastScoreTime = scoreTime

                                    }
                                } else if stateId == 9 {
                                    if currentIndex - 4 >= 0 {
                                        currentIndex = currentIndex - 4
                                        lastScoreTime = scoreTime

                                    }
                                } else if stateId == 10 {
                                    if currentIndex + 4 <= sportSize - 1 {
                                        currentIndex = currentIndex + 4
                                        lastScoreTime = scoreTime

                                    }
                                } else if stateId == 11 {
                                    selectionSubmited = self.selection
                                }
                                
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    self.selection = currentIndex
                                    scrollView.scrollTo(self.selection)
                                }
                            }
                        }
                    }
                })
        }
        
            
    }
}


