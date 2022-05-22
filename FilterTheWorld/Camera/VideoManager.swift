
import Foundation
import AVFoundation
import SwiftUI


class VideoManager: ObservableObject {
    
    
    
    var videoUrl:URL?
    
    @Published var frame: CGImage?
    @Published var frames: [CGImage] = [] {
        didSet {
            if frames.count > 0 && frame == nil {
                frame = frames[0]
            }
        }
    }
    
    
    private var generator:AVAssetImageGenerator!
    private var asset: AVURLAsset!
    init() {
        initAssetGenerator()
    }
    
    
    private func initAssetGenerator() {
        if let videoUrl = videoUrl {
            
            asset = AVURLAsset(url: videoUrl)
            print( "file exit \(FileManager.default.fileExists(atPath: videoUrl.path))")

            print("initAssetGenerator \(videoUrl) \n \(asset.duration.seconds)")
            generator = AVAssetImageGenerator(asset: asset)
            generator.requestedTimeToleranceAfter = .zero;
            generator.requestedTimeToleranceBefore = .zero;
        }
    }
    
    func getFrame(time:Double) {
        if let generator = generator {
            let currentTime = Int64(time * Double(asset.duration.timescale))
            let cmTime =
            CMTimeMake(value: currentTime, timescale: Int32(asset.duration.timescale))
            generator.generateCGImagesAsynchronously(forTimes: [cmTime as NSValue], completionHandler: {requestedTime, image, actualTime, result, error in
                
                DispatchQueue.main.async {
                    if let image = image {
                        self.frame = image
                    }
                }
            })
        }
    }
    
    func generatorFrames(videoUrl: URL?, framePerSecond: Double) {
        if let videoUrl = videoUrl {
            self.videoUrl = videoUrl
            self.initAssetGenerator()
        }
        
        if let generator = generator {
            
            var frameForTimes = [NSValue]()
            let videoDuration = asset.duration
            let sampleCounts = (framePerSecond * videoDuration.seconds).toInt
            let totalTimeLength = Int(videoDuration.seconds * Double(videoDuration.timescale))
            let step = totalTimeLength / sampleCounts
            self.frames = []
            self.frame = nil
            for i in 0 ..< sampleCounts {
                let cmTime =
                CMTimeMake(value: Int64(i * step), timescale: Int32(videoDuration.timescale))
                frameForTimes.append(NSValue(time: cmTime))
            }
            
            generator.generateCGImagesAsynchronously(forTimes: frameForTimes, completionHandler: {requestedTime, image, actualTime, result, error in
                
                DispatchQueue.main.async {
                    if let image = image {
                        print("""
                    frame size \(image.width)/\(image.height)/\(UIImage(cgImage:image).imageOrientation.rawValue)
              """)
                        self.frames.append(image)
                    }
                }
            })
            
        }
        
    }
    
}
