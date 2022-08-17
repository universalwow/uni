
import Foundation


struct SportState: Identifiable, Equatable, Hashable, Codable {
  
  var id: Int = -1
  var name:String = ""
  var description:String = ""
  var image: PngImage?
  var landmarkSegments :[LandmarkSegment] = []
  var humanPose: HumanPose?
  var objects: [Observation] = []
  
  // MARK: TO DELETE
  // TODO: 状态对应的规则 时间限制 一定时间内没有切换状态
  var transFormTimeLimit: Double? 
  // 计分规则 关节点对应的规则
  var scoreRules:[Rules] = []
  // 违规规则 用于提示
  var violateRules:[Rules] = []
    
    // 基于时间的检查周期及通过率
    var checkCycle:Double?
    var passingRate:Double?
    var keepTime:Double?
  

  static func == (lhs: SportState, rhs: SportState) -> Bool {
    lhs.name == rhs.name
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}


extension SportState {
  
  static var startState : SportState {
    SportState(id: 1, name: "Start", description: "start")
  }
  
  static var endState: SportState {
    SportState(id: 2, name: "End", description: "end")
  }
  
    static var readyState: SportState {
      SportState(id: 3, name: "Ready", description: "Ready")
    }
  
  
    func firstIndexOfRules(editedRulesId: UUID, ruleType: RuleType) -> Int? {
    switch ruleType {
    case .SCORE:
      return scoreRules.firstIndex(where: { rules in
        editedRulesId == rules.id
      })
    case .VIOLATE:
      return violateRules.firstIndex(where: { rules in
        editedRulesId == rules.id
      })
    }
  }
  
  func findRulesList(ruleType: RuleType) -> [Rules] {
    switch ruleType {
    case .SCORE:
      return scoreRules
    case .VIOLATE:
      return violateRules
    }
  }
  
  func findRules(ruleType: RuleType, currentSportStateRulesId: UUID) -> Rules? {
    findRulesList(ruleType: ruleType)
      .first(where: { rules in
        currentSportStateRulesId == rules.id
      })
  }
  
  func firstComplexRulesById(editedRulesId: UUID, ruleType: RuleType) -> Rules? {
    switch ruleType {
    case .SCORE:
      return scoreRules.first(where: { rules in
        editedRulesId == rules.id
      })
    case .VIOLATE:
      return violateRules.first(where: { rules in
        editedRulesId == rules.id
      })
    }
  }
  
    mutating func updateRule(editedSportStateRulesId: UUID, editedRule: Ruler, ruleType: RuleType, ruleClass: RuleClass) {
      if let rulesIndex = firstIndexOfRules(editedRulesId: editedSportStateRulesId, ruleType: ruleType) {
        switch ruleType {
          case .SCORE:
            scoreRules[rulesIndex].updateRule(editedRule: editedRule, ruleClass: ruleClass)

          case .VIOLATE:
            violateRules[rulesIndex].updateRule(editedRule: editedRule, ruleClass: ruleClass)
          }
    }
    
  }
    

  
  
  mutating func deleteRules(rulesId: UUID, ruleType: RuleType) {
    if let index = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
      switch ruleType {
      case .SCORE:
        scoreRules.remove(at: index)
      case .VIOLATE:
        violateRules.remove(at: index)
      }
    }
  }
    
    mutating func deleteRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
      if let index = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
        switch ruleType {
        case .SCORE:
            scoreRules[index].deleteRule(ruleId: ruleId, ruleClass: ruleClass)
        case .VIOLATE:
          violateRules[index].deleteRule(ruleId: ruleId, ruleClass: ruleClass)
        }
      }
    }
    

  
  func firstIndexOfLandmarkSegment(editedSportStateRuleId: String?) -> Int? {
      humanPose?.landmarkSegments.firstIndex(where: { landmarkSegment in
      landmarkSegment.landmarkSegmentType.id == editedSportStateRuleId
    })
  }
    
    func firstIndexOfLandmark(editedSportStateRuleId: String?) -> Int? {
        humanPose?.landmarks.firstIndex(where: { landmark in
        landmark.id == editedSportStateRuleId
      })
    }
    
    func firstIndexOfObservation(editedSportStateRuleId: String?) -> Int? {
        
        objects.firstIndex(where: { observation in
            observation.label == editedSportStateRuleId
        })
    }
  
  func findselectedSegment(editedSportStateRuleId: String?) -> LandmarkSegment? {
    if let index = firstIndexOfLandmarkSegment(editedSportStateRuleId: editedSportStateRuleId) {
      return landmarkSegments[index]
    }
    return nil
  }
    func segmentSelected(segment: LandmarkSegment) -> Bool? {
        if let index = firstIndexOfLandmarkSegment(editedSportStateRuleId: segment.id) {
            return landmarkSegments[index].selected
        }
        return nil
    }
  
    mutating func setSegmentToSelected(editedSportStateRuleId: String?, ruleClass: RuleClass) {
        humanPose?.landmarkSegments.indices.forEach{ index in
            self.humanPose?.landmarkSegments[index].selected = false
        }
        
        humanPose?.landmarks.indices.forEach { index in
            self.humanPose?.landmarks[index].selected = false
        }
        
        objects.indices.forEach { index in
            objects[index].selected = false
        }
        
        switch ruleClass {
        case .LandmarkSegment:
            if let editedSportStateRuleId = editedSportStateRuleId,
                let index = firstIndexOfLandmarkSegment(editedSportStateRuleId: editedSportStateRuleId){
                humanPose?.landmarkSegments[index].selected = true
            }
        case .Landmark:
            if let editedSportStateRuleId = editedSportStateRuleId,
                let index = firstIndexOfLandmark(editedSportStateRuleId: editedSportStateRuleId) {
                humanPose?.landmarks[index].selected = true
            }
            
        case .Observation:
            if let editedSportStateRuleId = editedSportStateRuleId,
                let index = firstIndexOfObservation(editedSportStateRuleId: editedSportStateRuleId) {
                objects[index].selected = true
            }
            
        }
        
        
  }
  

  
    func rulesSatisfy(ruleType: RuleType, stateTimeHistory: [StateTime], poseMap:PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int) {
    
    var rules : [Rules] = []
    switch ruleType {
      case .SCORE:
        rules = scoreRules
      case .VIOLATE:
        rules = violateRules
    }
    // 只要有一组条件满足
    return rules.reduce((false, Set<Warning>(), 0, 0), { result, next in
        // 每一组条件全部满足

        let satisfy = next.allSatisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
        // 返回满足率最大的那一组数目
        
        if result.3 == 0 && satisfy.3 == 0 {
            return (false, result.1, 0, 0)
        } else if result.3 == 0 && satisfy.3 != 0 {
            return (result.0 || satisfy.0, satisfy.1, satisfy.2, satisfy.3)
        } else if result.3 != 0 && satisfy.3 == 0 {
            return (false, result.1, result.2, result.3)
        } else {
            let lastSatisfyPercent = Double(result.2) / Double(result.3)
            let currentSatisfyPercent = Double(satisfy.2) / Double(satisfy.3)
            
            if currentSatisfyPercent >= lastSatisfyPercent {
                return (result.0 || satisfy.0, satisfy.1, satisfy.2, satisfy.3)
            }else {
                return (result.0 || satisfy.0, result.1, result.2, result.3)
            }
        }
    })
  }
  
  func findLandmarkSegment(id: String) -> LandmarkSegment {
    landmarkSegments.first{ landmarkSegment in
      landmarkSegment.id == id
    }!
  }
    
    
