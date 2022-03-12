
import Foundation
import UIKit




class SportManager: ObservableObject {
  @Published var sports:[Sport] = SportManager.allSports

  // 以下属性只能用于查询 不能用作存储
  var currentSportId: UUID?
  var currentStateId: SportStateUUID?
  var currentSportStateRulesId: UUID?
  
  var updateTimer: Timer?
  
  @Published var currentSportStateRuleId: String? {
    didSet {
      if currentSportStateRuleId != nil {
        if let _ = self.findCurrentSportStateRule() {
          print("修改规则。。。。。。。。")
        }else{
          
          self.addStateRule()
          print("添加新规则。。。。。。。。")
        }
        print("setSegmentToSelected \(currentSportStateRuleId)")
      }
      
      setSegmentToSelected()

    }
  }
  
  var currentSportStateRuleType:RuleType?
  var dispather = Dispatcher()
  
}

extension SportManager {
  

  
  // MARK: 计算变量
  
  static var allSports: [Sport] {
    Storage.allFiles(.documents).map{ url in
      Storage.retrieve(url: url, as: Sport.self)
    }
  }
  
  static var newSport: Sport {
    Sport()
  }
  
  
  var currentSportStateRuleWarning: String? {
    if let rule = findCurrentSportStateRule() {
      return rule.warning
    }
    return nil
  }
  
  func play(poseMap: PoseMap, currentTime: Double) {
    if let _ = firstIndex() {
//
//      sports[sportIndex].play(poseMap: poseMap, currentTime: currentTime)
//      // 展示提示消息
//      sports[sportIndex].cancelingWarnings.forEach {warning in
//        dispather.cancelAction(with: warning)
//        }
//
//      sports[sportIndex].newWarnings.forEach{ warning in
//        dispather.schedule(after: 1, with: warning, on: nil, action: {
//          print(warning)
//        })
//
//      }
      
    }
  }
  
  
  //MARK: sport
  
  func setCurrentSport(editedSport : Sport) {
    currentSportId = editedSport.id
  }
  
  private func firstIndex() -> Int? {
    if let currentSportId = currentSportId {
      return sports.firstIndex(where: { sport in
        sport.id == currentSportId
      })
    }
    return nil
  }
  
  
  private func firstIndex(editedSportId: UUID) -> Int? {
    return sports.firstIndex(where: { sport in
      sport.id == editedSportId
    })
  }
  
  
  func findFirstSport() -> Sport? {
    if let sportIndex = firstIndex() {
      return sports[sportIndex]
    }else {
      return nil
    }
  }
  
  func findFirstSport(sportId: UUID) -> Sport? {
    if let sportIndex = firstIndex(editedSportId: sportId) {
      return sports[sportIndex]
    }else {
      return nil
    }
  }
  
  func findFirstSport(sport: Sport) -> Sport? {
    findFirstSport(sportId: sport.id)
  }
  
  
  
  func addSport(sport:Sport) {
    sports.append(sport)
  }
  
  func saveSport(editedSport: Sport) {
    Storage.store(editedSport, to: .documents, as: editedSport.sportFileName)
  }
  
  private func updateSport(sport: Sport) {
    if let index = firstIndex(editedSportId: sport.id) {
      sports[index] = sport
    }
  }
  
  func updateSport(editedSport:Sport, sportName: String, sportDescription: String) {
    if let sport = findFirstSport(sport: editedSport) {
      var newSport = sport
      newSport.name = sportName
      newSport.description = sportDescription
      
      updateSport(sport: newSport)
    }
  }
  
  
  func deleteSport(editedSport: Sport) {
    if let sportIndex = firstIndex(editedSportId: editedSport.id) {
      sports.remove(at: sportIndex)
      Storage.delete(as: editedSport.sportFileName)
    }
  }
  
  //MARK: sport state
  
  func setCurrentSportState(editedSport : Sport, editedSportState: SportState) {
    currentStateId = editedSportState.id
  }
  
