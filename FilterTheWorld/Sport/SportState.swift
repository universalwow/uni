
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
    
    
//    var isScoreState:
  

  static func == (lhs: SportState, rhs: SportState) -> Bool {
    lhs.name == rhs.name
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}


extension SportState {
    
    static var interAction_1 : SportState {
      SportState(id: -1, name: "interAction_1", description: "interAction_1")
    }
    static var interAction_2 : SportState {
      SportState(id: -2, name: "提交答案", description: "提交答案")
    }
    static var interAction_3 : SportState {
      SportState(id: -3, name: "interAction_3", description: "interAction_3")
    }
    
    
    static var interAction_a : SportState {
      SportState(id: 0, name: "A", description: "A")
    }
    static var interAction_b : SportState {
      SportState(id: 1, name: "B", description: "B")
    }
    static var interAction_c : SportState {
      SportState(id: 2, name: "C", description: "C")
    }
    
    static var interAction_d : SportState {
      SportState(id: 3, name: "D", description: "D")
    }
    
  
  static var startState : SportState {
    SportState(id: 4, name: "Start", description: "start")
  }
  
  static var endState: SportState {
    SportState(id: 5, name: "End", description: "end")
  }
  
    static var readyState: SportState {
      SportState(id: 6, name: "Ready", description: "Ready")
    }
    
    func getFixedAreas() -> Set<String> {
        var areas: Set<String> = []
        scoreRules.forEach({ rules in
            areas.formUnion(
                rules.fixedAreaRules.map({ fixedAreaRule in
                fixedAreaRule.id
            }))
        })
        
        violateRules.forEach({ rules in
            areas.formUnion(
                rules.fixedAreaRules.map({ fixedAreaRule in
                fixedAreaRule.id
            }))
        })
        
        return areas
    }
    
    func getDynamicAreas() -> Set<String> {
        var areas: Set<String> = []
        scoreRules.forEach({ rules in
            areas.formUnion(
                rules.dynamicAreaRules.map({ dynamicAreaRule in
                    dynamicAreaRule.id
            }))
        })
        
        violateRules.forEach({ rules in
            areas.formUnion(
                rules.dynamicAreaRules.map({ dynamicAreaRule in
                    dynamicAreaRule.id
            }))
        })
        
        return areas
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
  
    mutating func setSegmentToSelected(editedSportStateRuleId: String?, ruleClass: RuleClass?) {
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
        
//        MARK: 设置区域被选择
        case .FixedArea:
            break
        case .DynamicArea:
            break
            
        case .none:
            break
   
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
//        MARK: 初始化isScoreWarning逻辑应移至外部设置
        let warningSet = Set(satisfy.1.map { warning -> Warning in
            var newWarning = warning
            newWarning.isScoreWarning = ruleType == .SCORE
            return newWarning
        })
        
        if result.3 == 0 && satisfy.3 == 0 {
            return (false, warningSet, satisfy.2, satisfy.3)
        } else if result.3 == 0 && satisfy.3 != 0 {
            return (result.0 || satisfy.0, warningSet, satisfy.2, satisfy.3)
        } else if result.3 != 0 && satisfy.3 == 0 {
            return (false, result.1, result.2, result.3)
        } else {
            let lastSatisfyPercent = Double(result.2) / Double(result.3)
            let currentSatisfyPercent = Double(satisfy.2) / Double(satisfy.3)
            
            if currentSatisfyPercent > lastSatisfyPercent {
                return (result.0 || satisfy.0, warningSet, satisfy.2, satisfy.3)
            } else if currentSatisfyPercent < lastSatisfyPercent {
                return (result.0 || satisfy.0, result.1, result.2, result.3)
            }else{
                return (result.0 || satisfy.0, result.1.union(warningSet), result.2, result.3)
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
                scoreRules[rulesIndex].addRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments, isScoreWarning: true)
            case .VIOLATE:
                violateRules[rulesIndex].addRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments, isScoreWarning: false)
            }
        }
    }
    
    func getRuleLandmarkSegmentAngles(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkSegmentAngle] {
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
    
    func getRuleLandmarkSegmentAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkSegmentAngle {
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
    
    
    
    mutating func updateRuleLandmarkSegmentAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,lowerBound: Double, upperBound: Double, id: UUID) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].updateRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass,
                                                                      warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, lowerBound: lowerBound, upperBound: upperBound, id: id)
            case .VIOLATE:
                violateRules[rulesIndex].updateRuleLandmarkSegmentAngle(ruleId: ruleId, ruleClass: ruleClass,
                                                                        warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, lowerBound: lowerBound, upperBound: upperBound, id: id)
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
                scoreRules[rulesIndex].addRuleAngleToLandmarkSegment(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments, isScoreWarning: true)
            case .VIOLATE:
                violateRules[rulesIndex].addRuleAngleToLandmarkSegment(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments, isScoreWarning: false)
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
    
    mutating func updateRuleAngleToLandmarkSegment(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, tolandmarkSegmentType: LandmarkTypeSegment, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].updateRuleAngleToLandmarkSegment(ruleId: ruleId, ruleClass: ruleClass, tolandmarkSegmentType: tolandmarkSegmentType, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id, landmarkSegments: humanPose!.landmarkSegments)
            case .VIOLATE:
                violateRules[rulesIndex].updateRuleAngleToLandmarkSegment(ruleId: ruleId, ruleClass: ruleClass, tolandmarkSegmentType: tolandmarkSegmentType, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id, landmarkSegments: humanPose!.landmarkSegments)
            }
        }
    }
    
