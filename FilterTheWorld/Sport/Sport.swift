

import Foundation

struct SportStateTransform: Identifiable, Hashable, Codable {
  var from: Int
  var to: Int
  var id = UUID()
  
}

enum SportPeriod: String, Codable, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    case CompletePeriod
    case HarfPeriod
    case Continuous
    case Discrete
    case None
    
    static func filteredCases(sportClass: SportClass) -> [SportPeriod] {
        switch sportClass {
        case .Counter:
            return [.CompletePeriod, HarfPeriod]
        case .Timer:
            return [.Discrete]
        case .TimeCounter:
            return [.Continuous, Discrete]
        case .None:
            return Self.allCases
        }
    }
}

enum SportClass: String, Codable, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    case Counter
    case Timer
    case TimeCounter
    case None
}


struct ViolateSequenceAndWarning: Codable {
    var warning: String = ""
    var stateIds: [Int] = []
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
    var states: [SportState] = [SportState.startState, SportState.endState, SportState.readyState] {
    didSet {
      // 删除操作 更新状态转换 和 计分状态列表
      if states.count < oldValue.count {
        updateStateTransform()
        updateScoreStateSequence()
      }
    }
    
  }
    
    
    
  
  var stateTransForm: [SportStateTransform] = []
  //MARK: 添加计分状态序列 使之可用于半周期
  var scoreStateSequence: [[Int]] = []
  var violateStateSequence: [ViolateSequenceAndWarning] = []
    
    //需要收集的关节点或者物体
    var selectedLandmarkTypes : [LandmarkType] = []
    var collectedObjects : [String] = []
    

  // 时间限制 秒
  var scoreTimeLimit:Double?
  var warningDelay: Double?
  var sportClass:SportClass?
    var sportPeriod:SportPeriod?
    var noStateWarning: String?
}


struct StateDescription: Identifiable, Codable {
    var stateId: Int
    var stateName: String
    var checkCycle: Double?
    var keepCycle: Double?
    var id: Int {
        stateId
    }
}

extension Sport {
    
  static var newSport: Sport = Sport(name: "New")
  
  var sportFileName : String {
      let v:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    return "\(self.id)_\(v).json"
  }
  
    var sportFullName: String {
        "\(self.name)-\(self.sportClass!.rawValue)-\(self.sportPeriod!.rawValue)"
    }
  
  var allStates: [SportState]  {
    states
  }
    
    var statesDescription: [StateDescription] {
        self.states.map { sportState in
            StateDescription(
                stateId: sportState.id, stateName: sportState.name, checkCycle: sportState.checkCycle, keepCycle: sportState.keepTime)
        }
    }
  
