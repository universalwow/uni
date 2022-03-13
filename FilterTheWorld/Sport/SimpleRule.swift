
import Foundation

enum CoordinateAxis: String, Identifiable,CaseIterable, Codable {
  var id: String {
    self.rawValue
  }
  
  case X,Y,XY
}

enum RuleType {
  case SCORE, VIOLATE
}

struct LandmarkSegmentToAxis: Codable{
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
  
  var toStateId:Int
  var toLandmarkSegmentToAxis: LandmarkSegmentToAxis {
    didSet {
      initBound()
    }
  }
  
  var length: Range<Double> {
    lowerBound..<upperBound
  }
  
  init(fromLandmarkToAxis: LandmarkToAxis, toStateId: Int, toLandmarkToAxis: LandmarkToAxis, toLandmarkSegmentToAxis: LandmarkSegmentToAxis) {
    self.fromLandmarkToAxis = fromLandmarkToAxis
    self.toLandmarkToAxis = toLandmarkToAxis
    self.toStateId = toStateId
    self.toLandmarkSegmentToAxis = toLandmarkSegmentToAxis
  }
  
  private mutating func initBound() {
    switch (fromLandmarkToAxis.axis, toLandmarkSegmentToAxis.axis) {
      case (.X, .X):
        let length = abs(fromLandmarkToAxis.landmark.position.x - toLandmarkToAxis.landmark.position.x)
        lowerBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
        upperBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
      case (.X, .Y):
        let length = abs(fromLandmarkToAxis.landmark.position.x - toLandmarkToAxis.landmark.position.x)
        lowerBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY
        upperBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY
      case (.X, .XY):
        let length = abs(fromLandmarkToAxis.landmark.position.x - toLandmarkToAxis.landmark.position.x)
        lowerBound = length/toLandmarkSegmentToAxis.landmarkSegment.distance
        upperBound = length/toLandmarkSegmentToAxis.landmarkSegment.distance
      case (.Y, .X):
        let length = abs(fromLandmarkToAxis.landmark.position.y - toLandmarkToAxis.landmark.position.y)
        lowerBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
        upperBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
      case (.Y, .Y):
        let length = abs(fromLandmarkToAxis.landmark.position.y - toLandmarkToAxis.landmark.position.y)
        lowerBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY
        upperBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY
      case (.Y, .XY):
        let length = abs(fromLandmarkToAxis.landmark.position.y - toLandmarkToAxis.landmark.position.y)
        lowerBound = length/toLandmarkSegmentToAxis.landmarkSegment.distance
        upperBound = length/toLandmarkSegmentToAxis.landmarkSegment.distance
      case (.XY, .X):
        let length = fromLandmarkToAxis.landmark.position.vector2d.distance(to: fromLandmarkToAxis.landmark.position.vector2d)
        lowerBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
        upperBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceX
      case (.XY, .Y):
        let length = fromLandmarkToAxis.landmark.position.vector2d.distance(to: fromLandmarkToAxis.landmark.position.vector2d)
        lowerBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY
        upperBound = length/toLandmarkSegmentToAxis.landmarkSegment.distanceY
      case (.XY, .XY):
        let length = fromLandmarkToAxis.landmark.position.vector2d.distance(to: fromLandmarkToAxis.landmark.position.vector2d)
        lowerBound = length/toLandmarkSegmentToAxis.landmarkSegment.distance
        upperBound = length/toLandmarkSegmentToAxis.landmarkSegment.distance
    }
  }
  
}

struct RelativeLandmarkSegmentsToAxis: Codable {
  
  var lowerBound:Double = 0
  var upperBound:Double = 0
  
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
  
  init(from: LandmarkSegmentToAxis, to: LandmarkSegmentToAxis) {
    self.from = from
    self.to = to
    initBound()
    print("length.........\(length)/\(from.landmarkSegment.id)/\(to.landmarkSegment.id)")
  }
  