//    -------------------
    
    func getRuleLandmarkSegmentLengths(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkSegmentLength] {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                return scoreRules[rulesIndex].getRuleLandmarkSegmentLengths(ruleId: ruleId, ruleClass: ruleClass)
            case .VIOLATE:
                return violateRules[rulesIndex].getRuleLandmarkSegmentLengths(ruleId: ruleId, ruleClass: ruleClass)
            }
        }
        
        return []
    }
    
    func getRuleLandmarkSegmentLength(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkSegmentLength {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            return scoreRules[rulesIndex].getRuleLandmarkSegmentLength(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            return violateRules[rulesIndex].getRuleLandmarkSegmentLength(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    mutating func addRuleLandmarkSegmentLength(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].addRuleLandmarkSegmentLength(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments, isScoreWarning: true)
            case .VIOLATE:
                violateRules[rulesIndex].addRuleLandmarkSegmentLength(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments, isScoreWarning: false)
            }
        }
    }
    
    mutating func removeRuleLandmarkSegmentLength(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            scoreRules[rulesIndex].removeRuleLandmarkSegmentLength(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            violateRules[rulesIndex].removeRuleLandmarkSegmentLength(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    mutating func updateRuleLandmarkSegmentLength(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, fromAxis: CoordinateAxis,tolandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].updateRuleLandmarkSegmentLength(ruleId: ruleId, ruleClass: ruleClass, fromAxis: fromAxis, tolandmarkSegmentType: tolandmarkSegmentType, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id, landmarkSegments: humanPose!.landmarkSegments)
            case .VIOLATE:
                violateRules[rulesIndex].updateRuleLandmarkSegmentLength(ruleId: ruleId, ruleClass: ruleClass, fromAxis: fromAxis, tolandmarkSegmentType: tolandmarkSegmentType, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id, landmarkSegments: humanPose!.landmarkSegments)
            }
        }
    }
    
    //    ----------------
            
            func getRuleLandmarkSegmentToStateAngles(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkSegmentToStateAngle] {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        return scoreRules[rulesIndex].getRuleLandmarkSegmentToStateAngles(ruleId: ruleId, ruleClass: ruleClass)
                    case .VIOLATE:
                        return violateRules[rulesIndex].getRuleLandmarkSegmentToStateAngles(ruleId: ruleId, ruleClass: ruleClass)
                    }
                }
                
                return []
            }
            
            func getRuleLandmarkSegmentToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkSegmentToStateAngle {
                let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
                switch ruleType {
                case .SCORE:
                    return scoreRules[rulesIndex].getRuleLandmarkSegmentToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                case .VIOLATE:
                    return violateRules[rulesIndex].getRuleLandmarkSegmentToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                }
            }
            
            mutating func addRuleLandmarkSegmentToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        scoreRules[rulesIndex].addRuleLandmarkSegmentToStateAngle(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, stateId: self.id, isScoreWarning: true)
                    case .VIOLATE:
                        violateRules[rulesIndex].addRuleLandmarkSegmentToStateAngle(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, stateId: self.id, isScoreWarning: false)
                    }
                }
            }
            
            mutating func removeRuleLandmarkSegmentToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].removeRuleLandmarkSegmentToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                case .VIOLATE:
                    violateRules[rulesIndex].removeRuleLandmarkSegmentToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                }
            }
            
            mutating func updateRuleLandmarkSegmentToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                    toStateId: Int,
                                                           isRelativeToExtremeDirection: Bool,
                                                           extremeDirection: ExtremeDirection,
                                                    toStateLandmarkSegment: LandmarkSegment,
                                                    lowerBound: Double, upperBound: Double,
                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, id: UUID) {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        scoreRules[rulesIndex].updateRuleLandmarkSegmentToStateAngle(ruleId: ruleId, ruleClass: ruleClass,
                                                                         toStateId: toStateId,
                                                                                isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                                extremeDirection: extremeDirection,
                                                                         toStateLandmarkSegment: toStateLandmarkSegment,
                                                                         lowerBound: lowerBound, upperBound: upperBound,
                                                                         warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id, humanPose: self.humanPose!)
                    case .VIOLATE:
                        violateRules[rulesIndex].updateRuleLandmarkSegmentToStateAngle(ruleId: ruleId, ruleClass: ruleClass,
                                                                           toStateId: toStateId,
                                                                                  isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                                  extremeDirection: extremeDirection,
                                                                           toStateLandmarkSegment: toStateLandmarkSegment,
                                                                           lowerBound: lowerBound, upperBound: upperBound,
                                                                           warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear,id: id, humanPose: self.humanPose!)
                    }
                }
            }
    
    
    
    //    ----------------
            
            func getRuleLandmarkSegmentToStateDistances(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkSegmentToStateDistance] {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        return scoreRules[rulesIndex].getRuleLandmarkSegmentToStateDistances(ruleId: ruleId, ruleClass: ruleClass)
                    case .VIOLATE:
                        return violateRules[rulesIndex].getRuleLandmarkSegmentToStateDistances(ruleId: ruleId, ruleClass: ruleClass)
                    }
                }
                
                return []
            }
            
            func getRuleLandmarkSegmentToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkSegmentToStateDistance {
                let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
                switch ruleType {
                case .SCORE:
                    return scoreRules[rulesIndex].getRuleLandmarkSegmentToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
                case .VIOLATE:
                    return violateRules[rulesIndex].getRuleLandmarkSegmentToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
                }
            }
            
            mutating func addRuleLandmarkSegmentToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        scoreRules[rulesIndex].addRuleLandmarkSegmentToStateDistance(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, stateId: self.id, isScoreWarning: true)
                    case .VIOLATE:
                        violateRules[rulesIndex].addRuleLandmarkSegmentToStateDistance(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, stateId: self.id, isScoreWarning: false)
                    }
                }
            }
            
            mutating func removeRuleLandmarkSegmentToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].removeRuleLandmarkSegmentToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
                case .VIOLATE:
                    violateRules[rulesIndex].removeRuleLandmarkSegmentToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
                }
            }
            
            mutating func updateRuleLandmarkSegmentToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                                   fromAxis: CoordinateAxis,
                                                    toStateId: Int,
                                                           isRelativeToExtremeDirection: Bool,
                                                           extremeDirection: ExtremeDirection,
                                                    toStateLandmarkSegment: LandmarkSegment,
                                                    lowerBound: Double, upperBound: Double,
                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        scoreRules[rulesIndex].updateRuleLandmarkSegmentToStateDistance(ruleId: ruleId, ruleClass: ruleClass,
                                                                                        fromAxis: fromAxis,
                                                                         toStateId: toStateId,
                                                                                isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                                extremeDirection: extremeDirection,
                                                                         toStateLandmarkSegment: toStateLandmarkSegment,
                                                                         lowerBound: lowerBound, upperBound: upperBound,
                                                                         warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id, humanPose: self.humanPose!)
                    case .VIOLATE:
                        violateRules[rulesIndex].updateRuleLandmarkSegmentToStateDistance(ruleId: ruleId, ruleClass: ruleClass,
                                                                                          fromAxis: fromAxis,
                                                                           toStateId: toStateId,
                                                                                  isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                                  extremeDirection: extremeDirection,
                                                                           toStateLandmarkSegment: toStateLandmarkSegment,
                                                                           lowerBound: lowerBound, upperBound: upperBound,
                                                                           warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id, humanPose: self.humanPose!)
                    }
                }
            }
    
    
    //    -------------------
        
        func getRuleDistanceToLandmarks(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [DistanceToLandmark] {
            if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                switch ruleType {
                case .SCORE:
                    return scoreRules[rulesIndex].getRuleDistanceToLandmarks(ruleId: ruleId, ruleClass: ruleClass)
                case .VIOLATE:
                    return violateRules[rulesIndex].getRuleDistanceToLandmarks(ruleId: ruleId, ruleClass: ruleClass)
                }
            }
            
            return []
        }
        
        func getRuleDistanceToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> DistanceToLandmark {
            let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
            switch ruleType {
            case .SCORE:
                return scoreRules[rulesIndex].getRuleDistanceToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
            case .VIOLATE:
                return violateRules[rulesIndex].getRuleDistanceToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
            }
        }
        
        mutating func addRuleDistanceToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
            if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].addRuleDistanceToLandmark(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!
                                                                     , isScoreWarning: true)
                case .VIOLATE:
                    violateRules[rulesIndex].addRuleDistanceToLandmark(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, isScoreWarning: false)
                }
            }
        }
        
        mutating func removeRuleDistanceToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
            let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].removeRuleDistanceToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
            case .VIOLATE:
                violateRules[rulesIndex].removeRuleDistanceToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
            }
        }
        
    mutating func updateRuleDistanceToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, fromAxis: CoordinateAxis, toLandmarkType: LandmarkType, tolandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
            if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].updateRuleDistanceToLandmark(ruleId: ruleId, ruleClass: ruleClass, fromAxis: fromAxis, toLandmarkType: toLandmarkType, tolandmarkSegmentType: tolandmarkSegmentType, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id, humanPose: humanPose!)
                case .VIOLATE:
                    violateRules[rulesIndex].updateRuleDistanceToLandmark(ruleId: ruleId, ruleClass: ruleClass, fromAxis: fromAxis,  toLandmarkType: toLandmarkType, tolandmarkSegmentType: tolandmarkSegmentType, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id, humanPose: humanPose!)
                }
            }
        }
    
    //    -------------------
    
    mutating func addRuleAngleToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].addRuleAngleToLandmark(ruleId: ruleId, ruleClass: ruleClass,
                                                               landmarks: humanPose!.landmarks, isScoreWarning: true)
            case .VIOLATE:
                violateRules[rulesIndex].addRuleAngleToLandmark(ruleId: ruleId, ruleClass: ruleClass,
                                                                 landmarks: humanPose!.landmarks, isScoreWarning: false)
            }
        }
    }
    
    func getRuleAngleToLandmarks(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [AngleToLandmark] {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                return scoreRules[rulesIndex].getRuleAngleToLandmarks(ruleId: ruleId, ruleClass: ruleClass)
            case .VIOLATE:
                return violateRules[rulesIndex].getRuleAngleToLandmarks(ruleId: ruleId, ruleClass: ruleClass)
            }
        }
        
        return []
    }
    
    func getRuleAngleToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> AngleToLandmark {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            return scoreRules[rulesIndex].getRuleAngleToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            return violateRules[rulesIndex].getRuleAngleToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    mutating func removeRuleAngleToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            scoreRules[rulesIndex].removeRuleAngleToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            violateRules[rulesIndex].removeRuleAngleToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    
    mutating func updateRuleAngleToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  lowerBound: Double, upperBound: Double,
                                                 toLandmarkType:LandmarkType, id: UUID) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            let toLandmark = humanPose!.landmarks.first(where: { landmark in
                landmark.id == toLandmarkType.id
            })!
            
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].updateRuleAngleToLandmark(ruleId: ruleId, ruleClass: ruleClass,
                                                                      warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, lowerBound: lowerBound, upperBound: upperBound,
                                                                      toLandmark: toLandmark, id: id)
            case .VIOLATE:
                violateRules[rulesIndex].updateRuleAngleToLandmark(ruleId: ruleId, ruleClass: ruleClass,
                                                                        warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  lowerBound: lowerBound, upperBound: upperBound,
                                                                        toLandmark: toLandmark, id: id)
            }
        }
    }
    
