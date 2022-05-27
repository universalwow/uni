
import Foundation
import CoreGraphics

enum CoordinateAxis: String, Identifiable, CaseIterable, Codable {
    var id: String {
        self.rawValue
    }
    case X,Y,XY
}


enum RuleType: String, Identifiable, CaseIterable {
    var id: String {
        self.rawValue
    }
    case SCORE, VIOLATE
}

struct LandmarkSegmentToAxis: Codable {
    var landmarkSegment: LandmarkSegment
    var axis:CoordinateAxis
    
    static var initValue = LandmarkSegmentToAxis(landmarkSegment: LandmarkSegment.initValue(), axis: .X)
}

// 关节点从一个状态到该状态的 相对位移


struct LandmarkToAxis: Codable{
    var landmark: Landmark
    var axis:CoordinateAxis
}

struct LandmarkToAxisAndState: Codable {
    var lowerBound:Double = 0
    var upperBound:Double = 0

    var toStateId:Int
    //相对
    var fromLandmarkToAxis: LandmarkToAxis {
        didSet {
            initBound()
        }
    }
    
    var toLandmarkToAxis: LandmarkToAxis {
        didSet {
            initBound()
        }
    }
    
    
    var toLandmarkSegmentToAxis: LandmarkSegmentToAxis {
        didSet {
            initBound()
        }
    }
    
    var warning:String = ""
    
    var length: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    init(toStateId: Int, fromLandmarkToAxis: LandmarkToAxis, toLandmarkToAxis: LandmarkToAxis, toLandmarkSegmentToAxis: LandmarkSegmentToAxis, warning: String) {
        self.toStateId = toStateId
        self.fromLandmarkToAxis = fromLandmarkToAxis
        self.toLandmarkToAxis = toLandmarkToAxis
        self.toLandmarkSegmentToAxis = toLandmarkSegmentToAxis
        self.warning = warning
        initBound()
    }
    
    
    
