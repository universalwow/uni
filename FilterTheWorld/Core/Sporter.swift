

import Foundation

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
    let stateId: Int
    let time: Double
//    状态变换时的关节信息
    let poseMap: PoseMap
    let object: Observation?
 
// 动态收集的物体位置

    var dynamicObjectsMaps:[String: ExtremeObject] = [:]
    
// 动态收集关节点位置
    var dynamicPoseMaps: [LandmarkType: ExtremePoint3D] = [:]
    
}


struct ScoreTime: Identifiable, Codable {
    var stateId: Int
    var time: Double
    var vaild: Bool
    let poseMap: PoseMap
    let object: Observation?
    
    var id: String {
        "\(stateId)-\(time)"
    }
}
struct WarningData : Identifiable, Codable {
    var warning: Warning
    var stateId: Int
    var time: Double
    
    var id: String {
        "\(stateId)-\(warning.content)-\(time)"
    }
}

struct SportReport: Identifiable, Codable {
    var id = UUID()
    var sporterName:String
    var sportName: String
    var sportClass: SportClass?
    var sportPeriod: SportPeriod?
    var startTime = -1.0
    var endTime = -1.0
    var statesDescription: [StateDescription]?
    var scoreTimes: [ScoreTime] = []
    var allStateTimes: [ScoreTime]?
    var warnings: [WarningData] = []
    var createTime: Double?
    
    
    
    var warningsGroupByContents: [String] {
        self.warnings.reduce([String](), { (result, newWarning) in
            var newResult = result
            if !newResult.contains(newWarning.warning.content) {
                newResult.append(newWarning.warning.content)
            }
            return newResult
        })
    }
    
    
    var fileName: String {
        "\(self.id).json"
    }
    
    var sportFullName: String {
        "\(self.sportName)\(self.sportClass?.rawValue != nil ? "-\(self.sportClass!.rawValue)" : "" )\(self.sportPeriod?.rawValue != nil ? "-\(self.sportPeriod!.rawValue)" : "")"
    }
    
    var sportTime: String {
        let time = self.endTime - self.startTime
        let minutes = Int(time/60)
        let seconds = Int(time) % 60
        return "\(minutes > 0 ? "\(minutes)分" : "")\(seconds > 0 ? "\(seconds)秒" : "")"
    }
    
    func findStateDescription(stateId: Int) -> StateDescription {
        return self.statesDescription!.first(where: { stateDescription in
            print("statesDescription \(stateDescription) - \(stateId)")
            return stateDescription.stateId == stateId
        })!
    }
    
    func findStateScoreTimes(stateId: Int) -> [ScoreTime] {
        self.scoreTimes.filter( { scoreTime in
            scoreTime.stateId == stateId
        })
    }
    
    func filterWarningsByContent(content: String) -> Int {
        self.warnings.filter({ warning in
            warning.warning.content == content
        }).count
    }
    
    var sortWarningsByTime : [WarningData] {
        self.warnings.sorted(by: { (leftWarning, rightWarning) in
            leftWarning.time < rightWarning.time
        })
    }
    
    var scoreTimesGroup: [Int:Int] {
        print("result \(self.scoreTimes)")
        return self.scoreTimes.reduce([Int:Int]()) { (result, nextScoreTime) in
            var newResult = result
            if newResult.keys.contains(nextScoreTime.stateId) {
                newResult[nextScoreTime.stateId] = newResult[nextScoreTime.stateId]! + 1
            }else{
                newResult[nextScoreTime.stateId] = 1
            }
            print("result \(newResult)")
            return newResult
        }
    }
    
