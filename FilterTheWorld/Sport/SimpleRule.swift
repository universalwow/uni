
import Foundation
import CoreGraphics

enum CoordinateAxis: String, Identifiable, CaseIterable, Codable {
    var id: String {
        self.rawValue
    }
    case X,Y,XY
}

enum Direction: String, Identifiable, CaseIterable, Codable {
    var id: String {
        self.rawValue
    }
    case UP, DOWN, LEFT, RIGTH, LEFT_UP, RIGHT_UP, LEFT_DOWN, RIGHT_DOWN
}


enum RuleType: String, Identifiable, CaseIterable {
    var id: String {
        self.rawValue
    }
    case SCORE, VIOLATE
}

enum RuleClass: String, Identifiable, CaseIterable, Codable {
    var id: String {
        self.rawValue
    }
    case LandmarkSegment, Landmark, Observation
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

struct LandmarkToDirection: Codable{
    var landmark: Landmark
    var direction:Direction
}

struct LandmarkToState: Identifiable, Codable {
    var id = UUID()
    var lowerBound:Double = 0
    var upperBound:Double = 0
    
    var toStateId:Int {
        didSet {
            if toStateId != oldValue {
                initBound()
            }
            
        }
    }
    //相对
    var fromLandmarkToAxis: LandmarkToAxis {
        didSet {
            if fromLandmarkToAxis.axis.id != oldValue.axis.id ||
                fromLandmarkToAxis.landmark.id != oldValue.landmark.id {
                initBound()
            }
            
        }
    }
    
    var toLandmarkToAxis: LandmarkToAxis {
        didSet {
            if toLandmarkToAxis.axis.id != oldValue.axis.id ||
                toLandmarkToAxis.landmark.id != oldValue.landmark.id {
                initBound()
            }
        }
    }
    
    
    var toLandmarkSegmentToAxis: LandmarkSegmentToAxis {
        didSet {
            if toLandmarkSegmentToAxis.axis.id != oldValue.axis.id ||
                toLandmarkSegmentToAxis.landmarkSegment.id != oldValue.landmarkSegment.id {
                initBound()
            }
            
        }
    }
    
