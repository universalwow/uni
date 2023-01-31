

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
    
    static func filteredPeriodCases(sportClass: SportClass) -> [SportPeriod] {
        switch sportClass {
        case .Counter:
            return [.CompletePeriod, .HarfPeriod]
        case .Timer:
            return [.None]
        case .TimeCounter:
            return [.CompletePeriod, .HarfPeriod]
        case .None:
            return Self.allCases
        case .TimeRanger:
            return [.None]
        }
    }
    
    static func filteredDiscreteCases(sportClass: SportClass) -> [SportPeriod] {
        switch sportClass {
        case .Counter:
            return [.None]
        case .Timer:
            return [.Continuous, .Discrete]
        case .TimeCounter:
            return [.Continuous, .Discrete]
        case .None:
            return Self.allCases
        case .TimeRanger:
            return [.None]
            
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
    case TimeRanger
    case None
}

enum InteractionType: String, Codable, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    case SingleChoice
    case MultipleChoice
    case SingleTouch
    case OrdinalTouch
    case None
}


struct ViolateSequenceAndWarning: Codable {
    var warning: Warning = Warning(content: "", triggeredWhenRuleMet: true, delayTime: 0.0)
    var stateIds: [Int] = []
}


struct SportDescription {
    var name: String
    var sportClass: SportClass
    
    var sportPeriod: SportPeriod
    var sportDiscrete: SportPeriod
    var isController: Bool
    
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
    var states: [SportState] = [SportState.interAction_1, SportState.interAction_2, SportState.interAction_3,
                                SportState.interAction_a, SportState.interAction_b, SportState.interAction_c, SportState.interAction_d,
                                SportState.startState, SportState.endState, SportState.readyState] {
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
    var interactionScoreStateSequence: [[Int]]? = []
  var violateStateSequence: [ViolateSequenceAndWarning] = []
    
    //需要收集的关节点或者物体
    var selectedLandmarkTypes : [LandmarkType] = []
    var collectedObjects : [String] = []
    

  // 时间限制 秒
    var scoreTimeLimit:Double = 2.0
    var warningDelay: Double = 2.0
    var sportClass:SportClass = .Counter
    var sportPeriod:SportPeriod = .CompletePeriod
    var sportDiscrete:SportPeriod?
    var noStateWarning: String = ""
    var isGestureController = false
    
    var interactionScoreCycle: Int? = 1
    
    var dynamicAreaNumber: Int? = 3
    var interactionType = InteractionType.None
    
    var questions: [Question] = [
        Question(question: "谁是世界上最可爱的人?", choices: ["军人", "农民", "教师"], answers: ["军人", "农民", "教师"]),
        Question(question: "1+1=?", choices: ["1", "2", "3"], answers: ["2"])
    ]
    
    var fixedAreas = [FixedAreaForSport(id: "固定区域(A)"),
                      FixedAreaForSport(id: "固定区域(B)"),
                      FixedAreaForSport(id: "固定区域(C)"),
                      FixedAreaForSport(id: "固定区域(D)"),
                      FixedAreaForSport(id: "固定区域(问题)"),
                      FixedAreaForSport(id: "固定区域(1)"),
                      FixedAreaForSport(id: "固定区域(2)"),
                      FixedAreaForSport(id: "固定区域(3)"),
                      FixedAreaForSport(id: "固定区域(4)")
    ]
    
    var dynamicAreas: [DynamicAreaForSport] = [
        DynamicAreaForSport(id: "动态区域(A)"),
        DynamicAreaForSport(id: "动态区域(B)"),
        DynamicAreaForSport(id: "动态区域(C)"),
        DynamicAreaForSport(id: "动态区域(D)"),
        DynamicAreaForSport(id: "动态区域(问题)"),
        DynamicAreaForSport(id: "动态区域(1)"),
        DynamicAreaForSport(id: "动态区域(2)"),
        DynamicAreaForSport(id: "动态区域(3)"),
        DynamicAreaForSport(id: "动态区域(4)")
    ]
    
    var sportDescription: SportDescription {
        SportDescription(name: name, sportClass: sportClass, sportPeriod: sportPeriod, sportDiscrete: sportDiscrete ?? .None, isController: isGestureController)
    }
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
        "\(self.name)-\(self.sportClass.rawValue)-\(self.sportPeriod.rawValue)-\(self.sportDiscrete?.rawValue ?? "None")"
    }
  
