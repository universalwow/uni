
import Foundation


struct SportState: Identifiable, Equatable, Hashable, Codable {
  
  var id: Int = -1
  var name:String = ""
  var description:String = ""
  var image: PngImage?
  var landmarkSegments :[LandmarkSegment] = []
  var objects: [Observation] = []
  
  // MARK: TO DELETE
  // TODO: 状态对应的规则 时间限制 一定时间内没有切换状态
  var transFormTimeLimit: Double? 
  var rules : [[SimpleRule]] = []
  // 计分规则 关节点对应的规则
  var complexScoreRules:[ComplexRules] = []
  // 违规规则 用于提示
  var complexViolateRules:[ComplexRules] = []
  

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
  
  
  
  func firstIndexOfComplexRules(editedRulesId: UUID, ruleType: RuleType) -> Int? {
    switch ruleType {
    case .SCORE:
      return complexScoreRules.firstIndex(where: { rules in
        editedRulesId == rules.id
      })
    case .VIOLATE:
      return complexViolateRules.firstIndex(where: { rules in
        editedRulesId == rules.id
      })
    }
  }
  
  func findComplexRulesList(ruleType: RuleType) -> [ComplexRules] {
    switch ruleType {
    case .SCORE:
      return complexScoreRules
    case .VIOLATE:
      return complexViolateRules
    }
  }
  
  func findComplexRules(ruleType: RuleType, currentSportStateRulesId: UUID) -> ComplexRules? {
    findComplexRulesList(ruleType: ruleType)
      .first(where: { rules in
        currentSportStateRulesId == rules.id
      })
  }
  
  func firstComplexRulesById(editedRulesId: UUID, ruleType: RuleType) -> ComplexRules? {
    switch ruleType {
    case .SCORE:
      return complexScoreRules.first(where: { rules in
        editedRulesId == rules.id
      })
    case .VIOLATE:
      return complexViolateRules.first(where: { rules in
        editedRulesId == rules.id
      })
    }
  }
  
  mutating func updateSportStateRule(editedSportStateRulesId: UUID, editedRule: ComplexRule, ruleType: RuleType) {
      if let rulesIndex = firstIndexOfComplexRules(editedRulesId: editedSportStateRulesId, ruleType: ruleType) {
        switch ruleType {
          case .SCORE:
            complexScoreRules[rulesIndex].updateSportStateRule(editedRule: editedRule)

          case .VIOLATE:
            complexViolateRules[rulesIndex].updateSportStateRule(editedRule: editedRule)
          }
    }
    
  }
  
  mutating func dropInvalidRules(editedSportStateRulesId: UUID, ruleType: RuleType) {
      if let rulesIndex = firstIndexOfComplexRules(editedRulesId: editedSportStateRulesId, ruleType: ruleType) {
        switch ruleType {
          case .SCORE:
            complexScoreRules[rulesIndex].dropInvalidRules()

          case .VIOLATE:
            complexViolateRules[rulesIndex].dropInvalidRules()
          }
    }
    
  }
  
  
  
  mutating func deleteSportStateRules(rulesId: UUID, ruleType: RuleType) {
    if let index = firstIndexOfComplexRules(editedRulesId: rulesId, ruleType: ruleType) {
      switch ruleType {
      case .SCORE:
        complexScoreRules.remove(at: index)
      case .VIOLATE:
        complexViolateRules.remove(at: index)
      }
    }
  }
    
    mutating func deleteSportStateRule(rulesId: UUID, ruleType: RuleType, ruleId:String) {
      if let index = firstIndexOfComplexRules(editedRulesId: rulesId, ruleType: ruleType) {
        switch ruleType {
        case .SCORE:
            complexScoreRules[index].rules.removeAll{ rule in
                rule.id == ruleId
            }
        case .VIOLATE:
          complexViolateRules[index].rules.removeAll{ rule in
              rule.id == ruleId
          }
        }
      }
    }
  
  func firstIndexOfLandmarkSegment(editedSportStateRuleId: String?) -> Int? {
    landmarkSegments.firstIndex(where: { landmarkSegment in
      landmarkSegment.landmarkSegmentType.id == editedSportStateRuleId
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
  
  mutating func setSegmentToSelected(editedSportStateRuleId: String?) {
    let range = 0..<landmarkSegments.count
    range.forEach{ index in
      landmarkSegments[index].selected = false
    }
    if let editedSportStateRuleId = editedSportStateRuleId,
        let index = firstIndexOfLandmarkSegment(editedSportStateRuleId: editedSportStateRuleId){
        landmarkSegments[index].selected = true
      print("editedSportStateRuleId \(landmarkSegments[index].selected)")
    }else{
        landmarkSegments.indices.forEach{ index in
            landmarkSegments[index].selected = false
        }
    }
  }
  
  
  mutating func setupLandmarkArea(editedSportStateRulesId: UUID, editedSportStateRule: ComplexRule, ruleType: RuleType, landmarkinArea: LandmarkInArea?) {
    
    if let rulesIndex = firstIndexOfComplexRules(editedRulesId: editedSportStateRulesId, ruleType: ruleType) {
      switch ruleType {
        case .SCORE:
        complexScoreRules[rulesIndex].setupLandmarkArea(editedSportStateRule: editedSportStateRule, landmarkinArea: landmarkinArea)

        case .VIOLATE:
        complexViolateRules[rulesIndex].setupLandmarkArea(editedSportStateRule: editedSportStateRule, landmarkinArea: landmarkinArea)
      }
    
    }
  }
  
  func complexScoreRulesSatisfy(ruleType: RuleType, stateTimeHistory: [StateTime], poseMap:PoseMap, object: Observation?) -> (Bool, Set<String>) {
    
    var rules : [ComplexRules] = []
    switch ruleType {
      case .SCORE:
        rules = complexScoreRules
      case .VIOLATE:
        rules = complexViolateRules
    }
    // 只要有一组条件满足
    return rules.reduce((false, Set<String>()), { result, complexRules in
        // 每一组条件全部满足
  //      (!complexRules.rules.isEmpty) &&
      let rulesSatisfy = complexRules.rules.reduce((true, Set<String>()), { satisfy, complexRule in
        let ruleSatisfy = complexRule.allSatisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object)
//        print("rule satisfy ... \(ruleSatisfy)")
        return (satisfy.0 && ruleSatisfy.0, satisfy.1.union(ruleSatisfy.1))
      })
      
      return (result.0 || rulesSatisfy.0, result.1.union(rulesSatisfy.1))
      
    })
  }
  
  func findLandmarkSegment(id: String) -> LandmarkSegment {
    landmarkSegments.first{ landmarkSegment in
      landmarkSegment.id == id
    }!
  }
  
}
