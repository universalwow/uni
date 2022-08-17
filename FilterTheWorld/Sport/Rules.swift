

import Foundation

struct Rules: Identifiable, Hashable, Codable {
    var id = UUID()
    
    // 合并成Ruler 不符合 Codable 协议
    var landmarkSegmentRules: [LandmarkSegmentRule] = []
    var landmarkRules: [LandmarkRule] = []
    var observationRules: [ObservationRule] = []
    
    var description:String = ""
    
    static func == (lhs: Rules, rhs: Rules) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D)  -> (Bool, Set<Warning>, Int, Int) {
        
        let landmarkSegmentRulesSatisfy = landmarkSegmentRules.reduce((true, Set<Warning>(), 0, 0), { result, next in
            let satisfy = next.allSatisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
            return (result.0 && satisfy.0,
                    result.1.union(satisfy.1),
                    result.2 + satisfy.2,
                    result.3 + satisfy.3)
        })
        
        let landmarkRulesSatisfy = landmarkRules.reduce((true, Set<Warning>(), 0, 0), { result, next in
            let satisfy = next.allSatisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
            return (result.0 && satisfy.0,
                    result.1.union(satisfy.1),
                    result.2 + satisfy.2,
                    result.3 + satisfy.3)
        })
        
        let observationRuleSatisfy = observationRules.reduce((true, Set<Warning>(), 0, 0), { result, next in
            let satisfy = next.allSatisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
            return (result.0 && satisfy.0,
                    result.1.union(satisfy.1),
                    result.2 + satisfy.2,
                    result.3 + satisfy.3)
        })
        
        return (landmarkSegmentRulesSatisfy.0 && landmarkRulesSatisfy.0 && observationRuleSatisfy.0,
                landmarkSegmentRulesSatisfy.1.union(landmarkRulesSatisfy.1).union(observationRuleSatisfy.1),
                landmarkSegmentRulesSatisfy.2 + landmarkRulesSatisfy.2 + observationRuleSatisfy.2,
                landmarkSegmentRulesSatisfy.3 + landmarkRulesSatisfy.3 + observationRuleSatisfy.3)
    }
    
    func firstIndexOfRule(editedRule: Ruler, ruleClass: RuleClass) -> Int? {
        switch ruleClass {
            case .LandmarkSegment:
                return landmarkSegmentRules.firstIndex(where: { rule in
                    editedRule.id == rule.id
                })
            case .Landmark:
                return landmarkRules.firstIndex(where: { rule in
                    editedRule.id == rule.id
                })
            case .Observation:
                return observationRules.firstIndex(where: { rule in
                    editedRule.id == rule.id
                })
        }

    }
    
    
    func firstIndexOfRule(editedRuleId: String, ruleClass: RuleClass) -> Int? {
        switch ruleClass {
            case .LandmarkSegment:
                return landmarkSegmentRules.firstIndex(where: { rule in
                    editedRuleId == rule.id
                })
            case .Landmark:
                return landmarkRules.firstIndex(where: { rule in
                    editedRuleId == rule.id
                })
            case .Observation:
                return observationRules.firstIndex(where: { rule in
                    editedRuleId == rule.id
                })
        }

    }
    
    func findFirstRule(ruleId: String, ruleClass: RuleClass) -> Ruler? {
        if let firstIndex = firstIndexOfRule(editedRuleId: ruleId, ruleClass: ruleClass) {
            switch ruleClass {
            case .LandmarkSegment:
                return landmarkSegmentRules[firstIndex]
            case .Landmark:
                return landmarkRules[firstIndex]
            case .Observation:
                return observationRules[firstIndex]
            }
        }
        return nil
    }
    
    
    mutating func updateRule(editedRule: Ruler, ruleClass: RuleClass) {
        if let firstIndex = firstIndexOfRule(editedRule: editedRule, ruleClass: ruleClass) {
            switch ruleClass {
            
            case .LandmarkSegment:
                landmarkSegmentRules[firstIndex] = editedRule as! LandmarkSegmentRule
            case .Landmark:
                landmarkRules[firstIndex] = editedRule as! LandmarkRule
            case .Observation:
                observationRules[firstIndex] = editedRule as! ObservationRule
            }
        } else {
            switch ruleClass {
            
            case .LandmarkSegment:
                landmarkSegmentRules.append(editedRule as! LandmarkSegmentRule)
            case .Landmark:
                landmarkRules.append(editedRule as! LandmarkRule)
            case .Observation:
                observationRules.append(editedRule as! ObservationRule)
            }
        }
        
    }
    
    
    
    
    mutating func addRule(ruleId: String, ruleClass: RuleClass) {
        switch ruleClass {
        case .LandmarkSegment:
            landmarkSegmentRules.append(LandmarkSegmentRule(ruleId: ruleId))
        case .Landmark:
            landmarkRules.append(LandmarkRule(ruleId: ruleId))
        case .Observation:
            observationRules.append(ObservationRule(ruleId: ruleId))
        }
    }
    
    mutating func deleteRule(ruleId: String, ruleClass: RuleClass) {
        let firstIndex = firstIndexOfRule(editedRuleId: ruleId, ruleClass: ruleClass)!
        switch ruleClass {
        case .LandmarkSegment:
            landmarkSegmentRules.remove(at: firstIndex)
        case .Landmark:
            landmarkRules.remove(at: firstIndex)
        case .Observation:
            observationRules.remove(at: firstIndex)
        }
    }
    
    
    func findFirstRulerByRuleId(ruleId: String, ruleClass: RuleClass) -> Int? {
        switch ruleClass {
        case .LandmarkSegment:
            return landmarkSegmentRules.firstIndex(where: { landmarkSegmentRule in
                landmarkSegmentRule.id == ruleId
            })
        case .Landmark:
            return landmarkRules.firstIndex(where: { landmarkRule in
                landmarkRule.id == ruleId
            })
        case .Observation:
            return observationRules.firstIndex(where: { observationRule in
                observationRule.id == ruleId
            })
        }
    }
    
    mutating func addRuleLandmarkSegmentAngle(ruleId: String, ruleClass: RuleClass, landmarkSegments: [LandmarkSegment]) {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            let landmarkSegment = landmarkSegments.first(where: { landmarkSegment in
                landmarkSegment.id == ruleId
            })!
            landmarkSegmentRules[ruleIndex].angle.append(
                AngleRange(landmarkSegment: landmarkSegment, warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2)))
        }
    }
    
    func getRuleLandmarkSegmentAngles(ruleId: String, ruleClass: RuleClass) -> [AngleRange] {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            return landmarkSegmentRules[ruleIndex].angle
        }
        return []
    }
    
    func getRuleLandmarkSegmentAngle(ruleId: String, ruleClass: RuleClass, id: UUID) -> AngleRange {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        return landmarkSegmentRules[ruleIndex].angle.first(where: { angle in
            angle.id == id
            
        })!
    }
    
    mutating func removeRuleLandmarkSegmentAngle(ruleId: String, ruleClass: RuleClass, id: UUID) {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        landmarkSegmentRules[ruleIndex].angle.removeAll(where: { angle in
            angle.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkSegmentAngle(ruleId: String, ruleClass: RuleClass, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, lowerBound: Double, upperBound: Double, id: UUID) {
        
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
            landmarkSegmentRules[ruleIndex].updateRuleLandmarkSegmentAngle(warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, lowerBound: lowerBound, upperBound: upperBound, id: id)
        

        }
    }
    
    
//    ---------------------------
    func getRuleAngleToLandmarkSegments(ruleId: String, ruleClass: RuleClass) -> [AngleToLandmarkSegment] {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            return landmarkSegmentRules[ruleIndex].angleToLandmarkSegment
        }
        return []
    }
    
    func getRuleAngleToLandmarkSegment(ruleId: String, ruleClass: RuleClass, id: UUID) -> AngleToLandmarkSegment {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        return landmarkSegmentRules[ruleIndex].angleToLandmarkSegment.first(where: { angle in
            angle.id == id
        })!
    }
    
    mutating func addRuleAngleToLandmarkSegment(ruleId: String, ruleClass: RuleClass, landmarkSegments: [LandmarkSegment]) {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            let landmarkSegment = landmarkSegments.first(where: { landmarkSegment in
                landmarkSegment.id == ruleId
            })!
            landmarkSegmentRules[ruleIndex].angleToLandmarkSegment.append(
                AngleToLandmarkSegment(
                    from: landmarkSegment,
                    to: landmarkSegment,
                    warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2))
            )
        }
    }
    
    
    mutating func removeRuleAngleToLandmarkSegment(ruleId: String, ruleClass: RuleClass, id: UUID) {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        landmarkSegmentRules[ruleIndex].angleToLandmarkSegment.removeAll(where: { angle in
            angle.id == id
            
        })
    }
    
    mutating func updateRuleAngleToLandmarkSegment(ruleId: String, ruleType: RuleType, ruleClass: RuleClass, tolandmarkSegmentType: LandmarkTypeSegment, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,  id: UUID, landmarkSegments: [LandmarkSegment]) {
        let fromLandmarkSegment = landmarkSegments.first(where: { landmarkSegment in
            landmarkSegment.id == ruleId
        })!
        let toLandmarkSegment = landmarkSegments.first(where: { landmarkSegment in
            landmarkSegment.id == tolandmarkSegmentType.id
        })!
        
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
            landmarkSegmentRules[ruleIndex].updateRuleAngleToLandmarkSegment(fromLandmarkSegment: fromLandmarkSegment, toLandmarkSegment: toLandmarkSegment, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)
        

        }
    }
    
