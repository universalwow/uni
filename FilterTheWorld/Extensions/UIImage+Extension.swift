//
//  ImageUtils.swift
//  faceID
//
//  Created by Davide on 20/05/2020.
//  Copyright © 2020 Davide. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import VideoToolbox
import Vision
import PerspectiveTransform


extension UIImage {
  
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
  
  
  func detectVisionContours(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
      
    let context = CIContext()
    print("rotate... \(self.imageOrientation.rawValue)")
    var inputImage = CIImage.init(cgImage: self.cgImage!, options: [.applyOrientationProperty:true]).oriented(.downMirrored)

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
              let transformImage  = UIImage(cgImage: cgimg)
          }
          
          let noiseReductionFilter = CIFilter.gaussianBlur()
          noiseReductionFilter.radius = 0.5
          noiseReductionFilter.inputImage = transform

          let blackAndWhite = BlackWhiteFilter()
          blackAndWhite.inputImage = noiseReductionFilter.outputImage!
          let filteredImage = blackAndWhite.outputImage!
      
          inputImage = filteredImage

          if let cgimg = context.createCGImage(filteredImage, from: filteredImage.extent) {
              let preProcessImage = UIImage(cgImage: cgimg)
          }
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
    
    let lines = lineList.filter{ele in
        return ele.0.count > 40 && (ele.0.max()! - ele.0.min()!) < 100
        
    }.map{ele -> [CGPoint] in
        

        let meanX = ele.0.reduce(0.0, +)/Double(ele.0.count)
        let minY = ele.1.min()!
        let maxY = ele.1.max()!
//                var lineFunc = linearRegression(ele.0, ele.1)
        return [CGPoint(x: meanX, y: minY), CGPoint(x: meanX, y: maxY)]
    }
    
    let ciContext = CIContext.init()
    
  let contouredImage = drawContours(contoursObservation: contoursObservation, sourceImage: ciContext.createCGImage(inputImage, from: inputImage.extent)!)
  
  }
  
    
   
    static func getUI(buffer: CVPixelBuffer) -> UIImage?{
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let temporaryContext = CIContext(options: nil)
        if let temporaryImage = temporaryContext.createCGImage(ciImage,from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer)))
        {
            return UIImage(cgImage: temporaryImage)
        }
        return nil
    }
    
    func cropFace(_ inputCGImage: CGImage, toRect cropRect: CGRect) -> UIImage?
    {
//        let imageViewScale = max(self.size.width / viewWidth,
//                                 self.size.height / viewHeight)
//        // Scale cropRect to handle images larger than shown-on-screen size
//        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
//                              y:cropRect.origin.y * imageViewScale,
//                              width:cropRect.size.width * imageViewScale,
//                              height:cropRect.size.height * imageViewScale)
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputCGImage.cropping(to:cropRect) else {return nil}
        return resize(croppedimage: UIImage(cgImage: cutImageRef))
    }

      func resize(croppedimage: UIImage) -> UIImage{
        //resize to 160x160 square
        let newWidth:CGFloat = 160
        let newHeight:CGFloat = 160
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), true, 3.0)
        croppedimage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    //RGBA => 32bit => 4x8
    func getPixelData(buffer :inout [Double]){
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        //removes the alpha channel
        let n = 4
        let newCount = pixelData.count - pixelData.count/4
        buffer = (0..<newCount).map { Double(pixelData[$0 + $0/(n - 1)])}
    }
    

    func prewhiten(input :inout [Double], output :inout MLMultiArray){
        var sum :Double = Double(input.reduce(0, +))
        let mean :Double = sum / Double(input.count)
        
        sum = 0xF
        for i in 0..<input.count {
            input[i] = input[i] - mean
            sum += pow(input[i],2)
        }
        
        let std :Double = sqrt(sum/Double(input.count))
        let std_adj :Double = max(std, 1.0/sqrt(Double(input.count)))

        var  i = 0
        for value in input{
            output[i] = NSNumber(value: Float32(value/std_adj))
            i += 1
        }
    }

    

    //**************************** DEBUG ****************************
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        if let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

            context?.translateBy(x: 0, y: self.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)

            UIGraphicsPushContext(context!)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

            return pixelBuffer
        }
        return nil
    }
    //***************************************************************


}


extension UIImage {
    /// Fix image orientaton to protrait up
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }

        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }

        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }

        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}


extension CIImage {
  func convertCIImageToCGImage() -> CGImage? {
      let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(self, from: self.extent) {
          return cgImage
      }
      return nil
  }
}


public struct PngImage: Equatable, Codable {

    public let photo: Data
    public let imageSize: CGSize
    
    public init(photo: UIImage) {
        self.photo = photo.pngData()!
        self.imageSize = photo.size
    }
}
