

import Foundation
import SwiftUI
import PerspectiveTransform
import CoreGraphics


extension CGFloat {
  var float:Float {
    Float(self)
  }
  
  
  var roundedString: String {
    String(format: "%.0f", self)
  }
}


extension Double {
  var float:Float {
    Float(self)
  }
  
  func roundedString(number: Int) -> String {
    String(format: "%.\(number)f", self)
  }
  
}

extension Float {
  var double:Double {
    Double(self)
  }
  
  func roundedString(number: Int) -> String {
    String(format: "%.\(number)f", self)
  }
  
}


extension CGSize {

  static func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width:left.width + right.width,
                  height: left.height + right.height)
  }
  
  static func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width:left.width * right,
                  height: left.height * right)
  }
  
  static func / (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width:left.width / right,
                  height: left.height / right)
  }
  
  
  var roundedString: String {
    "\(self.width.roundedString)/\(self.height.roundedString)"
  }
  
  
  func viewPoint(geometrySize:CGSize) -> CGPoint {
    CGPoint(x: geometrySize.width/2 + self.width, y: geometrySize.height/2 + self.height)
  }
  
  
}



