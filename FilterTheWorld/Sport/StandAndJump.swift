
import Foundation
enum StandAndJumpState: String {
    case START, READY, NONE, JUMP, DOWN
}

struct StandAndJump {
  
    var poseList : [HumanPose] = []
    var readyArea: [Point2D] = []
    var jumpArea:[Point2D] = []
    
    var state = StandAndJumpState.START
    
    var leftDownPoint = Point3D.zero
    var rightDownPoint = Point3D.zero
    
    init(jumpArea: [Point2D]) {
        self.jumpArea = jumpArea
        self.setReadArea()
    }
    
    mutating func setReadArea() {
        if jumpArea.count == 4 {
//            图像从左向右跳 从左
            readyArea.append(jumpArea[0])
            readyArea.append(jumpArea[3])
            let length = jumpArea[1].x - jumpArea[0].x
            let ratio = 0.2
            readyArea.append(Point2D(x: jumpArea[3].x - length * ratio, y: jumpArea[3].y))
            readyArea.append(Point2D(x: jumpArea[0].x - length * ratio, y: jumpArea[0].y))
            
            
        }
    }
    
    private func checkIsInReadyArea(humanPoses: [HumanPose]) -> Bool {
        return humanPoses.contains(where: { humanPose in
            return self.readyArea.satisfy(poseMap: humanPose.landmarksMaps, landmarkType: LandmarkType.LeftAnkle)
            &&  self.readyArea.satisfy(poseMap: humanPose.landmarksMaps, landmarkType: LandmarkType.RightAnkle)
        })
    }
    
    private func checkHanOneInReadyArea(humanPoses: [HumanPose]) -> Bool {
        return humanPoses.contains(where: { humanPose in
            return self.readyArea.satisfy(poseMap: humanPose.landmarksMaps, landmarkType: LandmarkType.LeftAnkle)
            ||  self.readyArea.satisfy(poseMap: humanPose.landmarksMaps, landmarkType: LandmarkType.RightAnkle)
        })
    }
    
    private func checkIsInJumpArea(humanPoses: [HumanPose]) -> Bool {
        return humanPoses.contains(where: { humanPose in
            return self.jumpArea.satisfy(poseMap: humanPose.landmarksMaps, landmarkType: LandmarkType.LeftAnkle)
            ||  self.jumpArea.satisfy(poseMap: humanPose.landmarksMaps, landmarkType: LandmarkType.RightAnkle)
        })
    }
    
    private func filterHumanPosesInJumpArea(humanPoses: [HumanPose]) -> [HumanPose] {
        return humanPoses.filter { humanPose in
            return self.jumpArea.satisfy(poseMap: humanPose.landmarksMaps, landmarkType: LandmarkType.LeftAnkle)
            ||  self.jumpArea.satisfy(poseMap: humanPose.landmarksMaps, landmarkType: LandmarkType.RightAnkle)
        }
    }
    
    
    private func findDownUpFrame() -> (Int, Int) {
        if self.poseList.count > 1 {
            let leftAnklePoints = self.poseList.map { humanPose in
                humanPose.landmarksMaps[LandmarkType.LeftAnkle]!
            }
            let rightAnklePoints = self.poseList.map { humanPose in
                humanPose.landmarksMaps[LandmarkType.RightAnkle]!
            }
            
            let leftAnkleDownUps = leftAnklePoints[0..<self.poseList.count-1].indices.map { index in
                leftAnklePoints[index+1].y - leftAnklePoints[index].y
            }
            let rightAnkleDownUps = rightAnklePoints[0..<self.poseList.count-1].indices.map { index in
                rightAnklePoints[index+1].y - rightAnklePoints[index].y
            }
            
            let leftDownIndex = leftAnkleDownUps.firstIndex(where: { upDown in
                upDown < 0
            })
            
            let rightDownIndex = rightAnkleDownUps.firstIndex(where: { upDown in
                upDown < 0
            })
            
            return (leftDownIndex ?? -1, rightDownIndex ?? -1)
            
            
        }
        
        return (-1, -1)
        
    }
    
    
    mutating func play(humanPoses: [HumanPose]) {
        switch state {
        case .START:
            print("请步入准备区域")
            if checkIsInReadyArea(humanPoses: humanPoses) {
                self.state = .READY
            }
        case .READY:
            print("请开始跳跃")
            if !self.checkHanOneInReadyArea(humanPoses: humanPoses) {
                self.state = .JUMP
            }
            
        case .NONE:
            break
            
        case .JUMP:
            
            if checkIsInReadyArea(humanPoses: humanPoses) {
                self.state = .READY
                poseList = []
            }
            
            let inJumpAreaPoses = filterHumanPosesInJumpArea(humanPoses: humanPoses)
            if inJumpAreaPoses.count == 1 {
                self.poseList.append(inJumpAreaPoses.first!)
                let leftRightDownFrame = findDownUpFrame()
                if leftRightDownFrame.0 == -1 && leftRightDownFrame.1 == -1 {
                    return
                }
                var leftDownFrameIndex = -1
                var rightDownFrameIndex = -1
                
                var leftDownPoint = Point3D.zero
                var rightDownPoint = Point3D.zero

                if leftRightDownFrame.0 != -1 {
                    //  左脚找到落地帧
                    leftDownFrameIndex = leftRightDownFrame.0
                }
                
                if leftRightDownFrame.1 != -1 {
                    //  右脚找到落地帧
                    rightDownFrameIndex = leftRightDownFrame.1
                }
                
          
//                找出左脚落地位置
                if leftDownFrameIndex != -1 {
                    leftDownPoint = poseList[leftDownFrameIndex].landmarksMaps[LandmarkType.LeftHeel]!
                }
//                找出右脚落地位置
                if rightDownFrameIndex != -1 {
                    rightDownPoint = poseList[rightDownFrameIndex].landmarksMaps[LandmarkType.RightHeel]!
                }
                
                if leftDownFrameIndex != -1 && rightDownFrameIndex == -1 {
                    rightDownPoint = poseList[leftDownFrameIndex].landmarksMaps[LandmarkType.RightHeel]!
                }
                
                if rightDownFrameIndex != -1 && leftDownFrameIndex == -1 {
                    leftDownPoint = poseList[rightDownFrameIndex].landmarksMaps[LandmarkType.LeftHeel]!
                }
                self.leftDownPoint = leftDownPoint
                self.rightDownPoint = rightDownPoint
                
                self.state = .DOWN
                

                
            } else if inJumpAreaPoses.count > 1 {
                print("多人站在垫子区域")
            }
            
        case .DOWN:
            break
        }
        
        
        
    }
  
  
  
  
  
    
  
  
  
  
}
