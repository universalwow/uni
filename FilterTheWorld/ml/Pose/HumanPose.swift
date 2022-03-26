//
//  Pose.swift
//  SBUI-iSport
//
//  Created by uniwow on 2021/6/25.
//  Copyright © 2021 陌路. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


typealias PoseMap = [LandmarkType: Point3D]

struct HumanPose:Identifiable {
  var id: Int
  //关节点
  private(set) var landmarks:[Landmark] = []
  private(set) var landmarkSegments :[LandmarkSegment] = []
  mutating func addElement(landmark:Landmark) {
    self.landmarks.append(landmark)
  }
}

extension HumanPose {
  var landmarksMaps: PoseMap {
    landmarks.reduce(PoseMap()) { (dict, landmark) -> PoseMap in
        var dict = dict
      dict[landmark.landmarkType] = landmark.position
        return dict
    }
  }
}


extension HumanPose {
  func landmarkTypePairsToSegments(landmarkMaps:PoseMap,
                                   landmarkTypePairs: [[LandmarkType]], color:Color) -> [LandmarkSegment] {
    var landmarkSegments:[LandmarkSegment]  = []
    for line in landmarkTypePairs {
        for index in line.indices {
          if (index == line.count - 1) {
            break
          }
          landmarkSegments.append(
            LandmarkTypeSegment(startLandmarkType: line[index], endLandmarkType: line[index + 1]).landmarkSegment(poseMap: landmarkMaps, color: color)
          )
        }
                                         
    }
    return landmarkSegments
  }
  
  mutating func initLandmarkSegments() {
    let landmarkMaps = self.landmarksMaps
    landmarkSegments = []
    landmarkSegments.append(contentsOf:
                              landmarkTypePairsToSegments(
                                landmarkMaps: landmarkMaps,
                                landmarkTypePairs: LandmarkType.leftBodyLines,
                                color: .blue)
    )
    landmarkSegments.append(contentsOf:
                              landmarkTypePairsToSegments(
                                landmarkMaps: landmarkMaps,
                                landmarkTypePairs: LandmarkType.rightBodyLines,
                                color: .green)
    )
    landmarkSegments.append(contentsOf:
                              landmarkTypePairsToSegments(
                                landmarkMaps: landmarkMaps,
                                landmarkTypePairs: LandmarkType.otherLines,
                                color: .white)
                            
    )
  }
}


extension HumanPose {
  mutating func selectLandmarkSegment(selectedlandmarkSegment: LandmarkSegment) {
    landmarkSegments[
      landmarkSegments.firstIndex{ landmarkSegment in
        landmarkSegment.id == selectedlandmarkSegment.id
      }!
    ].selected.toggle()
  }
  
  
  mutating func toggle() {
    landmarkSegments.indices.forEach { index in
      landmarkSegments[index].selected.toggle()
      
    }
  }
  
  mutating func noselected() {
    landmarkSegments.indices.forEach { index in
      landmarkSegments[index].selected = false
      
    }
  }
  
  var isSelected: Bool {
    landmarkSegments.contains{ landmarkSegment in
      landmarkSegment.selected
    }
  }
  
  
  mutating func updateSegmentAngleRange(selectedlandmarkSegment: LandmarkSegment) {
    landmarkSegments[
      landmarkSegments.firstIndex{ landmarkSegment in
        landmarkSegment.id == selectedlandmarkSegment.id
      }!
    ].angleRange = selectedlandmarkSegment.angleRange
  }
  
}









