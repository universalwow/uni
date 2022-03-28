

import Foundation


enum MarkType {
  case dot
  case rect
}


// 作为提示项
enum ObjectType: String {
  case person
  case rope
}



enum AnnotationType {
  case person
  case object
}


struct Annotation {
  var humanPoses: [HumanPose] = []
  var objects: [Observation]
  
}
