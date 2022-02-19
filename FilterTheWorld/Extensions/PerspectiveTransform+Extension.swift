
import Foundation
import PerspectiveTransform
import simd

extension Perspective {
  func getspectiveTransform(to: Perspective) -> float3x3 {
    let transform = self.projectiveTransform(destination: to)
    return float3x3(rows: [
        simd_float3(transform.m11.float, transform.m21.float, transform.m41.float),
        simd_float3(transform.m12.float, transform.m22.float, transform.m42.float),
        simd_float3(transform.m14.float, transform.m24.float, transform.m44.float)
        ])
  }
}