  var allStates: [SportState]  {
//      if states.contains(where: { state in
//          state.id == SportState.in
//
//      })
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
    
    mutating func addSportStateInteractionScoreSequence(index: Int, scoreState: SportState) {
        interactionScoreStateSequence![index].append(scoreState.id)
    }
    
    mutating func addSportStateViolateSequence(index: Int, violateState: SportState, warning: String) {
        violateStateSequence[index].stateIds.append(violateState.id)
        violateStateSequence[index].warning = Warning(content: warning, triggeredWhenRuleMet: true, delayTime: 0.0)
    }
    
    mutating func addSportStateScoreSequence() {
      scoreStateSequence.append([])
    }
    
    mutating func addSportStateInteractionScoreSequence() {
        if interactionScoreStateSequence == nil {
            interactionScoreStateSequence = []
        }
      interactionScoreStateSequence?.append([])
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
    
    
    mutating func deleteSportStateFromInteractionScoreSequence(sequenceIndex: Int, stateIndex: Int) {
        interactionScoreStateSequence![sequenceIndex].remove(at: stateIndex)
        if interactionScoreStateSequence![sequenceIndex].count == 0 {
            interactionScoreStateSequence!.remove(at: sequenceIndex)
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
          states[index].scoreRules.append(Rules(fixedAreaRules: [], description: "计分规则集"))
      case .VIOLATE:
        states[index].violateRules.append(Rules(fixedAreaRules: [], description: "违规规则集"))
      }
    }
  }
    
    mutating func updateSportState(editedSportState: SportState, directToState: SportState) {
      if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
          states[index].directToStateId = directToState.id
      
      }
    }
    
