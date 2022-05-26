

import SwiftUI

struct StaticValue {
    static let padding: CGFloat = 5
}

struct AngleDescriptionView: View {
    @EnvironmentObject var sportManager: SportsManager
    var angle: AngleRange
    var body: some View {
        VStack {
            HStack {
                Text("角度")
                Spacer()
                Button("删除") {
//                    sportManager.setCurrentSportStateRuleAngle(sport: sport, state: state, rules: rules, ruleType: ruleType , rule: rule, angle: nil)
                }.disabled(true)
            }
            
            Text("提醒:\(angle.warning)")
            Text("范围:\(angle.lowerBound.roundedString)/\(angle.upperBound.roundedString)")
        }
        
    }
}


struct LengthDescriptionView: View {
    var length: RelativeLandmarkSegmentsToAxis
    var body:some View {
        VStack {
            HStack {
                Text("关节对相对值")
                Spacer()
                Button("删除") {
                    
                }.disabled(true)
            }
            Text("提醒:\(length.warning)")
            
            HStack {
                Text("关节对:\(length.from.landmarkSegment.id)/\(length.from.axis.rawValue) -> \(length.to.landmarkSegment.id)/\(length.to.axis.rawValue)")
                Spacer()
                Text("范围:\(length.lowerBound.roundedString)/\(length.upperBound.roundedString)")
                
            }
            
        }
        
    }
}

struct LengthToStateDescriptionView: View {
    var length:LandmarkToAxisAndState
    var body:some View {
        VStack {
            HStack {
                Text("关节相对于状态位移")
                Spacer()
                Button("删除") {
                    
                }.disabled(true)
            }
            
            Text("提醒:\(length.warning)")

            
            HStack {
                
                Text("关节:\(length.fromLandmarkToAxis.landmark.id)/\(length.fromLandmarkToAxis.axis.rawValue) -> \(length.toStateId) -> \(length.toLandmarkSegmentToAxis.landmarkSegment.id)/\(length.toLandmarkSegmentToAxis.axis.rawValue)")
                Spacer()
                Text("范围:\(length.lowerBound.roundedString)/\(length.upperBound.roundedString)")

            }
        }
        
    }
}

struct LandmarkInAreaDescriptionView: View {
    var area:LandmarkInArea
    var body:some View {
        VStack {
            HStack {
                Text("关节在区域")
                Spacer()
                Button("删除") {
                    
                }.disabled(true)
            }
            
            Text("提醒:\(area.warning)")
            
            Text("关节:\(area.landmarkType.id) -> \(area.areaString)")

            
        }
    }
}


struct ObjectToLandmarkDescriptionView: View {
    var objectToLandmark: ObjectToLandmark
    var body: some View {
        VStack {
            HStack {
                Text("物体相对关节点距离")
                Spacer()
                Button("删除") {
                    
                }.disabled(true)
            }
            Text("提醒:\(objectToLandmark.warning)")

            HStack {
                Text("""
                    当前物体:\(objectToLandmark.fromPosition.id)/\(objectToLandmark.fromPosition.position.rawValue)/\(objectToLandmark.fromAxis.rawValue) -> \(objectToLandmark.toLandmark.landmarkType.rawValue) -> \(objectToLandmark.toLandmarkSegmentToAxis.landmarkSegment.id)/\(objectToLandmark.toLandmarkSegmentToAxis.axis.rawValue)
                    """
                )
                Spacer()
                Text("范围:\(objectToLandmark.lowerBound.roundedString)/\(objectToLandmark.upperBound.roundedString)")

            }
        }
    }
}

struct RuleDescriptionView: View {
    @Binding var rule:ComplexRule
    var body : some View {
        VStack {
            if let angle = rule.angle {
                AngleDescriptionView(angle: angle).padding([.top], StaticValue.padding)
                
                
            }
            if let length = rule.length {
                LengthDescriptionView(length: length).padding([.top], StaticValue.padding)
            }
            
            //                                    关节点在区域
            if let area = rule.landmarkInArea {
                LandmarkInAreaDescriptionView(area: area).padding([.top], StaticValue.padding)
            }
            
            
            if let length = rule.lengthToState {
                LengthToStateDescriptionView(length: length).padding([.top], StaticValue.padding)
            }
            
            if let objectToLandmark = rule.objectPositionToLandmark {
                ObjectToLandmarkDescriptionView(objectToLandmark: objectToLandmark)
            }
            
        }
    }
}

