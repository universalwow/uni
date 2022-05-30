//
//  ContentView.swift
//  SwiftUIVideoPlayerCoreImage
//
//  Created by Anupam Chugh on 25/08/20.
//

import SwiftUI
import AVKit
import CoreImage
import CoreImage.CIFilterBuiltins


struct VideoPlayerCoreImageView: View {
    
    @EnvironmentObject var sportGround: SportsGround
    @EnvironmentObject var imageAnalysis: ImageAnalysis
    
    @StateObject var videoManager = VideoManager()

    
    @State private var currentFilter = 0
    @State var mediaFlag = false
    @State var videoUrl:URL?

    
    var filters : [CIFilter?] = [nil, CIFilter.sepiaTone(), CIFilter.pixellate(), CIFilter.comicEffect()]
    let player = AVPlayer(url: Bundle.main.url(forResource: "IMG_1389", withExtension: "MOV")!)
    
    
    var body: some View {
        
        VStack{
            VideoPlayer(player: player)
                .onAppear{
                    player.currentItem!.videoComposition = AVVideoComposition(asset: player.currentItem!.asset,  applyingCIFiltersWithHandler: { request in
                        
//                        CMSampleBufferGetImageBuffer(<#T##sbuf: CMSampleBuffer##CMSampleBuffer#>)
                        
                        if let filter = self.filters[currentFilter]{
                            
                            print("request.compositionTime \(                       request.compositionTime)")
                            let source = request.sourceImage
                                                            .clampedToExtent()

                            
                            
                            filter.setValue(source, forKey: kCIInputImageKey)
                            
                            if filter.inputKeys.contains(kCIInputScaleKey){
                                filter.setValue(30, forKey: kCIInputScaleKey)
                            }
                            
                            let output = filter.outputImage!
                                .cropped(to: request.sourceImage.extent)
                            
                            
                            request.finish(with: output, context: nil)
                            
                        }
                        
                        
                        
                        
                        else{
                            request.finish(with: request.sourceImage, context: nil)
                        }
                    })
                }
            
            Picker(selection: $currentFilter, label: Text("Select Filter")) {
                ForEach(0..<filters.count) { index in
                    Text(self.filters[index]?.name ?? "None").tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
            HStack {
                Text("Value: \(self.filters[currentFilter]?.name ?? "None")")

                Button(action: {
                    self.mediaFlag = true
                    
                }) {
                    Text("选择视频")
                }
            }
        }
    }
}


