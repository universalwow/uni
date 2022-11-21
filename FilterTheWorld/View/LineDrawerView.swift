

import PerspectiveTransform
import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
//import GPUImage

import Foundation



struct LineDrawerView: View {
    
    @EnvironmentObject var standAndJumper: StandAndJumpSetter
    
    @Binding var leftTop: CGPoint
    @Binding var rightTop: CGPoint
    @Binding var rightBottom: CGPoint
    @Binding var leftBottom: CGPoint
    var image: UIImage
    @State var imageSize: CGSize = CGSize()

    
    @State var points : String = ""
    @State var preProcessImage: UIImage?
    @State var contouredImage: UIImage?
    @State var transformImage:UIImage?
    
    @State var stop = false
    
    
 
    
    @State var lines :[[CGPoint]] = []
    
    @State var outputImageSize = CGRect.init()
    
//    @State var direction:Direction = .LEFT
    
    
    var factor : Double {
        
        if leftTop.x < rightTop.x {
            return 1
        }
        return -1
    }
    
    var body: some View {
        VStack {
            
            Text("Contours: \(self.points)")

            Image(uiImage: image)
            .resizable()
            .scaledToFit()
//            .overlay(
//                GeometryReader{ geometry in
//
//                    LinesView(lines: self.lines, imageSize: imageSize, viewSize: geometry.size).stroke(lineWidth: 2)
//                }
//            )

            if let image = transformImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.6)
            }
            
