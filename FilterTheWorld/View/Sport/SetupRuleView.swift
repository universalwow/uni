

import SwiftUI

struct SetupRuleView: View {
    
    struct StaticValue {
        static let angleTextOffsetY: CGFloat = -20
        static let angleImageSize: CGFloat = 35
    }
    
    @EnvironmentObject var sportManager: SportsManager
    
    @State var minAngle = 0.0
    @State var maxAngle = 0.0
    //角度
    var minAngleslider: some View {
        HStack {
            Slider(
                value: $minAngle,
                in: 0...360,
                step: 1,
                label: {
                    Text("最小角度")
                },
                minimumValueLabel: {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
//                            self.minAngle = min(min(0, self.minAngle - 1), self.maxAngle)
                            self.minAngle = max(0, self.minAngle - 1)
                        }
                },
                maximumValueLabel: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
//                            self.minAngle = min(min(360, self.minAngle + 1), self.maxAngle)
                            self.minAngle = min(360, self.minAngle + 1)
                        }
                },
                onEditingChanged: { _ in
//                    self.minAngle = min(self.minAngle, self.maxAngle)
//                    self.minAngle = min(self.minAngle, self.maxAngle)
                    
                }).background(content: {
                    Text("\(self.minAngle)")
                        .offset(y: StaticValue.angleTextOffsetY)
                        .foregroundColor(self.maxAngle > self.minAngle ? .black : .red)
                    
                })
        }
        
    }
    
    var maxAngleslider: some View {
        HStack {
            Slider(
                value: $maxAngle,
                in: 0...360,
                step: 1,
                label: {
                    Text("最小角度")
                },
                minimumValueLabel: {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)
                        .onTapGesture {
//                            self.maxAngle = max(min(0, self.maxAngle - 1),self.minAngle)
                            self.maxAngle = max(0, self.maxAngle - 1)
                            
                        }
                },
                maximumValueLabel: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: StaticValue.angleImageSize, height: StaticValue.angleImageSize)

                        .onTapGesture {
//                            self.maxAngle = max(min(360, self.maxAngle + 1), self.minAngle)
                            self.maxAngle = min(360, self.maxAngle + 1)
                            
                        }
                },
                onEditingChanged: { _ in
//                    self.maxAngle = max(self.minAngle, self.maxAngle)
                }).background(content: {
                    Text("\(self.maxAngle)")
                        .offset(y: StaticValue.angleTextOffsetY)
                        .foregroundColor(self.maxAngle > self.minAngle ? .black : .red)

                })
        }
        
    }
    
    //相对长度
    @State var currentAxis : CoordinateAxis = .X
    @State var relativeAxis : CoordinateAxis = .X
    @State var relativelandmarkSegmentType: LandmarkTypeSegment = LandmarkTypeSegment.init(startLandmarkType: .LeftShoulder, endLandmarkType: .RightShoulder)
    var relativeLength : some View {
        HStack {
            Text("当前轴")
            Picker("当前轴", selection: $currentAxis) {
                ForEach(CoordinateAxis.allCases) { axis in
                    Text(axis.rawValue).tag(axis)
                }
            }
            Spacer()
            Text("相对关节对")
            Picker("相对关节对", selection: $relativelandmarkSegmentType) {
                ForEach() { landmarkType in
                    Text(axis.rawValue).tag(axis)
                }
            }
            
            Text("相对轴")
            Picker("相对轴", selection: $relativeAxis) {
                ForEach(CoordinateAxis.allCases) { axis in
                    Text(axis.rawValue).tag(axis)
                }
            }
            
            
        }
        
    }
    
    
    
    var body: some View {
        VStack {
            Text(self.sportManager.currentSportStateRuleId ?? "请选择关节对")
                .foregroundColor(self.sportManager.currentSportStateRuleId != nil ? .black : .red)
            
            HStack {
                Text("最小角度")
                    .onTapGesture {
                        self.minAngle = max(0, self.minAngle - 1)
                        
                    }
                
                minAngleslider
            }
            HStack {
                Text("最大角度")
                    .onTapGesture {
//                            self.maxAngle = max(min(0, self.maxAngle - 1),self.minAngle)
                        self.maxAngle = max(0, self.maxAngle - 1)
                        
                    }
                maxAngleslider
            }
            Spacer()
            
        }.padding()
    }
}

struct SetupRuleView_Previews: PreviewProvider {
    static var previews: some View {
        SetupRuleView()
    }
}
