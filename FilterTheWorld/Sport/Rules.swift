

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
                LandmarkSegmentAngle(landmarkSegment: landmarkSegment, warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2)))
        }
    }
    
    func getRuleLandmarkSegmentAngles(ruleId: String, ruleClass: RuleClass) -> [LandmarkSegmentAngle] {
        if ruleClass == .LandmarkSegment, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            return landmarkSegmentRules[ruleIndex].angle
        }
        return []
    }
    
    func getRuleLandmarkSegmentAngle(ruleId: String, ruleClass: RuleClass, id: UUID) -> LandmarkSegmentAngle {
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
        if ruleClass == .LandmarkSegment, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
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
    
    mutating func updateRuleAngleToLandmarkSegment(ruleId: String, ruleClass: RuleClass, tolandmarkSegmentType: LandmarkTypeSegment, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,  id: UUID, landmarkSegments: [LandmarkSegment]) {
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
    
    
    func getRuleLandmarkSegmentLengths(ruleId: String, ruleClass: RuleClass) -> [LandmarkSegmentLength] {
        if ruleClass == .LandmarkSegment, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            return landmarkSegmentRules[ruleIndex].length
        }
        return []
    }
    
    func getRuleLandmarkSegmentLength(ruleId: String, ruleClass: RuleClass, id: UUID) -> LandmarkSegmentLength {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        return landmarkSegmentRules[ruleIndex].length.first(where: { length in
            length.id == id
        })!
    }
    
    mutating func addRuleLandmarkSegmentLength(ruleId: String, ruleClass: RuleClass, landmarkSegments: [LandmarkSegment]) {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            let landmarkSegment = landmarkSegments.first(where: { landmarkSegment in
                landmarkSegment.id == ruleId
            })!
            landmarkSegmentRules[ruleIndex].length.append(
                LandmarkSegmentLength(
                    from: LandmarkSegmentToAxis(
                        landmarkSegment:landmarkSegment , axis: .X),
                    to: LandmarkSegmentToAxis(
                        landmarkSegment:landmarkSegment , axis: .X),
                    warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2))
            )
        }
    }
    
    mutating func removeRuleLandmarkSegmentLength(ruleId: String, ruleClass: RuleClass, id: UUID) {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        landmarkSegmentRules[ruleIndex].length.removeAll(where: { length in
            length.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkSegmentLength(ruleId: String, ruleClass: RuleClass, fromAxis: CoordinateAxis,tolandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,  id: UUID, landmarkSegments: [LandmarkSegment]) {
        let fromLandmarkSegment = landmarkSegments.first(where: { landmarkSegment in
            landmarkSegment.id == ruleId
        })!
        let toLandmarkSegment = landmarkSegments.first(where: { landmarkSegment in
            landmarkSegment.id == tolandmarkSegmentType.id
        })!
        
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
            landmarkSegmentRules[ruleIndex].updateRuleLandmarkSegmentLength(fromLandmarkSegment: fromLandmarkSegment, fromAxis: fromAxis, toLandmarkSegment: toLandmarkSegment, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)
        

        }
    }
//    -------------
    
    func getRuleLandmarkToSelfs(ruleId: String, ruleClass: RuleClass) -> [LandmarkToSelf] {
        if ruleClass == .Landmark, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            return landmarkRules[ruleIndex].landmarkToSelf
        }
        return []
    }
    
    func getRuleLandmarkToSelf(ruleId: String, ruleClass: RuleClass, id: UUID) -> LandmarkToSelf {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        return landmarkRules[ruleIndex].landmarkToSelf.first(where: { landmarkToSelf in
            landmarkToSelf.id == id
        })!
    }
    
    mutating func addRuleLandmarkToSelf(ruleId: String, ruleClass: RuleClass, humanPose: HumanPose) {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            let landmark = humanPose.landmarks.first(where: { landmark in
                landmark.id == ruleId
            })!
            let landmarkSegment = humanPose.landmarkSegments.first(where: { landmarkSegment in
                landmarkSegment.id == LandmarkTypeSegment(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder).id
            })!
            landmarkRules[ruleIndex].landmarkToSelf.append(
                LandmarkToSelf(
                    landmarkType: landmark.landmarkType,
                    toDirection: .LEFT,
                    toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: landmarkSegment, axis: .X),
                    xLowerBound: 0, yLowerBound: 0,
                    warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2))
            )

        }
    }
    
    mutating func removeRuleLandmarkToSelf(ruleId: String, ruleClass: RuleClass, id: UUID) {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        landmarkRules[ruleIndex].landmarkToSelf.removeAll(where: { length in
            length.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkToSelf(ruleId: String, ruleClass: RuleClass, direction: Direction, toLandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, xLowerBound: Double, yLowerBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID, landmarkSegments: [LandmarkSegment])  {

        let toLandmarkSegment = landmarkSegments.first(where: { landmarkSegment in
            landmarkSegment.id == toLandmarkSegmentType.id
        })!
        
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
            landmarkRules[ruleIndex].updateRuleLandmarkToSelf(direction: direction, toLandmarkSegment: toLandmarkSegment, toAxis: toAxis, xLowerBound: xLowerBound, yLowerBound: yLowerBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)
        

        }
    }
    
//    --------------
    
    func getRuleLandmarkToStates(ruleId: String, ruleClass: RuleClass) -> [LandmarkToState] {
        if ruleClass == .Landmark, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            return landmarkRules[ruleIndex].landmarkToState
        }
        return []
    }
    
    func getRuleLandmarkToState(ruleId: String, ruleClass: RuleClass, id: UUID) -> LandmarkToState {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        return landmarkRules[ruleIndex].landmarkToState.first(where: { landmarkToState in
            landmarkToState.id == id
        })!
    }
    
    mutating func addRuleLandmarkToState(ruleId: String, ruleClass: RuleClass, humanPose: HumanPose, stateId: Int) {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            let landmark = humanPose.landmarks.first(where: { landmark in
                landmark.id == ruleId
            })!
            let landmarkSegment = humanPose.landmarkSegments.first(where: { landmarkSegment in
                landmarkSegment.id == LandmarkTypeSegment(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder).id
            })!
            landmarkRules[ruleIndex].landmarkToState.append(
                
                LandmarkToState(toStateId: stateId,
                                fromLandmarkToAxis: LandmarkToAxis(landmark: landmark, axis: .X),
                                toLandmarkToAxis: LandmarkToAxis(landmark: landmark, axis: .X),
                                toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: landmarkSegment, axis: .X),
                                warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2)
                               )
                

            )

        }
    }
    
    mutating func removeRuleLandmarkToState(ruleId: String, ruleClass: RuleClass, id: UUID) {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        landmarkRules[ruleIndex].landmarkToState.removeAll(where: { length in
            length.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkToState(ruleId: String,  ruleClass: RuleClass,
                                            fromAxis: CoordinateAxis,
                                            toStateId: Int,
                                            toStateLandmark: Landmark,
                                            toLandmarkSegmentType: LandmarkTypeSegment,
                                            toAxis: CoordinateAxis,
                                            lowerBound: Double, upperBound: Double,
                                            warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID, humanPose: HumanPose)  {
        let fromLandmark = humanPose.landmarks.first(where: { landmark in
            landmark.id == ruleId
        })!
        
        
        let toLandmarkSegment = humanPose.landmarkSegments.first(where: { landmarkSegment in
            landmarkSegment.id == toLandmarkSegmentType.id
        })!
        
        
        
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
            landmarkRules[ruleIndex].updateRuleLandmarkToState(fromAxis: fromAxis,
                                                               fromLandmark: fromLandmark,
                                                              toStateId: toStateId,
                                                               toStateLandmark: toStateLandmark,
                                                               toLandmarkSegment: toLandmarkSegment,
                                                              toAxis: toAxis,
                                                              lowerBound: lowerBound, upperBound: upperBound,
                                                              warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)
        

        }
    }
    
    
    //    --------------
    
    
    mutating func addRuleAngleToLandmark(ruleId: String, ruleClass: RuleClass, landmarks: [Landmark]) {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            let fromLandmark = landmarks.first(where: { landmark in
                landmark.id == ruleId
            })!
            
            landmarkRules[ruleIndex].angleToLandmark.append(
                AngleToLandmark(fromLandmark: fromLandmark , toLandmark: fromLandmark,
                                warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2))
            )
      
        }
    }
    
    func getRuleAngleToLandmarks(ruleId: String, ruleClass: RuleClass) -> [AngleToLandmark] {
        if ruleClass == .Landmark, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            return landmarkRules[ruleIndex].angleToLandmark
        }
        return []
    }
    
    func getRuleAngleToLandmark(ruleId: String, ruleClass: RuleClass, id: UUID) -> AngleToLandmark {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        return landmarkRules[ruleIndex].angleToLandmark.first(where: { angle in
            angle.id == id
            
        })!
    }
    
    mutating func removeRuleAngleToLandmark(ruleId: String, ruleClass: RuleClass, id: UUID) {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        landmarkRules[ruleIndex].angleToLandmark.removeAll(where: { angle in
            angle.id == id
            
        })
    }
    
    mutating func updateRuleAngleToLandmark(ruleId: String, ruleClass: RuleClass, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, lowerBound: Double, upperBound: Double, toLandmark: Landmark, id: UUID) {
        
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
            landmarkRules[ruleIndex].updateRuleAngleToLandmark(warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, lowerBound: lowerBound, upperBound: upperBound, toLandmark: toLandmark, id: id)
        

        }
    }
    
    
