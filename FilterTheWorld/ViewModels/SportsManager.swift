
import Foundation
import UIKit
import SwiftUI




class SportsManager: ObservableObject {
    @Published var sports:[Sport] = SportsGround.allSports
    
    // 以下属性只能用于查询 不能用作存储
    var currentSportId: UUID?
    var currentStateId: Int?
    var currentSportStateRulesId: UUID?
    
    var updateTimer: Timer?
    
    @Published var currentSportStateRuleId: String?
    
    var currentSportStateRuleType:RuleType?
    
    var currentSportStateRuleClass:RuleClass = .LandmarkSegment {
        didSet {
            setSegmentToSelected()
            
        }
    }
    
    var dispather = Dispatcher()
    
    
    
}

extension SportsManager {
    // MARK: 计算变量
    
    //    static var allSports: [Sport] {
    //        Storage.allFiles(.documents).map{ url in
    //            Storage.retrieve(url: url, as: Sport.self)
    //        }
    //    }
    
    static var newSport: Sport {
        Sport(name: "I am Newer")
    }
    
    
    
    //MARK: sport
    
    func setSport(editedSport : Sport) {
        currentSportId = editedSport.id
    }
    
    private func firstIndexOfSport() -> Int? {
        if let currentSportId = currentSportId {
            return sports.firstIndex(where: { sport in
                sport.id == currentSportId
            })
        }
        return nil
    }
    
    
    private func firstIndexOfSport(editedSportId: UUID) -> Int? {
        return sports.firstIndex(where: { sport in
            sport.id == editedSportId
        })
    }
    
    
    func findFirstSport() -> Sport? {
        if let sportIndex = firstIndexOfSport() {
            return sports[sportIndex]
        }else {
            return nil
        }
    }
    
    func findFirstSport(sportId: UUID) -> Sport? {
        if let sportIndex = firstIndexOfSport(editedSportId: sportId) {
            return sports[sportIndex]
        }else {
            return nil
        }
    }
    
    func findFirstSport(sport: Sport) -> Sport? {
        findFirstSport(sportId: sport.id)
    }
    
    
    
    func addSport(sport:Sport) {
        if findFirstSport(sportId: sport.id) == nil {
            sports.append(sport)
        }
    }
    
    func addSport(sport:Sport, sportId: UUID) {
        var newSport = sport
        print("old \(sport.id) new \(sportId)")
        newSport.id = sportId
        if findFirstSport(sportId: newSport.id) == nil {
            sports.append(newSport)
        }
    }
    
    func saveSport(editedSport: Sport) {
        Storage.store(editedSport, to: .documents, as: editedSport.sportFileName)
    }
    
    
    
    func saveSports() {
        print("saveSports \(self.sports.count)")
        self.sports.forEach { sport in
            Storage.store(sport, to: .documents, as: sport.sportFileName)
        }
    }
    
    
    
    private func updateSport(sport: Sport) {
        if let index = firstIndexOfSport(editedSportId: sport.id) {
            sports[index] = sport
        }
    }
    
    func updateSport(editedSport:Sport, sportName: String, sportDescription: String, sportClass: SportClass,
                     sportPeriod: SportPeriod, sportDiscrete: SportPeriod, noStateWarning: String, isGestureController: Bool,
                     interactionType: InteractionType, dynamicAreaNumber: Int) {
        if let sport = findFirstSport(sport: editedSport) {
            var newSport = sport
            newSport.name = sportName
            newSport.description = sportDescription
            newSport.sportClass = sportClass
            newSport.sportPeriod = sportPeriod
            newSport.sportDiscrete = sportDiscrete
            newSport.noStateWarning = noStateWarning
            newSport.isGestureController = isGestureController
            newSport.interactionType = interactionType
            newSport.dynamicAreaNumber = dynamicAreaNumber
            updateSport(sport: newSport)
        }
    }
    
    func updateSport(editedSport:Sport, scoreTimeLimit: Double, interactionScoreCycle: Int, warningDelay: Double) {
        if let sport = findFirstSport(sport: editedSport) {
            var newSport = sport
            newSport.scoreTimeLimit = scoreTimeLimit
            newSport.interactionScoreCycle = interactionScoreCycle
            newSport.warningDelay = warningDelay
            
            updateSport(sport: newSport)
        }
    }
    
