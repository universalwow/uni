

import Foundation
import SwiftUI

enum ObjectPosition: String, Codable, Identifiable, CaseIterable {
  var id: String {
    self.rawValue
  }
  
  case topLeft
  case topMiddle
  case topRight
  case middleLeft
  case middle
  case middleRight
  case bottomLeft
  case bottomMiddle
  case bottomRight
  
}

extension CGRect {
  
  func pointOf(position: ObjectPosition) -> CGPoint {
    switch position {
    case .topLeft:
      return CGPoint(x: self.minX, y: self.minY)
    case .topMiddle:
      return CGPoint(x: self.midX, y: self.minY)
    case .topRight:
      return CGPoint(x: self.maxX, y: self.minY)
    case .middleLeft:
      return CGPoint(x: self.minX, y: self.midY)
    case .middle:
      return CGPoint(x: self.midX, y: self.midY)
    case .middleRight:
      return CGPoint(x: self.maxX, y: self.midY)
    case .bottomLeft:
      return CGPoint(x: self.minX, y: self.maxY)
    case .bottomMiddle:
      return CGPoint(x: self.midX, y: self.maxY)
    case .bottomRight:
      return CGPoint(x: self.maxX, y: self.maxY)
    }
  }
}



enum ObjectLabel: String, Codable {
    case ROPE = "rope"
    case POSE = "person"
    case BASKETBALL = "basketball"
}


struct Observation: Selectable, Codable, Equatable {
  var id: String
  var label: String
  var confidence: String
  var rect: CGRect
  var color = Color.blue
  var selected = false
  
  init(id: String, label: String, confidence: String, rect: CGRect) {
    self.id = id
    self.label = label
    self.confidence = confidence
    self.rect = rect
    self.color = setColor(label: label)
  }
  
  func setColor(label: String) -> Color {
      if label == ObjectLabel.ROPE.rawValue {
      return .blue
      }else if label == ObjectLabel.POSE.rawValue {
      return .green
    }
    return .white
  }
  
  var text: String {
    "\(self.label) - \(self.confidence)"
  }
}
