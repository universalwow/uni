

import Foundation
import SwiftUI

class SportsGround: ObservableObject {
    
    @Published var sports: [Sport] = SportsGround.allSports
    
    @Published var sporters : [Sporter] = []
    @Published var warnings: Set<String> = []
    
    
    func clearWarning() {
        totalWarnings = []
        //    warnings = []
        //    cancelableWarningMap.forEach{ key, _ in
        //      cancelableWarningMap[key]?.invalidate()
        //    }
        //    cancelableWarningMap.removeAll()
    }
    
    func addSporter(sport: Sport) {
        sporters = [Sporter(name: "Uni", sport: sport)]
    }
    
    func play(poseMap: PoseMap, object: Observation?, currentTime: Double) {
        
        sporters.indices.forEach { sporterIndex in
            sporters[sporterIndex].play(poseMap: poseMap, object: object, currentTime: currentTime)
            // 该帧到来的提醒
            // 1. 如果该提醒不存在 将其加入map
            // 2. 如果该提醒存在 则不管
            // 3. 如果没提醒 则取消所有
            
            //      cancelingWarnings = sporters[sporterIndex].cancelingWarnings
            //      newWarnings = sporters[sporterIndex].cancelingWarnings
            
            totalWarnings = sporters[sporterIndex].totalWarnings
            
            print("warnings \(sporters[sporterIndex].currentStateTime.sportState.name)/\(warnings)")
        }
    }
    
    var totalWarnings: Set<String> = [] {
        // 所有存在 totalWarnings 而不在 map 中的规则 加入map
        // 所有不存在 totalWarnings 而在 map中的 取消
        // 存在双方的 不管
        didSet {
            
            let cancelWarnings = cancelableWarningMap.map { warning, _ in
                warning
            }.filter { warning in
                !totalWarnings.contains(where: { newWarning in
                    warning == newWarning
                })
            }
            
            cancelWarnings.forEach { cancelWarning in
                cancelableWarningMap[cancelWarning]?.invalidate()
                cancelableWarningMap.removeValue(forKey: cancelWarning)
            }
            
            warnings = warnings.subtracting(cancelWarnings)
            
            totalWarnings.filter { newWarning in
                !cancelableWarningMap.contains(where: { warning, _ in
                    warning == newWarning
                })
            }.forEach { newWarning in
                cancelableWarningMap[newWarning] = timer(warning: newWarning)
            }
            
        }
    }
    
    
    
    var cancelableWarningMap: [String: Timer] = [:]
    
    func timer(warning: String) -> Timer {
        Timer.scheduledTimer(
            withTimeInterval: 1, repeats: false) { [weak self] _ in
                self?.warnings.insert(warning)
                // 加入后取消
                //        self?.cancelableWarningMap[warning]?.invalidate()
                //        self?.cancelableWarningMap.removeValue(forKey: warning)
            }
    }
    
    
    
}


extension SportsGround {
    static var allSports: [Sport] {
        Storage.allFiles(.documents).map{ url in
            Storage.retrieve(url: url, as: Sport.self)
        }
    }
    
    func updateSports() {
        sports = Storage.allFiles(.documents).map{ url in
            Storage.retrieve(url: url, as: Sport.self)
        }
    }
}
