

import SwiftUI

class ObservableState: ObservableObject {
    var ruleFlag = false {
        willSet {
            objectWillChange.send()
        }
    }
}
