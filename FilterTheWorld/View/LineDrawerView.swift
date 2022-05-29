

import PerspectiveTransform
import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import PerspectiveTransform
//import GPUImage

import Foundation


struct LineDrawerView: View {
    @State var points : String = ""
    @State var preProcessImage: UIImage?
    @State var contouredImage: UIImage?
    @State var transformImage:UIImage?
    @State var imageSize: CGSize = CGSize()
    
    @State var leftTop   = CGPoint(x: 900, y:  2449)
    @State   var rightTop    = CGPoint(x: 2060, y:  2462)
    @State var leftBottom  = CGPoint(x: 200, y:  2932)
        let rightBottom = CGPoint(x: 3935, y:  2949)
    
    @State var lines :[[CGPoint]] = []
    
    var body: some View {
        VStack {
            
            Text("Contours: \(self.points)")

            Image("IMG_1475")
            .resizable()
            .scaledToFit()
//            .overlay(
//                GeometryReader{ geometry in
//
//                    LinesView(lines: self.lines, imageSize: imageSize, viewSize: geometry.size).stroke(lineWidth: 2)
//                }
//            )


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
            
            if let image = transformImage{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.6)
            }

//
//            if let image = contouredImage{
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//            }
            
            HStack {
                Button("find contour", action: {
                    
                    DispatchQueue.global(qos: .background).async {
                        var minWidth: Float = 100
                        let sourceImage = UIImage.init(named: "IMG_1475")!
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
                                
                                
                                
                                var initDirection: Float?
                                while true {
                                    detectVisionContours(inputImage: inputImage, contourRequest: contourRequest, leftTop: leftTop, rightTop: rightTop, leftBottom: leftBottom, rightBottom: rightBottom)
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
                    //                    左倾 x 减小
                                    
                                    
                                    self.leftTop = CGPoint(x: leftTop.x - CGFloat(log2f(abs(direction)*2+1))*CGFloat(direction/(abs(direction)+1)), y: leftTop.y)
                                }
                                
                                if index > 0 && width <= minWidth + 1 {
                                    print("return 0 \(index)/\(innerIndex)")
                                    return
                                }
                                
                                initDirection = nil

                                while true {
                                    detectVisionContours(inputImage: inputImage, contourRequest: contourRequest, leftTop: leftTop, rightTop: rightTop, leftBottom: leftBottom, rightBottom: rightBottom)
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
                    //                    左倾 x 减小
                                    
                                    self.rightTop = CGPoint(x: rightTop.x - CGFloat(log2f(abs(direction)*2+1))*CGFloat(direction/(abs(direction)+1)), y: rightTop.y)
                                    direction
                                    
                                }
                                
                                if index > 0 && width <= minWidth + 1 {
                                    print("return 1 \(index)/\(innerIndex)")
                                    return
                                }
                            }
                            
                        }
                    }
                    
                    
                    
                    
                    
                })
            }

            
        }.background(Color.clear)
            .padding()
    }
    
    func applyperspectiveTransform(ciImage: CIImage, leftTop: CGPoint, rightTop: CGPoint,leftBottom: CGPoint,rightBottom: CGPoint ) -> CIImage
    {
        
        let start = Perspective(
            leftTop,
            rightTop,
            rightBottom,
            leftBottom
        )
        
        let destination = Perspective(
            CGPoint(x: 100,y: 50),
            CGPoint(x: 150,y: 50),
            CGPoint(x: 150,y: 150),
            CGPoint(x: 100, y: 150)
        )
        
//
//
//
        let fullTransform = start.projectiveTransform(destination: destination)
        
        
        let rows =
        float3x3(rows: [
            simd_float3(fullTransform.m11.float,      fullTransform.m21.float, fullTransform.m41.float),
            simd_float3(     fullTransform.m12.float, fullTransform.m22.float, fullTransform.m42.float),
            simd_float3(     fullTransform.m14.float,      fullTransform.m24.float, fullTransform.m44.float)
            ])
                
        let scaledVector = rows * simd_float3(x: 1444, y: 91, z: 1)
//        print("fullTransform \(fullTransform)")
        
//        print("scaledVector \(scaledVector/scaledVector.z )")
        let transform = CATransform3DGetAffineTransform(fullTransform)
        
//        print("current point \(leftTop.applying(transform))/\(rightTop.applying( transform))/\(rightBottom.applying( transform))/\(leftBottom.applying(transform))")
        let outCiImage = ciImage.applyingFilter("CIPerspectiveCorrection",
           parameters: [
            "inputTopLeft": CIVector(cgPoint: leftTop),
            "inputTopRight": CIVector(cgPoint: rightTop),
            "inputBottomLeft": CIVector(cgPoint: leftBottom),
            "inputBottomRight": CIVector(cgPoint: rightBottom),
           ])
        
        
        
//        print("outCiImage---------------\(ciImage.extent)/\(outCiImage.extent)")
        
        


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
                

                let blackAndWhite = BlackWhiteFilter()
                blackAndWhite.inputImage = noiseReductionFilter.outputImage!
                let filteredImage = blackAndWhite.outputImage!
            
                _inputImage = filteredImage
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
                
                return (ele.1.max()! - ele.1.min()!) > 100
                && (ele.0.max()! - ele.0.min()!) < 1000
                
                
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
            
            let ciContext = CIContext.init()
            
//            self.contouredImage = drawContours(contoursObservation: contoursObservation, sourceImage: ciContext.createCGImage(inputImage, from: inputImage.extent)!)

        }
    }
}

