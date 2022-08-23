import SwiftUI


enum LandmarkType: String, Identifiable, Equatable, Codable, CaseIterable {
    var id: String {
        self.rawValue
    }
    case Nose = "Nose" //鼻子
    
    case LeftEyeOuter = "LeftEyeOuter" //左眼外
    case LeftEye = "LeftEye" //左眼
    case LeftEyeInner = "LeftEyeInner" // 左眼内
    
    case RightEyeOuter = "RightEyeOuter" //右耳外侧
    case RightEye = "RightEye" //右眼
    case RightEyeInner = "RightEyeInner" //右眼内
    
    case LeftEar = "LeftEar" //左耳
    case RightEar = "RightEar" //右耳
    
    case MouthLeft = "MouthLeft" //左侧嘴角
    case MouthRight = "MouthRight" //右侧嘴角
    
    case LeftShoulder = "LeftShoulder" //左肩
    case RightShoulder = "RightShoulder" //右肩
    
    case LeftHip = "LeftHip" //左臀
    case RightHip = "RightHip" //右臀
    
    case LeftElbow = "LeftElbow" // 左胳膊肘
    case RightElbow = "RightElbow" //右胳膊肘
    
    case LeftWrist = "LeftWrist" // 左腕
    case RightWrist = "RightWrist" //右腕
    
    case LeftThumb = "LeftThumb" //左侧拇指
    case RightThumb = "RightThumb" //右侧拇指
    case LeftIndexFinger = "LeftIndexFinger" //左食指
    case RightIndexFinger = "RightIndexFinger" //右食指
    case LeftPinkyFinger = "LeftPinkyFinger" //左小指
    case RightPinkyFinger = "RightPinkyFinger" //右小指
    
    case LeftKnee = "LeftKnee" //左膝
    case RightKnee = "RightKnee" //右膝
    
    case LeftAnkle = "LeftAnkle" // 左脚踝
    case RightAnkle = "RightAnkle" //右侧嘴角
    
    case LeftHeel = "LeftHeel" //左脚跟
    case RightHeel = "RightHeel" //右脚跟
    
    case LeftToe = "LeftToe" //左脚趾
    case RightToe = "RightToe" //右脚趾
    
    case None = "None" //填充值
    
    
    var chineseName:String {
        switch self {
        case .Nose:
            return "鼻子"
        case .LeftEyeOuter:
            return "左眼外"
        case .LeftEye:
            return "左眼"
        case .LeftEyeInner:
            return "左眼内"
        case .RightEyeOuter:
            return "右眼外"
        case .RightEye:
            return "右眼"
        case .RightEyeInner:
            return "右眼内"
        case .LeftEar:
            return "左耳"
        case .RightEar:
            return "右耳"
        case .MouthLeft:
            return "左嘴角"
        case .MouthRight:
            return "右嘴角"
        case .LeftShoulder:
            return "左肩"
        case .RightShoulder:
            return "右肩"
        case .LeftHip:
            return "左臀"
        case .RightHip:
            return "右臀"
        case .LeftElbow:
            return "左手肘"
        case .RightElbow:
            return "右手肘"
        case .LeftWrist:
            return "左手腕"
        case .RightWrist:
            return "右手腕"
        case .LeftThumb:
            return "左手拇指"
        case .RightThumb:
            return "右手拇指"
        case .LeftIndexFinger:
            return "左手食指"
        case .RightIndexFinger:
            return "右手食指"
        case .LeftPinkyFinger:
            return "左手小指"
        case .RightPinkyFinger:
            return "右手小指"
        case .LeftKnee:
            return "左膝盖"
        case .RightKnee:
            return "右膝盖"
        case .LeftAnkle:
            return "左脚踝"
        case .RightAnkle:
            return "右脚踝"
        case .LeftHeel:
            return "左脚跟"
        case .RightHeel:
            return "右脚跟"
        case .LeftToe:
            return "左脚拇指"
        case .RightToe:
            return "右脚拇指"
        case .None:
            return "占位"
        }
    }
    
}



