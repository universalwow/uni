
import Foundation
import UIKit


class SportManager: ObservableObject {
  @Published var sports:[Sport] = SportManager.allSports()
  var newSport: Sport {
    Sport()
  }
  
  
  // 以下属性只能用于查询 不能用作存储
  var currentSportId: UUID?
  var currentStateId: SportStateUUID?
  
  var currentSportStateRulesId: UUID?
  @Published var currentSportStateRuleId: String?
  var editedSportStateRuleId: String?
  var currentSportStateRuleType:RuleType?

  var isNewRule = false
  
  var dispather = Dispatcher()
  
}

extension SportManager {
  
  
  func selectCurrentLandMarkArea() -> LandmarkInArea? {
    if let rule = selectCurrentRule() {
      if let area = rule.landmarkInArea {
        return area
      }
    }
    return nil
    
  }
  
  func setupLandmarkArea(landmarkinArea: LandmarkInArea?) {
    if let rule = selectCurrentRule() {
      var newRule = rule
      newRule.landmarkInArea = landmarkinArea
      self.updateCurrentRule(rule: newRule)
    }
    
  }
  
  func sportStateTransforms(editedSport: Sport) -> [SportStateTransform] {
    findFirstSport(sport: editedSport)!.stateTransForm
  }
  
  static func allSports() -> [Sport] {
    return Storage.allFiles(.documents).map{ url in
      Storage.retrieve(url: url, as: Sport.self)
    }
  }
  
  func updateCurrentSportStateRuleWarning(warning: String) {
    if let rule = selectCurrentRule() {
      var newRule = rule
      newRule.warning = warning
      self.updateCurrentRule(rule: newRule)
    }
    
  }
  
  var currentSportStateRuleWarning: String? {
    if let rule = selectCurrentRule() {
      return rule.warning
    }
    return nil
  }
  
  func updateSportStateRuleLandmarkInArea(firstPoint: CGPoint, secondPoint: CGPoint,
                                                  thirdPoint:CGPoint, fourthPoint: CGPoint
  ) {
    if let selectedLandmarkInArea = self.selectCurrentLandMarkArea() {
      self.setupLandmarkArea(landmarkinArea: LandmarkInArea(landmarkType: selectedLandmarkInArea.landmarkType, area: [firstPoint, secondPoint, thirdPoint, fourthPoint])
      )
    }
    
  }
  
  func updateSportStateRuleLandmarkInArea(landmarkType: LandmarkType) {
    if let selectedLandmarkInArea = self.selectCurrentLandMarkArea() {
      self.setupLandmarkArea(landmarkinArea: LandmarkInArea(landmarkType: landmarkType, area: selectedLandmarkInArea.area)
      )
    }else{
      self.setupLandmarkArea(landmarkinArea: LandmarkInArea(landmarkType: landmarkType, area: []))
    }
    
  }
  
  func selectCurrentRule() -> ComplexRule? {
    if let sportIndex = firstIndex() {
      if let state = self.sports[sportIndex].findFirstSportStateByUUID(editedStateUUID: currentStateId!) {
        if let rules = state.firstComplexRulesById(editedRulesId: currentSportStateRulesId!, ruleType: currentSportStateRuleType!) {
          return rules.firstRuleByRuleId(ruleId: currentSportStateRuleId)
          
        }
      }
    }
    return nil
  }
  
  func updateCurrentRule(rule: ComplexRule) {
    if let sportIndex = firstIndex() {
      sports[sportIndex].updateSportStateRule(editedSportStateUUID: self.currentStateId!, editedSportStateRulesId: currentSportStateRulesId!, editedRule: rule, ruleType: currentSportStateRuleType!)
    }
  }
  