//    ----------------
        
        func getRuleLandmarkToStateDistances(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkToStateDistance] {
            if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                switch ruleType {
                case .SCORE:
                    return scoreRules[rulesIndex].getRuleLandmarkToStateDistances(ruleId: ruleId, ruleClass: ruleClass)
                case .VIOLATE:
                    return violateRules[rulesIndex].getRuleLandmarkToStateDistances(ruleId: ruleId, ruleClass: ruleClass)
                }
            }
            
            return []
        }
        
        func getRuleLandmarkToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkToStateDistance {
            let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
            switch ruleType {
            case .SCORE:
                return scoreRules[rulesIndex].getRuleLandmarkToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
            case .VIOLATE:
                return violateRules[rulesIndex].getRuleLandmarkToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
            }
        }
        
        mutating func addRuleLandmarkToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
            if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].addRuleLandmarkToStateDistance(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, stateId: self.id, isScoreWarning: true)
                case .VIOLATE:
                    violateRules[rulesIndex].addRuleLandmarkToStateDistance(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, stateId: self.id, isScoreWarning: false)
                }
            }
        }
        
        mutating func removeRuleLandmarkToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
            let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].removeRuleLandmarkToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
            case .VIOLATE:
                violateRules[rulesIndex].removeRuleLandmarkToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
            }
        }
        
        mutating func updateRuleLandmarkToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                fromAxis: CoordinateAxis,
                                                toStateId: Int,
                                                       isRelativeToExtremeDirection: Bool,
                                                       extremeDirection: ExtremeDirection,
                                                toStateLandmark: Landmark,
                                                toLandmarkSegmentType: LandmarkTypeSegment,
                                                toAxis: CoordinateAxis,
                                                lowerBound: Double, upperBound: Double,
                                    warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
            if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].updateRuleLandmarkToStateDistance(ruleId: ruleId, ruleClass: ruleClass,
                                                                     fromAxis: fromAxis,
                                                                     toStateId: toStateId,
                                                                            isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                            extremeDirection: extremeDirection,
                                                                     toStateLandmark: toStateLandmark,
                                                                     toLandmarkSegmentType: toLandmarkSegmentType,
                                                                     toAxis: toAxis,
                                                                     lowerBound: lowerBound, upperBound: upperBound,
                                                                     warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id, humanPose: self.humanPose!)
                case .VIOLATE:
                    violateRules[rulesIndex].updateRuleLandmarkToStateDistance(ruleId: ruleId, ruleClass: ruleClass,
                                                                       fromAxis: fromAxis,
                                                                       toStateId: toStateId,
                                                                              isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                              extremeDirection: extremeDirection,
                                                                       toStateLandmark: toStateLandmark,
                                                                       toLandmarkSegmentType: toLandmarkSegmentType,
                                                                       toAxis: toAxis,
                                                                       lowerBound: lowerBound, upperBound: upperBound,
                                                                       warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id, humanPose: self.humanPose!)
                }
            }
        }
    
    
    
    //    ----------------
            
            func getRuleLandmarkToStateAngles(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkToStateAngle] {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        return scoreRules[rulesIndex].getRuleLandmarkToStateAngles(ruleId: ruleId, ruleClass: ruleClass)
                    case .VIOLATE:
                        return violateRules[rulesIndex].getRuleLandmarkToStateAngles(ruleId: ruleId, ruleClass: ruleClass)
                    }
                }
                
                return []
            }
            
            func getRuleLandmarkToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkToStateAngle {
                let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
                switch ruleType {
                case .SCORE:
                    return scoreRules[rulesIndex].getRuleLandmarkToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                case .VIOLATE:
                    return violateRules[rulesIndex].getRuleLandmarkToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                }
            }
            
            mutating func addRuleLandmarkToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        scoreRules[rulesIndex].addRuleLandmarkToStateAngle(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, stateId: self.id, isScoreWarning: true)
                    case .VIOLATE:
                        violateRules[rulesIndex].addRuleLandmarkToStateAngle(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, stateId: self.id, isScoreWarning: false)
                    }
                }
            }
            
            mutating func removeRuleLandmarkToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].removeRuleLandmarkToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                case .VIOLATE:
                    violateRules[rulesIndex].removeRuleLandmarkToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                }
            }
            
            mutating func updateRuleLandmarkToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                    toStateId: Int,
                                                           isRelativeToExtremeDirection: Bool,
                                                           extremeDirection: ExtremeDirection,
                                                    toStateLandmark: Landmark,
                                                    lowerBound: Double, upperBound: Double,
                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        scoreRules[rulesIndex].updateRuleLandmarkToStateAngle(ruleId: ruleId, ruleClass: ruleClass,
                                                                         toStateId: toStateId,
                                                                                isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                                extremeDirection: extremeDirection,
                                                                         toStateLandmark: toStateLandmark,
                                                                         lowerBound: lowerBound, upperBound: upperBound,
                                                                         warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id, humanPose: self.humanPose!)
                    case .VIOLATE:
                        violateRules[rulesIndex].updateRuleLandmarkToStateAngle(ruleId: ruleId, ruleClass: ruleClass,
                                                                           toStateId: toStateId,
                                                                                  isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                                  extremeDirection: extremeDirection,
                                                                           toStateLandmark: toStateLandmark,
                                                                           lowerBound: lowerBound, upperBound: upperBound,
                                                                           warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id, humanPose: self.humanPose!)
                    }
                }
            }
    

