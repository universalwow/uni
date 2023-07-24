
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

enum ExtremeDirection: String, Identifiable, CaseIterable, Codable {
    var id: String {
        self.rawValue
    }
    case MinX, MinY, MaxX, MaxY, MinX_MinY, MinX_MaxY, MaxX_MinY, MaxX_MaxY
}


enum RuleType: String, Identifiable, CaseIterable {
    var id: String {
        self.rawValue
    }
    case SCORE, VIOLATE
}

enum RuleClass: String, Identifiable, CaseIterable, Codable, Equatable {
    var id: String {
        self.rawValue
    }
    case LandmarkSegment, Landmark, Observation, FixedArea, DynamicArea, LandmarkMerge
}




//struct DynamicArea: Identifiable, Codable {
//    var id: String
//    var width: Double = 0.1
//    var heightToWidthRatio: Double = 1
//    //  左上，右下
//    var imageSize: Point2D
//    var limitedArea: [Point2D] = [Point2D.zero, Point2D.zero, Point2D.zero, Point2D.zero]
//    var area: [Point2D] = [Point2D.zero, Point2D.zero, Point2D.zero, Point2D.zero]
//
//}

struct DynamicAreaForSport: Identifiable, Codable {
    var id: String
    var width: Double = 0.1
    var heightToWidthRatio: Double = 1
    //  左上，右下
    var limitedArea: [Double] = [Double.zero, Double.zero,Double.zero,Double.zero]
    // 生成区域
    var area: [Point2D] = [Point2D.zero, Point2D.zero, Point2D.zero, Point2D.zero]
    
    var imageSize: Point2D?
    var content: String?
    var selected: Bool?
    
    var areaToRect: CGRect {
        CGRect(origin: self.area[0].cgPoint,
               size: CGSize(width: abs(self.area[2].x - self.area[0].x),
                            height: abs(self.area[2].y - self.area[0].y)))
    }

}

struct FixedAreaForSport: Identifiable, Codable {
    var id: String
    var width: Double = 0.1
    var heightToWidthRatio: Double = 1
    //  左上，右下
    var center: Point2D = Point2D.zero
    // 生成区域
    var area: [Point2D] = [Point2D.zero, Point2D.zero, Point2D.zero, Point2D.zero]
    
    var areaToRect: CGRect {
        CGRect(origin: self.area[0].cgPoint,
               size: CGSize(width: abs(self.area[2].x - self.area[0].x),
                            height: abs(self.area[2].y - self.area[0].y)))
    }
    
    var imageSize: Point2D?
    var content: String?
    var selected: Bool? 
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
        
        if stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) == nil {
            return true
        }
        
        let fromLandmark = self.fromLandmarkToAxis.landmark.landmarkType.landmark(poseMap: poseMap)
        
        // 依赖历史状态收集
        let toLandmark = self.fromLandmarkToAxis.landmark.landmarkType.landmark(
            poseMap: stateTimeHistory.last{ stateTime in
                stateTime.stateId == self.toStateId
            }!.poseMap
        )
        
        
        let fromSegment = LandmarkSegment(startLandmark: fromLandmark, endLandmark: toLandmark)
        let toSegment = self.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromLandmarkToAxis.axis,
                                                             toAxis: self.toLandmarkSegmentToAxis.axis,
                                                             range: self.range,
                                                             fromSegment: fromSegment,
                                                             toSegment: toSegment)
        return satisfyAndRatio.0
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


struct LandmarkToStateDistance: Identifiable, Codable {
    var id = UUID()
    var lowerBound:Double = 0
    var upperBound:Double = 0
    var toStateToggle: Bool? = false
    var toLastFrameToggle: Bool? = false
    var weight: Double? = 1
    
    
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
    
    var isRelativeToExtremeDirection = false
    var extremeDirection: ExtremeDirection = .MinX
    var defaultSatisfy: Bool? = true
    
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
    
    var reverseRange: Range<Double> {
        (-1 * upperBound)..<(-1 * lowerBound)
    }
    
    func satisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, lastPoseMap: PoseMap) -> Bool {
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmark = self.fromLandmarkToAxis.landmark.landmarkType.landmark(poseMap: poseMap)

            let toLandmark = ComplexRule.initLandmark(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmark: self.toLandmarkToAxis.landmark, toStateTime: toStateTime)
            
            
            let fromSegment = LandmarkSegment(startLandmark: fromLandmark, endLandmark: toLandmark)
            print("aaaa-\(fromSegment.startLandmark.id) 1\(fromSegment.startLandmark.position.x)/\(fromSegment.endLandmark.position.x) - \(stateTimeHistory.last!.stateId)")
            let toSegment = ComplexRule.initLandmarkSegment(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmarkSegment: toLandmarkSegmentToAxis.landmarkSegment, toStateTime: toStateTime)
//            self.toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
            if fromLandmark.isEmpty || toLandmark.isEmpty || toSegment.isEmpty {
                return false
            }
            
            let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromLandmarkToAxis.axis,
                                                                   toAxis: self.toLandmarkSegmentToAxis.axis,
                                                                   range: self.range,
                                                                   fromSegment: fromSegment,
                                                                   toSegment: toSegment)
            
            print("satisfy ------  \(satisfyAndRatio)")
            
            return satisfyAndRatio.0

            
        } else {
//            MARK: 默认为什么最好可以设置
            return defaultSatisfy ?? true
        }
    }
    
    func satisfyWithScore(stateTimeHistory: [StateTime], poseMap: PoseMap) -> (Bool,Double) {
        var score = 0.0
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmark = self.fromLandmarkToAxis.landmark.landmarkType.landmark(poseMap: poseMap)

            let toLandmark = ComplexRule.initLandmark(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmark: self.toLandmarkToAxis.landmark, toStateTime: toStateTime)
            
            let fromSegment = LandmarkSegment(startLandmark: fromLandmark, endLandmark: toLandmark)
            let toSegment = ComplexRule.initLandmarkSegment(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmarkSegment: toLandmarkSegmentToAxis.landmarkSegment, toStateTime: toStateTime)
            if fromLandmark.isEmpty || toSegment.isEmpty {
                return (false, score)
            }
            
            let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromLandmarkToAxis.axis,
                                                                   toAxis: self.toLandmarkSegmentToAxis.axis,
                                                                   range: self.range,
                                                                   fromSegment: fromSegment,
                                                                   toSegment: toSegment)
            if satisfyAndRatio.0 {
                score = ComplexRule.score(ratio: satisfyAndRatio.1, range: range)
            }
            
            return (satisfyAndRatio.0, score)

            
        } else {
//            MARK: 默认为什么最好可以设置
            return (defaultSatisfy ?? true, score)
        }
    }
    
    func satisfyWithRatio(stateTimeHistory: [StateTime], poseMap: PoseMap) -> (Bool,Double) {
        var score = 0.0
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmark = self.fromLandmarkToAxis.landmark.landmarkType.landmark(poseMap: poseMap)

            let toLandmark = ComplexRule.initLandmark(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmark: self.toLandmarkToAxis.landmark, toStateTime: toStateTime)
            
            let fromSegment = LandmarkSegment(startLandmark: fromLandmark, endLandmark: toLandmark)
            let toSegment = ComplexRule.initLandmarkSegment(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmarkSegment: toLandmarkSegmentToAxis.landmarkSegment, toStateTime: toStateTime)
            if fromLandmark.isEmpty || toSegment.isEmpty {
                return (false, score)
            }
            
//            let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromLandmarkToAxis.axis,
//                                                                   toAxis: self.toLandmarkSegmentToAxis.axis,
//                                                                   range: self.range,
//                                                                   fromSegment: fromSegment,
//                                                                   toSegment: toSegment)
//            score = satisfyAndRatio.1

            
            return ComplexRule.satisfyWithDirection(fromAxis: self.fromLandmarkToAxis.axis,
                                                    toAxis: self.toLandmarkSegmentToAxis.axis,
                                                    range: self.range,
                                                    fromSegment: fromSegment,
                                                    toSegment: toSegment)

            
        } else {
//            MARK: 默认为什么最好可以设置
            return (defaultSatisfy ?? true, score)
        }
    }
    
    func satisfyWithRatio2(stateTimeHistory: [StateTime], poseMap: PoseMap, lastPoseMap: PoseMap) -> (Bool,Double) {
        var score = 0.0
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmark = self.fromLandmarkToAxis.landmark.landmarkType.landmark(poseMap: poseMap)

            let toLandmark = self.toLandmarkToAxis.landmark.landmarkType.landmark(poseMap: lastPoseMap)

            let fromSegment = LandmarkSegment(startLandmark: fromLandmark, endLandmark: toLandmark)
            let toSegment = ComplexRule.initLandmarkSegment(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmarkSegment: toLandmarkSegmentToAxis.landmarkSegment, toStateTime: toStateTime)
            if fromLandmark.isEmpty || toSegment.isEmpty {
                return (false, score)
            }
            
//            let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromLandmarkToAxis.axis,
//                                                                   toAxis: self.toLandmarkSegmentToAxis.axis,
//                                                                   range: self.range,
//                                                                   fromSegment: fromSegment,
//                                                                   toSegment: toSegment)
//            score = satisfyAndRatio.1

            
            return ComplexRule.satisfyWithDirection(fromAxis: self.fromLandmarkToAxis.axis,
                                                    toAxis: self.toLandmarkSegmentToAxis.axis,
                                                    range: self.range,
                                                    fromSegment: fromSegment,
                                                    toSegment: toSegment)

            
        } else {
//            MARK: 默认为什么最好可以设置
            return (defaultSatisfy ?? true, score)
        }
    }
    
    
    
    
    func satisfyWithWeight(stateTimeHistory: [StateTime], poseMap: PoseMap, lastPoseMap: PoseMap) -> (Bool,Double) {
        var score = 0.0
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmark = self.fromLandmarkToAxis.landmark.landmarkType.landmark(poseMap: poseMap)

            let toLandmark = self.toLandmarkToAxis.landmark.landmarkType.landmark(poseMap: lastPoseMap)
            
            let fromSegment = LandmarkSegment(startLandmark: fromLandmark, endLandmark: toLandmark)
            let toSegment = ComplexRule.initLandmarkSegment(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmarkSegment: toLandmarkSegmentToAxis.landmarkSegment, toStateTime: toStateTime)
            if fromLandmark.isEmpty || toSegment.isEmpty {
                return (false, score)
            }
            
            let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromLandmarkToAxis.axis,
                                                                   toAxis: self.toLandmarkSegmentToAxis.axis,
                                                                   range: self.range,
                                                                   fromSegment: fromSegment,
                                                                   toSegment: toSegment)
            
            let reverseSatisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromLandmarkToAxis.axis,
                                                                   toAxis: self.toLandmarkSegmentToAxis.axis,
                                                                   range: self.reverseRange,
                                                                   fromSegment: fromSegment,
                                                                   toSegment: toSegment)
            if satisfyAndRatio.0 {
                score = weight!
            }
            
            if reverseSatisfyAndRatio.0 {
                score = -1 * weight!
            }
