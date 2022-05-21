
import Foundation
import SwiftUI

struct Card {
  var content:String
  var backColor: Color = .green
  
  static let `default`: Card = Card(content: "card", backColor: .green)
}
