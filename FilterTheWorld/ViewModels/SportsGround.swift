

import Foundation
import SwiftUI

class SportsGround: ObservableObject {
    
    @Published var sports: [Sport] = SportsGround.allSports
    
    @Published var sporters : [Sporter] = []
    @Published var warnings: [Warning] = []
    var sportersReport: [SportReport] = []
    
    func clearWarning() {
        warnings = []
    }
    
    

    
    func fixedAreas() -> [FixedAreaForSport] {
        var areas: [FixedAreaForSport] = []
        sporters.forEach( { sporter in
            areas.append(contentsOf:
                            sporter.getFixedAreas()
            )
        } )
        return areas
    }
    
    func dynamicAreas() -> [DynamicAreaForSport] {
        var areas: [DynamicAreaForSport] = []
        sporters.forEach( { sporter in
            areas.append(contentsOf:
                            sporter.getDynamicAreas()
            )
        } )
        return areas
    }
    
    func getAnswer() -> String {
        var answers : Set<Int> = []
        sporters.forEach { sporter in
            answers.formUnion(sporter.answerSet)
        }
        return answers.description
    }
    
    func addSporter(sport: Sport) {
        print("add Sporter")
        let sporter = Sporter(name: "Uni", sport: sport, onStateChange: {
            self.warnings = self.warnings.filter({ warning in
                print("content \(warning.changeStateClear == false) - \(warning.content)")
                return warning.changeStateClear == false
            })
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
            sportersReport[sporterIndex].interactionScoreTimes = sporter.interactionScoreTimes
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
            
       
//            if sporters[sporterIndex].scoreTimes 
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

        }
    }
    
    var cancelableWarningMap: [String: Timer] = [:]
    

    
}


extension SportsGround {
    static var allSports: [Sport] {
//        MARK: 此处加载的项目 从服务端加载时去掉图片等大资源。提升存储和网络效率
        let files = Storage.allFiles(.documents).filter{ url in
            let v:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            return url.absoluteString.contains(v)
        }.map{ url -> Sport in
//            print(url)
            return Storage.retrieve(url: url, as: Sport.self)
        }.sorted(by: { (first, second) in
            if first.name == second.name {
                return first.sportClass.rawValue <= second.sportClass.rawValue
            }
            return first.name <= second.name
            
        })
        print("files \(files.count)")
        return files
    }
    
    var allGrstureControllerSports : [Sport] {
        sports.filter{ sport in
            sport.isGestureController
        }
    }
    
    func updateSports() {
        sports = Storage.allFiles(.documents).filter{ url in
            let v:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            return url.absoluteString.contains(v)
        }.map{ url in
            
            let sport = Storage.retrieve(url: url, as: Sport.self)
            return sport
            
        }.sorted(by: { (first, second) in
            
            
            if first.name == second.name {
                return first.sportClass.rawValue <= second.sportClass.rawValue
            }
            return first.name < second.name
            
        })
    }
}
