
import Foundation
import UIKit


class SportManager: ObservableObject {
  @Published var sports:[Sport] = SportManager.allSports

  // 以下属性只能用于查询 不能用作存储
  var currentSportId: UUID?
  var currentStateId: SportStateUUID?
  
  var currentSportStateRulesId: UUID?
  
  @Published var currentSportStateRuleId: String? {
    didSet {
      setSegmentToSelected()
    }
  }
  var editedSportStateRuleId: String?
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
  
  
  private func firstIndex(editedSport: Sport) -> Int? {
    return sports.firstIndex(where: { sport in
      sport.id == editedSport.id
    })
  }
  
  
  func findFirstSport() -> Sport? {
    if let sportIndex = firstIndex() {
      return sports[sportIndex]
    }else {
      return nil
    }
  }
  
  func findFirstSport(sport: Sport) -> Sport? {
    if let sportIndex = firstIndex(editedSport: sport) {
      return sports[sportIndex]
    }else {
      return nil
    }
  }
  
  func addSport(sport:Sport) {
    sports.append(sport)
  }
  
  func saveSport(editedSport: Sport) {
    Storage.store(editedSport, to: .documents, as: editedSport.sportFileName)
  }
  
  func updateSport(editedSport:Sport, sportName: String, sportDescription: String) {
    if let index = firstIndex(editedSport: editedSport) {
      sports[index].name = sportName
      sports[index].description = sportDescription
    }
  }
  
  func deleteSport(editedSport: Sport) {
    if let sportIndex = firstIndex(editedSport: editedSport) {
      sports.remove(at: sportIndex)
      Storage.delete(as: editedSport.sportFileName)
    }
  }
  
  //MARK: sport state
  
  
  func setCurrentSportState(editedSport : Sport, editedSportState: SportState) {
    currentStateId = editedSportState.id
  }
  
  func findFirstSportState() -> SportState? {
    if let sportIndex = firstIndex() {
      return sports[sportIndex].findFirstSportStateByUUID(editedStateUUID: currentStateId!)
    }
    return nil
  }
  
  func findSportStateByUUID(editedSport: Sport, sportStateUUID: SportStateUUID) -> SportState? {
    if let sportIndex = firstIndex(editedSport: editedSport) {
      return sports[sportIndex].findFirstSportStateByUUID(editedStateUUID: sportStateUUID)
    }
    
    return nil
  }
    
  
  func addSportState(editedSport: Sport, stateName: String, stateDescription: String) {
    if let sportIndex = firstIndex(editedSport: editedSport) {
      sports[sportIndex].updateState(stateName: stateName, stateDescription: stateDescription)
    }
  }

  
  func deleteSportState(editedSport: Sport, editedSportState: SportState) {
    if editedSportState.id != SportState.startState.id, editedSportState.id != SportState.endState.id, let sportIndex = firstIndex(editedSport: editedSport) {
      sports[sportIndex].deleteState(state: editedSportState)
    }
  }
  
