
import Foundation

struct Warning: Codable, Hashable {
  var content: String
  // 提示时机，是条件满足触发还是不满足触发
  var triggeredWhenRuleMet: Bool
  // 延迟多久触发
  var delayTime:Double
// 切换状态是否清除
  var changeStateClear: Bool?
  var isScoreWarning: Bool?
    
    static func == (lhs: Warning, rhs: Warning) -> Bool {
        return lhs.content == rhs.content
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }
}
