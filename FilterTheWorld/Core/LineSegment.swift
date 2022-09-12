

import Foundation
import SwiftUI

func landmarkTypeSegmentString(startLandmarkType: LandmarkType, endLandmarkType: LandmarkType) -> String {
    "\(startLandmarkType.rawValue)-\(endLandmarkType.rawValue)"
}

struct LandmarkTypeSegment: Identifiable, Hashable, Codable {
    let startLandmarkType:LandmarkType
    let endLandmarkType:LandmarkType
    let id:String
    init(startLandmarkType:LandmarkType, endLandmarkType:LandmarkType) {
        self.startLandmarkType = startLandmarkType
        self.endLandmarkType = endLandmarkType
        self.id = landmarkTypeSegmentString(startLandmarkType: startLandmarkType, endLandmarkType: endLandmarkType)
    }
    
    
    
    var startAndEndSegmentTypes: [LandmarkType] {
        [startLandmarkType, endLandmarkType]
    }
}




struct LandmarkSegment: Hashable, Identifiable, Equatable,  Codable {
    
    var id: String {
        landmarkTypeSegmentString(startLandmarkType: startLandmark.landmarkType,
                                            endLandmarkType: endLandmark.landmarkType)
    }
    var startLandmark:Landmark
    var endLandmark:Landmark
    var selected:Bool = false
    var color:Color = .white
    var angleRange:Range<Int>?
    
    
    static func initValue() -> LandmarkSegment {
        LandmarkSegment(
            startLandmark: Landmark(position: Point3D(), landmarkType: LandmarkType.LeftShoulder),
            endLandmark: Landmark(position: Point3D(), landmarkType: LandmarkType.RightShoulder))
    }
    
    
    init(startLandmark:Landmark, endLandmark:Landmark) {
        self.init(startLandmark: startLandmark, endLandmark: endLandmark, color: .white)
    }
    
    init(startLandmark:Landmark, endLandmark:Landmark, color: Color) {
        self.startLandmark = startLandmark
        self.endLandmark = endLandmark
        self.color = color
    }
}






extension LandmarkTypeSegment {
    
    func landmarkSegment(poseMap: PoseMap, color:Color = .white) -> LandmarkSegment {
        let startPosition = poseMap[self.startLandmarkType]!
        let endPosition = poseMap[self.endLandmarkType]!
        return LandmarkSegment(
            startLandmark:
                Landmark(position: startPosition,
                         landmarkType: startLandmarkType),
            endLandmark:
                Landmark(position: endPosition,
                         landmarkType: endLandmarkType),
            color: color)
    }
}



extension LandmarkSegment {
    var selectedColor:Color {
        selected ? Color.red : color
    }
}

extension LandmarkSegment {
    
    var landmarkTypes: [LandmarkType] {
        [self.startLandmark.landmarkType,
         self.endLandmark.landmarkType
        ]
    }
    var angle2d: Double {
        (endLandmark.position.vector2d - startLandmark.position.vector2d)
            .oppositeYVector2D.angle()
    }
    
    var center2d: CGPoint {
        (startLandmark.position.vector2d + (endLandmark.position.vector2d - startLandmark.position.vector2d)/2).toCGPoint
    }
    
    var distanceX:Double {
        
        abs(startLandmark.position.x - endLandmark.position.x)
    }
    
    var distanceY:Double {
        abs(startLandmark.position.y - endLandmark.position.y)
    }
    
    var distanceXWithDirection:Double {
        startLandmark.position.x - endLandmark.position.x
    }
    
    var distanceYWithDirection:Double {
        startLandmark.position.y - endLandmark.position.y
    }
    
    var distance:Double {
        endLandmark.position.vector2d.distance(to: startLandmark.position.vector2d)
    }
    
    func relativeDistanceX(to: Double) -> Double {
        self.distanceX/to
    }
    
    func relativeDistanceY(to: Double) -> Double {
        self.distanceY/to
    }
    
    func relativeDistance(to: Double) -> Double {
        self.distance/to
    }
    
    var landmarkSegmentType: LandmarkTypeSegment {
        LandmarkTypeSegment(startLandmarkType: startLandmark.landmarkType, endLandmarkType: endLandmark.landmarkType)
    }
    
    var startAndEndSegment: [Landmark] {
        [startLandmark, endLandmark]
    }
    
    
    
}