    mutating func updateSportState(editedSportState: SportState, checkCycle: Double, passingRate: Double, keepTime: Double) {
      if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
          states[index].checkCycle = checkCycle
          states[index].passingRate = passingRate
          states[index].keepTime = keepTime
      }
    }
    
    mutating func updateSportState(editedSportState: SportState) {
      if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
          states[index].checkTimeRanges = []
      }
    }
    
    mutating func updateSportState(editedSportState: SportState, lowerBound: Double, upperBound: Double) {
      if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
          if states[index].checkTimeRanges == nil || states[index].checkTimeRanges!.isEmpty {
              states[index].checkTimeRanges = []
              states[index].checkTimeRanges!.append(TimeRange(id: 1, startTime: lowerBound, endTime: upperBound))
          }else {
              let nextId = states[index].checkTimeRanges!.max(by: { (_left, _right) -> Bool in
                  
                  return _left.id < _right.id
              })!.id + 1
              states[index].checkTimeRanges!.append(TimeRange(id: nextId, startTime: lowerBound, endTime: upperBound))
          }
          
      }
    }
  
    mutating func deleteSportState(editedSportState: SportState, timeRangeId: Int) {
        
      if let index = firstStateIndexByStateName(editedStateName: editedSportState.name) {
          if let timeRangeIndex = states[index].checkTimeRanges!.firstIndex(where: { timeRange in
              return timeRange.id == timeRangeId
          }) {
              states[index].checkTimeRanges!.remove(at: timeRangeIndex)
          }
          
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
    
    mutating func updateRuleLandmarkSegmentAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,lowerBound: Double, upperBound: Double, id: UUID) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].updateRuleLandmarkSegmentAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, lowerBound: lowerBound, upperBound: upperBound, id: id)

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
    
    
    mutating func updateRuleAngleToLandmarkSegment(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, tolandmarkSegmentType: LandmarkTypeSegment, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].updateRuleAngleToLandmarkSegment(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, tolandmarkSegmentType: tolandmarkSegmentType, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id)

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
    
    mutating func updateRuleLandmarkSegmentLength(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, fromAxis: CoordinateAxis,tolandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
            states[stateIndex].updateRuleLandmarkSegmentLength(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, fromAxis: fromAxis, tolandmarkSegmentType: tolandmarkSegmentType, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id)

        }
    }
    
    
    //    ---------------
            
            
            func getRuleLandmarkSegmentToStateAngles(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkSegmentToStateAngle] {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleLandmarkSegmentToStateAngles(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
            }
            
            func getRuleLandmarkSegmentToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkSegmentToStateAngle {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleLandmarkSegmentToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            mutating func addRuleLandmarkSegmentToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                  states[stateIndex].addRuleLandmarkSegmentToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
                }
            }
            
            
            mutating func removeRuleLandmarkSegmentToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                states[stateIndex].removeRuleLandmarkSegmentToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            
            mutating func updateRuleLandmarkSegmentToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                    toStateId: Int,
                                                           isRelativeToExtremeDirection: Bool,
                                                           extremeDirection: ExtremeDirection,
                                                    lowerBound: Double, upperBound: Double,
                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,id: UUID) {
                
                
                
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                    
                    let toStateLandmarkSegment = self.states.first(where: { state in
                        toStateId == state.id
                    })!.humanPose!.landmarkSegments.first(where: { landmarkSegment in
                        landmarkSegment.id == ruleId
                        
                    })!
                  states[stateIndex].updateRuleLandmarkSegmentToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
                                                                      toStateId: toStateId,
                                                                      isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                      extremeDirection: extremeDirection,
                                                               toStateLandmarkSegment: toStateLandmarkSegment,
                                                               lowerBound: lowerBound, upperBound: upperBound,
                                                               warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id)

                }
            }
        
    //    ---------------
            
            
            func getRuleLandmarkSegmentToStateDistances(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkSegmentToStateDistance] {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleLandmarkSegmentToStateDistances(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
            }
            
            func getRuleLandmarkSegmentToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkSegmentToStateDistance {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleLandmarkSegmentToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            mutating func addRuleLandmarkSegmentToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                  states[stateIndex].addRuleLandmarkSegmentToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
                }
            }
            
            
            mutating func removeRuleLandmarkSegmentToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                states[stateIndex].removeRuleLandmarkSegmentToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            
            mutating func updateRuleLandmarkSegmentToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                                   fromAxis: CoordinateAxis,
                                                    toStateId: Int,
                                                           isRelativeToExtremeDirection: Bool,
                                                           extremeDirection: ExtremeDirection,
                                                    lowerBound: Double, upperBound: Double,
                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
                
                
                
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                    
                    let toStateLandmarkSegment = self.states.first(where: { state in
                        toStateId == state.id
                    })!.humanPose!.landmarkSegments.first(where: { landmarkSegment in
                        landmarkSegment.id == ruleId
                        
                    })!
                  states[stateIndex].updateRuleLandmarkSegmentToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
                                                                              fromAxis: fromAxis,
                                                                      toStateId: toStateId,
                                                                      isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                      extremeDirection: extremeDirection,
                                                               toStateLandmarkSegment: toStateLandmarkSegment,
                                                               lowerBound: lowerBound, upperBound: upperBound,
                                                               warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id)

                }
            }
        
    
    //    -------------------------
        
        func getRuleDistanceToLandmarks(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [DistanceToLandmark] {
            let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
            return states[stateIndex].getRuleDistanceToLandmarks(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
        
        func getRuleDistanceToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> DistanceToLandmark {
            let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
            return states[stateIndex].getRuleDistanceToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
        }
        
        mutating func addRuleDistanceToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
            if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
              states[stateIndex].addRuleDistanceToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
            }
        }
        
        mutating func removeRuleDistanceToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
            let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
            states[stateIndex].removeRuleDistanceToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
        }
        
        mutating func updateRuleDistanceToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, fromAxis: CoordinateAxis, toLandmarkType: LandmarkType, tolandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID) {
            if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
              states[stateIndex].updateRuleDistanceToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, fromAxis: fromAxis,  toLandmarkType: toLandmarkType, tolandmarkSegmentType: tolandmarkSegmentType, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id)

            }
        }
    
    
    //    -----------
    mutating func addRuleAngleToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].addRuleAngleToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    func getRuleAngleToLandmarks(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [AngleToLandmark] {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleAngleToLandmarks(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
    }
    
    func getRuleAngleToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> AngleToLandmark {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleAngleToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func removeRuleAngleToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        states[stateIndex].removeRuleAngleToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func updateRuleAngleToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  lowerBound: Double, upperBound: Double,
                                            toLandmarkType: LandmarkType, id: UUID) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
            states[stateIndex].updateRuleAngleToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  lowerBound: lowerBound, upperBound: upperBound, toLandmarkType: toLandmarkType,
                                                       id: id)

        }
    }
    
    