  private mutating func initBound() {
    switch (from.axis, to.axis) {
    case (.X, .X):
        lowerBound = from.landmarkSegment.distanceX/to.landmarkSegment.distanceX
        upperBound = from.landmarkSegment.distanceX/to.landmarkSegment.distanceX
      
    case (.X, .Y):
        
        lowerBound = from.landmarkSegment.distanceX/to.landmarkSegment.distanceY
        upperBound = from.landmarkSegment.distanceX/to.landmarkSegment.distanceY

    case (.X, .XY):
            
            lowerBound = from.landmarkSegment.distanceX/to.landmarkSegment.distance
            upperBound = from.landmarkSegment.distanceX/to.landmarkSegment.distance
        
      // from Y
        
    case (.Y, .X):
        
        lowerBound = from.landmarkSegment.distanceY/to.landmarkSegment.distanceX
        upperBound = from.landmarkSegment.distanceY/to.landmarkSegment.distanceX
        
    case (.Y, .Y):
        
        lowerBound = from.landmarkSegment.distanceY/to.landmarkSegment.distanceY
        upperBound = from.landmarkSegment.distanceY/to.landmarkSegment.distanceY
        
    case (.Y, .XY):
            
        lowerBound = from.landmarkSegment.distanceY/to.landmarkSegment.distance
        upperBound = from.landmarkSegment.distanceY/to.landmarkSegment.distance
        
        
        // from XY
        
    case (.XY, .X):
        
        lowerBound = from.landmarkSegment.distance/to.landmarkSegment.distanceX
        upperBound = from.landmarkSegment.distance/to.landmarkSegment.distanceX
        
    case (.XY, .Y):
        
        lowerBound = from.landmarkSegment.distance/to.landmarkSegment.distanceY
        upperBound = from.landmarkSegment.distance/to.landmarkSegment.distanceY
          
    case (.XY, .XY):
            
        lowerBound = from.landmarkSegment.distance/to.landmarkSegment.distance
        upperBound = from.landmarkSegment.distance/to.landmarkSegment.distance
    }
  }
  
}

struct AngleRange: Codable {
  var lowerBound:Double
  var upperBound:Double
  
  var angle: Range<Int> {
    if lowerBound < upperBound {
      return lowerBound.toInt..<upperBound.toInt
    }else {
      return lowerBound.toInt..<(upperBound + 360).toInt
    }
    
  }
  static var relativeAngleRange: AngleRange = AngleRange(lowerBound: 0, upperBound: 0)

}


extension LandmarkInArea {
  var areaString: String {
    area.reduce("", { result, next in
      result + next.roundedString + ","
    })
  }
  
}

// 过滤有效人
// MARK: 当前只考虑单区域
struct LandmarkInArea: Codable {
  var landmarkType: LandmarkType
  
