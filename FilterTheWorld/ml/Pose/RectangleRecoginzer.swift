

import Foundation
import Vision
import CoreImage

class RectangleRecoginzer: ObservableObject {
  
  
  @Published var rectangles: [VNRectangleObservation] = []

  //Mark: - Rectangle detection
  func createVisionRequest(data:Data, maximumObservations:Int,
                           minimumAspectRatio:Float,
                           maximumAspectRatio:Float,
                           minimumSize:Float,
                           quadratureTolerance:Float, //仰角
                           minimumConfidence:Float
                          ) {
    
    let requestHandler = VNImageRequestHandler(data: data, options: [:])
    
          let request = VNDetectRectanglesRequest { request, error in
              self.completedVisionRequest(request, error: error)
          }
          request.maximumObservations = maximumObservations
          request.minimumAspectRatio = minimumAspectRatio
          request.maximumAspectRatio = maximumAspectRatio
          request.minimumSize = minimumSize
          request.quadratureTolerance = quadratureTolerance
          request.minimumConfidence = minimumConfidence
          request.shouldGroupAccessibilityChildren = false
          request.usesCPUOnly = false
          
          DispatchQueue.global().async {
              do {
                  try requestHandler.perform([request])
              } catch {
                  print("Error: Rectangle detection failed - vision request failed.")
              }
          }
      }
      
      func completedVisionRequest(_ request: VNRequest?, error: Error?) {
          guard let rectangles = request?.results as? [VNRectangleObservation] else {
              guard let error = error else { return }
              print("Error: Rectangle detection failed with error: \(error.localizedDescription)")
              return
          }
        DispatchQueue.main.async {
          self.rectangles = rectangles
          print("rects count \(self.rectangles.count)")

        }
      }
  
}