//    --------------
    mutating func transferRuleTo(rule: Ruler) {
        switch rule.ruleClass {
        case .LandmarkSegment:
            self.transferToLandmarkSegmentRules(rule: rule as! LandmarkSegmentRule)
        case .Landmark:
            self.transferToLandmarkRules(rule: rule as! LandmarkRule)
        case .Observation:
            self.transferToObservationRules(rule: rule as! ObservationRule)
        }
        
    }
    
    mutating func transferToLandmarkSegmentRules(rule: LandmarkSegmentRule) {
        if let index = landmarkSegmentRules.firstIndex(where: { landmarkSegmentRule in
            landmarkSegmentRule.id == rule.id
        }) {
            landmarkSegmentRules[index] = rule
        }else {
            landmarkSegmentRules.append(rule)
        }
    }
    
    mutating func transferToLandmarkRules(rule: LandmarkRule) {
        if let index = landmarkRules.firstIndex(where: { landmarkRule in
            landmarkRule.id == rule.id
        }) {
            landmarkRules[index] = rule
        }else {
            landmarkRules.append(rule)
        }
    }
    
    mutating func transferToObservationRules(rule: ObservationRule) {
        if let index = landmarkRules.firstIndex(where: { observationRule in
            observationRule.id == rule.id
        }) {
            observationRules[index] = rule
        }else {
            observationRules.append(rule)
        }
    }
 
    
}

