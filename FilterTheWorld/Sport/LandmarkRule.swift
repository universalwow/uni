

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
    

    // 关节相对自身位移
    
    var distanceToLandmark: [DistanceToLandmark] = []
    var angleToLandmark: [AngleToLandmark] = []
    // 关节相对自身最大位移
    
    var landmarkToStateDistance: [LandmarkToStateDistance] = []
    var landmarkToStateAngle: [LandmarkToStateAngle] = []
    
    

    

    
    
    
    
    
    func firstDistanceToLandmarkIndexById(id: UUID) -> Int? {
        distanceToLandmark.firstIndex(where: { _length in
            _length.id == id
        })
    }
    
    mutating func updateRuleDistanceToLandmark(toLandmark: Landmark, fromAxis: CoordinateAxis, toLandmarkSegment: LandmarkSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
        if let lengthIndex = self.firstDistanceToLandmarkIndexById(id: id) {
            
            distanceToLandmark[lengthIndex].warning.content = warningContent
            distanceToLandmark[lengthIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            distanceToLandmark[lengthIndex].warning.delayTime = delayTime
            distanceToLandmark[lengthIndex].warning.changeStateClear = changeStateClear

            distanceToLandmark[lengthIndex].lowerBound = lowerBound
            distanceToLandmark[lengthIndex].upperBound = upperBound
            
            distanceToLandmark[lengthIndex].from.landmarkSegment.endLandmark = toLandmark
            distanceToLandmark[lengthIndex].from.axis = fromAxis

            distanceToLandmark[lengthIndex].to = LandmarkSegmentToAxis(landmarkSegment: toLandmarkSegment, axis: toAxis)
        }
        
    }
    
    
    
    func firstAngleToLandmarkIndexById(id: UUID) -> Int? {
        angleToLandmark.firstIndex(where: { _angleToLandmark in
            _angleToLandmark.id == id
        })
    }
    
    mutating func updateRuleAngleToLandmark(warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  lowerBound: Double, upperBound: Double, toLandmark: Landmark, id: UUID) {
        if let index = self.firstAngleToLandmarkIndexById(id: id) {
            angleToLandmark[index].warning.content = warningContent
            angleToLandmark[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            angleToLandmark[index].warning.delayTime = delayTime
            angleToLandmark[index].warning.changeStateClear = changeStateClear

            angleToLandmark[index].lowerBound = lowerBound
            angleToLandmark[index].upperBound = upperBound
            
            angleToLandmark[index].toLandmark = toLandmark
        }
        
    }
    
    
    func firstLandmarkToStateDistanceIndexById(id: UUID) -> Int? {
        landmarkToStateDistance.firstIndex(where: { _landmarkToStateExtreme in
            _landmarkToStateExtreme.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkToStateDistance(fromAxis: CoordinateAxis,
                                                    fromLandmark: Landmark,
                                                    toStateId: Int,
                                                    isRelativeToExtremeDirection: Bool,
                                                    extremeDirection: ExtremeDirection,
                                                    toStateLandmark: Landmark,
                                                    toLandmarkSegment: LandmarkSegment,
                                                    toAxis: CoordinateAxis,
                                                    lowerBound: Double, upperBound: Double,
                                                    warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID, defaultSatisfy: Bool) {
        if let index = self.firstLandmarkToStateDistanceIndexById(id: id) {
            
            landmarkToStateDistance[index].warning.content = warningContent
            landmarkToStateDistance[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            landmarkToStateDistance[index].warning.delayTime = delayTime
            landmarkToStateDistance[index].warning.changeStateClear = changeStateClear
            landmarkToStateDistance[index].defaultSatisfy = defaultSatisfy
            landmarkToStateDistance[index].lowerBound = lowerBound
            landmarkToStateDistance[index].upperBound = upperBound
            
            
            
            landmarkToStateDistance[index].fromLandmarkToAxis =  LandmarkToAxis(landmark: fromLandmark, axis: fromAxis)
            landmarkToStateDistance[index].toLandmarkToAxis =  LandmarkToAxis(landmark: toStateLandmark, axis: fromAxis)
            landmarkToStateDistance[index].toStateId = toStateId
            landmarkToStateDistance[index].isRelativeToExtremeDirection = isRelativeToExtremeDirection
            landmarkToStateDistance[index].extremeDirection = extremeDirection
            landmarkToStateDistance[index].toLandmarkSegmentToAxis = LandmarkSegmentToAxis(landmarkSegment: toLandmarkSegment, axis: toAxis)
            
        }
        
    }
    
    
    func firstLandmarkToStateAngleIndexById(id: UUID) -> Int? {
        landmarkToStateAngle.firstIndex(where: { _angle in
            _angle.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkToStateAngle(
        fromLandmark: Landmark,
        toStateId: Int,
        isRelativeToExtremeDirection: Bool,
        extremeDirection: ExtremeDirection,
        toStateLandmark: Landmark,
        lowerBound: Double, upperBound: Double,
        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID) {
            if let index = self.firstLandmarkToStateAngleIndexById(id: id) {
                
                landmarkToStateAngle[index].warning.content = warningContent
                landmarkToStateAngle[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
                landmarkToStateAngle[index].warning.delayTime = delayTime
                landmarkToStateAngle[index].warning.changeStateClear = changeStateClear

                landmarkToStateAngle[index].lowerBound = lowerBound
                landmarkToStateAngle[index].upperBound = upperBound
                
                landmarkToStateAngle[index].fromLandmark =  fromLandmark
                landmarkToStateAngle[index].toLandmark =  toStateLandmark
                landmarkToStateAngle[index].toStateId = toStateId
                landmarkToStateAngle[index].isRelativeToExtremeDirection = isRelativeToExtremeDirection
                landmarkToStateAngle[index].extremeDirection = extremeDirection
                
            }
            
        }
    
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, objects: [Observation], frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int) {
        
        
        
        let distanceToLandmarkSatisfys = distanceToLandmark.reduce((true, Set<Warning>(), 0, 0), {result, next in
            let satisfy = next.satisfy(poseMap: poseMap)
            
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
        
        let angleToLandmarkSatisfys = angleToLandmark.reduce((true, Set<Warning>(), 0, 0), {result, next in
            let satisfy = next.satisfy(poseMap: poseMap)
            
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
        
        
        
        let landmarkToStateDistanceSatisfys = landmarkToStateDistance.reduce((true, Set<Warning>(), 0, 0), {result, next in
            let satisfy = next.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap)
            
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
        
        let landmarkToStateAngleSatisfys = landmarkToStateAngle.reduce((true, Set<Warning>(), 0, 0), {result, next in
            let satisfy = next.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap)
            
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
        
        
        // 每个规则至少要包含一个条件 且所有条件都必须满足
        return (angleToLandmarkSatisfys.0 && landmarkToStateDistanceSatisfys.0 && landmarkToStateAngleSatisfys.0 && distanceToLandmarkSatisfys.0,
                angleToLandmarkSatisfys.1.union(landmarkToStateDistanceSatisfys.1).union(landmarkToStateAngleSatisfys.1).union(distanceToLandmarkSatisfys.1),
                angleToLandmarkSatisfys.2 + landmarkToStateDistanceSatisfys.2 + landmarkToStateAngleSatisfys.2  + distanceToLandmarkSatisfys.2,
                angleToLandmarkSatisfys.3 + landmarkToStateDistanceSatisfys.3 + landmarkToStateAngleSatisfys.3  + distanceToLandmarkSatisfys.3
        )
    }
    
    
    
}

