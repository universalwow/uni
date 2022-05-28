

import Foundation
import SwiftUI

extension LandmarkInArea {
    func path(frameSize: Point2D) -> Path {
    var path = Path()
    var area : [Point2D] = []
    if imageSize.x == frameSize.x && imageSize.y == frameSize.y {
        area = self.area
    } else {
        area = self.area.map { point in
            Point2D(x: point.x/imageSize.x * frameSize.x,
                    y: point.y/imageSize.y * frameSize.y)
        }
    }
    let areaIndics = area.indices
    area.indices.forEach{ index in
      if index == areaIndics.lowerBound {
        path.move(to: area[index].cgPoint)
      }else if index == areaIndics.upperBound - 1 {
        path.addLine(to: area[areaIndics.lowerBound].cgPoint)
      }else {
        path.addLine(to: area[index].cgPoint)
      }
    }
    
    return path
  }
  
}
