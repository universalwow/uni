

import Foundation


//enum ExtremePoint {
//    case minX
//    case maxX
//    case minY
//    case maxY
//}

struct ExtremePoint3D {
    var minX: Point3D
    var maxX: Point3D
    var minY: Point3D
    var maxY: Point3D
    
    init(point: Point3D) {
        self.minX = point
        self.maxX = point
        self.minY = point
        self.maxY = point
    }
}

struct ExtremeObject {
    var minX: Observation
    var maxX: Observation
    var minY: Observation
    var maxY: Observation
    
    init(object: Observation) {
        self.minX = object
        self.maxX = object
        self.minY = object
        self.maxY = object
    }
}

struct StateTime {
    let sportState: SportState
    let time: Double
//    状态变换时的关节信息
    let poseMap: PoseMap
 
////    动态收集物体位置
//    var minYObject:Observation?
//    var maxYObject: Observation?
//    var minXObject:Observation?
//    var maxXObject: Observation?
// 动态收集的物体位置

    var dynamicObjectsMaps:[String: ExtremeObject] = [:]
    
// 动态收集关节点位置
    var dynamicPoseMaps: [LandmarkType: ExtremePoint3D] = [:]
    
}

class Sporter: Identifiable {
    var id = UUID()
    var name:String
    var sport: Sport
    init(name: String, sport: Sport) {
        self.name = name
        self.sport = sport
    }
    