//    ---------------
        
        
        func getRuleLandmarkToStateDistances(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkToStateDistance] {
            let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
            return states[stateIndex].getRuleLandmarkToStateDistances(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
        
        func getRuleLandmarkToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkToStateDistance {
            let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
            return states[stateIndex].getRuleLandmarkToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
        }
        
        mutating func addRuleLandmarkToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
            if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
              states[stateIndex].addRuleLandmarkToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
            }
        }
        
        
        mutating func removeRuleLandmarkToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
            let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
            states[stateIndex].removeRuleLandmarkToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
        }
        
        
        mutating func updateRuleLandmarkToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                fromAxis: CoordinateAxis,
                                                toStateId: Int,
                                                       isRelativeToExtremeDirection: Bool,
                                                       extremeDirection: ExtremeDirection,
                                                toLandmarkSegmentType: LandmarkTypeSegment,
                                                toAxis: CoordinateAxis,
                                                lowerBound: Double, upperBound: Double,
                                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID, defaultSatisfy: Bool) {
            
            
            
            if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                
                let toStateLandmark = self.states.first(where: { state in
                    toStateId == state.id
                })!.humanPose!.landmarks.first(where: { landmark in
                    landmark.id == ruleId
                    
                })!
              states[stateIndex].updateRuleLandmarkToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
                                                           fromAxis: fromAxis,
                                                                  toStateId: toStateId,
                                                                  isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                  extremeDirection: extremeDirection,
                                                                  
                                                           toStateLandmark: toStateLandmark,
                                                           toLandmarkSegmentType: toLandmarkSegmentType,
                                                           toAxis: toAxis,
                                                           lowerBound: lowerBound, upperBound: upperBound,
                                                                   warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id, defaultSatisfy: defaultSatisfy)

            }
        }
    
    
    //    ---------------
            
            
            func getRuleLandmarkToStateAngles(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkToStateAngle] {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleLandmarkToStateAngles(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
            }
            
            func getRuleLandmarkToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkToStateAngle {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleLandmarkToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            mutating func addRuleLandmarkToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                  states[stateIndex].addRuleLandmarkToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
                }
            }
            
            
            mutating func removeRuleLandmarkToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                states[stateIndex].removeRuleLandmarkToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            
            mutating func updateRuleLandmarkToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                    toStateId: Int,
                                                           isRelativeToExtremeDirection: Bool,
                                                           extremeDirection: ExtremeDirection,
                                                    lowerBound: Double, upperBound: Double,
                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID) {
                
                
                
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                    
                    let toStateLandmark = self.states.first(where: { state in
                        toStateId == state.id
                    })!.humanPose!.landmarks.first(where: { landmark in
                        landmark.id == ruleId
                        
                    })!
                  states[stateIndex].updateRuleLandmarkToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
                                                                      toStateId: toStateId,
                                                                      isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                      extremeDirection: extremeDirection,
                                                               toStateLandmark: toStateLandmark,
                                                               lowerBound: lowerBound, upperBound: upperBound,
                                                               warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id)

                }
            }
        
    
    
    