//            score = satisfyAndRatio.0 ? weight! : 0
            
            
            return (satisfyAndRatio.0, score)
            
        } else {
//            MARK: 默认为什么最好可以设置
            return (defaultSatisfy ?? true, score)
        }
        
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
            length = fromLandmarkToAxis.landmark.position.vector2d.distance(to: toLandmarkToAxis.landmark.position.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
            
        case (.XY, .Y):
            length = fromLandmarkToAxis.landmark.position.vector2d.distance(to: toLandmarkToAxis.landmark.position.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY
            
        case (.XY, .XY):
            length = fromLandmarkToAxis.landmark.position.vector2d.distance(to: toLandmarkToAxis.landmark.position.vector2d)
            bound = length/toLandmarkSegmentToAxis.landmarkSegment.distance
        }
        
        lowerBound = bound
        upperBound = bound
        
        
    }
    
}




struct LandmarkToStateAngle: Identifiable, Codable {
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
    var fromLandmark: Landmark
    
    var toLandmark: Landmark
    
    var warning:Warning
    
    var isRelativeToExtremeDirection = false
    var extremeDirection: ExtremeDirection = .MinX
    
    init(toStateId: Int, fromLandmark: Landmark, toLandmark: Landmark, warning: Warning) {
        self.toStateId = toStateId
        self.fromLandmark = fromLandmark
        self.toLandmark = toLandmark
        self.warning = warning
        
        initBound()
    }
    
    var range: Range<Double> {
        if lowerBound < upperBound {
            return lowerBound..<upperBound
        }else {
            return lowerBound..<(upperBound + 360)
        }
    }
    
    func satisfy(stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool {
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmark = self.fromLandmark.landmarkType.landmark(poseMap: poseMap)

            let toLandmark = ComplexRule.initLandmark(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmark: fromLandmark, toStateTime: toStateTime)
            
            let landmarkSegment = LandmarkSegment(startLandmark: toLandmark, endLandmark: fromLandmark)
            if landmarkSegment.isEmpty {
                return false
            }
            
            return range.contains(landmarkSegment.angle2d)

            
        } else {
            return true
        }
    }
    
