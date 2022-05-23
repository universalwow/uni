

import Foundation

import MLKit
import UIKit
import AVFoundation
import SwiftUI




struct FrameShowData {
  var fps = 0
  var currentTime = 0.0
  var poses: [HumanPose] = []
  
  mutating func selectePose(pose: HumanPose?) {
      if let pose = pose {
          poses.indices.forEach { index in
            let humanPose = poses[index]
            if humanPose.id == pose.id {
              poses[index].toggle()
            } else {
              poses[index].noselected()
            }
            
          }

      }else{
          poses.indices.forEach { index in
              poses[index].noselected()
          }
      }
    
  }
  
  var selectedPose : HumanPose? {
    poses.first { pose in
      pose.isSelected
    }
  }
}


class PoseRecognizer: ObservableObject {
  private var poseDetector: PoseDetector?
  let landmarkMirror = true
  @Published var frameData = FrameShowData()
//  @Published var uiImage = UIImage()
  
  // 计算帧率
  var frameCount = 0
  var lastTime = Date().timeIntervalSince1970
  
  
  
  func computeFps() -> Int? {
    frameCount += 1
    let currentTime = Date().timeIntervalSince1970
    print("\(currentTime)/\(lastTime)/\(frameCount)")
    
    if (currentTime - lastTime > 2.0) {
      lastTime = currentTime
      return frameCount/2
    }
    return nil
  }
  
  
  init(){
    let options = AccuratePoseDetectorOptions()
    options.detectorMode = .singleImage
    poseDetector = PoseDetector.poseDetector(options: options)
  }
  
  
  
  
  func detectPose(image: VisionImage, request: AVAsynchronousCIImageFilteringRequest?, currentTime: Double){
    
    guard let poseDetector = self.poseDetector else {
      request?.finish(with: request!.sourceImage, context: nil)
        return
    }
    
    poseDetector.process(image) { detectedPoses, error in
      guard error == nil else {
        request?.finish(with: request!.sourceImage, context: nil)
        return
      }
      
      let fps = self.computeFps()
      if fps != nil {
        self.frameCount = 0
      }
      guard let detectedPoses = detectedPoses else {
        request?.finish(with: request!.sourceImage, context: nil)
              DispatchQueue.main.async {
                self.frameData = FrameShowData(fps: fps ?? self.frameData.fps, currentTime: currentTime, poses: [])
              }
          return
      }
      
      DispatchQueue.main.async {
        var detectedHumanPoses = [HumanPose]()
        for poseIndex in detectedPoses.indices {
          var newPose = HumanPose(id: poseIndex)
          let pose = detectedPoses[poseIndex].landmarks
          for landmarkIndex in  pose.indices {
            let newLandmark = Landmark(position: Point3D(x: pose[landmarkIndex].position.x,
                                                         y: pose[landmarkIndex].position.y,
                                                         z: pose[landmarkIndex].position.z),
                                       landmarkType: LandmarkType(rawValue: pose[landmarkIndex].type.rawValue.landmarkTypeRawValueMirror)!)
            newPose.upsertLandmark(landmark: newLandmark)
          }
          newPose.initLandmarkSegments()
          detectedHumanPoses.append(newPose)
        }
        self.frameData = FrameShowData(fps: fps ?? self.frameData.fps, currentTime: currentTime, poses: detectedHumanPoses)
        
        if detectedHumanPoses.count == 0 {
          request?.finish(with: request!.sourceImage, context: nil)

        }else{
          
//          let uiImage = self.drawContours(sourceImage: request!.sourceImage.oriented(.downMirrored).convertCIImageToCGImage()! , poses: detectedHumanPoses)
          
//          request?.finish(with: CIImage(image: uiImage)!, context: nil)
          request?.finish(with: request!.sourceImage, context: nil)

        }

  
      }
      
    }
  }
  
  
  func addPath(poses: [HumanPose]) -> CGPath {
    
    var path = Path()
    
    poses.forEach{ pose in
      pose.landmarkSegments.forEach{landmarkSegment in
        path.move(to: landmarkSegment.startLandmark.position.vector2d.toCGPoint)
        path.addLine(to: landmarkSegment.endLandmark.position.vector2d.toCGPoint)
      }
      
    }
    
    
    return path.cgPath
  }
  
  
  func drawContours(sourceImage: CGImage, poses: [HumanPose]) -> UIImage {
    let size = CGSize(width: sourceImage.width, height: sourceImage.height)
    let renderer = UIGraphicsImageRenderer(size: size)
    
    let renderedImage = renderer.image { (context) in
    let renderingContext = context.cgContext

    renderingContext.draw(sourceImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      
    renderingContext.setLineWidth(4)
    let redUIColor = UIColor.red
    renderingContext.setStrokeColor(redUIColor.cgColor)

    renderingContext.addPath(addPath(poses: poses))
        
    renderingContext.strokePath()
    }
    
    
    
    return resizeImage(image: renderedImage, newWidth: size.width)
}
  
  
  // resize image
  func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
      let scale = newWidth / image.size.width
      let newHeight = image.size.height * scale
      UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
      image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
        
    return newImage!
  }
  
}