    private mutating func initBound() {
        
        var length = 0.0
        var bound = 0.0
        switch (fromLandmarkToAxis.axis, toLandmarkSegmentToAxis.axis) {
        case (.X, .X):
            length = abs(fromLandmarkToAxis.landmark.position.x - toLandmarkToAxis.landmark.position.x)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX

        case (.X, .Y):
            length = abs(fromLandmarkToAxis.landmark.position.x - toLandmarkToAxis.landmark.position.x)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY

        case (.X, .XY):
            length = abs(fromLandmarkToAxis.landmark.position.x - toLandmarkToAxis.landmark.position.x)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance

        case (.Y, .X):
            length = abs(fromLandmarkToAxis.landmark.position.y - toLandmarkToAxis.landmark.position.y)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX

        case (.Y, .Y):
            length = abs(fromLandmarkToAxis.landmark.position.y - toLandmarkToAxis.landmark.position.y)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY
        case (.Y, .XY):
            length = abs(fromLandmarkToAxis.landmark.position.y - toLandmarkToAxis.landmark.position.y)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance

        case (.XY, .X):
            length = fromLandmarkToAxis.landmark.position.vector2d.distance(to: fromLandmarkToAxis.landmark.position.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX

        case (.XY, .Y):
            length = fromLandmarkToAxis.landmark.position.vector2d.distance(to: fromLandmarkToAxis.landmark.position.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY

        case (.XY, .XY):
            length = fromLandmarkToAxis.landmark.position.vector2d.distance(to: fromLandmarkToAxis.landmark.position.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance
        }
        
        lowerBound = bound
        upperBound = bound
    }
    
}

struct ObjectPositionPoint: Identifiable, Codable {
    var id: String
    var position: ObjectPosition
    var point: Point2D
}

struct ObjectToObject: Codable {
    var lowerBound = 0.0
    var upperBound = 0.0
    
    var fromPosition: ObjectPositionPoint {
        didSet {
            initBound()
        }
    }
    var toPosition: ObjectPositionPoint {
        didSet {
            initBound()
        }
    }
    var fromAxis: CoordinateAxis {
        didSet {
            initBound()
        }
    }
    
    var toLandmarkSegmentToAxis: LandmarkSegmentToAxis {
        didSet {
            initBound()
        }
    }
    
    var warning = ""
    
    init(fromPosition:  ObjectPositionPoint, toPosition: ObjectPositionPoint,
         fromAxis: CoordinateAxis, toLandmarkSegmentToAxis: LandmarkSegmentToAxis, warning: String) {
        self.fromPosition = fromPosition
        self.toPosition = toPosition
        self.fromAxis = fromAxis
        self.toLandmarkSegmentToAxis = toLandmarkSegmentToAxis
        self.warning = warning
        initBound()
    }
    
    var length: Range<Double> {
        lowerBound..<upperBound
    }
    
    func satisfy(poseMap: PoseMap, fromObject: Observation, toObject: Observation) -> Bool {
        
        let fromObjectPosition = fromObject.rect.pointOf(position: self.fromPosition.position)
        let toObjectPosition = toObject.rect.pointOf(position: self.toPosition.position)

        
        let fromSegment = LandmarkSegment(startLandmark: Landmark(position: fromObjectPosition.point2d.point3D, landmarkType: LandmarkType.None), endLandmark: Landmark(position: toObjectPosition.point2d.point3D, landmarkType: LandmarkType.None))
        
        let toSegment = toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return ComplexRule.satisfyWithDirection(fromAxis: self.fromAxis, toAxis: self.toLandmarkSegmentToAxis.axis, lowerBound: self.lowerBound, upperBound: self.upperBound, fromSegment: fromSegment, toSegment: toSegment)
        
    }
    
    
    private mutating func initBound() {
        var length = 0.0
        var bound = 0.0
        print("initBound")
        
        switch (fromAxis, toLandmarkSegmentToAxis.axis) {
        case (.X, .X):
            length = fromPosition.point.x - toPosition.point.x
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
        case (.X, .Y):
            length = fromPosition.point.x - toPosition.point.x
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY

        case (.X, .XY):
            length = fromPosition.point.x - toPosition.point.x
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance

        case (.Y, .X):
            length = fromPosition.point.y - toPosition.point.y
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX

        case (.Y, .Y):
            length = fromPosition.point.y - toPosition.point.y
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY

        case (.Y, .XY):
            length = fromPosition.point.y - toPosition.point.y
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance

        case (.XY, .X):
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
    
        case (.XY, .Y):
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY

        case (.XY, .XY):
            
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance

        }
        lowerBound = bound
        upperBound = bound
    }
    
    
    
    
    
    
}

struct ObjectToLandmark: Codable {
    var lowerBound:Double = 0
    var upperBound:Double = 0
    
    var fromAxis: CoordinateAxis {
        didSet {
            initBound()
        }
    }
    
    var fromPosition: ObjectPositionPoint {
        didSet {
            initBound()
        }
    }
    var toLandmark: Landmark {
        didSet {
            initBound()
        }
    }
    
    
    var toLandmarkSegmentToAxis: LandmarkSegmentToAxis {
        didSet {
            initBound()
        }
    }
    
    var warning = ""
    
    
    init(fromAxis: CoordinateAxis, fromPosition: ObjectPositionPoint, toLandmark: Landmark, toLandmarkSegmentToAxis: LandmarkSegmentToAxis, warning: String) {
        self.fromAxis = fromAxis
        self.fromPosition = fromPosition
        self.toLandmark = toLandmark
        self.toLandmarkSegmentToAxis = toLandmarkSegmentToAxis
        self.warning = warning
        initBound()
    }
    
    var length: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(poseMap: PoseMap, object: Observation) -> Bool {
        
        let fromObject = object.rect.pointOf(position: self.fromPosition.position)
        let toLandmark = self.toLandmark.landmarkType.landmark(poseMap: poseMap)
        
        let fromSegment = LandmarkSegment(startLandmark: Landmark(position: fromObject.point2d.point3D, landmarkType: LandmarkType.None), endLandmark: toLandmark)
        
        let toSegment = toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return ComplexRule.satisfyWithDirection(fromAxis: self.fromAxis, toAxis: self.toLandmarkSegmentToAxis.axis, lowerBound: self.lowerBound, upperBound: self.upperBound, fromSegment: fromSegment, toSegment: toSegment)
        
    }
    
    private mutating func initBound() {
        var length = 0.0
        var bound = 0.0
        
        
        switch (fromAxis, toLandmarkSegmentToAxis.axis) {
        case (.X, .X):
            length = fromPosition.point.x - toLandmark.position.x
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
        case (.X, .Y):
            length = fromPosition.point.x - toLandmark.position.x
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY

        case (.X, .XY):
            length = fromPosition.point.x - toLandmark.position.x
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance

        case (.Y, .X):
            length = fromPosition.point.y - toLandmark.position.y
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX

        case (.Y, .Y):
            length = fromPosition.point.y - toLandmark.position.y
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY

        case (.Y, .XY):
            length = fromPosition.point.y - toLandmark.position.y
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance

        case (.XY, .X):
            length = fromPosition.point.vector2d.distance(to: toLandmark.position.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
    
        case (.XY, .Y):
            length = fromPosition.point.vector2d.distance(to: toLandmark.position.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY

        case (.XY, .XY):
            
            length = fromPosition.point.vector2d.distance(to: toLandmark.position.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance

        }
        lowerBound = bound
        upperBound = bound
    }
    
}


struct RelativeLandmarkSegmentsToAxis: Codable {
    
    var lowerBound:Double = 0
    var upperBound:Double = 0
    var warning:String = ""
    
    var from:LandmarkSegmentToAxis {
        didSet {
            initBound()
        }
    }
    var to: LandmarkSegmentToAxis {
        didSet {
            initBound()
        }
    }
    
    var length: Range<Double> {
        lowerBound..<upperBound
    }
    
    init(from: LandmarkSegmentToAxis, to: LandmarkSegmentToAxis, warning: String) {
        self.from = from
        self.to = to
        self.warning = warning
        initBound()
    }
    
    private mutating func initBound() {
        var bound = 0.0
        switch (from.axis, to.axis) {
        case (.X, .X):
            bound = from.landmarkSegment.distanceX/to.landmarkSegment.distanceX

            
        case (.X, .Y):
            bound = from.landmarkSegment.distanceX/to.landmarkSegment.distanceY

            
        case (.X, .XY):
            bound = from.landmarkSegment.distanceX/to.landmarkSegment.distance
            
            // from Y
            
        case (.Y, .X):
            bound = from.landmarkSegment.distanceY/to.landmarkSegment.distanceX
            
        case (.Y, .Y):
            bound = from.landmarkSegment.distanceY/to.landmarkSegment.distanceY
            
        case (.Y, .XY):
            bound = from.landmarkSegment.distanceY/to.landmarkSegment.distance
            
            
            // from XY
            
        case (.XY, .X):
            bound = from.landmarkSegment.distance/to.landmarkSegment.distanceX
            
        case (.XY, .Y):
            bound = from.landmarkSegment.distance/to.landmarkSegment.distanceY

            
        case (.XY, .XY):
            bound = from.landmarkSegment.distance/to.landmarkSegment.distance

        }
        lowerBound = bound
        upperBound = bound
    }
    
}

struct AngleRange: Codable {
    var lowerBound = 0.0
    var upperBound = 0.0
    var landmarkSegment: LandmarkSegment {
        didSet {
            initBound()
        }
    }
    var warning:String = ""
    
    var angle: Range<Int> {
        if lowerBound < upperBound {
            return lowerBound.toInt..<upperBound.toInt
        }else {
            return lowerBound.toInt..<(upperBound + 360).toInt
        }
    }
    
    init(landmarkSegment: LandmarkSegment, warning: String) {
        self.landmarkSegment = landmarkSegment
        self.warning = warning
    }
    
    
    func satisfy(poseMap: PoseMap) -> Bool? {
        let landmarkSegment = landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        return angle.contains(Int(landmarkSegment.angle2d))
    }
    
    mutating func initBound() {
        let angle = landmarkSegment.angle2d
        self.lowerBound = angle
        self.upperBound = angle
    }
    
    
}


extension LandmarkInArea {
    
    var areaString: String {
        area.reduce("", { result, next in
            result + next.roundedString + ","
        })
    }
    
    var areaToRect: CGRect {
        CGRect(origin: self.area[0].cgPoint,
               size: CGSize(width: abs(self.area[2].x - self.area[0].x),
                            height: abs(self.area[2].y - self.area[0].y)))
    }
    
}

// 过滤有效人
// MARK: 当前只考虑单区域
struct LandmarkInArea: Codable {
    var landmarkType: LandmarkType
    
    //  左上角 顺时针
    var area: [Point2D]
    var warning:String = ""
    
    
    init(landmarkType: LandmarkType, warning: String) {
        self.landmarkType = landmarkType
        self.warning = warning
        self.area = [Point2D.zero,Point2D.zero,Point2D.zero,Point2D.zero]
    }
    
    
    func satisfy(landmarkSegmentType: LandmarkTypeSegment, poseMap: PoseMap) -> Bool? {
        
        let landmarkSegment = landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        if landmarkType == landmarkSegment.startLandmark.landmarkType {
            return path.contains(landmarkSegment.startLandmark.position.vector2d.toCGPoint)
        }else if landmarkType == landmarkSegment.endLandmark.landmarkType {
            return path.contains(landmarkSegment.endLandmark.position.vector2d.toCGPoint)
            
        }
        return nil
    }
}



struct ComplexRules: Identifiable, Hashable, Codable {
    var id = UUID()
    var rules:[ComplexRule] = []
    
    var description:String = ""
    
    static func == (lhs: ComplexRules, rhs: ComplexRules) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func firstIndexOfRule(editedRule: ComplexRule) -> Int? {
        rules.firstIndex(where: { rule in
            rule.landmarkSegmentType.id == editedRule.landmarkSegmentType.id
        })
    }
    
    func firstIndexOfRuleBySegmentType(segmentType: LandmarkTypeSegment) -> Int? {
        rules.firstIndex(where: { rule in
            rule.landmarkSegmentType.id == segmentType.id
        })
    }
    
    func firstRuleBySegmentType(segmentType: LandmarkTypeSegment) -> ComplexRule? {
        if let index = firstIndexOfRuleBySegmentType(segmentType: segmentType) {
            return rules[index]
        }
        return nil
    }
    
    func findFirstComplexRule(ruleId: String?) -> ComplexRule? {
        if let ruleId = ruleId {
            return rules.first(where: { rule in
                rule.id == ruleId
            })
        }
        return nil
        
    }
    
    mutating func dropInvalidRules() {
        // MARK: 新规则
        rules.removeAll { editedRule in
            if editedRule.angle == nil && editedRule.landmarkInArea == nil &&
//                editedRule.lengthX == nil && editedRule.lengthY == nil && editedRule.lengthXY == nil &&
                editedRule.length == nil &&
                editedRule.lengthToState == nil &&
//                editedRule.lengthXToState == nil && editedRule.lengthYToState == nil && editedRule.lengthXYToState == nil &&
//                editedRule.objectPositionYToLandmark == nil && editedRule.objectPositionYToLandmark == nil && editedRule.objectPositionXYToLandmark == nil
                editedRule.objectPositionToLandmark == nil
            
                
            {
                return true
            }
            return false
        }
    }
    
    mutating func updateSportStateRule(editedRule: ComplexRule) {
        
        if let index = firstIndexOfRule(editedRule: editedRule) {
            rules[index] = editedRule
        }else{
            rules.append(editedRule)
        }
        
    }
    
    mutating func setupLandmarkArea(editedSportStateRule: ComplexRule, landmarkinArea: LandmarkInArea?) {
        if let index = firstIndexOfRule(editedRule: editedSportStateRule) {
            self.rules[index].landmarkInArea = landmarkinArea
        }
    }
}

/**
 基于多帧的规则 假设为依赖过去状态收集值
 
 */





/**
 基于单帧的规则
 */
func ruleIdToLandmarkTypes(ruleId: String) -> LandmarkTypeSegment {
    let landmarkTypes = ruleId
        .split(separator: "-")
        .compactMap{ landmarkTypeString in
            LandmarkType(rawValue: "\(landmarkTypeString)")
        }
    return LandmarkTypeSegment(startLandmarkType: landmarkTypes.first!, endLandmarkType: landmarkTypes.last!)
}

struct ComplexRule: Identifiable, Hashable, Codable {
    static func == (lhs: ComplexRule, rhs: ComplexRule) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    var landmarkSegmentType:LandmarkTypeSegment
    
    init(landmarkSegmentType: LandmarkTypeSegment) {
        self.id = landmarkSegmentType.id
        self.landmarkSegmentType = landmarkSegmentType
    }
    
    init(ruleId: String) {
        self.id = ruleId
        self.landmarkSegmentType = ruleIdToLandmarkTypes(ruleId: ruleId)
    }
    
    //  var landmarkSegment:LandmarkSegment
    // 10 - 30 340-380
    // 角度
    // 当前状态下该规则需要的提示
    var warning:String = ""
    // 角度
    var angle:AngleRange?
//    // X 轴间距
//    var lengthX: RelativeLandmarkSegmentsToAxis?
//    // Y 轴间距
//    var lengthY: RelativeLandmarkSegmentsToAxis?
//    // 距离
//    var lengthXY: RelativeLandmarkSegmentsToAxis?
    var length: RelativeLandmarkSegmentsToAxis?
    
    // 关节点在区域内
    var landmarkInArea:LandmarkInArea?
    // TODO:
    //MARK:  1. 物体在区域内 2. 物体与关节点的关系 3.物体相对自身位移 关节相对自身位移
    
    // 基于多帧的规则
//    var lengthXToState: LandmarkToAxisAndState?
//    var lengthYToState: LandmarkToAxisAndState?
//    var lengthXYToState: LandmarkToAxisAndState?
    
    var lengthToState:LandmarkToAxisAndState?
    
    // 物体位置相对于关节点
//    var objectPositionXToLandmark: ObjectToLandmark?
//    var objectPositionYToLandmark: ObjectToLandmark?
//    var objectPositionXYToLandmark: ObjectToLandmark?
     var objectPositionToLandmark: ObjectToLandmark?
    
    // 物体位置相对于物体位置
    var objectPositionToObjectPosition: ObjectToObject?
    
    
    func angleSatisfy(angleRange: AngleRange, poseMap: PoseMap) -> Bool {
        let landmarkSegment = landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        //    print("angle range \(angleRange.angle)/\(landmarkSegment.angle2d.toInt)/\(angleRange.angle.contains(landmarkSegment.angle2d.toInt))")
        return angleRange.angle.contains(landmarkSegment.angle2d.toInt) ||
        angleRange.angle.contains(landmarkSegment.angle2d.toInt + 360)
    }
    
    func landmarkInAreaSatisfy(landmarkInArea: LandmarkInArea, poseMap: PoseMap) -> Bool? {
        return landmarkInArea.satisfy(landmarkSegmentType: landmarkSegmentType, poseMap: poseMap)
    }
    
    func objectToLandmarkSatisfy(objectToLandmark: ObjectToLandmark, poseMap: PoseMap, object: Observation) -> Bool {
        return objectToLandmark.satisfy(poseMap: poseMap, object: object)
    }
    
    
    
    
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation?) -> (Bool, Set<String>) {
        // 单帧
//        var lengthXSatisfy: Bool? = true
//        var lengthYSatisfy: Bool? = true
//        var lengthXYSatisfy: Bool? = true
        var lengthSatisfy: Bool? = true

        var angleSatisfy: Bool? = true
        var landmarkInAreaSatisfy: Bool? = true
        
        // 多帧
//        var lengthXToStateSatisfy: Bool? = true
//        var lengthYToStateSatisfy: Bool? = true
//        var lengthXYToStateSatisfy: Bool? = true
        var lengthToStateSatisfy: Bool? = true
        // 物体相对于关节点
        
//        var objectXToLandmarkSatisfy: Bool? = true
//        var objectYToLandmarkSatisfy: Bool? = true
//        var objectXYToLandmarkSatisfy: Bool? = true
        
        var objectToLandmarkSatisfy: Bool? = true

        var warnings : Set<String> = []
        
//        if let length = lengthX {
//            lengthXSatisfy = lengthSatisfy(relativeDistance: length, poseMap: poseMap)
//            if lengthXSatisfy == false {
//                warnings.insert(length.warning)
//            }
//        }
//
//        if let length = lengthY {
//            lengthYSatisfy = lengthSatisfy(relativeDistance: length, poseMap: poseMap)
//            if lengthYSatisfy == false {
//                warnings.insert(length.warning)
//            }
//        }
//
//        if let length = lengthXY {
//            lengthXYSatisfy = lengthSatisfy(relativeDistance: length, poseMap: poseMap)
//            if lengthXYSatisfy == false {
//                warnings.insert(length.warning)
//            }
//        }
        
        if let length = length {
            lengthSatisfy = self.lengthSatisfy(relativeDistance: length, poseMap: poseMap)
                    if lengthSatisfy == false {
                        warnings.insert(length.warning)
                    }
                }
        
        if let angleRange = angle {
            angleSatisfy = self.angleSatisfy(angleRange: angleRange, poseMap: poseMap)
            
            if angleSatisfy == false {
                warnings.insert(angleRange.warning)
            }
        }
        
        if let landmarkInArea = landmarkInArea {
            landmarkInAreaSatisfy = self.landmarkInAreaSatisfy(landmarkInArea: landmarkInArea, poseMap: poseMap)
            if landmarkInAreaSatisfy == false {
                warnings.insert(landmarkInArea.warning)
            }
        }
        
//
//        if let length = lengthXToState {
//            lengthXToStateSatisfy = lengthToStateSatisfy(relativeDistance: length, stateTimeHistory: stateTimeHistory, poseMap: poseMap)
//            if lengthXToStateSatisfy == false {
//                warnings.insert(length.warning)
//            }
//        }
//
//        if let length = lengthYToState {
//            lengthYToStateSatisfy = lengthToStateSatisfy(relativeDistance: length, stateTimeHistory: stateTimeHistory, poseMap: poseMap)
//            if lengthYToStateSatisfy == false {
//                warnings.insert(length.warning)
//            }
//        }
//
//        if let length = lengthXYToState {
//            lengthXYToStateSatisfy = lengthToStateSatisfy(relativeDistance: length, stateTimeHistory: stateTimeHistory, poseMap: poseMap)
//            if lengthXYToStateSatisfy == false {
//                warnings.insert(length.warning)
//            }
//        }
        
        if let length = lengthToState {
            lengthToStateSatisfy = self.lengthToStateSatisfy(relativeDistance: length, stateTimeHistory: stateTimeHistory, poseMap: poseMap)
            if lengthToStateSatisfy == false {
                warnings.insert(length.warning)
            }
        }
        
        
//        if let objectTolandmark = objectPositionXToLandmark {
//            if let object = object {
//                objectXToLandmarkSatisfy = objectToLandmarkSatisfy(objectToLandmark: objectTolandmark, poseMap: poseMap, object: object)
//            } else {
//                objectXToLandmarkSatisfy = false
//            }
//            if objectXToLandmarkSatisfy == false {
//                warnings.insert(objectTolandmark.warning)
//            }
//        }
        
//        if let objectTolandmark = objectPositionYToLandmark {
//            if let object = object {
//                objectYToLandmarkSatisfy = objectToLandmarkSatisfy(objectToLandmark: objectTolandmark, poseMap: poseMap, object: object)
//            }
//            else {
//                objectYToLandmarkSatisfy = false
//            }
//
//            if objectYToLandmarkSatisfy == false {
//                warnings.insert(objectTolandmark.warning)
//            }
//        }
//
//        if let objectTolandmark = objectPositionXYToLandmark {
//            if let object = object {
//                objectXYToLandmarkSatisfy = objectToLandmarkSatisfy(objectToLandmark: objectTolandmark, poseMap: poseMap, object: object)
//            }
//            else {
//                objectXYToLandmarkSatisfy = false
//            }
//            if objectXYToLandmarkSatisfy == false {
//                warnings.insert(objectTolandmark.warning)
//            }
//        }
        
        if let objectTolandmark = objectPositionToLandmark {
            if let object = object {
                objectToLandmarkSatisfy = self.objectToLandmarkSatisfy(objectToLandmark: objectTolandmark, poseMap: poseMap, object: object)
            } else {
                objectToLandmarkSatisfy = false
            }
            if objectToLandmarkSatisfy == false {
                warnings.insert(objectTolandmark.warning)
            }
        }
        
        // 每个规则至少要包含一个条件 且所有条件都必须满足
        return (
//            lengthXSatisfy == true && lengthYSatisfy == true && lengthXYSatisfy == true &&
            lengthSatisfy == true &&
                angleSatisfy == true && landmarkInAreaSatisfy == true &&
//                lengthXToStateSatisfy == true && lengthYToStateSatisfy == true && lengthXYToStateSatisfy == true &&
                lengthToStateSatisfy == true &&
            objectToLandmarkSatisfy == true
//                objectXToLandmarkSatisfy == true && objectYToLandmarkSatisfy == true && objectXYToLandmarkSatisfy == true
                , warnings)
    }
    
    func lengthSatisfy(relativeDistance: RelativeLandmarkSegmentsToAxis, poseMap: PoseMap) -> Bool? {
        let  lowerBound = relativeDistance.length.lowerBound
        let  upperBound = relativeDistance.length.upperBound
        
        let fromSegment = relativeDistance.from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        let toSegment = relativeDistance.to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return ComplexRule.satisfy(fromAxis: relativeDistance.from.axis,
                                   toAxis: relativeDistance.to.axis,
                                   lowerBound: lowerBound,
                                   upperBound: upperBound,
                                   fromSegment: fromSegment,
                                   toSegment: toSegment)
    }
    
    
    func lengthToStateSatisfy(relativeDistance: LandmarkToAxisAndState, stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool? {
        
        if stateTimeHistory.isEmpty || stateTimeHistory.contains(where: { stateTime in
            stateTime.sportState.id == SportState.startState.id
        }) && stateTimeHistory.last { stateTime in
            stateTime.sportState.id == relativeDistance.toStateId
        } == nil {
            return true
        }
        
        let  lowerBound = relativeDistance.length.lowerBound
        let  upperBound = relativeDistance.length.upperBound
        
        let fromLandmark = relativeDistance.fromLandmarkToAxis.landmark.landmarkType.landmark(poseMap: poseMap)
        
        // 依赖历史状态收集
        let toLandmark = relativeDistance.fromLandmarkToAxis.landmark.landmarkType.landmark(
            poseMap: stateTimeHistory.last{ stateTime in
                stateTime.sportState.id == relativeDistance.toStateId
            }!.poseMap
        )
        
        
        let fromSegment = LandmarkSegment(startLandmark: fromLandmark, endLandmark: toLandmark)
        let toSegment = relativeDistance.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return ComplexRule.satisfy(fromAxis: relativeDistance.fromLandmarkToAxis.axis,
                                   toAxis: relativeDistance.toLandmarkSegmentToAxis.axis,
                                   lowerBound: lowerBound,
                                   upperBound: upperBound,
                                   fromSegment: fromSegment,
                                   toSegment: toSegment)
        
        
        
    }
    
}

struct SimpleRule: Codable {
    var landmarkSegmentType:LandmarkTypeSegment
    // 10 - 30 340-380
    var angleRange:Range<Int>
    
    func angleSatisfy(poseMap: PoseMap) -> Bool {
        let landmarkSegment = landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        return angleRange.contains(landmarkSegment.angle2d.toInt) ||
        angleRange.contains(landmarkSegment.angle2d.toInt + 360)
    }
}


struct StateTransition {
    let currentState: SportState
    let nextState:SportState
}


extension ComplexRule {
    
    static func satisfy(fromAxis: CoordinateAxis, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, fromSegment: LandmarkSegment, toSegment: LandmarkSegment) -> Bool {
        switch (fromAxis, toAxis) {
        case (.X, .X):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceX/toSegment.distanceX
            )
            
        case (.X, .Y):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceX/toSegment.distanceY
            )
            
        case (.X, .XY):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceX/toSegment.distance
            )
            
            // from Y
            
        case (.Y, .X):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceY/toSegment.distanceX
            )
            
        case (.Y, .Y):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceY/toSegment.distanceY
            )
            
        case (.Y, .XY):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceY/toSegment.distance
            )
            
            // from XY
            
        case (.XY, .X) :
            return (lowerBound..<upperBound).contains(
                fromSegment.distance/toSegment.distanceX
            )
            
        case (.XY, .Y):
            return (lowerBound..<upperBound).contains(
                fromSegment.distance/toSegment.distanceY
            )
            
        case (.XY, .XY):
            return (lowerBound..<upperBound).contains(
                fromSegment.distance/toSegment.distance
            )
        }
    }
    
    
    static func satisfyWithDirection(fromAxis: CoordinateAxis, toAxis: CoordinateAxis, lowerBound: Double, upperBound: Double, fromSegment: LandmarkSegment, toSegment: LandmarkSegment) -> Bool {
        switch (fromAxis, toAxis) {
        case (.X, .X):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceXWithDirection/toSegment.distanceX
            )
            
        case (.X, .Y):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceXWithDirection/toSegment.distanceY
            )
            
        case (.X, .XY):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceXWithDirection/toSegment.distance
            )
            
            // from Y
            
        case (.Y, .X):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceYWithDirection/toSegment.distanceX
            )
            
        case (.Y, .Y):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceYWithDirection/toSegment.distanceY
            )
            
        case (.Y, .XY):
            return (lowerBound..<upperBound).contains(
                fromSegment.distanceYWithDirection/toSegment.distance
            )
            
            // from XY
            
        case (.XY, .X) :
            return (lowerBound..<upperBound).contains(
                fromSegment.distance/toSegment.distanceX
            )
            
        case (.XY, .Y):
            return (lowerBound..<upperBound).contains(
                fromSegment.distance/toSegment.distanceY
            )
            
        case (.XY, .XY):
            return (lowerBound..<upperBound).contains(
                fromSegment.distance/toSegment.distance
            )
        }
    }
    
    
}