    var warning:Warning
    
    
    init(toStateId: Int, fromLandmarkToAxis: LandmarkToAxis, toLandmarkToAxis: LandmarkToAxis, toLandmarkSegmentToAxis: LandmarkSegmentToAxis, warning: Warning) {
        self.toStateId = toStateId
        self.fromLandmarkToAxis = fromLandmarkToAxis
        self.toLandmarkToAxis = toLandmarkToAxis
        self.toLandmarkSegmentToAxis = toLandmarkSegmentToAxis
        self.warning = warning
        
        initBound()
    }
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool {
        
        if stateTimeHistory.isEmpty || stateTimeHistory.contains(where: { stateTime in
            stateTime.sportState.id == SportState.startState.id
        }) && stateTimeHistory.last(where: { stateTime in
            stateTime.sportState.id == self.toStateId
        }) == nil {
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
        
        return ComplexRule.satisfyWithDirection(fromAxis: self.fromLandmarkToAxis.axis,
                                   toAxis: self.toLandmarkSegmentToAxis.axis,
                                   range: self.range,
                                   fromSegment: fromSegment,
                                   toSegment: toSegment)
    }
    
    private mutating func initBound() {
        
        var length = 0.0
        var bound = 0.0
        switch (fromLandmarkToAxis.axis, toLandmarkSegmentToAxis.axis) {
        case (.X, .X):
            length = fromLandmarkToAxis.landmark.position.x - toLandmarkToAxis.landmark.position.x
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
            
        case (.X, .Y):
            length = fromLandmarkToAxis.landmark.position.x - toLandmarkToAxis.landmark.position.x
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY
            
        case (.X, .XY):
            length = fromLandmarkToAxis.landmark.position.x - toLandmarkToAxis.landmark.position.x
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance
            
        case (.Y, .X):
            length = fromLandmarkToAxis.landmark.position.y - toLandmarkToAxis.landmark.position.y
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
            
        case (.Y, .Y):
            length = fromLandmarkToAxis.landmark.position.y - toLandmarkToAxis.landmark.position.y
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY
        case (.Y, .XY):
            length = fromLandmarkToAxis.landmark.position.y - toLandmarkToAxis.landmark.position.y
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

// 关节点相对自身位移

struct LandmarkToSelf: Identifiable, Codable {
    var id = UUID()
    
    var landmarkType: LandmarkType
    var xLowerBound:Double = 0
    var yLowerBound:Double = 0

    var toDirection: Direction
    
    var toLandmarkSegmentToAxis: LandmarkSegmentToAxis
    
    var warning:Warning
    
    init(landmarkType: LandmarkType, toDirection: Direction, toLandmarkSegmentToAxis: LandmarkSegmentToAxis, xLowerBound: Double, yLowerBound: Double, warning: Warning) {
        self.landmarkType = landmarkType
        self.toDirection = toDirection
        self.toLandmarkSegmentToAxis = toLandmarkSegmentToAxis
        self.xLowerBound = xLowerBound
        self.yLowerBound = yLowerBound
        self.warning = warning
    }
    
    func satisfy(stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool {
        //相对于当前状态收集到的边界位移
        let toStateTime = stateTimeHistory.last!
        
        if [SportState.startState.name, SportState.readyState.name].contains(where: { name in
            name == toStateTime.sportState.name
            
        }) {
            return true
        }
        
        let toSegment = self.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        var relativeToLength = 0.0
        switch toLandmarkSegmentToAxis.axis {
            
        case .X:
            relativeToLength = toSegment.distanceX
        case .Y:
            relativeToLength = toSegment.distanceY
        case .XY:
            relativeToLength = toSegment.distance
        }
        
        let targetXBound = xLowerBound * relativeToLength
        let targetYBound = yLowerBound * relativeToLength
        
//        希望fromBound是正值 如果为负则说明有错误
        var fromXBound = targetXBound
        var fromYBound = targetYBound
        
        switch toDirection {
//            相对上一状态的位移
            case .UP:
                let targetY = toStateTime.dynamicPoseMaps[landmarkType]!.minY
                fromYBound = poseMap[landmarkType]!.y - targetY.y
            
            case .DOWN:
                let targetY = toStateTime.dynamicPoseMaps[landmarkType]!.maxY
                fromYBound = targetY.y - poseMap[landmarkType]!.y
            
            case .LEFT:
                let targetX = toStateTime.dynamicPoseMaps[landmarkType]!.minX
                fromXBound = poseMap[landmarkType]!.x - targetX.x
            
            case .RIGTH:
                let targetX = toStateTime.dynamicPoseMaps[landmarkType]!.maxX
                fromXBound = targetX.x - poseMap[landmarkType]!.x
                
            case .LEFT_UP:
                let targetX = toStateTime.dynamicPoseMaps[landmarkType]!.minX
                fromXBound = poseMap[landmarkType]!.x - targetX.x

                let targetY = toStateTime.dynamicPoseMaps[landmarkType]!.minY
                fromYBound = poseMap[landmarkType]!.y - targetY.y
            
            case .LEFT_DOWN:
                let targetX = toStateTime.dynamicPoseMaps[landmarkType]!.minX
                fromXBound = poseMap[landmarkType]!.x - targetX.x
                
                let targetY = toStateTime.dynamicPoseMaps[landmarkType]!.maxY
                fromYBound = targetY.y - poseMap[landmarkType]!.y

            case .RIGHT_UP:
            
                let targetX = toStateTime.dynamicPoseMaps[landmarkType]!.maxX
                fromXBound = targetX.x - poseMap[landmarkType]!.x

                let targetY = toStateTime.dynamicPoseMaps[landmarkType]!.minY
                fromYBound = poseMap[landmarkType]!.y - targetY.y
            
            case .RIGHT_DOWN:
                let targetX = toStateTime.dynamicPoseMaps[landmarkType]!.maxX
                fromXBound = targetX.x - poseMap[landmarkType]!.x

                let targetY = toStateTime.dynamicPoseMaps[landmarkType]!.maxY
                fromYBound = targetY.y - poseMap[landmarkType]!.y
        }
        
        return fromXBound >= targetXBound && fromYBound >= targetYBound
    }

}




// 物体相对自身位移
struct ObjectToSelf: Identifiable, Codable {
    var id = UUID()
    var objectId: String = ""
    var xLowerBound:Double = 0
    var yLowerBound:Double = 0

    var toDirection: Direction
    var warning:Warning
    
    init(objectId: String, toDirection: Direction, xLowerBound: Double, yLowerBound: Double, warning: Warning) {
        self.objectId = objectId
        self.toDirection = toDirection
        self.xLowerBound = xLowerBound
        self.yLowerBound = yLowerBound
        self.warning = warning
    }
    
    func satisfy(stateTimeHistory: [StateTime], object: Observation) -> Bool {
        //相对于当前状态收集到的边界位移
        let toStateTime = stateTimeHistory.last!
        
        let targetXBound = xLowerBound * object.rect.height
        let targetYBound = yLowerBound * object.rect.height
        
//        希望fromBound是正值 如果为负则说明有错误
        var fromXBound = targetXBound
        var fromYBound = targetYBound
        
        switch toDirection {
//            相对上一状态的位移
            case .UP:
                let targetYObject = toStateTime.dynamicObjectsMaps[object.label]!.minY
                fromYBound = object.rect.midY - targetYObject.rect.midY
            
            case .DOWN:
                let targetYObject = toStateTime.dynamicObjectsMaps[object.label]!.maxY
                fromYBound = targetYObject.rect.midY - object.rect.midY
            
            case .LEFT:
                let targetXObject = toStateTime.dynamicObjectsMaps[object.label]!.minX
                fromXBound = object.rect.midX - targetXObject.rect.midX
            
            case .RIGTH:
                let targetXObject = toStateTime.dynamicObjectsMaps[object.label]!.maxX
                fromXBound = targetXObject.rect.midX - object.rect.midX
                
            case .LEFT_UP:
                let targetXObject = toStateTime.dynamicObjectsMaps[object.label]!.minX
                fromXBound = object.rect.midX - targetXObject.rect.midX

                let targetYObject = toStateTime.dynamicObjectsMaps[object.label]!.minY
                fromYBound = object.rect.midY - targetYObject.rect.midY
            
            case .LEFT_DOWN:
                let targetXObject = toStateTime.dynamicObjectsMaps[object.label]!.minX
                    fromXBound = object.rect.midX - targetXObject.rect.midX
                
                let targetYObject = toStateTime.dynamicObjectsMaps[object.label]!.maxY
                    fromYBound = targetYObject.rect.midY - object.rect.midY

            case .RIGHT_UP:
            
                let targetXObject = toStateTime.dynamicObjectsMaps[object.label]!.maxX
                    fromXBound = targetXObject.rect.midX - object.rect.midX

                let targetYObject = toStateTime.dynamicObjectsMaps[object.label]!.minY
                    fromYBound = object.rect.midY - targetYObject.rect.midY
            
            case .RIGHT_DOWN:
                let targetXObject = toStateTime.dynamicObjectsMaps[object.label]!.maxX
                    fromXBound = targetXObject.rect.midX - object.rect.midX

                let targetYObject = toStateTime.dynamicObjectsMaps[object.label]!.maxY
                    fromYBound = targetYObject.rect.midY - object.rect.midY
        }
        
        return fromXBound >= targetXBound && fromYBound >= targetYBound
    }
}




struct ObjectPositionPoint: Identifiable, Codable {
    var id: String
    var position: ObjectPosition
    var point: Point2D
}

struct ObjectToObject: Identifiable, Codable {
    
    var id = UUID()
    
    var lowerBound = 0.0
    var upperBound = 0.0
    
    var fromPosition: ObjectPositionPoint {
        didSet {
            if fromPosition.id != oldValue.id ||
                fromPosition.position.id != oldValue.position.id {
                initBound()
            }
            
        }
    }
    var toPosition: ObjectPositionPoint {
        didSet {
            if toPosition.id != oldValue.id ||
                toPosition.position.id != oldValue.position.id {
                initBound()
            }
        }
    }
    var fromAxis: CoordinateAxis {
        didSet {
            if fromAxis.id != oldValue.id {
                initBound()
            }
        }
    }
    
    var toLandmarkSegmentToAxis: LandmarkSegmentToAxis {
        didSet {
            if toLandmarkSegmentToAxis.axis.id != oldValue.axis.id ||
                toLandmarkSegmentToAxis.landmarkSegment.id != oldValue.landmarkSegment.id {
                initBound()
            }
            
        }
    }
    
    var warning:Warning
    
    init(fromPosition:  ObjectPositionPoint, toPosition: ObjectPositionPoint,
         fromAxis: CoordinateAxis, toLandmarkSegmentToAxis: LandmarkSegmentToAxis, warning: Warning) {
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

struct ObjectToLandmark: Identifiable, Codable {
    var id = UUID()
    
    var lowerBound:Double = 0
    var upperBound:Double = 0
    
    var fromAxis: CoordinateAxis {
        didSet {
            if fromAxis.id != oldValue.id {
                initBound()
            }
        }
    }
    
    var fromPosition: ObjectPositionPoint {
        didSet {
            if fromPosition.id != oldValue.id ||
                fromPosition.position.id != oldValue.position.id {
                print("fromPosition \(fromPosition.id) \(fromPosition.position.id) - \(fromPosition.point)")
                
                initBound()
            }
        }
    }
    var toLandmark: Landmark {
        didSet {
            if toLandmark.id != oldValue.id {
                initBound()
            }
            
        }
    }
    
    
    var toLandmarkSegmentToAxis: LandmarkSegmentToAxis {
        didSet {
            if toLandmarkSegmentToAxis.axis.id != oldValue.axis.id ||
                toLandmarkSegmentToAxis.landmarkSegment.id != oldValue.landmarkSegment.id {
                initBound()
            }
            
        }
    }
    
    var warning: Warning
    
    init(fromAxis: CoordinateAxis, fromPosition: ObjectPositionPoint, toLandmark: Landmark, toLandmarkSegmentToAxis: LandmarkSegmentToAxis, warning: Warning) {
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


struct LandmarkSegmentLength: Identifiable, Codable {
    var id = UUID()
    
    var lowerBound:Double = 0
    var upperBound:Double = 0

    var from:LandmarkSegmentToAxis {
        didSet {
            if from.landmarkSegment.id != oldValue.landmarkSegment.id ||
                from.axis.id != oldValue.axis.id {
                initBound()
            }
            
        }
    }
    var to: LandmarkSegmentToAxis {
        didSet {
            if to.landmarkSegment.id != oldValue.landmarkSegment.id ||
                to.axis.id != oldValue.axis.id {
                initBound()
            }
        }
    }
    
    var warning:Warning
    
    init(from: LandmarkSegmentToAxis, to: LandmarkSegmentToAxis, warning: Warning) {
        self.from = from
        self.to = to
        self.warning = warning
        initBound()
    }
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(poseMap: PoseMap) -> Bool {
        
        let fromSegment = self.from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        let toSegment = self.to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return ComplexRule.satisfyWithDirection(fromAxis: self.from.axis,
                                   toAxis: self.to.axis,
                                   range: self.range,
                                   fromSegment: fromSegment,
                                   toSegment: toSegment)
    }
    
 
    
    private mutating func initBound() {
        var bound = 0.0
        switch (from.axis, to.axis) {
        case (.X, .X):
            bound = from.landmarkSegment.distanceXWithDirection/to.landmarkSegment.distanceX
            
            
        case (.X, .Y):
            bound = from.landmarkSegment.distanceXWithDirection/to.landmarkSegment.distanceY
            
            
        case (.X, .XY):
            bound = from.landmarkSegment.distanceXWithDirection/to.landmarkSegment.distance
            
            // from Y
            
        case (.Y, .X):
            bound = from.landmarkSegment.distanceYWithDirection/to.landmarkSegment.distanceX
            
        case (.Y, .Y):
            bound = from.landmarkSegment.distanceYWithDirection/to.landmarkSegment.distanceY
            
        case (.Y, .XY):
            bound = from.landmarkSegment.distanceYWithDirection/to.landmarkSegment.distance
            
            
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

struct AngleToLandmarkSegment: Identifiable, Codable {
    
    var id = UUID()
    var lowerBound:Double = 0
    var upperBound:Double = 0
    
    var from:LandmarkSegment {
        didSet {
            if oldValue.landmarkSegmentType != from.landmarkSegmentType {
                initBound()
            }
        }
    }
    var to: LandmarkSegment {
        didSet {
            if oldValue.landmarkSegmentType != to.landmarkSegmentType {
                initBound()
            }
        }
    }
    
    var warning:Warning
    
    init(from: LandmarkSegment, to: LandmarkSegment, warning: Warning) {
        self.from = from
        self.to = to
        self.warning = warning
        initBound()
    }

    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(poseMap: PoseMap) -> Bool {
        
        let fromSegment = self.from.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        let toSegment = self.to.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        return range.contains(fromSegment.angle2d - toSegment.angle2d) || range.contains(fromSegment.angle2d - toSegment.angle2d + 360) || range.contains(fromSegment.angle2d - toSegment.angle2d - 360)
    }
    
    private mutating func initBound() {
        let bound = from.angle2d - to.angle2d
        lowerBound = bound
        upperBound = bound
        
    }
}

struct LandmarkSegmentAngle: Identifiable, Codable {
    var id = UUID()
    var lowerBound = 0.0
    var upperBound = 0.0
    var landmarkSegment: LandmarkSegment {
        didSet {
            if oldValue.id != landmarkSegment.id {
                initBound()
            }
        }
    }
    var warning:Warning

    init(landmarkSegment: LandmarkSegment, warning: Warning) {
        self.landmarkSegment = landmarkSegment
        self.warning = warning
        initBound()
    }
    
    var range: Range<Int> {
        if lowerBound < upperBound {
            return lowerBound.toInt..<upperBound.toInt
        }else {
            return lowerBound.toInt..<(upperBound + 360).toInt
        }
    }
    
    func satisfy(poseMap: PoseMap) -> Bool {
        let landmarkSegment = landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        print("angle range - \(range) - \(Int(landmarkSegment.angle2d))")
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
struct LandmarkInArea: Identifiable, Codable {
    var id = UUID()
    var landmark: Landmark
    var imageSize:Point2D
    
    //  左上角 顺时针
    var area: [Point2D]
    
    var warning:Warning
    
    init(landmark: Landmark, imageSize: Point2D, warning: Warning) {
        self.landmark = landmark
        self.imageSize = imageSize
        self.warning = warning
        self.area = [
            Point2D(x: 0.4*self.imageSize.width, y: 0.6*self.imageSize.height),
            Point2D(x: 0.6*self.imageSize.width, y: 0.6*self.imageSize.height),
            Point2D(x: 0.6*self.imageSize.width, y: 0.8*self.imageSize.height),
            Point2D(x: 0.4*self.imageSize.width, y: 0.8*self.imageSize.height)
                    ]
    }
    
    func satisfy(poseMap: PoseMap, frameSize: Point2D) -> Bool {
        let landmarkPoint = poseMap[landmark.landmarkType]!
        let path = self.path(frameSize: frameSize)
        return path.contains(landmarkPoint.vector2d.toCGPoint)
    }
    
    var satisfy: Bool {
        let path = self.path(frameSize: imageSize)
        return path.contains(landmark.position.vector2d.toCGPoint)
    }
}



struct ComplexRules: Identifiable, Hashable, Codable {
    var id = UUID()
    // 关系与
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
    
//    mutating func updateSportStateRule(editedRule: Ruler, ruleClass: Rule) {
//
//        if let index = firstIndexOfRule(editedRule: editedRule) {
//            rules[index] = editedRule
//        }else{
//            rules.append(editedRule)
//        }
//
//    }
    
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
func ruleIdToLandmarkSegmentType(ruleId: String) -> LandmarkTypeSegment {
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
        self.landmarkSegmentType = ruleIdToLandmarkSegmentType(ruleId: ruleId)
    }
    
    // ---------------基于单帧的规则--------------
    // 10 - 30 340-380
    // 角度
    
    var angle:LandmarkSegmentAngle?
    // 相对长度
    var length: LandmarkSegmentLength?
    
    var angleToLandmarkSegment: AngleToLandmarkSegment?
    
    // 物体位置相对于关节点
    var objectPositionToLandmark: ObjectToLandmark?
    
    // 物体位置相对于物体位置
    var objectPositionToObjectPosition: ObjectToObject?
    
    // 关节点在区域内
    var landmarkInArea:LandmarkInArea?

    // -------------基于多帧的规则-------------
    
    // 关节相对自身位移
//    相关状态转换时收集的关节点 不更新
    var lengthToState:LandmarkToState?
    
    // 物体相对于自身最大位移
    var objectToSelf: ObjectToSelf?
    
    // 关节相对自身最大位移
    var landmarkToSelf: LandmarkToSelf?
    
    
    func angleSatisfy(angleRange: LandmarkSegmentAngle, poseMap: PoseMap) -> Bool {
        
        return angleRange.satisfy(poseMap: poseMap)
    }
    
    func angleToLandmarkSatisfy(angleToLandmarkSegment: AngleToLandmarkSegment, poseMap: PoseMap) -> Bool {
        
        return angleToLandmarkSegment.satisfy(poseMap: poseMap)
    }
    
    func lengthSatisfy(relativeDistance: LandmarkSegmentLength, poseMap: PoseMap) -> Bool? {
        return relativeDistance.satisfy(poseMap: poseMap)
    }
    
    func landmarkInAreaSatisfy(landmarkInArea: LandmarkInArea, poseMap: PoseMap, frameSize: Point2D) -> Bool? {
        return landmarkInArea.satisfy(poseMap: poseMap, frameSize: frameSize)
    }
    
    func lengthToStateSatisfy(relativeDistance: LandmarkToState, stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool? {
        return relativeDistance.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap)
    }
    
    func objectToLandmarkSatisfy(objectToLandmark: ObjectToLandmark, poseMap: PoseMap, object: Observation) -> Bool {
        return objectToLandmark.satisfy(poseMap: poseMap, object: object)
    }
    
    func objectToObjectSatisfy(objectToObject: ObjectToObject, poseMap: PoseMap, object: Observation, targetObject: Observation) -> Bool {
        return objectToObject.satisfy(poseMap: poseMap, fromObject: object, toObject: targetObject)
    }
    
    func objectToSelfSatisfy(objectToSelf: ObjectToSelf, stateTimeHistory: [StateTime], object: Observation) -> Bool {
        return objectToSelf.satisfy(stateTimeHistory: stateTimeHistory, object: object)
    }
    
    func landmarkToSelfSatisfy(landmarkToSelf: LandmarkToSelf, stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool? {
        return landmarkToSelf.satisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap)
    }
    

    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D) -> (Bool, Set<Warning>) {
        // 单帧
        var lengthSatisfy: Bool? = true
        
        var angleSatisfy: Bool? = true
        
        var angleToLandmarkSegmentSatisfy: Bool? = true
        
        var landmarkInAreaSatisfy: Bool? = true
        
        // 多帧
        
        var lengthToStateSatisfy: Bool? = true
        // 物体相对于关节点
        
        
        var objectToLandmarkSatisfy: Bool? = true
        
        //物体相对物体
        var objectToObjectSatisfy: Bool? = true
        
        //物体相对自身最大位移
        var objectToSelfSatisfy: Bool? = true
        
        //关节相对自身最大位移
        var landmarkToSelfSatisfy: Bool? = true
        
        var warnings : Set<Warning> = []
        
        
        if let length = length {
            lengthSatisfy = self.lengthSatisfy(relativeDistance: length, poseMap: poseMap)
            let satisfyWarning = length.warning.triggeredWhenRuleMet
            if satisfyWarning && lengthSatisfy == true {
                warnings.insert(length.warning)
            }else if !satisfyWarning && lengthSatisfy == false {
                warnings.insert(length.warning)
            }
            
        }
        
        if let angleRange = angle {
            angleSatisfy = self.angleSatisfy(angleRange: angleRange, poseMap: poseMap)
            let satisfyWarning = angleRange.warning.triggeredWhenRuleMet
            
            if satisfyWarning && angleSatisfy == true {
                warnings.insert(angleRange.warning)
            }else if !satisfyWarning && angleSatisfy == false {
                warnings.insert(angleRange.warning)
            }
        }
        
        if let angleToLandmarkSegment = angleToLandmarkSegment {
            angleToLandmarkSegmentSatisfy = self.angleToLandmarkSatisfy(angleToLandmarkSegment: angleToLandmarkSegment, poseMap: poseMap)
            let satisfyWarning = angleToLandmarkSegment.warning.triggeredWhenRuleMet
            
            if satisfyWarning && angleToLandmarkSegmentSatisfy == true {
                warnings.insert(angleToLandmarkSegment.warning)
            }else if !satisfyWarning && angleToLandmarkSegmentSatisfy == false {
                warnings.insert(angleToLandmarkSegment.warning)
            }
            
        }
        
        if let landmarkInArea = landmarkInArea {
            landmarkInAreaSatisfy = self.landmarkInAreaSatisfy(landmarkInArea: landmarkInArea, poseMap: poseMap, frameSize: frameSize)
           
            
            let satisfyWarning = landmarkInArea.warning.triggeredWhenRuleMet
            
            if satisfyWarning && landmarkInAreaSatisfy == true {
                warnings.insert(landmarkInArea.warning)
            }else if !satisfyWarning && landmarkInAreaSatisfy == false {
                warnings.insert(landmarkInArea.warning)
            }
        }
        
        
        if let length = lengthToState {
            lengthToStateSatisfy = self.lengthToStateSatisfy(relativeDistance: length, stateTimeHistory: stateTimeHistory, poseMap: poseMap)
            let satisfyWarning = length.warning.triggeredWhenRuleMet
            if satisfyWarning && lengthToStateSatisfy == true {
                warnings.insert(length.warning)
            }else if !satisfyWarning && lengthToStateSatisfy == false {
                warnings.insert(length.warning)
            }
        }
        
        
        if let objectTolandmark = objectPositionToLandmark {
            if let object = object {
                objectToLandmarkSatisfy = self.objectToLandmarkSatisfy(objectToLandmark: objectTolandmark, poseMap: poseMap, object: object)
            } else {
                objectToLandmarkSatisfy = false
            }
            
            let satisfyWarning = objectTolandmark.warning.triggeredWhenRuleMet
            
            if satisfyWarning && objectToLandmarkSatisfy == true {
                warnings.insert(objectTolandmark.warning)
            }else if !satisfyWarning && objectToLandmarkSatisfy == false {
                warnings.insert(objectTolandmark.warning)
            }
        }
        
        if let objectToObject = objectPositionToObjectPosition {
            if let object = object, let targetObject = targetObject {
                objectToObjectSatisfy = self.objectToObjectSatisfy(objectToObject: objectToObject, poseMap: poseMap, object: object, targetObject: targetObject)
            } else {
                objectToObjectSatisfy = false
            }
            let satisfyWarning = objectToObject.warning.triggeredWhenRuleMet
            
            if satisfyWarning && objectToObjectSatisfy == true {
                warnings.insert(objectToObject.warning)
            }else if !satisfyWarning && objectToObjectSatisfy == false {
                warnings.insert(objectToObject.warning)
            }
        }
        
        if let objectToSelf = objectToSelf {
            if let object = object {
                objectToSelfSatisfy = self.objectToSelfSatisfy(objectToSelf: objectToSelf, stateTimeHistory: stateTimeHistory, object: object)
            } else {
                objectToSelfSatisfy = false
            }
            let satisfyWarning = objectToSelf.warning.triggeredWhenRuleMet
            
            if satisfyWarning && objectToSelfSatisfy == true {
                warnings.insert(objectToSelf.warning)
            }else if !satisfyWarning && objectToSelfSatisfy == false {
                warnings.insert(objectToSelf.warning)
            }
        }
        
        if let landmarkToSelf = landmarkToSelf {
            landmarkToSelfSatisfy = self.landmarkToSelfSatisfy(landmarkToSelf: landmarkToSelf, stateTimeHistory: stateTimeHistory, poseMap: poseMap)
            
            let satisfyWarning = landmarkToSelf.warning.triggeredWhenRuleMet
            if satisfyWarning && landmarkToSelfSatisfy == true {
                warnings.insert(landmarkToSelf.warning)
            }else if !satisfyWarning && landmarkToSelfSatisfy == false {
                warnings.insert(landmarkToSelf.warning)
            }
        }
        
        // 每个规则至少要包含一个条件 且所有条件都必须满足
        return (
            lengthSatisfy == true &&
            angleSatisfy == true &&
            angleToLandmarkSegmentSatisfy == true &&
            landmarkInAreaSatisfy == true &&
            lengthToStateSatisfy == true &&
            objectToLandmarkSatisfy == true &&
            objectToObjectSatisfy == true &&
            objectToSelfSatisfy == true &&
            landmarkToSelfSatisfy == true
            , warnings)
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
            print("---------------\(range) -- \(fromSegment.distanceYWithDirection/toSegment.distanceX)")
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
