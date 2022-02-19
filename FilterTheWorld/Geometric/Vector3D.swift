import Foundation

struct Vector3D {
  var x = 0.0
  var y = 0.0
  var z = 0.0
    
  static let zero = Vector3D(x: 0, y: 0, z: 0)
}

extension Vector3D: CustomStringConvertible {
    var description: String {
        return "(x: \(x), y: \(y), z: \(z)"
    }
}

extension Vector3D {
    // Vector addition
    static func + (left: Vector3D, right: Vector3D) -> Vector3D {
      return Vector3D(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }
    
    // Vector subtraction
    static func - (left: Vector3D, right: Vector3D) -> Vector3D {
        return left + (-right)
    }
    
    // Vector addition assignment
    static func += (left: inout Vector3D, right: Vector3D) {
        left = left + right
    }
    
    // Vector subtraction assignment
    static func -= (left: inout Vector3D, right: Vector3D) {
        left = left - right
    }
    
    // Vector negation
    static prefix func - (vector: Vector3D) -> Vector3D {
      return Vector3D(x: -vector.x, y: -vector.y, z: -vector.z)
    }
}

infix operator * : MultiplicationPrecedence
infix operator / : MultiplicationPrecedence
infix operator • : MultiplicationPrecedence

extension Vector3D {
    // Scalar-vector multiplication
    static func * (left: Double, right: Vector3D) -> Vector3D {
      return Vector3D(x: right.x * left, y: right.y * left, z: right.z * left)
    }
    
    static func * (left: Vector3D, right: Double) -> Vector3D {
      return Vector3D(x: left.x * right, y: left.y * right, z: left.z * right)
    }
    
    // Vector-scalar division
    static func / (left: Vector3D, right: Double) -> Vector3D {
        guard right != 0 else { fatalError("Division by zero") }
      return Vector3D(x: left.x / right, y: left.y / right, z: left.z / right)
    }
    
    // Vector-scalar division assignment
    static func /= (left: inout Vector3D, right: Double) -> Vector3D {
        guard right != 0 else { fatalError("Division by zero") }
      return Vector3D(x: left.x / right, y: left.y / right, z: left.z / right)
    }
    
    // Scalar-vector multiplication assignment
    static func *= (left: inout Vector3D, right: Double) {
        left = left * right
    }
}

extension Vector3D {
    // Vector magnitude (length)
    var magnitude: Double {
        return sqrt(x*x + y*y + z*z)
    }
    
    // Distance between two vectors
    func distance(to vector: Vector3D) -> Double {
        return (self - vector).magnitude
    }
    
    // Vector normalization
    var normalized: Vector3D {
      return Vector3D(x: x / magnitude, y: y / magnitude, z: z / magnitude)
    }
    
    // Dot product of two vectors
    static func • (left: Vector3D, right: Vector3D) -> Double {
      return left.x * right.x + left.y * right.y + left.z * right.z
    }
    
    // Angle between two vectors
    // θ = acos(AB)
    func angle(to vector: Vector3D) -> Double {
        return acos(self.normalized • vector.normalized)
    }
}

extension Vector3D {
//    点所在的象限
    var quadrant:Int {
        switch (self.x,self.y) {
        case let (x, y) where x > 0 && y > 0:
            return 1
        case let (x, y) where x > 0 && y < 0:
            return 2
        case let (x, y) where x < 0 && y < 0:
            return 3
        case let (x, y) where x < 0 && y < 0:
            return 4
            
        case let (x, y) where x == 0 && y == 0:
            return 0
        
        case let (x, y) where x == 0 && y > 0:
            return 1
            
        case let (x, y) where x == 0 && y < 0:
            return 3
            
        case let (x, y) where x > 0 && y == 0:
            return 2
            
        case let (x, y) where x < 0 && y == 0:
            return 4
            
        default:
            return 0
        }
    }
    
    
    // 向量相对Y轴正方向的夹角 0 - 360
    func angle() -> Double {
        switch self.quadrant {
            case 0:
                return 0
            case 1:
                return self.angle(to: Vector3D(x: 0, y: 1))
            case 2:
                return self.angle(to: Vector3D(x: 1, y: 0)) + 90
            case 3:
                return self.angle(to: Vector3D(x: 0, y: -1)) + 180
            case 4:
                return self.angle(to: Vector3D(x: -1, y: 0)) + 270
            default:
                return 0
            
        }
    }
    
    static func angle(left: Vector3D, right: Vector3D) -> Double {
        return left.angle() - right.angle()
    }
}

extension Vector3D: Equatable {
    static func == (left: Vector3D, right: Vector3D) -> Bool {
      return (left.x == right.x) && (left.y == right.y) && (left.z == right.z)
    }
}