//    -------------------
    
    func getRuleObjectToLandmarks(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [ObjectToLandmark] {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                return scoreRules[rulesIndex].getRuleObjectToLandmarks(ruleId: ruleId, ruleClass: ruleClass)
            case .VIOLATE:
                return violateRules[rulesIndex].getRuleObjectToLandmarks(ruleId: ruleId, ruleClass: ruleClass)
            }
        }
        
        return []
    }
    
    func getRuleObjectToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> ObjectToLandmark {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            return scoreRules[rulesIndex].getRuleObjectToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            return violateRules[rulesIndex].getRuleObjectToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    mutating func addRuleObjectToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].addRuleObjectToLandmark(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, objects: objects, isScoreWarning: true)
            case .VIOLATE:
                violateRules[rulesIndex].addRuleObjectToLandmark(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, objects: objects, isScoreWarning: false)
            }
        }
    }
    
    mutating func removeRuleObjectToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            scoreRules[rulesIndex].removeRuleObjectToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            violateRules[rulesIndex].removeRuleObjectToLandmark(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    mutating func updateRuleObjectToLandmark(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                             objectPosition: ObjectPosition,
                                                                                     fromAxis: CoordinateAxis,
                                                                                     toLandmarkType: LandmarkType,
                                                                                     toLandmarkSegmentType: LandmarkTypeSegment,
                                                                                     toAxis: CoordinateAxis,
                                             lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, id: UUID, isRelativeToObject: Bool) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].updateRuleObjectToLandmark(ruleId: ruleId, ruleClass: ruleClass,
                                                                  objectPosition: objectPosition,
                                                                  fromAxis: fromAxis,
                                                                  toLandmarkType: toLandmarkType,
                                                                  toLandmarkSegmentType: toLandmarkSegmentType,
                                                                  toAxis: toAxis,
                                                                  lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear,id: id,
                                                                  humanPose: humanPose!, objects: objects, isRelativeToObject: isRelativeToObject)

            case .VIOLATE:
                violateRules[rulesIndex].updateRuleObjectToLandmark(ruleId: ruleId, ruleClass: ruleClass,
                                                                    objectPosition: objectPosition,
                                                                    fromAxis: fromAxis,
                                                                    toLandmarkType: toLandmarkType,
                                                                    toLandmarkSegmentType: toLandmarkSegmentType,
                                                                    toAxis: toAxis,
                                                            lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id,
                                                                    humanPose: humanPose!, objects: objects, isRelativeToObject: isRelativeToObject)

            }
        }
    }
    
