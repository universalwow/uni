

import Foundation
import UIKit


struct SportStateTransform: Identifiable, Hashable, Codable {
  var from: SportStateUUID
  var to: SportStateUUID
  var id = UUID()
  
}

struct Sport: Identifiable, Hashable, Codable {
  static func == (lhs: Sport, rhs: Sport) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
          hasher.combine(id)
      }
  
  var id = UUID()
  var name:String = ""
  var description:String = ""
  var states: [SportState] = [] {
    didSet {
    }
    
  }
  
  var stateTransForm: [SportStateTransform] = []
  var startState:SportState = SportState.startState
  var endState:SportState = SportState.endState

  var currentState:SportState = SportState.startState
  
  var scoreTimes: [Double] = []
  var totalWarnings: Set<String> = []
  // 当前帧提示，所有存留提示
  var cancelingWarnings: Set<String> = []
  var newWarnings: Set<String> = []
  
  
  
  
}

extension Sport {
  
  var allStates: [SportState]  {
    states + [startState, endState]
  }
  
  
  func firstStateIndexByStateName(editedStateName: String) -> Int? {
    states.firstIndex(where: { state in
      state.name == editedStateName
    })
    
  }
  
  func firstStateIndexByStateID(editedStateUUID: SportStateUUID) -> Int? {
    states.firstIndex(where: { state in
      state.id == editedStateUUID
    })
    
  }
  
  
  mutating func setSportStateImage(editedStateId: SportStateUUID, image: UIImage, landmarkSegments: [LandmarkSegment]) {
    if let index = firstSportStateIndexByUUID(sportStateUUID: editedStateId) {
      states[index].image = PngImage(photo: image)
      states[index].landmarkSegments = landmarkSegments
    }
  }
  
  func findFirstSportStateByUUID(editedStateUUID: SportStateUUID) -> SportState? {
    if let sportStateIndex = firstStateIndexByStateID(editedStateUUID: editedStateUUID) {
      return states[sportStateIndex]
    }else {
      return nil
    }
  }
  
  
  mutating func setupLandmarkArea(editedSportStateId: SportStateUUID, editedSportStateRulesId: UUID, editedSportStateRule: ComplexRule, ruleType: RuleType, landmarkinArea: LandmarkInArea?) {
    if let index = firstStateIndexByStateID(editedStateUUID: editedSportStateId) {
      states[index].setupLandmarkArea(editedSportStateRulesId: editedSportStateRulesId, editedSportStateRule: editedSportStateRule, ruleType: ruleType, landmarkinArea: landmarkinArea)
    }
  }
  
  var maxStateId: SportStateUUID {
    allStates.map{ state in
      state.id
    }.max()!
  }
  
  mutating func updateState(stateName: String, stateDescription: String) {
    if let index = firstStateIndexByStateName(editedStateName: stateName) {
      states[index].name = stateName
      states[index].description = stateDescription
    }else{
      addNewState(state: SportState(id: maxStateId + 1, name: stateName, description: stateDescription))
    }
  }
  
  mutating func updateStateIsScore(stateName: String, isScore:Bool) {
    if let index = firstStateIndexByStateName(editedStateName: stateName) {
      states[index].isScore = isScore
    }
  }

  
  mutating func addNewState(state: SportState) {
    states.append(state)
  }
  
