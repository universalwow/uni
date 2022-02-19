
import CoreImage
import Vision
import UIKit
import MLKit
import PhotosUI
import CoreVideo
import MLImage
import SwiftUI
import Foundation


struct SportDataShow: Equatable {
  static func == (lhs: SportDataShow, rhs: SportDataShow) -> Bool {
    lhs.frameData.currentTime == rhs.frameData.currentTime
  }
  
  var frameData:FrameShowData = FrameShowData()
  var frame:UIImage = UIImage()
}

class ImageAnalysis : ObservableObject {
  @Published var faces:[Face]?
  private var to_crop :UIImage? = nil
  
  @Published var detectedObjects:[CGRect]?
  @Published var modelInited = false
  @Published var sportData:SportDataShow = SportDataShow()
  
  
  @Published var cachedFrames:[(Double, UIImage)] = []
  var currentFrame:UIImage?
    
  private var faceRecognizer :FaceRecognizer?
  
  private(set) var poseRecognizer: PoseRecognizer?
  private(set) var objectRecognizer: ObjectRecognizer?


  init() {
    DispatchQueue.global(qos: .userInteractive).async {
      self.faceRecognizer = FaceRecognizer()
      self.poseRecognizer = PoseRecognizer()
      self.objectRecognizer = ObjectRecognizer()
      
      self.setupSubscriptions()
      DispatchQueue.main.async {
        self.modelInited = true
        print("inited..............")

      }
    }
    
    
    
  }
  
  func setupSubscriptions() {

    poseRecognizer?.$frameData
      .receive(on: RunLoop.main)
      .map { frameData in
        
        if let index = self.cachedFrames.firstIndex(where: { cache in
          String(cache.0) == String(frameData.currentTime)
        }) {
          let image = self.cachedFrames[index].1
          self.cachedFrames.removeAll(where: { cache in
            cache.0 <= frameData.currentTime
          })
          

          return SportDataShow(frameData: frameData, frame: image)
        }else{
          self.cachedFrames.removeAll(where: { cache in
            cache.0 <= frameData.currentTime
          })
          return SportDataShow(frameData: frameData, frame: self.sportData.frame)
          
        }
        
      }
      .assign(to: &$sportData)
  }
    
  
  func detectorProcess(image: UIImage, request: AVAsynchronousCIImageFilteringRequest?, currentTime: TimeInterval) {
    DispatchQueue.global(qos: .userInitiated).async {
      
      let visionImage = VisionImage(image: image)
      visionImage.orientation = image.imageOrientation
//      print(image.imageOrientation.rawValue)
//      self.findObjects(image: visionImage)
      self.findPoses(image: visionImage, request: request, currentTime: currentTime)
      
    }
  }

  // 物体检测
  func findObjects(image: VisionImage) {
    self.objectRecognizer?.detectObject(image: image)
  }
  
  // 关节点检测
  func findPoses(image: VisionImage, request: AVAsynchronousCIImageFilteringRequest?, currentTime: Double){
    if let poseRecognizer = poseRecognizer {
      poseRecognizer.detectPose(image: image, request: request, currentTime: currentTime)
    }else{
      request?.finish(with: request!.sourceImage, context: nil)
    }

  }

  func imageAnalysis(image: UIImage, request: AVAsynchronousCIImageFilteringRequest?, currentTime: Double) {
    DispatchQueue.main.async {
      self.currentFrame = image
      self.cachedFrames.append((currentTime, image))
      self.detectorProcess(image: image, request: request, currentTime: currentTime)
    }
    

  }
}


extension ImageAnalysis {
  
  private func detectFace(in image: CVPixelBuffer, imageSize: CGSize) {
    DispatchQueue.main.async {
      self.faces = []

    }
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    if results.count == 0 {
                    }
                    else {
                      self.to_crop = UIImage.getUI(buffer: image)
                      self.handleFaceDetectionResults(results, imageSize: imageSize)
                    }
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .up, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    
  private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation], imageSize:CGSize) {
        DispatchQueue.global(qos: .userInitiated).sync {
            for face in observedFaces {
                // 人脸在原始图片上的位置
              let originRect = CGRect(x: face.boundingBox.origin.x * imageSize.width,
                                      y: (1 - face.boundingBox.origin.y - face.boundingBox.height) * imageSize.height, width: face.boundingBox.width*imageSize.width, height: face.boundingBox.height*imageSize.height)
                
                guard let cropped = self.to_crop!.cropFace((self.to_crop?.cgImage)!, toRect: originRect) else {return}
              
                            
              self.faceRecognizer?.recognize(image: cropped)
              
              faces?.append(Face(name: "\(self.faceRecognizer!.name)/\(self.faceRecognizer!.probability.roundTo(places: 2))", rect: originRect))

            }
        }
    }
}


extension ImageAnalysis {
  
  func selectLandmarkSegment(selectedHumanPose: HumanPose, selectedlandmarkSegment: LandmarkSegment) {
    self.sportData.frameData.poses[(self.sportData.frameData.poses.firstIndex { humanPose in
      humanPose.id == selectedHumanPose.id
    })!].selectLandmarkSegment(selectedlandmarkSegment: selectedlandmarkSegment)
  }
  
  func updateSegmentAngleRange(selectedHumanPose: HumanPose, selectedlandmarkSegment: LandmarkSegment) {
    self.sportData.frameData.poses[(self.sportData.frameData.poses.firstIndex { humanPose in
      humanPose.id == selectedHumanPose.id
    })!].updateSegmentAngleRange(selectedlandmarkSegment: selectedlandmarkSegment)
    
    
  }
}

