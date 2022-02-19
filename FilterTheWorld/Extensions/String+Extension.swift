

import Foundation


extension String {
  var landmarkTypeRawValueMirror: String {
    
    if self.contains("Left") {
      return self.replacingOccurrences(of: "Left", with:"Right")
    }else if (self.contains("Right")) {
      return self.replacingOccurrences(of: "Right", with:"Left")
    }
    return self
  }
}
