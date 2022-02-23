
import Foundation
import UIKit


class SportManager: ObservableObject {
  @Published var sports:[Sport] = SportManager.allSports()
  var newSport: Sport {
    Sport()
  }
  
  var currentSportId: UUID?
  var currentSportState:SportState?
  var currentSportStateRules: ComplexRules?
  @Published var currentSportStateRule: ComplexRule?
  var editedSportStateRule: ComplexRule?
  var currentSportStateRuleType:RuleType?
  var landmarkInArea: LandmarkInArea?
  @Published var hasAreaRule = false {
    didSet {
      print("hasAreaRule.................")
      if !hasAreaRule {
        landmarkInArea = nil
      }
    }
  }
  
  var isNewRule = false
  
  var dispather = Dispatcher()
  
}

extension SportManager {
  
  func sportStateTransforms(editedSport: Sport) -> [SportStateTransform] {
    findFirstSport(sport: editedSport)!.stateTransForm
  }
  
  static func allSports() -> [Sport] {
    return Storage.allFiles(.documents).map{ url in
      Storage.retrieve(url: url, as: Sport.self)
    }
  }
  
  func updateCurrentSportStateRuleWarning(warning: String) {
    if currentSportStateRule != nil {
      currentSportStateRule?.warning = warning
    }
  }
  
  var currentSportStateRuleWarning: String? {
    return currentSportStateRule?.warning
  }
  
  func updateSportStateRuleLandmarkInArea(firstPoint: CGPoint,
                                                  secondPoint: CGPoint,
                                                  thirdPoint:CGPoint,
                                                  fourthPoint: CGPoint
  ) {
    
    landmarkInArea?.area = [firstPoint, secondPoint, thirdPoint, fourthPoint]
    currentSportStateRule?.landmarkInArea = landmarkInArea
    
  }
  
  func updateSportStateRuleLandmarkInArea(landmarkType: LandmarkType) {
    
    if landmarkInArea == nil {
      landmarkInArea = LandmarkInArea(landmarkType: landmarkType, area: [])
    }else{
      landmarkInArea?.landmarkType = landmarkType
    }
    
  }
  
  func updateCurrentSportStateRuleLengthLowerBound(axis: CoordinateAxis, lowerBound: String) {
    if let lowerBound = Double(lowerBound) {
      switch axis {
        case .X:
          currentSportStateRule?.lengthX?.lowerBound = lowerBound
        case .Y:
          currentSportStateRule?.lengthY?.lowerBound = lowerBound
        case .XY:
          currentSportStateRule?.lengthXY?.lowerBound = lowerBound
        }
    }
  }
  
  
  
  
  func updateCurrentSportStateRuleLengthUpperBound(axis: CoordinateAxis, upperBound: String) {
    if let upperBound = Double(upperBound) {
      switch axis {
        case .X:
          currentSportStateRule?.lengthX?.upperBound = upperBound
        case .Y:
          currentSportStateRule?.lengthY?.upperBound = upperBound
        case .XY:
          currentSportStateRule?.lengthXY?.upperBound = upperBound
        }
    }
  }
  
  func getCurrentSportStateRuleLength(fromAxis: CoordinateAxis) -> RelativeLandmarkSegmentsToAxis {
    switch fromAxis {
    case .X:
      return currentSportStateRule!.lengthX!
    case .Y:
      return currentSportStateRule!.lengthY!
    case .XY:
      return currentSportStateRule!.lengthXY!
    }
  }
  
  func updateCurrentSportStateRuleLength(axis: CoordinateAxis, length: RelativeLandmarkSegmentsToAxis?) {
    if currentSportStateRule != nil {
      switch axis {
      case .X:
      
        currentSportStateRule?.lengthX = length
      case .Y:
        currentSportStateRule?.lengthY = length
      case .XY:
        currentSportStateRule?.lengthXY = length
      }
    }
    
    
  }
  
  func updateCurrentSportStateRuleLengthToLandmarkSegment(axis: CoordinateAxis, landmarkSegment: LandmarkSegment) {
    switch axis {
    case .X:
      currentSportStateRule?.lengthX?.to.landmarkSegment = landmarkSegment
    case .Y:
      currentSportStateRule?.lengthY?.to.landmarkSegment = landmarkSegment
    case .XY:
      currentSportStateRule?.lengthXY?.to.landmarkSegment = landmarkSegment
    }
  }
  
  
  func updateCurrentSportStateRuleLengthToAxis(fromAxis: CoordinateAxis, toAxis: CoordinateAxis) {
    switch fromAxis {
    case .X:
      currentSportStateRule?.lengthX?.to.axis = toAxis
      currentSportStateRule?.lengthX?.initBound()
    case .Y:
      currentSportStateRule?.lengthY?.to.axis = toAxis
      currentSportStateRule?.lengthY?.initBound()
    case .XY:
      currentSportStateRule?.lengthXY?.to.axis = toAxis
      currentSportStateRule?.lengthXY?.initBound()
    }
  }
  
  
  
