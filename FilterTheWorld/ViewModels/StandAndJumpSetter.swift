

import SwiftUI
import Foundation
import PerspectiveTransform
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins


class StandAndJumpSetter: ObservableObject {
    
    var lines :[[CGPoint]] = []
    var outputImageSize: CGRect = CGRect.init()
    var transform : CATransform3D = .init()
    @Published var leftDownPoint = Point2D.zero
    @Published var rightDownPoint = Point2D.zero
    
    @Published var leftDownPosition = 0.0
    @Published var rightDownPosition = 0.0
    
    @Published var sport: StandAndJump?
    
    
    
    func setSport(jumpArea: [Point2D]) {
        self.leftDownPoint = .zero
        self.rightDownPoint = .zero
        self.leftDownPosition = .zero
        self.rightDownPosition = .zero
        sport = StandAndJump(jumpArea: jumpArea)
    }
    
    func setTransForm(transform: CATransform3D) {
        self.transform = transform
    }
    
    func setLines(lines: [[CGPoint]]) {
        self.lines = lines
    }
    
    func transFormFrom(point: Point2D) -> Point2D {
        let rows =
        float3x3(rows: [
            simd_float3(transform.m11.float, transform.m21.float, transform.m41.float),
            simd_float3(     transform.m12.float, transform.m22.float, transform.m42.float),
            simd_float3(     transform.m14.float,      transform.m24.float, transform.m44.float)
            ])
        var scaledVector = rows * simd_float3(x: Float(point.x), y: Float(point.y), z: 1)
        scaledVector = scaledVector/scaledVector.z
        return Point2D(x: Double(scaledVector.x), y: Double(scaledVector.y))
        
    }
    
    func indexToPosition(index: Int) -> Double {
        if index > 0 {
            return Double(100 + (index - 1) * 5)
        } else if index == -1 {
            return -1
        }
        return 0
    }
    
    func addedPosition(point: Point2D, index: Int) -> Double {
        if index > -1 && index < self.lines.count - 1 {
            let minX = self.lines[index][0].x
            let maxX = self.lines[index+1][0].x
            return (point.x - minX)/(maxX - minX) * 5
            
            
        }else if index == -1 {
            return -1
        } else {
            let maxX = self.lines[index][0].x
            let minX = self.lines[index-1][0].x
            return (point.x - maxX)/(maxX - minX) * 5
        }
        
    }
    
    func findDownPosition(point: Point2D) -> Double {
        var index = self.lines.indices[0..<self.lines.count-1].first(where: { index in
            point.x >= self.lines[index][0].x &&
            point.x < self.lines[index+1][0].x
        }) ?? -1
        
        if self.lines.last![0].x <= point.x {
            index = self.lines.count - 1
        }
        
        let initPosition = indexToPosition(index: index)
        let addedLength = addedPosition(point: point, index: index)
        
        return initPosition + addedLength
    }
    
    func play(humanPoses: [HumanPose]) {
        self.sport?.play(humanPoses: humanPoses)
        if let state = self.sport?.state {
            if state == .DOWN {
                self.leftDownPoint = transFormFrom(point:self.sport!.leftDownPoint.point2D)
                self.rightDownPoint = transFormFrom(point:self.sport!.rightDownPoint.point2D)
                self.leftDownPosition = findDownPosition(point: self.leftDownPoint)
                self.rightDownPosition = findDownPosition(point: self.rightDownPoint)

            }
        }
    }
    
}