    var allHasKeyFrameStates: [SportState]  {
        states.filter({ state in
            state.image != nil
        })
    }
    
    
  
  
  var allImageSettedState: [SportState] {
    states.filter { state in
      state.image != nil
      
    }
  }
    
    
    var objects: [Observation] {
        if let state = states.first(where: { state in
            state.image != nil
        }) {
            return state.objects
        }
        return []
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
    } else {
      addState(stateName: stateName, stateDescription: stateDescription)
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
        print("addStateTransform \(fromSportState.name) -> \(toSportState.name)")
      stateTransForm.append(SportStateTransform(from: fromSportState.id, to: toSportState.id))
    }
  }
  
  mutating func deleteStateTransForm(fromSportState:SportState, toSportState: SportState) {
    stateTransForm.removeAll{ transform in
      transform.from == fromSportState.id &&
      transform.to == toSportState.id
    }
  }
    
    mutating func addSportStateScoreSequence(index: Int, scoreState: SportState) {
        scoreStateSequence[index].append(scoreState.id)
    }
    
    mutating func addSportStateViolateSequence(index: Int, violateState: SportState, warning: String) {
        violateStateSequence[index].stateIds.append(violateState.id)
        violateStateSequence[index].warning = warning
    }
    
    mutating func addSportStateScoreSequence() {
      scoreStateSequence.append([])
    }
    
    mutating func addSportStateViolateSequence() {
      violateStateSequence.append(ViolateSequenceAndWarning())
    }
  
  mutating func deleteSportStateScoreSequence() {
    scoreStateSequence.removeAll()
  }
    
    
    mutating func deleteSportStateFromScoreSequence(sequenceIndex: Int, stateIndex: Int) {
        scoreStateSequence[sequenceIndex].remove(at: stateIndex)
        if scoreStateSequence[sequenceIndex].count == 0 {
            scoreStateSequence.remove(at: sequenceIndex)
        }
    }
    
    mutating func deleteSportStateFromViolateSequence(sequenceIndex: Int, stateIndex: Int) {
        violateStateSequence[sequenceIndex].stateIds.remove(at: stateIndex)
        if violateStateSequence[sequenceIndex].stateIds.count == 0 {
            violateStateSequence.remove(at: sequenceIndex)
        }
    }
  
  
  mutating private func updateScoreStateSequence() {
    var newScoreStateSequence:[[Int]] = []
    
    scoreStateSequence.forEach{ stateIds in
        var newScoreStates:[Int] = []

        stateIds.forEach { scoreStateId in
            let newScoreState = allStates.first{ state in
              state.id == scoreStateId
            }
            
            if let newScoreState = newScoreState {
                newScoreStates.append(newScoreState.id)
            }
        }
        
        if !newScoreStates.isEmpty {
            newScoreStateSequence.append(newScoreStates)
        }
      
    }
    scoreStateSequence = newScoreStateSequence
  }
  
  
    
    mutating func updateSport(landmarkType: LandmarkType) {
        if !self.selectedLandmarkTypes.contains(landmarkType) {
            selectedLandmarkTypes.append(landmarkType)
        }
    }
    
      
    mutating func deleteSport(landmarkType: LandmarkType) {
          selectedLandmarkTypes.removeAll(where: { _landmarkType in
              _landmarkType.id == landmarkType.id
          })
      }
    
    mutating func updateSport(objectId: String) {
        if !self.collectedObjects.contains(objectId) {
            self.collectedObjects.append(objectId)

        }
    }
    
      
    mutating func deleteSport(objectId: String) {
        self.collectedObjects.removeAll(where: { _objectId in
            _objectId == objectId
          })
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
    
    mutating func updateSportState(editedSportState: SportState, checkCycle: Double, passingRate: Double, keepTime: Double) {
      if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
          states[index].checkCycle = checkCycle
          states[index].passingRate = passingRate
          states[index].keepTime = keepTime
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
    
    mutating func updateSportStateRule(editedSportStateUUID: Int, ruleType: RuleType, editedRulesIndex: Int, editedRule: ComplexRule) {
      if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID){
        states[stateIndex].updateSportStateRule(ruleType: ruleType, rulesIndex: editedRulesIndex, editedRule: editedRule)
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
    mutating func deleteSportStateRule(editedSportState: SportState, editedRulesId: UUID, ruleType: RuleType, ruleId:String) {
      if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
          states[index].deleteSportStateRule(rulesId: editedRulesId, ruleType: ruleType, ruleId: ruleId)
      }
    }
  

  
  // 每个状态都设置了相应的规则 则已经被设置
  var ruleHasSetuped: Bool {
    states.count ==  states.reduce(0, {(result, state) in
        (!state.complexScoreRules.isEmpty ? 1 : 0) + result
    })
  }
  
  // 规则完整度
  var ruleIntegrity:Double {
    Double(states.reduce(0, {(result, state) in
      (!state.complexScoreRules.isEmpty ? 1 : 0) + result
    }))/Double(states.count)
  }

  
  mutating func setSegmentToSelected(editedSportStateUUID: Int, editedSportStateRuleId: String?) {
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID) {
      states[stateIndex].setSegmentToSelected(editedSportStateRuleId: editedSportStateRuleId)
    }
  }
  

}
