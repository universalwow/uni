

import Foundation
import SwiftUI

class SportsGround: ObservableObject {
  @Published var sporters : [Sporter] = []
  
  func addSporter(sport: Sport) {
    sporters = [Sporter(name: "Uni", sport: sport)]
  }
  
  
}


extension SportsGround {
  static var allSports: [Sport] {
    Storage.allFiles(.documents).map{ url in
      Storage.retrieve(url: url, as: Sport.self)
    }
  }
}