//    ---------------------------
        
        func getRuleLandmarkToStateExtremes(ruleId: String, ruleClass: RuleClass) -> [LandmarkToStateExtreme] {
            if ruleClass == .Landmark, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
                return landmarkRules[ruleIndex].landmarkToStateExtreme
            }
            return []
        }
        
        func getRuleLandmarkToStateExtreme(ruleId: String, ruleClass: RuleClass, id: UUID) -> LandmarkToStateExtreme {
            let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
            return landmarkRules[ruleIndex].landmarkToStateExtreme.first(where: { landmarkToStateExtreme in
                landmarkToStateExtreme.id == id
            })!
        }
        
        mutating func addRuleLandmarkToStateExtreme(ruleId: String, ruleClass: RuleClass, humanPose: HumanPose, stateId: Int) {
            if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
                let landmark = humanPose.landmarks.first(where: { landmark in
                    landmark.id == ruleId
                })!
                let landmarkSegment = humanPose.landmarkSegments.first(where: { landmarkSegment in
                    landmarkSegment.id == LandmarkTypeSegment(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder).id
                })!
                landmarkRules[ruleIndex].landmarkToStateExtreme.append(
                    
                    LandmarkToStateExtreme(toStateId: stateId,
                                    fromLandmarkToAxis: LandmarkToAxis(landmark: landmark, axis: .X),
                                    toLandmarkToAxis: LandmarkToAxis(landmark: landmark, axis: .X),
                                    toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: landmarkSegment, axis: .X),
                                    warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2)
                                   )
                    

                )

            }
        }
        
        mutating func removeRuleLandmarkToStateExtreme(ruleId: String, ruleClass: RuleClass, id: UUID) {
            let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
            landmarkRules[ruleIndex].landmarkToStateExtreme.removeAll(where: { length in
                length.id == id
                
            })
        }
        
        mutating func updateRuleLandmarkToStateExtreme(ruleId: String,  ruleClass: RuleClass,
                                                fromAxis: CoordinateAxis,
                                                toStateId: Int,
                                                       isRelativeToExtremeDirection: Bool,

                                                       extremeDirection: ExtremeDirection,
                                                toStateLandmark: Landmark,
                                                toLandmarkSegmentType: LandmarkTypeSegment,
                                                toAxis: CoordinateAxis,
                                                lowerBound: Double, upperBound: Double,
                                                warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID, humanPose: HumanPose)  {
            let fromLandmark = humanPose.landmarks.first(where: { landmark in
                landmark.id == ruleId
            })!
            
            
            let toLandmarkSegment = humanPose.landmarkSegments.first(where: { landmarkSegment in
                landmarkSegment.id == toLandmarkSegmentType.id
            })!
            
            
            
            if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
                landmarkRules[ruleIndex].updateRuleLandmarkToStateExtreme(fromAxis: fromAxis,
                                                                   fromLandmark: fromLandmark,
                                                                  toStateId: toStateId,
                                                                          isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                   extremeDirection: extremeDirection,
                                                                   toStateLandmark: toStateLandmark,
                                                                   toLandmarkSegment: toLandmarkSegment,
                                                                  toAxis: toAxis,
                                                                  lowerBound: lowerBound, upperBound: upperBound,
                                                                  warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)
            

            }
        }
