

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
    var landmarkToState: [LandmarkToState] = []
    // 关节相对自身最大位移
    var landmarkToSelf: [LandmarkToSelf] = []
    
    
    func firstLandmarkToSelfIndexById(id: UUID) -> Int? {
        landmarkToSelf.firstIndex(where: { _landmarkToSelf in
            _landmarkToSelf.id == id
            
        })
    }
    
    
    
    
    mutating func updateRuleLandmarkToSelf(direction: Direction, toLandmarkSegment: LandmarkSegment, toAxis: CoordinateAxis, xLowerBound: Double, yLowerBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID) {
        if let landmarkToSelfIndex = self.firstLandmarkToSelfIndexById(id: id) {
            
            landmarkToSelf[landmarkToSelfIndex].warning.content = warningContent
            landmarkToSelf[landmarkToSelfIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            landmarkToSelf[landmarkToSelfIndex].warning.delayTime = delayTime
            
            landmarkToSelf[landmarkToSelfIndex].xLowerBound = xLowerBound
            landmarkToSelf[landmarkToSelfIndex].yLowerBound = yLowerBound
            
            
            landmarkToSelf[landmarkToSelfIndex].toDirection = direction
            landmarkToSelf[landmarkToSelfIndex].toLandmarkSegmentToAxis = LandmarkSegmentToAxis(landmarkSegment: toLandmarkSegment, axis: toAxis)

        }
        
    }
    
    
    func firstLandmarkToStateIndexById(id: UUID) -> Int? {
        landmarkToState.firstIndex(where: { _landmarkToState in
            _landmarkToState.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkToState(fromAxis: CoordinateAxis,
                                            fromLandmark: Landmark,
                                            toStateId: Int,
                                            toStateLandmark: Landmark,
                                            toLandmarkSegment: LandmarkSegment,
                                            toAxis: CoordinateAxis,
                                            lowerBound: Double, upperBound: Double,
                                            warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID) {
        if let landmarkToStateIndex = self.firstLandmarkToStateIndexById(id: id) {
            
            landmarkToState[landmarkToStateIndex].warning.content = warningContent
            landmarkToState[landmarkToStateIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            landmarkToState[landmarkToStateIndex].warning.delayTime = delayTime
            
            landmarkToState[landmarkToStateIndex].lowerBound = lowerBound
            landmarkToState[landmarkToStateIndex].upperBound = upperBound
            
            
            
            landmarkToState[landmarkToStateIndex].fromLandmarkToAxis =  LandmarkToAxis(landmark: fromLandmark, axis: fromAxis)
            landmarkToState[landmarkToStateIndex].toLandmarkToAxis =  LandmarkToAxis(landmark: toStateLandmark, axis: fromAxis)
            landmarkToState[landmarkToStateIndex].toStateId = toStateId

            landmarkToState[landmarkToStateIndex].toLandmarkSegmentToAxis = LandmarkSegmentToAxis(landmarkSegment: toLandmarkSegment, axis: toAxis)

        }
        
    }
    
    
    func firstLandmarkInAreaIndexById(id: UUID) -> Int? {
        landmarkInArea.firstIndex(where: { _landmarkInArea in
            _landmarkInArea.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkInArea(
        area: [Point2D],imageSize: Point2D, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID) {
        if let landmarkInAreaIndex = self.firstLandmarkInAreaIndexById(id: id) {
            
            landmarkInArea[landmarkInAreaIndex].warning.content = warningContent
            landmarkInArea[landmarkInAreaIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            landmarkInArea[landmarkInAreaIndex].warning.delayTime = delayTime
            
            landmarkInArea[landmarkInAreaIndex].area = area
            landmarkInArea[landmarkInAreaIndex].imageSize = imageSize
            



        }
        
    }
    
    
    func landmarkInAreaSatisfy(landmarkInArea: LandmarkInArea, poseMap: PoseMap, frameSize: Point2D) -> Bool {
        return landmarkInArea.satisfy(poseMap: poseMap, frameSize: frameSize)
    }
    
    func lengthToStateSatisfy(relativeDistance: LandmarkToState, stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool {
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
        

        
        let lengthToStateSatisfys = landmarkToState.reduce((true, Set<Warning>(), 0, 0), {result, next in
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

