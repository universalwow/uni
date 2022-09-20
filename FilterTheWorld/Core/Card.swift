
import Foundation
import SwiftUI

struct Card {
  var content:String
  var sportClass: SportClass
    var sportPeriod: SportPeriod
    var sportDiscrete: SportPeriod
    var isGestureController: Bool
    var interactionType: InteractionType
  var backColor: Color = .green
  
    static let `default`: Card = Card(content: "card",
                                      sportClass: .None,
                                      sportPeriod: .None,
                                      sportDiscrete: .None,
                                      isGestureController: false,
                                      interactionType: .None,
                                      backColor: .green)
}
