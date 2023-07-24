

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
    
    var landmarkSegmentAngle:[LandmarkSegmentAngle] = []
    // 相对长度
    var landmarkSegmentLength: [LandmarkSegmentLength] = []
    
    var angleToLandmarkSegment: [AngleToLandmarkSegment] = []
    var landmarkSegmentToStateAngle: [LandmarkSegmentToStateAngle] = []
    var landmarkSegmentToStateDistance: [LandmarkSegmentToStateDistance] = []
    
    func firstAngleIndexById(id: UUID) -> Int? {
        landmarkSegmentAngle.firstIndex(where: { _angle in
            _angle.id == id
        })
    }
    
    func firstAngleToLandmarkSegmentIndexById(id: UUID) -> Int? {
        angleToLandmarkSegment.firstIndex(where: { _angle in
            _angle.id == id
        })
    }
    

    
    mutating func updateRuleLandmarkSegmentAngle(warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, lowerBound: Double, upperBound: Double, id: UUID) {
        if let angleIndex = self.firstAngleIndexById(id: id) {
            landmarkSegmentAngle[angleIndex].warning.content = warningContent
            landmarkSegmentAngle[angleIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            landmarkSegmentAngle[angleIndex].warning.delayTime = delayTime
            landmarkSegmentAngle[angleIndex].warning.changeStateClear = changeStateClear

            landmarkSegmentAngle[angleIndex].lowerBound = lowerBound
            landmarkSegmentAngle[angleIndex].upperBound = upperBound
        }
        
    }
    
    mutating func updateRuleAngleToLandmarkSegment(fromLandmarkSegment: LandmarkSegment, toLandmarkSegment: LandmarkSegment, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
        if let angleIndex = self.firstAngleToLandmarkSegmentIndexById(id: id) {
            
            angleToLandmarkSegment[angleIndex].warning.content = warningContent
            angleToLandmarkSegment[angleIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            angleToLandmarkSegment[angleIndex].warning.delayTime = delayTime
            angleToLandmarkSegment[angleIndex].warning.changeStateClear = changeStateClear

            angleToLandmarkSegment[angleIndex].lowerBound = lowerBound
            angleToLandmarkSegment[angleIndex].upperBound = upperBound
            
            angleToLandmarkSegment[angleIndex].from = fromLandmarkSegment
            angleToLandmarkSegment[angleIndex].to = toLandmarkSegment
        }
        
    }
    
    func firstLandmarkSegmentLengthIndexById(id: UUID) -> Int? {
        landmarkSegmentLength.firstIndex(where: { _length in
            _length.id == id
        })
    }
    
    mutating func updateRuleLandmarkSegmentLength(fromLandmarkSegment: LandmarkSegment, fromAxis: CoordinateAxis, toLandmarkSegment: LandmarkSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,  id: UUID) {
        if let lengthIndex = self.firstLandmarkSegmentLengthIndexById(id: id) {
            
            landmarkSegmentLength[lengthIndex].warning.content = warningContent
            landmarkSegmentLength[lengthIndex].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            landmarkSegmentLength[lengthIndex].warning.delayTime = delayTime
            landmarkSegmentLength[lengthIndex].warning.changeStateClear = changeStateClear

            
            landmarkSegmentLength[lengthIndex].lowerBound = lowerBound
            landmarkSegmentLength[lengthIndex].upperBound = upperBound
            
            landmarkSegmentLength[lengthIndex].from = LandmarkSegmentToAxis(landmarkSegment: fromLandmarkSegment, axis: fromAxis)
            landmarkSegmentLength[lengthIndex].to = LandmarkSegmentToAxis(landmarkSegment: toLandmarkSegment, axis: toAxis)
        }
        
    }
    
    func firstLandmarkSegmentToStateAngleIndexById(id: UUID) -> Int? {
        landmarkSegmentToStateAngle.firstIndex(where: { _angle in
            _angle.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkSegmentToStateAngle(
        fromLandmarkSegment: LandmarkSegment,
        toStateId: Int,
        isRelativeToExtremeDirection: Bool,
        extremeDirection: ExtremeDirection,
        toStateLandmarkSegment: LandmarkSegment,
        lowerBound: Double, upperBound: Double,
        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, id: UUID) {
            if let index = self.firstLandmarkSegmentToStateAngleIndexById(id: id) {
                
                landmarkSegmentToStateAngle[index].warning.content = warningContent
                landmarkSegmentToStateAngle[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
                landmarkSegmentToStateAngle[index].warning.delayTime = delayTime
                landmarkSegmentToStateAngle[index].warning.changeStateClear = changeStateClear

                landmarkSegmentToStateAngle[index].lowerBound = lowerBound
                landmarkSegmentToStateAngle[index].upperBound = upperBound
                
                landmarkSegmentToStateAngle[index].fromLandmarkSegment =  fromLandmarkSegment
                landmarkSegmentToStateAngle[index].toLandmarkSegment =  toStateLandmarkSegment
                landmarkSegmentToStateAngle[index].toStateId = toStateId
                landmarkSegmentToStateAngle[index].isRelativeToExtremeDirection = isRelativeToExtremeDirection
                landmarkSegmentToStateAngle[index].extremeDirection = extremeDirection
                
            }
            
        }
    
    func firstLandmarkSegmentToStateDistanceIndexById(id: UUID) -> Int? {
        landmarkSegmentToStateDistance.firstIndex(where: { _distance in
            _distance.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkSegmentToStateDistance(
        fromAxis: CoordinateAxis,
        fromLandmarkSegment: LandmarkSegment,
        toStateId: Int,
        isRelativeToExtremeDirection: Bool,
        extremeDirection: ExtremeDirection,
        toStateLandmarkSegment: LandmarkSegment,
        lowerBound: Double, upperBound: Double,
        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
            if let index = self.firstLandmarkSegmentToStateDistanceIndexById(id: id) {
                
                landmarkSegmentToStateDistance[index].warning.content = warningContent
                landmarkSegmentToStateDistance[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
                landmarkSegmentToStateDistance[index].warning.delayTime = delayTime
                landmarkSegmentToStateDistance[index].warning.changeStateClear = changeStateClear

                landmarkSegmentToStateDistance[index].lowerBound = lowerBound
                landmarkSegmentToStateDistance[index].upperBound = upperBound
                
                landmarkSegmentToStateDistance[index].fromAxis =  fromAxis
                landmarkSegmentToStateDistance[index].fromLandmarkSegment =  fromLandmarkSegment
                landmarkSegmentToStateDistance[index].toLandmarkSegment =  toStateLandmarkSegment
                landmarkSegmentToStateDistance[index].toStateId = toStateId
                landmarkSegmentToStateDistance[index].isRelativeToExtremeDirection = isRelativeToExtremeDirection
                landmarkSegmentToStateDistance[index].extremeDirection = extremeDirection
                
            }
            
        }
    
    
    
    
    
    
    // 是否满足， 收集提醒， 满足的数目， 总规则数
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, lastPoseMap: PoseMap, objects: [Observation], frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int) {
        // 单帧
        
        
        let landmarkSegmentLengthSatisfys = landmarkSegmentLength.reduce((true, Set<Warning>(), 0, 0), {result, next in
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
                    result.3 + 1)
        })
        
        let landmarkSegmentAngleSatisfys = landmarkSegmentAngle.reduce((true, Set<Warning>(), 0, 0), {result, next in
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
                    result.3 + 1)
        })
        
        let angleToLandmarkSegmentSatisfys = angleToLandmarkSegment.reduce((true, Set<Warning>(), 0, 0), {result, next in
            
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
                    result.3 + 1)
        })
        
        let landmarkSegmentToStateAngleSatisfys = landmarkSegmentToStateAngle.reduce((true, Set<Warning>(), 0, 0), {result, next in
            
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
                    result.3 + 1)
        })
        
        let landmarkSegmentToStateDistanceSatisfys = landmarkSegmentToStateDistance.reduce((true, Set<Warning>(), 0, 0), {result, next in
            
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
                    result.3 + 1)
        })
        
        
        return (landmarkSegmentLengthSatisfys.0 && landmarkSegmentAngleSatisfys.0 && angleToLandmarkSegmentSatisfys.0 && landmarkSegmentToStateAngleSatisfys.0 && landmarkSegmentToStateDistanceSatisfys.0,
                landmarkSegmentLengthSatisfys.1.union(landmarkSegmentAngleSatisfys.1).union(angleToLandmarkSegmentSatisfys.1).union(landmarkSegmentToStateAngleSatisfys.1).union(landmarkSegmentToStateDistanceSatisfys.1),
                landmarkSegmentLengthSatisfys.2 + landmarkSegmentAngleSatisfys.2 + angleToLandmarkSegmentSatisfys.2 + landmarkSegmentToStateAngleSatisfys.2 + landmarkSegmentToStateDistanceSatisfys.2,
                landmarkSegmentLengthSatisfys.3 + landmarkSegmentAngleSatisfys.3 + angleToLandmarkSegmentSatisfys.3 + landmarkSegmentToStateAngleSatisfys.3 + landmarkSegmentToStateDistanceSatisfys.3)
    }
    
    
    // 是否满足， 收集提醒， 满足的数目， 总规则数
    func allSatisfyWithScore(stateTimeHistory: [StateTime], poseMap: PoseMap, objects: [Observation], frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int, [Double]) {
        // 单帧
        
        
        let landmarkSegmentLengthSatisfys = landmarkSegmentLength.reduce((true, Set<Warning>(), 0, 0, [Double]()), {result, next in
            let satisfy = next.satisfyWithScore(poseMap: poseMap)
            
            var newWarnings = result.1
            
            if next.warning.triggeredWhenRuleMet && satisfy.0 {
                newWarnings.insert(next.warning)
            }else if !next.warning.triggeredWhenRuleMet && !satisfy.0 {
                newWarnings.insert(next.warning)
            }
            
            return (result.0 && satisfy.0,
                    newWarnings,
                    satisfy.0 ? result.2 + 1 : result.2,
                    result.3 + 1, result.4 + [satisfy.1])
        })
        
        let landmarkSegmentAngleSatisfys = landmarkSegmentAngle.reduce((true, Set<Warning>(), 0, 0, [Double]()), {result, next in
            let satisfy = next.satisfyWithScore(poseMap: poseMap)
            var newWarnings = result.1
            
            if next.warning.triggeredWhenRuleMet && satisfy.0 {
                newWarnings.insert(next.warning)
            }else if !next.warning.triggeredWhenRuleMet && !satisfy.0 {
                newWarnings.insert(next.warning)
            }
            
            return (result.0 && satisfy.0,
                    newWarnings,
                    satisfy.0 ? result.2 + 1 : result.2,
                    result.3 + 1, result.4 + [satisfy.1])
        })
        
        let angleToLandmarkSegmentSatisfys = angleToLandmarkSegment.reduce((true, Set<Warning>(), 0, 0, [Double]()), {result, next in
            
            let satisfy = next.satisfyWithScore(poseMap: poseMap)
            
            var newWarnings = result.1
            
            if next.warning.triggeredWhenRuleMet && satisfy.0 {
                newWarnings.insert(next.warning)
            }else if !next.warning.triggeredWhenRuleMet && !satisfy.0 {
                newWarnings.insert(next.warning)
            }
            
            return (result.0 && satisfy.0,
                    newWarnings,
                    satisfy.0 ? result.2 + 1 : result.2,
                    result.3 + 1, result.4 + [satisfy.1])
        })
        
        let landmarkSegmentToStateAngleSatisfys = landmarkSegmentToStateAngle.reduce((true, Set<Warning>(), 0, 0, [Double]()), {result, next in
            
            let satisfy = next.satisfyWithScore(stateTimeHistory: stateTimeHistory, poseMap: poseMap)
            
            var newWarnings = result.1
            
            if next.warning.triggeredWhenRuleMet && satisfy.0 {
                newWarnings.insert(next.warning)
            }else if !next.warning.triggeredWhenRuleMet && !satisfy.0 {
                newWarnings.insert(next.warning)
            }
            
            return (result.0 && satisfy.0,
                    newWarnings,
                    satisfy.0 ? result.2 + 1 : result.2,
                    result.3 + 1, result.4 + [satisfy.1])
        })
        
        let landmarkSegmentToStateDistanceSatisfys = landmarkSegmentToStateDistance.reduce((true, Set<Warning>(), 0, 0, [Double]()), {result, next in
            
            let satisfy = next.satisfyWithScore(stateTimeHistory: stateTimeHistory, poseMap: poseMap)
            
            var newWarnings = result.1
            
            if next.warning.triggeredWhenRuleMet && satisfy.0 {
                newWarnings.insert(next.warning)
            }else if !next.warning.triggeredWhenRuleMet && !satisfy.0 {
                newWarnings.insert(next.warning)
            }
            
            return (result.0 && satisfy.0,
                    newWarnings,
                    satisfy.0 ? result.2 + 1 : result.2,
                    result.3 + 1, result.4 + [satisfy.1])
        })
        
        
        return (landmarkSegmentLengthSatisfys.0 && landmarkSegmentAngleSatisfys.0 && angleToLandmarkSegmentSatisfys.0 && landmarkSegmentToStateAngleSatisfys.0 && landmarkSegmentToStateDistanceSatisfys.0,
                landmarkSegmentLengthSatisfys.1.union(landmarkSegmentAngleSatisfys.1).union(angleToLandmarkSegmentSatisfys.1).union(landmarkSegmentToStateAngleSatisfys.1).union(landmarkSegmentToStateDistanceSatisfys.1),
                landmarkSegmentLengthSatisfys.2 + landmarkSegmentAngleSatisfys.2 + angleToLandmarkSegmentSatisfys.2 + landmarkSegmentToStateAngleSatisfys.2 + landmarkSegmentToStateDistanceSatisfys.2,
                landmarkSegmentLengthSatisfys.3 + landmarkSegmentAngleSatisfys.3 + angleToLandmarkSegmentSatisfys.3 + landmarkSegmentToStateAngleSatisfys.3 + landmarkSegmentToStateDistanceSatisfys.3,
                landmarkSegmentLengthSatisfys.4 + landmarkSegmentAngleSatisfys.4 + angleToLandmarkSegmentSatisfys.4 + landmarkSegmentToStateAngleSatisfys.4 + landmarkSegmentToStateDistanceSatisfys.4
        )
    }
    
    
    
}


