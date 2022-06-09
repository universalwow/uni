

import Foundation
import SwiftUI

struct Point3D: Equatable, Hashable, Codable {
  var x = 0.0
  var y = 0.0
  var z = 0.0
  static let zero = Point3D()
}

struct Point2D: Equatable, Hashable, Codable {
  var x = 0.0
  var y = 0.0
  static let zero = Point2D()
}


extension Point3D {
  var vector2d: Vector2D {
    Vector2D(x: x, y: y)
  }
  
  var point2D: Point2D {
    Point2D(x: x, y: y)
  }
}

extension Double {
    var decimel: Decimal {
        Decimal(self)
    }
}


extension Point2D {
  var cgPoint: CGPoint {
    CGPoint(x: self.x, y: self.y)
  }
  
  var vector2d: Vector2D {
    Vector2D(x: x, y: y)
  }
  
  var point3D: Point3D {
    Point3D(x: x, y: y, z: 0)
  }

    var width: Double {
        self.x
    }
    
    var height: Double {
        self.y
    }
//    对角线
    var diag:Double {
        sqrt(self.x * self.x + self.y * self.y)
    }
  
  var roundedString: String {
    "\(self.x.roundedString)/\(self.y.roundedString)"
  }
}