//    --------------
    
    
    func getRuleLandmarkInAreas(ruleId: String, ruleClass: RuleClass) -> [LandmarkInArea] {
        if ruleClass == .Landmark, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            
            return landmarkRules[ruleIndex].landmarkInArea
        }
        return []
    }
    
    func getRuleLandmarkInArea(ruleId: String, ruleClass: RuleClass, id: UUID) -> LandmarkInArea {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        return landmarkRules[ruleIndex].landmarkInArea.first(where: { landmarkInArea in
            landmarkInArea.id == id
        })!
    }
    
    
    mutating func addRuleLandmarkInArea(ruleId: String, ruleClass: RuleClass, landmarks: [Landmark], imageSize: Point2D) {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            let landmark = landmarks.first(where: { landmark in
                landmark.id == ruleId
            })!
            
            landmarkRules[ruleIndex].landmarkInArea.append(
                LandmarkInArea(landmark: landmark, imageSize: imageSize,
                               warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2))
            )
        }
    }
    
    
    mutating func removeRuleLandmarkInArea(ruleId: String, ruleClass: RuleClass, id: UUID) {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        landmarkRules[ruleIndex].landmarkInArea.removeAll(where: { landmarkInArea in
            landmarkInArea.id == id
            
        })
    }
    
    mutating func updateRuleLandmarkInArea(ruleId: String,  ruleClass: RuleClass,
                                           area: [Point2D], imageSize: Point2D, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID) {
        
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
            landmarkRules[ruleIndex].updateRuleLandmarkInArea(
                area: area, imageSize: imageSize, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)
        

        }
    }
    
