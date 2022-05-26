
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
    
    
    func findSelectedSegments() -> [LandmarkSegment] {
        findFirstSportState()!.landmarkSegments
    }
    
    func findSelectedObjects() -> [Observation] {
        findFirstSportState()!.objects
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
    
    
    func setCurrentSportStateRule(landmarkSegment: LandmarkSegment) {
        currentSportStateRuleId = landmarkSegment.id
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
    
    
    func findCurrentSportStateRuleMutiFrameLength(fromAxis: CoordinateAxis) -> LandmarkToAxisAndState? {
        let rule = findComplexRulex()?.findFirstComplexRule(ruleId: currentSportStateRuleId)
//        switch fromAxis {
//        case .X:
//            return rule?.lengthXToState
//
//        case .Y:
//            return rule?.lengthYToState
//        case .XY:
//            return rule?.lengthXYToState
//        }
        return rule?.lengthToState
        
    }
    
    func findCurrentSportStateRuleObjectToLandmark(fromAxis: CoordinateAxis) -> ObjectToLandmark? {
        let rule = findComplexRulex()?.findFirstComplexRule(ruleId: currentSportStateRuleId)
//        switch fromAxis {
//
//        case .X:
//            return rule?.objectPositionXToLandmark
//
//        case .Y:
//            return rule?.objectPositionYToLandmark
//        case .XY:
//            return rule?.objectPositionXYToLandmark
//        }
        return rule?.objectPositionToLandmark
        
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
    
//    func updateSportStateRule(firstPoint: Point2D, secondPoint: Point2D, thirdPoint:Point2D, fourthPoint: Point2D) {
//
//        if let  rule = findCurrentSportStateRule() {
//            var newRule = rule
//            newRule.landmarkInArea!.area =
//            [firstPoint, secondPoint, thirdPoint, fourthPoint]
//            self.upsertCurrentRule(rule: newRule)
//        }
//
//    }
    
//    func updateSportStateRule(landmarkType: LandmarkType, landmarkInAreaWarning: String) {
//        if let rule = findCurrentSportStateRule() {
//            var newRule = rule
//            newRule.landmarkInArea!.landmarkType = landmarkType
//            newRule.landmarkInArea!.warning = landmarkInAreaWarning
//            self.upsertCurrentRule(rule: newRule)
//        }
//    }
    
    
    func updateSportStateRuleMutiFrame(fromAxis: CoordinateAxis, landmarkType: LandmarkType, stateId: Int, landmarkSegment: LandmarkSegment, toAxis: CoordinateAxis, warning: String) {
        if let  rule = findCurrentSportStateRule() {
            let fromStateLandmark = findFirstSportState()!
                .findLandmarkSegment(id: rule.id)
                .startAndEndSegment.first{ landmark in
                    landmark.landmarkType == landmarkType
                }!
            var newRule = rule
//            switch fromAxis {
//            case .X:
//                newRule.lengthXToState!.fromLandmarkToAxis.landmark = fromStateLandmark
//
//                let toStateLandmark =
//                findFirstSportState(editedSportId: currentSportId!, sportStateUUID: stateId)!
//                    .findLandmarkSegment(id: rule.id)
//                    .startAndEndSegment.first{ landmark in
//                        landmark.landmarkType == landmarkType
//                    }!
//                newRule.lengthXToState!.toLandmarkToAxis.landmark = toStateLandmark
//
//                newRule.lengthXToState!.toLandmarkSegmentToAxis.landmarkSegment = landmarkSegment
//                newRule.lengthXToState!.toLandmarkSegmentToAxis.axis = toAxis
//                newRule.lengthXToState!.toStateId = stateId
//
//                newRule.lengthXToState!.warning = warning
//
//
//            case .Y:
//                newRule.lengthYToState!.fromLandmarkToAxis.landmark = fromStateLandmark
//
//                let toStateId = newRule.lengthYToState!.toStateId
//                let toStateLandmark =
//                findFirstSportState(editedSportId: currentSportId!, sportStateUUID: toStateId)!
//                    .findLandmarkSegment(id: rule.id)
//                    .startAndEndSegment.first{ landmark in
//                        landmark.landmarkType == landmarkType
//                    }!
//                newRule.lengthYToState!.toLandmarkToAxis.landmark = toStateLandmark
//
//                newRule.lengthYToState!.toLandmarkSegmentToAxis.landmarkSegment = landmarkSegment
//                newRule.lengthYToState!.toLandmarkSegmentToAxis.axis = toAxis
//                newRule.lengthYToState!.toStateId = stateId
//                newRule.lengthYToState!.warning = warning
//
//
//
//            case .XY:
//                newRule.lengthXYToState!.fromLandmarkToAxis.landmark = fromStateLandmark
//
//                let toStateId = newRule.lengthXYToState!.toStateId
//                let toStateLandmark =
//                findFirstSportState(editedSportId: currentSportId!, sportStateUUID: toStateId)!
//                    .findLandmarkSegment(id: rule.id)
//                    .startAndEndSegment.first{ landmark in
//                        landmark.landmarkType == landmarkType
//                    }!
//                newRule.lengthXYToState!.toLandmarkToAxis.landmark = toStateLandmark
//
//                newRule.lengthXYToState!.toLandmarkSegmentToAxis.landmarkSegment = landmarkSegment
//                newRule.lengthXYToState!.toLandmarkSegmentToAxis.axis = toAxis
//                newRule.lengthXYToState!.toStateId = stateId
//                newRule.lengthXYToState!.warning = warning
//
//            }
            newRule.lengthToState!.fromLandmarkToAxis.landmark = fromStateLandmark
            
            let toStateLandmark =
            findFirstSportState(editedSportId: currentSportId!, sportStateUUID: stateId)!
                .findLandmarkSegment(id: rule.id)
                .startAndEndSegment.first{ landmark in
                    landmark.landmarkType == landmarkType
                }!
            newRule.lengthToState!.toLandmarkToAxis.landmark = toStateLandmark
            
            newRule.lengthToState!.toLandmarkSegmentToAxis.landmarkSegment = landmarkSegment
            newRule.lengthToState!.toLandmarkSegmentToAxis.axis = toAxis
            newRule.lengthToState!.toStateId = stateId
            
            newRule.lengthToState!.warning = warning
            
            
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    
    
    func updateCurrentSportStateRule(axis: CoordinateAxis, objectToLandmark: ObjectToLandmark?) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
//            switch axis {
//            case .X:
//                newRule.objectPositionXToLandmark = objectToLandmark
//            case .Y:
//                newRule.objectPositionYToLandmark = objectToLandmark
//
//            case .XY:
//                newRule.objectPositionXYToLandmark = objectToLandmark
//            }
            newRule.objectPositionToLandmark = objectToLandmark

            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func updateSportStateRule(
        fromAxis: CoordinateAxis,
        landmarkType: LandmarkType,
        objectId: String,
        objectPosition: ObjectPosition,
        landmarkSegment: LandmarkSegment,
        toAxis: CoordinateAxis,
        warning: String
    ) {
        if let rule = findCurrentSportStateRule() {
            
            let landmark = findFirstSportState()!
                .findLandmarkSegment(id: rule.id)
                .startAndEndSegment.first{ landmark in
                    landmark.landmarkType == landmarkType
                }!
            
            let selectedObject = findFirstSportState()!.objects.first{ object in
                object.id == objectId
            }!
            
            var newRule = rule
//            switch fromAxis {
//            case .X:
//                newRule.objectPositionXToLandmark?.fromAxis = fromAxis
//                newRule.objectPositionXToLandmark?.toLandmark = landmark
//                newRule.objectPositionXToLandmark?.fromPosition.id = objectId
//                newRule.objectPositionXToLandmark?.fromPosition.position = objectPosition
//                newRule.objectPositionXToLandmark?.fromPosition.point =  selectedObject.rect.pointOf(
//                    position: objectPosition).point2d
//                newRule.objectPositionXToLandmark?.toLandmarkSegmentToAxis.axis = toAxis
//                newRule.objectPositionXToLandmark?.toLandmarkSegmentToAxis.landmarkSegment = landmarkSegment
//                newRule.objectPositionXToLandmark?.warning = warning
//
//
//            case .Y:
//                newRule.objectPositionYToLandmark?.fromAxis = fromAxis
//                newRule.objectPositionYToLandmark?.toLandmark = landmark
//
//                newRule.objectPositionYToLandmark?.fromPosition.id = objectId
//
//                newRule.objectPositionYToLandmark?.fromPosition.position = objectPosition
//                newRule.objectPositionYToLandmark?.fromPosition.point =  selectedObject.rect.pointOf(
//                    position: objectPosition).point2d
//                newRule.objectPositionYToLandmark?.toLandmarkSegmentToAxis.axis = toAxis
//                newRule.objectPositionYToLandmark?.toLandmarkSegmentToAxis.landmarkSegment = landmarkSegment
//
//                newRule.objectPositionYToLandmark?.warning = warning
//
//
//            case .XY:
//                newRule.objectPositionXYToLandmark?.fromAxis = fromAxis
//                newRule.objectPositionXYToLandmark?.toLandmark = landmark
//
//                newRule.objectPositionXYToLandmark?.fromPosition.id = objectId
//
//                newRule.objectPositionXYToLandmark?.fromPosition.position = objectPosition
//                newRule.objectPositionXYToLandmark?.fromPosition.point =  selectedObject.rect.pointOf(
//                    position: objectPosition).point2d
//                newRule.objectPositionXYToLandmark?.toLandmarkSegmentToAxis.axis = toAxis
//                newRule.objectPositionXYToLandmark?.toLandmarkSegmentToAxis.landmarkSegment = landmarkSegment
//
//                newRule.objectPositionXYToLandmark?.warning = warning
//
//
//            }
//
            newRule.objectPositionToLandmark?.fromAxis = fromAxis
            newRule.objectPositionToLandmark?.toLandmark = landmark
            newRule.objectPositionToLandmark?.fromPosition.id = objectId
            newRule.objectPositionToLandmark?.fromPosition.position = objectPosition
            newRule.objectPositionToLandmark?.fromPosition.point =  selectedObject.rect.pointOf(
                position: objectPosition).point2d
            newRule.objectPositionToLandmark?.toLandmarkSegmentToAxis.axis = toAxis
            newRule.objectPositionToLandmark?.toLandmarkSegmentToAxis.landmarkSegment = landmarkSegment
            newRule.objectPositionToLandmark?.warning = warning
            
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
    
    
    func getCurrentSportStateRuleLength(fromAxis: CoordinateAxis) -> RelativeLandmarkSegmentsToAxis? {
        let rule = findCurrentSportStateRule()!
//        switch fromAxis {
//        case .X:
//            return rule.lengthX
//        case .Y:
//            return rule.lengthY
//        case .XY:
//            return rule.lengthXY
//        }
        return rule.length
    }
    
    func getCurrentSportStateRuleMultiFrameLength(fromAxis: CoordinateAxis) -> LandmarkToAxisAndState? {
        let rule = findCurrentSportStateRule()!
//        switch fromAxis {
//        case .X:
//            return rule.lengthXToState
//        case .Y:
//            return rule.lengthYToState
//        case .XY:
//            return rule.lengthXYToState
//        }
        return rule.lengthToState
    }
    
    func getCurrentSportStateRuleObjectTolandmark(fromAxis: CoordinateAxis) -> ObjectToLandmark? {
        let rule = findCurrentSportStateRule()!
//        switch fromAxis {
//        case .X:
//            return rule.objectPositionXToLandmark!
//        case .Y:
//            return rule.objectPositionYToLandmark!
//        case .XY:
//            return rule.objectPositionXYToLandmark!
//        }
        return rule.objectPositionToLandmark
    }
    
    func updateSportStateRule(axis: CoordinateAxis, lowerBound: Double, upperBound: Double) {
        if let rule = self.findCurrentSportStateRule() {
            var newRule = rule
//            switch axis {
//            case .X:
//                newRule.lengthX!.lowerBound = lowerBound
//                newRule.lengthX!.upperBound = upperBound
//            case .Y:
//                newRule.lengthY!.lowerBound = lowerBound
//                newRule.lengthY!.upperBound = upperBound
//            case .XY:
//                newRule.lengthXY!.lowerBound = lowerBound
//                newRule.lengthXY!.upperBound = upperBound
//            }
            newRule.length!.lowerBound = lowerBound
            newRule.length!.upperBound = upperBound
            self.upsertCurrentRule(rule: newRule)
        }
        
    }
    
    func updateCurrentRuleObjectTolandmark(axis: CoordinateAxis, lowerBound: String, upperBound: String) {
        if let rule = self.findCurrentSportStateRule() {
            var newRule = rule
            if let lowerBound = Double(lowerBound), let upperBound =  Double(upperBound){
//                switch axis {
//                case .X:
//                    newRule.objectPositionXToLandmark!.lowerBound = lowerBound
//                    newRule.objectPositionXToLandmark!.upperBound = upperBound
//                case .Y:
//                    newRule.objectPositionYToLandmark!.lowerBound = lowerBound
//                    newRule.objectPositionYToLandmark!.upperBound = upperBound
//                case .XY:
//                    newRule.objectPositionXYToLandmark!.lowerBound = lowerBound
//                    newRule.objectPositionXYToLandmark!.upperBound = upperBound
//                }
                newRule.objectPositionToLandmark!.lowerBound = lowerBound
                newRule.objectPositionToLandmark!.upperBound = upperBound
            }
            self.upsertCurrentRule(rule: newRule)
        }
        
    }
    
    
    func updateCurrentRuleMultiFrame(axis: CoordinateAxis, lowerBound: Double, upperBound: Double) {
        if let rule = self.findCurrentSportStateRule() {
            var newRule = rule
//            switch axis {
//            case .X:
//                newRule.lengthXToState!.lowerBound = lowerBound
//                newRule.lengthXToState!.upperBound = upperBound
//
//            case .Y:
//                newRule.lengthYToState!.lowerBound = lowerBound
//                newRule.lengthYToState!.upperBound = upperBound
//
//            case .XY:
//                newRule.lengthXYToState!.lowerBound = lowerBound
//                newRule.lengthXYToState!.upperBound = upperBound
//
//            }
                newRule.lengthToState!.lowerBound = lowerBound
                newRule.lengthToState!.upperBound = upperBound
            self.upsertCurrentRule(rule: newRule)
        }
        
    }
    
    
    
    func setSportStateRuleMultiFrameLength(fromAxis: CoordinateAxis, relativeSegment: LandmarkSegment, toAxis: CoordinateAxis, toStateId: Int) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            let length = LandmarkToAxisAndState(
                fromLandmarkToAxis:
                    LandmarkToAxis(
                        landmark: self.findselectedSegment()!.startLandmark,
                        axis: fromAxis),
                toStateId: toStateId,
                toLandmarkToAxis: LandmarkToAxis(
                    landmark: self.findselectedSegment()!.startLandmark,
                    axis: fromAxis),
                toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: relativeSegment, axis: toAxis))
//            switch fromAxis {
//            case .X:
//                newRule.lengthXToState = length
//
//            case .Y:
//                newRule.lengthYToState = length
//
//            case .XY:
//                newRule.lengthXYToState = length
//
//            }
            newRule.lengthToState = length
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func setSportStateRuleObjectToLandmark(fromAxis: CoordinateAxis, fromObjectPosition: ObjectPosition, relativeSegment: LandmarkSegment, toAxis: CoordinateAxis) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            
            var object = findFirstSportState()!.objects.first!
            
            let objectToLandmark = ObjectToLandmark(
                fromAxis: fromAxis,
                fromPosition: ObjectPositionPoint(
                    id: object.id,
                    position: fromObjectPosition,
                    point: object.rect.pointOf(position: fromObjectPosition).point2d),
                toLandmark: self.findselectedSegment()!.startLandmark,
                toLandmarkSegmentToAxis: LandmarkSegmentToAxis(landmarkSegment: relativeSegment, axis: toAxis))
            
//            switch fromAxis {
//            case .X:
//                newRule.objectPositionXToLandmark = objectToLandmark
//
//            case .Y:
//                newRule.objectPositionYToLandmark = objectToLandmark
//
//            case .XY:
//                newRule.objectPositionXYToLandmark = objectToLandmark
//
//            }
            newRule.objectPositionToLandmark = objectToLandmark
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func setSportStateRuleLength(fromAxis: CoordinateAxis, relativeSegment: LandmarkSegment, toAxis: CoordinateAxis) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
            let length = RelativeLandmarkSegmentsToAxis(
                from: LandmarkSegmentToAxis(landmarkSegment: self.findselectedSegment()!, axis: fromAxis),
                to: LandmarkSegmentToAxis(landmarkSegment: relativeSegment, axis: toAxis)
            )
//            switch fromAxis {
//            case .X:
//                newRule.lengthX = length
//
//            case .Y:
//                newRule.lengthY = length
//            case .XY:
//                newRule.lengthXY = length
//            }
                newRule.length = length

            self.upsertCurrentRule(rule: newRule)
        }
        
        
    }
    
    func removeSportStateRuleLength(fromAxis: CoordinateAxis) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
//            switch fromAxis {
//            case .X:
//                newRule.lengthX = nil
//            case .Y:
//                newRule.lengthY = nil
//            case .XY:
//                newRule.lengthXY = nil
//            }
            newRule.length = nil
            self.upsertCurrentRule(rule: newRule)
        }
        
        
    }
    
    func removeSportStateRuleLengthMutiFrame(fromAxis: CoordinateAxis) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
//            switch fromAxis {
//            case .X:
//                newRule.lengthXToState = nil
//            case .Y:
//                newRule.lengthYToState = nil
//            case .XY:
//                newRule.lengthXYToState = nil
//            }
                newRule.lengthToState = nil
            self.upsertCurrentRule(rule: newRule)
        }
        
        
    }
    func removeSportStateRuleObjectToLandmark(fromAxis: CoordinateAxis) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