  mutating func addNewSportStateRules(editedSportState: SportState, ruleType: RuleType) {
    if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
      switch ruleType {
      case .SCORE:
        states[index].complexScoreRules.append(ComplexRules(rules: [], description: "计分规则集"))
      case .VIOLATE:
        states[index].complexViolateRules.append(ComplexRules(rules: [], description: "违规规则集"))
      }
    }
  }
  
  mutating func deleteSportStateRules(editedSportState: SportState, editedRulesId: UUID, ruleType: RuleType) {
    if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
      states[index].deleteSportStateRules(rulesId: editedRulesId, ruleType: ruleType)

    }
  }
  
  mutating func deleteState(state: SportState) {
    
    if let index = firstStateIndexByStateID(editedStateUUID: state.id) {
      states.remove(at: index)
      updateStateTransform()
    }
  }
  
  // 每个状态都设置了相应的规则 则已经被设置
  var ruleHasSetuped: Bool {
    states.count ==  states.reduce(0, {(result, state) in
      (!state.rules.isEmpty ? 1 : 0) + result
    })
  }
  
  // 规则完整度
  var ruleIntegrity:Double {
    Double(states.reduce(0, {(result, state) in
      (!state.rules.isEmpty ? 1 : 0) + result
    }))/Double(states.count)
  }
  

  
  
  var sportFileName : String {
    "\(self.id).json"
  }
  
  mutating func updateStateRule(selectedState: SportState, humanposes: [HumanPose]) {
    if let sportIndex = firstStateIndexByStateName(editedStateName: selectedState.name) {
      states[sportIndex].rules = []
      humanposes.forEach{ pose in
        
        var rules: [SimpleRule] = []
        pose.landmarkSegments.forEach{ landmarkSegment in
          if landmarkSegment.selected && landmarkSegment.angleRange != nil {
            rules.append(SimpleRule(landmarkSegmentType: LandmarkTypeSegment(startLandmarkType: landmarkSegment.startLandmark.landmarkType , endLandmarkType: landmarkSegment.endLandmark.landmarkType), angleRange: landmarkSegment.angleRange!))
          }
        }
        
        if !rules.isEmpty {
          states[sportIndex].rules.append(rules)
        }
      }
      if !states[sportIndex].rules.isEmpty {
        Storage.store(self, as: sportFileName)
      }
      
    }
    
  }
  
  mutating func updateStateTransform() {
    var newStateTransForm:[SportStateTransform] = []
    
    
    stateTransForm.forEach{ transform in
      let fromTransform = allStates.first{ state in
        state.id == transform.from
      }
      
      let toTransform = allStates.first{ state in
        state.id == transform.to
      }
      
      
      if let fromTransform = fromTransform, let toTransform = toTransform {
        newStateTransForm.append(SportStateTransform(from: fromTransform.id , to: toTransform.id))
      }
      
      
    }
    stateTransForm = newStateTransForm
  }
  
  func firstSportStateIndexByUUID(sportStateUUID: SportStateUUID) -> Int? {
    allStates.firstIndex(where: { state in
      state.id == sportStateUUID
      
    })
  }
  
  func firstSportStateIndexByName(sportStateName: String) -> Int? {
    allStates.firstIndex(where: { state in
      state.name == sportStateName
      
    })
  }
  
  
  func findSportStateByName(sportStateName: String) -> SportState? {
    if let index = firstSportStateIndexByName(sportStateName: sportStateName) {
      return allStates[index]
    }
    return nil
    
  }
  
  func findSportStateByUUID(sportStateUUID: SportStateUUID) -> SportState? {
    if let index = firstSportStateIndexByUUID(sportStateUUID: sportStateUUID) {
      return allStates[index]
    }
    return nil
    
  }
  
  
  mutating func addStateTransform(fromSportState:SportState, toSportState: SportState) {
    if !stateTransForm.contains(where: { transform in
      transform.from == fromSportState.id &&
      transform.to == toSportState.id
      
    }) {
      stateTransForm.append(SportStateTransform(from: fromSportState.id, to: toSportState.id))
    }
  }
  
  mutating func deleteStateTransForm(fromSportState:SportState, toSportState: SportState) {
    stateTransForm.removeAll{ transform in
      transform.from == fromSportState.id &&
      transform.to == toSportState.id
    }
  }
  
  
  mutating func updateSportStateRule(editedSportStateUUID: SportStateUUID, editedSportStateRulesId: UUID, editedRule: ComplexRule, ruleType: RuleType) {
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID){
      states[stateIndex].updateSportStateRule(editedSportStateRulesId: editedSportStateRulesId, editedRule: editedRule, ruleType: ruleType)
    }
  }
  
  
  mutating func play(poseMap:PoseMap, currentTime: Double) {
    if let lastScoreTime = scoreTimes.last, (lastScoreTime >= currentTime) {
      scoreTimes.removeAll{ scoreTime in
        scoreTime >= currentTime
      }
      currentState  = startState
    }
//    print("----------1")

    
    // 违规逻辑
    stateTransForm.forEach({ transform in
      if currentState.id == transform.from {
        if let toState = findSportStateByUUID(sportStateUUID: transform.to) {
          var allCurrentFrameWarnings:Set<String> = []
          toState.currentStateViolateWarning(poseMap: poseMap).forEach{ warns in
            allCurrentFrameWarnings = allCurrentFrameWarnings.union(warns)
          }


          // 取消的提示
          cancelingWarnings = totalWarnings.subtracting(allCurrentFrameWarnings)
          // 当前新添加
          newWarnings = allCurrentFrameWarnings.subtracting(totalWarnings)
          
          // 之前存在的提示
          let oldWarnings = totalWarnings.intersection(allCurrentFrameWarnings)
          totalWarnings = newWarnings.union(oldWarnings)
        }
        }
      })
    
    
    // 计分逻辑
    stateTransForm.forEach({ transform in
      if currentState.id == transform.from {
        if let toState = findSportStateByUUID(sportStateUUID: transform.to) {
          if toState.complexScoreRulesSatisfy(poseMap: poseMap) {
            if toState.isScore {
              scoreTimes.append(currentTime)
              
            }
            currentState = toState
    
          }
        }
        
      }
    })
  }
  
  
  mutating func setSegmentToSelected(editedSportStateUUID: SportStateUUID, editedSportStateRuleId: String?) {
    
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID) {
      states[stateIndex].setSegmentToSelected(editedSportStateRuleId: editedSportStateRuleId)
    }
  }
  func findselectedSegment(editedSportStateUUID: SportStateUUID, editedSportStateRuleId: String) -> LandmarkSegment? {
    
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID) {
      return states[stateIndex].findselectedSegment(editedSportStateRuleId: editedSportStateRuleId)
    }
    return nil
  }
  
  
  func findSelectedSegments(editedSportStateUUID: SportStateUUID) -> [LandmarkSegment]? {
    
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID) {
      return states[stateIndex].landmarkSegments
    }
    return nil
  }
}