    var scoreStates: [Int] {
        print("result \(self.scoreTimes)")
        return self.scoreTimes.reduce([Int]()) { (result, nextScoreTime) in
            var newResult = result
            if !newResult.contains(nextScoreTime.stateId) {
                newResult.append(nextScoreTime.stateId)
            }
            print("result \(newResult)")
            return newResult
        }
    }
    
    
    static func timeFormater(time: Double) -> String {
        if time < 1000000 {
            return String(time)
        }else {
            let date = Date(timeIntervalSince1970: time)
//            let zone = NSTimeZone.system // 获得系统的时区
//            let addSeconds = zone.secondsFromGMT(for: date)
//            date.addTimeInterval(TimeInterval(addSeconds))
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            return dateFormatter.string(from: date)
        }
    }
    
    static func secondFormater(time: Double) -> String {
        let minutes = Int(time/60)
        let seconds = Int(time) % 60
        let milliseconds = Int((time - Double(minutes * 60 + seconds)) * 1000)
        return "\(minutes > 0 ? "\(minutes)分" : "")\(seconds > 0 ? "\(seconds)秒" : "")\(milliseconds)毫秒"
    }
}

class Sporter: Identifiable {
    var id = UUID()
    var name:String
    var sport: Sport
    var onStateChange: () -> Void
    init(name: String, sport: Sport, onStateChange: @escaping () -> Void) {
        self.name = name
        self.sport = sport
        self.onStateChange = onStateChange
    }
    
    deinit {
        print("deinit---------------")
        cancelableWarningMap.keys.forEach({ key in
            cancelableWarningMap[key]?.invalidate()
            cancelableWarningMap.removeValue(forKey: key)
        })
        inCheckingStatesTimer.keys.forEach({ key in
            inCheckingStatesTimer[key]?.invalidate()
            inCheckingStatesTimer.removeValue(forKey: key)
        })
    }
    
    var allStateTimeHistory :[ScoreTime] = []
    
    var nextStatePreview = SportState.startState
    var currentStateTime = StateTime(stateId: SportState.startState.id, time: 0, poseMap: [:], object: nil) {
        
        didSet {
            if currentStateTime.stateId == SportState.startState.id {
                stateTimeHistory = [currentStateTime]
            }else {
                
                stateTimeHistory.append(currentStateTime)
//                print("state change time history \(currentStateTime.stateId) \(currentStateTime.time)")
                // 移除无用的前置序列
//                if !sport.scoreStateSequence.isEmpty && stateTimeHistory.count > sport.scoreStateSequence.map { stateIds in
//                    stateIds.count
//                }.max()! {
//                    stateTimeHistory.remove(at: 0)
//                }
                
                
                sport.scoreStateSequence.forEach({ _scoreStateSequence in
                    if stateTimeHistory.count >= _scoreStateSequence.count {
                        let allStateSatisfy = _scoreStateSequence.indices.allSatisfy{ index in
                            _scoreStateSequence[index] == stateTimeHistory[index + stateTimeHistory.count - _scoreStateSequence.count].stateId
                        }
          
                        if allStateSatisfy {
                            // 检查状态改变后是否满足多帧条件 决定是否计分
                            if sport.sportClass == .Counter {
                                scoreTimes.append(
                                    ScoreTime(stateId: currentStateTime.stateId, time: currentStateTime.time, vaild: true, poseMap: currentStateTime.poseMap, object: currentStateTime.object)
                                )

                            }else {
                                scoreTimes.append(contentsOf: timerScoreTimes)
                            }

                        }
                        
                    }
                    
                })
                timerScoreTimes = []
                
                if currentStateTime.stateId != SportState.readyState.id {
                    self.onStateChange()
                }
            }
            
            allStateTimeHistory.append(ScoreTime(stateId: currentStateTime.stateId, time: currentStateTime.time, vaild: true, poseMap: currentStateTime.poseMap, object: currentStateTime.object))
        }
    }
    
    var nextState = SportState.startState
    
    var scoreTimes: [ScoreTime] = [] {
        didSet {
            // 计分保留最后一个状态
            
            if oldValue.count > scoreTimes.count {
                return
            }
            
//            stateTimeHistory = [stateTimeHistory.last!]

        }
    }
    