  func updateCurrentRuleLengthLowerBound(axis: CoordinateAxis, lowerBound: String) {
    if let rule = self.selectCurrentRule() {
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
    if let rule = self.selectCurrentRule() {
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

  
  func getCurrentSportStateRuleLength(fromAxis: CoordinateAxis) -> RelativeLandmarkSegmentsToAxis {
    let rule = selectCurrentRule()!
    switch fromAxis {
    case .X:
      return rule.lengthX!
    case .Y:
      return rule.lengthY!
    case .XY:
      return rule.lengthXY!
    }
  }
  
  func updateCurrentSportStateRuleLength(axis: CoordinateAxis, length: RelativeLandmarkSegmentsToAxis?) {
    if let rule = selectCurrentRule() {
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
    
    if let rule = selectCurrentRule() {
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
    
    if let rule = selectCurrentRule() {
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
    if let rule = selectCurrentRule() {
      var newRule = rule
      newRule.angle  = angle
      self.updateCurrentRule(rule: newRule)
      
    }
  }
  
  private func firstIndex() -> Int? {
//    print("firstIndex \(currentSportId)")
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
  
  func setCurrentSport(editedSport : Sport) {
    currentSportId = editedSport.id
//    print("currentSport - \(currentSportId)")
  }
  
  func setCurrentSportState(editedSport : Sport, editedSportState: SportState) {
    currentStateId = editedSportState.id
  }
  
  func setSportStateImage(image: UIImage, landmarkSegments: [LandmarkSegment]) {
    if let sportIndex = firstIndex() {
      sports[sportIndex].setSportStateImage(editedStateId: currentStateId!, image: image, landmarkSegments: landmarkSegments)
    }
  }
  
  func setCurrentSportStateRule(editedSport: Sport, editedSportState: SportState, editedSportStateRules: ComplexRules, editedSportStateRule: ComplexRule?, ruleType: RuleType) {
    currentSportId = editedSport.id
    currentStateId = editedSportState.id
    currentSportStateRulesId  = editedSportStateRules.id
    self.editedSportStateRuleId = editedSportStateRule?.id
    self.currentSportStateRuleId = nil
    currentSportStateRuleType = ruleType
    if editedSportStateRule == nil {
      isNewRule = true
    }else{
      isNewRule = false
    }
  }
  
  func setCurrentSportStateRule(editedSportStateRule: ComplexRule?) {
    currentSportStateRuleId = editedSportStateRule?.id
    setSegmentToSelected()
  }
  
  func resetCurrentSportStateRule() {
    print("before reset ...... \(currentSportStateRuleId)")

    self.currentSportStateRuleId = self.editedSportStateRuleId
    setSegmentToSelected()
    print("after reset ...... \(currentSportStateRuleId)")

  }

  func setCurrentSportStateRule(editedSportStateRule: ComplexRule) {
    currentSportStateRuleId = editedSportStateRuleId
    setSegmentToSelected()
  }
  
  func selectedCurrentSportStateRule(editedSegmentType: LandmarkTypeSegment) -> ComplexRule? {
    // 查询当前规则
    if let sportIndex = firstIndex() {
      if let state = self.sports[sportIndex].findFirstSportStateByUUID(editedStateUUID: currentStateId!) {
        if let rules = state.firstComplexRulesById(editedRulesId: currentSportStateRulesId!, ruleType: currentSportStateRuleType!) {
          return rules.firstRuleBySegmentType(segmentType: editedSegmentType)
        }
      }

      
    }
    setSegmentToSelected()
    return nil
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
  
  
  func findCurrentState() -> SportState? {
    if let sportIndex = firstIndex() {
      return sports[sportIndex].findFirstSportStateByUUID(editedStateUUID: currentStateId!)
    }
    return nil
  }
  
  func findSelectedSegments() -> [LandmarkSegment]? {
    if let sportIndex = firstIndex() {

      let segments = sports[sportIndex].findSelectedSegments(editedSportStateUUID: currentStateId!)
      
      return segments
    }
    return nil
  }
  
  
  func findSelectedRules(editedState: SportState, ruleType: RuleType) -> [ComplexRules] {
    switch ruleType {
    case .SCORE:
      return editedState.complexScoreRules
    case .VIOLATE:
      return editedState.complexViolateRules
    }
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
  
  
  func findSportStateByUUID(editedSport: Sport, sportStateUUID: SportStateUUID) -> SportState? {
    if let sportIndex = firstIndex(editedSport: editedSport) {
      return sports[sportIndex].findSportStateByUUID(sportStateUUID: sportStateUUID)
    }
    
    return nil
  }
  
  func findSportStateByName(sportStateName: String) -> SportState? {
    if let sportIndex = firstIndex() {
      return sports[sportIndex].findSportStateByName(sportStateName: sportStateName)
    }
    
    return nil
  }
  
  
  
  
  func play(poseMap: PoseMap, currentTime: Double) {
    if let sportIndex = firstIndex() {

      sports[sportIndex].play(poseMap: poseMap, currentTime: currentTime)
      // 展示提示消息
      sports[sportIndex].cancelingWarnings.forEach {warning in
        dispather.cancelAction(with: warning)
        }
      
      sports[sportIndex].newWarnings.forEach{ warning in
        dispather.schedule(after: 1, with: warning, on: nil, action: {
          print(warning)
        })

      }
      
    }
  }
  
  func deleteSport() {
  }
  
  
  func addSport(sport:Sport) {
    sports.append(sport)
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
  
  func updateSport(editedSport:Sport, sportName: String, sportDescription: String) {
    if let index = firstIndex(editedSport: editedSport) {
      sports[index].name = sportName
      sports[index].description = sportDescription
    }
  }
  
  func deleteSportState(editedSport: Sport, editedSportState: SportState) {
    if let sportIndex = firstIndex(editedSport: editedSport) {
      sports[sportIndex].deleteState(state: editedSportState)
    }
    
  }
  
  func addSportState(editedSport: Sport, stateName: String, stateDescription: String) {
    if let sportIndex = firstIndex(editedSport: editedSport) {
      sports[sportIndex].updateState(stateName: stateName, stateDescription: stateDescription)
    }
  }
  
  
  func updateSportStateIsScore(editedSport: Sport, sportStateName: String, isScore: Bool) {
    if let sportIndex = firstIndex(editedSport: editedSport) {
      sports[sportIndex].updateStateIsScore(stateName: sportStateName, isScore: isScore)
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
  

}
