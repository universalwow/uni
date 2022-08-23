

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
    var objectToLandmark: [ObjectToLandmark] = []
    
    // 物体位置相对于物体位置
    var objectToObject: [ObjectToObject] = []
    
    // 物体相对于自身最大位移
    var objectToSelf: [ObjectToSelf] = []
    // 物体相对于自身最大位移
    var objectToState: [ObjectToStateExtreme] = []
    
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
                                             lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID, isRelativeToObject: Bool) {
        if let index = self.firstObjectToLandmarkIndexById(id: id) {
            
            
            objectToLandmark[index].warning.content = warningContent
            objectToLandmark[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            objectToLandmark[index].warning.delayTime = delayTime
            
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
    
    
    mutating func updateRuleObjectToObject(fromAxis: CoordinateAxis, fromObjectPosition: ObjectPosition, fromObject: Observation, toObject: Observation, toObjectPosition: ObjectPosition, toLandmarkSegment: LandmarkSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID, isRelativeToObject: Bool) {
        if let index = self.firstObjectToObjectIndexById(id: id) {
            
            let fromObjectPoint = fromObject.rect.pointOf(position: fromObjectPosition).point2d
            let toObjectPoint = toObject.rect.pointOf(position: toObjectPosition).point2d
            
            objectToObject[index].warning.content = warningContent
            objectToObject[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            objectToObject[index].warning.delayTime = delayTime
            
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
    
    func firstObjectToSelfIndexById(id: UUID) -> Int? {
        objectToSelf.firstIndex(where: { _objectToSelf in
            _objectToSelf.id == id
            
        })
    }
    
    mutating func updateRuleObjectToSelf(direction: Direction, xLowerBound: Double, yLowerBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID) {
        if let index = self.firstObjectToSelfIndexById(id: id) {
            

            objectToSelf[index].warning.content = warningContent
            objectToSelf[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
            objectToSelf[index].warning.delayTime = delayTime
            
            objectToSelf[index].xLowerBound = xLowerBound
            objectToSelf[index].yLowerBound = yLowerBound
            
            objectToSelf[index].toDirection = direction
        }
    }
    
    func firstObjectToStateExtremeIndexById(id: UUID) -> Int? {
        objectToState.firstIndex(where: { _objectToState in
            _objectToState.id == id
            
        })
    }
    
    
    mutating func updateRuleObjectToStateExtreme(
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
        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID){
            if let index = self.firstObjectToStateExtremeIndexById(id: id) {
                
                objectToState[index].warning.content = warningContent
                objectToState[index].warning.triggeredWhenRuleMet = triggeredWhenRuleMet
                objectToState[index].warning.delayTime = delayTime
                
                objectToState[index].lowerBound = lowerBound
                objectToState[index].upperBound = upperBound
                
                objectToState[index].fromPosition.point = fromObject.rect.pointOf(position: fromPosition).point2d
                objectToState[index].fromPosition.position = fromPosition
                objectToState[index].fromPosition.axis = fromAxis
                
                objectToState[index].toPosition.point = toObject.rect.pointOf(position: fromPosition).point2d
                objectToState[index].toPosition.position = fromPosition
                objectToState[index].toPosition.axis = fromAxis
                
                objectToState[index].isRelativeToObject = isRelativeToObject
                objectToState[index].isRelativeToExtremeDirection = isRelativeToExtremeDirection
                objectToState[index].extremeDirection = extremeDirection
                objectToState[index].toStateId = toStateId
                objectToState[index].toLandmarkSegmentToAxis.landmarkSegment = toLandmarkSegment
                objectToState[index].toLandmarkSegmentToAxis.axis = toAxis


                
            }
            
        }
    
    
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
        
        let objectToLandmarkSatisfys = objectToLandmark.reduce((true, Set<Warning>(), 0, 0), {result, next in
            var satisfy = false
            if let object = object {
                satisfy = self.objectToLandmarkSatisfy(objectToLandmark: next, poseMap: poseMap, object: object)
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
                    result.2 + 1)
        })
        
        let objectToObjectSatisfys = objectToObject.reduce((true, Set<Warning>(), 0, 0), {result, next in
            var satisfy = false
            if let object = object, let targetObject = targetObject {
                satisfy = self.objectToObjectSatisfy(objectToObject: next, poseMap: poseMap, object: object, targetObject: targetObject)
            } else {
                satisfy = false
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
            }else if !next.warning.triggeredWhenRuleMet && !satisfy {
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
