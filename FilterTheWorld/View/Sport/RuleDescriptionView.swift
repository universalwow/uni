

import SwiftUI

struct StaticValue {
    static let padding: CGFloat = 5
}

struct AngleDescriptionView: View {
    var angle: AngleRange
    var body: some View {
        VStack {
            HStack {
                Text("角度")
                Spacer()
                Button("删除") {
                    
                }
            }
            
            HStack {
                Text("提醒:")
                Spacer()
                Text(angle.warning)
            }
            HStack {
                Text("最小值:")
                Text(angle.lowerBound.roundedString)
                Spacer()
                Text("最大值:")
                Text(angle.upperBound.roundedString)
            }
        }
        
    }
}


struct LengthDescriptionView: View {
    var length: RelativeLandmarkSegmentsToAxis
    var body:some View {
        VStack {
            HStack {
                Text("关节对")
                Spacer()
                Button("删除") {
                    
                }
            }
            HStack {
                Text("提醒:")
                Spacer()
                Text(length.warning)
            }
            
            HStack {
                Text("当前关节:")
                Text(length.from.landmarkSegment.id)
                Text("当前轴:")
                Text(length.from.axis.rawValue)
                Spacer()
                Text("相对关节:")
                Text(length.to.landmarkSegment.id)
                Text("相对轴:")
                Text(length.to.axis.rawValue)
            }
            
            HStack {
                Text("最小值:")
                Text(length.lowerBound.roundedString)
                Spacer()
                Text("最大值:")
                Text(length.upperBound.roundedString)
            }
        }

    }
}

struct LengthToStateDescriptionView: View {
    var length:LandmarkToAxisAndState
    var body:some View {
        VStack {
            HStack {
                Text("关节在区域")
                Spacer()
                Button("删除") {
                    
                }
            }
            HStack {
                Text("提醒:")
                Spacer()
                Text(length.warning)
            }
            
            HStack {
                Text("当前关节:")
                Text(length.fromLandmarkToAxis.landmark.id)
                Spacer()
                Text("当前轴:")
                Text(length.fromLandmarkToAxis.axis.rawValue)
            }
            HStack {
                
                Text("相对状态:")
                Text("\(length.toStateId)")
                Text("相对关节:")
                Text(length.toLandmarkToAxis.landmark.id)
                Text("相对轴:")
                Text(length.toLandmarkToAxis.axis.rawValue)
                Text("相对关节对:")
                Text(length.toLandmarkSegmentToAxis.landmarkSegment.id)
                Text("相对轴:")
                Text(length.toLandmarkSegmentToAxis.axis.rawValue)
            }
            
            HStack {
                Text("最小值:")
                Text(length.lowerBound.roundedString)
                Spacer()
                Text("最大值:")
                Text(length.upperBound.roundedString)
            }
        }

    }
}

struct LandmarkInAreaDescriptionView: View {
    var area:LandmarkInArea
    var body:some View {
        VStack {
            HStack {
                Text("关节相对于状态位移")
                Spacer()
                Button("删除") {
                    
                }
            }
            HStack {
                Text("提醒:")
                Spacer()
                Text(area.warning)
            }
            
            HStack {
                Text("当前关节:")
                Text(area.landmarkType.id)
                Spacer()
                Text("区域:")
                Text(area.areaString)
                
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
            
            VStack {
                if let length = rule.lengthX {
                    LengthDescriptionView(length: length).padding([.top], StaticValue.padding)
                    
                }
                
                if let length = rule.lengthY {
                    LengthDescriptionView(length: length).padding([.top], StaticValue.padding)
                    
                }
                
                if let length = rule.lengthXY {
                    LengthDescriptionView(length: length).padding([.top], StaticValue.padding)
                    
                }
            }
            
            //                                    关节点在区域
            if let area = rule.landmarkInArea {
                LandmarkInAreaDescriptionView(area: area).padding([.top], StaticValue.padding)
            }
            
            VStack {
                if let length = rule.lengthXToState {
                    LengthToStateDescriptionView(length: length)
                }
                if let length = rule.lengthYToState {
                    LengthToStateDescriptionView(length: length)
                }
                if let length = rule.lengthXYToState {
                    LengthToStateDescriptionView(length: length)
                }
            }
        }
    }
}

