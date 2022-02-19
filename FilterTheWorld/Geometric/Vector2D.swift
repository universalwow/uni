//
//  Vector2D.swift
//
//  Created by uniwow on 2021/6/24.
//

import Foundation
import SwiftUI

struct Vector2D {
    var x = 0.0, y = 0.0
    
    static let zero = Vector2D(x: 0, y: 0)
}

extension Vector2D: CustomStringConvertible {
    var description: String {
        return "(x: \(x), y: \(y))"
    }
  
  var toCGPoint: CGPoint {
    CGPoint(x: x,y: y)
  }
}




extension Vector2D {
    // Vector addition
    static func + (left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x + right.x, y: left.y + right.y)
    }
    
    // Vector subtraction
    static func - (left: Vector2D, right: Vector2D) -> Vector2D {
        return left + (-right)
    }
    
    // Vector addition assignment
    static func += (left: inout Vector2D, right: Vector2D) {
        left = left + right
    }
    
    // Vector subtraction assignment
    static func -= (left: inout Vector2D, right: Vector2D) {
        left = left - right
    }
    
    // Vector negation
    static prefix func - (vector: Vector2D) -> Vector2D {
        return Vector2D(x: -vector.x, y: -vector.y)
    }
}

infix operator * : MultiplicationPrecedence
infix operator / : MultiplicationPrecedence
infix operator • : MultiplicationPrecedence

extension Vector2D {
    // Scalar-vector multiplication
    static func * (left: Double, right: Vector2D) -> Vector2D {
        return Vector2D(x: right.x * left, y: right.y * left)
    }
    
    static func * (left: Vector2D, right: Double) -> Vector2D {
        return Vector2D(x: left.x * right, y: left.y * right)
    }
    
    // Vector-scalar division
    static func / (left: Vector2D, right: Double) -> Vector2D {
        guard right != 0 else { fatalError("Division by zero") }
        return Vector2D(x: left.x / right, y: left.y / right)
    }
    
    // Vector-scalar division assignment
    static func /= (left: inout Vector2D, right: Double) -> Vector2D {
        guard right != 0 else { fatalError("Division by zero") }
        return Vector2D(x: left.x / right, y: left.y / right)
    }
    
    // Scalar-vector multiplication assignment
    static func *= (left: inout Vector2D, right: Double) {
        left = left * right
    }
}

extension Vector2D {
    // Vector magnitude (length)
    var magnitude: Double {
        return sqrt(x*x + y*y)
    }
    
    // Distance between two vectors
    func distance(to vector: Vector2D) -> Double {
        return (self - vector).magnitude
    }
    
    // Vector normalization
    var normalized: Vector2D {
        return Vector2D(x: x / magnitude, y: y / magnitude)
    }
    
    // Dot product of two vectors
    static func • (left: Vector2D, right: Vector2D) -> Double {
        return left.x * right.x + left.y * right.y
    }
    
    // Angle between two vectors
    // θ = acos(AB)
    func angle(to vector: Vector2D) -> Double {
      return acos(self.normalized • vector.normalized)/Double.pi*180.0
    }
}

extension Vector2D {
//    点所在的象限
    var quadrant:Int {
        switch (self.x,self.y) {
        case let (x, y) where x > 0 && y > 0:
            return 1
        case let (x, y) where x > 0 && y < 0:
            return 2
        case let (x, y) where x < 0 && y < 0:
            return 3
        case let (x, y) where x < 0 && y > 0:
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
                return self.angle(to: Vector2D(x: 0, y: 1))
            case 2:
                return self.angle(to: Vector2D(x: 1, y: 0)) + 90
            case 3:
                return self.angle(to: Vector2D(x: 0, y: -1)) + 180
            case 4:
                return self.angle(to: Vector2D(x: -1, y: 0)) + 270
            default:
                return 0
            
        }
    }
    
    static func angle(left: Vector2D, right: Vector2D) -> Double {
        return left.angle() - right.angle()
    }
}

extension Vector2D: Equatable {
    static func == (left: Vector2D, right: Vector2D) -> Bool {
        return (left.x == right.x) && (left.y == right.y)
    }
}


extension Vector2D {
  var oppositeYVector2D : Vector2D {
    Vector2D(x: x, y: -1 * y)
  }
  
}
