

import Foundation



struct StateTime {
    let sportState: SportState
    let time: Double
//    状态变换时的关节信息
    let poseMap: PoseMap
    var minObject:Observation?
    var maxObject: Observation?
    
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
            
            // 状态切换 取消历史提示
            totalWarnings = []
            
        }
    }
    
    var scoreTimes: [(Double, Bool)] = [] {
        didSet {
            // 计分保留最后一个状态
            stateTimeHistory = [stateTimeHistory.last!]
            
        }
    }
    var totalWarnings: Set<String> = []
    
    
    //  // 当前帧提示，所有存留提示
    //  var cancelingWarnings: Set<String> = []
    //  var newWarnings: Set<String> = []
    
    var stateTimeHistory: [StateTime] = [StateTime(sportState: SportState.startState, time: 0, poseMap: [:])]
    
    
    mutating func updateCurrentStateObjectBounds(object: Observation) {
        if stateTimeHistory.endIndex == 0 {
            return
        }
        let index = stateTimeHistory.endIndex - 1
        if stateTimeHistory[index].minObject == nil {
            stateTimeHistory[index].minObject = object
            stateTimeHistory[index].maxObject = object
        }else {
            
            if object.rect.midY < stateTimeHistory[index].minObject!.rect.midY {
                stateTimeHistory[index].minObject = object
            }
            
            if object.rect.midY > stateTimeHistory[index].maxObject!.rect.midY {
                stateTimeHistory[index].maxObject = object
            }
            
            
        }
        
    }
    
    var lastTime: Double = 0
    
    mutating func updateWarnings(allCurrentFrameWarnings: Set<String>) {
        totalWarnings = allCurrentFrameWarnings
    }
    
    
    mutating func play(poseMap:PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
//      收集最低点和最高点
        if let object = object {
            updateCurrentStateObjectBounds(object: object)
        }
        
        // 3秒没切换状态 则重置状态为开始
        if currentTime - currentStateTime.time > 3 {
            print("时间间隔3秒")
            currentStateTime  = StateTime(sportState: .startState, time: currentTime, poseMap: poseMap)
        }
        
        // 如果返回顺序错误 则丢弃
        if lastTime > currentTime {
            return
        }
        
        var allCurrentFrameWarnings : Set<String> = []
        // 违规逻辑
//        if currentStateTime.sportState.id == SportState.startState.id {
////            起始状态可以转变为单个状态
////            let transform = sport.stateTransForm.first { currentStateTime.sportState.id == $0.from }!
////            if let startState = sport.findFirstSportStateByUUID(editedStateUUID: transform.from)
////            {
////                let satisfy = startState.complexScoreRulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object,targetObject: targetObject, frameSize: frameSize)
////                if !satisfy.0 {
////                    allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
////                    //          updateWarnings(allCurrentFrameWarnings: satisfy.1)
////                }
////            }
//            // 起始状态可以转变为多个状态
//            let transforms = sport.stateTransForm.filter { currentStateTime.sportState.id == $0.from }
//            transforms.forEach{ transform in
//                if let startState = sport.findFirstSportStateByUUID(editedStateUUID: transform.from)
//                {
//                    let satisfy = startState.complexScoreRulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object,targetObject: targetObject, frameSize: frameSize)
//                    if !satisfy.0 {
//                        allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
//                        //          updateWarnings(allCurrentFrameWarnings: satisfy.1)
//                    }
//                }
//            }
//
//        } else {
//            // 之后的状态转换
////            let transform = sport.stateTransForm.first { currentStateTime.sportState.id == $0.from }!
////            if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
////                let satisfy = toState.complexScoreRulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
////                if !satisfy.0 {
////                    allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
////                    //            updateWarnings(allCurrentFrameWarnings: satisfy.1)
////                }
////            }
//
//            let transforms = sport.stateTransForm.filter { currentStateTime.sportState.id == $0.from }
//            transforms.forEach { transform in
//
//                if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
//                    let satisfy = toState.complexScoreRulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
//                    if !satisfy.0 {
//                        allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
//                        //            updateWarnings(allCurrentFrameWarnings: satisfy.1)
//                    }
//                }
//            }
//
//
//
//        }
        
        
//        let transforms = sport.stateTransForm.filter { currentStateTime.sportState.id == $0.from }
//        transforms.forEach { transform in
//
//            if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
//                let satisfy = toState.complexScoreRulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
//                if !satisfy.0 {
//                    allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
//                    //            updateWarnings(allCurrentFrameWarnings: satisfy.1)
//                }
//            }
//        }
//
//        // 计分逻辑 当前状态为开始状态 使用开始状态检查
//        if currentStateTime.sportState.id == SportState.startState.id {
////             起始状态可以转变为单个状态
////            let transform = sport.stateTransForm.first { currentStateTime.sportState.id == $0.from }!
////            if let startState = sport.findFirstSportStateByUUID(editedStateUUID: transform.from),
////               let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to)
////            {
////                let satisfy = startState.complexScoreRulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
////                if satisfy.0 {
////                    currentStateTime = StateTime(sportState: toState, time: currentTime, poseMap: poseMap)
////                } else {
////                    allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
////                    //          updateWarnings(allCurrentFrameWarnings: satisfy.1)
////                }
////            }
//
//            //             起始状态可以转变为多个状态
//
//            let transforms = sport.stateTransForm.filter { currentStateTime.sportState.id == $0.from }
//            transforms.forEach { transform in
//                if let startState = sport.findFirstSportStateByUUID(editedStateUUID: transform.from),
//                   let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to)
//                {
//                    let satisfy = startState.complexScoreRulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
//                    if satisfy.0 {
//                        currentStateTime = StateTime(sportState: toState, time: currentTime, poseMap: poseMap)
//                    } else {
//                        allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
//                        //          updateWarnings(allCurrentFrameWarnings: satisfy.1)
//                    }
//                }
//            }
//
//
//
//        } else {
//            // 之后的状态转换
////            let transform = sport.stateTransForm.first { currentStateTime.sportState.id == $0.from }!
////            if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
////                let satisfy = toState.complexScoreRulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
////                if satisfy.0  {
////                    currentStateTime = StateTime(sportState: toState, time: currentTime, poseMap: poseMap)
////                } else {
////                    allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
////                    //            updateWarnings(allCurrentFrameWarnings: satisfy.1)
////                }
////            }
//            let transforms = sport.stateTransForm.filter { currentStateTime.sportState.id == $0.from }
//            transforms.forEach { transform in
//                if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
//                    let satisfy = toState.complexScoreRulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
//                    if satisfy.0  {
//                        currentStateTime = StateTime(sportState: toState, time: currentTime, poseMap: poseMap)
//                    } else {
//                        allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
//                        //            updateWarnings(allCurrentFrameWarnings: satisfy.1)
//                    }
//                }
//
//            }
//
//        }
        
        let transforms = sport.stateTransForm.filter { currentStateTime.sportState.id == $0.from }
        transforms.forEach { transform in
            if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
                let satisfy = toState.complexScoreRulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
                if satisfy.0  {
                    currentStateTime = StateTime(sportState: toState, time: currentTime, poseMap: poseMap)
                } else {
                    allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
                    //            updateWarnings(allCurrentFrameWarnings: satisfy.1)
                }
            }
            
        }
        
        
        allCurrentFrameWarnings.remove("")
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
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(["时间间隔过长"])
                print("时间间隔过长 \(currentTime) - \(allStateSatisfy)")
            }
            
            
            if allStateSatisfy && timeSatisfy {
                // 检查状态改变后是否满足多帧条件 决定是否计分
                scoreTimes.append((currentTime, true))

                
            }
            
            
        }
        
        
        
        if currentTime > lastTime {
            lastTime = currentTime
        }
        updateWarnings(allCurrentFrameWarnings: allCurrentFrameWarnings)

        
    }
    
}