    func satisfyWithScore(stateTimeHistory: [StateTime], poseMap: PoseMap) -> (Bool, Double) {
        var score = 0.0
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmark = self.fromLandmark.landmarkType.landmark(poseMap: poseMap)

            let toLandmark = ComplexRule.initLandmark(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmark: fromLandmark, toStateTime: toStateTime)
            
            let landmarkSegment = LandmarkSegment(startLandmark: toLandmark, endLandmark: fromLandmark)
            if landmarkSegment.isEmpty {
                return (false, score)
            }
            
            if range.contains(landmarkSegment.angle2d) {
                score = ComplexRule.score(ratio: landmarkSegment.angle2d, range: range)            }
            
            return (range.contains(landmarkSegment.angle2d), score)
            
        } else {
            return (true, score)
        }
    }
    
    mutating func initBound() {
        let fromSegment = LandmarkSegment(startLandmark: toLandmark, endLandmark: fromLandmark)
        let angle = fromSegment.angle2d
        self.lowerBound = angle
        self.upperBound = angle
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
        
        if [SportState.startState.id, SportState.readyState.id].contains(where: { id in
            id == toStateTime.stateId
            
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



struct ObjectToStateDistance: Identifiable, Codable {
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
    
    var fromPosition: ObjectPositionPoint {
        didSet {
            if fromPosition.id != oldValue.id ||
                fromPosition.position.id != oldValue.position.id || fromPosition.axis != oldValue.axis {
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
    
    
    var toLandmarkSegmentToAxis: LandmarkSegmentToAxis {
        didSet {
            if toLandmarkSegmentToAxis.axis.id != oldValue.axis.id ||
                toLandmarkSegmentToAxis.landmarkSegment.id != oldValue.landmarkSegment.id {
                initBound()
            }
            
        }
    }
    
    var warning:Warning
    
    var isRelativeToExtremeDirection = false
    var extremeDirection: ExtremeDirection = .MinX
    
    var isRelativeToObject: Bool = false {
        didSet {
            if isRelativeToObject != oldValue {
                initBound()
            }
        }
    }
    
    var object: Observation
    
    init(toStateId: Int, fromPosition: ObjectPositionPoint, toPosition: ObjectPositionPoint, toLandmarkSegmentToAxis: LandmarkSegmentToAxis, warning: Warning, object: Observation) {
        self.toStateId = toStateId
        self.fromPosition = fromPosition
        self.toPosition = toPosition
        self.toLandmarkSegmentToAxis = toLandmarkSegmentToAxis
        self.warning = warning
        self.object = object
        
        initBound()
    }
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    func satisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation) -> Bool {
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromObjectPoint = object.rect.pointOf(position: fromPosition.position).point2d
            
            let toObjectPoint = ComplexRule.initObjectPoint(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromPosition: fromPosition, toStateTime: toStateTime)
            
            let fromSegment = LandmarkSegment(startLandmark: Landmark(position: fromObjectPoint.point3D, landmarkType: LandmarkType.None), endLandmark: Landmark(position: toObjectPoint.point3D, landmarkType: LandmarkType.None))

            
            let toSegment = toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
            
            if fromSegment.isEmpty || toSegment.isEmpty {
                return false
            }
            if isRelativeToObject == true {
                return ComplexRule.satisfyWithDirectionRelativeToObject(fromAxis: self.fromPosition.axis, range: self.range, fromSegment: fromSegment, relativeTo: object.rect.height).0
            }
            
            let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromPosition.axis,
                                                                   toAxis: self.toLandmarkSegmentToAxis.axis,
                                                                   range: self.range,
                                                                   fromSegment: fromSegment,
                                                                   toSegment: toSegment)

            return satisfyAndRatio.0

            
        }else {
            return true
        }
    }
    
    func satisfyWithScore(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation) -> (Bool, Double) {
        
        var score = 0.0
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromObjectPoint = object.rect.pointOf(position: fromPosition.position).point2d
            
            let toObjectPoint = ComplexRule.initObjectPoint(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromPosition: fromPosition, toStateTime: toStateTime)
            
            let fromSegment = LandmarkSegment(startLandmark: Landmark(position: fromObjectPoint.point3D, landmarkType: LandmarkType.None), endLandmark: Landmark(position: toObjectPoint.point3D, landmarkType: LandmarkType.None))

            
            let toSegment = toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
            
            if fromSegment.isEmpty || toSegment.isEmpty {
                return (false, score)
            }
            if isRelativeToObject == true {
                let satisfyAndRatio = ComplexRule.satisfyWithDirectionRelativeToObject(fromAxis: self.fromPosition.axis, range: self.range, fromSegment: fromSegment, relativeTo: object.rect.height)
                
                if satisfyAndRatio.0 {
                    score = ComplexRule.score(ratio: satisfyAndRatio.1, range: range)
                }
                
                return (satisfyAndRatio.0, score)
            }
            
            let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromPosition.axis,
                                                                   toAxis: self.toLandmarkSegmentToAxis.axis,
                                                                   range: self.range,
                                                                   fromSegment: fromSegment,
                                                                   toSegment: toSegment)
            if satisfyAndRatio.0 {
                score = ComplexRule.score(ratio: satisfyAndRatio.1, range: range)
            }

            return (satisfyAndRatio.0, score)

            
        }else {
            return (true, score)
        }
    }
    
    private mutating func initBound() {
        
        var length = 0.0
        var relativeTo = 0.0
        
        
        
        switch (fromPosition.axis, toLandmarkSegmentToAxis.axis) {
        case (.X, .X):
            length = fromPosition.point.x - toPosition.point.x
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceX
            
        case (.X, .Y):
            length = fromPosition.point.x - toPosition.point.x
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceY
            
        case (.X, .XY):
            length = fromPosition.point.x - toPosition.point.x
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distance
            
        case (.Y, .X):
            length = fromPosition.point.y - toPosition.point.y
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceX
            
        case (.Y, .Y):
            length = fromPosition.point.y - toPosition.point.y
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceY
        case (.Y, .XY):
            length = fromPosition.point.y - toPosition.point.y
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distance
            
        case (.XY, .X):
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)

            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceX
            
        case (.XY, .Y):
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)

            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceY
            
        case (.XY, .XY):
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distance
        }
        
        if isRelativeToObject == true {
            relativeTo = object.rect.height
        }
        let bound = length/relativeTo
        
        lowerBound = bound
        upperBound = bound
        
        
    }
    
}



struct ObjectToStateAngle: Identifiable, Codable {
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
    
    var fromPosition: ObjectPositionPoint {
        didSet {
            if fromPosition.id != oldValue.id ||
                fromPosition.position.id != oldValue.position.id || fromPosition.axis != oldValue.axis {
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
    
    
    
    var warning:Warning
    
    var isRelativeToExtremeDirection = false
    var extremeDirection: ExtremeDirection = .MinX
    
    
    init(toStateId: Int, fromPosition: ObjectPositionPoint, toPosition: ObjectPositionPoint, warning: Warning) {
        self.toStateId = toStateId
        self.fromPosition = fromPosition
        self.toPosition = toPosition
        self.warning = warning
        
        initBound()
    }
    
    
    func satisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation) -> Bool {
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromObjectPoint = object.rect.pointOf(position: fromPosition.position).point2d

            let toObjectPoint = ComplexRule.initObjectPoint(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromPosition: fromPosition, toStateTime: toStateTime)
            
            
            let landmarkSegment = LandmarkSegment(startLandmark: Landmark(position: toObjectPoint.point3D, landmarkType: LandmarkType.None), endLandmark: Landmark(position: fromObjectPoint.point3D, landmarkType: LandmarkType.None))
            
            if landmarkSegment.isEmpty {
                return false
            }
            
            return range.contains(landmarkSegment.angle2d) || range.contains(landmarkSegment.angle2d + 360)

            
        }else {
            return true
        }
    }
    
    func satisfyWithScore(stateTimeHistory: [StateTime], poseMap: PoseMap, object: Observation) -> (Bool, Double) {
        var score = 0.0
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromObjectPoint = object.rect.pointOf(position: fromPosition.position).point2d

            let toObjectPoint = ComplexRule.initObjectPoint(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromPosition: fromPosition, toStateTime: toStateTime)
            
            
            let landmarkSegment = LandmarkSegment(startLandmark: Landmark(position: toObjectPoint.point3D, landmarkType: LandmarkType.None), endLandmark: Landmark(position: fromObjectPoint.point3D, landmarkType: LandmarkType.None))
            
            if landmarkSegment.isEmpty {
                return (false, score)
            }
            
            if range.contains(landmarkSegment.angle2d) {
                score = ComplexRule.score(ratio: landmarkSegment.angle2d, range: range)
            } else if range.contains(landmarkSegment.angle2d + 360) {
                score = ComplexRule.score(ratio: landmarkSegment.angle2d + 360, range: range)

            }
            
            return (range.contains(landmarkSegment.angle2d) || range.contains(landmarkSegment.angle2d + 360), score)

            
        }else {
            return (true, score)
        }
    }
    
    var range: Range<Double> {
        if lowerBound < upperBound {
            return lowerBound..<upperBound
        }else {
            return lowerBound..<(upperBound + 360)
        }
    }
    
 
    
    
    private mutating func initBound() {
        
        let angle = LandmarkSegment(startLandmark: Landmark(position: toPosition.point.point3D, landmarkType: .None),
                                    endLandmark: Landmark(position: fromPosition.point.point3D, landmarkType: .None)).angle2d
        
        lowerBound = angle
        upperBound = angle
        
        
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
    var axis: CoordinateAxis
}

struct ObjectToObject: Identifiable, Codable {
    
