

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
            LandmarkSegmentView(landmarkSegment: landmarkSegment, imageSize: imageSize, viewSize: viewSize)
                .stroke(landmarkSegment.color, lineWidth: 2)
            
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
                    sportManager.updateSportState(image: imageAnalysis.sportData.frame, landmarkSegments: imageAnalysis.selectedHumanPose()?.landmarkSegments ?? [])
                    print("选择一个人 \(imageAnalysis.selectedHumanPose() == nil ? false : true )")
                    
                    
                }
            }
        }
        
    }
}