  func setSportStateImage(image: UIImage, landmarkSegments: [LandmarkSegment]) {
    if let sportIndex = firstIndex() {
      sports[sportIndex].setSportStateImage(editedStateId: currentStateId!, image: image.pngData()!, width: Int(image.size.width), height: Int(image.size.width), landmarkSegments: landmarkSegments)
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
  
  
  func findSelectedSegments() -> [LandmarkSegment]? {
    if let sportIndex = firstIndex() {
      let segments = sports[sportIndex].findSelectedSegments(editedSportStateUUID: currentStateId!)
      return segments
    }
    return nil
  }
  
  
  // MARK: state rule
  func setCurrentSportStateRule(editedSport: Sport, editedSportState: SportState, editedSportStateRules: ComplexRules, editedSportStateRule: ComplexRule?, ruleType: RuleType) {
    currentSportId = editedSport.id
    currentStateId = editedSportState.id
    currentSportStateRulesId  = editedSportStateRules.id
    self.editedSportStateRuleId = editedSportStateRule?.id
    self.currentSportStateRuleId = nil
    currentSportStateRuleType = ruleType
  }
  
  
  func resetCurrentSportStateRule() {
    self.currentSportStateRuleId = self.editedSportStateRuleId
  }
  
  func setCurrentSportStateRule(editedSportStateRule: ComplexRule) {
    currentSportStateRuleId = editedSportStateRuleId
  }
  
  func updateCurrentRule(rule: ComplexRule) {
    if let sportIndex = firstIndex() {
      sports[sportIndex].updateSportStateRule(editedSportStateUUID: self.currentStateId!, editedSportStateRulesId: currentSportStateRulesId!, editedRule: rule, ruleType: currentSportStateRuleType!)
    }
  }
  
  func findSelectedRules(editedState: SportState, ruleType: RuleType) -> [ComplexRules] {
    switch ruleType {
    case .SCORE:
      return editedState.complexScoreRules
    case .VIOLATE:
      return editedState.complexViolateRules
    }
  }
  
  func findCurrentSportStateRule() -> ComplexRule? {
    if let sportIndex = firstIndex() {
      if let state = self.sports[sportIndex].findFirstSportStateByUUID(editedStateUUID: currentStateId!) {
        if let rules = state.firstComplexRulesById(editedRulesId: currentSportStateRulesId!, ruleType: currentSportStateRuleType!) {
          return rules.firstRuleByRuleId(ruleId: currentSportStateRuleId)
          
        }
      }
    }
    return nil
  }
  
  func findCurrentSportStateRule(editedSegmentType: LandmarkTypeSegment) -> ComplexRule? {
    // 查询当前规则
    if let sportIndex = firstIndex() {
      if let state = self.sports[sportIndex].findFirstSportStateByUUID(editedStateUUID: currentStateId!) {
        if let rules = state.firstComplexRulesById(editedRulesId: currentSportStateRulesId!, ruleType: currentSportStateRuleType!) {
          return rules.firstRuleBySegmentType(segmentType: editedSegmentType)
        }
      }
    }
    return nil
  }
  
  func setLandmarkArea(landmarkinArea: LandmarkInArea?) {
    if let rule = findCurrentSportStateRule() {
      var newRule = rule
      newRule.landmarkInArea = landmarkinArea
      self.updateCurrentRule(rule: newRule)
    }
  }
  func findCurrentLandMarkArea() -> LandmarkInArea? {
    if let rule = findCurrentSportStateRule() {
      if let area = rule.landmarkInArea {
        return area
      }
    }
    return nil
  }
  
  func updateSportStateRuleLandmarkInArea(firstPoint: CGPoint, secondPoint: CGPoint, thirdPoint:CGPoint, fourthPoint: CGPoint) {
    if let selectedLandmarkInArea = self.findCurrentLandMarkArea() {
      self.setLandmarkArea(landmarkinArea: LandmarkInArea(landmarkType: selectedLandmarkInArea.landmarkType, area: [firstPoint.point2d, secondPoint.point2d, thirdPoint.point2d, fourthPoint.point2d])
      )
    }
  }
  
  func updateSportStateRuleLandmarkInArea(landmarkType: LandmarkType) {
    if let selectedLandmarkInArea = self.findCurrentLandMarkArea() {
      self.setLandmarkArea(landmarkinArea: LandmarkInArea(landmarkType: landmarkType, area: selectedLandmarkInArea.area)
      )
    }else{
      self.setLandmarkArea(landmarkinArea: LandmarkInArea(landmarkType: landmarkType, area: []))
    }
  }
  
  func setCurrentSportStateRuleWarning(warning: String) {
    if let rule = findCurrentSportStateRule() {
      var newRule = rule
      newRule.warning = warning
      self.updateCurrentRule(rule: newRule)
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
      self.updateCurrentRule(rule: newRule)
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
      self.updateCurrentRule(rule: newRule)
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
      self.updateCurrentRule(rule: newRule)
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
      self.updateCurrentRule(rule: newRule)
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
      self.updateCurrentRule(rule: newRule)
      
    }
  }
  
  func setCurrentSportStateRuleAngle(angle: AngleRange?) {
    if let rule = findCurrentSportStateRule() {
      var newRule = rule
      newRule.angle  = angle
      self.updateCurrentRule(rule: newRule)
      
    }
  }
  
  
  func addNewSportStateRules(editedSport: Sport, editedSportState: SportState, ruleType: RuleType) {
    if let sportIndex = firstIndex(editedSport: editedSport) {
      sports[sportIndex].addNewSportStateRules(editedSportState: editedSportState, ruleType: ruleType)
    }
    
  }
  
  func deleteSportStateRules(editedSport: Sport, editedSportState: SportState, editedRules: ComplexRules, ruleType: RuleType) {
    if let sportIndex = firstIndex(editedSport: editedSport) {
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
