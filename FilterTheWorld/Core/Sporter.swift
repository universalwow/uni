

import Foundation



struct StateTime {
  let sportState: SportState
  let time: Double
  let poseMap: PoseMap
}

struct Sporter: Identifiable {
  var id = UUID()
  var name:String
  var sport: Sport
  
  var currentStateTime: StateTime = StateTime(sportState: SportState.startState, time: 0, poseMap: [:]) {
    
    didSet {
      if currentStateTime.sportState.name == SportState.startState.name {
        stateTimeHistory = [currentStateTime]
      }else {
        stateTimeHistory.append(currentStateTime)
        // 移除无用的前置序列
        if stateTimeHistory.count > sport.scoreStateSequence.count {
          stateTimeHistory.remove(at: 0)
        }
        
      }
    }
  }
  
  var scoreTimes: [(Double, Bool)] = [] {
    didSet {
      // 计分保留最后一个状态
      stateTimeHistory = [stateTimeHistory.last!]
      totalWarnings = []
      cancelingWarnings = []
      newWarnings = []
    }
  }
  var totalWarnings: Set<String> = []
  // 当前帧提示，所有存留提示
  var cancelingWarnings: Set<String> = []
  var newWarnings: Set<String> = []
  
  var stateTimeHistory: [StateTime] = []
  
  
  mutating func play(poseMap:PoseMap, currentTime: Double) {
    
    if let lastScoreTime = scoreTimes.last, (lastScoreTime.0 >= currentTime) {
      print("score time \(lastScoreTime.0)/\(currentTime)")
      scoreTimes.removeAll{ scoreTime in
        
        scoreTime.0 >= currentTime
      }
      currentStateTime  = StateTime(sportState: .startState, time: currentTime, poseMap: [:])
    }

    // 违规逻辑
    sport.stateTransForm.forEach({ transform in
//      if currentStateTime.sportState.id == transform.from {
      if let toState = sport.findFirstSportStateByUUID(editedStateUUID: currentStateTime.sportState.id) {
          var allCurrentFrameWarnings:Set<String> = []
          toState.currentStateViolateWarning(poseMap: poseMap).forEach{ warns in
            allCurrentFrameWarnings = allCurrentFrameWarnings.union(warns)
          }

          // 取消的提示
          cancelingWarnings = totalWarnings.subtracting(allCurrentFrameWarnings)
          // 当前新添加
          newWarnings = allCurrentFrameWarnings.subtracting(totalWarnings)
          
          // 之前存在的提示
          let oldWarnings = totalWarnings.intersection(allCurrentFrameWarnings)
          totalWarnings = newWarnings.union(oldWarnings)
          print("warning \(totalWarnings.count)/\(cancelingWarnings.count)")
          totalWarnings.forEach{ string in
            print("warning \(string)")
            
          }
        
          cancelingWarnings.forEach{ string in
            print("warning cancel \(string)")
          }
        }
//        }
      })
    
    
    // 计分逻辑
    if currentStateTime.sportState.id == SportState.startState.id {
      sport.stateTransForm.forEach({ transform in
        if currentStateTime.sportState.id == transform.from {
          if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
              if toState.complexScoreRulesSatisfy(poseMap: poseMap) {
                currentStateTime = StateTime(sportState: toState, time: currentTime, poseMap: poseMap)
              }
            }
        }
      })
      return
    }
    
    
    sport.stateTransForm.forEach({ transform in
      if currentStateTime.sportState.id == transform.from {
        if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
          if toState.complexScoreRulesSatisfy(poseMap: poseMap) && toState.complexScoreRulesMultiFrameSatisfy(stateTimeHistory: stateTimeHistory, poseMap: poseMap) {
            currentStateTime = StateTime(sportState: toState, time: currentTime, poseMap: poseMap)
          }
        }
      }
    })
    
    
    // 长度等于计数序列开始判断是否满足计分条件
    if stateTimeHistory.count == sport.scoreStateSequence.count {
      let allStateSatisfy = sport.scoreStateSequence.indices.allSatisfy{ index in
        sport.scoreStateSequence[index].name == stateTimeHistory[index].sportState.name
      }
      
      var timeSatisfy = true
      
      if let timeLimit = sport.scoreTimeLimit, sport.scoreStateSequence.count > 1, let startTime = stateTimeHistory.first?.time, let endTime = stateTimeHistory.last?.time {
        if endTime - startTime > timeLimit {
          timeSatisfy = false
        }
      }
      
      
      // 时间间隔不满足 抛出warning
      if !timeSatisfy {
        
      }
      
      if allStateSatisfy && timeSatisfy {
        // 检查状态改变后是否满足多帧条件 决定是否计分
        scoreTimes.append((currentTime,true))
//        if stateTimeHistory.last!.sportState.complexScoreRulesMultiFrameSatisfy(stateTimeHistory: stateTimeHistory) {
//
//        }else {
//          scoreTimes.append((currentTime,false))
//        }
        
      }
      
      
    }
    
    
    
    
    
  }
  
}
