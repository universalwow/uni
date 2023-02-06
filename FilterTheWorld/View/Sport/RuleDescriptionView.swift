

import SwiftUI

struct StaticValue {
    static let padding: CGFloat = 5
}

struct LandmarkSegmentAngleDescriptionView: View {
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


struct LandmarkSegmentLengthDescriptionView: View {
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
            Text("\(length.lowerBound.roundedString(number: 2))/\(length.upperBound.roundedString(number: 2))")
            Spacer()
        }
        
    }
}

struct DistanceToLandmarkDescriptionView: View {
    var distanceToLandmark: DistanceToLandmark
    var body:some View {
        HStack {
            Text("关节\(distanceToLandmark.from.landmarkSegment.startLandmark.id)/\(distanceToLandmark.from.axis.rawValue)相对\(distanceToLandmark.from.landmarkSegment.endLandmark.id)-\(distanceToLandmark.to.landmarkSegment.id)/\(distanceToLandmark.to.axis.rawValue)长度:\(distanceToLandmark.warning.content)")
            Spacer()
            Text("\(distanceToLandmark.lowerBound.roundedString(number: 2))/\(distanceToLandmark.upperBound.roundedString(number: 2))")
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

struct LandmarkSegmentToStateAngleDescriptionView: View {
    var landmarkSegmentToStateAngle:LandmarkSegmentToStateAngle
    var body:some View {
        HStack {
            Text("关节对\(landmarkSegmentToStateAngle.fromLandmarkSegment.id)相对状态\(landmarkSegmentToStateAngle.toStateId)角度:\(landmarkSegmentToStateAngle.warning.content)")
            Spacer()
            Text("\(landmarkSegmentToStateAngle.lowerBound.roundedString(number: 2))/\(landmarkSegmentToStateAngle.upperBound.roundedString(number: 2))")
            Spacer()
        }
        
    }
}

struct LandmarkSegmentToStateDistanceDescriptionView: View {
    var landmarkSegmentToStateDistance:LandmarkSegmentToStateDistance
    var body:some View {
        HStack {
            Text("关节对\(landmarkSegmentToStateDistance.fromLandmarkSegment.id)相对状态\(landmarkSegmentToStateDistance.toStateId)长度:\(landmarkSegmentToStateDistance.warning.content)")
            Spacer()
            Text("\(landmarkSegmentToStateDistance.lowerBound.roundedString(number: 2))/\(landmarkSegmentToStateDistance.upperBound.roundedString(number: 2))")
            Spacer()
        }
        
    }
}

struct LandmarkToStateDistanceDescriptionView: View {
    var landmarkToStateDistance:LandmarkToStateDistance
    var body:some View {
        HStack {
            Text("同状态\(landmarkToStateDistance.toStateId)关节\(landmarkToStateDistance.toLandmarkToAxis.landmark.id)/\(landmarkToStateDistance.fromLandmarkToAxis.axis.rawValue)相对\(landmarkToStateDistance.toLandmarkSegmentToAxis.landmarkSegment.id)/\(landmarkToStateDistance.toLandmarkSegmentToAxis.axis.rawValue)位移:\(landmarkToStateDistance.warning.content)")
            Spacer()
            Text("\(landmarkToStateDistance.lowerBound.roundedString(number: 2))/\(landmarkToStateDistance.upperBound.roundedString(number: 2))")
            Spacer()
        }
        
    }
}

struct LandmarkToStateAngleDescriptionView: View {
    var landmarkToStateAngle:LandmarkToStateAngle
    var body:some View {
        HStack {
            Text("关节\(landmarkToStateAngle.fromLandmark.id)相对状态\(landmarkToStateAngle.toStateId)角度:\(landmarkToStateAngle.warning.content)")
            Spacer()
            Text("\(landmarkToStateAngle.lowerBound.roundedString(number: 2))/\(landmarkToStateAngle.upperBound.roundedString(number: 2))")
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

struct LandmarkInAreaForAreaRuleDescriptionView: View {
    var area:LandmarkInAreaForAreaRule
    var body:some View {
        HStack {
            Text("关节\(area.landmark.id)在区域\(area.areaId):\(area.warning.content)")
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

struct ObjectToStateDistanceDescriptionView: View {
    var objectToStateDistance: ObjectToStateDistance
    var body: some View {
        
        
        HStack {
            Text("物体\(objectToStateDistance.fromPosition.id)/\(objectToStateDistance.fromPosition.position.rawValue)相对\(objectToStateDistance.toStateId)/\(objectToStateDistance.toLandmarkSegmentToAxis.landmarkSegment.id)/\(objectToStateDistance.toLandmarkSegmentToAxis.axis.rawValue)位移:\(objectToStateDistance.warning.content)")
            Spacer()
            Text("\(objectToStateDistance.lowerBound.roundedString(number: 2))/\(objectToStateDistance.upperBound.roundedString(number: 2))")

        }
    }
}

struct ObjectToStateAngleDescriptionView: View {
    var objectToStateAngle: ObjectToStateAngle
    var body: some View {
        
        
        HStack {
            Text("物体\(objectToStateAngle.fromPosition.id)/\(objectToStateAngle.fromPosition.position.rawValue)相对\(objectToStateAngle.toStateId)角度:\(objectToStateAngle.warning.content)")
            Spacer()
            Text("\(objectToStateAngle.lowerBound.roundedString(number: 2))/\(objectToStateAngle.upperBound.roundedString(number: 2))")

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
            
            ForEach(rule.landmarkSegmentAngle, content: { _angle in
                LandmarkSegmentAngleDescriptionView(angle: _angle)
                Divider()
                
            })

            ForEach(rule.angleToLandmarkSegment, content: { _angleToLandmarkSegment in
                AngleToLandmarkSegmentDescriptionView(angleToLandmarkSegment: _angleToLandmarkSegment)
                Divider()
                
            })
            
            ForEach(rule.landmarkSegmentLength, content: { _length in
                LandmarkSegmentLengthDescriptionView(length: _length)
                Divider()
                
            })
            
            ForEach(rule.landmarkSegmentToStateAngle, content: { _angle in
                LandmarkSegmentToStateAngleDescriptionView(landmarkSegmentToStateAngle: _angle)
                Divider()
                
            })
            
            ForEach(rule.landmarkSegmentToStateDistance, content: { _distance in
                LandmarkSegmentToStateDistanceDescriptionView(landmarkSegmentToStateDistance: _distance)
                Divider()
                
            })


            
            
            
        }
    }
}


struct LandmarkRuleDescriptionView: View {
    @Binding var rule:LandmarkRule
    var body : some View {
        VStack {
            
            
            ForEach(rule.distanceToLandmark, content: { distanceToLandmark in
                DistanceToLandmarkDescriptionView(distanceToLandmark: distanceToLandmark)
                Divider()
                
            })
            
            ForEach(rule.angleToLandmark, content: { angleToLandmark in
                AngleToLandmarkDescriptionView(angleToLandmark: angleToLandmark)
                Divider()
                
            })
            
            ForEach(rule.landmarkToStateDistance, content: { landmarkToStateDistance in
                LandmarkToStateDistanceDescriptionView(landmarkToStateDistance: landmarkToStateDistance)
                Divider()
            })
            
            ForEach(rule.landmarkToStateAngle, content: { landmarkToStateAngle in
                LandmarkToStateAngleDescriptionView(landmarkToStateAngle: landmarkToStateAngle)
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

            ForEach(rule.objectToStateDistance, content: { objectToStateDistance in
                ObjectToStateDistanceDescriptionView(objectToStateDistance: objectToStateDistance)
                Divider()
                
            })
            
            ForEach(rule.objectToStateAngle, content: { objectToStateAngle in
                ObjectToStateAngleDescriptionView(objectToStateAngle: objectToStateAngle)
                Divider()
                
            })
            
        }
    }
}

struct FixedAreaRuleDescriptionView: View {
    @Binding var rule:FixedAreaRule
    var body : some View {
        VStack {
            
            
            ForEach(rule.landmarkInFixedArea, content: { landmarkInArea in
                LandmarkInAreaForAreaRuleDescriptionView(area: landmarkInArea)
                Divider()
            })
            
        }
    }
}

struct DynamicAreaRuleDescriptionView: View {
    @Binding var rule:DynamicAreaRule
    var body : some View {
        VStack {
            
            
            ForEach(rule.landmarkInDynamicdArea, content: { landmarkInArea in
                LandmarkInAreaForAreaRuleDescriptionView(area: landmarkInArea)
                Divider()
            })
            
        }
    }
}