  func findFirstSportState() -> SportState? {
    findFirstSport()?.findFirstSportStateByUUID(editedStateUUID: currentStateId!)
  }
  
  
  private func findFirstSportState(editedSportId: UUID, sportStateUUID: SportStateUUID) -> SportState? {
    findFirstSport(sportId: editedSportId)?.findFirstSportStateByUUID(editedStateUUID: sportStateUUID)
  }
  
  
  func findFirstSportState(editedSport: Sport, sportStateUUID: SportStateUUID) -> SportState? {
    return findFirstSportState(editedSportId: editedSport.id, sportStateUUID: sportStateUUID)
    
  }

  
  func addSportState(editedSport: Sport, stateName: String, stateDescription: String) {
    if let sportIndex = firstIndex(editedSportId: editedSport.id) {
      sports[sportIndex].addState(stateName: stateName, stateDescription: stateDescription)
    }
  }

  
  func deleteSportState(editedSport: Sport, editedSportState: SportState) {
    if let sportIndex = firstIndex(editedSportId: editedSport.id) {
      sports[sportIndex].deleteState(state: editedSportState)
    }
  }
  
  
  private func updateSportState(state: SportState) {
    if let sportIndex = firstIndex() {
      sports[sportIndex].updateSport(state: state)
    }
  }
  
  func updateSportState(image: UIImage, landmarkSegments: [LandmarkSegment]) {
    if let state = findFirstSportState() {
      var newState = state
      newState.image = PngImage(photo: image.pngData()!, width: Int(image.size.width), height: Int(image.size.width))

      newState.landmarkSegments = landmarkSegments
      self.updateSportState(state: newState)
      
    }
  }
  
  
  func addSportStatetransform(fromSportState: SportState, toSportState: SportState) {
    if let sportIndex = firstIndex() {
      sports[sportIndex].addStateTransform(fromSportState: fromSportState, toSportState: toSportState)
    }
  }
  
  func deleteSportStateTransForm(fromSportState: SportState, toSportState: SportState) {
    if let sportIndex = firstIndex() {
      sports[sportIndex].deleteStateTransForm(fromSportState: fromSportState, toSportState: toSportState)
    }
  }
  
  func findSportStateTransforms(editedSport: Sport) -> [SportStateTransform] {
    findFirstSport(sport: editedSport)!.stateTransForm
  }
  
  func addSportStateScoreSequence(scoreState: SportState) {
    if let sportIndex = firstIndex() {
      sports[sportIndex].addSportStateScoreSequence(scoreState: scoreState)
    }
  }
  
  func deleteSportStateScoreSequence() {
    if let sportIndex = firstIndex() {
      sports[sportIndex].deleteSportStateScoreSequence()
    }
  }
  
  func findSportStateScoreSequence(editedSport: Sport) -> [SportState] {
    findFirstSport(sport: editedSport)!.scoreStateSequence
  }
  
  
  func findSelectedSegments() -> [LandmarkSegment] {
    findFirstSportState()!.landmarkSegments
  }
  
  
  // MARK: state rule
  func setCurrentSportStateRule(editedSport: Sport, editedSportState: SportState, editedSportStateRules: ComplexRules, editedSportStateRule: ComplexRule?, ruleType: RuleType) {
    currentSportId = editedSport.id
    currentStateId = editedSportState.id
    currentSportStateRulesId  = editedSportStateRules.id
    self.currentSportStateRuleId = editedSportStateRule?.id
    currentSportStateRuleType = ruleType
  }
  
  
  func setCurrentSportStateRule(landmarkSegment: LandmarkSegment) {
    currentSportStateRuleId = landmarkSegment.id
  }
  
  
  private func addStateRule() {
    let rule = ComplexRule(ruleId: self.currentSportStateRuleId!)
    self.upsertCurrentRule(rule: rule)
  }
  
  
  private func upsertCurrentRule(rule: ComplexRule) {
    if let sportIndex = firstIndex() {
      sports[sportIndex].updateSportStateRule(editedSportStateUUID: self.currentStateId!, editedSportStateRulesId: currentSportStateRulesId!, editedRule: rule, ruleType: currentSportStateRuleType!)
    }
  }
  
