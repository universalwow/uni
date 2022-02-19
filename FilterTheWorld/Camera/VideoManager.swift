/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import AVFoundation
import SwiftUI


class VideoManager: ObservableObject {
  
  var videoUrl:URL = Bundle.main.url(forResource: "IMG_1389", withExtension: "MOV")! // use your own url
  
//  @Published var frames:[UIImage]
  
  @Published var frame: CGImage?
  private var generator:AVAssetImageGenerator!

  func getAllFrames() {
     let asset:AVAsset = AVAsset(url:self.videoUrl)
     let duration:Float64 = CMTimeGetSeconds(asset.duration)
     self.generator = AVAssetImageGenerator(asset:asset)
     self.generator.appliesPreferredTrackTransform = true
//     self.frames = []
     for index:Int in 0 ..< Int(duration) {
       print("----------------------\(index)")
        
        self.getFrame(fromTime:Float64(index))
     }
     self.generator = nil
  }

  private func getFrame(fromTime:Float64) {
      let time:CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale:600)
      let image:CGImage
      do {
         try image = self.generator.copyCGImage(at:time, actualTime:nil)
      } catch {
         return
      }
      self.frame = image
    
//      self.frames.append(UIImage(cgImage:image))
  }
  
  func generatorFrames() {
    if let path = Bundle.main.path(forResource: "IMG_1389", ofType:"MOV") {
        let fileUrl  = NSURL(fileURLWithPath: path)
        let asset = AVURLAsset(url: (fileUrl as URL), options: nil)
        let videoDuration = asset.duration
          
        let generator = AVAssetImageGenerator(asset: asset)
      generator.requestedTimeToleranceAfter = .zero;
      generator.requestedTimeToleranceBefore = .zero;

        var frameForTimes = [NSValue]()
      let sampleCounts = 30 * videoDuration.seconds.toInt
        let totalTimeLength = Int(videoDuration.seconds * Double(videoDuration.timescale))
      print("\(videoDuration.seconds)/\(videoDuration.timescale)")
        let step = totalTimeLength / sampleCounts
      
        for i in 0 ..< sampleCounts {
          
          let cmTime =
//          CMTime(seconds: i, preferredTimescale: videoDuration.timescale)
            CMTimeMake(value: Int64(i * step), timescale: Int32(videoDuration.timescale))
            frameForTimes.append(NSValue(time: cmTime))
        }
      
        generator.generateCGImagesAsynchronously(forTimes: frameForTimes, completionHandler: {requestedTime, image, actualTime, result, error in
            
            DispatchQueue.main.async {
                if let image = image {
                    print(requestedTime.value, requestedTime.seconds, actualTime.value)
                  self.frame = image
                    
                  
                }
            }
        })
    }
    
  }
  
}