    var delayWarnings: Set<String> = []
    var noDelayWarnings: Set<String> = []
//    MARK: 第一次捕获到时 添加到延迟展示
//    当下一帧消失时 未必想取消该展示 比如运球过低 是在等高位置的出现
//    开合跳之类的不存在这种问题是因为开合之间没有中间状态
    
    var timerScoreTimes: [ScoreTime] = [] {
        didSet {
            
            if oldValue.count > timerScoreTimes.count {
                return
            }
            if timerScoreTimes.isEmpty {
                return
            }
            
            let last_1 = timerScoreTimes.last!
            let state = sport.findFirstStateByStateId(stateId: last_1.stateId)!


            if sport.sportDiscrete == .Continuous && timerScoreTimes.count > 1 {
                let last_2 = timerScoreTimes[timerScoreTimes.count - 2]
                
                if last_2.stateId == last_1.stateId {
                    if last_1.time - last_2.time > state.checkCycle! + 0.5 {
                        // 如果不连续 则只保留最后一个
                        timerScoreTimes = [last_1]
                    }
                    
                } else {
                    // 状态不同 则只保留最后一个
                    timerScoreTimes = [last_1]
                }
            } else if sport.sportDiscrete == .Discrete && timerScoreTimes.count > 1 {
                //  如果是离散的 则只保留最后一个
                let last_1 = timerScoreTimes.last!
                let last_2 = timerScoreTimes[timerScoreTimes.count - 2]
                if last_1.stateId != last_2.stateId {
                    timerScoreTimes = [last_1]
                }
            }
            
            
            if timerScoreTimes.count == state.keepTime!.toInt {
                currentStateTime = StateTime(stateId: state.id, time: last_1.time, poseMap: last_1.poseMap, object: last_1.object)
            }
        }

    }

    
    var stateTimeHistory: [StateTime] = [StateTime(stateId: SportState.startState.id, time: 0, poseMap: [:], object: nil)]
    
  
    var cancelableWarningMap: [String: Timer] = [:]
    
    var warningsData: [WarningData] = []
    
    func warningTimer(warning: WarningData) -> Timer {
        let timer =
        Timer.scheduledTimer(
            withTimeInterval: warning.warning.delayTime, repeats: false) { [self] timer in

                DispatchQueue.main.async {
                    self.delayWarnings.insert(warning.warning.content)
                    self.warningsData.append(warning)
                }
        
                timer.invalidate()
                
            }
        return timer

    }

    
    var inCheckingStateHistory: [String: [Bool]] = [:]
    // 检测到状态维护的计时器
    var inCheckingStatesTimer: [String: Timer] = [:]
    