//    --------------
    func getRuleObjectToLandmarks(ruleId: String, ruleClass: RuleClass) -> [ObjectToLandmark] {
        if ruleClass == .Observation, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            return observationRules[ruleIndex].objectToLandmark
        }
        return []
    }
    
    
    func getRuleObjectToLandmark(ruleId: String, ruleClass: RuleClass, id: UUID) -> ObjectToLandmark {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        return observationRules[ruleIndex].objectToLandmark.first(where: { objectToLandmark in
            objectToLandmark.id == id
        })!
    }
    
    mutating func addRuleObjectToLandmark(ruleId: String, ruleClass: RuleClass, humanPose: HumanPose, objects: [Observation]) {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            let object = objects.first(where: { _object in
                _object.label == ruleId
            })!
            let landmark = humanPose.landmarks.first(where: { _landmark in
                _landmark.id == LandmarkType.LeftShoulder.id
            })!
            
            let landmarkSegment = humanPose.landmarkSegments.first(where: { landmarkSegment in
                landmarkSegment.id == LandmarkTypeSegment(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder).id
            })!
            
            observationRules[ruleIndex].objectToLandmark.append(
                ObjectToLandmark(
                    fromPosition: ObjectPositionPoint(id: ruleId, position: .middle, point: object.rect.center.point2d, axis: .Y),
                                 toLandmark: landmark,
                                 toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: landmarkSegment, axis: .X), warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2),
                                 object: object
                                )
            )
        }
    }
    
    
    mutating func removeRuleObjectToLandmark(ruleId: String, ruleClass: RuleClass, id: UUID) {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        observationRules[ruleIndex].objectToLandmark.removeAll(where: { objectToLandmark in
            objectToLandmark.id == id
        })
    }
    
    
    mutating func updateRuleObjectToLandmark(ruleId: String, ruleClass: RuleClass,
                                             objectPosition: ObjectPosition,
                                                                                     fromAxis: CoordinateAxis,
                                                                                     toLandmarkType: LandmarkType,
                                                                                     toLandmarkSegmentType: LandmarkTypeSegment,
                                                                                     toAxis: CoordinateAxis,
                                             lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID, humanPose: HumanPose, objects: [Observation], isRelativeToObject: Bool) {
        
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
            let object = objects.first(where: { _object in
                _object.label == ruleId
            })!
            print("object \(object.rect) - \(ruleId) - \(object.rect.pointOf(position: objectPosition).point2d)")
            
            let toLandmark = humanPose.landmarks.first(where: { _landmark in
                _landmark.id == toLandmarkType.id
            })!
            
            let toLandmarkSegment = humanPose.landmarkSegments.first(where: { landmarkSegment in
                landmarkSegment.id == toLandmarkSegmentType.id
            })!
            
            observationRules[ruleIndex].updateRuleObjectToLandmark(objectPosition: objectPosition,
                                                                   objectPoint: object.rect.pointOf(position: objectPosition).point2d,
                                                                   fromAxis: fromAxis,
                                                                   toLandmark: toLandmark,
                                                                   toLandmarkSegment: toLandmarkSegment,
                                                                   toAxis: toAxis,
                                                                   lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id, isRelativeToObject: isRelativeToObject)

        }
    }
    

