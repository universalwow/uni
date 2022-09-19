

import Foundation

struct AreaRule: Identifiable, Hashable, Codable, Ruler {
    
    static func == (lhs: AreaRule, rhs: AreaRule) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    
    var ruleClass: RuleClass = .Area
    

    //  左上，右下
//    var limitedArea: [Point2D] = [Point2D.zero, Point2D.zero, Point2D.zero, Point2D.zero]
    
    var landmarkInArea: [LandmarkInAreaForAreaRule] = []
    
    func firstLandmarkInAreaIndexById(id: UUID) -> Int? {
        landmarkInArea.firstIndex(where: { _landmarkInArea in
            _landmarkInArea.id == id
            
        })
    }
    
    mutating func generatorArea(areaId: String, area: [Point2D]) {

        landmarkInArea.indices.forEach({ index in
            if landmarkInArea[index].dynamicAreaId == areaId {
                landmarkInArea[index].area = area
            }
        })
    }
    

    
    mutating func updateRuleLandmarkInAreaForAreaRule(
        area: [Point2D], imageSize: Point2D, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,  landmark: Landmark, id: UUID) {
        
            
            
            if let landmarkInAreaIndex = self.firstLandmarkInAreaIndexById(id: id) {
                
                landmarkInArea[landmarkInAreaIndex].warning.content = warningContent
                landmarkInArea[landmarkInAreaIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
                landmarkInArea[landmarkInAreaIndex].warning.delayTime = delayTime
                landmarkInArea[landmarkInAreaIndex].warning.changeStateClear = changeStateClear
                landmarkInArea[landmarkInAreaIndex].landmark = landmark
                landmarkInArea[landmarkInAreaIndex].area = area

           
            }
            
        }
    
    
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int) {
        
        let landmarkInAreaSatisfys = landmarkInArea.reduce((true, Set<Warning>(), 0, 0), {result, next in
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
        
        return landmarkInAreaSatisfys
    }
    
 
    
    
}
