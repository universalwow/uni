
import CoreImage
import Vision
import UIKit
import MLKit
import PhotosUI
import CoreVideo
import MLImage



extension Double {
    public func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Double {
  var toInt:Int {
    Int(self)
  }
}

struct Face: Identifiable {
  var id = UUID()
  var name: String
  //百分数
  var rect: CGRect
}

class ContentViewModel: ObservableObject {
  @Published var error: Error?
  @Published var frame: CGImage?
  @Published var faces:[Face]?
  @Published var detectedObjects:[CGRect]?
  @Published var detectedBodyKeyPoints:[CGRect]?
  
  



  @Published var comicFilter = false
  var monoFilter = false
  var crystalFilter = false
  var cameraStop = false
  

  // 是否进行识别
  var detectFace = false
  
  private var to_crop :UIImage? = nil

  private let context = CIContext()
  private var recognizer :FaceRecognizer?
  
  private var objectDetector: ObjectDetector?
  private var poseDetector: PoseDetector?
  
  var objectDetectorYOLO: ObjectRecoginzerYOLO?


  private let cameraManager = CameraManager.shared
  private let frameManager = FrameManager.shared

  init() {
    
    DispatchQueue.global(qos: .userInteractive).async {
//      self.recognizer = FaceRecognizer()
//      self.initObjectDetector()
//      self.initPoseDetector()
      self.objectDetectorYOLO = ObjectRecoginzerYOLO(yoloModelName: "yolov5-pipeline")

      self.setupSubscriptions()
      print("init................")
      
    }
    
  }
  
  func stopCamera() {
    
    cameraManager.stop()
    cameraStop = true
  }
  
  func startCamera() {
    cameraManager.start()
    cameraStop = false
  }
  
  func startRecord() {
    if !cameraStop {
      frameManager.startRecording()
//      cameraManager.startRecording()
    }
  }
  
  func stopRecord() {
    if !cameraStop && !cameraStop {
//      cameraManager.stopRecording()
      frameManager.stopRecording()

      
    }
  }
  
  
  func initObjectDetector() {
    let options = ObjectDetectorOptions()
    options.detectorMode = .singleImage
    options.shouldEnableMultipleObjects = true
    options.shouldEnableClassification = true
    
    objectDetector = ObjectDetector.objectDetector(options: options)
  }
  
  func initPoseDetector() {
    let options = AccuratePoseDetectorOptions()
    options.detectorMode = .singleImage
    poseDetector = PoseDetector.poseDetector(options: options)
  }
  
  
  func detectorProcess(image: UIImage) {
    DispatchQueue.global(qos: .userInitiated).async {
      guard let objectDetector = self.objectDetector else {
            return
        }

      let visionImage = VisionImage(image: image)
      visionImage.orientation = image.imageOrientation

      objectDetector.process(visionImage) { detectedObjects, error in
          guard error == nil else {
              return
          }

          guard let detectedObjects = detectedObjects,
                !detectedObjects.isEmpty else {
              return
          }


        self.setupOverlayView(image: image, detectedObjects: detectedObjects)

      }
    //
      guard let poseDetector = self.poseDetector else {
          return
      }
      
      poseDetector.process(visionImage) { detectedPoses, error in
        guard error == nil else {
          // Error.
          return
        }
          
          
          guard let detectedPoses = detectedPoses,
                !detectedPoses.isEmpty else {
              return
          }
          
        self.setupOverlayViews(image: image, detectedPoses: detectedPoses)
      }
    }
    
    
      
      
  }
  
  func setupOverlayViews(image: UIImage, detectedPoses: [Pose]) {
//      print("pose count... \(detectedPoses.count)")
      self.detectedBodyKeyPoints = []
      for i in 0..<detectedPoses.count {
          let pose = detectedPoses[i].landmarks
          for j in  0..<pose.count {
              let position = pose[j].position
            
            detectedBodyKeyPoints?.append(CGRect(x: position.x, y: position.y, width: 2, height: 2))
                              
          }
      }
  }
  
  
  func setupOverlayView(image: UIImage, detectedObjects: [Object]) {

    self.detectedObjects = []
      for i in 0..<detectedObjects.count {
        self.detectedObjects?.append(detectedObjects[i].frame)

      }
  }