//    --------------
    
    
    func getRuleObjectToObjects(ruleId: String, ruleClass: RuleClass) -> [ObjectToObject] {
        if ruleClass == .Observation, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            return observationRules[ruleIndex].objectToObject
        }
        return []
    }
    
    
    func getRuleObjectToObject(ruleId: String, ruleClass: RuleClass, id: UUID) -> ObjectToObject {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        return observationRules[ruleIndex].objectToObject.first(where: { objectToObject in
            objectToObject.id == id
        })!
    }
    
    mutating func addRuleObjectToObject(ruleId: String, ruleClass: RuleClass, humanPose: HumanPose, objects: [Observation]) {
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
            let object = objects.first(where: { _object in
                _object.label == ruleId
            })!
            
            let landmarkSegment = humanPose.landmarkSegments.first(where: { landmarkSegment in
                landmarkSegment.id == LandmarkTypeSegment(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder).id
            })!
            
            observationRules[ruleIndex].objectToObject.append(
                ObjectToObject(
                    fromPosition: ObjectPositionPoint(id: ruleId, position: .middle, point: object.rect.center.point2d, axis: .Y),
                    toPosition: ObjectPositionPoint(id: ruleId, position: .middle, point: object.rect.center.point2d, axis: .Y),
                    toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: landmarkSegment, axis: .X),
                    warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2), object: object)
            )
        }
    }
    
    
    mutating func removeRuleObjectToObject(ruleId: String, ruleClass: RuleClass, id: UUID) {
        let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
        observationRules[ruleIndex].objectToObject.removeAll(where: { objectToObject in
            objectToObject.id == id
        })
    }
    
    
    mutating func updateRuleObjectToObject(ruleId: String, ruleClass: RuleClass,
                                           fromAxis: CoordinateAxis, fromObjectPosition: ObjectPosition, toObjectId: String, toObjectPosition: ObjectPosition, toLandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID,
                                           landmarkSegments: [LandmarkSegment], objects: [Observation], isRelativeToObject: Bool) {
        
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
            let fromObject = objects.first(where: { _object in
                _object.label == ruleId
            })!
            
            let toObject = objects.first(where: { _object in
                _object.label == toObjectId
            })!
            print("object \(fromObject.rect) - \(ruleId) - \(fromObject.rect.pointOf(position: fromObjectPosition).point2d)")
            

            
            let toLandmarkSegment = landmarkSegments.first(where: { landmarkSegment in
                landmarkSegment.id == toLandmarkSegmentType.id
            })!
            
            observationRules[ruleIndex].updateRuleObjectToObject(fromAxis: fromAxis, fromObjectPosition: fromObjectPosition, fromObject: fromObject, toObject: toObject, toObjectPosition: toObjectPosition, toLandmarkSegment: toLandmarkSegment, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id, isRelativeToObject: isRelativeToObject)

        }
    }
    //    --------------
        
        
        func getRuleObjectToSelfs(ruleId: String, ruleClass: RuleClass) -> [ObjectToSelf] {
            if ruleClass == .Observation, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
                return observationRules[ruleIndex].objectToSelf
            }
            return []
        }
        
        
        func getRuleObjectToSelf(ruleId: String, ruleClass: RuleClass, id: UUID) -> ObjectToSelf {
            let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
            return observationRules[ruleIndex].objectToSelf.first(where: { objectToSelf in
                objectToSelf.id == id
            })!
        }
        
        mutating func addRuleObjectToSelf(ruleId: String, ruleClass: RuleClass) {
            if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
                
                observationRules[ruleIndex].objectToSelf.append(
                    ObjectToSelf(objectId: ruleId, toDirection: .LEFT, xLowerBound: 0, yLowerBound: 0, warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2))
                )
            }
        }
        
        
        mutating func removeRuleObjectToSelf(ruleId: String, ruleClass: RuleClass, id: UUID) {
            let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
            observationRules[ruleIndex].objectToSelf.removeAll(where: { objectToSelf in
                objectToSelf.id == id
            })
        }
    
    
    mutating func updateRuleObjectToSelf(ruleId: String, ruleClass: RuleClass,
                                         direction: Direction, xLowerBound: Double, yLowerBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID) {
        
        if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {

 
            observationRules[ruleIndex].updateRuleObjectToSelf(direction: direction, xLowerBound: xLowerBound, yLowerBound: yLowerBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)
        }
    }

    //    ---------------------------
            
            func getRuleObjectToStateExtremes(ruleId: String, ruleClass: RuleClass) -> [ObjectToStateExtreme] {
                if ruleClass == .Observation, let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
                    return observationRules[ruleIndex].objectToState
                }
                return []
            }
            
            func getRuleObjectToStateExtreme(ruleId: String, ruleClass: RuleClass, id: UUID) -> ObjectToStateExtreme {
                let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
                return observationRules[ruleIndex].objectToState.first(where: { objectToState in
                    objectToState.id == id
                })!
            }
            
            mutating func addRuleObjectToStateExtreme(ruleId: String, ruleClass: RuleClass, landmarkSegments: [LandmarkSegment], stateId: Int, objects: [Observation]) {
                if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass) {
                    let object = objects.first(where: { object in
                        object.label == ruleId
                    })!
                    
                    
                    let landmarkSegment = landmarkSegments.first(where: { landmarkSegment in
                        landmarkSegment.id == LandmarkTypeSegment(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder).id
                    })!
                    observationRules[ruleIndex].objectToState.append(
                        ObjectToStateExtreme(toStateId: stateId,
                                             fromPosition: ObjectPositionPoint(
                                                id: ruleId, position: .middle, point: object.rect.pointOf(position: .middle).point2d, axis: .X),
                                             toPosition: ObjectPositionPoint(
                                                id: ruleId, position: .middle, point: object.rect.pointOf(position: .middle).point2d, axis: .X),
                                             toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: landmarkSegment, axis: .X),
                                             warning: Warning(content: "", triggeredWhenRuleMet: false, delayTime: 2),                                             object: object)
                    )

                }
            }
            
            mutating func removeRuleObjectToStateExtreme(ruleId: String, ruleClass: RuleClass, id: UUID) {
                let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)!
                observationRules[ruleIndex].objectToState.removeAll(where: { objectToState in
                    objectToState.id == id
                    
                })
            }
            
            mutating func updateRuleObjectToStateExtreme(ruleId: String,  ruleClass: RuleClass,
                                                         fromAxis: CoordinateAxis,
                                                         toStateId: Int,
                                                         fromPosition: ObjectPosition,
                                                         toObject: Observation,
                                                        isRelativeToObject: Bool,
                                                        isRelativeToExtremeDirection: Bool,
                                                         extremeDirection: ExtremeDirection,
                                                        toLandmarkSegmentType: LandmarkTypeSegment,
                                                        toAxis: CoordinateAxis,
                                                        lowerBound: Double, upperBound: Double,
                                                         warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,
                                                         id: UUID, landmarkSegments: [LandmarkSegment], objects: [Observation])   {
                
                let fromObject = objects.first(where: { object in
                    object.label == ruleId
                })!
                
                
                let toLandmarkSegment = landmarkSegments.first(where: { landmarkSegment in
                    landmarkSegment.id == toLandmarkSegmentType.id
                })!
                
                
                
                if let ruleIndex = findFirstRulerByRuleId(ruleId: ruleId, ruleClass: ruleClass)  {
                    observationRules[ruleIndex].updateRuleObjectToStateExtreme(
                        fromAxis: fromAxis,
                        toStateId: toStateId,
                        fromPosition: fromPosition,
                        fromObject: fromObject,
                        toObject: toObject,
                        isRelativeToObject: isRelativeToObject,
                        isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                        extremeDirection: extremeDirection,
                        toLandmarkSegment: toLandmarkSegment,
                        toAxis: toAxis,
                        lowerBound: lowerBound, upperBound: upperBound,
                        warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet,
                        delayTime: delayTime, id: id)
                

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

