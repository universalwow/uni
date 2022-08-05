

import Foundation
import SwiftUI

class SportsGround: ObservableObject {
    
    @Published var sports: [Sport] = SportsGround.allSports
    
    @Published var sporters : [Sporter] = []
    @Published var warnings: Set<String> = []
    var sportersReport: [SportReport] = []
    
    
    func clearWarning() {
        warnings = []
    }
    
    func addSporter(sport: Sport) {
        print("add Sporter")
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
            sportersReport[sporterIndex].warnings = sporter.warningsData
            
            Storage.store(sportersReport[sporterIndex], to: .documents, secondaryDirectory: "sportsReport", as: sportersReport[sporterIndex].fileName)
        })
    }
    
    func play(poseMap: PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
        sporters.indices.forEach { sporterIndex in
            if sportersReport[sporterIndex].startTime < 0 {
                sportersReport[sporterIndex].startTime = currentTime
            }
            sporters[sporterIndex].play(poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize, currentTime: currentTime)
            DispatchQueue.main.async {
                self.warnings = self.sporters[sporterIndex].warnings
            }

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
            DispatchQueue.main.async {
                self.warnings = self.warnings.subtracting(cancelWarnings)
            }
            
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
