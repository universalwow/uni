

import Foundation
import CoreImage
import PerspectiveTransform
import simd
import CoreGraphics


extension CIImage {
  
  func applyperspectiveTransform(topLeft:CGPoint, topRight:CGPoint, bottomLeft:CGPoint, bottomRight:CGPoint) -> CIImage
  {
//    [topLeft, topRight, bottomLeft, bottomRight]
      let outCiImage = self.applyingFilter("CIPerspectiveCorrection",
         parameters: [
          "inputTopLeft": CIVector(cgPoint: topLeft),
          "inputTopRight": CIVector(cgPoint: topRight),
          "inputBottomLeft": CIVector(cgPoint: bottomLeft),
          "inputBottomRight": CIVector(cgPoint: bottomRight),
         ])
      
      print("outCiImage---------------\(self.extent)/\(outCiImage.extent)")
      return outCiImage
  }
  
}
