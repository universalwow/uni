
import Foundation
import SwiftUI

struct Card {
  var content:String
  var sportClass: SportClass
  var backColor: Color = .green
  
    static let `default`: Card = Card(content: "card", sportClass: .None, backColor: .green)
}