struct Landmark: Equatable, Identifiable, Hashable, Codable {
    var id: String {
        landmarkType.id
    }
    var position: Point3D
    let landmarkType: LandmarkType
    var selected:Bool = false
    var color:Color = .white
    
}

extension Landmark {
    func pointToFit(imageSize: CGSize,
                    viewSize: CGSize) -> CGPoint {
        let imageRatio = 1.0/imageSize.ratio()
        let viewRatio = 1.0/viewSize.ratio()
        
        return imageRatio >= viewRatio ? CGPoint(
            x:
                viewSize.width/2 + (self.position.x - imageSize.width/2)/imageSize.height * viewSize.height,
            y: self.position.y/imageSize.height * viewSize.height
        ) : CGPoint(
            x:
                self.position.x/imageSize.width * viewSize.width
            ,
            y: viewSize.height/2 + (self.position.y - imageSize.height/2)/imageSize.width * viewSize.width
            
        )
        
    }
}







extension LandmarkType {
    static let rightBodyLines = [
        [RightEar,RightEyeOuter,RightEye,RightEyeInner,Nose],
        [RightShoulder,RightElbow,RightWrist], //,RightPinkyFinger,RightThumb
        [RightShoulder, RightHip,RightKnee,RightAnkle,RightHeel,RightToe]
    ]
    
    static let leftBodyLines = [
        [LeftEar,LeftEyeOuter,LeftEye,LeftEyeInner,Nose],
        [LeftShoulder,LeftElbow,LeftWrist], //,LeftPinkyFinger,LeftThumb
        [LeftShoulder,LeftHip,LeftKnee,LeftAnkle,LeftHeel,LeftToe],
    ]
    
    static let otherLines = [
        [MouthLeft, MouthRight],
        [LeftShoulder,RightShoulder],
        [LeftHip, RightHip]
        
    ]
    
    static let secondaryRuleLines = [
        [LeftElbow, RightElbow],
        [LeftWrist, RightWrist],
        [LeftKnee, RightKnee],
        [LeftAnkle, RightAnkle]
    ]
    
    static let needAnglePairs = [
        [LeftShoulder,RightShoulder],
        [LeftHip, RightHip],
        [LeftShoulder,LeftElbow,LeftWrist],
        [RightShoulder,RightElbow,RightWrist],
        [LeftShoulder,LeftHip,LeftKnee,LeftAnkle,LeftHeel,LeftToe],
        [RightShoulder, RightHip,RightKnee,RightAnkle,RightHeel,RightToe]
    ]
    
    func landmark(poseMap: PoseMap) -> Landmark {
        let point = poseMap[self]!
        return Landmark(position: point, landmarkType: self)
    }
    
    static let landmarkSegmentTypes: [LandmarkTypeSegment] = {
        return needAnglePairs.map { lines in
            zip(lines[0..<lines.count - 1], lines[1..<lines.count])
        }.reduce([LandmarkTypeSegment]()) { result, next in
            
            var appendResult = next.map { startLandmarkType, endLandmarkType in
                    LandmarkTypeSegment(
                        startLandmarkType: startLandmarkType,
                        endLandmarkType: endLandmarkType)

            }
            appendResult.append(contentsOf: result)
            return appendResult
        }
 
    }()
    
    
    static let landmarkSegmentTypesForSetRule: [LandmarkTypeSegment] = {
        return (needAnglePairs + secondaryRuleLines).map { lines in
            zip(lines[0..<lines.count - 1], lines[1..<lines.count])
        }.reduce([LandmarkTypeSegment]()) { result, next in
            
            var appendResult = next.map { startLandmarkType, endLandmarkType in
                    LandmarkTypeSegment(
                        startLandmarkType: startLandmarkType,
                        endLandmarkType: endLandmarkType)

            }
            appendResult.append(contentsOf: result)
            return appendResult
        }
 
    }()
    
    
}