    var id = UUID()
    
    var lowerBound = 0.0
    var upperBound = 0.0
    
    var fromPosition: ObjectPositionPoint {
        didSet {
            if fromPosition.id != oldValue.id ||
                fromPosition.position.id != oldValue.position.id || fromPosition.axis != oldValue.axis {
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

    
    var toLandmarkSegmentToAxis: LandmarkSegmentToAxis {
        didSet {
            if toLandmarkSegmentToAxis.axis.id != oldValue.axis.id ||
                toLandmarkSegmentToAxis.landmarkSegment.id != oldValue.landmarkSegment.id {
                initBound()
            }
            
        }
    }
    
    var warning:Warning
    
    var isRelativeToObject: Bool = false {
        didSet {
            if isRelativeToObject != oldValue {
                initBound()
            }
        }
    }
    
    var object: Observation
    
    init(fromPosition:  ObjectPositionPoint, toPosition: ObjectPositionPoint,
         toLandmarkSegmentToAxis: LandmarkSegmentToAxis, warning: Warning, object: Observation) {

        self.fromPosition = fromPosition
        self.toPosition = toPosition
        self.toLandmarkSegmentToAxis = toLandmarkSegmentToAxis
        self.warning = warning
        self.object = object

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
        
        if fromSegment.isEmpty || toSegment.isEmpty {
            return false
        }
        
        if isRelativeToObject == true {
            return ComplexRule.satisfyWithDirectionRelativeToObject(fromAxis: self.fromPosition.axis, range: self.range, fromSegment: fromSegment, relativeTo: fromObject.rect.height).0
        }
        
        let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromPosition.axis, toAxis: self.toLandmarkSegmentToAxis.axis, range: self.range, fromSegment: fromSegment, toSegment: toSegment)
        
        return satisfyAndRatio.0
        
    }
    
    func satisfyWithScore(poseMap: PoseMap, fromObject: Observation, toObject: Observation) -> (Bool, Double) {
        
        var score = 0.0
        
        let fromObjectPosition = fromObject.rect.pointOf(position: self.fromPosition.position)
        let toObjectPosition = toObject.rect.pointOf(position: self.toPosition.position)

        
        let fromSegment = LandmarkSegment(startLandmark: Landmark(position: fromObjectPosition.point2d.point3D, landmarkType: LandmarkType.None), endLandmark: Landmark(position: toObjectPosition.point2d.point3D, landmarkType: LandmarkType.None))

        
        let toSegment = toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        if fromSegment.isEmpty || toSegment.isEmpty {
            return (false, score)
        }
        
        if isRelativeToObject == true {
            let satisfyAndRatio = ComplexRule.satisfyWithDirectionRelativeToObject(fromAxis: self.fromPosition.axis, range: self.range, fromSegment: fromSegment, relativeTo: fromObject.rect.height)
            
            if satisfyAndRatio.0 {
                score = ComplexRule.score(ratio: satisfyAndRatio.1, range: range)

            }
            
            return (satisfyAndRatio.0, score)
        }
        
        let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromPosition.axis, toAxis: self.toLandmarkSegmentToAxis.axis, range: self.range, fromSegment: fromSegment, toSegment: toSegment)
        if satisfyAndRatio.0 {
            score = ComplexRule.score(ratio: satisfyAndRatio.1, range: range)

        }
        
        return (satisfyAndRatio.0, score)
        
    }
    
    
    private mutating func initBound() {
        var length = 0.0
        var relativeTo = 0.0
        
        switch (self.fromPosition.axis, toLandmarkSegmentToAxis.axis) {
        case (.X, .X):
            length = fromPosition.point.x - toPosition.point.x
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceX
        case (.X, .Y):
            length = fromPosition.point.x - toPosition.point.x
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceY
            
        case (.X, .XY):
            length = fromPosition.point.x - toPosition.point.x
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distance
            
        case (.Y, .X):
            length = fromPosition.point.y - toPosition.point.y
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceX
            
        case (.Y, .Y):
            length = fromPosition.point.y - toPosition.point.y
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceY
            
        case (.Y, .XY):
            length = fromPosition.point.y - toPosition.point.y
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distance
            
        case (.XY, .X):
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceX
            
        case (.XY, .Y):
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceY
            
        case (.XY, .XY):
            
            length = fromPosition.point.vector2d.distance(to: toPosition.point.vector2d)
            relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distance
            
        }
        
        if isRelativeToObject == true {
            relativeTo = object.rect.height
        }
        let bound = length/relativeTo

        lowerBound = bound
        upperBound = bound
    }
}

struct ObjectToLandmark: Identifiable, Codable {
    var id = UUID()
    
    var lowerBound:Double = 0
    var upperBound:Double = 0
    

    
    var fromPosition: ObjectPositionPoint {
        didSet {
            if fromPosition.id != oldValue.id ||
                fromPosition.position.id != oldValue.position.id || fromPosition.axis.rawValue != oldValue.axis.rawValue {
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
    
    var isRelativeToObject: Bool = false {
        didSet {
            if isRelativeToObject != oldValue {
                initBound()
            }
        }
    }
    var object: Observation?
    
    var warning: Warning
    
    init(fromPosition: ObjectPositionPoint, toLandmark: Landmark, toLandmarkSegmentToAxis: LandmarkSegmentToAxis, warning: Warning, object: Observation) {
        self.fromPosition = fromPosition
        self.toLandmark = toLandmark
        self.toLandmarkSegmentToAxis = toLandmarkSegmentToAxis
        self.warning = warning
        self.object = object
        initBound()
    }
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(poseMap: PoseMap, object: Observation) -> Bool {
        
        let fromObjectPoint = object.rect.pointOf(position: self.fromPosition.position)
        let toLandmark = self.toLandmark.landmarkType.landmark(poseMap: poseMap)
        
        
        let fromSegment = LandmarkSegment(startLandmark: Landmark(position: fromObjectPoint.point2d.point3D, landmarkType: LandmarkType.None), endLandmark: toLandmark)
        
        
        let toSegment = toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        if fromSegment.isEmpty || toSegment.isEmpty {
            return false
        }
        
        if isRelativeToObject == true {
            return ComplexRule.satisfyWithDirectionRelativeToObject(fromAxis: self.fromPosition.axis, range: self.range, fromSegment: fromSegment, relativeTo: object.rect.height).0
        }
        
        let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromPosition.axis, toAxis: self.toLandmarkSegmentToAxis.axis, range: self.range, fromSegment: fromSegment, toSegment: toSegment)
        
        return satisfyAndRatio.0
        
    }
    
    func satisfyWithScore(poseMap: PoseMap, object: Observation) -> (Bool,Double) {
        
        let fromObjectPoint = object.rect.pointOf(position: self.fromPosition.position)
        let toLandmark = self.toLandmark.landmarkType.landmark(poseMap: poseMap)
        
        var score = 0.0
        
        let fromSegment = LandmarkSegment(startLandmark: Landmark(position: fromObjectPoint.point2d.point3D, landmarkType: LandmarkType.None), endLandmark: toLandmark)
        
        
        let toSegment = toLandmarkSegmentToAxis.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        if fromSegment.isEmpty || toSegment.isEmpty {
            return (false, score)
        }
        
        if isRelativeToObject == true {
            
            let satisfyAndRatio = ComplexRule.satisfyWithDirectionRelativeToObject(fromAxis: self.fromPosition.axis, range: self.range, fromSegment: fromSegment, relativeTo: object.rect.height)
            
            if satisfyAndRatio.0 {
                score = ComplexRule.score(ratio: satisfyAndRatio.1, range: range)
            }
            
            return (satisfyAndRatio.0, score)
        }
        
        let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.fromPosition.axis, toAxis: self.toLandmarkSegmentToAxis.axis, range: self.range, fromSegment: fromSegment, toSegment: toSegment)
        if satisfyAndRatio.0 {
            score = ComplexRule.score(ratio: satisfyAndRatio.1, range: range)
        }
        
        return (satisfyAndRatio.0, score)
        
    }
    
    private mutating func initBound() {
        var length = 0.0
        var relativeTo = 0.0
        
        
        switch (self.fromPosition.axis, toLandmarkSegmentToAxis.axis) {
            case (.X, .X):
                length = fromPosition.point.x - toLandmark.position.x
                relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceX
            case (.X, .Y):
                length = fromPosition.point.x - toLandmark.position.x
                relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceY
                
            case (.X, .XY):
                length = fromPosition.point.x - toLandmark.position.x
                relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distance
                
            case (.Y, .X):
                length = fromPosition.point.y - toLandmark.position.y
                relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceX
                
            case (.Y, .Y):
                length = fromPosition.point.y - toLandmark.position.y
                relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceY
                
            case (.Y, .XY):
                length = fromPosition.point.y - toLandmark.position.y
                relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distance
                
            case (.XY, .X):
                length = fromPosition.point.vector2d.distance(to: toLandmark.position.vector2d)
                relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceX
                
            case (.XY, .Y):
                length = fromPosition.point.vector2d.distance(to: toLandmark.position.vector2d)
                relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distanceY
                
            case (.XY, .XY):
                length = fromPosition.point.vector2d.distance(to: toLandmark.position.vector2d)
                relativeTo = toLandmarkSegmentToAxis.landmarkSegment.distance
            
        }
        
        
        if isRelativeToObject == true, let object = object {
            relativeTo = object.rect.height
        }
        let bound = length/relativeTo

        lowerBound = bound
        upperBound = bound
    }
    
}


struct LandmarkSegmentLength: Identifiable, Codable {
    var id = UUID()
    