  private func findComplexRulesList(sportId: UUID, editedStateId: SportStateUUID, ruleType: RuleType) -> [ComplexRules] {
    let sportState = findFirstSportState(editedSportId: sportId, sportStateUUID: editedStateId)!
    
    return sportState.findComplexRulesList(ruleType: ruleType)
    
  }
  
  func findComplexRulesList(sport: Sport, editedState: SportState, ruleType: RuleType) -> [ComplexRules] {
    findComplexRulesList(sportId: sport.id, editedStateId: editedState.id, ruleType: ruleType)
  }
  
  func findComplexRulex() -> ComplexRules {
    let sportState = findFirstSportState()
    return (sportState?.findComplexRules(ruleType: currentSportStateRuleType!, currentSportStateRulesId: currentSportStateRulesId!))!
  }
  
  
  func findCurrentSportStateRule() -> ComplexRule? {
    
    // ComplexRulex
    let complexRulex = findComplexRulex()
    return complexRulex.findFirstComplexRule(ruleId: currentSportStateRuleId)
    
  }
  
  
  func dropInvalidComplexRule() {
    if let sportIndex = firstIndex() {
      sports[sportIndex].dropInvalidComplexRule(editedSportStateUUID: self.currentStateId!, editedSportStateRulesId: currentSportStateRulesId!, ruleType: currentSportStateRuleType!)
    }
  }
  
  func setCurrentRuleLandmarkInArea() {
    if let rule = findCurrentSportStateRule() {
      var newRule = rule
      newRule.landmarkInArea = LandmarkInArea(
        landmarkType: rule.landmarkSegmentType.startLandmarkType,
        area: [])
      self.upsertCurrentRule(rule: newRule)
    }
  }
  
  func setLandmarkArea(landmarkinArea: LandmarkInArea?) {
    if let rule = findCurrentSportStateRule() {
      var newRule = rule
      newRule.landmarkInArea = landmarkinArea
      self.upsertCurrentRule(rule: newRule)
    }
  }
  
  func findCurrentLandmarkArea() -> LandmarkInArea? {
    let rule = findCurrentSportStateRule()
    return rule?.landmarkInArea
  }
  
  func updateSportStateRule(firstPoint: CGPoint, secondPoint: CGPoint, thirdPoint:CGPoint, fourthPoint: CGPoint) {
    
    if let  rule = findCurrentSportStateRule() {
      var newRule = rule
      newRule.landmarkInArea!.area =
      [firstPoint.point2d, secondPoint.point2d, thirdPoint.point2d, fourthPoint.point2d]
      self.upsertCurrentRule(rule: newRule)
    }
    
  }
  
  func updateSportStateRule(landmarkType: LandmarkType) {
    if let  rule = findCurrentSportStateRule() {
      var newRule = rule
      
      newRule.landmarkInArea!.landmarkType = landmarkType
      self.upsertCurrentRule(rule: newRule)
    }
  }
  
  func setCurrentSportStateRuleWarning(warning: String) {
    if let rule = findCurrentSportStateRule() {
      var newRule = rule
      newRule.warning = warning
      self.upsertCurrentRule(rule: newRule)
    }
  }
  
  
  func getCurrentSportStateRuleLength(fromAxis: CoordinateAxis) -> RelativeLandmarkSegmentsToAxis {
    let rule = findCurrentSportStateRule()!
    switch fromAxis {
    case .X:
      return rule.lengthX!
    case .Y:
      return rule.lengthY!
    case .XY:
      return rule.lengthXY!
    }
  }
  
  func updateCurrentRuleLengthLowerBound(axis: CoordinateAxis, lowerBound: String) {
    if let rule = self.findCurrentSportStateRule() {
      var newRule = rule
      if let lowerBound = Double(lowerBound) {
        switch axis {
          case .X:
          newRule.lengthX?.lowerBound = lowerBound
          case .Y:
          newRule.lengthY?.lowerBound = lowerBound
          case .XY:
          newRule.lengthXY?.lowerBound = lowerBound
          }
      }
      self.upsertCurrentRule(rule: newRule)
    }
    
  }
  