//    -------------------
    
    
    func getRuleObjectToObjects(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [ObjectToObject] {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                return scoreRules[rulesIndex].getRuleObjectToObjects(ruleId: ruleId, ruleClass: ruleClass)
            case .VIOLATE:
                return violateRules[rulesIndex].getRuleObjectToObjects(ruleId: ruleId, ruleClass: ruleClass)
            }
        }
        
        return []
    }
    
    func getRuleObjectToObject(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> ObjectToObject {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            return scoreRules[rulesIndex].getRuleObjectToObject(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            return violateRules[rulesIndex].getRuleObjectToObject(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    mutating func addRuleObjectToObject(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].addRuleObjectToObject(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, objects: objects, isScoreWarning: true)
            case .VIOLATE:
                violateRules[rulesIndex].addRuleObjectToObject(ruleId: ruleId, ruleClass: ruleClass, humanPose: humanPose!, objects: objects, isScoreWarning: false)
            }
        }
    }
    
    mutating func removeRuleObjectToObject(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            scoreRules[rulesIndex].removeRuleObjectToObject(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            violateRules[rulesIndex].removeRuleObjectToObject(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    mutating func updateRuleObjectToObject(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                           fromAxis: CoordinateAxis, fromObjectPosition: ObjectPosition, toObjectId: String, toObjectPosition: ObjectPosition, toLandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID, isRelativeToObject: Bool) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].updateRuleObjectToObject(ruleId: ruleId, ruleClass: ruleClass,
                                                                fromAxis: fromAxis,fromObjectPosition: fromObjectPosition,toObjectId: toObjectId, toObjectPosition: toObjectPosition, toLandmarkSegmentType: toLandmarkSegmentType, toAxis: toAxis,     lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id,
                                                                landmarkSegments: humanPose!.landmarkSegments, objects: objects, isRelativeToObject: isRelativeToObject)

            case .VIOLATE:
                violateRules[rulesIndex].updateRuleObjectToObject(ruleId: ruleId,  ruleClass: ruleClass,
                                                                  fromAxis: fromAxis,fromObjectPosition: fromObjectPosition,toObjectId: toObjectId, toObjectPosition: toObjectPosition, toLandmarkSegmentType: toLandmarkSegmentType, toAxis: toAxis,     lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id,
                                                                  landmarkSegments: humanPose!.landmarkSegments, objects: objects, isRelativeToObject: isRelativeToObject)

            }
        }
    }
    
    
    //    ----------------
            
            func getRuleObjectToStateDistances(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [ObjectToStateDistance] {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        return scoreRules[rulesIndex].getRuleObjectToStateDistances(ruleId: ruleId, ruleClass: ruleClass)
                    case .VIOLATE:
                        return violateRules[rulesIndex].getRuleObjectToStateDistances(ruleId: ruleId, ruleClass: ruleClass)
                    }
                }
                
                return []
            }
            
            func getRuleObjectToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> ObjectToStateDistance {
                let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
                switch ruleType {
                case .SCORE:
                    return scoreRules[rulesIndex].getRuleObjectToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
                case .VIOLATE:
                    return violateRules[rulesIndex].getRuleObjectToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
                }
            }
            
            mutating func addRuleObjectToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        scoreRules[rulesIndex].addRuleObjectToStateDistance(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments, stateId: self.id, objects: objects, isScoreWarning: true)
                    case .VIOLATE:
                        violateRules[rulesIndex].addRuleObjectToStateDistance(ruleId: ruleId, ruleClass: ruleClass, landmarkSegments: humanPose!.landmarkSegments, stateId: self.id, objects: objects, isScoreWarning: false)
                    }
                }
            }
            
            mutating func removeRuleObjectToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].removeRuleObjectToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
                case .VIOLATE:
                    violateRules[rulesIndex].removeRuleObjectToStateDistance(ruleId: ruleId, ruleClass: ruleClass, id: id)
                }
            }
            
            mutating func updateRuleObjectToStateDistance(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
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
                                                                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID)   {
                
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        scoreRules[rulesIndex].updateRuleObjectToStateDistance(ruleId: ruleId, ruleClass: ruleClass,
                                                                              fromAxis: fromAxis,
                                                                              toStateId: toStateId,
                                                                              fromPosition: fromPosition,
                                                                              toObject: toObject,
                                                                              isRelativeToObject: isRelativeToObject,
                                                                              isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                              extremeDirection: extremeDirection,
                                                                              toLandmarkSegmentType: toLandmarkSegmentType,
                                                                              toAxis: toAxis,
                                                                              lowerBound: lowerBound, upperBound: upperBound,
                                                                              warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet,
                                                                              delayTime: delayTime, changeStateClear: changeStateClear, id: id, landmarkSegments: humanPose!.landmarkSegments, objects: objects)

                    case .VIOLATE:
                        violateRules[rulesIndex].updateRuleObjectToStateDistance(ruleId: ruleId, ruleClass: ruleClass,
                                                                                fromAxis: fromAxis,
                                                                                toStateId: toStateId,
                                                                                fromPosition: fromPosition,
                                                                                toObject: toObject,
                                                                                isRelativeToObject: isRelativeToObject,
                                                                                isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                                extremeDirection: extremeDirection,
                                                                                toLandmarkSegmentType: toLandmarkSegmentType,
                                                                                toAxis: toAxis,
                                                                                lowerBound: lowerBound, upperBound: upperBound,
                                                                                warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet,
                                                                                delayTime: delayTime, changeStateClear: changeStateClear, id: id, landmarkSegments: humanPose!.landmarkSegments, objects: objects)

                    }
                }
            }
        
    
    
    //    ----------------
            
            func getRuleObjectToStateAngles(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [ObjectToStateAngle] {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        return scoreRules[rulesIndex].getRuleObjectToStateAngles(ruleId: ruleId, ruleClass: ruleClass)
                    case .VIOLATE:
                        return violateRules[rulesIndex].getRuleObjectToStateAngles(ruleId: ruleId, ruleClass: ruleClass)
                    }
                }
                
                return []
            }
            
            func getRuleObjectToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> ObjectToStateAngle {
                let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
                switch ruleType {
                case .SCORE:
                    return scoreRules[rulesIndex].getRuleObjectToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                case .VIOLATE:
                    return violateRules[rulesIndex].getRuleObjectToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                }
            }
            
            mutating func addRuleObjectToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        scoreRules[rulesIndex].addRuleObjectToStateAngle(ruleId: ruleId, ruleClass: ruleClass, stateId: self.id, objects: objects, isScoreWarning: true)
                    case .VIOLATE:
                        violateRules[rulesIndex].addRuleObjectToStateAngle(ruleId: ruleId, ruleClass: ruleClass, stateId: self.id, objects: objects, isScoreWarning: false)
                    }
                }
            }
            
            mutating func removeRuleObjectToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].removeRuleObjectToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                case .VIOLATE:
                    violateRules[rulesIndex].removeRuleObjectToStateAngle(ruleId: ruleId, ruleClass: ruleClass, id: id)
                }
            }
            
            mutating func updateRuleObjectToStateAngle(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                                                                    toStateId: Int,
                                                                                             fromPosition: ObjectPosition,
                                                         toObject: Observation,
                                                                                               isRelativeToExtremeDirection: Bool,
                                                                                               extremeDirection: ExtremeDirection,

                                                                                                    lowerBound: Double, upperBound: Double,
                                                                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID)   {
                
                if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                    switch ruleType {
                    case .SCORE:
                        scoreRules[rulesIndex].updateRuleObjectToStateAngle(ruleId: ruleId, ruleClass: ruleClass,
                                                                              toStateId: toStateId,
                                                                              fromPosition: fromPosition,
                                                                              toObject: toObject,
                                                                              isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                              extremeDirection: extremeDirection,
                                                                              lowerBound: lowerBound, upperBound: upperBound,
                                                                              warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet,
                                                                              delayTime: delayTime,changeStateClear: changeStateClear,  id: id,
                                                                             objects: objects)

                    case .VIOLATE:
                        violateRules[rulesIndex].updateRuleObjectToStateAngle(ruleId: ruleId, ruleClass: ruleClass,
                                                                                toStateId: toStateId,
                                                                                fromPosition: fromPosition,
                                                                                toObject: toObject,
                                                                                isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                                extremeDirection: extremeDirection,
                                                                                lowerBound: lowerBound, upperBound: upperBound,
                                                                                warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet,
                                                                                delayTime: delayTime, changeStateClear: changeStateClear, id: id,
                                                                              objects: objects)

                    }
                }
            }
    
    
    //    -------------------
    

    
    mutating func generatorFixedArea(areaId: String, area: [Point2D]) {
        
        scoreRules.indices.forEach({ rulesIndex in
            scoreRules[rulesIndex].generatorFixedArea(areaId: areaId, area: area)
        })
            
        violateRules.indices.forEach({ rulesIndex in
            violateRules[rulesIndex].generatorFixedArea(areaId: areaId, area: area)
        })
    }
    
    mutating func generatorDynamicArea(areaId: String, area: [Point2D]) {
        
        scoreRules.indices.forEach({ rulesIndex in
            scoreRules[rulesIndex].generatorDynamicArea(areaId: areaId, area: area)
        })
            
        violateRules.indices.forEach({ rulesIndex in
            violateRules[rulesIndex].generatorDynamicArea(areaId: areaId, area: area)
        })
    }
    

    
    

    
    
