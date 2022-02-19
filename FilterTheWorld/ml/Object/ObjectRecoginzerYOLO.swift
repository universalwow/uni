

import Foundation

import Vision
import UIKit


class ObjectRecoginzerYOLO: ObservableObject {
  
  // Vision parts
  private var lastTime = Date().timeIntervalSince1970

  private var detectionOverlay: CALayer! = nil
  var bufferSize = CGSize.zero
  var rootLayer: CALayer! = nil
  var imageSize: CGSize = CGSize.zero

  private var requests = [VNRequest]()
  @Published var results: [Observation] = []
  
  init() {
    let _ = setupVision()
    
  }
  
  func setupVision() -> NSError? {
      // Setup Vision parts
      let error: NSError! = nil
      
      guard let modelURL = Bundle.main.url(forResource: "YOLOv3FP16", withExtension: "mlmodelc") else {
          return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
      }
      do {
          let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
          let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
            DispatchQueue.main.async(execute: { [self] in
              
                  // perform all the UI updates on the main queue
                let currentTime = Date().timeIntervalSince1970
                  if let results = request.results {


                    var observations: [Observation] = []

                    for observation in results where observation is VNRecognizedObjectObservation {
                        guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                            continue
                        }
                        // Select only the label with the highest confidence.
                        let topLabelObservation = objectObservation.labels[0]
                      let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(self.imageSize.width), Int(self.imageSize.height))
                      
                      let newBound = CGRect(origin: CGPoint(x: objectBounds.minX, y: self.imageSize.height - objectBounds.minY - objectBounds.height), size: objectBounds.size)
                      print("object position \(newBound)")

                      observations.append(Observation(label: "\(topLabelObservation.identifier)/\(topLabelObservation.confidence.roundedString(number: 2))", rect:
                                                        newBound))
//                      self.drawVisionRequestResults(results)
                    }

                    self.results = observations

                  }
              
              print("current time \(Float(currentTime -  self.lastTime).roundedString(number: 5))/\(self.results.count)/\(self.imageSize)")
              self.lastTime = currentTime
  
              })
          })
          self.requests = [objectRecognition]
      } catch let error as NSError {
          print("Model loading went wrong: \(error)")
      }
      
      return error
  }
  
  func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
      let textLayer = CATextLayer()
      textLayer.name = "Object Label"
      let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
      let largeFont = UIFont(name: "Helvetica", size: 24.0)!
      formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
      textLayer.string = formattedString
      textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
      textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
      textLayer.shadowOpacity = 0.7
      textLayer.shadowOffset = CGSize(width: 2, height: 2)
      textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
      textLayer.contentsScale = 2.0 // retina rendering
      // rotate the layer into screen orientation and scale and mirror
      textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
      return textLayer
  }
  
  func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
      let shapeLayer = CALayer()
      shapeLayer.bounds = bounds
      shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
      shapeLayer.name = "Found Object"
      shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
      shapeLayer.cornerRadius = 7
      return shapeLayer
  }
  
  func updateLayerGeometry() {
      let bounds = rootLayer.bounds
      var scale: CGFloat
      
      let xScale: CGFloat = bounds.size.width / bufferSize.height
      let yScale: CGFloat = bounds.size.height / bufferSize.width
      
      scale = fmax(xScale, yScale)
      if scale.isInfinite {
          scale = 1.0
      }
      CATransaction.begin()
      CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
      
      // rotate the layer into screen orientation and scale and mirror
      detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
      // center the layer
      detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
      
      CATransaction.commit()
      
  }

  
  func drawVisionRequestResults(_ results: [Any]) {
      CATransaction.begin()
      CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
      detectionOverlay.sublayers = nil // remove all the old recognized objects
      for observation in results where observation is VNRecognizedObjectObservation {
          guard let objectObservation = observation as? VNRecognizedObjectObservation else {
              continue
          }
          // Select only the label with the highest confidence.
          let topLabelObservation = objectObservation.labels[0]
          let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
          
          let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
          
          let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                          identifier: topLabelObservation.identifier,
                                                          confidence: topLabelObservation.confidence)
          shapeLayer.addSublayer(textLayer)
          detectionOverlay.addSublayer(shapeLayer)
      }
      self.updateLayerGeometry()
      CATransaction.commit()
  }
  
  
  func detectObject(in image: CVPixelBuffer, imageSize: CGSize) {
    self.imageSize = imageSize
    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .up, options: [:])
    do {
        try imageRequestHandler.perform(self.requests)
    } catch {
        print("error ",error)
    }
    
  }
}
