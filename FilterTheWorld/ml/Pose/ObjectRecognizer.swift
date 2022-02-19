

import Foundation

import MLKit

class ObjectRecognizer: ObservableObject {
  
  private var objectDetector: ObjectDetector?

  @Published var detectedObjects: [CGRect]?
  
  init(){
    let options = ObjectDetectorOptions()
    options.detectorMode = .singleImage
    options.shouldEnableMultipleObjects = true
    options.shouldEnableClassification = true
    objectDetector = ObjectDetector.objectDetector(options: options)
  }
  
  func detectObject(image: VisionImage){
    self.detectedObjects = []
      
      guard let objectDetector = self.objectDetector else {
            return
        }

      objectDetector.process(image) { detectedObjects, error in
          guard error == nil else {
              return
          }

          guard let detectedObjects = detectedObjects,
                !detectedObjects.isEmpty else {
              return
          }
          for i in 0..<detectedObjects.count {
            self.detectedObjects?.append(detectedObjects[i].frame)
          }
    }
    
  
  }
  
  
}
