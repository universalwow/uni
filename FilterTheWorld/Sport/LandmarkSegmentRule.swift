

import Foundation






struct LandmarkSegmentRule: Identifiable, Hashable, Codable, Ruler {
    static func == (lhs: LandmarkSegmentRule, rhs: LandmarkSegmentRule) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // 关节点ID
    var id: String
    
    var landmarkSegmentType:LandmarkTypeSegment
    var ruleClass = RuleClass.LandmarkSegment
    
    init(landmarkSegmentType: LandmarkTypeSegment) {
        self.id = landmarkSegmentType.id
        self.landmarkSegmentType = landmarkSegmentType
    }
    
    init(ruleId: String) {
        self.id = ruleId
        self.landmarkSegmentType = ruleIdToLandmarkSegmentType(ruleId: ruleId)
    }
    
    // 10 - 30 340-380
    // 角度
    
    var angle:[AngleRange] = []
    // 相对长度
    var length: [RelativeLandmarkSegmentsToAxis] = []
    
    var angleToLandmarkSegment: [AngleToLandmarkSegment] = []
    
    func firstAngleIndexById(id: UUID) -> Int? {
        angle.firstIndex(where: { _angle in
            _angle.id == id
        })
    }
    
    func firstAngleToLandmarkSegmentIndexById(id: UUID) -> Int? {
        angleToLandmarkSegment.firstIndex(where: { _angle in
            _angle.id == id
        })
    }
    
    mutating func updateRuleLandmarkSegmentAngle(warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, lowerBound: Double, upperBound: Double, id: UUID) {
        if let angleIndex = self.firstAngleIndexById(id: id) {
            angle[angleIndex].warning.content = warningContent
            angle[angleIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            angle[angleIndex].warning.delayTime = delayTime
            angle[angleIndex].lowerBound = lowerBound
            angle[angleIndex].upperBound = upperBound
        }
        
    }
    
    mutating func updateRuleAngleToLandmarkSegment(fromLandmarkSegment: LandmarkSegment, toLandmarkSegment: LandmarkSegment, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,  id: UUID) {
        if let angleIndex = self.firstAngleToLandmarkSegmentIndexById(id: id) {
  
            angleToLandmarkSegment[angleIndex].warning.content = warningContent
            angleToLandmarkSegment[angleIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            angleToLandmarkSegment[angleIndex].warning.delayTime = delayTime
            
            angleToLandmarkSegment[angleIndex].lowerBound = lowerBound
            angleToLandmarkSegment[angleIndex].upperBound = upperBound
            
            angleToLandmarkSegment[angleIndex].from = fromLandmarkSegment
            angleToLandmarkSegment[angleIndex].to = toLandmarkSegment
        }
        
    }
    
    
    
    func angleSatisfy(angleRange: AngleRange, poseMap: PoseMap) -> Bool {
        return angleRange.satisfy(poseMap: poseMap)
    }
    
    func angleToLandmarkSatisfy(angleToLandmarkSegment: AngleToLandmarkSegment, poseMap: PoseMap) -> Bool {
        
        return angleToLandmarkSegment.satisfy(poseMap: poseMap)
    }
    
    func lengthSatisfy(relativeDistance: RelativeLandmarkSegmentsToAxis, poseMap: PoseMap) -> Bool {
        return relativeDistance.satisfy(poseMap: poseMap)
    }
    
    
    // 是否满足， 收集提醒， 满足的数目， 总规则数
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int) {
        // 单帧

        
        let lengthSatisfys = length.reduce((true, Set<Warning>(), 0, 0), {result, next in
            let satisfy = self.lengthSatisfy(relativeDistance: next, poseMap: poseMap)

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
        
        let angleSatisfys = angle.reduce((true, Set<Warning>(), 0, 0), {result, next in
            let satisfy = self.angleSatisfy(angleRange: next, poseMap: poseMap)
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
        
        let angleToLandmarkSegmentSatisfys = angleToLandmarkSegment.reduce((true, Set<Warning>(), 0, 0), {result, next in
            
            let satisfy = self.angleToLandmarkSatisfy(angleToLandmarkSegment: next, poseMap: poseMap)

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
        
        
        return (lengthSatisfys.0 && angleSatisfys.0 && angleToLandmarkSegmentSatisfys.0,
         lengthSatisfys.1.union(angleSatisfys.1).union(angleToLandmarkSegmentSatisfys.1),
         lengthSatisfys.2 + angleSatisfys.2 + angleToLandmarkSegmentSatisfys.2,
         lengthSatisfys.3 + angleSatisfys.3 + angleToLandmarkSegmentSatisfys.3)
    }
    
    
    
}


