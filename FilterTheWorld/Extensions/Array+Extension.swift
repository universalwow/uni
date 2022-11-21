

import Foundation
import SwiftUI




extension String {
    func transformToPinyin(hasBlank: Bool = false) -> String {
        
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef,nil, kCFStringTransformToLatin, false) // 转换为带音标的拼音
        CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false) // 去掉音标
        let pinyin = stringRef as String
        return hasBlank ? pinyin : pinyin.replacingOccurrences(of: " ", with: "")
    }
}

extension Array where Self.Element == Point2D {
    var path : Path {
        var path = Path()
        var area : [Point2D] = []
        area = self
        
        let areaIndics = area.indices
        area.indices.forEach{ index in
          if index == areaIndics.lowerBound {
            path.move(to: area[index].cgPoint)
          }else {
            path.addLine(to: area[index].cgPoint)
          }
        }
        
        path.addLine(to: area[0].cgPoint)
        
        return path
  }
    
    func satisfy(poseMap: PoseMap, landmarkType: LandmarkType) -> Bool {
        let landmarkPoint = poseMap[landmarkType]!
        return self.path.contains(landmarkPoint.vector2d.toCGPoint)
    }
}


//
//extension Array {
//
//    /// 数组内中文按拼音字母排序
//    ///
//    /// - Parameter ascending: 是否升序（默认升序）
//    func sortedByPinyin(ascending: Bool = true) -> Array<String>? {
//        if self is Array<String> {
//            return (self as! Array<String>).sorted { (value1, value2) -> Bool in
//                let pinyin1 = value1.transformToPinyin()
//                let pinyin2 = value2.transformToPinyin()
//                return pinyin1.compare(pinyin2) == (ascending ? .orderedAscending : .orderedDescending)
//            }
//        }
//        return nil
//    }
//}
