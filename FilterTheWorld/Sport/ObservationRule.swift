

import Foundation


struct ObservationRule: Identifiable, Hashable, Codable, Ruler {
    static func == (lhs: ObservationRule, rhs: ObservationRule) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    var objectLabel: ObjectLabel
    var ruleClass: RuleClass = .Observation
    
    init(objectLabel: ObjectLabel) {
        self.id = objectLabel.rawValue
        self.objectLabel = objectLabel
    }
    
    init(ruleId: String) {
        self.id = ruleId
        self.objectLabel = ObjectLabel(rawValue: ruleId)!
    }
    
    // 物体位置相对于关节点
    var objectPositionToLandmark: [ObjectToLandmark] = []
    
    // 物体位置相对于物体位置
    var objectPositionToObjectPosition: [ObjectToObject] = []
    
    // 物体相对于自身最大位移
    var objectToSelf: [ObjectToSelf] = []
    
    func objectToLandmarkSatisfy(objectToLandmark: ObjectToLandmark, poseMap: PoseMap, object: Observation) -> Bool {
        return objectToLandmark.satisfy(poseMap: poseMap, object: object)
    }
    
    func objectToObjectSatisfy(objectToObject: ObjectToObject, poseMap: PoseMap, object: Observation, targetObject: Observation) -> Bool {
        return objectToObject.satisfy(poseMap: poseMap, fromObject: object, toObject: targetObject)
    }
    
    func objectToSelfSatisfy(objectToSelf: ObjectToSelf, stateTimeHistory: [StateTime], object: Observation) -> Bool {
        return objectToSelf.satisfy(stateTimeHistory: stateTimeHistory, object: object)
    }
    

    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int) {
        
        let objectToLandmarkSatisfys = objectPositionToLandmark.reduce((true, Set<Warning>(), 0, 0), {result, next in
            var satisfy = false
            if let object = object {
                satisfy = self.objectToLandmarkSatisfy(objectToLandmark: next, poseMap: poseMap, object: object)
            }
            
            var newWarnings = result.1
            if next.warning.triggeredWhenRuleMet && satisfy {
                newWarnings.insert(next.warning)
            }else if !next.warning.triggeredWhenRuleMet && satisfy {
                newWarnings.insert(next.warning)
            }
            
            return (result.0 && satisfy,
                    newWarnings,
                    satisfy ? result.2 + 1 : result.2,
                    result.2 + 1)
        })
        
        let objectToObjectSatisfys = objectPositionToObjectPosition.reduce((true, Set<Warning>(), 0, 0), {result, next in
            var satisfy = false
            if let object = object, let targetObject = targetObject {
                satisfy = self.objectToObjectSatisfy(objectToObject: next, poseMap: poseMap, object: object, targetObject: targetObject)
            } else {
                satisfy = false
            }
            
            var newWarnings = result.1
            if next.warning.triggeredWhenRuleMet && satisfy {
                newWarnings.insert(next.warning)
            }else if !next.warning.triggeredWhenRuleMet && satisfy {
                newWarnings.insert(next.warning)
            }
            
            return (result.0 && satisfy,
                    newWarnings,
                    satisfy ? result.2 + 1 : result.2,
                    result.2 + 1)
        })
        
        let objectToSelfSatisfys = objectToSelf.reduce((true, Set<Warning>(), 0, 0), {result, next in
            var satisfy = false
            if let object = object {
                satisfy = self.objectToSelfSatisfy(objectToSelf: next, stateTimeHistory: stateTimeHistory, object: object)
            } else {
                satisfy = false
            }
            
            var newWarnings = result.1
            if next.warning.triggeredWhenRuleMet && satisfy {
                newWarnings.insert(next.warning)
            }else if !next.warning.triggeredWhenRuleMet && satisfy {
                newWarnings.insert(next.warning)
            }
            
            return (result.0 && satisfy,
                    newWarnings,
                    satisfy ? result.2 + 1 : result.2,
                    result.2 + 1)
        })
        
        // 每个规则至少要包含一个条件 且所有条件都必须满足
        return (objectToLandmarkSatisfys.0 && objectToObjectSatisfys.0 && objectToSelfSatisfys.0,
                objectToLandmarkSatisfys.1.union(objectToObjectSatisfys.1).union(objectToSelfSatisfys.1),
                objectToLandmarkSatisfys.2 + objectToObjectSatisfys.2 + objectToSelfSatisfys.2,
                objectToLandmarkSatisfys.3 + objectToObjectSatisfys.3 + objectToSelfSatisfys.3)
    }
    
    
    
}
