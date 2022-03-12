
import Foundation
import CoreGraphics

protocol RoundedString {
  var roundedString: String { get }
}

extension CGSize: RoundedString {
  var roundedString: String {
    "\(self.width.roundedString)/\(self.height.roundedString)"
  }
}

extension CGPoint: RoundedString {
  var roundedString: String {
    "\(self.x.roundedString)/\(self.y.roundedString)"
  }
}

extension CGFloat: RoundedString {
  var roundedString: String {
    String(format: "%.0f", self)
  }
}

extension Double: RoundedString {
  var roundedString: String {
    String(format: "%.0f", self)
  }
}

extension Float: RoundedString {
  var roundedString: String {
    String(format: "%.0f", self)
  }
}






