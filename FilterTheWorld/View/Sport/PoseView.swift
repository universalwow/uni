

import SwiftUI

struct LandmarkView: View {
    var pose: HumanPose
    var imageSize: CGSize
    var viewSize: CGSize
    
    var body: some View {
        ForEach(pose.landmarks) { landmark in
            Circle()
                .fill(pose.isSelected ? Color.yellow : Color.white)
                .frame(width: 6)
                .position(landmark.pointToFit(imageSize: imageSize, viewSize: viewSize))
        }
    }
}

struct LandmarkSegmentView: Shape {
    var landmarkSegment:LandmarkSegment
    var imageSize: CGSize
    var viewSize: CGSize
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startLandmark = landmarkSegment.startLandmark
        let endLandmark = landmarkSegment.endLandmark
        path.move(to: startLandmark.pointToFit(imageSize: imageSize, viewSize: viewSize))
        path.addLine(to: endLandmark.pointToFit(imageSize: imageSize, viewSize: viewSize))
        return path
    }
}

struct PoseView: View {
    var pose: HumanPose
    var imageSize: CGSize
    var viewSize: CGSize
    var showAngle:Bool = true
    
    
    func lineWidth(landmarkSegment: LandmarkSegment) -> CGFloat {
        let startLandmarkType = landmarkSegment.startLandmark.landmarkType
        let endLandmarkType = landmarkSegment.endLandmark.landmarkType
        
        if (LandmarkType.leftBodyLines + LandmarkType.rightBodyLines + LandmarkType.otherLines)
            .contains(where: { landmarkTypes in
            landmarkTypes.contains(startLandmarkType) && landmarkTypes.contains(endLandmarkType)
        }) {
            return 3
        }
        
        return 1
    }
    
    var body: some View {
        ForEach(pose.landmarkSegments) { landmarkSegment in
            Group {
                
                LandmarkSegmentView(landmarkSegment: landmarkSegment, imageSize: imageSize, viewSize: viewSize)
                    
                    .stroke(landmarkSegment.color, lineWidth: lineWidth(landmarkSegment: landmarkSegment))
                
//
//                LandmarkSegmentAngleView(landmarkSegment: landmarkSegment, imageSize: imageSize, viewSize: viewSize)
//                    .foregroundColor(.yellow).opacity(showAngle ? 1 : 0)
            }
        }
    }
}

struct LandmarkSegmentAngleView:View {
    var landmarkSegment: LandmarkSegment
    var imageSize: CGSize
    var viewSize: CGSize
    var body: some View {
        Text(landmarkSegment.angle2d.roundedString)
            .position(landmarkSegment.center2d.pointToFit(imageSize: imageSize, viewSize: viewSize))
    }
}

struct LandmarkViewForSetupRule: View {
    var landmarks: [Landmark] 
    var imageSize: CGSize
    var viewSize: CGSize
    

    
    var body: some View {
        
        
        
        ForEach(landmarks) { landmark in
            Circle()
                .fill(landmark.selected ? Color.yellow : Color.red)
                .frame(width: 5)
                .position(landmark.pointToFit(imageSize: imageSize, viewSize: viewSize))
        }
        
        
    }
}

struct PoseViewForSetupRule: View {
    
    @EnvironmentObject var sportManager: SportsManager
    var landmarkSegments: [LandmarkSegment]
    var imageSize: CGSize
    var viewSize: CGSize
    
    func colorOf(segment: LandmarkSegment) -> Color {
        segment.selected  ? Color.yellow : segment.color
    }
    
    var body: some View {
        ForEach(landmarkSegments) { landmarkSegment in
            Group {
                LandmarkSegmentView(landmarkSegment: landmarkSegment, imageSize: imageSize, viewSize: viewSize)
                    .stroke(
                        colorOf(segment: landmarkSegment), lineWidth: 2)
                LandmarkSegmentAngleView(landmarkSegment: landmarkSegment, imageSize: imageSize, viewSize: viewSize)
                    .foregroundColor(
                        colorOf(segment: landmarkSegment))
            }.onTapGesture {
                // 选择关节或关节点
                sportManager.setCurrentSportStateRule(landmarkSegmentType: landmarkSegment.landmarkSegmentType, ruleClass: .LandmarkSegment)
                
            }
            
            
            
            
        }
    }
}




struct PosesViewForSetupRule: View {
    @EnvironmentObject var sportManager: SportsManager
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    var imageSize: CGSize
    var viewSize: CGSize
    var body: some View {
        ZStack {
            let humanPose = sportManager.findFirstState()!.humanPose!
            PoseViewForSetupRule(landmarkSegments: humanPose.landmarkSegments, imageSize: imageSize, viewSize: viewSize)
            LandmarkViewForSetupRule(landmarks: humanPose.landmarks, imageSize: imageSize, viewSize: viewSize)
        }
        
    }
}




struct PosesView: View {
    @EnvironmentObject var sportManager: SportsManager
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    
    var poses: [HumanPose]?
    var imageSize: CGSize
    var viewSize: CGSize
    var body: some View {
        if let poses = poses {
            ForEach(poses) { pose in
                ZStack {
                    PoseView(pose: pose, imageSize: imageSize, viewSize: viewSize)
                    LandmarkView(pose: pose, imageSize: imageSize, viewSize: viewSize)
                }.onTapGesture {
                    //选择一个人
                    imageAnalysis.selectHumanPose(selectedHumanPose: pose)
                    sportManager.updateSportState(image: imageAnalysis.sportData.frame, humanPose: imageAnalysis.selectedHumanPose())
                    print("选择一个人 \(imageAnalysis.selectedHumanPose() == nil ? false : true )")
                    
                    
                }
            }
        }
        
    }
}


struct PosesViewForSportsGround: View {
    @EnvironmentObject var sportManager: SportsManager
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    
    var poses: [HumanPose]?
    var imageSize: CGSize
    var viewSize: CGSize
    var showAngle: Bool = true
    var body: some View {
        if let poses = poses {
            ForEach(poses) { pose in
                ZStack {
                    PoseView(pose: pose, imageSize: imageSize, viewSize: viewSize, showAngle: showAngle)
                    LandmarkView(pose: pose, imageSize: imageSize, viewSize: viewSize)
                }
            }
        }
        
    }
}