  func updateCurrentRuleLengthUpperBound(axis: CoordinateAxis, upperBound: String) {
    if let rule = self.findCurrentSportStateRule() {
      var newRule = rule
      if let upperBound = Double(upperBound) {
        switch axis {
          case .X:
          newRule.lengthX?.upperBound = upperBound
          case .Y:
          newRule.lengthY?.upperBound = upperBound
          case .XY:
          newRule.lengthXY?.upperBound = upperBound
          }
      }
      self.upsertCurrentRule(rule: newRule)
    }
    
  }
  
  func updateCurrentSportStateRuleLength(axis: CoordinateAxis, length: RelativeLandmarkSegmentsToAxis?) {
    if let rule = findCurrentSportStateRule() {
      var newRule = rule
      switch axis {
        case .X:
          newRule.lengthX = length
        case .Y:
          newRule.lengthY = length
        case .XY:
          newRule.lengthXY = length
      }
      self.upsertCurrentRule(rule: newRule)
    }
  }
  
  func updateCurrentSportStateRuleLengthToLandmarkSegment(axis: CoordinateAxis, landmarkSegment: LandmarkSegment) {
    
    if let rule = findCurrentSportStateRule() {
      var newRule = rule
      switch axis {
      case .X:
        newRule.lengthX?.to.landmarkSegment = landmarkSegment
      case .Y:
        newRule.lengthY?.to.landmarkSegment = landmarkSegment
      case .XY:
        newRule.lengthXY?.to.landmarkSegment = landmarkSegment
      }
      self.upsertCurrentRule(rule: newRule)
    }
  }
  
  
  func updateCurrentSportStateRuleLengthToAxis(fromAxis: CoordinateAxis, toAxis: CoordinateAxis) {
    
    if let rule = findCurrentSportStateRule() {
      var newRule = rule
      switch fromAxis {
      case .X:
        newRule.lengthX?.to.axis = toAxis
        newRule.lengthX?.initBound()
      case .Y:
        newRule.lengthY?.to.axis = toAxis
        newRule.lengthY?.initBound()
      case .XY:
        newRule.lengthXY?.to.axis = toAxis
        newRule.lengthXY?.initBound()
      }
      self.upsertCurrentRule(rule: newRule)
      
    }
  }
  
  func setCurrentSportStateRuleAngle(angle: AngleRange?) {
    if let rule = findCurrentSportStateRule() {
      var newRule = rule
      newRule.angle  = angle
      self.upsertCurrentRule(rule: newRule)
    }
  }
  
  
  func addNewSportStateRules(editedSport: Sport, editedSportState: SportState, ruleType: RuleType) {
    if let sportIndex = firstIndex(editedSportId: editedSport.id) {
      sports[sportIndex].addNewSportStateRules(editedSportState: editedSportState, ruleType: ruleType)
    }
    
  }
  
  func deleteSportStateRules(editedSport: Sport, editedSportState: SportState, editedRules: ComplexRules, ruleType: RuleType) {
    if let sportIndex = firstIndex(editedSportId: editedSport.id) {
      sports[sportIndex].deleteSportStateRules(editedSportState: editedSportState, editedRulesId: editedRules.id, ruleType: ruleType)
    }
  }
  
  
  func setSegmentToSelected() {
    if let sportIndex = firstIndex() {
      sports[sportIndex].setSegmentToSelected(editedSportStateUUID: currentStateId!, editedSportStateRuleId: currentSportStateRuleId)
    }
  }
  
  func findselectedSegment() -> LandmarkSegment? {
    if let sportIndex = firstIndex() {
      return sports[sportIndex].findselectedSegment(editedSportStateUUID: currentStateId!, editedSportStateRuleId: currentSportStateRuleId!)
    }
    return nil
  }
  

}