//    MARK: RULE
    
    mutating func addRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].addRule(ruleId: ruleId, ruleClass: ruleClass)
            case .VIOLATE:
                violateRules[rulesIndex].addRule(ruleId: ruleId, ruleClass: ruleClass)
            }
        }
    }
    
    mutating func addRuleLandmarkSegmentAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].addRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments)
            case .VIOLATE:
                violateRules[rulesIndex].addRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments)
            }
        }
    }
    
    func getRuleLandmarkSegmentAngles(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [AngleRange] {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                return scoreRules[rulesIndex].getRuleLandmarkSegmentAngles(ruleId: ruleId, ruleClass: ruleClass)
            case .VIOLATE:
                return violateRules[rulesIndex].getRuleLandmarkSegmentAngles(ruleId: ruleId, ruleClass: ruleClass)
            }
        }
        
        return []
    }
    
    func getRuleLandmarkSegmentAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> AngleRange {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            return scoreRules[rulesIndex].getRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            return violateRules[rulesIndex].getRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    mutating func removeRuleLandmarkSegmentAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            scoreRules[rulesIndex].removeRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            violateRules[rulesIndex].removeRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    
    
    mutating func updateRuleLandmarkSegmentAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, lowerBound: Double, upperBound: Double, id: UUID) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].updateRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass,
                                                                      warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, lowerBound: lowerBound, upperBound: upperBound, id: id)
            case .VIOLATE:
                violateRules[rulesIndex].updateRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass,
                                                                        warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, lowerBound: lowerBound, upperBound: upperBound, id: id)
            }
        }
    }
    
//    ----------------
    
    func getRuleAngleToLandmarkSegments(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [AngleToLandmarkSegment] {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                return scoreRules[rulesIndex].getRuleAngleToLandmarkSegments(ruleId: ruleId, ruleClass: ruleClass)
            case .VIOLATE:
                return violateRules[rulesIndex].getRuleAngleToLandmarkSegments(ruleId: ruleId, ruleClass: ruleClass)
            }
        }
        
        return []
    }
    
    
    func getRuleAngleToLandmarkSegment(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> AngleToLandmarkSegment {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            return scoreRules[rulesIndex].getRuleAngleToLandmarkSegment(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            return violateRules[rulesIndex].getRuleAngleToLandmarkSegment(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    
    mutating func addRuleAngleToLandmarkSegment(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].addRuleAngleToLandmarkSegment(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments)
            case .VIOLATE:
                violateRules[rulesIndex].addRuleAngleToLandmarkSegment(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments)
            }
        }
    }
    
    mutating func removeRuleAngleToLandmarkSegment(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            scoreRules[rulesIndex].removeRuleAngleToLandmarkSegment(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            violateRules[rulesIndex].removeRuleAngleToLandmarkSegment(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    mutating func updateRuleAngleToLandmarkSegment(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, tolandmarkSegmentType: LandmarkTypeSegment, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,  id: UUID) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].updateRuleAngleToLandmarkSegment(ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, tolandmarkSegmentType: tolandmarkSegmentType, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id, landmarkSegments: humanPose!.landmarkSegments)
            case .VIOLATE:
                violateRules[rulesIndex].updateRuleAngleToLandmarkSegment(ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, tolandmarkSegmentType: tolandmarkSegmentType, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id, landmarkSegments: humanPose!.landmarkSegments)
            }
        }
    }
    
//    -------------------
    mutating func transferRuleTo(ruleType:RuleType, rulesIndex:Int, rule: Ruler) {
        
        switch ruleType {
        case .SCORE:
            scoreRules[rulesIndex].transferRuleTo(rule: rule)
        case .VIOLATE:
            violateRules[rulesIndex].transferRuleTo(rule: rule)
        }

        
    }
    
    
  
}
