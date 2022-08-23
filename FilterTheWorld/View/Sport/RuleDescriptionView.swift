

import SwiftUI

struct StaticValue {
    static let padding: CGFloat = 5
}

struct AngleDescriptionView: View {
    var angle: LandmarkSegmentAngle
    var body: some View {
        HStack {
            Text("角度:\(angle.warning.content)/\(angle.warning.delayTime.roundedString(number: 2))/\(angle.warning.triggeredWhenRuleMet.description)")
            Spacer()
            Text("\(angle.lowerBound.roundedString)/\(angle.upperBound.roundedString)")
            Spacer()
        }
        
    }
}


struct LengthDescriptionView: View {
    var length: LandmarkSegmentLength
    var body:some View {
        HStack {
            Text("关节对\(length.from.landmarkSegment.id)/\(length.from.axis.rawValue)相对 \(length.to.landmarkSegment.id)/\(length.to.axis.rawValue)长度:\(length.warning.content)")
            Spacer()
            Text("\(length.lowerBound.roundedString(number: 4))/\(length.upperBound.roundedString(number: 4))")
            Spacer()
        }
        
    }
}

struct AngleToLandmarkSegmentDescriptionView: View {
    var angleToLandmarkSegment: AngleToLandmarkSegment
    var body:some View {
        HStack {
            Text("关节对\(angleToLandmarkSegment.from.id)相对 \(angleToLandmarkSegment.to.id)角度:\(angleToLandmarkSegment.warning.content)")
            Spacer()
            Text("\(angleToLandmarkSegment.lowerBound.roundedString(number: 4))/\(angleToLandmarkSegment.upperBound.roundedString(number: 4))")
            Spacer()
        }
        
    }
}



struct LengthToStateDescriptionView: View {
    var length:LandmarkToState
    var body:some View {
        HStack {
            Text("同状态\(length.toStateId)关节\(length.fromLandmarkToAxis.landmark.id)/\(length.fromLandmarkToAxis.axis.rawValue)相对\(length.toLandmarkSegmentToAxis.landmarkSegment.id)/\(length.toLandmarkSegmentToAxis.axis.rawValue)位移:\(length.warning.content)")
            Spacer()
            Text("\(length.lowerBound.roundedString(number: 4))/\(length.upperBound.roundedString(number: 4))")
            Spacer()
        }
        
    }
}

struct AngleToLandmarkDescriptionView: View {
    var angleToLandmark: AngleToLandmark
    var body: some View {
        HStack {
            Text("相对\(angleToLandmark.toLandmark.id)角度:\(angleToLandmark.warning.content)/\(angleToLandmark.warning.delayTime.roundedString(number: 2))/\(angleToLandmark.warning.triggeredWhenRuleMet.description)")
            Spacer()
            Text("\(angleToLandmark.lowerBound.roundedString)/\(angleToLandmark.upperBound.roundedString)")
            Spacer()
        }
        
    }
}

struct LengthToStateExtremeDescriptionView: View {
    var length:LandmarkToStateExtreme
    var body:some View {
        HStack {
            Text("同状态\(length.toStateId)关节\(length.fromLandmarkToAxis.landmark.id)/\(length.fromLandmarkToAxis.axis.rawValue)相对\(length.toLandmarkSegmentToAxis.landmarkSegment.id)/\(length.toLandmarkSegmentToAxis.axis.rawValue)位移:\(length.warning.content)")
            Spacer()
            Text("\(length.lowerBound.roundedString(number: 4))/\(length.upperBound.roundedString(number: 4))")
            Spacer()
        }
        
    }
}

struct LandmarkInAreaDescriptionView: View {
    var area:LandmarkInArea
    var body:some View {
        HStack {
            Text("关节\(area.landmark.id)在区域:\(area.warning.content)")
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
            Text("物体\(objectToLandmark.fromPosition.id)/\(objectToLandmark.fromPosition.position.rawValue)/\(objectToLandmark.fromPosition.axis.rawValue)与关节\(objectToLandmark.toLandmark.landmarkType.rawValue)相对\(objectToLandmark.toLandmarkSegmentToAxis.landmarkSegment.id)/\(objectToLandmark.toLandmarkSegmentToAxis.axis.rawValue)距离:\(objectToLandmark.warning.content)")
            Spacer()
            Text("\(objectToLandmark.lowerBound.roundedString(number: 4))/\(objectToLandmark.upperBound.roundedString(number: 4))")
            Spacer()
        }
    }
}

