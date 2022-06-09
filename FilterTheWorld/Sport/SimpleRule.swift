
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

struct ObjectSizeToAxis: Codable {
    var objectSize: Point2D
    var axis: CoordinateAxis
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
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool? {
        
        if stateTimeHistory.isEmpty || stateTimeHistory.contains(where: { stateTime in
            stateTime.sportState.id == SportState.startState.id
        }) && stateTimeHistory.last { stateTime in
            stateTime.sportState.id == self.toStateId
        } == nil {
            return true
        }
        
        let fromLandmark = self.fromLandmarkToAxis.landmark.landmarkType.landmark(poseMap: poseMap)
        
        // 依赖历史状态收集
        let toLandmark = self.fromLandmarkToAxis.landmark.landmarkType.landmark(
            poseMap: stateTimeHistory.last{ stateTime in
                stateTime.sportState.id == self.toStateId
            }!.poseMap
        )
        
        
        let fromSegment = LandmarkSegment(startLandmark: fromLandmark, endLandmark: toLandmark)
        let toSegment = self.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return ComplexRule.satisfy(fromAxis: self.fromLandmarkToAxis.axis,
                                   toAxis: self.toLandmarkSegmentToAxis.axis,
                                   range: self.range,
                                   fromSegment: fromSegment,
                                   toSegment: toSegment)
        
        
        
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


struct ObjectToState: Codable {
    var lowerBound:Double = 0
    var upperBound:Double = 0

    var toStateId:Int
    
    var fromAxis: CoordinateAxis {
        didSet {
            initBound()
        }
    }
    //相对
    var fromPosition:ObjectPositionPoint {
        didSet {
            initBound()
        }
    }
    
    var toPosition:ObjectPositionPoint {
        didSet {
            initBound()
        }
    }
    
    var toObjectSize:ObjectSizeToAxis {
        didSet {
            initBound()
        }
    }
    
    var warning:String = ""
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(stateTimeHistory: [StateTime], object: Observation) -> Bool? {
        
        if stateTimeHistory.isEmpty || stateTimeHistory.contains(where: { stateTime in
            stateTime.sportState.id == SportState.startState.id
        }) && stateTimeHistory.last { stateTime in
            stateTime.sportState.id == self.toStateId
        } == nil {
            return true
        }
        
        let fromPosition = self.fromLandmarkToAxis.landmark.landmarkType.landmark(poseMap: poseMap)
        
        // 依赖历史状态收集
        let toLandmark = self.fromLandmarkToAxis.landmark.landmarkType.landmark(
            poseMap: stateTimeHistory.last{ stateTime in
                stateTime.sportState.id == self.toStateId
            }!.poseMap
        )
        
        
        let fromSegment = LandmarkSegment(startLandmark: fromLandmark, endLandmark: toLandmark)
        let toSegment = self.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return ComplexRule.satisfy(fromAxis: self.fromLandmarkToAxis.axis,
                                   toAxis: self.toLandmarkSegmentToAxis.axis,
                                   range: self.range,
                                   fromSegment: fromSegment,
                                   toSegment: toSegment)
        
        
        
    }
    
    
    init(toStateId: Int, fromAxis: CoordinateAxis, fromObjectPosition: ObjectPositionPoint, toObjectPosition: ObjectPositionPoint, toObjectWidthOrHeight: ObjectSizeToAxis, warning: String) {
        self.toStateId = toStateId
        self.fromPosition = fromObjectPosition
        self.toPosition = toObjectPosition
        self.toObjectSize = toObjectWidthOrHeight
        self.warning = warning
        initBound()
    }
    
    
    
    private mutating func initBound() {
        var length = 0.0
        var bound = 0.0
        print("initBound")
        
        switch (fromAxis, toObjectSize.axis) {
        case (.X, .X):
            length = fromPosition.point.x - toPosition.point.x
            bound = length/toObjectSize.objectSize.width
        case (.X, .Y):
            length = fromPosition.point.x - toPosition.point.x
            bound = length/toObjectSize.objectSize.height

        case (.X, .XY):
            length = fromPosition.point.x - toPosition.point.x
            bound = length/toObjectSize.objectSize.diag

        case (.Y, .X):
            length = fromPosition.point.y - toPosition.point.y
            bound = length/toObjectSize.objectSize.width

        case (.Y, .Y):
            length = fromPosition.point.y - toPosition.point.y
            bound = length/toObjectSize.objectSize.height

        case (.Y, .XY):
            length = fromPosition.point.y - toPosition.point.y
            bound = length/toObjectSize.objectSize.diag

        case (.XY, .X):
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)
            bound = length/toObjectSize.objectSize.width
    
        case (.XY, .Y):
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)
            bound = length/toObjectSize.objectSize.height

        case (.XY, .XY):
            
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)
            bound = length/toObjectSize.objectSize.diag

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
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    func satisfy(poseMap: PoseMap, fromObject: Observation, toObject: Observation) -> Bool {
        
        let fromObjectPosition = fromObject.rect.pointOf(position: self.fromPosition.position)
        let toObjectPosition = toObject.rect.pointOf(position: self.toPosition.position)

        
        let fromSegment = LandmarkSegment(startLandmark: Landmark(position: fromObjectPosition.point2d.point3D, landmarkType: LandmarkType.None), endLandmark: Landmark(position: toObjectPosition.point2d.point3D, landmarkType: LandmarkType.None))
        
        let toSegment = toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return ComplexRule.satisfyWithDirection(fromAxis: self.fromAxis, toAxis: self.toLandmarkSegmentToAxis.axis, range: self.range, fromSegment: fromSegment, toSegment: toSegment)
        
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
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(poseMap: PoseMap, object: Observation) -> Bool {
        
        let fromObject = object.rect.pointOf(position: self.fromPosition.position)
        let toLandmark = self.toLandmark.landmarkType.landmark(poseMap: poseMap)
        
        let fromSegment = LandmarkSegment(startLandmark: Landmark(position: fromObject.point2d.point3D, landmarkType: LandmarkType.None), endLandmark: toLandmark)
        
        let toSegment = toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return ComplexRule.satisfyWithDirection(fromAxis: self.fromAxis, toAxis: self.toLandmarkSegmentToAxis.axis, range: self.range, fromSegment: fromSegment, toSegment: toSegment)
        
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
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(poseMap: PoseMap) -> Bool? {
        
        let fromSegment = self.from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        let toSegment = self.to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return ComplexRule.satisfy(fromAxis: self.from.axis,
                                   toAxis: self.to.axis,
                                   range: self.range,
                                   fromSegment: fromSegment,
                                   toSegment: toSegment)
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
    
    var range: Range<Int> {
        if lowerBound < upperBound {
            return lowerBound.toInt..<upperBound.toInt
        }else {
            return lowerBound.toInt..<(upperBound + 360).toInt
        }
    }
    
    init(landmarkSegment: LandmarkSegment, warning: String) {
        self.landmarkSegment = landmarkSegment
        self.warning = warning
        initBound()
    }
    
    
    func satisfy(poseMap: PoseMap) -> Bool {
        let landmarkSegment = landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        return range.contains(Int(landmarkSegment.angle2d)) || range.contains(Int(landmarkSegment.angle2d + 360))
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
    var imageSize:Point2D
    
    //  左上角 顺时针
    var area: [Point2D]
    
    var warning:String = ""
    
    
    init(landmarkType: LandmarkType, imageSize: Point2D, warning: String) {
        self.landmarkType = landmarkType
        self.imageSize = imageSize
        self.warning = warning
        self.area = [Point2D.zero,Point2D.zero,Point2D.zero,Point2D.zero]
    }
    
    
    func satisfy(landmarkSegmentType: LandmarkTypeSegment, poseMap: PoseMap, frameSize: Point2D) -> Bool? {
        
        let landmarkSegment = landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        let path = self.path(frameSize: frameSize)
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
    // 相对长度
    var length: RelativeLandmarkSegmentsToAxis?
    
    // 关节点在区域内
    var landmarkInArea:LandmarkInArea?
    // TODO:
    //MARK:  1. 物体在区域内 2. 物体与关节点的关系 3.物体相对自身位移 关节相对自身位移
    
    // 基于多帧的规则
//    关节相对自身位移
    var lengthToState:LandmarkToAxisAndState?
    
    // 物体位置相对于关节点
     var objectPositionToLandmark: ObjectToLandmark?
    
    // 物体位置相对于物体位置
    var objectPositionToObjectPosition: ObjectToObject?
    
    // 物体相对于自身位移
    var objectToState: ObjectToState?
    
    
    
    func angleSatisfy(angleRange: AngleRange, poseMap: PoseMap) -> Bool {
        return angleRange.satisfy(poseMap: poseMap)
    }
    
    func lengthSatisfy(relativeDistance: RelativeLandmarkSegmentsToAxis, poseMap: PoseMap) -> Bool? {
        return relativeDistance.satisfy(poseMap: poseMap)
    }
    
    func landmarkInAreaSatisfy(landmarkInArea: LandmarkInArea, poseMap: PoseMap, frameSize: Point2D) -> Bool? {
        return landmarkInArea.satisfy(landmarkSegmentType: landmarkSegmentType, poseMap: poseMap, frameSize: frameSize)
    }
    
    func lengthToStateSatisfy(relativeDistance: LandmarkToAxisAndState, stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool? {
        return relativeDistance.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap)
        
    }
    
    func objectToLandmarkSatisfy(objectToLandmark: ObjectToLandmark, poseMap: PoseMap, object: Observation) -> Bool {
        return objectToLandmark.satisfy(poseMap: poseMap, object: object)
    }
    
    func objectToObjectSatisfy(objectToObject: ObjectToObject, poseMap: PoseMap, object: Observation, targetObject: Observation) -> Bool {
        return objectToObject.satisfy(poseMap: poseMap, fromObject: object, toObject: targetObject)
    }
    
    
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D) -> (Bool, Set<String>) {
        // 单帧
        var lengthSatisfy: Bool? = true

        var angleSatisfy: Bool? = true
        var landmarkInAreaSatisfy: Bool? = true
        
        // 多帧

        var lengthToStateSatisfy: Bool? = true
        // 物体相对于关节点

        
        var objectToLandmarkSatisfy: Bool? = true
        
        //物体相对物体
        var objectToObjectSatisfy: Bool? = true

        var warnings : Set<String> = []
        
        
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
            landmarkInAreaSatisfy = self.landmarkInAreaSatisfy(landmarkInArea: landmarkInArea, poseMap: poseMap, frameSize: frameSize)
            if landmarkInAreaSatisfy == false {
                warnings.insert(landmarkInArea.warning)
            }
        }
        
        
        if let length = lengthToState {
            lengthToStateSatisfy = self.lengthToStateSatisfy(relativeDistance: length, stateTimeHistory: stateTimeHistory, poseMap: poseMap)
            if lengthToStateSatisfy == false {
                warnings.insert(length.warning)
            }
        }
        
        
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
        
        if let objectToObject = objectPositionToObjectPosition {
            if let object = object, let targetObject = targetObject {
                objectToObjectSatisfy = self.objectToObjectSatisfy(objectToObject: objectToObject, poseMap: poseMap, object: object, targetObject: targetObject)
            } else {
                objectToLandmarkSatisfy = false
            }
            if objectToLandmarkSatisfy == false {
                warnings.insert(objectToObject.warning)
            }
        }
        
        // 每个规则至少要包含一个条件 且所有条件都必须满足
        return (
            lengthSatisfy == true &&
                angleSatisfy == true && landmarkInAreaSatisfy == true &&
                lengthToStateSatisfy == true &&
            objectToLandmarkSatisfy == true &&
            objectToObjectSatisfy == true
                , warnings)
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
    
    static func satisfy(fromAxis: CoordinateAxis, toAxis: CoordinateAxis, range: Range<Double>, fromSegment: LandmarkSegment, toSegment: LandmarkSegment) -> Bool {
        switch (fromAxis, toAxis) {
        case (.X, .X):
            return range.contains(
                fromSegment.distanceX/toSegment.distanceX
            )
            
        case (.X, .Y):
            return range.contains(
                fromSegment.distanceX/toSegment.distanceY
            )
            
        case (.X, .XY):
            return range.contains(
                fromSegment.distanceX/toSegment.distance
            )
            
            // from Y
            
        case (.Y, .X):
            return range.contains(
                fromSegment.distanceY/toSegment.distanceX
            )
            
        case (.Y, .Y):
            return range.contains(
                fromSegment.distanceY/toSegment.distanceY
            )
            
        case (.Y, .XY):
            return range.contains(
                fromSegment.distanceY/toSegment.distance
            )
            
            // from XY
            
        case (.XY, .X) :
            return range.contains(
                fromSegment.distance/toSegment.distanceX
            )
            
        case (.XY, .Y):
            return range.contains(
                fromSegment.distance/toSegment.distanceY
            )
            
        case (.XY, .XY):
            return range.contains(
                fromSegment.distance/toSegment.distance
            )
        }
    }
    
    
    static func satisfyWithDirection(fromAxis: CoordinateAxis, toAxis: CoordinateAxis, range: Range<Double>, fromSegment: LandmarkSegment, toSegment: LandmarkSegment) -> Bool {
        switch (fromAxis, toAxis) {
        case (.X, .X):
            return range.contains(
                fromSegment.distanceXWithDirection/toSegment.distanceX
            )
            
        case (.X, .Y):
            return range.contains(
                fromSegment.distanceXWithDirection/toSegment.distanceY
            )
            
        case (.X, .XY):
            return range.contains(
                fromSegment.distanceXWithDirection/toSegment.distance
            )
            
            // from Y
            
        case (.Y, .X):
            return range.contains(
                fromSegment.distanceYWithDirection/toSegment.distanceX
            )
            
        case (.Y, .Y):
            return range.contains(
                fromSegment.distanceYWithDirection/toSegment.distanceY
            )
            
        case (.Y, .XY):
            return range.contains(
                fromSegment.distanceYWithDirection/toSegment.distance
            )
            
            // from XY
            
        case (.XY, .X) :
            return range.contains(
                fromSegment.distance/toSegment.distanceX
            )
            
        case (.XY, .Y):
            return range.contains(
                fromSegment.distance/toSegment.distanceY
            )
            
        case (.XY, .XY):
            return range.contains(
                fromSegment.distance/toSegment.distance
            )
        }
    }
    
    
}
