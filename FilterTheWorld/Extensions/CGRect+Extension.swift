

import Foundation
import UIKit

extension CGRect {
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
    
    func rectToFit(imageSize: CGSize, viewSize: CGSize) -> CGRect {
        let leftTop = CGPoint(x: self.minX, y: self.minY).pointToFit(imageSize: imageSize, viewSize: viewSize)
        let rightBottom = CGPoint(x: self.maxX, y: self.maxY).pointToFit(imageSize: imageSize, viewSize: viewSize)
        
        return CGRect(origin: leftTop, size:
                        CGSize(width: rightBottom.x - leftTop.x,
                               height: rightBottom.y - leftTop.y)
        )
        
        
    }
    
    
}