    var lowerBound:Double = 0
    var upperBound:Double = 0
    
    var standard:Double? = 0.0

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
        
        if fromSegment.isEmpty || toSegment.isEmpty {
            return false
        }
        
        let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.from.axis,
                                                               toAxis: self.to.axis,
                                                               range: self.range,
                                                               fromSegment: fromSegment,
                                                               toSegment: toSegment)
        
        return satisfyAndRatio.0
    }
    
    func satisfyWithScore(poseMap: PoseMap) -> (Bool, Double) {
        
        var score = 0.0
        let fromSegment = self.from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        let toSegment = self.to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        if fromSegment.isEmpty || toSegment.isEmpty {
            return (false, score)
        }
        
//        let _standard = standard!
        
        let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.from.axis,
                                                               toAxis: self.to.axis,
                                                               range: self.range,
                                                               fromSegment: fromSegment,
                                                               toSegment: toSegment)
        
        if satisfyAndRatio.0 {
            score = ComplexRule.score(ratio: satisfyAndRatio.1, range: range)
            
        }
        
        return (satisfyAndRatio.0, score)

    }
    
 
    
    private mutating func initBound() {
        let bound = ComplexRule.initBound(fromAxis: from.axis, toAxis: to.axis, fromSegment: from.landmarkSegment, toSegment: to.landmarkSegment)
        lowerBound = bound
        upperBound = bound
        standard = bound
    }
    
}

struct AngleToLandmarkSegment: Identifiable, Codable {
    
    var id = UUID()
    var lowerBound:Double = 0
    var upperBound:Double = 0
    var standard:Double? = 0.0
    
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
        
        if fromSegment.isEmpty || toSegment.isEmpty {
            return false
        }
        
        return range.contains(fromSegment.angle2d - toSegment.angle2d) || range.contains(fromSegment.angle2d - toSegment.angle2d + 360) || range.contains(fromSegment.angle2d - toSegment.angle2d - 360)
    }

    
    func satisfyWithScore(poseMap: PoseMap) -> (Bool, Double) {
        let _satisfy = self.satisfy(poseMap: poseMap)
        var score = 0.0
//        let _standard = standard!
        if _satisfy {
            
            let fromAngle = self.from.landmarkSegmentType.landmarkSegment(poseMap: poseMap).angle2d
            let toAngle = self.to.landmarkSegmentType.landmarkSegment(poseMap: poseMap).angle2d
            
            let angle = fromAngle - toAngle
            
            if range.contains(angle) {
                score = ComplexRule.score(ratio: angle, range: range)
            } else if range.contains(angle + 360) {
                score = ComplexRule.score(ratio: angle + 360, range: range)

            } else if range.contains(angle - 360) {
                score = ComplexRule.score(ratio: angle - 360, range: range)

            }
        }
        
        return (_satisfy, score)

        
    }
    
    private mutating func initBound() {
        let bound = from.angle2d - to.angle2d
        lowerBound = bound
        upperBound = bound
        standard = bound
        
    }
}

struct LandmarkSegmentAngle: Identifiable, Codable {
    var id = UUID()
    var lowerBound = 0.0
    var upperBound = 0.0
    
    var standard:Double? = 0.0
    
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
    
    var range: Range<Double> {
        if lowerBound < upperBound {
            return lowerBound..<upperBound
        }else {
            return lowerBound..<(upperBound + 360)
        }
    }
    
    func satisfy(poseMap: PoseMap) -> Bool {
        let landmarkSegment = landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        if landmarkSegment.isEmpty {
            return false
        }
//        print("angle range - \(range) - \(Int(landmarkSegment.angle2d))")
        return range.contains(landmarkSegment.angle2d) || range.contains(landmarkSegment.angle2d + 360)
    }
    
    mutating func initBound() {
        let angle = landmarkSegment.angle2d
        self.lowerBound = angle
        self.upperBound = angle
        self.standard = angle
    }
    
//    func satisfyWithScore(poseMap: PoseMap) -> (Bool, Double) {
//        let _satisfy = self.satisfy(poseMap: poseMap)
//        var score = 0.0
//        let _standard = standard!
//        if _satisfy {
//
//            let angle = landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).angle2d
//            if lowerBound > upperBound {
////                情况太多，懒得区分，大概写法是可靠的，情况非常特殊
//                score = [1 - (angle - _standard)/(upperBound + 360 - _standard),
//                         1 - (angle + 360 - _standard)/(upperBound + 360 - _standard),
//                         1 - (angle - _standard)/(upperBound - _standard),
//
//                         1 - (_standard - angle)/(_standard - lowerBound),
//                         1 - (_standard + 360 - angle)/(_standard + 360 - lowerBound),
//                         1 - (_standard - angle)/(_standard + 360 - lowerBound)
//                ].filter({ _score in
//                    return _score >= 0 && _score <= 1
//                }).max() ?? 0.5
//
//
//            }else {
//                if angle > _standard {
//                    score = 1.0 - (angle - _standard)/(upperBound - _standard)
//                } else {
//                    score = 1.0 - (_standard - angle)/(_standard - lowerBound)
//                }
//            }
//        }
//
//        return (_satisfy, score)
//
//
//    }
    
    func satisfyWithScore(poseMap: PoseMap) -> (Bool, Double) {
        let _satisfy = self.satisfy(poseMap: poseMap)
        var score = 0.0
//        let _standard = standard!
        if _satisfy {
            
            let angle = landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).angle2d
            
            if range.contains(angle) {
                score = ComplexRule.score(ratio: angle, range: range)
            } else if range.contains(angle + 360) {
                score = ComplexRule.score(ratio: angle + 360, range: range)
                
            }
        }
        