//            switch fromAxis {
//            case .X:
//                newRule.lengthXToState = nil
//            case .Y:
//                newRule.lengthYToState = nil
//            case .XY:
//                newRule.lengthXYToState = nil
//            }
                newRule.objectPositionToLandmark = nil
            self.upsertCurrentRule(rule: newRule)
        }
        
        
    }
    
    func updateCurrentSportStateRuleLengthMutiFrame(axis: CoordinateAxis, length: LandmarkToAxisAndState?) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
//            switch axis {
//            case .X:
//                newRule.lengthXToState = length
//            case .Y:
//                newRule.lengthYToState = length
//            case .XY:
//                newRule.lengthXYToState = length
//            }
            newRule.lengthToState = length
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    func updateCurrentSportStateRuleLength(axis: CoordinateAxis, length: RelativeLandmarkSegmentsToAxis?) {
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
//            switch axis {
//            case .X:
//                newRule.lengthX = length
//            case .Y:
//                newRule.lengthY = length
//            case .XY:
//                newRule.lengthXY = length
//            }
            newRule.length = length
            self.upsertCurrentRule(rule: newRule)
        }
    }
    
    
    func updateSportStateRule(
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
    
    
    func updateCurrentSportStateRule(
        fromAxis: CoordinateAxis,
        toAxis: CoordinateAxis,
        relativeSegment: LandmarkSegment,
        warning: String
    ) {
        
        if let rule = findCurrentSportStateRule() {
            var newRule = rule
//            switch fromAxis {
//            case .X:
//                newRule.lengthX!.to.landmarkSegment = relativeSegment
//                newRule.lengthX!.to.axis = toAxis
//                newRule.lengthX!.warning = warning
//            case .Y:
//                newRule.lengthY!.to.landmarkSegment = relativeSegment
//                newRule.lengthY!.to.axis = toAxis
//                newRule.lengthY!.warning = warning
//
//            case .XY:
//                newRule.lengthXY!.to.landmarkSegment = relativeSegment
//                newRule.lengthXY!.to.axis = toAxis
//                newRule.lengthXY!.warning = warning
//
//            }
            newRule.length!.to.landmarkSegment = relativeSegment
            newRule.length!.to.axis = toAxis
            newRule.length!.warning = warning
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
    
    func getCurrentSportStateRuleAngle() -> AngleRange? {
        if let rule = findCurrentSportStateRule() {
            return rule.angle
        }
        return nil
    }
    
    
    func addNewSportStateRules(editedSport: Sport, editedSportState: SportState, ruleType: RuleType) {
        self.currentSportId = editedSport.id
        self.currentStateId = editedSportState.id
        self.currentSportStateRuleType = ruleType
        
        if let sportIndex = firstIndex(editedSportId: editedSport.id) {
            sports[sportIndex].addNewSportStateRules(editedSportState: editedSportState, ruleType: ruleType)
        }
        
    }
    
    func deleteSportStateRules(editedSport: Sport, editedSportState: SportState, editedRules: ComplexRules, ruleType: RuleType) {
        if let sportIndex = firstIndex(editedSportId: editedSport.id) {
            sports[sportIndex].deleteSportStateRules(editedSportState: editedSportState, editedRulesId: editedRules.id, ruleType: ruleType)
        }
    }
    
    func deleteSportStateRule(editedSport: Sport, editedSportState: SportState, editedRules: ComplexRules, ruleType: RuleType, ruleId: String) {
        if let sportIndex = firstIndex(editedSportId: editedSport.id) {
            sports[sportIndex].deleteSportStateRule(editedSportState: editedSportState, editedRulesId: editedRules.id, ruleType: ruleType, ruleId: ruleId)
        }
    }
    
    
    func setSegmentToSelected() {
        if let sportIndex = firstIndex() {
            sports[sportIndex].setSegmentToSelected(editedSportStateUUID: currentStateId!, editedSportStateRuleId: currentSportStateRuleId)
        }
    }
    
    func findselectedSegment() -> LandmarkSegment? {
        findFirstSportState()?.findselectedSegment(editedSportStateRuleId: currentSportStateRuleId)
    }
    
    func segmentSelected(segment: LandmarkSegment) -> Bool? {
        findFirstSportState()?.segmentSelected(segment: segment)
    }
    
    func findlandmarkSegment(landmarkTypeSegment: LandmarkTypeSegment) -> LandmarkSegment {
        findSelectedSegments().first{ segment in
            segment.id == landmarkTypeSegment.id
        }!
    }
    
    
}