//    -----------
    
    func getRuleObjectToLandmarks(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [ObjectToLandmark] {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleObjectToLandmarks(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
    }
    
    func getRuleObjectToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> ObjectToLandmark {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleObjectToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func addRuleObjectToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].addRuleObjectToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    mutating func removeRuleObjectToLandmark(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        states[stateIndex].removeRuleObjectToLandmark(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func updateRuleObjectToLandmark(
        stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
        objectPosition: ObjectPosition,
                                                fromAxis: CoordinateAxis,
                                                toLandmarkType: LandmarkType,
                                                toLandmarkSegmentType: LandmarkTypeSegment,
                                                toAxis: CoordinateAxis,
        lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, id: UUID, isRelativeToObject: Bool) {
        
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
      
          states[stateIndex].updateRuleObjectToLandmark(
            rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
            objectPosition: objectPosition,
            fromAxis: fromAxis,
            toLandmarkType: toLandmarkType,
            toLandmarkSegmentType: toLandmarkSegmentType,
            toAxis: toAxis,
            lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear,id: id, isRelativeToObject: isRelativeToObject)

        }
    }
    
//    -----------
    
    func getRuleObjectToObjects(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [ObjectToObject] {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleObjectToObjects(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
    }
    
    func getRuleObjectToObject(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> ObjectToObject {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        return states[stateIndex].getRuleObjectToObject(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func addRuleObjectToObject(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
          states[stateIndex].addRuleObjectToObject(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    mutating func removeRuleObjectToObject(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
        let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
        states[stateIndex].removeRuleObjectToObject(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
    }
    
    mutating func updateRuleObjectToObject(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                           fromAxis: CoordinateAxis, fromObjectPosition: ObjectPosition, toObjectId: String, toObjectPosition: ObjectPosition, toLandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID, isRelativeToObject: Bool) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
      
          states[stateIndex].updateRuleObjectToObject(
            rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
            fromAxis: fromAxis,fromObjectPosition: fromObjectPosition,toObjectId: toObjectId, toObjectPosition: toObjectPosition, toLandmarkSegmentType: toLandmarkSegmentType, toAxis: toAxis,     lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id, isRelativeToObject: isRelativeToObject)
        }
        
    }
    
    //    ---------------
            
            
            func getRuleObjectToStateDistances(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [ObjectToStateDistance] {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleObjectToStateDistances(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
            }
            
            func getRuleObjectToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> ObjectToStateDistance {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleObjectToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            mutating func addRuleObjectToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                  states[stateIndex].addRuleObjectToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
                }
            }
            
            
            mutating func removeRuleObjectToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                states[stateIndex].removeRuleObjectToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            
            mutating func updateRuleObjectToStateDistance(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                         fromAxis: CoordinateAxis,
                                                                                                    toStateId: Int,
                                                                                             fromPosition: ObjectPosition,
                                                                                             isRelativeToObject: Bool,
                                                                                               isRelativeToExtremeDirection: Bool,
                                                                                               extremeDirection: ExtremeDirection,
                                                                                                    toLandmarkSegmentType: LandmarkTypeSegment,
                                                                                                    toAxis: CoordinateAxis,
                                                                                                    lowerBound: Double, upperBound: Double,
                                                                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID)  {
                
                
                
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                    
                    let toStateObject = self.states.first(where: { state in
                        toStateId == state.id
                    })!.objects.first(where: { object in
                        object.label == ruleId
                        
                    })!
                  states[stateIndex].updateRuleObjectToStateDistance(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
                                                                    fromAxis: fromAxis,
                                                                    toStateId: toStateId,
                                                                    fromPosition: fromPosition,
                                                                    toObject: toStateObject,
                                                                    isRelativeToObject: isRelativeToObject,
                                                                    isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                    extremeDirection: extremeDirection,
                                                                    toLandmarkSegmentType: toLandmarkSegmentType,
                                                                    toAxis: toAxis,
                                                                    lowerBound: lowerBound, upperBound: upperBound,
                                                                    warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id)

                }
            }
    
    
    //    ---------------
            
            
            func getRuleObjectToStateAngles(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [ObjectToStateAngle] {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleObjectToStateAngles(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
            }
            
            func getRuleObjectToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> ObjectToStateAngle {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleObjectToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            mutating func addRuleObjectToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                  states[stateIndex].addRuleObjectToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
                }
            }
            
            
            mutating func removeRuleObjectToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                states[stateIndex].removeRuleObjectToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            
            mutating func updateRuleObjectToStateAngle(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                                                                                                    toStateId: Int,
                                                                                             fromPosition: ObjectPosition,
                                                                                               isRelativeToExtremeDirection: Bool,
                                                                                               extremeDirection: ExtremeDirection,
                                                                                                    lowerBound: Double, upperBound: Double,
                                                                                        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID)  {
                
                
                
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                    
                    let toStateObject = self.states.first(where: { state in
                        toStateId == state.id
                    })!.objects.first(where: { object in
                        object.label == ruleId
                        
                    })!
                  states[stateIndex].updateRuleObjectToStateAngle(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
                                                                    toStateId: toStateId,
                                                                    fromPosition: fromPosition,
                                                                    toObject: toStateObject,
                                                                    isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                    extremeDirection: extremeDirection,
                                                                    lowerBound: lowerBound, upperBound: upperBound,
                                                                    warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id)

                }
            }
    
    //    -----------
        

    
    func getFixedArea(ruleId: String?) -> FixedAreaForSport? {
        return fixedAreas.first(where: { area in
            area.id == ruleId
        })
    }
    
    func getFixedAreas() -> [FixedAreaForSport] {
        return fixedAreas.filter({ area in
            area.content != "" || area.content != nil
        })
    }
    
    func getDynamicArea(ruleId: String?) -> DynamicAreaForSport? {
        return dynamicAreas.first(where: { area in
            area.id == ruleId
        })
    }
    

    
    func findFirstFixedAreaIndex(areaId: String) -> Int? {
        fixedAreas.firstIndex(where: { area in
            area.id == areaId
        })
    }
    
    func findFirstDynamicAreaIndex(areaId: String) -> Int? {
        dynamicAreas.firstIndex(where: { area in
            area.id == areaId
        })
    }
    
    mutating func generatorFixedArea(imageSize: Point2D, areaId: String) -> [Point2D] {
      

        let areaIndex = findFirstFixedAreaIndex(areaId: areaId)!
        let width = fixedAreas[areaIndex].width
        let heightToWidthRatio = fixedAreas[areaIndex].heightToWidthRatio
        
        let centerX = fixedAreas[areaIndex].center.x * imageSize.width
        let centerY = fixedAreas[areaIndex].center.y * imageSize.height

        let _width = imageSize.width * width
        let height = _width * heightToWidthRatio

        let leftTop = Point2D(x: centerX - _width/2, y: centerY - height/2)
        let rightTop = Point2D(x: centerX + _width/2, y: centerY - height/2)
        let rightBottom = Point2D(x: centerX + _width/2, y: centerY + height/2)
        let leftBottom = Point2D(x: centerX - _width/2, y: centerY + height/2)
        
        return [leftTop, rightTop, rightBottom, leftBottom]
    }
    
    mutating func generatorDynamicArea(imageSize: Point2D, areaId: String) -> [Point2D] {
      

        let areaIndex = findFirstDynamicAreaIndex(areaId: areaId)!
        let width = dynamicAreas[areaIndex].width
        let heightToWidthRatio = dynamicAreas[areaIndex].heightToWidthRatio
        
        
        
        let centerX = Double.random(in: dynamicAreas[areaIndex].limitedArea[0]...dynamicAreas[areaIndex].limitedArea[2]) * imageSize.width
        let centerY = Double.random(in: dynamicAreas[areaIndex].limitedArea[1]...dynamicAreas[areaIndex].limitedArea[3]) * imageSize.height

        let _width = imageSize.width * width
        let height = _width * heightToWidthRatio

        let leftTop = Point2D(x: centerX - _width/2, y: centerY - height/2)
        let rightTop = Point2D(x: centerX + _width/2, y: centerY - height/2)
        let rightBottom = Point2D(x: centerX + _width/2, y: centerY + height/2)
        let leftBottom = Point2D(x: centerX - _width/2, y: centerY + height/2)
        
        return [leftTop, rightTop, rightBottom, leftBottom]
    }
    
    mutating func generatorFixedArea(areaId: String, area: [Point2D]) {
        
        states.indices.forEach({ stateIndex in
            states[stateIndex].generatorFixedArea(areaId: areaId, area: area)
        })
    }
    
    
    
    mutating func generatorDynamicArea(areaId: String, area: [Point2D]) {
        
        states.indices.forEach({ stateIndex in
            states[stateIndex].generatorDynamicArea(areaId: areaId, area: area)
        })
    }
    

    
    mutating func updateFixedArea(
        stateId: Int, ruleId: String, width: Double, heightToWidthRatio: Double, centerX: Double, centerY: Double, content: String) {
        
            if let areaIndex = findFirstFixedAreaIndex(areaId: ruleId) {
                fixedAreas[areaIndex].width = width
                fixedAreas[areaIndex].heightToWidthRatio = heightToWidthRatio
                fixedAreas[areaIndex].center.x = centerX
                fixedAreas[areaIndex].center.y = centerY
                fixedAreas[areaIndex].content = content
                let state = findFirstStateByStateId(stateId: stateId)!
                let imageSize = state.image!.imageSize

                let area = generatorFixedArea(imageSize: imageSize.point2d, areaId: ruleId)
                fixedAreas[areaIndex].area = area
                fixedAreas[areaIndex].imageSize = imageSize.point2d
             
                generatorFixedArea(areaId: ruleId, area: area)
            }
        
    }
    
    mutating func updateDynamicArea(areaId: String, area: [Point2D]) {
        if let areaIndex = findFirstDynamicAreaIndex(areaId: areaId) {
            dynamicAreas[areaIndex].area = area
        }
    }
    
    mutating func updateDynamicArea(
        stateId: Int, ruleId: String, width: Double, heightToWidthRatio: Double,
        leftTopX: Double, leftTopY: Double, rightBottomX: Double, rightBottomY: Double, content: String
    ) {
        
            if let areaIndex = findFirstDynamicAreaIndex(areaId: ruleId) {
                dynamicAreas[areaIndex].width = width
                dynamicAreas[areaIndex].heightToWidthRatio = heightToWidthRatio
                dynamicAreas[areaIndex].limitedArea[0] = leftTopX
                dynamicAreas[areaIndex].limitedArea[1] = leftTopY
                dynamicAreas[areaIndex].limitedArea[2] = rightBottomX
                dynamicAreas[areaIndex].limitedArea[3] = rightBottomY
                dynamicAreas[areaIndex].content = content
                
                let state = findFirstStateByStateId(stateId: stateId)!
                let imageSize = state.image!.imageSize

                let area = generatorDynamicArea(imageSize: imageSize.point2d, areaId: ruleId)
                dynamicAreas[areaIndex].area = area
                dynamicAreas[areaIndex].imageSize = imageSize.point2d
             
                generatorDynamicArea(areaId: ruleId, area: area)
            }
        
    }

    
    //    ---------------
        
        
            func getRuleLandmarkInFixedAreasForAreaRule(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkInAreaForAreaRule] {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleLandmarkInFixedAreasForAreaRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
            }
            
            func getRuleLandmarkInFixedAreaForAreaRule(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkInAreaForAreaRule {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleLandmarkInFixedAreaForAreaRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            mutating func addRuleLandmarkInFixedAreaForAreaRule(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                    let area = fixedAreas.first(where: { area in
                        area.id == ruleId
                        
                    })!.area
                    states[stateIndex].addRuleLandmarkInFixedAreaForAreaRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, fixedArea: area)
                }
            }
            
            mutating func removeRuleLandmarkInFixedAreaForAreaRule(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                states[stateIndex].removeRuleLandmarkInFixedAreaForAreaRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            mutating func updateRuleLandmarkInFixedAreaForAreaRule(
                stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                area: [Point2D],warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, landmarkType: LandmarkType,
                id: UUID) {
                
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
              
                  states[stateIndex].updateRuleLandmarkInFixedAreaForAreaRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
                                                                         area: area, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, landmarkType: landmarkType, id: id)

                }
            }
    
    
    //    ---------------
        
        
            func getRuleLandmarkInDynamicAreasForAreaRule(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) -> [LandmarkInAreaForAreaRule] {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleLandmarkInDynamicAreasForAreaRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
            }
            
            func getRuleLandmarkInDynamicAreaForAreaRule(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) -> LandmarkInAreaForAreaRule {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                return states[stateIndex].getRuleLandmarkInDynamicAreaForAreaRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            mutating func addRuleLandmarkInDynamicAreaForAreaRule(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass) {
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
                    let area = dynamicAreas.first(where: { area in
                        area.id == ruleId
                        
                    })!.area
                    states[stateIndex].addRuleLandmarkInDynamicAreaForAreaRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, fixedArea: area)
                }
            }
            
            
            mutating func removeRuleLandmarkInDynamicAreaForAreaRule(stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass, id: UUID) {
                let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId)!
                states[stateIndex].removeRuleLandmarkInDynamicAreaForAreaRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass, id: id)
            }
            
            mutating func updateRuleLandmarkInDynamicAreaForAreaRule(
                stateId: Int, rulesId: UUID, ruleId: String, ruleType: RuleType, ruleClass: RuleClass,
                area: [Point2D],warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, landmarkType: LandmarkType,
                id: UUID) {
                
                if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
              
                  states[stateIndex].updateRuleLandmarkInDynamicAreaForAreaRule(rulesId: rulesId, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass,
                                                                         area: area, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, landmarkType: landmarkType, id: id)

                }
            }
    
    
//    -----------
    mutating func transferRuleTo(stateId:Int, ruleType:RuleType, rulesIndex:Int, rule: Ruler) {
        if let stateIndex = firstStateIndexByStateID(editedStateUUID: stateId) {
            states[stateIndex].transferRuleTo(ruleType: ruleType, rulesIndex: rulesIndex, rule: rule)
        }
    }
  

}
