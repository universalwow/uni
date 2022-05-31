
import Foundation
import AVFoundation
import SwiftUI


class VideoManager: ObservableObject {
    
    
    var videoUrl:URL?
    
    @Published var frame: CGImage?
    
    @Published var frameCIImage: CIImage?
    @Published var frames: [CGImage] = []
    
    @Published var allFrames: [CGImage] = [] {
        didSet {
            if allFrames.count > 0 && frame == nil {
                frame = allFrames[0]
            }
        }
    }
    
    
    private var generator:AVAssetImageGenerator!
    private var asset: AVURLAsset!
    init() {
        //        initAssetGenerator()
//        initAssetOutput()
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
    
    
    
    
    func generatorFrame(frameTime: NSValue) {
        
        if let generator = generator {
            DispatchQueue.main.async {
//                self.frames  = []
                generator.generateCGImagesAsynchronously(forTimes: [frameTime], completionHandler: {requestedTime, image, actualTime, result, error in
                    DispatchQueue.main.async {
                        if let image = image {
                            print("""
                        frame size \(image.width)/\(image.height)/\(UIImage(cgImage:image).imageOrientation.rawValue)
                  """)
                            self.frame = image
                        }
                    }
                    
                })
            }
            
            
        }
        
    }
    
    
    func generatorAllFrames(videoUrl: URL, fps: Double) {
        let frameTimes = self.generatorTimeSteps(videoUrl: videoUrl, framePerSecond: fps)
        self.generatorAllFrames(frameTimes: frameTimes)
    }
    
    func generatorTimeSteps(videoUrl: URL, framePerSecond: Double) -> [NSValue] {
        asset = AVURLAsset(url: videoUrl)
        generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceAfter = .zero;
        generator.requestedTimeToleranceBefore = .zero;
        
        print("initAssetGenerator \(videoUrl) \n \(asset.duration.seconds)")
        
        var frameForTimes = [NSValue]()
        let videoDuration = asset.duration
        let sampleCounts = (framePerSecond * videoDuration.seconds).toInt
        let totalTimeLength = Int(videoDuration.seconds * Double(videoDuration.timescale))
        let step = totalTimeLength / sampleCounts
        
        for i in 0 ..< sampleCounts {
            let cmTime = CMTimeMake(value: Int64(i * step), timescale: Int32(videoDuration.timescale))
            frameForTimes.append(NSValue(time: cmTime))
        }
        return frameForTimes
    }
    
    func getFrame(time:Double) {
        if let generator = generator {
            if time < asset.duration.seconds {
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
    }
    
    func generatorTimeSteps(videoUrl: URL, fps: Double, startTime: Double) -> [NSValue] {
        asset = AVURLAsset(url: videoUrl)
        generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceAfter = .zero;
        generator.requestedTimeToleranceBefore = .zero;
        
        print("initAssetGenerator \(videoUrl) \n \(asset.duration.seconds)")
        
        var frameForTimes = [NSValue]()
        let videoDuration = asset.duration
        let sampleCounts = (fps * videoDuration.seconds).toInt
        let totalTimeLength = Int(videoDuration.seconds * Double(videoDuration.timescale))
        let step = totalTimeLength / sampleCounts
        
        for i in 0 ..< sampleCounts {
            let cmTime = CMTimeMake(value: Int64(i * step), timescale: Int32(videoDuration.timescale))
            frameForTimes.append(NSValue(time: cmTime))
        }
        return frameForTimes
    }
    
    func generatorAllFrames(frameTimes: [NSValue]) {
        
        if let generator = generator {
            
            self.allFrames = []
            
            generator.generateCGImagesAsynchronously(forTimes: frameTimes, completionHandler: {requestedTime, image, actualTime, result, error in
                
                DispatchQueue.main.async {
                    if let image = image {
//                        print("""
//                    frame size \(image.width)/\(image.height)/\(UIImage(cgImage:image).imageOrientation.rawValue)
//              """)
                        self.allFrames.append(image)
                    }
                }
            })
            
        }
        
    }
    
    
    func generatorFrames(frameTimes: [NSValue]) {
        
        if let generator = generator {
            DispatchQueue.main.async {
                self.frames  = []
                generator.generateCGImagesAsynchronously(forTimes: frameTimes, completionHandler: {requestedTime, image, actualTime, result, error in
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
    
}