            if let image = contouredImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }

            if let image = preProcessImage{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                        GeometryReader{ geometry in

                            LinesView(lines: self.lines, imageSize: imageSize, viewSize: geometry.size).stroke(lineWidth: 2).foregroundColor(.green)
                        }
                    )
            }
            
       


   
            
            HStack {
                Button("find contour", action: {
                    self.stop = false
                    
                    DispatchQueue.global(qos: .background).async {
                        var minWidth: Float = 100
                        let sourceImage = image
                        var inputImage = CIImage.init(cgImage: sourceImage.cgImage!, options: [.applyOrientationProperty:true]).oriented(.downMirrored)

                        let contourRequest = VNDetectContoursRequest.init()
                        contourRequest.revision = VNDetectContourRequestRevision1
                        contourRequest.contrastAdjustment = 1.0
                        contourRequest.detectDarkOnLight = true
                        contourRequest.maximumImageDimension = 512
                        
                        for index in 0..<3 {
                            //  找最小值
                            
//                            for
                            for innerIndex in (1..<20) {
                                var width : Float = 10000
//                                if self.lines.count >= 20 {
//                                    let result1 = self.lines[1..<18]
//                                    let result2 = self.lines[3..<20]
//                                    let zipResult = zip(result1, result2).reduce([0.0,0.0]) { result, next in
//
//                                        let firstMinY = next.0[0].y
//                                        let firstMaxY = next.0[1].y
//                                        let secondMinY = next.1[0].y
//                                        let secondMaxY = next.1[1].y
//
//                                        return [firstMinY - secondMinY + result[0], firstMaxY - secondMaxY + result[1]]
//
//                                    }
//
//
//                                    self.rightTop = CGPoint(x: rightTop.x, y: rightTop.y -
//                                                            zipResult[0]/9 )
//                                    self.rightBottom = CGPoint(x: rightBottom.x, y: rightBottom.y - zipResult[1]/9)
//
//                                }
                                
                                var initDirection: Float? 
                                while true && !self.stop {
                                    detectVisionContours(inputImage: inputImage, contourRequest: contourRequest, leftTop: leftTop, rightTop: rightTop, leftBottom: leftBottom, rightBottom: rightBottom)
                                    
                                    if self.lines.count >= 5 {
                                        let result = self.lines[0...self.lines.count/2].reduce([0.0,0.0]) { result, next in
                                            [next[2].x + result[0], next[2].y + result[1]]
                                        }
                                        width = result[0].float/Float(self.lines.count)
                                        minWidth = min(width, minWidth)
                                        
                                        let direction = result[1].float/Float(self.lines.count)
                                        if initDirection == nil {
                                            initDirection = direction
                                        }
                                        
                                        self.points = "count \(self.lines.count) width \(width) direction \(direction)"
                                        
                                        if let _initDirection =  initDirection {
                                            if direction * _initDirection < 0 {
                                                break
                                            }
                                        }
                                        
                                        self.leftTop = CGPoint(x: leftTop.x - CGFloat(log2f(abs(direction)*2+1))*CGFloat(direction/(abs(direction)+1))*factor, y: leftTop.y)
                                    }
                                    
                                    
                                }
                                
                                
                                if index > 0 && width <= minWidth + 2 {
                                    print("return 0 \(index)/\(innerIndex)")
                                    return
                                }
                                
                                initDirection = nil

                                while true && !self.stop {
                                    detectVisionContours(inputImage: inputImage, contourRequest: contourRequest, leftTop: leftTop, rightTop: rightTop, leftBottom: leftBottom, rightBottom: rightBottom)
                                    
                                    if self.lines.count >= 5 {
                

//                                        self.rightTop = CGPoint(x: rightTop.x, y: rightTop.y + firstMinY - secondMinY)
//                                        self.rightBottom = CGPoint(x: rightBottom.x, y: rightBottom.y - (firstMaxY - secondMaxY))
                                        
                                        let result = self.lines[self.lines.count/2...self.lines.count-1].reduce([0.0,0.0]) { result, next in
                                            [next[2].x + result[0], next[2].y + result[1]]
                                        }
                                        width = result[0].float/Float(self.lines.count)
                                        minWidth = min(width, minWidth)
                                        let direction = result[1].float/Float(self.lines.count)
                                        if initDirection == nil {
                                            initDirection = direction
                                        }
                                        
                                        
                                        self.points = "count \(self.lines.count) width \(width) direction \(direction)"
                                        
                                        if let _initDirection =  initDirection {
                                            if direction * _initDirection < 0 {
                                                break
                                            }
                                        }
                                        
                                        self.rightTop = CGPoint(x: rightTop.x - CGFloat(log10(width))*CGFloat(log2f(abs(direction)*2+1))*CGFloat(direction/(abs(direction)+1))*factor, y: rightTop.y)
                                        
                                    }
                                }
                                
                                if index > 0 && width <= minWidth + 2 {
                                    print("return 1 \(index)/\(innerIndex)")
                                    return
                                }
                            }
                            
                        }
                    }
                    
                    
                    
                    
                    
                })
                
                Button(action: {
                    self.stop = true
                    setTransform()
                    
                    
                }, label: {
                    Text("Stop")
                })
                
                Button(action: {
                    let maxWidthLine = self.lines.max(by: { leftLine, rightLine in
                        leftLine[2].x < rightLine[2].x
                    })!
                    
                    let index = self.lines.firstIndex(where: { line in
                        line[0].x == maxWidthLine[0].x
                        
                    })!
                    DispatchQueue.main.async {
                        self.lines.remove(at: index)
                        setTransform()
                    }
                    
                    
                    
                }, label: {
                    Text("清除无效线段")
                })
            }

            
        }.background(Color.clear)
            .padding()
    }
    
    
    func setTransform() {
              let start = Perspective(
                  leftTop,
                  rightTop,
                  rightBottom,
                  leftBottom
              )
              
        print("outputImageSize... \(outputImageSize.width) \(outputImageSize.height)")
              let destination = Perspective(
                  CGPoint(x: 0,y: 0),
                  CGPoint(x: outputImageSize.width,y: 0),
                  CGPoint(x: outputImageSize.width,y: outputImageSize.height),
                  CGPoint(x: 0, y: outputImageSize.height)
              )

            let fullTransform = start.projectiveTransform(destination: destination)
              
                standAndJumper.setTransForm(transform: fullTransform)
                standAndJumper.setLines(lines: self.lines)
    }
    
    func applyperspectiveTransform(ciImage: CIImage, leftTop: CGPoint, rightTop: CGPoint,leftBottom: CGPoint,rightBottom: CGPoint ) -> CIImage
    {
        
        
//        let transform = CATransform3DGetAffineTransform(fullTransform)
//        let inverted =  transform.inverted()
        
//        print("current point \(leftTop) \(leftTop.applying(transform))/\(rightTop.applying( transform))/\(rightBottom.applying( transform))/\(leftBottom.applying(transform))")
        let outCiImage = ciImage.applyingFilter("CIPerspectiveCorrection",
           parameters: [
            "inputTopLeft": CIVector(cgPoint: leftTop),
            "inputTopRight": CIVector(cgPoint: rightTop),
            "inputBottomLeft": CIVector(cgPoint: leftBottom),
            "inputBottomRight": CIVector(cgPoint: rightBottom),
           ])
        
        
        
        print("outCiImage---------------\(ciImage.extent)/\(outCiImage.extent)")
        self.outputImageSize = outCiImage.extent

                      
//              let scaledVector = rows * simd_float3(x: Float(rightBottom.x), y: Float(rightBottom.y), z: 1)
      //        print("fullTransform \(fullTransform)")
              
//              print("current point scaledVector \(scaledVector/scaledVector.z )")


        return outCiImage

//        return outCiImage
    }
    
    func collectChild(contour: VNContour) {
        if contour.childContours.count > 0 {
            contour.childContours.forEach{ childContour in
//                print("Child.................")
//                printContour(contour: contour)

                collectChild(contour: childContour)
            }
        }else{
//            printContour(contour: contour)
            
        }
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
//        renderingContext.setLineWidth(5.0 / CGFloat(size.width))
            renderingContext.setLineWidth(0.005)
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
    
    func detectVisionContours(inputImage: CIImage, contourRequest: VNDetectContoursRequest,leftTop: CGPoint, rightTop: CGPoint, leftBottom: CGPoint, rightBottom: CGPoint){
        var _inputImage = inputImage
        let context = CIContext()
//        if let sourceImage = UIImage.init(named: "IMG_1475")
            
        do {
            
            
            do {
                   
                let transform = applyperspectiveTransform(ciImage: inputImage, leftTop: leftTop, rightTop: rightTop, leftBottom: leftBottom, rightBottom: rightBottom)
                imageSize = transform.extent.size

                DispatchQueue.main.async {
                    if let cgimg = context.createCGImage(transform, from: transform.extent) {
                        self.transformImage  = UIImage(cgImage: cgimg)
                    }
                }
                    
                    
                
                let noiseReductionFilter = CIFilter.gaussianBlur()
                noiseReductionFilter.radius = 0.5
                noiseReductionFilter.inputImage = transform
                let noiseImage = noiseReductionFilter.outputImage!

                let blackAndWhite = BlackWhiteFilter()
                blackAndWhite.inputImage = noiseImage
                let filteredImage = blackAndWhite.outputImage!
                
                let morphologyRectangleMinimumFilter = CIFilter.morphologyRectangleMinimum()
                morphologyRectangleMinimumFilter.inputImage = filteredImage
                morphologyRectangleMinimumFilter.width = 4
                morphologyRectangleMinimumFilter.height = 10
//                return morphologyRectangleMinimumFilter.outputImage
                let morphologyImage = morphologyRectangleMinimumFilter.outputImage!

                _inputImage = morphologyImage
                
//                let morphologyMinimumFilter = CIFilter.morphologyMinimum()
//                morphologyMinimumFilter.inputImage = filteredImage
//                morphologyMinimumFilter.radius = 3
//                let morphologyImage = morphologyMinimumFilter.outputImage!
//
//                _inputImage = morphologyImage


                DispatchQueue.main.async {
                    if let cgimg = context.createCGImage(morphologyImage, from: morphologyImage.extent) {
                        let aaa = UIImage(cgImage: cgimg)
                        self.contouredImage = aaa
                    }
                }
                
            
                DispatchQueue.main.async {
                    if let cgimg = context.createCGImage(filteredImage, from: filteredImage.extent) {
                        let aaa = UIImage(cgImage: cgimg)
                        self.preProcessImage = aaa
                    }
                }
            }

            let requestHandler = VNImageRequestHandler.init(ciImage: _inputImage, options: [:])

            try! requestHandler.perform([contourRequest])
            let contoursObservation = contourRequest.results?.first as! VNContoursObservation
            
//            self.points  = String(contoursObservation.topLevelContourCount)
            let lineList = contoursObservation.topLevelContours.map{ contour -> ([Double], [Double]) in
//                print("contour******************")
                if contour.normalizedPoints.count > 10 {
//                    print(" child count \(contour.childContours.count)")
                    if (contour.childContours.count > 0) {
                        collectChild(contour: contour)
                    }
                    var list = contour.normalizedPoints.map{ point -> (Double, Double) in
                        let x = Double(SIMD2<Float>(point).x*Float(transformImage!.size.width))
                        let y = Double((1 - SIMD2<Float>(point).y)*Float(transformImage!.size.height))
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
            
            }.filter{ele in
                ele.0.count != 0
            }
            
            self.lines = lineList.filter{ele in
                return (ele.1.max()! - ele.1.min()!) > 80
                && (ele.1.max()! - ele.1.min()!) < 1000
            }.map{ele in
                
                let minX = ele.0.min()!
                let maxX = ele.0.max()!
                let meanX = ele.0.reduce(0.0, +)/Double(ele.0.count)
                let minY = ele.1.min()!
                let maxY = ele.1.max()!
                
                let minXY = ele.1[ele.0.firstIndex(of: minX)!]
                let maxXY = ele.1[ele.0.firstIndex(of: maxX)!]
//                print("-----------\(maxX - minX)/\(maxXY - minXY)")
                
                
//                var lineFunc = linearRegression(ele.0, ele.1)
                return [CGPoint(x: meanX, y: minY),
                        CGPoint(x: meanX, y: maxY),
//                        x反应质量好坏 y反应倾斜方向 正值上部左倾
                        CGPoint(x: maxX - minX, y: maxXY - minXY)]
            }.sorted{ _left, _right in
                _left[0].x < _right[0].x
            }
            

            
//            let ciContext = CIContext.init()
            
//            self.contouredImage = drawContours(contoursObservation: contoursObservation, sourceImage: ciContext.createCGImage(inputImage, from: inputImage.extent)!)

        }
    }
}

