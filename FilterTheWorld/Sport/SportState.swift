
import Foundation
import UIKit


typealias SportStateUUID = Int

struct SportState: Identifiable, Equatable, Hashable, Codable {

  static var startState = SportState(id: 1, name: "Start", description: "start")
  static var endState = SportState(id: 2, name: "End", description: "end")
  
  var id: SportStateUUID = -1
  var name:String = ""
  var description:String = ""
  var isScore: Bool = false
  var image: PngImage?
  var landmarkSegments :[LandmarkSegment] = []
  var rules : [[SimpleRule]] = []
  // 计分规则
  var complexScoreRules:[ComplexRules] = []
  // 违规规则 用于提示
  var complexViolateRules:[ComplexRules] = []
  
  
  static func == (lhs: SportState, rhs: SportState) -> Bool {
    lhs.name == rhs.name
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
  
  func rulesSatisfy(poseMap:PoseMap) -> Bool {
    rules.contains{ simpleRules in
      simpleRules.allSatisfy{ simpleRule in
        simpleRule.angleSatisfy(poseMap: poseMap)
      }
    }
  }
  
  
  func currentStateViolateWarning(poseMap: PoseMap) -> [Set<String>] {
    complexViolateRules.map{rules in
      rules.currentRulesWarnings(poseMap: poseMap)
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
  
  func complexScoreRulesSatisfy(poseMap:PoseMap) -> Bool {
    // 只要有一组条件满足
    complexScoreRules.contains{ complexRules in
      // 每一组条件全部满足
      (!complexRules.rules.isEmpty) && complexRules.rules.allSatisfy{ complexRule in
        complexRule.allSatisfy(poseMap: poseMap)
      }
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
  


  
  func firstComplexRulesById(editedRulesId: UUID, ruleType: RuleType) -> ComplexRules? {
    switch ruleType {
    case .SCORE:
      return
      complexScoreRules.first(where: { rules in
        editedRulesId == rules.id
      })
    case .VIOLATE:
      return complexViolateRules.first(where: { rules in
        editedRulesId == rules.id
      })
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
  
  func firstIndexOfLandmarkSegment(editedSportStateRuleId: String) -> Int? {
    landmarkSegments.firstIndex(where: { landmarkSegment in
      landmarkSegment.landmarkSegmentType.id == editedSportStateRuleId
    })
  }

  
  mutating func setSegmentToSelected(editedSportStateRuleId: String?) {
    let range = 0..<landmarkSegments.count
    range.forEach{ index in
      landmarkSegments[index].selected = false
    }
    if let editedSportStateRuleId = editedSportStateRuleId,
        let index = firstIndexOfLandmarkSegment(editedSportStateRuleId: editedSportStateRuleId){
        landmarkSegments[index].selected = true
    }

    
  }
  
  func findselectedSegment(editedSportStateRuleId: String) -> LandmarkSegment? {
    if let index = firstIndexOfLandmarkSegment(editedSportStateRuleId: editedSportStateRuleId) {
      return landmarkSegments[index]
    }
    
    return nil
  }
  
  
  
  
  
}