    func checkStateTimer(state: SportState, currentTime: Double, withTimeInterval: TimeInterval, poseMap: PoseMap, object: Observation?) -> Timer {
        Timer.scheduledTimer(
            withTimeInterval: withTimeInterval, repeats: false) {[self] timer in
                if self.inCheckingStateHistory.keys.contains(state.name) {
                    let result = self.inCheckingStateHistory[state.name]!
                        .reduce((0.0, 0.0), { result, newValue in
                            let total = result.0 + 1
                            let pass = result.1 + (newValue ? 1 : 0)
                        
                            return (total, pass)
                            }
                        )
                    
                    if result.0 > 0 && result.1/result.0 > state.passingRate! {
                        self.timerScoreTimes.append(
                            ScoreTime(stateId: state.id, time: currentTime, vaild: true, poseMap: poseMap, object: object)
                        )
                        nextStatePreview = state
                    }
                    
                    timer.invalidate()
                    inCheckingStateHistory.removeValue(forKey: state.name)
                    inCheckingStatesTimer.removeValue(forKey: state.name)
                }
                
      
            }
    }
    //
    
    
    func updateCurrentStateObjectBounds(object: Observation?, targetObservation: Observation?, objectLabels: [String]) {
        if stateTimeHistory.isEmpty {
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
        if stateTimeHistory.isEmpty {
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
    
    func updateWarnings(currentTime: Double, allCurrentFrameWarnings: Set<Warning>) {
        noDelayWarnings = []
        allCurrentFrameWarnings.forEach { warning in
            if warning.delayTime < 0.3 {
                noDelayWarnings.insert(warning.content)
                self.warningsData.append(WarningData(warning: warning, stateId: currentStateTime.stateId, time: currentTime))
            }
        }

        let totalWarnings =
        allCurrentFrameWarnings.map { warning in
            WarningData(warning: warning, stateId: currentStateTime.stateId, time: currentTime)
            
        }
        // 所有存在 totalWarnings 而不在 map 中的规则 加入map
        // 所有不存在 totalWarnings 而在 map中的 取消
        // 存在双方的 不管
        let cancelWarnings = cancelableWarningMap.map { warning, _ in
            warning
        }.filter { warning in
            !totalWarnings.contains(where: { newWarning in
                warning == newWarning.warning.content
            })
        }
        cancelWarnings.forEach { cancelWarning in

            cancelableWarningMap[cancelWarning]?.invalidate()
            cancelableWarningMap.removeValue(forKey: cancelWarning)
        }
        
        DispatchQueue.main.async {
            self.delayWarnings = self.delayWarnings.subtracting(cancelWarnings)
        }
        
        totalWarnings.filter { newWarning in
            !cancelableWarningMap.contains(where: { warning, _ in
                warning == newWarning.warning.content
            })
        }.forEach { newWarning in
            if newWarning.warning.delayTime >= 0.3 {
                cancelableWarningMap[newWarning.warning.content] = warningTimer(warning: newWarning)
            }
            
        }
    }
    
    func play(poseMap:PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
        switch sport.sportClass {
        case .Counter:
            playCounter(poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize, currentTime: currentTime)
        case .Timer:
            playTimer(poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize, currentTime: currentTime)
        case .TimeCounter:
            
            playTimeCounter(poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize, currentTime: currentTime)
            
        case .None: break
            
        }
        
    }
    
    // 计时类项目流程
    func playTimer(poseMap:PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
        
        if lastTime > currentTime {
            return
        }
        
        if !sport.selectedLandmarkTypes.isEmpty {
            updateCurrentStateLandmarkBounds(poseMap: poseMap, landmarkTypes: sport.selectedLandmarkTypes)
        }
        
        if !sport.collectedObjects.isEmpty {
            updateCurrentStateObjectBounds(object: object, targetObservation: targetObject, objectLabels: sport.collectedObjects)
        }
        
        var allCurrentFrameWarnings : Set<Warning> = []

        let allHasRuleStates = sport.states.filter({ state in
            sport.scoreStateSequence.flatMap({ states in
                states
            }).contains(state.id)
        })
        
        //如果有一个状态满足
        
        let allRulesSatisfy = allHasRuleStates.map({state -> (Bool, Set<Warning>, Int, Int) in
            let satisfy = state.rulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
            if satisfy.0 {
//                如果不包含该状态 则建立计时器
                if !inCheckingStatesTimer.keys.contains(state.name) {
                    inCheckingStatesTimer[state.name] = checkStateTimer(state: state, currentTime: currentTime, withTimeInterval: state.checkCycle!, poseMap: poseMap, object: object)
                }
            }

            
            if self.inCheckingStatesTimer.keys.contains(state.name) {
                if self.inCheckingStateHistory.keys.contains(state.name) {
                    self.inCheckingStateHistory[state.name]!.append(satisfy.0)
                }else {
                    self.inCheckingStateHistory[state.name] = [satisfy.0]
                }
            }
            
            return satisfy
        })
        
        
        if allRulesSatisfy.count == 1 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfy[0].1)
        } else if allRulesSatisfy.count > 1 {
            let allRulesSatisfySorted = allRulesSatisfy.sorted(by: {($0).2 >= ($1).2})
            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
            }
            allRulesSatisfySorted.filter{ (_, warnings, _ , _) in
                warnings.contains(where: { warning in
                    warning.triggeredWhenRuleMet
                })
            }.forEach({ (satisfy, warnings, _ , _) in
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(warnings)
            }
            )
        }
        
        if allRulesSatisfy.contains(where: { (satisfy, warnings, _, _) in
            satisfy && !warnings.contains(where: { warning in
                warning.triggeredWhenRuleMet
            })
        }) {
            allCurrentFrameWarnings = []
        }
        
        if self.inCheckingStatesTimer.isEmpty {
            if self.scoreTimes.isEmpty {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union([
                    Warning(content: "开始\(sport.name)", triggeredWhenRuleMet: true, delayTime: sport.warningDelay)
                ])
                
            } else {
                let allRulesSatisfySorted = allRulesSatisfy.sorted(by: {($0).2 >= ($1).2})
                if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                    allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
                }
                
                allCurrentFrameWarnings = allCurrentFrameWarnings.union([
                    Warning(content: "继续\(sport.name)", triggeredWhenRuleMet: true, delayTime: sport.warningDelay)
                    
                ])
    
            }
            
        }
        