  func setupSubscriptions() {
    // swiftlint:disable:next array_init
    
    
    cameraManager.$error
      .receive(on: RunLoop.main)
      .map { $0 }
      .assign(to: &$error)

    frameManager.$current
      .receive(on: RunLoop.main)
      .compactMap { buffer in
//
//        let uiImage = UIImage(named: "720_1280")
//        let buffer = uiImage?.toCVPixelBuffer()
        
        guard let image = CGImage.create(from: buffer) else {
          print("---------------get nil")
          return nil
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
          self.objectDetectorYOLO?.detectObject(in: buffer!, imageSize: CGSize(width: image.width, height: image.height),currentTime: 0)
        }
        
//        let uiImage = UIImage(cgImage: image)
        
        
//        self.detectFace(in: buffer!)
        
       
//        var ciImage = CIImage(cgImage: image)
        

        
//        self.detectorProcess(image: UIImage(cgImage: image))
//
//        if self.comicFilter {
//          ciImage = ciImage.applyingFilter("CIComicEffect")
//        }
//
//        if self.monoFilter {
//          ciImage = ciImage.applyingFilter("CIPhotoEffectNoir")
//        }
//
//        if self.crystalFilter {
//          ciImage = ciImage.applyingFilter("CICrystallize")
//        }
        
//        return self.context.createCGImage(ciImage, from: ciImage.extent)
        return image
      }
      .assign(to: &$frame)
  }
}


extension ContentViewModel {
    private func detectFace(in image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                if let results = request.results as? [VNFaceObservation] {
                    if results.count == 0 {
//                        self.clearDrawings()
//                      print("-------------0")
                      self.faces = []
                    }
                    else {
                      print("-------------\(results.count)")
                        self.to_crop = UIImage.getUI(buffer: image)
                        self.handleFaceDetectionResults(results)
                    }
                }
            }
        })
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .up, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
  
  

    
    private func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]) {
        DispatchQueue.global(qos: .userInitiated).sync {
          self.faces = []
            for face in observedFaces {
                          
                // 人脸在原始图片上的位置
              let originRect = CGRect(x: face.boundingBox.origin.x * Config.originPreset.currentPreset().width,
                                      y: (1 - face.boundingBox.origin.y - face.boundingBox.height) * Config.originPreset.currentPreset().height, width: face.boundingBox.width*Config.originPreset.currentPreset().height, height: face.boundingBox.height*Config.originPreset.currentPreset().height)
                

                guard let cropped = self.to_crop!.cropFace((self.to_crop?.cgImage)!, toRect: originRect) else {return}
//
//              self.recognizer.recognize(image: cropped)
              faces?.append(Face(name: "name \(self.recognizer?.name)\n probability \(self.recognizer?.probability.roundTo(places: 2))", rect: originRect))

            }
        }
    }
}



private enum Constant {
  static let alertControllerTitle = "Vision Detectors"
  static let alertControllerMessage = "Select a detector"
  static let cancelActionTitleText = "Cancel"
  static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
  static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
  static let noResultsMessage = "No Results"
  static let localModelFile = (name: "bird", type: "tflite")
  static let labelConfidenceThreshold = 0.75
  static let smallDotRadius: CGFloat = 4.0
  static let lineWidth: CGFloat = 3.0
  static let originalScale: CGFloat = 1.0
  static let padding: CGFloat = 10.0
  static let resultsLabelHeight: CGFloat = 200.0
  static let resultsLabelLines = 5
  static let imageLabelResultFrameX = 0.4
  static let imageLabelResultFrameY = 0.1
  static let imageLabelResultFrameWidth = 0.5
  static let imageLabelResultFrameHeight = 0.8
  static let segmentationMaskAlpha: CGFloat = 0.5
}
