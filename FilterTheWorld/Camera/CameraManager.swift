

import AVFoundation
import Vision
import SwiftUI



struct Config {
  static let originPreset = AVCaptureSession.Preset.vga640x480
}


extension CGSize {
  func ratio() -> Double {
    self.width/self.height
  }
}


extension View {
  
  // 图片裁剪后坐标变换  geometry.size
  func clipedPoint(originImageFrame: CGSize,
                   currentViewFrame: CGSize,
                   originPosition: CGPoint) -> CGPoint {
    
    let originRatio = originImageFrame.ratio()
    let currentViewRatio = currentViewFrame.ratio()
    // 裁剪x轴
    
    let newOriginFrameWidth = currentViewRatio * originImageFrame.height
    let newOriginFrameHeight = originImageFrame.width/currentViewRatio
    return originRatio >= currentViewRatio ? CGPoint(
      x:
       (originPosition.x - (originImageFrame.width - newOriginFrameWidth)/2)/newOriginFrameWidth*currentViewFrame.width,
      y: originPosition.y/originImageFrame.height * currentViewFrame.height
    ) : CGPoint(
      x:
        originPosition.x/originImageFrame.width * currentViewFrame.width
        ,
      y: (originPosition.y - (originImageFrame.height - newOriginFrameHeight)/2)/newOriginFrameHeight*currentViewFrame.height
     )

  }
  
  
  func pointTransform(originImageFrame: CGSize,
                   currentViewFrame: CGSize,
                   originPosition: CGPoint) -> CGPoint {
    
    let originRatio = 1.0/originImageFrame.ratio()
    let currentViewRatio = 1.0/currentViewFrame.ratio()
    return originRatio >= currentViewRatio ? CGPoint(
      x:
        currentViewFrame.width/2 + (originPosition.x - originImageFrame.width/2)/originImageFrame.height * currentViewFrame.height,
      y: originPosition.y/originImageFrame.height * currentViewFrame.height
    ) : CGPoint(
      x:
        originPosition.x/originImageFrame.width * currentViewFrame.width
        ,
    y: currentViewFrame.height/2 + (originPosition.y - originImageFrame.height/2)/originImageFrame.width * currentViewFrame.width

     )

  }
  
  
  
  
  
}

extension AVCaptureSession.Preset {
  func currentPreset() -> CGSize {
    switch self {
      case .hd1280x720:
        return CGSize(width: 720.0, height: 1280.0)
      case .hd1920x1080:
        return CGSize(width: 1080.0,height: 1920.0)
      case .vga640x480:
        return CGSize(width: 480.0,height: 640.0)
      default:
        return CGSize(width: 720.0, height: 1280.0)
    }
  
  }
}




class CameraManager: NSObject, ObservableObject {
  enum Status {
    case unconfigured
    case configured
    case unauthorized
    case failed
  }

  static let shared = CameraManager()

  @Published var error: CameraError?

    lazy var session: AVCaptureSession = {
        
        let avSession = AVCaptureSession()
      avSession.sessionPreset = Config.originPreset
      return avSession
    }()

  private let sessionQueue = DispatchQueue(label: "com.raywenderlich.SessionQ")
  private let videoOutput = AVCaptureVideoDataOutput()
  private let videoFileOutput = AVCaptureMovieFileOutput()

  
  private var status = Status.unconfigured

  private override init() {
    super.init()
    configure()
  }

  private func set(error: CameraError?) {
    DispatchQueue.main.async {
      self.error = error
    }
  }

  private func checkPermissions() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .notDetermined:
      sessionQueue.suspend()
      AVCaptureDevice.requestAccess(for: .video) { authorized in
        if !authorized {
          self.status = .unauthorized
          self.set(error: .deniedAuthorization)
        }
        self.sessionQueue.resume()
      }
    case .restricted:
      status = .unauthorized
      set(error: .restrictedAuthorization)
    case .denied:
      status = .unauthorized
      set(error: .deniedAuthorization)
    case .authorized:
      break
    @unknown default:
      status = .unauthorized
      set(error: .unknownAuthorization)
    }
  }

  private func configureCaptureSession() {
    guard status == .unconfigured else {
      return
    }

    session.beginConfiguration()

    defer {
      session.commitConfiguration()
    }
      
    let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
//    AVCaptureDevice.default(
//      .builtInWideAngleCamera,
//      for: .video,
//      position: .back)
    guard let camera = device else {
      set(error: .cameraUnavailable)
      status = .failed
      return
    }

    do {
        
      let cameraInput = try AVCaptureDeviceInput(device: camera)
      if session.canAddInput(cameraInput) {
        session.addInput(cameraInput)
      } else {
        set(error: .cannotAddInput)
        status = .failed
        return
      }
    } catch {
      set(error: .createCaptureInput(error))
      status = .failed
      return
    }

    if session.canAddOutput(videoOutput) {
      session.addOutput(videoOutput)

//      videoOutput.videoSettings =
//        [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
      // Add a video data output
      videoOutput.alwaysDiscardsLateVideoFrames = true
      videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
      
      let videoConnection = videoOutput.connection(with: .video)
      // Always process the frames
      videoConnection?.isEnabled = true
      videoConnection?.videoOrientation = .portrait
    } else {
      set(error: .cannotAddOutput)
      status = .failed
      return
    }

    status = .configured
  }

  private func configure() {
    checkPermissions()

    sessionQueue.async {
      self.configureCaptureSession()
//      self.session.startRunning()
    }
  }
  
  func start() {
    sessionQueue.async {
      if (!self.session.isRunning) {
        self.session.startRunning()
      }
      
    }
  }
  
  func stop() {
    sessionQueue.async {
      if (self.session.isRunning) {
        self.session.stopRunning()
      }
      
    }
  }
  

  func set(
    _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
    queue: DispatchQueue
  ) {
    sessionQueue.async {
      self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
    }
  }
}


extension CameraManager: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    print(outputFileURL.absoluteString)
  }
  
  
  func startRecording(){
    print("can add output \(session.canAddOutput(videoFileOutput))")
          session.addOutput(videoFileOutput)
          
          let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
          let filePath = documentsURL.appendingPathComponent("tempPZDC")

          videoFileOutput.startRecording(to: filePath, recordingDelegate: self)
      }

      func stopRecording(){
          videoFileOutput.stopRecording()
          session.removeOutput(videoFileOutput)
          print("🔴 RECORDING \(videoFileOutput.isRecording)")
      }
  
}