        return (_satisfy, score)

        
    }
    
    
}

struct LandmarkSegmentToStateAngle: Identifiable, Codable {
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
    var fromLandmarkSegment: LandmarkSegment
    
    var toLandmarkSegment: LandmarkSegment
    
    var warning:Warning
    
    var isRelativeToExtremeDirection = false
    var extremeDirection: ExtremeDirection = .MinX
    
    init(toStateId: Int, fromLandmarkSegment: LandmarkSegment, toLandmarkSegment: LandmarkSegment, warning: Warning) {
        self.toStateId = toStateId
        self.fromLandmarkSegment = fromLandmarkSegment
        self.toLandmarkSegment = toLandmarkSegment
        self.warning = warning
        
        initBound()
    }
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool {
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmarkSegment = self.toLandmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
          
            let toLandmarkSegment = ComplexRule.initLandmarkSegment(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmarkSegment: self.toLandmarkSegment, toStateTime: toStateTime)
            
            if fromLandmarkSegment.isEmpty || toLandmarkSegment.isEmpty {
                return false
            }
            
            
            
            
            return range.contains(fromLandmarkSegment.angle2d - toLandmarkSegment.angle2d) || range.contains(fromLandmarkSegment.angle2d - toLandmarkSegment.angle2d + 360) || range.contains(fromLandmarkSegment.angle2d - toLandmarkSegment.angle2d - 360)

            
        } else {
            return true
        }
    }
    
    
    func satisfyWithScore(stateTimeHistory: [StateTime], poseMap: PoseMap) -> (Bool, Double) {
        
        var score = 0.0
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmarkSegment = self.toLandmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
          
            let toLandmarkSegment = ComplexRule.initLandmarkSegment(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmarkSegment: self.toLandmarkSegment, toStateTime: toStateTime)
            
            if fromLandmarkSegment.isEmpty || toLandmarkSegment.isEmpty {
                return (false, score)
            }
            
            let angle = fromLandmarkSegment.angle2d - toLandmarkSegment.angle2d
            
            if range.contains(angle) {
                score = ComplexRule.score(ratio: angle, range: range)
            } else if range.contains(angle + 360) {
                score = ComplexRule.score(ratio: angle + 360, range: range)

            } else if range.contains(angle - 360) {
                score = ComplexRule.score(ratio: angle-360, range: range)

            }
            
            return (range.contains(angle) || range.contains(angle + 360) || range.contains(angle - 360), score)

            
        } else {
            return (true, score)
        }
    }
    
    mutating func initBound() {
        
        let angle = fromLandmarkSegment.angle2d - toLandmarkSegment.angle2d
        self.lowerBound = angle
        self.upperBound = angle
    }
    
}


struct LandmarkSegmentToStateDistance: Identifiable, Codable {
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
    var fromAxis: CoordinateAxis {
        didSet {
            if fromAxis.rawValue != oldValue.rawValue {
                initBound()
            }
        }
    }
    var fromLandmarkSegment: LandmarkSegment
    
    var toLandmarkSegment: LandmarkSegment
    
    var warning:Warning
    
    var isRelativeToExtremeDirection = false
    var extremeDirection: ExtremeDirection = .MinX
    
    init(fromAxis: CoordinateAxis, toStateId: Int, fromLandmarkSegment: LandmarkSegment, toLandmarkSegment: LandmarkSegment, warning: Warning) {
        self.fromAxis = fromAxis
        self.toStateId = toStateId
        self.fromLandmarkSegment = fromLandmarkSegment
        self.toLandmarkSegment = toLandmarkSegment
        self.warning = warning
        
        initBound()
    }
    
    var range: Range<Double> {
        lowerBound..<upperBound
    }
    
    
    func satisfy(stateTimeHistory: [StateTime], poseMap: PoseMap) -> Bool {
        
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmarkSegment = self.toLandmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)

            
            let toLandmarkSegment = ComplexRule.initLandmarkSegment(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmarkSegment: self.toLandmarkSegment, toStateTime: toStateTime)
            
            
            if fromLandmarkSegment.isEmpty || toLandmarkSegment.isEmpty {
                return false
            }
            
            
            return ComplexRule.satisfyWithDirection2(fromAxis: fromAxis, toAxis: fromAxis, range: range, fromSegment: fromLandmarkSegment, toSegment: toLandmarkSegment).0


            
        } else {
            return true
        }
    }
    
    
    func satisfyWithScore(stateTimeHistory: [StateTime], poseMap: PoseMap) -> (Bool, Double) {
        var score = 0.0
        if let toStateTime = stateTimeHistory.last(where: { stateTime in
            stateTime.stateId == self.toStateId
        }) {
            
            let fromLandmarkSegment = self.toLandmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)

            let toLandmarkSegment = ComplexRule.initLandmarkSegment(isRelativeToExtremeDirection: isRelativeToExtremeDirection, extremeDirection: extremeDirection, fromLandmarkSegment: self.toLandmarkSegment, toStateTime: toStateTime)
            
            
            if fromLandmarkSegment.isEmpty || toLandmarkSegment.isEmpty {
                return (false, score)
            }
            
            let satisfyAndRatio = ComplexRule.satisfyWithDirection2(fromAxis: fromAxis, toAxis: fromAxis, range: range, fromSegment: fromLandmarkSegment, toSegment: toLandmarkSegment)
            
            
            if satisfyAndRatio.0 {
                score = ComplexRule.score(ratio: satisfyAndRatio.1, range: range)

            }
            
            return (satisfyAndRatio.0, score)
            
        } else {
            return (true, score)
        }
    }
    
    private mutating func initBound() {
        var bound = 0.0
        switch fromAxis {
        case .X:
            bound = fromLandmarkSegment.distanceXWithDirection/toLandmarkSegment.distanceXWithDirection
        case .Y:
            bound = fromLandmarkSegment.distanceYWithDirection/toLandmarkSegment.distanceYWithDirection

        case .XY:
            bound = fromLandmarkSegment.distance/toLandmarkSegment.distance
        }
        lowerBound = bound
        upperBound = bound
    }
    
}



struct DistanceToLandmark: Identifiable, Codable {
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
        
        
        
        if fromSegment.isEmpty || toSegment.isEmpty {
            return false
        }
        