        if currentTime > lastTime {
            lastTime = currentTime
        }
        
        allCurrentFrameWarnings.remove(Warning(content: "", triggeredWhenRuleMet: false, delayTime: 0.0))
        updateWarnings(currentTime: currentTime, allCurrentFrameWarnings: allCurrentFrameWarnings)
        
    }
    
    func playTimeCounter(poseMap:PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
        
        // 如果返回顺序错误 则丢弃
        if lastTime > currentTime {
            return
        }
        
        
//      收集最低点和最高点
        if !sport.selectedLandmarkTypes.isEmpty {
            updateCurrentStateLandmarkBounds(poseMap: poseMap, landmarkTypes: sport.selectedLandmarkTypes)
        }
        
        if !sport.collectedObjects.isEmpty {
            updateCurrentStateObjectBounds(object: object, targetObservation: targetObject, objectLabels: sport.collectedObjects)
        }
        
 
    
        var allCurrentFrameWarnings : Set<Warning> = []

//        违规逻辑
        let transforms = sport.stateTransForm.filter { currentStateTime.stateId == $0.from }
        
        let violateRulesTransformSatisfy = transforms.map { transform -> (Bool, Set<Warning>, Int, Int) in

            if let toState = sport.findFirstStateByStateId(stateId: transform.to) {
                let satisfy = toState.rulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
                return satisfy
            }
            return (false, [], 0, 0)
            
        }
        // 违规逻辑 1.如果只有一个转换 则直接给提醒 2.如果有多个转换, 提示符合条多的那一个
        // 如果有满足条件的违规 则清空

        if violateRulesTransformSatisfy.count == 1 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(violateRulesTransformSatisfy[0].1)
        } else if violateRulesTransformSatisfy.count > 1 {
            let allRulesSatisfySorted = violateRulesTransformSatisfy.sorted(by: {($0).2 >= ($1).2})
            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
            }
            allRulesSatisfySorted.filter{ (_, warnings, _ , _) in
                warnings.contains(where: { warning in
                    warning.triggeredWhenRuleMet
                })
            }.forEach({ (_, warnings, _ , _) in
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(warnings)
            }
            )
        }
        
        if violateRulesTransformSatisfy.contains(where: { (satisfy, warnings, _, _) in
            satisfy && !warnings.contains(where: { warning in
                warning.triggeredWhenRuleMet
            })
        }) {
            allCurrentFrameWarnings = []
        }

