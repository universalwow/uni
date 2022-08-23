

import Foundation
import SwiftUI

class SportsGround: ObservableObject {
    
    @Published var sports: [Sport] = SportsGround.allSports
    
    @Published var sporters : [Sporter] = []
    @Published var warnings: [String] = []
    var sportersReport: [SportReport] = []
    
    
    func clearWarning() {
        warnings = []
    }
    
    func addSporter(sport: Sport) {
        print("add Sporter")
        let sporter = Sporter(name: "Uni", sport: sport, onStateChange: {
            self.warnings = []
        })
        sporters = [sporter]
        sportersReport = [SportReport(sporterName: sporter.name, sportName: sport.name, sportClass: sport.sportClass, sportPeriod: sport.sportPeriod, statesDescription: sport.statesDescription)]
        clearWarning()
    }
    
    func saveSportReport(endTime: Double) {
        sporters.indices.forEach({ sporterIndex in
            let sporter = sporters[sporterIndex]
            sportersReport[sporterIndex].endTime = endTime
            sportersReport[sporterIndex].scoreTimes = sporter.scoreTimes
            sportersReport[sporterIndex].allStateTimes = sporter.allStateTimeHistory

            sportersReport[sporterIndex].warnings = sporter.warningsData
            sportersReport[sporterIndex].createTime = Date().timeIntervalSince1970
            
            if sportersReport[sporterIndex].endTime - sportersReport[sporterIndex].startTime > 20 {
                Storage.store(sportersReport[sporterIndex], to: .documents, secondaryDirectory: "sportsReport", as: sportersReport[sporterIndex].fileName)
            }
            
            
        })
    }
    
    func play(poseMap: PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
        sporters.indices.forEach { sporterIndex in
            if sportersReport[sporterIndex].startTime < 0 {
                sportersReport[sporterIndex].startTime = currentTime
            }
            sporters[sporterIndex].play(poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize, currentTime: currentTime)
            self.sporters[sporterIndex].delayWarnings.forEach({ newWarning in
                if !self.warnings.contains(newWarning) {
                    self.warnings.append(newWarning)
                }
            })
            self.sporters[sporterIndex].noDelayWarnings.forEach({ newWarning in
                if !self.warnings.contains(newWarning) {
                    self.warnings.append(newWarning)
                }
            })
//            状态切换清除warning
            
            
            
            
            
            
            

        }
    }
    
    var cancelableWarningMap: [String: Timer] = [:]
    

    
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