    func updateSport(editedSport:Sport, state: SportState, checkCycle: Double, passingRate:Double, keepTime: Double, isTimer: Bool) {
        
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports[sportIndex].updateSportState(editedSportState: state, checkCycle: checkCycle, passingRate: passingRate, keepTime: keepTime, isTimer: isTimer)
            
        }
    }
    
    func updateSport(editedSport:Sport, state: SportState) {
        
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports[sportIndex].updateSportState(editedSportState: state)
        }
    }
    
    func updateSport(editedSport:Sport, state: SportState, lowerBound: Double, upperBound: Double) {
        
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports[sportIndex].updateSportState(editedSportState: state, lowerBound: lowerBound, upperBound: upperBound)
        }
    }
    
    func updateSport(editedSport:Sport, state: SportState, rules: Rules, ruleType: RuleType, mergeLowerBound: Double, mergeUpperBound: Double, weightLowerBound: Double, weightUpperBound: Double) {
        
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports[sportIndex].updateSportState(editedSportState: state, rules: rules, ruleType: ruleType, mergeLowerBound: mergeLowerBound, mergeUpperBound: mergeUpperBound, weightLowerBound: weightLowerBound, weightUpperBound: weightUpperBound)
        }
    }
    
    func deleteSport(editedSport:Sport, state: SportState, timeRangeId: Int) {
        
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports[sportIndex].deleteSportState(editedSportState: state, timeRangeId: timeRangeId)
        }
    }
    
    func deleteSport(editedSport: Sport) {
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports.remove(at: sportIndex)
            Storage.delete(as: editedSport.sportFileName)
        }
    }
    
    //MARK: sport state
    
    func setState(editedSport : Sport, editedSportState: SportState) {
        currentSportId = editedSport.id
        currentStateId = editedSportState.id
    }
    
    
    

    
    func findFirstState() -> SportState? {
        findFirstSport()?.findFirstStateByStateId(stateId: currentStateId!)
    }
    
    
    func findFirstState(sportId: UUID, stateId: Int) -> SportState? {
        return findFirstSport(sportId: sportId)?.findFirstStateByStateId(stateId: stateId)
    }
    
    
    func findState(editedSport: Sport, sportStateUUID: Int) -> SportState? {
        return findFirstState(sportId: editedSport.id, stateId: sportStateUUID)
        
    }
    
    
    func addSportState(editedSport: Sport, stateName: String, stateDescription: String) {
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports[sportIndex].updateState(stateName: stateName, stateDescription: stateDescription)
        }
    }
    
    
    func deleteSportState(editedSport: Sport, editedSportState: SportState) {
        if [SportState.interAction_1, SportState.interAction_2, SportState.interAction_3,
            SportState.interAction_a, SportState.interAction_b, SportState.interAction_c, SportState.interAction_d,
            SportState.startState, SportState.endState, SportState.readyState].contains(where: { state in
            state.id == editedSportState.id
        }) {
            return
        }
        
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports[sportIndex].deleteState(state: editedSportState)
        }
    }
    
    
    private func updateSportState(state: SportState) {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].updateSport(state: state)
        }
    }
    
    func updateSportState(image: UIImage, humanPose: HumanPose?) {
        if let state = findFirstState() {
            var newState = state
            newState.image = PngImage(photo: image.pngData()!, width: Int(image.size.width), height: Int(image.size.height))
            
            newState.humanPose = humanPose
            newState.landmarkSegments = humanPose?.landmarkSegments ?? []
            self.updateSportState(state: newState)
            
        }
    }
    
    
    
    func updateSportState(image: UIImage, objects: [Observation]) {
        if let state = findFirstState() {
            var newState = state
            newState.image = PngImage(photo: image.pngData()!, width: Int(image.size.width), height: Int(image.size.height))
            newState.objects = objects
            self.updateSportState(state: newState)
        }
    }
    
    func keyFrameSetted(sport: Sport, state: SportState) -> Bool {
        if let state = findState(editedSport: sport, sportStateUUID: state.id) {
            return state.image != nil
        }
        return false
    }
    
    func updateSportState(sport: Sport, state: SportState, directToState: SportState) {
        
        
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            
            sports[sportIndex].updateSportState(editedSportState: state, directToState: directToState)
        }
    }
    
    func addSportStatetransform(sport: Sport, fromSportState: SportState, toSportState: SportState) {
        
        
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].addStateTransform(fromSportState: fromSportState, toSportState: toSportState)
        }
    }
    
    func deleteSportStateTransForm(sport:Sport, fromSportState: SportState, toSportState: SportState) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].deleteStateTransForm(fromSportState: fromSportState, toSportState: toSportState)
        }
    }
    
    func findSportStateTransforms(editedSport: Sport) -> [SportStateTransform] {
        findFirstSport(sport: editedSport)!.stateTransForm
    }
    
    
    
    func addSportStateScoreSequence(sport:Sport, index: Int, scoreState: SportState) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].addSportStateScoreSequence(index: index, scoreState: scoreState)
        }
    }
    
    func addSportStateInteractionScoreSequence(sport:Sport, index: Int, scoreState: SportState) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].addSportStateInteractionScoreSequence(index: index, scoreState: scoreState)
        }
    }
    
    func addSportStateViolateSequence(sport:Sport, index: Int, violateState: SportState, warning: String) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].addSportStateViolateSequence(index: index, violateState: violateState, warning: warning)
        }
    }
    
    func addSportStateScoreSequence(sport:Sport) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].addSportStateScoreSequence()
        }
    }
    
    func addSportStateInteractionScoreSequence(sport:Sport) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].addSportStateInteractionScoreSequence()
        }
    }
    
    func addSportStateViolateSequence(sport:Sport) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].addSportStateViolateSequence()
        }
    }
    
    func deleteSportStateScoreSequence() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].deleteSportStateScoreSequence()
        }
    }
    
    
    
    func deleteSportStateFromScoreSequence(sport:Sport, sequenceIndex: Int, stateIndex:Int) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id){
            sports[sportIndex].deleteSportStateFromScoreSequence(sequenceIndex: sequenceIndex, stateIndex: stateIndex)
        }
    }
    
    func deleteSportStateFromInteractionScoreSequence(sport:Sport, sequenceIndex: Int, stateIndex:Int) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id){
            sports[sportIndex].deleteSportStateFromInteractionScoreSequence(sequenceIndex: sequenceIndex, stateIndex: stateIndex)
        }
    }
    
    func deleteSportStateFromViolateSequence(sport:Sport, sequenceIndex: Int, stateIndex:Int) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id){
            sports[sportIndex].deleteSportStateFromViolateSequence(sequenceIndex: sequenceIndex, stateIndex: stateIndex)
        }
    }
    
    func findSportStateScoreSequence(editedSport: Sport) -> [[Int]] {
        findFirstSport(sport: editedSport)!.scoreStateSequence
    }
    
    func updateSport(sport: Sport, landmarkType: LandmarkType) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].updateSport(landmarkType: landmarkType)
        }
    }
    
    func deleteSport(sport: Sport, landmarkType: LandmarkType) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].deleteSport(landmarkType: landmarkType)
        }
    }
    
    func updateSport(sport: Sport, objectId: String) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].updateSport(objectId: objectId)
        }
    }
    
    func deleteSport(sport: Sport, objectId: String) {
        if let sportIndex = firstIndexOfSport(editedSportId: sport.id) {
            sports[sportIndex].deleteSport(objectId: objectId)
        }
    }
    
    
    func findSelectedSegments() -> [LandmarkSegment] {
        findFirstState()!.landmarkSegments
    }
    
    func findSelectedObjects() -> [Observation] {
        findFirstState()!.objects
    }
    

    
    func findDynamicAreasForSport() -> [DynamicAreaForSport] {
        return findFirstSport()!.dynamicAreas
    }
    
    func findFixedAreasForSport() -> [FixedAreaForSport] {
        return findFirstSport()!.fixedAreas
    }
    
    func findSelectedObjects(sport:Sport) -> [Observation]? {
        sport.states.first(where: { state in
            state.image != nil
        })?.objects
    }
    
    // MARK: state rule
    func setRule(editedSport: Sport, editedSportState: SportState, editedSportStateRules: Rules, editedSportStateRule: Ruler?, ruleType: RuleType, ruleClass: RuleClass) {
        currentSportId = editedSport.id
        currentStateId = editedSportState.id
        currentSportStateRulesId  = editedSportStateRules.id
        currentSportStateRuleType = ruleType
        self.currentSportStateRuleId = editedSportStateRule?.id
        self.currentSportStateRuleClass = ruleClass
        
//        print(currentSportStateRuleType)
    }
    
    
    func setCurrentSportStateRule(landmarkSegmentType: LandmarkTypeSegment, ruleClass: RuleClass) {
        currentSportStateRuleId = landmarkSegmentType.id
        currentSportStateRuleClass = ruleClass
        
    }
    
    func setCurrentSportStateRule(landmarkType: LandmarkType, ruleClass: RuleClass) {
        currentSportStateRuleId = landmarkType.id
        currentSportStateRuleClass = ruleClass
    }
    
    func setCurrentSportStateRule(objectLabel: String, ruleClass: RuleClass) {
        currentSportStateRuleId = objectLabel
        currentSportStateRuleClass = ruleClass
    }
    
    
    func setRule() -> Bool {
        if currentSportStateRuleId != nil {
            if let _ = self.findRule() {
                print("修改规则。。。。。。。。\(currentSportStateRuleId!) \(currentSportStateRuleClass.rawValue)")
            }else{
                
                if let sportIndex = firstIndexOfSport() {
                    sports[sportIndex].addRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
                }
                
                print("添加新规则。。。。。。。。")
            }
            
            
        }
        return currentSportStateRuleId != nil
    }
    
    
    private func findRulesList(sportId: UUID, editedStateId: Int, ruleType: RuleType) -> [Rules] {
        let sportState = findFirstState(sportId: sportId, stateId: editedStateId)!
        
        return sportState.findRulesList(ruleType: ruleType)
        
    }
    
    func findRulesList(sport: Sport, editedState: SportState, ruleType: RuleType) -> [Rules] {
        findRulesList(sportId: sport.id, editedStateId: editedState.id, ruleType: ruleType)
    }
    
    func findRules() -> Rules? {
        let sportState = findFirstState()
        return sportState?.findRules(ruleType: currentSportStateRuleType!, currentSportStateRulesId: currentSportStateRulesId!)
    }
    
    func findRule() -> Ruler? {
        
        // Rules
        let rules = findRules()
        return rules?.findFirstRule(ruleId: currentSportStateRuleId!, ruleClass: currentSportStateRuleClass)
    }
    
    func addNewRules(editedSport: Sport, editedSportState: SportState, ruleType: RuleType) {
        self.currentSportId = editedSport.id
        self.currentStateId = editedSportState.id
        self.currentSportStateRuleType = ruleType
        
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports[sportIndex].addNewSportStateRules(editedSportState: editedSportState, ruleType: ruleType)
        }
        
    }
    
    func deleteRules(editedSport: Sport, editedSportState: SportState, editedRules: Rules, ruleType: RuleType) {
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports[sportIndex].deleteRules(editedSportState: editedSportState, editedRulesId: editedRules.id, ruleType: ruleType)
        }
    }
    
    func deleteRule(editedSport: Sport, editedSportState: SportState, editedRules: Rules, ruleId:String, ruleType: RuleType, ruleClass: RuleClass) {
        if let sportIndex = firstIndexOfSport(editedSportId: editedSport.id) {
            sports[sportIndex].deleteRule(editedSportState: editedSportState, editedRulesId: editedRules.id, ruleId: ruleId, ruleType: ruleType, ruleClass: ruleClass)
        }
    }
    
    func setSegmentToSelected() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].setSegmentToSelected(editedSportStateUUID: currentStateId!, editedSportStateRuleId: currentSportStateRuleId, ruleClass: currentSportStateRuleClass)
        }
    }
    
    func findSelectedSegment() -> LandmarkSegment? {
        findFirstState()?.findselectedSegment(editedSportStateRuleId: currentSportStateRuleId)
    }
    
    func segmentSelected(segment: LandmarkSegment) -> Bool? {
        findFirstState()?.segmentSelected(segment: segment)
    }
    
    func findLandmarkSegment(landmarkTypeSegment: LandmarkTypeSegment) -> LandmarkSegment {
        findSelectedSegments().first{ segment in
            segment.id == landmarkTypeSegment.id
        }!
    }
    
    
    func addRuleLandmarkSegmentAngle() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleLandmarkSegmentAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    
    func getRuleLandmarkSegmentAngles() -> [LandmarkSegmentAngle] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkSegmentAngles(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleLandmarkSegmentAngle(id: UUID) -> LandmarkSegmentAngle {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkSegmentAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func removeRuleLandmarkSegmentAngle(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleLandmarkSegmentAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func updateRuleLandmarkSegmentAngle(warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,lowerBound: Double, upperBound: Double, id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleLandmarkSegmentAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                          warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  lowerBound: lowerBound, upperBound: upperBound, id: id)
    }
    
    
    //    ------------------------
    
    func getRuleAngleToLandmarkSegments() -> [AngleToLandmarkSegment] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleAngleToLandmarkSegments(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleAngleToLandmarkSegment(id: UUID) -> AngleToLandmarkSegment {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleAngleToLandmarkSegment(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func addRuleAngleToLandmarkSegment() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleAngleToLandmarkSegment(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    func removeRuleAngleToLandmarkSegment(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleAngleToLandmarkSegment(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func updateRuleAngleToLandmarkSegment(tolandmarkSegmentType: LandmarkTypeSegment, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleAngleToLandmarkSegment(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, tolandmarkSegmentType: tolandmarkSegmentType, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id)
    }
    
    
    
    //    ---------------
    
    func getRuleLandmarkSegmentLengths() -> [LandmarkSegmentLength] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkSegmentLengths(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleLandmarkSegmentLength(id: UUID) -> LandmarkSegmentLength {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkSegmentLength(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func addRuleLandmarkSegmentLength() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleLandmarkSegmentLength(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    func removeRuleLandmarkSegmentLength(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleLandmarkSegmentLength(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func updateRuleLandmarkSegmentLength(fromAxis: CoordinateAxis,tolandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,  id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleLandmarkSegmentLength(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, fromAxis: fromAxis, tolandmarkSegmentType: tolandmarkSegmentType, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id)
    }
    
    
    //    -------------------------------
    
    func getRuleLandmarkSegmentToStateAngles() -> [LandmarkSegmentToStateAngle] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkSegmentToStateAngles(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleLandmarkSegmentToStateAngle(id: UUID) -> LandmarkSegmentToStateAngle {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkSegmentToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    
    
    func addRuleLandmarkSegmentToStateAngle() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleLandmarkSegmentToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    
    func removeRuleLandmarkSegmentToStateAngle(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleLandmarkSegmentToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func updateRuleLandmarkSegmentToStateAngle(
        toStateId: Int,
        isRelativeToExtremeDirection: Bool,
        extremeDirection: ExtremeDirection,
        lowerBound: Double, upperBound: Double,
        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, id: UUID) {
            let sportIndex = firstIndexOfSport()!
            sports[sportIndex].updateRuleLandmarkSegmentToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                                     toStateId: toStateId,
                                                                     isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                     extremeDirection: extremeDirection,
                                                                     lowerBound: lowerBound, upperBound: upperBound,
                                                                     warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id)
            
        }
    
    
    //    -------------------------------
    
    func getRuleLandmarkSegmentToStateDistances() -> [LandmarkSegmentToStateDistance] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkSegmentToStateDistances(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleLandmarkSegmentToStateDistance(id: UUID) -> LandmarkSegmentToStateDistance {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkSegmentToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    
    
    func addRuleLandmarkSegmentToStateDistance() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleLandmarkSegmentToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    
    func removeRuleLandmarkSegmentToStateDistance(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleLandmarkSegmentToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func updateRuleLandmarkSegmentToStateDistance(
        fromAxis: CoordinateAxis,
        toStateId: Int,
        isRelativeToExtremeDirection: Bool,
        extremeDirection: ExtremeDirection,
        lowerBound: Double, upperBound: Double,
        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID) {
            let sportIndex = firstIndexOfSport()!
            sports[sportIndex].updateRuleLandmarkSegmentToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                                        fromAxis: fromAxis,
                                                                        toStateId: toStateId,
                                                                        isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                                        extremeDirection: extremeDirection,
                                                                        lowerBound: lowerBound, upperBound: upperBound,
                                                                        warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id)
            
        }
    
    
    
    
    
    
    //    ---------------
    
    func getRuleDistanceToLandmarks() -> [DistanceToLandmark] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleDistanceToLandmarks(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleDistanceToLandmark(id: UUID) -> DistanceToLandmark {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleDistanceToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func addRuleDistanceToLandmark() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleDistanceToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    func removeRuleDistanceToLandmark(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleDistanceToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func updateRuleDistanceToLandmark(fromAxis: CoordinateAxis, toLandmarkType: LandmarkType, tolandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleDistanceToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, fromAxis: fromAxis,  toLandmarkType: toLandmarkType, tolandmarkSegmentType: tolandmarkSegmentType, toAxis: toAxis, lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id)
    }
    
    //    -------------------------------
    
    
    
    
    func addRuleAngleToLandmark() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleAngleToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    
    func getRuleAngleToLandmarks() -> [AngleToLandmark] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleAngleToLandmarks(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleAngleToLandmark(id: UUID) -> AngleToLandmark {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleAngleToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func removeRuleAngleToLandmark(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleAngleToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func updateRuleAngleToLandmark(warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  lowerBound: Double, upperBound: Double, toLandmarkType: LandmarkType, id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleAngleToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                     warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  lowerBound: lowerBound, upperBound: upperBound, toLandmarkType: toLandmarkType, id: id)
    }
    
    //    -------------------------------
    
    func getRuleLandmarkToStateDistances() -> [LandmarkToStateDistance] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkToStateDistances(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleLandmarkToStateDistancesMerge() -> [LandmarkToStateDistance] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkToStateDistancesMerge(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleLandmarkToStateDistance(id: UUID) -> LandmarkToStateDistance {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func getRuleLandmarkToStateDistanceMerge(id: UUID) -> LandmarkToStateDistance {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkToStateDistanceMerge(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    
    
    func addRuleLandmarkToStateDistance() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleLandmarkToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    func addRuleLandmarkToStateDistanceMerge() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleLandmarkToStateDistanceMerge(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    
    func removeRuleLandmarkToStateDistance(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleLandmarkToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func removeRuleLandmarkToStateDistanceMerge(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleLandmarkToStateDistanceMerge(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func updateRuleLandmarkToStateDistance(fromAxis: CoordinateAxis,
                                           toStateId: Int,
                                           toLandmarkType: LandmarkType,
                                           isRelativeToExtremeDirection: Bool,
                                           extremeDirection: ExtremeDirection,
                                           toLandmarkSegmentType: LandmarkTypeSegment,
                                           toAxis: CoordinateAxis,
                                           lowerBound: Double, upperBound: Double,
                                           warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID, defaultSatisfy: Bool,toStateToggle: Bool, toLastFrameToggle: Bool) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleLandmarkToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                             fromAxis: fromAxis,
                                                             toStateId: toStateId,
                                                             toLandmarkType: toLandmarkType,
                                                             isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                             extremeDirection: extremeDirection,
                                                             toLandmarkSegmentType: toLandmarkSegmentType,
                                                             toAxis: toAxis,
                                                             lowerBound: lowerBound, upperBound: upperBound,
                                                             warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id, defaultSatisfy: defaultSatisfy,toStateToggle: toStateToggle, toLastFrameToggle: toLastFrameToggle)
        
    }
    
    func updateRuleLandmarkToStateDistanceMerge(fromAxis: CoordinateAxis,
                                           toStateId: Int,
                                           toLandmarkType: LandmarkType,
                                           isRelativeToExtremeDirection: Bool,
                                           extremeDirection: ExtremeDirection,
                                           toLandmarkSegmentType: LandmarkTypeSegment,
                                           toAxis: CoordinateAxis,
                                           lowerBound: Double, upperBound: Double,
                                                warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID, defaultSatisfy: Bool, toStateToggle: Bool, toLastFrameToggle: Bool, weight: Double)  {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleLandmarkToStateDistanceMerge(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                             fromAxis: fromAxis,
                                                             toStateId: toStateId,
                                                             toLandmarkType: toLandmarkType,
                                                             isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                             extremeDirection: extremeDirection,
                                                             toLandmarkSegmentType: toLandmarkSegmentType,
                                                             toAxis: toAxis,
                                                             lowerBound: lowerBound, upperBound: upperBound,
                                                                  warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id, defaultSatisfy: defaultSatisfy, toStateToggle: toStateToggle, toLastFrameToggle: toLastFrameToggle, weight: weight)
        
    }
    
    
    
    //    -------------------------------
    
    func getRuleLandmarkToStateAngles() -> [LandmarkToStateAngle] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkToStateAngles(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleLandmarkToStateAngle(id: UUID) -> LandmarkToStateAngle {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    
    
    func addRuleLandmarkToStateAngle() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleLandmarkToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    
    func removeRuleLandmarkToStateAngle(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleLandmarkToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func updateRuleLandmarkToStateAngle(
        toStateId: Int,
        isRelativeToExtremeDirection: Bool,
        extremeDirection: ExtremeDirection,
        lowerBound: Double, upperBound: Double,
        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
            let sportIndex = firstIndexOfSport()!
            sports[sportIndex].updateRuleLandmarkToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                              toStateId: toStateId,
                                                              isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                              extremeDirection: extremeDirection,
                                                              lowerBound: lowerBound, upperBound: upperBound,
                                                              warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id)
            
        }
    
    
    //    ---------------------------------
    
    func getRuleObjectToLandmarks() -> [ObjectToLandmark] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleObjectToLandmarks(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    
    func getRuleObjectToLandmark(id: UUID) -> ObjectToLandmark {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleObjectToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func addRuleObjectToLandmark() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleObjectToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    func removeRuleObjectToLandmark(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleObjectToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func updateRuleObjectToLandmark(objectPosition: ObjectPosition,
                                    fromAxis: CoordinateAxis,
                                    toLandmarkType: LandmarkType,
                                    toLandmarkSegmentType: LandmarkTypeSegment,
                                    toAxis: CoordinateAxis,
                                    lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool, id: UUID, isRelativeToObject: Bool) {
        
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleObjectToLandmark(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                      objectPosition: objectPosition,
                                                      fromAxis: fromAxis,
                                                      toLandmarkType: toLandmarkType,
                                                      toLandmarkSegmentType: toLandmarkSegmentType,
                                                      toAxis: toAxis,
                                                      lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear, id: id, isRelativeToObject: isRelativeToObject)
        
        
    }
    
    
    //    ---------------------------------
    
    func getRuleObjectToObjects() -> [ObjectToObject] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleObjectToObjects(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    
    func getRuleObjectToObject(id: UUID) -> ObjectToObject {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleObjectToObject(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func addRuleObjectToObject() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleObjectToObject(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    func removeRuleObjectToObject(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleObjectToObject(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func updateRuleObjectToObject(fromAxis: CoordinateAxis, fromObjectPosition: ObjectPosition, toObjectId: String, toObjectPosition: ObjectPosition, toLandmarkSegmentType: LandmarkTypeSegment, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool, id: UUID, isRelativeToObject: Bool) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleObjectToObject(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                    fromAxis: fromAxis,fromObjectPosition: fromObjectPosition,toObjectId: toObjectId, toObjectPosition: toObjectPosition, toLandmarkSegmentType: toLandmarkSegmentType, toAxis: toAxis,     lowerBound: lowerBound, upperBound: upperBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id, isRelativeToObject: isRelativeToObject)
    }
    
    
    
    //    -------------------------------
    
    func getRuleObjectToStateDistances() -> [ObjectToStateDistance] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleObjectToStateDistances(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleObjectToStateDistance(id: UUID) -> ObjectToStateDistance {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleObjectToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    
    
    func addRuleObjectToStateDistance() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleObjectToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    
    func removeRuleObjectToStateDistance(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleObjectToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func updateRuleObjectToStateDistance(fromAxis: CoordinateAxis,
                                         toStateId: Int,
                                         fromPosition: ObjectPosition,
                                         isRelativeToObject: Bool,
                                         isRelativeToExtremeDirection: Bool,
                                         extremeDirection: ExtremeDirection,
                                         toLandmarkSegmentType: LandmarkTypeSegment,
                                         toAxis: CoordinateAxis,
                                         lowerBound: Double, upperBound: Double,
                                         warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleObjectToStateDistance(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                           fromAxis: fromAxis,
                                                           toStateId: toStateId,
                                                           fromPosition: fromPosition,
                                                           isRelativeToObject: isRelativeToObject,
                                                           isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                           extremeDirection: extremeDirection,
                                                           
                                                           toLandmarkSegmentType: toLandmarkSegmentType,
                                                           toAxis: toAxis,
                                                           lowerBound: lowerBound, upperBound: upperBound,
                                                           warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime,changeStateClear: changeStateClear,  id: id)
        
    }
    
    
    //    -------------------------------
    
    func getRuleObjectToStateAngles() -> [ObjectToStateAngle] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleObjectToStateAngles(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    func getRuleObjectToStateAngle(id: UUID) -> ObjectToStateAngle {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleObjectToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    
    
    func addRuleObjectToStateAngle() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleObjectToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    
    func removeRuleObjectToStateAngle(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleObjectToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    
    func updateRuleObjectToStateAngle(
        toStateId: Int,
        fromPosition: ObjectPosition,
        isRelativeToExtremeDirection: Bool,
        extremeDirection: ExtremeDirection,
        lowerBound: Double, upperBound: Double,
        warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double,changeStateClear: Bool,  id: UUID) {
            let sportIndex = firstIndexOfSport()!
            sports[sportIndex].updateRuleObjectToStateAngle(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,                                                                                                         toStateId: toStateId,
                                                            fromPosition: fromPosition,
                                                            isRelativeToExtremeDirection: isRelativeToExtremeDirection,
                                                            extremeDirection: extremeDirection,
                                                            lowerBound: lowerBound, upperBound: upperBound,
                                                            warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, id: id)
            
        }
    
    //    Area rule---------------------------------
    

    
    func getFixedArea() -> FixedAreaForSport? {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getFixedArea(ruleId: currentSportStateRuleId)
    }
    
    func getFixedAreas() -> [FixedAreaForSport] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getFixedAreas()
    }
    
    func getDynamicArea() -> DynamicAreaForSport? {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getDynamicArea(ruleId: currentSportStateRuleId)
    }

    
    func updateFixedArea(width: Double, heightToWidthRatio: Double, centerX: Double, centerY: Double, content: String
    ) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateFixedArea(stateId: currentStateId!, ruleId: currentSportStateRuleId!, width: width, heightToWidthRatio: heightToWidthRatio, centerX: centerX, centerY: centerY, content: content)
    }
    
    func updateDynamicArea(width: Double, heightToWidthRatio: Double,
                           leftTopX: Double, leftTopY: Double, rightBottomX: Double, rightBottomY: Double, content: String
    ) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateDynamicArea(stateId: currentStateId!, ruleId: currentSportStateRuleId!, width: width, heightToWidthRatio: heightToWidthRatio, leftTopX: leftTopX, leftTopY: leftTopY, rightBottomX: rightBottomX, rightBottomY: rightBottomY, content: content)
    }

    
    //    ---------------------------------
    
    func getRuleLandmarkInFixedAreasForAreaRule() -> [LandmarkInAreaForAreaRule] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkInFixedAreasForAreaRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    
    
    func getRuleLandmarkInFixedArea(id: UUID) -> LandmarkInAreaForAreaRule {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkInFixedAreaForAreaRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func addRuleLandmarkInFixedAreaForAreaRule() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleLandmarkInFixedAreaForAreaRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    func removeRuleLandmarkInFixedArea(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleLandmarkInFixedAreaForAreaRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func updateRuleLandmarkInFixedArea(area: [Point2D],
                                  warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,
                                             landmarkType: LandmarkType, id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleLandmarkInFixedAreaForAreaRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                               area: area, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, landmarkType: landmarkType, id: id)
        
    }
    
    
    //    ---------------------------------
    
    func getRuleLandmarkInDynamicAreas() -> [LandmarkInAreaForAreaRule] {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkInDynamicAreasForAreaRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
    }
    
    
    
    func getRuleLandmarkInDynamicArea(id: UUID) -> LandmarkInAreaForAreaRule {
        let sportIndex = firstIndexOfSport()!
        return sports[sportIndex].getRuleLandmarkInDynamicAreaForAreaRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func addRuleLandmarkInDynamicAreaForAreaRule() {
        if let sportIndex = firstIndexOfSport() {
            sports[sportIndex].addRuleLandmarkInDynamicAreaForAreaRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass)
        }
    }
    
    func removeRuleLandmarkInDynamicArea(id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].removeRuleLandmarkInDynamicAreaForAreaRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass, id: id)
    }
    
    func updateRuleLandmarkInDynamicArea(area: [Point2D],
                                  warningContent: String, triggeredWhenRuleMet: Bool, delayTime: Double, changeStateClear: Bool,
                                             landmarkType: LandmarkType, id: UUID) {
        let sportIndex = firstIndexOfSport()!
        sports[sportIndex].updateRuleLandmarkInDynamicAreaForAreaRule(stateId: currentStateId!, rulesId: currentSportStateRulesId!, ruleId: currentSportStateRuleId!, ruleType: currentSportStateRuleType!, ruleClass: currentSportStateRuleClass,
                                                               area: area, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, changeStateClear: changeStateClear, landmarkType: landmarkType, id: id)
        
    }
//    ---------------------
    
    
    
    
    func transferRuleTo(sportId: UUID, stateId:Int, ruleType:RuleType, rulesIndex:Int, rule: Ruler
    ) {
        if let sportIndex = firstIndexOfSport(editedSportId: sportId) {
            sports[sportIndex].transferRuleTo(stateId: stateId, ruleType: ruleType, rulesIndex: rulesIndex, rule: rule)
        }
    }
    
}