//    ---------------------
    
    func getRuleLandmarkInFixedAreasForAreaRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkInAreaForAreaRule] {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            switch ruleType {
            case .SCORE:
                return scoreRules[rulesIndex].getRuleLandmarkInFixedAreasForAreaRule(ruleId: ruleId, ruleClass: ruleClass)
            case .VIOLATE:
                return violateRules[rulesIndex].getRuleLandmarkInFixedAreasForAreaRule(ruleId: ruleId, ruleClass: ruleClass)
            }
        }
        
        return []
    }

func getRuleLandmarkInFixedAreaForAreaRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkInAreaForAreaRule {
    let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!

    switch ruleType {
    case .SCORE:
        return scoreRules[rulesIndex].getRuleLandmarkInFixedAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, id: id)
    case .VIOLATE:
        return violateRules[rulesIndex].getRuleLandmarkInFixedAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, id: id)
    }
}
    
    mutating func addRuleLandmarkInFixedAreaForAreaRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, fixedArea: [Point2D]) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {

            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].addRuleLandmarkInFixedAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, landmarks: humanPose!.landmarks, imageSize: image!.imageSize.point2d, isScoreWarning: true, area: fixedArea)
            case .VIOLATE:
                violateRules[rulesIndex].addRuleLandmarkInFixedAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, landmarks: humanPose!.landmarks, imageSize: image!.imageSize.point2d, isScoreWarning: false, area: fixedArea)
            }
        }
    }
    
    
    mutating func removeRuleLandmarkInFixedAreaForAreaRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
        switch ruleType {
        case .SCORE:
            scoreRules[rulesIndex].removeRuleLandmarkInFixedAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            violateRules[rulesIndex].removeRuleLandmarkInFixedAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
    
    mutating func updateRuleLandmarkInFixedAreaForAreaRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                      area: [Point2D], warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, landmarkType: LandmarkType, id: UUID) {
        if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
            let imageSize = self.image!.imageSize.point2d
            let landmark = humanPose!.landmarks.first(where: { landmark in
                landmark.id == landmarkType.id
            })!
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].updateRuleLandmarkInFixedAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass,
                                                                area: area, imageSize: imageSize, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,
                                                                           landmark: landmark,
                                                                           id: id)

            case .VIOLATE:
                violateRules[rulesIndex].updateRuleLandmarkInFixedAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass,
                                                                   area: area, imageSize: imageSize, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,
                                                                             landmark: landmark,
                                                                             id: id)

            }
        }
    }
    
    
    //    ---------------------
        
        func getRuleLandmarkInDynamicAreasForAreaRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkInAreaForAreaRule] {
            if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                switch ruleType {
                case .SCORE:
                    return scoreRules[rulesIndex].getRuleLandmarkInDynamicAreasForAreaRule(ruleId: ruleId, ruleClass: ruleClass)
                case .VIOLATE:
                    return violateRules[rulesIndex].getRuleLandmarkInDynamicAreasForAreaRule(ruleId: ruleId, ruleClass: ruleClass)
                }
            }
            
            return []
        }

    func getRuleLandmarkInDynamicAreaForAreaRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkInAreaForAreaRule {
        let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!

        switch ruleType {
        case .SCORE:
            return scoreRules[rulesIndex].getRuleLandmarkInDynamicAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, id: id)
        case .VIOLATE:
            return violateRules[rulesIndex].getRuleLandmarkInDynamicAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, id: id)
        }
    }
        
        mutating func addRuleLandmarkInDynamicAreaForAreaRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, fixedArea: [Point2D]) {
            if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {

                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].addRuleLandmarkInDynamicAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, landmarks: humanPose!.landmarks, imageSize: image!.imageSize.point2d, isScoreWarning: true, area: fixedArea)
                case .VIOLATE:
                    violateRules[rulesIndex].addRuleLandmarkInDynamicAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, landmarks: humanPose!.landmarks, imageSize: image!.imageSize.point2d, isScoreWarning: false, area: fixedArea)
                }
            }
        }
        
        
        mutating func removeRuleLandmarkInDynamicAreaForAreaRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
            let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType)!
            switch ruleType {
            case .SCORE:
                scoreRules[rulesIndex].removeRuleLandmarkInDynamicAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, id: id)
            case .VIOLATE:
                violateRules[rulesIndex].removeRuleLandmarkInDynamicAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass, id: id)
            }
        }
        
        mutating func updateRuleLandmarkInDynamicAreaForAreaRule(rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                          area: [Point2D], warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, landmarkType: LandmarkType, id: UUID) {
            if let rulesIndex = firstIndexOfRules(editedRulesId: rulesId, ruleType: ruleType) {
                let imageSize = self.image!.imageSize.point2d
                let landmark = humanPose!.landmarks.first(where: { landmark in
                    landmark.id == landmarkType.id
                })!
                switch ruleType {
                case .SCORE:
                    scoreRules[rulesIndex].updateRuleLandmarkInDynamicAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass,
                                                                    area: area, imageSize: imageSize, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,
                                                                               landmark: landmark,
                                                                               id: id)

                case .VIOLATE:
                    violateRules[rulesIndex].updateRuleLandmarkInDynamicAreaForAreaRule(ruleId: ruleId, ruleClass: ruleClass,
                                                                       area: area, imageSize: imageSize, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,
                                                                                 landmark: landmark,
                                                                                 id: id)

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
