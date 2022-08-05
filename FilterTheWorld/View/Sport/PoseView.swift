

import SwiftUI

struct LandmarkView: View {
    var pose: HumanPose
    var imageSize: CGSize
    var viewSize: CGSize
    
    var body: some View {
        ForEach(pose.landmarks) { landmark in
            Circle()
                .fill(pose.isSelected ? Color.yellow : Color.red)
                .frame(width: 5)
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
    
    var body: some View {
        ForEach(pose.landmarkSegments) { landmarkSegment in
            Group {
                LandmarkSegmentView(landmarkSegment: landmarkSegment, imageSize: imageSize, viewSize: viewSize)
                    .stroke(landmarkSegment.color, lineWidth: 2)
                LandmarkSegmentAngleView(landmarkSegment: landmarkSegment, imageSize: imageSize, viewSize: viewSize)
                    .foregroundColor(.yellow)
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
    var landmarkSegments: [LandmarkSegment]
    var imageSize: CGSize
    var viewSize: CGSize
    
    var landmarks: [Landmark] {
        var _landmarks : [Landmark] = []
        landmarkSegments.forEach { landmarkSegment in
            if !_landmarks.contains(where: { _landmark in
                _landmark.id == landmarkSegment.startLandmark.id
            }) {
                _landmarks.append(landmarkSegment.startLandmark)
            }
            if !_landmarks.contains(where: { _landmark in
                _landmark.id == landmarkSegment.endLandmark.id
            }) {
                _landmarks.append(landmarkSegment.endLandmark)
            }
        }
        return _landmarks
    }
    
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
    
    func colorOf(selected: Bool?, segment: LandmarkSegment) -> Color {
        selected ?? false ? Color.yellow : segment.color
    }
    
    var body: some View {
        ForEach(landmarkSegments) { landmarkSegment in
            Group {
                LandmarkSegmentView(landmarkSegment: landmarkSegment, imageSize: imageSize, viewSize: viewSize)
                    .stroke(
                        colorOf(selected: sportManager.segmentSelected(segment: landmarkSegment), segment: landmarkSegment), lineWidth: 2)
                LandmarkSegmentAngleView(landmarkSegment: landmarkSegment, imageSize: imageSize, viewSize: viewSize)
                    .foregroundColor(
                        colorOf(selected: sportManager.segmentSelected(segment: landmarkSegment), segment: landmarkSegment))
            }.onTapGesture {
                // 选择关节或关节点
                sportManager.setCurrentSportStateRule(landmarkSegmentType: landmarkSegment.landmarkSegmentType)
                
            }
            
            
            
            
        }
    }
}




struct PosesViewForSetupRule: View {
    @EnvironmentObject var sportManager: SportsManager
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    var landmarkSegments: [LandmarkSegment]
    var imageSize: CGSize
    var viewSize: CGSize
    var body: some View {
        ZStack {
            PoseViewForSetupRule(landmarkSegments: landmarkSegments, imageSize: imageSize, viewSize: viewSize)
            LandmarkViewForSetupRule(landmarkSegments: landmarkSegments, imageSize: imageSize, viewSize: viewSize)
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
    var body: some View {
        if let poses = poses {
            ForEach(poses) { pose in
                ZStack {
                    PoseView(pose: pose, imageSize: imageSize, viewSize: viewSize)
                    LandmarkView(pose: pose, imageSize: imageSize, viewSize: viewSize)
                }
            }
        }
        
    }
}

