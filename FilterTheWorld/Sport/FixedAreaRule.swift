

import Foundation

struct FixedAreaRule: Identifiable, Hashable, Codable, Ruler {
    
    static func == (lhs: FixedAreaRule, rhs: FixedAreaRule) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    
    var ruleClass: RuleClass = .FixedArea
    
    
    var landmarkInFixedArea: [LandmarkInAreaForAreaRule] = []

    
    
    func firstLandmarkInFixedAreaIndexById(id: UUID) -> Int? {
        landmarkInFixedArea.firstIndex(where: { _landmarkInArea in
            _landmarkInArea.id == id
            
        })
    }
    

    
    mutating func generatorFixedArea(areaId: String, area: [Point2D]) {

        landmarkInFixedArea.indices.forEach({ index in
            if landmarkInFixedArea[index].areaId == areaId {
                landmarkInFixedArea[index].area = area
            }
        })
    }
        
    mutating func updateRuleLandmarkInFixedAreaForAreaRule(
        area: [Point2D], imageSize: Point2D, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,  landmark: Landmark, id: UUID) {
        
            if let landmarkInAreaIndex = self.firstLandmarkInFixedAreaIndexById(id: id) {
                
                landmarkInFixedArea[landmarkInAreaIndex].warning.content = warningContent
                landmarkInFixedArea[landmarkInAreaIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
                landmarkInFixedArea[landmarkInAreaIndex].warning.delayTime = delayTime
                landmarkInFixedArea[landmarkInAreaIndex].warning.changeStateClear = changeStateClear
                landmarkInFixedArea[landmarkInAreaIndex].landmark = landmark
                landmarkInFixedArea[landmarkInAreaIndex].area = area

           
            }
            
        }
    
    
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, objects: [Observation], frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int) {
        
        let landmarkInFixedAreaSatisfys = landmarkInFixedArea.reduce((true, Set<Warning>(), 0, 0), {result, next in
            let satisfy = next.satisfy(poseMap: poseMap, frameSize: frameSize)
            
            var newWarnings = result.1
            
            if next.warning.triggeredWhenRuleMet && satisfy {
                newWarnings.insert(next.warning)
            }else if !next.warning.triggeredWhenRuleMet && !satisfy {
                newWarnings.insert(next.warning)
            }
            
            return (result.0 && satisfy,
                    newWarnings,
                    satisfy ? result.2 + 1 : result.2,
                    result.2 + 1)
        })
        
        return landmarkInFixedAreaSatisfys
    }

}

struct DynamicAreaRule: Identifiable, Hashable, Codable, Ruler {
    
    static func == (lhs: DynamicAreaRule, rhs: DynamicAreaRule) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    
    var ruleClass: RuleClass = .DynamicArea
    

    //  左上，右下
//    var limitedArea: [Point2D] = [Point2D.zero, Point2D.zero, Point2D.zero, Point2D.zero]
    
    
    var landmarkInDynamicdArea: [LandmarkInAreaForAreaRule] = []
    
    
    func firstLandmarkInDynamicAreaIndexById(id: UUID) -> Int? {
        landmarkInDynamicdArea.firstIndex(where: { _landmarkInArea in
            _landmarkInArea.id == id
            
        })
    }
    

    
    mutating func generatorDynamicArea(areaId: String, area: [Point2D]) {

        landmarkInDynamicdArea.indices.forEach({ index in
            if landmarkInDynamicdArea[index].areaId == areaId {
                landmarkInDynamicdArea[index].area = area
            }
        })
    }
    

    
    
    
    mutating func updateRuleLandmarkInDynamicAreaForAreaRule(
        area: [Point2D], imageSize: Point2D, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,  landmark: Landmark, id: UUID) {
        
            
            
            if let landmarkInAreaIndex = self.firstLandmarkInDynamicAreaIndexById(id: id) {
                
                landmarkInDynamicdArea[landmarkInAreaIndex].warning.content = warningContent
                landmarkInDynamicdArea[landmarkInAreaIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
                landmarkInDynamicdArea[landmarkInAreaIndex].warning.delayTime = delayTime
                landmarkInDynamicdArea[landmarkInAreaIndex].warning.changeStateClear = changeStateClear
                landmarkInDynamicdArea[landmarkInAreaIndex].landmark = landmark
                landmarkInDynamicdArea[landmarkInAreaIndex].area = area

           
            }
            
        }
    
    
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, objects: [Observation], frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int) {
        
        let landmarkInDynamicAreaSatisfys = landmarkInDynamicdArea.reduce((true, Set<Warning>(), 0, 0), {result, next in
            let satisfy = next.satisfy(poseMap: poseMap, frameSize: frameSize)
            
            var newWarnings = result.1
            
            if next.warning.triggeredWhenRuleMet && satisfy {
                newWarnings.insert(next.warning)
            }else if !next.warning.triggeredWhenRuleMet && !satisfy {
                newWarnings.insert(next.warning)
            }
            
            return (result.0 && satisfy,
                    newWarnings,
                    satisfy ? result.2 + 1 : result.2,
                    result.2 + 1)
        })
        
        return landmarkInDynamicAreaSatisfys
    }

}
