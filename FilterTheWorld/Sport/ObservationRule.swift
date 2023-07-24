

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
    
//    TODO: 基于物体的规则添加0值
    init(ruleId: String) {
        self.id = ruleId
        self.objectLabel = ObjectLabel(rawValue: ruleId)!
    }
    
    // 物体位置相对于关节点
    var objectToLandmark: [ObjectToLandmark] = []
    
    // 物体位置相对于物体位置
    var objectToObject: [ObjectToObject] = []
    
    
    // 物体相对于自身最大位移
    var objectToStateDistance: [ObjectToStateDistance] = []
    
    var objectToStateAngle: [ObjectToStateAngle] = []
    
    func firstObjectToLandmarkIndexById(id: UUID) -> Int? {
        objectToLandmark.firstIndex(where: { _objectToLandmark in
            _objectToLandmark.id == id
            
        })
    }
    
    mutating func updateRuleObjectToLandmark(objectPosition: ObjectPosition,
                                             objectPoint: Point2D,
                                             fromAxis: CoordinateAxis,
                                             toLandmark: Landmark,
                                             toLandmarkSegment: LandmarkSegment,
                                             toAxis: CoordinateAxis,
                                             lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, id: UUID, isRelativeToObject: Bool) {
        if let index = self.firstObjectToLandmarkIndexById(id: id) {
            
            
            objectToLandmark[index].warning.content = warningContent
            objectToLandmark[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            objectToLandmark[index].warning.delayTime = delayTime
            objectToLandmark[index].warning.changeStateClear = changeStateClear

            objectToLandmark[index].lowerBound = lowerBound
            objectToLandmark[index].upperBound = upperBound
            
            objectToLandmark[index].fromPosition.point = objectPoint
            objectToLandmark[index].fromPosition.axis = fromAxis
            objectToLandmark[index].fromPosition.position = objectPosition
            
            
            objectToLandmark[index].toLandmark = toLandmark
            objectToLandmark[index].toLandmarkSegmentToAxis = LandmarkSegmentToAxis(landmarkSegment: toLandmarkSegment, axis: toAxis)
            objectToLandmark[index].isRelativeToObject = isRelativeToObject
            
            
        }
        
    }
    
    func firstObjectToObjectIndexById(id: UUID) -> Int? {
        objectToObject.firstIndex(where: { _objectToObject in
            _objectToObject.id == id
            
        })
    }
    
    
    mutating func updateRuleObjectToObject(fromAxis: CoordinateAxis, fromObjectPosition: ObjectPosition, fromObject: Observation, toObject: Observation, toObjectPosition: ObjectPosition, toLandmarkSegment: LandmarkSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID, isRelativeToObject: Bool) {
        if let index = self.firstObjectToObjectIndexById(id: id) {
            
            let fromObjectPoint = fromObject.rect.pointOf(position: fromObjectPosition).point2d
            let toObjectPoint = toObject.rect.pointOf(position: toObjectPosition).point2d
            
            objectToObject[index].warning.content = warningContent
            objectToObject[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            objectToObject[index].warning.delayTime = delayTime
            objectToObject[index].warning.changeStateClear = changeStateClear

            objectToObject[index].lowerBound = lowerBound
            objectToObject[index].upperBound = upperBound
            
            
            objectToObject[index].fromPosition.point = fromObjectPoint
            objectToObject[index].fromPosition.position = fromObjectPosition
            objectToObject[index].fromPosition.axis = fromAxis
            
            
            objectToObject[index].toPosition.point = toObjectPoint
            objectToObject[index].toPosition.id = toObject.label
            objectToObject[index].toPosition.position = toObjectPosition
            objectToObject[index].toPosition.axis = fromAxis
            
            
            objectToObject[index].toLandmarkSegmentToAxis = LandmarkSegmentToAxis(landmarkSegment: toLandmarkSegment, axis: toAxis)
            objectToObject[index].isRelativeToObject = isRelativeToObject
            
            
        }
    }
    
    
    
    func firstObjectToStateDistanceIndexById(id: UUID) -> Int? {
        objectToStateDistance.firstIndex(where: { _objectToState in
            _objectToState.id == id
            
        })
    }
    
    
    mutating func updateRuleObjectToStateDistance(
        fromAxis: CoordinateAxis,
        toStateId: Int,
        fromPosition: ObjectPosition,
        fromObject: Observation,
        toObject: Observation,
        isRelativeToObject: Bool,
        isRelativeToExtremeDirection: Bool,
        extremeDirection: ExtremeDirection,
        toLandmarkSegment: LandmarkSegment,
        toAxis: CoordinateAxis,
        lowerBound: Double, upperBound: Double,
        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID){
            if let index = self.firstObjectToStateDistanceIndexById(id: id) {
                
                objectToStateDistance[index].warning.content = warningContent
                objectToStateDistance[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
                objectToStateDistance[index].warning.delayTime = delayTime
                objectToStateDistance[index].warning.changeStateClear = changeStateClear

                objectToStateDistance[index].lowerBound = lowerBound
                objectToStateDistance[index].upperBound = upperBound
                
                objectToStateDistance[index].fromPosition.point = fromObject.rect.pointOf(position: fromPosition).point2d
                objectToStateDistance[index].fromPosition.position = fromPosition
                objectToStateDistance[index].fromPosition.axis = fromAxis
                
                objectToStateDistance[index].toPosition.point = toObject.rect.pointOf(position: fromPosition).point2d
                objectToStateDistance[index].toPosition.position = fromPosition
                objectToStateDistance[index].toPosition.axis = fromAxis
                
                objectToStateDistance[index].isRelativeToObject = isRelativeToObject
                objectToStateDistance[index].isRelativeToExtremeDirection = isRelativeToExtremeDirection
                objectToStateDistance[index].extremeDirection = extremeDirection
                objectToStateDistance[index].toStateId = toStateId
                objectToStateDistance[index].toLandmarkSegmentToAxis.landmarkSegment = toLandmarkSegment
                objectToStateDistance[index].toLandmarkSegmentToAxis.axis = toAxis
                
            }
            
        }
    
    
    func firstObjectToStateAngleIndexById(id: UUID) -> Int? {
        objectToStateAngle.firstIndex(where: { _objectToStateAngle in
            _objectToStateAngle.id == id
            
        })
    }
    
    
    mutating func updateRuleObjectToStateAngle(
        toStateId: Int,
        fromPosition: ObjectPosition,
        fromObject: Observation,
        toObject: Observation,
        isRelativeToExtremeDirection: Bool,
        extremeDirection: ExtremeDirection,
        lowerBound: Double, upperBound: Double,
        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID){
            if let index = self.firstObjectToStateAngleIndexById(id: id) {
                
                objectToStateAngle[index].warning.content = warningContent
                objectToStateAngle[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
                objectToStateAngle[index].warning.delayTime = delayTime
                objectToStateAngle[index].warning.changeStateClear = changeStateClear

                objectToStateAngle[index].lowerBound = lowerBound
                objectToStateAngle[index].upperBound = upperBound
                
                objectToStateAngle[index].fromPosition.point = fromObject.rect.pointOf(position: fromPosition).point2d
                objectToStateAngle[index].fromPosition.position = fromPosition
                objectToStateAngle[index].fromPosition.axis = .X
                
                objectToStateAngle[index].toPosition.point = toObject.rect.pointOf(position: fromPosition).point2d
                objectToStateAngle[index].toPosition.position = fromPosition
                objectToStateAngle[index].toPosition.axis = .X
                
                objectToStateAngle[index].isRelativeToExtremeDirection = isRelativeToExtremeDirection
                objectToStateAngle[index].extremeDirection = extremeDirection
                objectToStateAngle[index].toStateId = toStateId
                
            }
            
        }
    
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, lastPoseMap: PoseMap,objects: [Observation], frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int) {
        
        let objectToLandmarkSatisfys = objectToLandmark.reduce((true, Set<Warning>(), 0, 0), {result, next in
            var satisfy = false
            let selectedObject = objects.first(where: { _object in
                _object.label == next.fromPosition.id
            })
            
            if selectedObject != nil {
                satisfy = next.satisfy(poseMap: poseMap, object: selectedObject!)
            }
            
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
        
        let objectToObjectSatisfys = objectToObject.reduce((true, Set<Warning>(), 0, 0), {result, next in
            var satisfy = false
            
            let selectedFromObject = objects.first(where: { _object in
                _object.label == next.fromPosition.id
            })
            
            let selectedToObject = objects.first(where: { _object in
                _object.label == next.toPosition.id
            })
            
            if selectedFromObject != nil && selectedToObject != nil {
                satisfy = next.satisfy(poseMap: poseMap, fromObject: selectedFromObject!, toObject: selectedToObject!)
            }

            
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
        
        let objectToStateDistanceSatisfys = objectToStateDistance.reduce((true, Set<Warning>(), 0, 0), {result, next in
            var satisfy = false
            
            let selectedObject = objects.first(where: { _object in
                _object.label == next.fromPosition.id
            })
            
            if selectedObject != nil {
                satisfy = next.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: selectedObject!)
            }
            

            
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
        
        let objectToStateAngleSatisfys = objectToStateAngle.reduce((true, Set<Warning>(), 0, 0), {result, next in
            var satisfy = false
            
            let selectedObject = objects.first(where: { _object in
                _object.label == next.fromPosition.id
            })
            
            if selectedObject != nil {
                satisfy = next.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: selectedObject!)
            }
            
//            if let object = object {
//                satisfy = next.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object)
//            } else {
//                satisfy = false
//            }
            
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
        
        // 每个规则至少要包含一个条件 且所有条件都必须满足
        return (objectToLandmarkSatisfys.0 && objectToObjectSatisfys.0 && objectToStateDistanceSatisfys.0 &&
                objectToStateAngleSatisfys.0,
                objectToLandmarkSatisfys.1.union(objectToObjectSatisfys.1).union(objectToStateDistanceSatisfys.1)
            .union(objectToStateAngleSatisfys.1),
                objectToLandmarkSatisfys.2 + objectToObjectSatisfys.2 + objectToStateDistanceSatisfys.2
                + objectToStateAngleSatisfys.2,
                objectToLandmarkSatisfys.3 + objectToObjectSatisfys.3 + objectToStateDistanceSatisfys.3
                + objectToStateAngleSatisfys.3)
    }
    
    
    func allSatisfyWithScore(stateTimeHistory: [StateTime], poseMap: PoseMap, objects: [Observation], frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int, [Double]) {
        
        let objectToLandmarkSatisfys = objectToLandmark.reduce((true, Set<Warning>(), 0, 0, [Double]()), {result, next in
            var satisfy = (false, 0.0)
            let selectedObject = objects.first(where: { _object in
                _object.label == next.fromPosition.id
            })
            
            if selectedObject != nil {
                satisfy = next.satisfyWithScore(poseMap: poseMap, object: selectedObject!)
            }
            
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
        
        let objectToObjectSatisfys = objectToObject.reduce((true, Set<Warning>(), 0, 0, [Double]()), {result, next in
            var satisfy = (false, 0.0)
            
            let selectedFromObject = objects.first(where: { _object in
                _object.label == next.fromPosition.id
            })
            
            let selectedToObject = objects.first(where: { _object in
                _object.label == next.toPosition.id
            })
            
            if selectedFromObject != nil && selectedToObject != nil {
                satisfy = next.satisfyWithScore(poseMap: poseMap, fromObject: selectedFromObject!, toObject: selectedToObject!)
            }

            
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
        
        let objectToStateDistanceSatisfys = objectToStateDistance.reduce((true, Set<Warning>(), 0, 0, [Double]()), {result, next in
            var satisfy = (false, 0.0)
            
            let selectedObject = objects.first(where: { _object in
                _object.label == next.fromPosition.id
            })
            
            if selectedObject != nil {
                satisfy = next.satisfyWithScore(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: selectedObject!)
            }
            

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
        
        let objectToStateAngleSatisfys = objectToStateAngle.reduce((true, Set<Warning>(), 0, 0, [Double]()), {result, next in
            var satisfy = (false, 0.0)
            
            let selectedObject = objects.first(where: { _object in
                _object.label == next.fromPosition.id
            })
            
            if selectedObject != nil {
                satisfy = next.satisfyWithScore(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: selectedObject!)
            }
            
//            if let object = object {
//                satisfy = next.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object)
//            } else {
//                satisfy = false
//            }
            
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
        
        // 每个规则至少要包含一个条件 且所有条件都必须满足
        return (objectToLandmarkSatisfys.0 && objectToObjectSatisfys.0 && objectToStateDistanceSatisfys.0 &&
                objectToStateAngleSatisfys.0,
                objectToLandmarkSatisfys.1.union(objectToObjectSatisfys.1).union(objectToStateDistanceSatisfys.1)
            .union(objectToStateAngleSatisfys.1),
                objectToLandmarkSatisfys.2 + objectToObjectSatisfys.2 + objectToStateDistanceSatisfys.2
                + objectToStateAngleSatisfys.2,
                objectToLandmarkSatisfys.3 + objectToObjectSatisfys.3 + objectToStateDistanceSatisfys.3
                + objectToStateAngleSatisfys.3,
                objectToLandmarkSatisfys.4 + objectToObjectSatisfys.4 + objectToStateDistanceSatisfys.4
                + objectToStateAngleSatisfys.4
        )
    }
    
    
    
    
    
    
}