    var currentStateTime: StateTime = StateTime(sportState: SportState.startState, time: 0, poseMap: [:]) {
        
        didSet {
            if currentStateTime.sportState.name == SportState.startState.name {
                stateTimeHistory = [currentStateTime]
            }else {
                stateTimeHistory.append(currentStateTime)
                // 移除无用的前置序列
                if stateTimeHistory.count > sport.scoreStateSequence.map { stateIds in
                    stateIds.count
                }.max()! {
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
    
    // 检测到状态维护的计时器
    var inCheckingStatesTimer: [String: Timer] = [:]
    var inCheckingStateHistory: [String: [Bool]] = [:]
    
    func timer(state: SportState, withTimeInterval: TimeInterval) -> Timer {
        Timer.scheduledTimer(
            withTimeInterval: withTimeInterval, repeats: false) {[self] _ in
                if self.inCheckingStateHistory.keys.contains(state.name) {
                    let result = self.inCheckingStateHistory[state.name]!
                        .reduce((0.0, 0.0), { result, newValue in
                            let total = result.0 + 1
                            let pass = result.1 + (newValue ? 1 : 0)
                        
                            return (total, pass)
                            }
                        )
                    
                    if result.0 > 0 && result.1/result.0 > state.passingRate! {
                        self.scoreTimes.append((0.0, true))
                    }
                    
                    inCheckingStateHistory.removeValue(forKey: state.name)
                    inCheckingStatesTimer.removeValue(forKey: state.name)
                }
                
      
            }
    }
    //
    
    
    func updateCurrentStateObjectBounds(object: Observation?, targetObservation: Observation?, objectLabels: [String]) {
        if stateTimeHistory.endIndex == 0 {
            return
        }
        let index = stateTimeHistory.endIndex - 1
        
        
        objectLabels.forEach { objectLabel in
            var collectedObject : Observation? = nil
            if let _object = object, objectLabel == _object.label {
                collectedObject = _object
            } else if let _object = targetObservation, objectLabel == _object.label {
                collectedObject = _object
            }
            
            if let _collectedObject = collectedObject {
                if stateTimeHistory[index].dynamicObjectsMaps[objectLabel] == nil {
                    stateTimeHistory[index].dynamicObjectsMaps[objectLabel] = ExtremeObject(object: _collectedObject)
                } else {
                    
                    if _collectedObject.rect.midX < stateTimeHistory[index].dynamicObjectsMaps[objectLabel]!.minX.rect.midX {
                        stateTimeHistory[index].dynamicObjectsMaps[objectLabel]!.minX = _collectedObject
                    }
                    
                    if _collectedObject.rect.midX > stateTimeHistory[index].dynamicObjectsMaps[objectLabel]!.maxX.rect.midX {
                        stateTimeHistory[index].dynamicObjectsMaps[objectLabel]!.maxX = _collectedObject
                    }
                    
                    if _collectedObject.rect.midY < stateTimeHistory[index].dynamicObjectsMaps[objectLabel]!.minY.rect.midY {
                        stateTimeHistory[index].dynamicObjectsMaps[objectLabel]!.minY = _collectedObject
                    }
                    
                    if _collectedObject.rect.midY > stateTimeHistory[index].dynamicObjectsMaps[objectLabel]!.maxY.rect.midY {
                        stateTimeHistory[index].dynamicObjectsMaps[objectLabel]!.maxY = _collectedObject
                    }
                    
                    
                }
            }
            
            
            
        }
        
    }
    
    func updateCurrentStateLandmarkBounds(poseMap: PoseMap, landmarkTypes: [LandmarkType]) {
        if stateTimeHistory.endIndex == 0 {
            return
        }
        
        let index = stateTimeHistory.endIndex - 1
        landmarkTypes.forEach { landmarkType in
            let point = poseMap[landmarkType]!
            if stateTimeHistory[index].dynamicPoseMaps[landmarkType] == nil {
                stateTimeHistory[index].dynamicPoseMaps[landmarkType] = ExtremePoint3D(point: point)
            } else {
                
                if point.x < stateTimeHistory[index].dynamicPoseMaps[landmarkType]!.minX.x {
                    stateTimeHistory[index].dynamicPoseMaps[landmarkType]!.minX = point
                }
                
                if point.x > stateTimeHistory[index].dynamicPoseMaps[landmarkType]!.maxX.x {
                    stateTimeHistory[index].dynamicPoseMaps[landmarkType]!.maxX = point
                }
                
                if point.y < stateTimeHistory[index].dynamicPoseMaps[landmarkType]!.minY.y {
                    stateTimeHistory[index].dynamicPoseMaps[landmarkType]!.minY = point
                }
                
                if point.y > stateTimeHistory[index].dynamicPoseMaps[landmarkType]!.maxY.y {
                    stateTimeHistory[index].dynamicPoseMaps[landmarkType]!.maxY = point
                }
                
                
            }
            
        }
        
        
    }
    
    var lastTime: Double = 0
    
    func updateWarnings(allCurrentFrameWarnings: Set<String>) {
        totalWarnings = allCurrentFrameWarnings
    }
    
    // 计时类项目流程
    func playTimer(poseMap:PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
        
        if lastTime > currentTime {
            return
        }
        
        var allCurrentFrameWarnings : Set<String> = []

        let allHasRuleStates = sport.states.filter({ state in
            !state.complexScoreRules.isEmpty
        })
        
        //计分检测
//        如果有一个状态满足
        allHasRuleStates.forEach({ state in
            let satisfy = state.complexRulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
            if satisfy.0 {
//                如果不包含该状态 则建立计时器
                if !inCheckingStatesTimer.keys.contains(state.name) {
                    inCheckingStatesTimer[state.name] = timer(state: state, withTimeInterval: state.checkCycle!)
                }
//                    print("转换状态 - \(currentStateTime.sportState.name) - \(satisfy)")
            } else {
//                如果已经在计时器里 则提示消息
                if self.inCheckingStatesTimer.keys.contains(state.name) {
                    allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
                    print("warnings--------------------\(allCurrentFrameWarnings)")

                }
                //            updateWarnings(allCurrentFrameWarnings: satisfy.1)
            }
            
            if self.inCheckingStatesTimer.keys.contains(state.name) {
                if self.inCheckingStateHistory.keys.contains(state.name) {
                    self.inCheckingStateHistory[state.name]!.append(satisfy.0)
                }else {
                    self.inCheckingStateHistory[state.name] = [satisfy.0]
                }
            }
        })
        
        allCurrentFrameWarnings.remove("")
        
        if currentTime > lastTime {
            lastTime = currentTime
        }
        
        updateWarnings(allCurrentFrameWarnings: allCurrentFrameWarnings)
        
    }
    
    func play(poseMap:PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
        if let sportClass = sport.sportClass {
            switch sportClass {
            case .Counter:
                playCounter(poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize, currentTime: currentTime)
            case .Timer:
                playTimer(poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize, currentTime: currentTime)
            case .TimeCounter: break
                
            case .None: break
                
            }
        }
        
    }
    
    
    func playCounter(poseMap:PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
        
//      收集最低点和最高点
        if !sport.selectedLandmarkTypes.isEmpty {
            updateCurrentStateLandmarkBounds(poseMap: poseMap, landmarkTypes: sport.selectedLandmarkTypes)
        }
        
        if !sport.collectedObjects.isEmpty {
            updateCurrentStateObjectBounds(object: object, targetObservation: targetObject, objectLabels: sport.collectedObjects)
        }
        
        if !stateTimeHistory.isEmpty {
            print("state time \(stateTimeHistory.last)")
        }
        
        // 3秒没切换状态 则重置状态为开始
//        MARK: 添加重置为开始条件 当前太粗暴
        
        if let timeLimit = sport.scoreTimeLimit, currentTime - currentStateTime.time > timeLimit {
//            print("时间间隔3秒")
            currentStateTime  = StateTime(sportState: .startState, time: currentTime, poseMap: poseMap)
        }
        
        // 如果返回顺序错误 则丢弃
        if lastTime > currentTime {
            return
        }
        
        var allCurrentFrameWarnings : Set<String> = []

//        违规逻辑
        let transforms = sport.stateTransForm.filter { currentStateTime.sportState.id == $0.from }
        
        // 只有一个违规逻辑成立 则清空提示
//        全部违规，则违规
        
        let violateRulesTransformSatisfy = transforms.map { transform -> Bool in

            if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
                let satisfy = toState.complexRulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
                if !satisfy.0 {
                    allCurrentFrameWarnings = allCurrentFrameWarnings.union(satisfy.1)
                    //            updateWarnings(allCurrentFrameWarnings: satisfy.1)
                }
                return satisfy.0
            }
            return true
            
        }
//        如果有满足条件的转换 则清空提示消息
        if violateRulesTransformSatisfy.contains(true) {
            allCurrentFrameWarnings = []
        }

//        计分逻辑 状态未切换时判断
        
        var allCurrentFrameScoreWarnings : Set<String> = []

        let scoreRulesTransformSatisfy = transforms.map { transform -> Bool in
            
            if let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to), transform.from == currentStateTime.sportState.id {
                let satisfy = toState.complexRulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
                if satisfy.0  {
                    currentStateTime = StateTime(sportState: toState, time: currentTime, poseMap: poseMap)
//                    print("转换状态 - \(currentStateTime.sportState.name) - \(satisfy)")
                } else {
                    allCurrentFrameScoreWarnings = allCurrentFrameScoreWarnings.union(satisfy.1)
                    //            updateWarnings(allCurrentFrameWarnings: satisfy.1)
                }
                return satisfy.0
            }
            return true
            
        }
        
//        没有状态转换成功 则添加提示
        if !scoreRulesTransformSatisfy.contains(true) && !allCurrentFrameScoreWarnings.isEmpty {
            allCurrentFrameWarnings = allCurrentFrameWarnings.union(allCurrentFrameScoreWarnings)
        }
        
        
        
        
        allCurrentFrameWarnings.remove("")
        // 长度等于计数序列开始判断是否满足计分条件
        
        sport.scoreStateSequence.forEach({ _scoreStateSequence in
            if stateTimeHistory.count >= _scoreStateSequence.count {
                let allStateSatisfy = _scoreStateSequence.indices.allSatisfy{ index in
                    _scoreStateSequence[index] == stateTimeHistory[index + stateTimeHistory.count - _scoreStateSequence.count].sportState.id
                }
                
                var timeSatisfy = true
                
                if let timeLimit = sport.scoreTimeLimit, _scoreStateSequence.count > 1, let startTime = stateTimeHistory.first?.time, let endTime = stateTimeHistory.last?.time {
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
            
        })
        
        
        
        
        if currentTime > lastTime {
            lastTime = currentTime
        }
        
        updateWarnings(allCurrentFrameWarnings: allCurrentFrameWarnings)

        
    }
    
}
