

import Foundation
import SwiftUI

class SportsGround: ObservableObject {
    
    @Published var sports: [Sport] = SportsGround.allSports
    
    @Published var sporters : [Sporter] = []
    @Published var warnings: Set<String> = []
    var sportersReport: [SportReport] = []
    
    
    
    var warningArray: [String] {
        warnings.map{ warning in
            warning
        }.sorted()
    }
    
    func clearWarning() {
        totalWarnings = []
        //    warnings = []
        //    cancelableWarningMap.forEach{ key, _ in
        //      cancelableWarningMap[key]?.invalidate()
        //    }
        //    cancelableWarningMap.removeAll()
    }
    
    func addSporter(sport: Sport) {
        let sporter = Sporter(name: "Uni", sport: sport)
        sporters = [sporter]
        sportersReport = [SportReport(sporterName: sporter.name, sportName: sport.name, sportClass: sport.sportClass, sportPeriod: sport.sportPeriod, statesDescription: sport.statesDescription)]
        clearWarning()
    }
    
    func saveSportReport(endTime: Double) {
        sporters.indices.forEach({ sporterIndex in
            let sporter = sporters[sporterIndex]
            sportersReport[sporterIndex].endTime = endTime
            sportersReport[sporterIndex].scoreTimes = sporter.scoreTimes
            sportersReport[sporterIndex].warnings = sporter.warnings
            
            Storage.store(sportersReport[sporterIndex], to: .documents, secondaryDirectory: "sportsReport", as: sportersReport[sporterIndex].fileName)
            
        })
    }
    
    func play(poseMap: PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
        sporters.indices.forEach { sporterIndex in
            if sportersReport[sporterIndex].startTime < 0 {
                sportersReport[sporterIndex].startTime = currentTime
            }
            sporters[sporterIndex].play(poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize, currentTime: currentTime)
            // 该帧到来的提醒
            // 1. 如果该提醒不存在 将其加入map
            // 2. 如果该提醒存在 则不管
            // 3. 如果没提醒 则取消所有
            
            //      cancelingWarnings = sporters[sporterIndex].cancelingWarnings
            //      newWarnings = sporters[sporterIndex].cancelingWarnings
            
            totalWarnings = sporters[sporterIndex].totalWarnings
//
//            print("warnings \(sporters[sporterIndex].currentStateTime.sportState.name)/\(warnings)")
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
                cancelableWarningMap[newWarning] = timer(warning: newWarning, warningDelay: sporters.first?.sport.warningDelay ?? 1.0)
            }
            
        }
    }
    
    
    
    var cancelableWarningMap: [String: Timer] = [:]
    
    func timer(warning: String, warningDelay: TimeInterval) -> Timer {
        Timer.scheduledTimer(
            withTimeInterval: warningDelay, repeats: false) { [weak self] _ in
                self?.warnings.insert(warning)
                // 加入后取消
                //        self?.cancelableWarningMap[warning]?.invalidate()
                //        self?.cancelableWarningMap.removeValue(forKey: warning)
            }
    }
    
    
    
}


extension SportsGround {
    static var allSports: [Sport] {
//        MARK: 此处加载的项目 从服务端加载时去掉图片等大资源。提升存储和网络效率
        Storage.allFiles(.documents).map{ url in
            Storage.retrieve(url: url, as: Sport.self)
        }
    }
    
    func updateSports() {
        sports = Storage.allFiles(.documents).map{ url in
            
            let sport = Storage.retrieve(url: url, as: Sport.self)
            print("start camera update.........\(sport.name) - \(sport.scoreTimeLimit ?? 0)")
            return sport
            
        }
    }
}