  func setCurrentSportStateRuleAngle(angle: AngleRange?) {
    
    currentSportStateRule?.angle  = angle
  }
  
  
  
  private func firstIndex() -> Int? {
    print("firstIndex \(currentSportId)")
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
    print("currentSport - \(currentSportId)")
  }
  
  func setCurrentSportState(editedSport : Sport, editedSportState: SportState) {
    currentSportState = editedSportState
  }
  
  
  func setSportStateImage(image: UIImage, landmarkSegments: [LandmarkSegment]) {
    if let sportIndex = firstIndex() {
      sports[sportIndex].setSportStateImage(editedState: currentSportState!, image: image, landmarkSegments: landmarkSegments)
    }
  }
  
  
  func setCurrentSportStateRule(editedSport: Sport, editedSportState: SportState, editedSportStateRules: ComplexRules, editedSportStateRule: ComplexRule?, ruleType: RuleType) {
    currentSportId = editedSport.id
    currentSportState = editedSportState
    currentSportStateRules  = editedSportStateRules
    self.editedSportStateRule = editedSportStateRule
    self.currentSportStateRule = nil
    currentSportStateRuleType = ruleType
    if editedSportStateRule == nil {
      isNewRule = true
    }else{
      isNewRule = false
    }
//    setSegmentToSelected()
  }
  
  func setCurrentSportStateRule(editedSportStateRule: ComplexRule?) {
    currentSportStateRule = editedSportStateRule
    setSegmentToSelected()
  }
  
  func resetCurrentSportStateRule() {
    self.currentSportStateRule = self.editedSportStateRule
//    setSegmentToSelected()
//
//    self.currentSportStateRule = rule
    setSegmentToSelected()
    print("reset ...... \(currentSportStateRule)")

  }

  
  func setCurrentSportStateRule(editedSportStateRule: ComplexRule) {
    currentSportStateRule = editedSportStateRule
    setSegmentToSelected()
  }
  
  func selectedCurrentSportStateRule(editedSegmentType: LandmarkTypeSegment) -> ComplexRule? {
    // 查询当前规则
    if let sportIndex = firstIndex() {
      if let state = self.sports[sportIndex].findFirstSportState(editedState: currentSportState!) {
        if let rules = state.firstComplexRulesById(editedRulesId: currentSportStateRules!.id, ruleType: currentSportStateRuleType!) {
          return rules.firstRuleBySegmentType(segmentType: editedSegmentType)
        }
      }

      
    }
    setSegmentToSelected()
    return nil
  }
  
//  
//  func setSegmentToSelected(editedSport: Sport) {
//    if let sportIndex = firstIndex() {
//      sports[sportIndex].setSegmentToSelected(editedSportState: currentSportState!, editedSportStateRule: currentSportStateRule)
//    }
//  }
  
  func setSegmentToSelected() {
    if let sportIndex = firstIndex() {
      sports[sportIndex].setSegmentToSelected(editedSportState: currentSportState!, editedSportStateRule: currentSportStateRule)
    }
  }
  
  
  
  func findselectedSegment() -> LandmarkSegment? {
    if let sportIndex = firstIndex() {
      return sports[sportIndex].findselectedSegment(editedSportState: currentSportState!, editedSportStateRule: currentSportStateRule!)
    }
    return nil
  }
  
  func findSelectedSegments() -> [LandmarkSegment]? {
    if let sportIndex = firstIndex() {

      let segments = sports[sportIndex].findSelectedSegments(editedSportState: currentSportState!)
      
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
      sports[sportIndex].deleteSportStateRules(editedSportState: editedSportState, editedRules: editedRules, ruleType: ruleType)
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
  
  func updateSportStateRule() {
    if let currentSportStateRule = currentSportStateRule {
      if let sportIndex = firstIndex() {
        sports[sportIndex].updateSportStateRule(editedSportState: self.currentSportState!, editedSportStateRules: currentSportStateRules!, editedRule: currentSportStateRule, ruleType: currentSportStateRuleType!)
      }
    }
    
  }

}
