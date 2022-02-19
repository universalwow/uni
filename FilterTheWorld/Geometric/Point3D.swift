

import Foundation


struct Point3D: Equatable, Hashable, Codable {
  var x = 0.0
  var y = 0.0
  var z = 0.0
  static let zero = Point3D()
}


extension Point3D {
  var vector2d: Vector2D {
    Vector2D(x: x, y: y)
  }
}




