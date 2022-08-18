

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
    var warning: Warning = Warning(content: "", triggeredWhenRuleMet: true, delayTime: 0.0)
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
    var scoreTimeLimit:Double = 2.0
    var warningDelay: Double = 2.0
    var sportClass:SportClass = .Counter
    var sportPeriod:SportPeriod = .CompletePeriod
    var noStateWarning: String = ""
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
        "\(self.name)-\(self.sportClass.rawValue)-\(self.sportPeriod.rawValue)"
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
  
  func findFirstStateByStateId(stateId: Int) -> SportState? {
    if let index = firstStateIndexByStateID(editedStateUUID: stateId) {
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
        violateStateSequence[index].warning = Warning(content: warning, triggeredWhenRuleMet: true, delayTime: 0.0)
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
        states[index].scoreRules.append(Rules(description: "计分规则集"))
      case .VIOLATE:
        states[index].violateRules.append(Rules(description: "违规规则集"))
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
  
  

  
  mutating func deleteRules(editedSportState: SportState, editedRulesId: UUID, ruleType: RuleType) {
    if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
      states[index].deleteRules(rulesId: editedRulesId, ruleType: ruleType)
    }
  }
    
    mutating func deleteRule(editedSportState: SportState, editedRulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
      if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
          states[index].deleteRule(rulesId: editedRulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
      }
    }


  
  // 每个状态都设置了相应的规则 则已经被设置
  var ruleHasSetuped: Bool {
    states.count ==  states.reduce(0, {(result, state) in
        (!state.scoreRules.isEmpty ? 1 : 0) + result
    })
  }
  
  // 规则完整度
  var ruleIntegrity:Double {
    Double(states.reduce(0, {(result, state) in
      (!state.scoreRules.isEmpty ? 1 : 0) + result
    }))/Double(states.count)
  }

  
    mutating func setSegmentToSelected(editedSportStateUUID: Int, editedSportStateRuleId: String?, ruleClass: RuleClass?) {
    if let stateIndex = firstStateIndexByStateID(editedStateUUID: editedSportStateUUID) {
      states[stateIndex].setSegmentToSelected(editedSportStateRuleId: editedSportStateRuleId, ruleClass: ruleClass)
    }
  }
    
    
    mutating func addRule(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].addRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    mutating func addRuleLandmarkSegmentAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].addRuleLandmarkSegmentAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    func getRuleLandmarkSegmentAngles(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkSegmentAngle] {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleLandmarkSegmentAngles(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
    }
    
    func getRuleLandmarkSegmentAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkSegmentAngle {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleLandmarkSegmentAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func removeRuleLandmarkSegmentAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        states[stateIndex].removeRuleLandmarkSegmentAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func updateRuleLandmarkSegmentAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, lowerBound: Double, upperBound: Double, id: UUID) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].updateRuleLandmarkSegmentAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, lowerBound: lowerBound, upperBound: upperBound, id: id)

        }
    }
    
    
//    ----------------------------
    
    func getRuleAngleToLandmarkSegments(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [AngleToLandmarkSegment] {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleAngleToLandmarkSegments(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
    }
    
    func getRuleAngleToLandmarkSegment(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> AngleToLandmarkSegment {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleAngleToLandmarkSegment(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func addRuleAngleToLandmarkSegment(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].addRuleAngleToLandmarkSegment(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    mutating func removeRuleAngleToLandmarkSegment(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        states[stateIndex].removeRuleAngleToLandmarkSegment(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    
    mutating func updateRuleAngleToLandmarkSegment(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, tolandmarkSegmentType: LandmarkTypeSegment, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,  id: UUID) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].updateRuleAngleToLandmarkSegment(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, tolandmarkSegmentType: tolandmarkSegmentType, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)

        }
    }
//    -------------------------
    
    func getRuleLandmarkSegmentLengths(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkSegmentLength] {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleLandmarkSegmentLengths(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
    }
    
    func getRuleLandmarkSegmentLength(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkSegmentLength {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleLandmarkSegmentLength(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func addRuleLandmarkSegmentLength(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].addRuleLandmarkSegmentLength(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    mutating func removeRuleLandmarkSegmentLength(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        states[stateIndex].removeRuleLandmarkSegmentLength(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func updateRuleLandmarkSegmentLength(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, fromAxis: CoordinateAxis,tolandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,  id: UUID) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].updateRuleLandmarkSegmentLength(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, fromAxis: fromAxis, tolandmarkSegmentType: tolandmarkSegmentType, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)

        }
    }
    
//    ----------
    
    func getRuleLandmarkToSelfs(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkToSelf] {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleLandmarkToSelfs(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
    }
    
    func getRuleLandmarkToSelf(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkToSelf {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleLandmarkToSelf(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func addRuleLandmarkToSelf(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].addRuleLandmarkToSelf(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    mutating func removeRuleLandmarkToSelf(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        states[stateIndex].removeRuleLandmarkToSelf(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func updateRuleLandmarkToSelf(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, direction: Direction, toLandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, xLowerBound: Double, yLowerBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID)  {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].updateRuleLandmarkToSelf(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, direction: direction, toLandmarkSegmentType: toLandmarkSegmentType, toAxis: toAxis, xLowerBound: xLowerBound, yLowerBound: yLowerBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)

        }
    }
//    -----------
    
    
    func getRuleLandmarkToStates(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkToState] {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleLandmarkToStates(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
    }
    
    func getRuleLandmarkToState(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkToState {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleLandmarkToState(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func addRuleLandmarkToState(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].addRuleLandmarkToState(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    
    mutating func removeRuleLandmarkToState(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        states[stateIndex].removeRuleLandmarkToState(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    
    mutating func updateRuleLandmarkToState(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                            fromAxis: CoordinateAxis,
                                            toStateId: Int,
                                            toLandmarkSegmentType: LandmarkTypeSegment,
                                            toAxis: CoordinateAxis,
                                            lowerBound: Double, upperBound: Double,
                                warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID) {
        
        
        
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
            
            let toStateLandmark = self.states.first(where: { state in
                toStateId == state.id
            })!.humanPose!.landmarks.first(where: { landmark in
                landmark.id == ruleId
                
            })!
          states[stateIndex].updateRuleLandmarkToState(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
                                                       fromAxis: fromAxis,
                                                       toStateId: toStateId,
                                                       toStateLandmark: toStateLandmark,
                                                       toLandmarkSegmentType: toLandmarkSegmentType,
                                                       toAxis: toAxis,
                                                       lowerBound: lowerBound, upperBound: upperBound,
                                                       warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)

        }
    }
    
//    -----------
    
    func getRuleLandmarkInAreas(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkInArea] {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleLandmarkInAreas(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
    }
    
    func getRuleLandmarkInArea(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkInArea {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleLandmarkInArea(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func addRuleLandmarkInArea(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].addRuleLandmarkInArea(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    
    mutating func removeRuleLandmarkInArea(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        states[stateIndex].removeRuleLandmarkInArea(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func updateRuleLandmarkInArea(
        stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
        area: [Point2D],warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, id: UUID) {
        
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
      
          states[stateIndex].updateRuleLandmarkInArea(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
                                                      area: area, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: id)

        }
    }
    
//    -----------
    mutating func transferRuleTo(stateId:Int, ruleType:RuleType, rulesIndex:Int, rule: Ruler) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
            states[stateIndex].transferRuleTo(ruleType: ruleType, rulesIndex: rulesIndex, rule: rule)
        }
    }
  

}
