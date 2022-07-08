
import Foundation
import UIKit
import SwiftUI




class SportsManager: ObservableObject {
    @Published var sports:[Sport] = SportsManager.allSports
    
    // 以下属性只能用于查询 不能用作存储
    var currentSportId: UUID?
    var currentStateId: Int?
    var currentSportStateRulesId: UUID?
    
    var updateTimer: Timer?
    
    @Published var currentSportStateRuleId: String?
//    {
//        didSet {
//            if currentSportStateRuleId != nil {
//                if let _ = self.findCurrentSportStateRule() {
//                    print("修改规则。。。。。。。。")
//                }else{
//
//                    self.addStateRule()
//                    print("添加新规则。。。。。。。。")
//                }
//                print("setSegmentToSelected \(currentSportStateRuleId)")
//            }
//
//            setSegmentToSelected()
//
//        }
//    }
    
    
    var currentSportStateRuleType:RuleType?
    var dispather = Dispatcher()
    
}

extension SportsManager {
    
    // MARK: 计算变量
    
    static var allSports: [Sport] {
        Storage.allFiles(.documents).map{ url in
            Storage.retrieve(url: url, as: Sport.self)
        }
    }
    
    static var newSport: Sport {
        Sport(name: "I am Newer")
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
    
    func saveSports() {
        self.sports.forEach { sport in
            Storage.store(sport, to: .documents, as: sport.sportFileName)
        }
    }
    
    func uploadSports() {
        self.sports.forEach { sport in
//            Storage.store(sport, to: .documents, as: sport.sportFileName)
        }
    }
    
    private func updateSport(sport: Sport) {
        if let index = firstIndex(editedSportId: sport.id) {
            print("\(sport.description)")
            
            sports[index] = sport
        }
    }
    
    func updateSport(editedSport:Sport, sportName: String, sportDescription: String) {
        if let sport = findFirstSport(sport: editedSport) {
            var newSport = sport
            newSport.name = sportName
            newSport.description = sportDescription
            print("\(newSport.name) - \(newSport.description)")
            
            updateSport(sport: newSport)
        }
    }
    
    func updateSport(editedSport:Sport, scoreTimeLimit: Double) {
        if let sport = findFirstSport(sport: editedSport) {
            var newSport = sport
            newSport.scoreTimeLimit = scoreTimeLimit
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
        currentSportId = editedSport.id
        currentStateId = editedSportState.id
    }
    
    func findFirstSportState() -> SportState? {
        findFirstSport()?.findFirstSportStateByUUID(editedStateUUID: currentStateId!)
    }
    
    
    
    
    private func findFirstSportState(editedSportId: UUID, sportStateUUID: Int) -> SportState? {
        findFirstSport(sportId: editedSportId)?.findFirstSportStateByUUID(editedStateUUID: sportStateUUID)
    }
    
    
    func findFirstSportState(editedSport: Sport, sportStateUUID: Int) -> SportState? {
        return findFirstSportState(editedSportId: editedSport.id, sportStateUUID: sportStateUUID)
        
    }
    
    
    func addSportState(editedSport: Sport, stateName: String, stateDescription: String) {
        if let sportIndex = firstIndex(editedSportId: editedSport.id) {
            sports[sportIndex].updateState(stateName: stateName, stateDescription: stateDescription)
        }
    }
    
    
    func deleteSportState(editedSport: Sport, editedSportState: SportState) {
        if [SportState.startState, SportState.endState].contains(where: { state in
            state.id == editedSportState.id
        }) {
            return
        }
        
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
            newState.image = PngImage(photo: image.pngData()!, width: Int(image.size.width), height: Int(image.size.height))
            
            newState.landmarkSegments = landmarkSegments
            self.updateSportState(state: newState)
            
        }
    }
    
    func updateSportState(image: UIImage, objects: [Observation]) {
        if let state = findFirstSportState() {
            var newState = state
            newState.image = PngImage(photo: image.pngData()!, width: Int(image.size.width), height: Int(image.size.height))
            newState.objects = objects
            self.updateSportState(state: newState)
            
        }
    }
    
    func keyFrameSetted(sport: Sport, state: SportState) -> Bool {
        if let state = findFirstSportState(editedSport: sport, sportStateUUID: state.id) {
            return state.image != nil
        }
        return false
    }
    
    
    func addSportStatetransform(sport: Sport, fromSportState: SportState, toSportState: SportState) {
        
        
        if let sportIndex = firstIndex(editedSportId: sport.id) {
            sports[sportIndex].addStateTransform(fromSportState: fromSportState, toSportState: toSportState)
        }
    }
    
    func deleteSportStateTransForm(sport:Sport, fromSportState: SportState, toSportState: SportState) {
        if let sportIndex = firstIndex(editedSportId: sport.id) {
            sports[sportIndex].deleteStateTransForm(fromSportState: fromSportState, toSportState: toSportState)
        }
    }
    
    func findSportStateTransforms(editedSport: Sport) -> [SportStateTransform] {
        findFirstSport(sport: editedSport)!.stateTransForm
    }
    
    func addSportStateScoreSequence(sport:Sport, scoreState: SportState) {
        if let sportIndex = firstIndex(editedSportId: sport.id) {
            sports[sportIndex].addSportStateScoreSequence(scoreState: scoreState)
        }
    }
    
    func deleteSportStateScoreSequence() {
        if let sportIndex = firstIndex() {
            sports[sportIndex].deleteSportStateScoreSequence()
        }
    }
    
    func deleteSportStateFromScoreSequence(sport:Sport, stateIndex:Int) {
        if let sportIndex = firstIndex(editedSportId: sport.id){
            sports[sportIndex].deleteSportStateFromScoreSequence(stateIndex: stateIndex)
        }
    }
    
    func findSportStateScoreSequence(editedSport: Sport) -> [SportState] {
        findFirstSport(sport: editedSport)!.scoreStateSequence
    }
    
    func updateSport(sport: Sport, landmarkType: LandmarkType) {
        if let sportIndex = firstIndex(editedSportId: sport.id) {
            sports[sportIndex].updateSport(landmarkType: landmarkType)
        }
    }
    
    func deleteSport(sport: Sport, landmarkType: LandmarkType) {
        if let sportIndex = firstIndex(editedSportId: sport.id) {
            sports[sportIndex].deleteSport(landmarkType: landmarkType)
        }
    }
    
    func updateSport(sport: Sport, objectId: String) {
        if let sportIndex = firstIndex(editedSportId: sport.id) {
            sports[sportIndex].updateSport(objectId: objectId)
        }
    }
    
    func deleteSport(sport: Sport, objectId: String) {
        if let sportIndex = firstIndex(editedSportId: sport.id) {
            sports[sportIndex].deleteSport(objectId: objectId)
        }
    }

    
    
    func findSelectedSegments() -> [LandmarkSegment] {
        findFirstSportState()!.landmarkSegments
    }
    
    func findSelectedObjects() -> [Observation] {
        findFirstSportState()!.objects

    }
    
    func findSelectedObjects(sport:Sport) -> [Observation]? {
        sport.states.first(where: { state in
            state.image != nil
        })?.objects
    }
    
    
    
    
    
    // MARK: state rule
    func setCurrentSportStateRule(editedSport: Sport, editedSportState: SportState, editedSportStateRules: ComplexRules, editedSportStateRule: ComplexRule?, ruleType: RuleType) {
        currentSportId = editedSport.id
        currentStateId = editedSportState.id
        currentSportStateRulesId  = editedSportStateRules.id
        currentSportStateRuleType = ruleType
        self.currentSportStateRuleId = editedSportStateRule?.id
        
        
        print(currentSportStateRuleType)
    }
    
    
    func setCurrentSportStateRule(landmarkSegmentType: LandmarkTypeSegment) {
        currentSportStateRuleId = landmarkSegmentType.id
        setSegmentToSelected()

    }
    
    
    private func addStateRule() {
        let rule = ComplexRule(ruleId: self.currentSportStateRuleId!)
        self.upsertCurrentRule(rule: rule)
    }
    
    func setStateRule() {
        if currentSportStateRuleId != nil {
            if let _ = self.findCurrentSportStateRule() {
                print("修改规则。。。。。。。。")
            }else{

                self.addStateRule()
                print("添加新规则。。。。。。。。")
            }
            print("setSegmentToSelected \(currentSportStateRuleId)")
        }
    }
    
    
    
    
    
    private func upsertCurrentRule(rule: ComplexRule) {
        if let sportIndex = firstIndex() {
            sports[sportIndex].updateSportStateRule(editedSportStateUUID: self.currentStateId!, editedSportStateRulesId: currentSportStateRulesId!, editedRule: rule, ruleType: currentSportStateRuleType!)
        }
    }
    
    private func findComplexRulesList(sportId: UUID, editedStateId: Int, ruleType: RuleType) -> [ComplexRules] {
        let sportState = findFirstSportState(editedSportId: sportId, sportStateUUID: editedStateId)!
        
        return sportState.findComplexRulesList(ruleType: ruleType)
        
    }
    
    func findComplexRulesList(sport: Sport, editedState: SportState, ruleType: RuleType) -> [ComplexRules] {
        findComplexRulesList(sportId: sport.id, editedStateId: editedState.id, ruleType: ruleType)
    }
    
    func findComplexRulex() -> ComplexRules? {
        let sportState = findFirstSportState()
        return sportState?.findComplexRules(ruleType: currentSportStateRuleType!, currentSportStateRulesId: currentSportStateRulesId!)
    }
    
    
    func findCurrentSportStateRule() -> ComplexRule? {
        
        // ComplexRulex
        let complexRulex = findComplexRulex()
        return complexRulex?.findFirstComplexRule(ruleId: currentSportStateRuleId)
        
    }
    
    func findCurrentSportStateRule(sport:Sport, state:SportState,rules:ComplexRules, rule: ComplexRule, ruleType: RuleType) -> ComplexRule? {
        if let state = findFirstSportState(editedSport: sport, sportStateUUID: state.id), let rules = state.firstComplexRulesById(editedRulesId: rules.id, ruleType: ruleType), let rule = rules.findFirstComplexRule(ruleId: rule.id) {
            return rule
        }
        return nil
    }
    
    
    
    func dropInvalidComplexRule() {
        if let sportIndex = firstIndex() {
            sports[sportIndex].dropInvalidComplexRule(editedSportStateUUID: self.currentStateId!, editedSportStateRulesId: currentSportStateRulesId!, ruleType: currentSportStateRuleType!)
        }
    }
    

    func setRuleLandmarkInArea(landmarkinArea: LandmarkInArea?) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.landmarkInArea = landmarkinArea
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func setRuleLandmarkInArea(landmarkType: LandmarkType, imageSize: Point2D, warning: String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.landmarkInArea = LandmarkInArea(landmarkType: landmarkType, imageSize: imageSize, warning: warning)
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func updateRuleLandmarkInArea(landmarkType: LandmarkType, warning: String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.landmarkInArea!.landmarkType = landmarkType
            newRule.landmarkInArea!.warning = warning

            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func updateRuleLandmarkInArea(area: [Point2D]) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.landmarkInArea!.area = area
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    
    
    func getRuleLandmarkInArea() -> LandmarkInArea? {
        let rule = findCurrentSportStateRule()
        return rule?.landmarkInArea
    }
    
    
    func updateRuleToStateLandmark(stateId: Int, fromAxis: CoordinateAxis, landmarkType: LandmarkType,  landmarkSegment: LandmarkSegment, toAxis: CoordinateAxis, warning: String) {
        if let  rule = findCurrentSportStateRule() {
            let fromStateLandmark = findFirstSportState()!
                .findLandmarkSegment(id: rule.id)
                .startAndEndSegment.first{ landmark in
                    landmark.landmarkType == landmarkType
                }!
            var newRule = rule

            newRule.lengthToState!.fromLandmarkToAxis.landmark = fromStateLandmark
            newRule.lengthToState!.fromLandmarkToAxis.axis = fromAxis
            let toStateLandmark =
            findFirstSportState(editedSportId: currentSportId!, sportStateUUID: stateId)!
                .findLandmarkSegment(id: rule.id)
                .startAndEndSegment.first{ landmark in
                    landmark.landmarkType == landmarkType
                }!
            newRule.lengthToState!.toLandmarkToAxis.landmark = toStateLandmark
            newRule.lengthToState!.toLandmarkToAxis.axis = fromAxis
            
            newRule.lengthToState!.toLandmarkSegmentToAxis.landmarkSegment = landmarkSegment
            newRule.lengthToState!.toLandmarkSegmentToAxis.axis = toAxis
            newRule.lengthToState!.toStateId = stateId
            
            newRule.lengthToState!.warning = warning
            
            
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    
    
    
    func updateRuleObjectToLandmark(
        fromAxis: CoordinateAxis,
        landmarkType: LandmarkType,
        objectId: String,
        objectPosition: ObjectPosition,
        landmarkSegment: LandmarkSegment,
        toAxis: CoordinateAxis,
        warning: String
    ) {
        if let rule = findCurrentSportStateRule() {
            
            let state = findFirstSportState()!
            
            let landmark = state
                .findLandmarkSegment(id: rule.id)
                .startAndEndSegment.first{ landmark in
                    landmark.landmarkType == landmarkType
                }!
            
            let selectedObject = state.objects.first{ object in
                object.label == objectId
            }!
            
            var newRule = rule
            newRule.objectPositionToLandmark!.fromAxis = fromAxis
            newRule.objectPositionToLandmark!.toLandmark = landmark
            newRule.objectPositionToLandmark!.fromPosition.id = objectId
            newRule.objectPositionToLandmark!.fromPosition.position = objectPosition
            newRule.objectPositionToLandmark!.fromPosition.point =  selectedObject.rect.pointOf(
                position: objectPosition).point2d
            newRule.objectPositionToLandmark!.toLandmarkSegmentToAxis.axis = toAxis
            newRule.objectPositionToLandmark!.toLandmarkSegmentToAxis.landmarkSegment = landmarkSegment
            newRule.objectPositionToLandmark!.warning = warning
            
            self.upsertCurrentRule(rule: newRule)
            
        }
        
    }
    
    func setRuleObjectToLandmark(
        fromAxis: CoordinateAxis,
        landmarkType: LandmarkType,
        objectId: String,
        objectPosition: ObjectPosition,
        landmarkSegment: LandmarkSegment,
        toAxis: CoordinateAxis,
        warning: String
    ) {
        if let rule = findCurrentSportStateRule() {
            
            let state = findFirstSportState()!
            
            let landmark = state
                .findLandmarkSegment(id: rule.id)
                .startAndEndSegment.first{ landmark in
                    landmark.landmarkType == landmarkType
                }!
            
            let selectedObject = state.objects.first{ object in
                object.label == objectId
            }!
            
            var newRule = rule
            newRule.objectPositionToLandmark = ObjectToLandmark(fromAxis: fromAxis,
                                                                fromPosition: ObjectPositionPoint(
                                                                    id: objectId,
                                                                    position: objectPosition, point: selectedObject.rect.pointOf(
                                                                        position: objectPosition).point2d), toLandmark: landmark, toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: landmarkSegment, axis: toAxis), warning: warning)
            self.upsertCurrentRule(rule: newRule)
            
        }
        
    }
    
    
    func setRuleWarning(warning: String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.warning = warning
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    
    func getRuleLandmarkSegmentLength() -> RelativeLandmarkSegmentsToAxis? {
        let rule = findCurrentSportStateRule()!

        return rule.length
    }
    
    func getRuleToStateLandmark() -> LandmarkToAxisAndState? {
        let rule = findCurrentSportStateRule()!
        return rule.lengthToState
    }
    
    
    func getRuleObjectToLandmark() -> ObjectToLandmark? {
        let rule = findCurrentSportStateRule()!
        return rule.objectPositionToLandmark
    }
    
    func getRuleObjectToObject() -> ObjectToObject? {
        let rule = findCurrentSportStateRule()!
        return rule.objectPositionToObjectPosition
    }
    
    func updateRuleLandmarkSegmentLength(lowerBound: Double, upperBound: Double) {
        if let rule = self.findCurrentSportStateRule() {
            var newRule = rule
            newRule.length!.lowerBound = lowerBound
            newRule.length!.upperBound = upperBound
            self.upsertCurrentRule(rule: newRule)
        }
        
    }
    
    func updateRuleObjectToLandmark(lowerBound: Double, upperBound: Double) {
        if let rule = self.findCurrentSportStateRule() {
            var newRule = rule
            newRule.objectPositionToLandmark!.lowerBound = lowerBound
            newRule.objectPositionToLandmark!.upperBound = upperBound
            self.upsertCurrentRule(rule: newRule)
        }
        
    }
    
    func updateRuleToStateLandmark(lowerBound: Double, upperBound: Double) {
        if let rule = self.findCurrentSportStateRule() {
            var newRule = rule
                newRule.lengthToState!.lowerBound = lowerBound
                newRule.lengthToState!.upperBound = upperBound
            self.upsertCurrentRule(rule: newRule)
        }
        
    }
    

    
    func setRuleToStateLandmark(toStateId: Int, fromAxis: CoordinateAxis, relativeSegment: LandmarkSegment, toAxis: CoordinateAxis, warning: String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            let length = LandmarkToAxisAndState(
                toStateId: toStateId,
                fromLandmarkToAxis:
                    LandmarkToAxis(
                        landmark: self.findSelectedSegment()!.startLandmark,
                        axis: fromAxis),
                
                toLandmarkToAxis: LandmarkToAxis(
                    landmark: self.findSelectedSegment()!.startLandmark,
                    axis: fromAxis),
                toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: relativeSegment, axis: toAxis),
                warning: warning)

            newRule.lengthToState = length
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
 

    

    func updateRuleObjectToObject(lowerBound: Double, upperBound: Double) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.objectPositionToObjectPosition!.lowerBound = lowerBound
            newRule.objectPositionToObjectPosition!.upperBound = upperBound
            self.upsertCurrentRule(rule: newRule)
        }
    }
    func updateRuleObjectToObject(
                                                
        fromAxis: CoordinateAxis, fromObjectId: String, fromObjectPosition: ObjectPosition, toObjectId: String, toObjectPosition: ObjectPosition, relativeSegment: LandmarkSegment, toAxis: CoordinateAxis, warning: String){
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            
            let fromObject = findFirstSportState()!.objects.first{ _object in
                _object.label == fromObjectId
            }!
            
            let toObject = findFirstSportState()!.objects.first{ _object in
                _object.label == toObjectId
            }!
            
            newRule.objectPositionToObjectPosition!.fromPosition = ObjectPositionPoint(
                id: fromObjectId,
                position: fromObjectPosition,
                point: fromObject.rect.pointOf(position: fromObjectPosition).point2d)
            newRule.objectPositionToObjectPosition!.toPosition = ObjectPositionPoint(
                id: toObjectId,
                position: toObjectPosition,
                point: toObject.rect.pointOf(position: toObjectPosition).point2d)
            newRule.objectPositionToObjectPosition!.fromAxis = fromAxis
            newRule.objectPositionToObjectPosition!.toLandmarkSegmentToAxis = LandmarkSegmentToAxis(landmarkSegment: relativeSegment, axis: toAxis)
            newRule.objectPositionToObjectPosition!.warning = warning
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func setRuleObjectToObject(
                                                
        fromAxis: CoordinateAxis, fromObjectId: String, fromObjectPosition: ObjectPosition, toObjectId: String, toObjectPosition: ObjectPosition, relativeSegment: LandmarkSegment, toAxis: CoordinateAxis, warning: String){
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            
            let fromObject = findFirstSportState()!.objects.first{ _object in
                _object.label == fromObjectId
            }!
            
            let toObject = findFirstSportState()!.objects.first{ _object in
                _object.label == toObjectId
            }!
            
            newRule.objectPositionToObjectPosition = ObjectToObject(
                fromPosition:  ObjectPositionPoint(
                id: fromObjectId,
                position: fromObjectPosition,
                point: fromObject.rect.pointOf(position: fromObjectPosition).point2d), toPosition: ObjectPositionPoint(
                    id: toObjectId,
                    position: toObjectPosition,
                    point: toObject.rect.pointOf(position: toObjectPosition).point2d),
                fromAxis: fromAxis, toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: relativeSegment, axis: toAxis), warning: warning)
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func setRuleObjectToObject(objectToObject: ObjectToObject?){
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.objectPositionToObjectPosition = objectToObject
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func setRuleLandmarkSegmentLength(fromAxis: CoordinateAxis, relativeSegment: LandmarkSegment, toAxis: CoordinateAxis, warning: String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            let length = RelativeLandmarkSegmentsToAxis(
                from: LandmarkSegmentToAxis(landmarkSegment: self.findSelectedSegment()!, axis: fromAxis),
                to: LandmarkSegmentToAxis(landmarkSegment: relativeSegment, axis: toAxis),
                warning: warning
            )
                newRule.length = length

            self.upsertCurrentRule(rule: newRule)
        }
        
        
    }
    
    func updateRuleLandmarkSegmentLength(fromAxis: CoordinateAxis, relativeSegment: LandmarkSegment, toAxis: CoordinateAxis, warning: String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            
            newRule.length!.from = LandmarkSegmentToAxis(landmarkSegment: self.findSelectedSegment()!, axis: fromAxis)
            newRule.length!.to = LandmarkSegmentToAxis(landmarkSegment: relativeSegment, axis: toAxis)
            newRule.length!.warning = warning

            self.upsertCurrentRule(rule: newRule)
        }
        
        
    }
    
    func setRuleLandmarkSegmentLength(length: RelativeLandmarkSegmentsToAxis?) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.length = length
            self.upsertCurrentRule(rule: newRule)
        }
        
    }
    
    func setRuleToStateLandmark(toStateLandmark: LandmarkToAxisAndState?) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule

                newRule.lengthToState = toStateLandmark
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    
    func setRuleObjectToLandmark(objectToLandmark: ObjectToLandmark?) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
                newRule.objectPositionToLandmark = objectToLandmark
            self.upsertCurrentRule(rule: newRule)
        }
        
    }
    
    func setRuleLandmarkToSelf(landmarkToSelf: LandmarkToSelf?) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
                newRule.landmarkToSelf = landmarkToSelf
            self.upsertCurrentRule(rule: newRule)
        }
        
    }
    
    
    func getRuleObjectToSelf() -> ObjectToSelf? {
        let rule = findCurrentSportStateRule()
        return rule?.objectToSelf
    }
    
    func getRuleLandmarkToSelf() -> LandmarkToSelf? {
        let rule = findCurrentSportStateRule()
        return rule?.landmarkToSelf
    }
    
    func setRuleObjectToSelf(objectToSelf: ObjectToSelf?) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule

            newRule.objectToSelf = objectToSelf
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func setRuleObjectToSelf(objectId:String, direction: Direction, xLowerBound: Double, yLowerBound: Double, warning:String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule

            newRule.objectToSelf = ObjectToSelf(objectId: objectId, toDirection: direction, xLowerBound: xLowerBound, yLowerBound: yLowerBound, warning: warning)
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func setRuleLandmarkToSelf(landmarkType:LandmarkType, direction: Direction, toLandmarkSegment: LandmarkSegment, toAxis: CoordinateAxis, xLowerBound: Double, yLowerBound: Double, warning:String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule

            newRule.landmarkToSelf = LandmarkToSelf(
                landmarkType: landmarkType,
                toDirection: direction,
                toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: toLandmarkSegment, axis: toAxis),
                xLowerBound: xLowerBound,
                yLowerBound: yLowerBound,
                warning: warning)
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func updateRuleObjectToSelf(objectId:String, direction: Direction, xLowerBound: Double, yLowerBound: Double, warning:String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule

            newRule.objectToSelf!.objectId = objectId
            newRule.objectToSelf!.toDirection = direction
            newRule.objectToSelf!.xLowerBound = xLowerBound
            newRule.objectToSelf!.yLowerBound = yLowerBound

            newRule.objectToSelf!.warning = warning
            
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    
    func updateRuleLandmarkToSelf(landmarkType:LandmarkType, direction: Direction, toLandmarkSegment: LandmarkSegment, toAxis: CoordinateAxis, xLowerBound: Double, yLowerBound: Double, warning:String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule

            newRule.landmarkToSelf!.landmarkType = landmarkType
            newRule.landmarkToSelf!.toDirection = direction
            
            newRule.landmarkToSelf!.toLandmarkSegmentToAxis = LandmarkSegmentToAxis(landmarkSegment: toLandmarkSegment, axis: toAxis)
            
            newRule.landmarkToSelf!.xLowerBound = xLowerBound
            newRule.landmarkToSelf!.yLowerBound = yLowerBound

            newRule.landmarkToSelf!.warning = warning
            
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func updateRuleObjectToSelf(xLowerBound: Double, yLowerBound: Double) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.objectToSelf!.xLowerBound = xLowerBound
            newRule.objectToSelf!.yLowerBound = yLowerBound
            
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func updateRuleLandmarkToSelf(xLowerBound: Double, yLowerBound: Double) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.landmarkToSelf!.xLowerBound = xLowerBound
            newRule.landmarkToSelf!.yLowerBound = yLowerBound
            
            self.upsertCurrentRule(rule: newRule)
        }
    }
    

    
    
    func upsertRule(
        sportId: UUID,
        stateId:Int,
        ruleType: RuleType,
        rulesIndex:Int,
        rule: ComplexRule
    ) {
        if let sportIndex = firstIndex(editedSportId: sportId) {
            sports[sportIndex].updateSportStateRule(editedSportStateUUID: stateId, ruleType: ruleType, editedRulesIndex: rulesIndex, editedRule: rule)
        }
    }
    
    
    
    func setRuleLandmarkSegmentAngle(landmarkSegment: LandmarkSegment, warning:String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.angle  = AngleRange(landmarkSegment: landmarkSegment, warning: warning)
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func setRuleLandmarkSegmentAngle(angle: AngleRange?) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.angle  = nil
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func updateRuleLandmarkSegmentAngle(landmarkSegment: LandmarkSegment, warning:String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.angle!.landmarkSegment  = landmarkSegment
            newRule.angle!.warning = warning
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func updateRuleLandmarkSegmentAngle(lowerBound: Double, upperBound: Double, warning: String) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            newRule.angle!.lowerBound = lowerBound
            newRule.angle!.upperBound = upperBound
            newRule.angle!.warning = warning
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func getRuleLandmarkSegmentAngle() -> AngleRange? {
        if let rule = findCurrentSportStateRule() {
            return rule.angle
        }
        return nil
    }
    
    func addNewRules(editedSport: Sport, editedSportState: SportState, ruleType: RuleType) {
        self.currentSportId = editedSport.id
        self.currentStateId = editedSportState.id
        self.currentSportStateRuleType = ruleType
        
        if let sportIndex = firstIndex(editedSportId: editedSport.id) {
            sports[sportIndex].addNewSportStateRules(editedSportState: editedSportState, ruleType: ruleType)
        }
        
    }
    
    func deleteRules(editedSport: Sport, editedSportState: SportState, editedRules: ComplexRules, ruleType: RuleType) {
        if let sportIndex = firstIndex(editedSportId: editedSport.id) {
            sports[sportIndex].deleteSportStateRules(editedSportState: editedSportState, editedRulesId: editedRules.id, ruleType: ruleType)
        }
    }
    
    func deleteRule(editedSport: Sport, editedSportState: SportState, editedRules: ComplexRules, ruleType: RuleType, ruleId: String) {
        if let sportIndex = firstIndex(editedSportId: editedSport.id) {
            sports[sportIndex].deleteSportStateRule(editedSportState: editedSportState, editedRulesId: editedRules.id, ruleType: ruleType, ruleId: ruleId)
        }
    }
    
    
    func setSegmentToSelected() {
        if let sportIndex = firstIndex() {
            sports[sportIndex].setSegmentToSelected(editedSportStateUUID: currentStateId!, editedSportStateRuleId: currentSportStateRuleId)
        }
    }
    
    func findSelectedSegment() -> LandmarkSegment? {
        findFirstSportState()?.findselectedSegment(editedSportStateRuleId: currentSportStateRuleId)
    }
    
    func segmentSelected(segment: LandmarkSegment) -> Bool? {
        findFirstSportState()?.segmentSelected(segment: segment)
    }
    
    func findLandmarkSegment(landmarkTypeSegment: LandmarkTypeSegment) -> LandmarkSegment {
        findSelectedSegments().first{ segment in
            segment.id == landmarkTypeSegment.id
        }!
    }
    
    
}