        let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.from.axis,
                                                               toAxis: self.to.axis,
                                                               range: self.range,
                                                               fromSegment: fromSegment,
                                                               toSegment: toSegment)
        
        return satisfyAndRatio.0
    }
    
    func satisfyWithScore(poseMap: PoseMap) -> (Bool, Double) {
        
        var score = 0.0
        let fromSegment = self.from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        let toSegment = self.to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        
        
        if fromSegment.isEmpty || toSegment.isEmpty {
            return (false, score)
        }
        
        let satisfyAndRatio = ComplexRule.satisfyWithDirection(fromAxis: self.from.axis,
                                                               toAxis: self.to.axis,
                                                               range: self.range,
                                                               fromSegment: fromSegment,
                                                               toSegment: toSegment)
        
        
        
        if satisfyAndRatio.0 {
            score = ComplexRule.score(ratio: satisfyAndRatio.1, range: range)
        }
        return (satisfyAndRatio.0, score)
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


struct AngleToLandmark: Identifiable, Codable {
    var id = UUID()
    var lowerBound = 0.0
    var upperBound = 0.0
    var fromLandmark: Landmark
    var toLandmark: Landmark {
        didSet {
            if oldValue.id != toLandmark.id {
                initBound()
            }
        }
    }
    
    var landmarkSegment: LandmarkSegment {
        LandmarkSegment(startLandmark: toLandmark, endLandmark: fromLandmark)
    }
    var warning:Warning

    init(fromLandmark: Landmark, toLandmark: Landmark, warning: Warning) {
        
        self.fromLandmark = fromLandmark
        self.toLandmark = toLandmark
        self.warning = warning
        initBound()
    }
    
    var range: Range<Double> {
        if lowerBound < upperBound {
            return lowerBound..<upperBound
        }else {
            return lowerBound..<(upperBound + 360)
        }
    }
    
    func satisfy(poseMap: PoseMap) -> Bool {
        let landmarkSegment = landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap)
        
        if landmarkSegment.isEmpty {
            return false
        }
        
//        print("angle range - \(range) - \(Int(landmarkSegment.angle2d))")
        return range.contains(landmarkSegment.angle2d) || range.contains(landmarkSegment.angle2d + 360)
    }
    
    func satisfyWithScore(poseMap: PoseMap) -> (Bool, Double) {
        let _satisfy = self.satisfy(poseMap: poseMap)
        var score = 0.0
//        let _standard = standard!
        if _satisfy {
            
            let angle = landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).angle2d
            
            if range.contains(angle) {
                score = ComplexRule.score(ratio: angle, range: range)
            } else if range.contains(angle + 360) {
                score = ComplexRule.score(ratio: angle + 360, range: range)
            }
            
        }
        
        return (_satisfy, score)

        
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
    
    var isDynamicArea: Bool?
    var width: Double?
    var heightToWidthRatio: Double?
    //  左上，右下
    var limitedArea: [Point2D]?

    
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


extension LandmarkInAreaForAreaRule {
    
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

struct LandmarkInAreaForAreaRule: Identifiable, Codable {
    var id = UUID()
    var areaId: String
    var landmark: Landmark
    var imageSize:Point2D
    
    //  左上角 顺时针
    var area: [Point2D]
    
    var warning:Warning
    
    init(areaId: String, landmark: Landmark, imageSize: Point2D, warning: Warning, area: [Point2D]) {
        self.areaId = areaId
        self.landmark = landmark
        self.imageSize = imageSize
        self.warning = warning
        self.area = area
    }
    
    func satisfy(poseMap: PoseMap, frameSize: Point2D) -> Bool {
        let landmarkPoint = poseMap[landmark.landmarkType]!
        if landmarkPoint.isEmpty {
            return false
        }
        let path = self.path(frameSize: frameSize)
        return path.contains(landmarkPoint.vector2d.toCGPoint)
    }
    
    func satisfyWithScore(poseMap: PoseMap, frameSize: Point2D) -> (Bool, Double) {
        var score = 0.0
        let landmarkPoint = poseMap[landmark.landmarkType]!
        if landmarkPoint.isEmpty {
            return (false, score)
        }
        
        let path = self.path(frameSize: frameSize)
        
        if path.contains(landmarkPoint.vector2d.toCGPoint) {
            score = 1.0
        }
        
        return (path.contains(landmarkPoint.vector2d.toCGPoint), score)
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
    
    static func initBound(fromAxis: CoordinateAxis, toAxis: CoordinateAxis, fromSegment: LandmarkSegment, toSegment: LandmarkSegment) -> Double {
        var ratio = 0.0
        switch (fromAxis, toAxis) {
        case (.X, .X):
            ratio = fromSegment.distanceXWithDirection/toSegment.distanceX
            print("aaaa-\(fromSegment.startLandmark.id) \(fromSegment.startLandmark.position.x)/\(fromSegment.endLandmark.position.x) - \(toSegment.distanceXWithDirection)")
        case (.X, .Y):
            ratio = fromSegment.distanceXWithDirection/toSegment.distanceY

            
        case (.X, .XY):
            ratio = fromSegment.distanceXWithDirection/toSegment.distance

            // from Y
            
        case (.Y, .X):
            ratio = fromSegment.distanceYWithDirection/toSegment.distanceX
            
        case (.Y, .Y):
            ratio = fromSegment.distanceYWithDirection/toSegment.distanceY
            
        case (.Y, .XY):
            ratio = fromSegment.distanceYWithDirection/toSegment.distance
            // from XY
            
        case (.XY, .X) :
            ratio = fromSegment.distance/toSegment.distanceX
            
        case (.XY, .Y):
            ratio = fromSegment.distance/toSegment.distanceY
            
        case (.XY, .XY):
            ratio = fromSegment.distance/toSegment.distance
        }
        return ratio
    }
    
    
    static func satisfyWithDirection(fromAxis: CoordinateAxis, toAxis: CoordinateAxis, range: Range<Double>, fromSegment: LandmarkSegment, toSegment: LandmarkSegment) -> (Bool, Double) {
        
        let ratio = initBound(fromAxis: fromAxis, toAxis: toAxis, fromSegment: fromSegment, toSegment: toSegment)
        
        return (range.contains(ratio), ratio)
    }
    
    static func initObjectPoint(isRelativeToExtremeDirection: Bool, extremeDirection: ExtremeDirection, fromPosition: ObjectPositionPoint, toStateTime: StateTime) -> Point2D {
        var toObjectPoint = Point2D.zero

        if isRelativeToExtremeDirection {
            switch extremeDirection {
                
                case .MinX:
                toObjectPoint = toStateTime.dynamicObjectsMaps[fromPosition.id]!.minX.rect.pointOf(position: fromPosition.position).point2d
                case .MinY:
                toObjectPoint = toStateTime.dynamicObjectsMaps[fromPosition.id]!.minY.rect.pointOf(position: fromPosition.position).point2d
                case .MaxX:
                toObjectPoint = toStateTime.dynamicObjectsMaps[fromPosition.id]!.maxX.rect.pointOf(position: fromPosition.position).point2d
                case .MaxY:
                toObjectPoint = toStateTime.dynamicObjectsMaps[fromPosition.id]!.maxY.rect.pointOf(position: fromPosition.position).point2d

                case .MinX_MinY:
                toObjectPoint.x = toStateTime.dynamicObjectsMaps[fromPosition.id]!.minX.rect.pointOf(position: fromPosition.position).point2d.x
                
                toObjectPoint.y = toStateTime.dynamicObjectsMaps[fromPosition.id]!.minY.rect.pointOf(position: fromPosition.position).point2d.y

                case .MinX_MaxY:
                toObjectPoint.x = toStateTime.dynamicObjectsMaps[fromPosition.id]!.minX.rect.pointOf(position: fromPosition.position).point2d.x
                
                toObjectPoint.y = toStateTime.dynamicObjectsMaps[fromPosition.id]!.maxY.rect.pointOf(position: fromPosition.position).point2d.y

                case .MaxX_MinY:
                toObjectPoint.x = toStateTime.dynamicObjectsMaps[fromPosition.id]!.maxX.rect.pointOf(position: fromPosition.position).point2d.x
                
                toObjectPoint.y = toStateTime.dynamicObjectsMaps[fromPosition.id]!.minY.rect.pointOf(position: fromPosition.position).point2d.y

                case .MaxX_MaxY:
                toObjectPoint.x = toStateTime.dynamicObjectsMaps[fromPosition.id]!.maxX.rect.pointOf(position: fromPosition.position).point2d.x
                
                toObjectPoint.y = toStateTime.dynamicObjectsMaps[fromPosition.id]!.maxY.rect.pointOf(position: fromPosition.position).point2d.y

                }
            
        }else {
            toObjectPoint = toStateTime.object!.rect.pointOf(position: fromPosition.position).point2d
        }
        
        return toObjectPoint
    }
    
    static func initLandmark(isRelativeToExtremeDirection: Bool, extremeDirection: ExtremeDirection, fromLandmark: Landmark, toStateTime: StateTime) -> Landmark {
        var toLandmark = Landmark(position: Point3D.zero, landmarkType: fromLandmark.landmarkType)

        if isRelativeToExtremeDirection {
            switch extremeDirection {
                
                case .MinX:
                    toLandmark.position = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.minX
                case .MinY:
                    toLandmark.position = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.minY

                case .MaxX:
                    toLandmark.position = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.maxX

                case .MaxY:
                    toLandmark.position = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.maxY
                

                case .MinX_MinY:
                    toLandmark.position.x = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.minX.x
                    toLandmark.position.y = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.minY.y

                case .MinX_MaxY:
                    toLandmark.position.x = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.minX.x
                    toLandmark.position.y = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.maxY.y

                case .MaxX_MinY:
                    toLandmark.position.x = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.maxX.x
                    toLandmark.position.y = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.minY.y

                case .MaxX_MaxY:
                    toLandmark.position.x = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.maxX.x
                    toLandmark.position.y = toStateTime.dynamicPoseMaps[fromLandmark.landmarkType]!.maxY.y

                }
            
        }else {
            toLandmark = fromLandmark.landmarkType.landmark(
                poseMap: toStateTime.poseMap
            )
        }
        
        return toLandmark
    }
    
    static func initLandmarkSegment(isRelativeToExtremeDirection: Bool, extremeDirection: ExtremeDirection, fromLandmarkSegment: LandmarkSegment, toStateTime: StateTime) -> LandmarkSegment {
        
        var toLandmarkSegment = LandmarkSegment(
            startLandmark: Landmark(position: Point3D.zero, landmarkType: fromLandmarkSegment.startLandmark.landmarkType),
            endLandmark: Landmark(position: Point3D.zero, landmarkType: fromLandmarkSegment.endLandmark.landmarkType)
        )
        
        if isRelativeToExtremeDirection {
            switch extremeDirection {
                
                case .MinX:
                    toLandmarkSegment.startLandmark.position = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.minX
                    toLandmarkSegment.endLandmark.position = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.minX

                case .MinY:
                    toLandmarkSegment.startLandmark.position = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.minY
                    toLandmarkSegment.endLandmark.position = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.minY

                case .MaxX:
                    toLandmarkSegment.startLandmark.position = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.maxX
                    toLandmarkSegment.endLandmark.position = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.maxX

                case .MaxY:
                    toLandmarkSegment.startLandmark.position = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.maxY
                    toLandmarkSegment.endLandmark.position = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.maxY
                

                case .MinX_MinY:
                    toLandmarkSegment.startLandmark.position.x = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.minX.x
                    toLandmarkSegment.startLandmark.position.y = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.minY.y
                    
                    toLandmarkSegment.endLandmark.position.x = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.minX.x
                    toLandmarkSegment.endLandmark.position.y = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.minY.y



                case .MinX_MaxY:
                    toLandmarkSegment.startLandmark.position.x = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.minX.x
                    toLandmarkSegment.startLandmark.position.y = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.maxY.y
                    
                    toLandmarkSegment.endLandmark.position.x = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.minX.x
                    toLandmarkSegment.endLandmark.position.y = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.maxY.y


                case .MaxX_MinY:
                
                    toLandmarkSegment.startLandmark.position.x = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.maxX.x
                    toLandmarkSegment.startLandmark.position.y = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.minY.y
                    
                    toLandmarkSegment.endLandmark.position.x = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.maxX.x
                    toLandmarkSegment.endLandmark.position.y = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.minY.y



                case .MaxX_MaxY:
                    toLandmarkSegment.startLandmark.position.x = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.maxX.x
                    toLandmarkSegment.startLandmark.position.y = toStateTime.dynamicPoseMaps[toLandmarkSegment.startLandmark.landmarkType]!.maxY.y
                    
                    toLandmarkSegment.endLandmark.position.x = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.maxX.x
                    toLandmarkSegment.endLandmark.position.y = toStateTime.dynamicPoseMaps[toLandmarkSegment.endLandmark.landmarkType]!.maxY.y


            }
            
        }else {
            
            toLandmarkSegment = toLandmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: toStateTime.poseMap)
        }
        
        return toLandmarkSegment
    }
    
    
    static func initBoundWithDirection2(fromAxis: CoordinateAxis, toAxis: CoordinateAxis, fromSegment: LandmarkSegment, toSegment: LandmarkSegment) -> Double {
        var ratio = 0.0
        switch (fromAxis, toAxis) {
        case (.X, .X):
            print("aaaa \(fromSegment.startLandmark.position.x)/\(fromSegment.endLandmark.position.x) - \(toSegment.distanceXWithDirection)")
            ratio = fromSegment.distanceXWithDirection/toSegment.distanceXWithDirection
            
            
        case (.X, .Y):
            ratio =  fromSegment.distanceXWithDirection/toSegment.distanceYWithDirection
            
        case (.X, .XY):
            ratio = fromSegment.distanceXWithDirection/toSegment.distance

            
            // from Y
            
        case (.Y, .X):
            ratio = fromSegment.distanceYWithDirection/toSegment.distanceXWithDirection
            
        case (.Y, .Y):
            ratio = fromSegment.distanceYWithDirection/toSegment.distanceYWithDirection
            
        case (.Y, .XY):
            ratio = fromSegment.distanceYWithDirection/toSegment.distance
            
            // from XY
            
        case (.XY, .X) :
            ratio = fromSegment.distance/toSegment.distanceXWithDirection
            
        case (.XY, .Y):
            ratio = fromSegment.distance/toSegment.distanceYWithDirection
            
        case (.XY, .XY):
            ratio = fromSegment.distance/toSegment.distance
        }
        
        return ratio
    }
    
    
    static func satisfyWithDirection2(fromAxis: CoordinateAxis, toAxis: CoordinateAxis, range: Range<Double>, fromSegment: LandmarkSegment, toSegment: LandmarkSegment) -> (Bool, Double) {
        let ratio = initBoundWithDirection2(fromAxis: fromAxis, toAxis: toAxis, fromSegment: fromSegment, toSegment: toSegment)
        return (range.contains(ratio), ratio)
        
    }
    
    static func initBoundToObject(fromAxis: CoordinateAxis, fromSegment: LandmarkSegment, relativeTo: Double) -> Double {
        var ratio = 0.0
        switch fromAxis {
        case .X:

                ratio = fromSegment.distanceXWithDirection/relativeTo


            
            // from Y
            
        case .Y:
                ratio = fromSegment.distanceYWithDirection/relativeTo
  
            
            // from XY
            
        case .XY:
                ratio = fromSegment.distance/relativeTo
 
        }
        return ratio
    }
    
    static func satisfyWithDirectionRelativeToObject(fromAxis: CoordinateAxis, range: Range<Double>, fromSegment: LandmarkSegment, relativeTo: Double) -> (Bool, Double) {
        let ratio = initBoundToObject(fromAxis: fromAxis, fromSegment: fromSegment, relativeTo: relativeTo)
        return (range.contains(ratio), ratio)
        
    }
    
    static func score(ratio:Double, range: Range<Double>) -> Double {
        print("bbbbbbbbbb -\(1 - abs(ratio*2 - (range.lowerBound + range.upperBound))/(range.upperBound - range.lowerBound))")
        return 1 - abs(ratio*2 - (range.lowerBound + range.upperBound))/(range.upperBound - range.lowerBound)
    }
    
    
}