struct ObjectToObjectDescriptionView: View {
    var objectToObject: ObjectToObject
    var body: some View {
        HStack {
            Text("物体\(objectToObject.fromPosition.id)/\(objectToObject.fromPosition.position.rawValue)/\(objectToObject.fromPosition.axis.rawValue)与物体\(objectToObject.toPosition.id)/\(objectToObject.toPosition.position.rawValue)相对\(objectToObject.toLandmarkSegmentToAxis.landmarkSegment.id)/\(objectToObject.toLandmarkSegmentToAxis.axis.rawValue)距离:\(objectToObject.warning.content)")
            Spacer()
            Text("\(objectToObject.lowerBound.roundedString(number: 4))/\(objectToObject.upperBound.roundedString(number: 4))")
            Spacer()
        }
    }
}

struct ObjectToSelfDescriptionView: View {
    var objectToSelf: ObjectToSelf
    var body: some View {
        HStack {
            Text("物体\(objectToSelf.objectId )相对自身\(objectToSelf.toDirection.rawValue )方向移动\(objectToSelf.xLowerBound.roundedString(number: 4))/\(objectToSelf.yLowerBound.roundedString(number: 4)):\(objectToSelf.warning.content)")
            Spacer()
            
        }
    }
}

struct ObjectToStateExtremeDescriptionView: View {
    var objectToState: ObjectToStateExtreme
    var body: some View {
        
        
        HStack {
            Text("物体\(objectToState.fromPosition.id)/\(objectToState.fromPosition.position.rawValue)相对\(objectToState.toStateId)/\(objectToState.toLandmarkSegmentToAxis.landmarkSegment.id)/\(objectToState.toLandmarkSegmentToAxis.axis.rawValue)位移:\(objectToState.warning.content)")
            Spacer()
            Text("\(objectToState.lowerBound.roundedString(number: 2))/\(objectToState.upperBound.roundedString(number: 2))")

        }
    }
}


struct LandmarkToSelfDescriptionView: View {
    var landmarkToSelf: LandmarkToSelf
    var body: some View {
        HStack {
            Text("关节点\(landmarkToSelf.landmarkType.rawValue)相对自身\(landmarkToSelf.toLandmarkSegmentToAxis.landmarkSegment.id)/\(landmarkToSelf.toLandmarkSegmentToAxis.axis.rawValue)/\(landmarkToSelf.toDirection.rawValue )方向移动\(landmarkToSelf.xLowerBound.roundedString(number: 4))/\(landmarkToSelf.yLowerBound.roundedString(number: 4)):\(landmarkToSelf.warning.content)")
            Spacer()
        }
    }
}

struct LandmarkSegmentRuleDescriptionView: View {
    @Binding var rule:LandmarkSegmentRule
    var body : some View {
        VStack {
            
            ForEach(rule.angle, content: { _angle in
                AngleDescriptionView(angle: _angle)
                Divider()
                
            })

            ForEach(rule.angleToLandmarkSegment, content: { _angleToLandmarkSegment in
                AngleToLandmarkSegmentDescriptionView(angleToLandmarkSegment: _angleToLandmarkSegment)
                Divider()
                
            })
            
            ForEach(rule.length, content: { _length in
                LengthDescriptionView(length: _length)
                Divider()
                
            })


            
            
            
        }
    }
}


struct LandmarkRuleDescriptionView: View {
    @Binding var rule:LandmarkRule
    var body : some View {
        VStack {
            
//            ForEach(rule.landmarkToSelf, content: { landmarkToSelf in
//                LandmarkToSelfDescriptionView(landmarkToSelf: landmarkToSelf)
//                Divider()
//
//            })

//            ForEach(rule.landmarkToState, content: { lengthToState in
//                LengthToStateDescriptionView(length: lengthToState)
//                Divider()
//
//            })
            
            ForEach(rule.angleToLandmark, content: { angleToLandmark in
                AngleToLandmarkDescriptionView(angleToLandmark: angleToLandmark)
                Divider()
                
            })
            
            ForEach(rule.landmarkToStateExtreme, content: { landmarkToStateExtreme in
                LengthToStateExtremeDescriptionView(length: landmarkToStateExtreme)
                Divider()
                
            })
            
            ForEach(rule.landmarkInArea, content: { landmarkInArea in
                LandmarkInAreaDescriptionView(area: landmarkInArea)
                Divider()
                
            })

            
        }
    }
}

struct ObservationRuleDescriptionView: View {
    @Binding var rule:ObservationRule
    var body : some View {
        VStack {
            
            ForEach(rule.objectToLandmark, content: { objectToLandmark in
                ObjectToLandmarkDescriptionView(objectToLandmark: objectToLandmark)
                Divider()
                
            })
            
            ForEach(rule.objectToObject, content: { objectToObject in
                ObjectToObjectDescriptionView(objectToObject: objectToObject)
                Divider()
                
            })

//            ForEach(rule.objectToSelf, content: { objectToSelf in
//                ObjectToSelfDescriptionView(objectToSelf: objectToSelf)
//                Divider()
//
//            })
            ForEach(rule.objectToState, content: { objectToState in
                ObjectToStateExtremeDescriptionView(objectToState: objectToState)
                Divider()
                
            })
            
        }
    }
}

