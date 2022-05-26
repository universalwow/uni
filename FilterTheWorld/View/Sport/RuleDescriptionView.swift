

import SwiftUI

struct StaticValue {
    static let padding: CGFloat = 5
}

struct AngleDescriptionView: View {
    @EnvironmentObject var sportManager: SportsManager
    var angle: AngleRange
    var body: some View {
        HStack {
            Text("角度:\(angle.warning)")
            Spacer()
            Text("\(angle.lowerBound.roundedString)/\(angle.upperBound.roundedString)")
            Spacer()
        }
        
    }
}


struct LengthDescriptionView: View {
    var length: RelativeLandmarkSegmentsToAxis
    var body:some View {
        HStack {
            Text("关节对\(length.from.landmarkSegment.id)/\(length.from.axis.rawValue)相对 \(length.to.landmarkSegment.id)/\(length.to.axis.rawValue)长度:\(length.warning)")
            Spacer()
            Text("\(length.lowerBound.roundedString)/\(length.upperBound.roundedString)")
            Spacer()
        }
        
    }
}

struct LengthToStateDescriptionView: View {
    var length:LandmarkToAxisAndState
    var body:some View {
        HStack {
            Text("同状态\(length.toStateId)关节\(length.fromLandmarkToAxis.landmark.id)/\(length.fromLandmarkToAxis.axis.rawValue)相对\(length.toLandmarkSegmentToAxis.landmarkSegment.id)/\(length.toLandmarkSegmentToAxis.axis.rawValue)位移:\(length.warning)")
            Spacer()
            Text("\(length.lowerBound.roundedString)/\(length.upperBound.roundedString)")
            Spacer()
        }
        
    }
}

struct LandmarkInAreaDescriptionView: View {
    var area:LandmarkInArea
    var body:some View {
        HStack {
            Text("关节\(area.landmarkType.id)在区域:\(area.warning)")
            Spacer()
            Text(area.areaString)
            Spacer()
        }
    }
}


struct ObjectToLandmarkDescriptionView: View {
    var objectToLandmark: ObjectToLandmark
    var body: some View {
        HStack {
            Text("物体\(objectToLandmark.fromPosition.id)/\(objectToLandmark.fromPosition.position.rawValue)/\(objectToLandmark.fromAxis.rawValue)与关节\(objectToLandmark.toLandmark.landmarkType.rawValue)相对\(objectToLandmark.toLandmarkSegmentToAxis.landmarkSegment.id)/\(objectToLandmark.toLandmarkSegmentToAxis.axis.rawValue)距离:\(objectToLandmark.warning)")
            Spacer()
            Text("\(objectToLandmark.lowerBound.roundedString)/\(objectToLandmark.upperBound.roundedString)")
            Spacer()
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

