

import Foundation



struct StateTime {
  let sportState: SportState
  let time: Double
}

struct Sporter {
  var name:String
  var sport: Sport
  
  
  var currentStateTime: StateTime = StateTime(sportState: SportState.startState, time: 0) {
    
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
  
  var scoreTimes: [Double] = [] {
    didSet {
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
    
    if let lastScoreTime = scoreTimes.last, (lastScoreTime >= currentTime) {
      scoreTimes.removeAll{ scoreTime in
        scoreTime >= currentTime
      }
      currentStateTime  = StateTime(sportState: .startState, time: currentTime)
      
    }

    // 违规逻辑
    sport.stateTransForm.forEach({ transform in
      if currentStateTime.sportState.id == transform.from {
        if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
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
        }
        }
      })
    
    
    // 计分逻辑
    sport.stateTransForm.forEach({ transform in
      if currentStateTime.sportState.id == transform.from {
        if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
          if toState.complexScoreRulesSatisfy(poseMap: poseMap) {
            currentStateTime = StateTime(sportState: toState, time: currentTime)
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
      
      if let timeLimit = sport.timeLimit, sport.scoreStateSequence.count > 1, let startTime = stateTimeHistory.first?.time, let endTime = stateTimeHistory.last?.time {
        if endTime - startTime > timeLimit {
          timeSatisfy = false
        }
      }
      
      if allStateSatisfy && timeSatisfy {
        scoreTimes.append(currentTime)
      }
      
      
    }
    
    
    
    
    
  }
  
}
