
import Foundation




class AnnotationManager: ObservableObject {
  @Published var humanposes : [HumanPose] = []
  
  
  func addHumanPose() {
    let maxId = humanposes.max{ humanLeft, humanRight in
      humanLeft.id < humanRight.id
    }?.id ?? 0
    humanposes.append(
      HumanPose(
        id: maxId + 1
      )
    )
  }
  
  
  func deleteHumanPose(humanPose: HumanPose) {
    if let index = firstIndexOf(humanpose: humanPose) {
      humanposes.remove(at: index)
    }
  }
  
  func upsertLandmark(humanPose: HumanPose, landmark: Landmark) {
    if let humanPoseIndex = firstIndexOf(humanpose: humanPose) {
      humanposes[humanPoseIndex].upsertLandmark(landmark: landmark)
    }
  }
  
  func deleteLandmark(humanPose: HumanPose, landmarkType: LandmarkType) {
    if let humanPoseIndex = firstIndexOf(humanpose: humanPose) {
      humanposes[humanPoseIndex].deleteLandmark(landmarkType: landmarkType)
    }
  }
  
  
  func findCurrentHumanPose(humanPose: HumanPose) -> HumanPose {
    let index = firstIndexOf(humanpose: humanPose)!
    return humanposes[index]
  }
  
  func firstIndexOf(humanpose: HumanPose) -> Int? {
    humanposes.firstIndex{ human in
      human.id == humanpose.id
    }
  }
}
