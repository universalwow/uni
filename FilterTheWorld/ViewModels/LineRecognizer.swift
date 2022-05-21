

import Foundation
import SwiftUI
import Vision
import PerspectiveTransform

class LineRecognizer:ObservableObject {
  
  @Published var transformedImage:UIImage?
  @Published var blackAndWhiteImage:UIImage?
  @Published var contouredImage:UIImage?
  @Published var lines:[[CGPoint]] = []
  
  func detectVisionContours(uiImage: UIImage,topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
      
    let context = CIContext()
    print("rotate... \(uiImage.imageOrientation.rawValue)")
    var inputImage = CIImage.init(cgImage: uiImage.cgImage!, options: [.applyOrientationProperty:true]).oriented(.downMirrored)

    let contourRequest = VNDetectContoursRequest.init()
    contourRequest.revision = VNDetectContourRequestRevision1
    contourRequest.contrastAdjustment = 1.0
    contourRequest.detectDarkOnLight = true
    
    contourRequest.maximumImageDimension = 512
    
    do {
            
//                    let monochromeFilter = CIFilter.colorControls()
//                    monochromeFilter.inputImage = noiseReductionFilter.outputImage!
//                    monochromeFilter.contrast = 20.0
//                    monochromeFilter.brightness = 4
//                    monochromeFilter.saturation = 50
//                    let filteredImage = monochromeFilter.outputImage!

          
          
          let transform = inputImage.applyperspectiveTransform(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
          if let cgimg = context.createCGImage(transform, from: transform.extent) {
            self.transformedImage = UIImage(cgImage: cgimg)
          }
          
//          let noiseReductionFilter = CIFilter.gaussianBlur()
//          noiseReductionFilter.radius = 0.5
//          noiseReductionFilter.inputImage = transform
//
//          let blackAndWhite = BlackWhiteFilter()
//          blackAndWhite.inputImage = noiseReductionFilter.outputImage!
//          let filteredImage = blackAndWhite.outputImage!
//      
//          inputImage = filteredImage
//
//          if let cgimg = context.createCGImage(filteredImage, from: filteredImage.extent) {
//              blackAndWhiteImage = UIImage(cgImage: cgimg)
//          }
      }

    let requestHandler = VNImageRequestHandler.init(ciImage: inputImage, options: [:])

    try! requestHandler.perform([contourRequest])
    let contoursObservation = contourRequest.results?.first as! VNContoursObservation
    
    let lineList:[([Double], [Double])] = contoursObservation.topLevelContours.map{ contour -> ([Double], [Double]) in
//                print("contour******************")
        if contour.normalizedPoints.count > 20 {
            var list = contour.normalizedPoints.map{ point -> (Double, Double) in
              let x = Double(SIMD2<Float>(point).x*Float(inputImage.extent.size.width))
              let y = Double((1 - SIMD2<Float>(point).y)*Float(inputImage.extent.size.height))
                return (x,y)
            }
            return (list.map{ ele in
                ele.0
            }, list.map{ ele in
                ele.1
            })
       
        }else {
            return ([Double](), [Double]())
        }
    
    }
    
    lines = lineList.filter{ele in
        return ele.0.count > 40 && (ele.0.max()! - ele.0.min()!) < 100
        
    }.map{ele -> [CGPoint] in
        

        let meanX = ele.0.reduce(0.0, +)/Double(ele.0.count)
        let minY = ele.1.min()!
        let maxY = ele.1.max()!
//                var lineFunc = linearRegression(ele.0, ele.1)
        return [CGPoint(x: meanX, y: minY), CGPoint(x: meanX, y: maxY)]
    }
    
    let ciContext = CIContext.init()
    
    contouredImage = drawContours(contoursObservation: contoursObservation, sourceImage: ciContext.createCGImage(inputImage, from: inputImage.extent)!)
  }
  
  
  public func drawContours(contoursObservation: VNContoursObservation, sourceImage: CGImage) -> UIImage {
      let size = CGSize(width: sourceImage.width, height: sourceImage.height)
      let renderer = UIGraphicsImageRenderer(size: size)
      
      let renderedImage = renderer.image { (context) in
      let renderingContext = context.cgContext

      let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
      renderingContext.concatenate(flipVertical)
          
      renderingContext.draw(sourceImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      
      renderingContext.scaleBy(x: size.width, y: size.height)
      renderingContext.setLineWidth(5.0 / CGFloat(size.width))
      let redUIColor = UIColor.red
      renderingContext.setStrokeColor(redUIColor.cgColor)
//            self.lines.forEach{ line in
//                renderingContext.addLines(between: line)
//            }
          
      renderingContext.addPath(contoursObservation.normalizedPath)
          
      renderingContext.strokePath()
      }
      
      return renderedImage
  }
  
  
  
}