//        计分逻辑 状态未切换时判断
   
        let scoreRulesTransformSatisfy = transforms.map { transform -> (Bool, Set<Warning>, Int, Int) in
            
            if let toState = sport.findFirstStateByStateId(stateId: transform.to), transform.from == currentStateTime.stateId {
                nextState = toState
                let satisfy = toState.rulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
                if satisfy.0  {
                    if !inCheckingStatesTimer.keys.contains(toState.name) {
                        inCheckingStatesTimer[toState.name] = checkStateTimer(state: toState, currentTime: currentTime, withTimeInterval: toState.checkCycle!, poseMap: poseMap, object: object)
                    }
                }
                
                if self.inCheckingStatesTimer.keys.contains(toState.name) {
                    if self.inCheckingStateHistory.keys.contains(toState.name) {
                        self.inCheckingStateHistory[toState.name]!.append(satisfy.0)
                    }else {
                        self.inCheckingStateHistory[toState.name] = [satisfy.0]
                    }
                }
                
                return satisfy
            }
            print("allCurrentFrameWarnings 1111111" )
            return (false, [], 0, 0)
            
        }
        
        if scoreRulesTransformSatisfy.count == 1 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(scoreRulesTransformSatisfy[0].1)
            
            print("allCurrentFrameWarnings \(transforms) \(scoreRulesTransformSatisfy[0]) \(currentStateTime.stateId) \(allCurrentFrameWarnings)")
        } else if scoreRulesTransformSatisfy.count > 1 {
            let allRulesSatisfySorted = scoreRulesTransformSatisfy.sorted(by: {($0).2 >= ($1).2})
            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
            }
            allRulesSatisfySorted.filter{ (_, warnings, _ , _) in
                warnings.contains(where: { warning in
                    warning.triggeredWhenRuleMet
                })
            }.forEach({ (_, warnings, _ , _) in
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(warnings)
            }
            )
        }
        
        if scoreRulesTransformSatisfy.contains(where: { (satisfy, warnings, _, _) in
            satisfy && !warnings.contains(where: { warning in
                warning.triggeredWhenRuleMet
            })
        }) {
            allCurrentFrameWarnings = []
        }
        
        allCurrentFrameWarnings.remove(Warning(content: "", triggeredWhenRuleMet: true, delayTime: 0.0))
        updateWarnings(currentTime: currentTime, allCurrentFrameWarnings: allCurrentFrameWarnings)
        
        // 长度等于计数序列开始判断是否满足计分条件
        
        if currentTime > lastTime {
            lastTime = currentTime
        }
    }
    
    
    func playCounter(poseMap:PoseMap, object: Observation?, targetObject: Observation?, frameSize: Point2D, currentTime: Double) {
        
        
        // 如果返回顺序错误 则丢弃
        if lastTime > currentTime {
            return
        }
        
//      收集最低点和最高点
        if !sport.selectedLandmarkTypes.isEmpty {
            updateCurrentStateLandmarkBounds(poseMap: poseMap, landmarkTypes: sport.selectedLandmarkTypes)
        }
        
        if !sport.collectedObjects.isEmpty {
            updateCurrentStateObjectBounds(object: object, targetObservation: targetObject, objectLabels: sport.collectedObjects)
        }
        
        
        // 3秒没切换状态 则重置状态为开始
////        MARK: 添加重置为开始条件 当前太粗暴
        var allCurrentFrameWarnings : Set<Warning> = []

//
        if currentTime - currentStateTime.time > sport.scoreTimeLimit {
//            print("时间间隔3秒")
            currentStateTime = StateTime(stateId: SportState.startState.id, time: currentTime, poseMap: poseMap, object: object)
            allCurrentFrameWarnings = allCurrentFrameWarnings.union([
                Warning(content: "状态变换间隔太久", triggeredWhenRuleMet: true, delayTime: 0)
            ])
        }
        

        let transforms = sport.stateTransForm.filter { currentStateTime.stateId == $0.from }
        
        let violateRulesTransformSatisfy = transforms.map { transform -> (Bool, Set<Warning>, Int, Int) in

            if let toState = sport.findFirstStateByStateId(stateId: transform.to) {
                let satisfy = toState.rulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
                return satisfy
            }
            return (false, [], 0, 0)
            
        }
        // 违规逻辑 1.如果只有一个转换 则直接给提醒 2.如果有多个转换, 提示符合条多的那一个
        // 如果有满足条件的违规 则清空

        if violateRulesTransformSatisfy.count == 1 {
            allCurrentFrameWarnings = allCurrentFrameWarnings.union(violateRulesTransformSatisfy[0].1)
        } else if violateRulesTransformSatisfy.count > 1 {
            let allRulesSatisfySorted = violateRulesTransformSatisfy.sorted(by: {($0).2 >= ($1).2})
            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
            }
            
            allRulesSatisfySorted.filter{ (_, warnings, _ , _) in
                warnings.contains(where: { warning in
                    warning.triggeredWhenRuleMet
                })
            }.forEach({ (_, warnings, _ , _) in
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(warnings)
            }
            )
            
        }
        
        if violateRulesTransformSatisfy.contains(where: { (satisfy, warnings, _, _) in
            satisfy && !warnings.contains(where: { warning in
                warning.triggeredWhenRuleMet
            })
        }) {
            allCurrentFrameWarnings = []
        }

