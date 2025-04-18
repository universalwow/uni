

import Foundation

protocol Ruler: Codable {
    var id: String { get set }
    var ruleClass: RuleClass { get set } 
    func allSatisfy(stateTimeHistory: [StateTime], poseMap: PoseMap, lastPoseMap: PoseMap, objects: [Observation], frameSize: Point2D) -> (Bool, Set<Warning>, Int, Int)
}
