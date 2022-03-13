

import Foundation

struct SportStateTransform: Identifiable, Hashable, Codable {
  var from: Int
  var to: Int
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
      // 删除操作 更新状态转换 和 计分状态列表
      if states.count < oldValue.count {
        updateStateTransform()
        updateScoreStateSequence()
      }
    }
    
  }
  
  var stateTransForm: [SportStateTransform] = []
  var scoreStateSequence: [SportState] = []
  
  // 时间限制 秒
  var scoreTimeLimit:Double?
}

extension Sport {
  
  var sportFileName : String {
    "\(self.id).json"
  }
  var allStates: [SportState]  {
    states + [SportState.startState, SportState.endState]
  }
  
  
  var maxStateId: Int {
    allStates.map{ state in
      state.id
    }.max()!
  }

  // MARK: state
  
  func firstStateIndexByStateName(editedStateName: String) -> Int? {
    allStates.firstIndex(where: { state in
      state.name == editedStateName
    })
  }
  
  func firstStateIndexByStateID(editedStateUUID: Int) -> Int? {
    allStates.firstIndex(where: { state in
      state.id == editedStateUUID
      
    })
  }
  
  func findFirstSportStateByUUID(editedStateUUID: Int) -> SportState? {
    if let index = firstStateIndexByStateID(editedStateUUID: editedStateUUID) {
      return allStates[index]
    }
    return nil
  }
  
  
  mutating private func addState(state: SportState) {
    states.append(state)
  }
  
  mutating func addState(stateName: String, stateDescription: String) {
    let state = SportState(id: maxStateId + 1, name: stateName, description: stateDescription)
    addState(state: state)
  }
  
  mutating func updateSport(state: SportState) {
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: state.id) {
      states[stateIndex] = state
    }
  }
  
  mutating func updateState(stateName: String, stateDescription: String) {
    if let index = firstStateIndexByStateName(editedStateName: stateName) {
      states[index].name = stateName
      states[index].description = stateDescription
    }
  }
  
  mutating func deleteState(state: SportState) {
    if let index = firstStateIndexByStateID(editedStateUUID: state.id) {
      states.remove(at: index)
    }
  }

  
  mutating private func updateStateTransform() {
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
  
  
  mutating func addSportStateScoreSequence(scoreState: SportState) {
    scoreStateSequence.append(scoreState)
  }
  
  mutating func deleteSportStateScoreSequence() {
    scoreStateSequence.removeAll()
  }
  
  
  mutating private func updateScoreStateSequence() {
    var newScoreStates:[SportState] = []
    
    scoreStateSequence.forEach{ scoreState in
      let newScoreState = allStates.first{ state in
        state.id == scoreState.id
      }
      
      if let newScoreState = newScoreState {
        newScoreStates.append(newScoreState)
      }
    }
    scoreStateSequence = newScoreStates
  }
  
  
  // MARK: rule
//  mutating func setupLandmarkArea(editedSportStateId: SportStateUUID, editedSportStateRulesId: UUID, editedSportStateRule: ComplexRule, ruleType: RuleType, landmarkinArea: LandmarkInArea?) {
//    if let index = firstStateIndexByStateID(editedStateUUID: editedSportStateId) {
//      states[index].setupLandmarkArea(editedSportStateRulesId: editedSportStateRulesId, editedSportStateRule: editedSportStateRule, ruleType: ruleType, landmarkinArea: landmarkinArea)
//    }
//  }
  
  
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
  
  mutating func addSportStateRule(editedSportStateUUID: Int, editedSportStateRulesId: UUID, editedRule: ComplexRule, ruleType: RuleType) {
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID){
      states[stateIndex].updateSportStateRule(editedSportStateRulesId: editedSportStateRulesId, editedRule: editedRule, ruleType: ruleType)
    }
  }
  
  mutating func updateSportStateRule(editedSportStateUUID: Int, editedSportStateRulesId: UUID, editedRule: ComplexRule, ruleType: RuleType) {
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID){
      states[stateIndex].updateSportStateRule(editedSportStateRulesId: editedSportStateRulesId, editedRule: editedRule, ruleType: ruleType)
    }
  }
  
  
  
  
  mutating func dropInvalidComplexRule(editedSportStateUUID: Int, editedSportStateRulesId: UUID, ruleType: RuleType) {
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID){
      states[stateIndex].dropInvalidRules(editedSportStateRulesId: editedSportStateRulesId, ruleType: ruleType)
    }
  }
  

  
  mutating func deleteSportStateRules(editedSportState: SportState, editedRulesId: UUID, ruleType: RuleType) {
    if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
      states[index].deleteSportStateRules(rulesId: editedRulesId, ruleType: ruleType)

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

  
  mutating func setSegmentToSelected(editedSportStateUUID: Int, editedSportStateRuleId: String?) {
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID) {
      states[stateIndex].setSegmentToSelected(editedSportStateRuleId: editedSportStateRuleId)
    }
  }
  

}
