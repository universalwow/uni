

import Foundation
import SwiftUI

extension LandmarkInArea {
  var path: Path {
    var path = Path()
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