//        计分逻辑 状态未切换时判断
        
        let scoreRulesTransformSatisfy = transforms.map { transform -> (Bool, Set<Warning>, Int, Int) in
            
            if let toState = sport.findFirstStateByStateId(stateId: transform.to), transform.from == currentStateTime.stateId {
                
                nextState = toState
                
                let satisfy = toState.rulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
                if satisfy.0  {
                    currentStateTime = StateTime(stateId: toState.id, time: currentTime, poseMap: poseMap, object: object)
                }
                return satisfy
            }
            return (false, [], 0, 0)
            
        }
        
//        区分是否为满足时提醒和不满足时提醒
        if scoreRulesTransformSatisfy.count == 1 {
            allCurrentFrameWarnings = allCurrentFrameWarnings.union(scoreRulesTransformSatisfy[0].1)

            
        } else if scoreRulesTransformSatisfy.count > 1 {
            let allRulesSatisfySorted = scoreRulesTransformSatisfy.sorted(by: {($0).2 >= ($1).2})
            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
            }
            

            allRulesSatisfySorted.filter{ (_, warnings, _ , _) in
                warnings.contains(where: { warning in

                    warning.triggeredWhenRuleMet
                })
            }.forEach({ (satisfy, warnings, _ , _) in
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(warnings)
            }
            )
        }
        
        if scoreRulesTransformSatisfy.contains(where: { (satisfy, warnings, _, _) in
            satisfy && !warnings.contains(where: { warning in
                warning.triggeredWhenRuleMet
            })
        }) {
            allCurrentFrameWarnings = []
        }
        
        // 长度等于计数序列开始判断是否满足计分条件
        sport.violateStateSequence.forEach({ _violateStateSequence in
            if stateTimeHistory.count >= _violateStateSequence.stateIds.count {
                let allStateSatisfy = _violateStateSequence.stateIds.indices.allSatisfy{ index in
                    _violateStateSequence.stateIds[index] == stateTimeHistory[index + stateTimeHistory.count - _violateStateSequence.stateIds.count].stateId
                }

                if allStateSatisfy {
                    allCurrentFrameWarnings = allCurrentFrameWarnings.union([_violateStateSequence.warning])
                }
            }
            
        })
        
        
        allCurrentFrameWarnings.remove(Warning(content: "", triggeredWhenRuleMet: true, delayTime: 0.0))
        updateWarnings(currentTime: currentTime, allCurrentFrameWarnings: allCurrentFrameWarnings)
        
        if currentTime > lastTime {
            lastTime = currentTime
        }
        
    }
    
    
    
}
