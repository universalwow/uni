

import Foundation

struct LandmarkRule: Identifiable, Hashable, Codable, Ruler {
    static func == (lhs: LandmarkRule, rhs: LandmarkRule) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    var landmarkType:LandmarkType
    
    var ruleClass: RuleClass = .Landmark
    
    init(landmarkType: LandmarkType) {
        self.id = landmarkType.id
        self.landmarkType = landmarkType
    }
    
    init(ruleId: String) {
        self.id = ruleId
        self.landmarkType = LandmarkType(rawValue: ruleId)!
    }
    
    
    // 关节点在区域内
    var landmarkInArea: [LandmarkInArea] = []
    // 关节相对自身位移
//    相关状态转换时收集的关节点 不更新
    var lengthToState: [LandmarkToAxisAndState] = []
    // 关节相对自身最大位移
    var landmarkToSelf: [LandmarkToSelf] = []
    
    
    func landmarkInAreaSatisfy(landmarkInArea: LandmarkInArea, poseMap: PoseMap, frameSize: Point2D) -> Bool {
        return landmarkInArea.satisfy(poseMap: poseMap, frameSize: frameSize)
    }
    
    func lengthToStateSatisfy(relativeDistance: LandmarkToAxisAndState, stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool {
        return relativeDistance.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap)
    }
    
    
    func landmarkToSelfSatisfy(landmarkToSelf: LandmarkToSelf, stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool {
        return landmarkToSelf.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap)
    }
    

    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int) {
        
        let landmarkInAreaSatisfys = landmarkInArea.reduce((true, Set<Warning>(), 0, 0), {result, next in
            let satisfy = self.landmarkInAreaSatisfy(landmarkInArea: next, poseMap: poseMap, frameSize: frameSize)

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
        

        
        let lengthToStateSatisfys = lengthToState.reduce((true, Set<Warning>(), 0, 0), {result, next in
            let satisfy = self.lengthToStateSatisfy(relativeDistance: next, stateTimeHistory: stateTimeHistory, poseMap: poseMap)

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
        
        

        let landmarkToSelfSatisfys = landmarkToSelf.reduce((true, Set<Warning>(), 0, 0), { result, next in
            let satisfy = self.landmarkToSelfSatisfy(landmarkToSelf: next, stateTimeHistory: stateTimeHistory, poseMap: poseMap)

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
        return (landmarkInAreaSatisfys.0 && lengthToStateSatisfys.0 && landmarkToSelfSatisfys.0,
                landmarkInAreaSatisfys.1.union(lengthToStateSatisfys.1).union(landmarkToSelfSatisfys.1),
                landmarkInAreaSatisfys.2 + lengthToStateSatisfys.2 + landmarkToSelfSatisfys.2,
                landmarkInAreaSatisfys.3 + lengthToStateSatisfys.3 + landmarkToSelfSatisfys.3)
    }
    
    
    
}

