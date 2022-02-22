
import Foundation
import SwiftUI



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


struct RelativeLandmarkSegmentsToAxis: Codable {
  
  var lowerBound:Double
  var upperBound:Double
  
  var from:LandmarkSegmentToAxis
  var to: LandmarkSegmentToAxis
  
  var length: Range<Double> {
    lowerBound..<upperBound
  }
  
  mutating func initBound() {
    
    switch (from, to) {
      case (let from, let to) where from.axis == .X && to.axis == .X :
        lowerBound = from.landmarkSegment.distanceX/to.landmarkSegment.distanceX
        upperBound = from.landmarkSegment.distanceX/to.landmarkSegment.distanceX
        
      case (let from, let to) where from.axis == .X && to.axis == .Y :
        
        lowerBound = from.landmarkSegment.distanceX/to.landmarkSegment.distanceY
        upperBound = from.landmarkSegment.distanceX/to.landmarkSegment.distanceY

          
      case (let from, let to) where from.axis == .X && to.axis == .XY:
            
            lowerBound = from.landmarkSegment.distanceX/to.landmarkSegment.distance
            upperBound = from.landmarkSegment.distanceX/to.landmarkSegment.distance
        
      // from Y
        
      case (let from, let to) where from.axis == .Y && to.axis == .X :
        
        lowerBound = from.landmarkSegment.distanceY/to.landmarkSegment.distanceX
        upperBound = from.landmarkSegment.distanceY/to.landmarkSegment.distanceX
        
        
      case (let from, let to) where from.axis == .Y && to.axis == .Y :
        
        lowerBound = from.landmarkSegment.distanceY/to.landmarkSegment.distanceY
        upperBound = from.landmarkSegment.distanceY/to.landmarkSegment.distanceY
        
          

      case (let from, let to) where from.axis == .Y && to.axis == .XY:
            
        lowerBound = from.landmarkSegment.distanceY/to.landmarkSegment.distance
        upperBound = from.landmarkSegment.distanceY/to.landmarkSegment.distance
        
        
        // from XY
        
      case (let from, let to) where from.axis == .XY && to.axis == .X :
        
        lowerBound = from.landmarkSegment.distance/to.landmarkSegment.distanceX
        upperBound = from.landmarkSegment.distance/to.landmarkSegment.distanceX
        
        
      case (let from, let to) where from.axis == .XY && to.axis == .Y :
        
        lowerBound = from.landmarkSegment.distance/to.landmarkSegment.distanceY
        upperBound = from.landmarkSegment.distance/to.landmarkSegment.distanceY
        

          
      case (let from, let to) where from.axis == .XY && to.axis == .XY:
            
        lowerBound = from.landmarkSegment.distance/to.landmarkSegment.distance
        upperBound = from.landmarkSegment.distance/to.landmarkSegment.distance
    
    case (_, _): break
      
    }
  }
  
  static func initValue(fromLandmarkSegment: LandmarkSegment, axis: CoordinateAxis) -> RelativeLandmarkSegmentsToAxis {
    
    return RelativeLandmarkSegmentsToAxis(lowerBound: 0,
                                   upperBound: 0,
                                   from: LandmarkSegmentToAxis(landmarkSegment: fromLandmarkSegment, axis: axis), to: LandmarkSegmentToAxis.initValue)
    
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

// 过滤有效人
// MARK: 当前只考虑单区域
struct LandmarkInArea: Codable {
  var landmarkSegmentType: LandmarkTypeSegment
  var landmarkType: LandmarkType
  
  var area: [CGPoint]
  
  var path: Path {
    var path = Path()
    let areaIndics = area.indices
    area.indices.forEach{ index in
      if index == areaIndics.lowerBound {
        path.move(to: area[index])
      }else if index == areaIndics.upperBound - 1 {
        path.addLine(to: area[areaIndics.lowerBound])
      }else {
        path.addLine(to: area[index])
      }
      
    }
    
    return path
  }
  
  func satisfy(poseMap: PoseMap) -> Bool? {
    
    let landmarkSegment = landmarkSegmentType.landmarkSegment(poseMap: poseMap)
    
    if landmarkType == landmarkSegment.startLandmark.landmarkType {
      return path.contains(landmarkSegment.startLandmark.position.vector2d.toCGPoint)
    }else if landmarkType == landmarkSegment.endLandmark.landmarkType {
      return path.contains(landmarkSegment.endLandmark.position.vector2d.toCGPoint)

    }
    return nil
  }
  
//  var contains: Bool {
//    landmarks.contains(where: { landmark in
//      path.contains(landmark.position.vector2d.toCGPoint)
//    })
//  }
//
//
//  var satisfy:Bool {
//    switch isAllSatisfy {
//      case true:
//        return allSatisfy
//      case false:
//        return contains
//      }
//  }
  
  
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
  
  
  mutating func updateSportStateRule(editedRule: ComplexRule) {
    if editedRule.angle == nil && editedRule.lengthX == nil && editedRule.lengthY == nil && editedRule.lengthXY == nil {
      if let index = firstIndexOfRule(editedRule: editedRule) {
        rules.remove(at: index)
      }
    }else{
      if let index = firstIndexOfRule(editedRule: editedRule) {
        rules[index] = editedRule
      }else{
        rules.append(editedRule)
      }
    }
    
  }
  
  func currentRulesWarnings(poseMap: PoseMap) -> Set<String> {
    Set(rules.map{ rule in
      rule.currentRuleWarning(poseMap: poseMap)
    }).subtracting([""])
  }
  
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
//  var landmarkSegment:LandmarkSegment
  // 10 - 30 340-380
  // 角度
  // 当前状态下需要的提示
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
  
  
  func angleSatisfy(angleRange: AngleRange, poseMap: PoseMap) -> Bool {
    let landmarkSegment = landmarkSegmentType.landmarkSegment(poseMap: poseMap)
    return angleRange.angle.contains(landmarkSegment.angle2d.toInt) ||
    angleRange.angle.contains(landmarkSegment.angle2d.toInt + 360)
  }
  
  
  func landmarkInAreaSatisfy(landmarkInArea: LandmarkInArea, poseMap: PoseMap) -> Bool? {
    return landmarkInArea.satisfy(poseMap: poseMap)
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