  var area: [Point2D]
  
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
    rules.removeAll { editedRule in
      if editedRule.angle == nil && editedRule.landmarkInArea == nil &&
          editedRule.lengthX == nil && editedRule.lengthY == nil && editedRule.lengthXY == nil {
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
  
  func currentRulesWarnings(poseMap: PoseMap) -> Set<String> {
    Set(rules.map{ rule in
      rule.currentRuleWarning(poseMap: poseMap)
    }).subtracting([""])
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
  // X 轴间距
  var lengthX: RelativeLandmarkSegmentsToAxis?
  // Y 轴间距
  var lengthY: RelativeLandmarkSegmentsToAxis?
  // 距离
  var lengthXY: RelativeLandmarkSegmentsToAxis?
  
  // 关节点在区域内
  var landmarkInArea:LandmarkInArea?
  // TODO:
  //MARK:  1. 物体在区域内 2. 物体与关节点的关系 3.物体相对自身位移 关节相对自身位移
  
  // 基于多帧的规则
  var lengthXToState: LandmarkToAxisAndState?
  var lengthYToState: LandmarkToAxisAndState?
  var lengthXYToState: LandmarkToAxisAndState?
  
  func angleSatisfy(angleRange: AngleRange, poseMap: PoseMap) -> Bool {
    let landmarkSegment = landmarkSegmentType.landmarkSegment(poseMap: poseMap)
    return angleRange.angle.contains(landmarkSegment.angle2d.toInt) ||
    angleRange.angle.contains(landmarkSegment.angle2d.toInt + 360)
  }
  
  
  func landmarkInAreaSatisfy(landmarkInArea: LandmarkInArea, poseMap: PoseMap) -> Bool? {
    return landmarkInArea.satisfy(landmarkSegmentType: landmarkSegmentType, poseMap: poseMap)
  }
  
  
  func currentRuleWarning(poseMap: PoseMap) -> String {
    if allSatisfy(poseMap: poseMap) {
      return ""
    }
    return warning
  }
  
  
  func allSatisfy(poseMap: PoseMap) -> Bool {
    var lengthXSatisfy: Bool? = true
    var lengthYSatisfy: Bool? = true
    var lengthXYSatisfy: Bool? = true
    var angleSatisfy: Bool? = true
    var landmarkInAreaSatisfy: Bool? = true
    
    if let length = lengthX {
      lengthXSatisfy = lengthSatisfy(relativeDistance: length, poseMap: poseMap)
    }
    
    if let length = lengthY {
      lengthYSatisfy = lengthSatisfy(relativeDistance: length, poseMap: poseMap)
    }
    
    if let length = lengthXY {
      lengthXYSatisfy = lengthSatisfy(relativeDistance: length, poseMap: poseMap)
    }
    
    if let angleRange = angle {
      angleSatisfy = self.angleSatisfy(angleRange: angleRange, poseMap: poseMap)
    }
    
    if let landmarkInArea = landmarkInArea {
      landmarkInAreaSatisfy = self.landmarkInAreaSatisfy(landmarkInArea: landmarkInArea, poseMap: poseMap)
    }
    
    
    
    // 每个规则至少要包含一个条件 且所有条件都必须满足
    return (lengthX != nil || lengthY != nil || lengthXY != nil || angle != nil || landmarkInArea != nil) &&
    lengthXSatisfy == true && lengthYSatisfy == true && lengthXYSatisfy == true && angleSatisfy == true && landmarkInAreaSatisfy == true
  }
  
  func lengthSatisfy(relativeDistance: RelativeLandmarkSegmentsToAxis, poseMap: PoseMap) -> Bool? {

    let  lowerBound = relativeDistance.length.lowerBound
    let  upperBound = relativeDistance.length.upperBound
    
    switch (relativeDistance.from, relativeDistance.to) {
      case (let from, let to) where from.axis == .X && to.axis == .X :
  
        
        return (lowerBound..<upperBound).contains(
          from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceX/to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceX
        )
        
      case (let from, let to) where from.axis == .X && to.axis == .Y :
        
        return (lowerBound..<upperBound).contains(
          from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceX/to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceY
        )
          
      case (let from, let to) where from.axis == .X && to.axis == .XY:
            
            
            return (lowerBound..<upperBound).contains(
              from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceX/to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distance
            )
        
      // from Y
        
      case (let from, let to) where from.axis == .Y && to.axis == .X :
        
        
        return (lowerBound..<upperBound).contains(
          from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceY/to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceX
        )
        
        
      case (let from, let to) where from.axis == .Y && to.axis == .Y :
        
        return (lowerBound..<upperBound).contains(
          from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceY/to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceY
        )
          

      case (let from, let to) where from.axis == .Y && to.axis == .XY:
        
        return (lowerBound..<upperBound).contains(
          from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceY/to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distance
        )
        
        // from XY
        
      case (let from, let to) where from.axis == .XY && to.axis == .X :
        
        return (lowerBound..<upperBound).contains(
          from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distance/to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceX
        )
        
      case (let from, let to) where from.axis == .XY && to.axis == .Y :
        
        return (lowerBound..<upperBound).contains(
          from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distance/to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distanceY
        )
          
      case (let from, let to) where from.axis == .XY && to.axis == .XY:

        return (lowerBound..<upperBound).contains(
          from.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distance/to.landmarkSegment.landmarkSegmentType.landmarkSegment(poseMap: poseMap).distance
        )
    
    case (_, _):
      return nil
    }
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
