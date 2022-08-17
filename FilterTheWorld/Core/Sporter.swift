

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
    let sportState: SportState
    let time: Double
//    状态变换时的关节信息
    let poseMap: PoseMap
 
// 动态收集的物体位置

    var dynamicObjectsMaps:[String: ExtremeObject] = [:]
    
// 动态收集关节点位置
    var dynamicPoseMaps: [LandmarkType: ExtremePoint3D] = [:]
    
}


struct ScoreTime: Identifiable, Codable {
    var stateId: Int
    var time: Double
    var vaild: Bool
    
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
    init(name: String, sport: Sport) {
        self.name = name
        self.sport = sport
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
    
    var currentStateTime = StateTime(sportState: SportState.startState, time: 0, poseMap: [:]) {
        
        didSet {
            if currentStateTime.sportState.name == SportState.startState.name {
                stateTimeHistory = [currentStateTime]
            }else {
                stateTimeHistory.append(currentStateTime)
                print("state change time history \(currentStateTime.sportState.name) \(currentStateTime.time)")
                // 移除无用的前置序列
                if stateTimeHistory.count > sport.scoreStateSequence.map { stateIds in
                    stateIds.count
                }.max()! {
                    stateTimeHistory.remove(at: 0)
                }
            }
            allStateTimeHistory.append(ScoreTime(stateId: currentStateTime.sportState.id, time: currentStateTime.time, vaild: true))
        }
    }
    
    var nextState = SportState.startState
    
    var scoreTimes: [ScoreTime] = [] {
        didSet {
            // 计分保留最后一个状态
            
            if oldValue.count > scoreTimes.count {
                return
            }
            
            if sport.sportClass == .Counter {
                stateTimeHistory = [stateTimeHistory.last!]
            }
        }
    }
    
    var warnings: Set<String> = []
//    MARK: 第一次捕获到时 添加到延迟展示
//    当下一帧消失时 未必想取消该展示 比如运球过低 是在等高位置的出现
//    开合跳之类的不存在这种问题是因为开合之间没有中间状态
    
    var timerScoreTimes: [ScoreTime] = [] {
        didSet {
            if oldValue.count > timerScoreTimes.count {
                return
            }
            if sport.sportClass == .TimeCounter && timerScoreTimes.count > 1, let state = sport.findFirstStateByStateId(stateId: timerScoreTimes.last!.stateId) {
                    if sport.sportPeriod == .Continuous {
                        // 如果是连续的 则判断和上一个状态一样的时间间隔
                        let last_1 = timerScoreTimes.last!
                        let last_2 = timerScoreTimes[timerScoreTimes.count - 2]
                        
                        if last_2.stateId == last_1.stateId && last_1.time - last_2.time > state.checkCycle! + 0.5 {
                            
                            while timerScoreTimes.count > 1 && timerScoreTimes[timerScoreTimes.count - 2].stateId == state.id {
                                timerScoreTimes.remove(at: timerScoreTimes.count - 2)
                            }
                        }
                    }
                
                    if timerScoreTimes.count >= state.keepTime!.toInt {
                        if timerScoreTimes[timerScoreTimes.count - state.keepTime!.toInt..<timerScoreTimes.count].allSatisfy({ sportScore in
                            sportScore.stateId == state.id
                        }) {
                            currentStateTime = StateTime(sportState: state, time: timerScoreTimes.last!.time, poseMap: [:])
//                            此处也应该放开
                            if sport.scoreStateSequence[0].contains(state.id) {
                                scoreTimes.append(contentsOf: timerScoreTimes[timerScoreTimes.count - state.keepTime!.toInt..<timerScoreTimes.count])
                            }
                        }
                    }
                    
            } else if sport.sportClass == .Timer  && !timerScoreTimes.isEmpty, let state = sport.findFirstStateByStateId(stateId: timerScoreTimes.last!.stateId) {
                    if sport.scoreStateSequence[0].contains(state.id) {
                        scoreTimes.append(timerScoreTimes.last!)
                    }
            }
        }

    }

    
    var stateTimeHistory: [StateTime] = [StateTime(sportState: SportState.startState, time: 0, poseMap: [:])]
    
  
    var cancelableWarningMap: [String: Timer] = [:]
    
    var warningsData: [WarningData] = []
    
    func warningTimer(warning: WarningData) -> Timer {
        let timer =
        Timer.scheduledTimer(
            withTimeInterval: warning.warning.delayTime, repeats: false) { [self] timer in

                DispatchQueue.main.async {
                    self.warnings.insert(warning.warning.content)
                    self.warningsData.append(warning)
                }
        
                timer.invalidate()
                
            }
        return timer

    }

    
    var inCheckingStateHistory: [String: [Bool]] = [:]
    // 检测到状态维护的计时器
    var inCheckingStatesTimer: [String: Timer] = [:]
    
    func checkStateTimer(state: SportState, currentTime: Double, withTimeInterval: TimeInterval) -> Timer {
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
                        switch sport.sportClass {
                            case .Counter:
                                self.scoreTimes.append(
                                    ScoreTime(stateId: state.id, time: currentTime, vaild: true)
                                    )

                            case .Timer:
                                self.timerScoreTimes.append(
                                    ScoreTime(stateId: state.id, time: currentTime, vaild: true)
                                )

                            case .TimeCounter:
                                self.timerScoreTimes.append(
                                    ScoreTime(stateId: state.id, time: currentTime, vaild: true)
                                )

                            case .None:
                                break
                            }
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
        
        allCurrentFrameWarnings.forEach { warning in
            if warning.delayTime < 0.3 {
                warnings.insert(warning.content)
                self.warningsData.append(WarningData(warning: warning, stateId: currentStateTime.sportState.id, time: currentTime))
            }
        }

        let totalWarnings =
        allCurrentFrameWarnings.map { warning in
            WarningData(warning: warning, stateId: currentStateTime.sportState.id, time: currentTime)
            
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
            self.warnings = self.warnings.subtracting(cancelWarnings)
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
        
        var allCurrentFrameWarnings : Set<Warning> = []

        let allHasRuleStates = sport.states.filter({ state in
            !state.scoreRules.isEmpty
        })
        
        //如果有一个状态满足
        
        let allRulesSatisfy = allHasRuleStates.map({state -> (Bool, Set<Warning>, Int, Int) in
            let satisfy = state.rulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
            if satisfy.0 {
//                如果不包含该状态 则建立计时器
                if !inCheckingStatesTimer.keys.contains(state.name) {
                    inCheckingStatesTimer[state.name] = checkStateTimer(state: state, currentTime: currentTime, withTimeInterval: state.checkCycle!)
                }
            }

            
            if self.inCheckingStatesTimer.keys.contains(state.name) {
                if self.inCheckingStateHistory.keys.contains(state.name) {
                    self.inCheckingStateHistory[state.name]!.append(satisfy.0)
                }else {
                    self.inCheckingStateHistory[state.name] = [satisfy.0]
                }
            }
            if satisfy.0 {
                currentStateTime = StateTime(sportState: state, time: currentTime, poseMap: [:])
            }
            return satisfy
        })
        
        if allRulesSatisfy.count == 1 {
            if !allRulesSatisfy[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfy[0].1)
            }
        } else if allRulesSatisfy.count > 1 {
            let allRulesSatisfySorted = allRulesSatisfy.sorted(by: {($0).2 >= ($1).2})
            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
            }
        }
        
        if allRulesSatisfy.contains(where: { (satisfy, _, _, _) in
            satisfy
        }) {
            allCurrentFrameWarnings = []
        }else {
            currentStateTime = StateTime(sportState: .startState, time: currentTime, poseMap: [:])

        }
    
        
        if self.inCheckingStatesTimer.isEmpty {
            if self.scoreTimes.isEmpty {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union([
                    Warning(content: "开始\(sport.name)", triggeredWhenRuleMet: true, delayTime: sport.warningDelay)
                    
                ])
            }else {
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
        
//      收集最低点和最高点
        if !sport.selectedLandmarkTypes.isEmpty {
            updateCurrentStateLandmarkBounds(poseMap: poseMap, landmarkTypes: sport.selectedLandmarkTypes)
        }
        
        if !sport.collectedObjects.isEmpty {
            updateCurrentStateObjectBounds(object: object, targetObservation: targetObject, objectLabels: sport.collectedObjects)
        }
        
        // 如果返回顺序错误 则丢弃
        if lastTime > currentTime {
            return
        }
    
        var allCurrentFrameWarnings : Set<Warning> = []

//        违规逻辑
        let transforms = sport.stateTransForm.filter { currentStateTime.sportState.id == $0.from }
        
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
            if !violateRulesTransformSatisfy[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(violateRulesTransformSatisfy[0].1)
            }
        } else if violateRulesTransformSatisfy.count > 1 {
            let allRulesSatisfySorted = violateRulesTransformSatisfy.sorted(by: {($0).2 >= ($1).2})
            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
            }
        }
        
        if violateRulesTransformSatisfy.contains(where: { (satisfy, _, _, _) in
            satisfy
        }) {
            allCurrentFrameWarnings = []
        }

//        计分逻辑 状态未切换时判断
   
        let scoreRulesTransformSatisfy = transforms.map { transform -> (Bool, Set<Warning>, Int, Int) in
            
            if let toState = sport.findFirstStateByStateId(stateId: transform.to), transform.from == currentStateTime.sportState.id {
                nextState = toState
                let satisfy = toState.rulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
                if satisfy.0  {
                    if !inCheckingStatesTimer.keys.contains(toState.name) {
                        inCheckingStatesTimer[toState.name] = checkStateTimer(state: toState, currentTime: currentTime, withTimeInterval: toState.checkCycle!)
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
            return (false, [], 0, 0)
            
        }
        
        if scoreRulesTransformSatisfy.count == 1 {
            if !scoreRulesTransformSatisfy[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(scoreRulesTransformSatisfy[0].1)
            }
        } else if scoreRulesTransformSatisfy.count > 1 {
            let allRulesSatisfySorted = scoreRulesTransformSatisfy.sorted(by: {($0).2 >= ($1).2})
            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
            }
        }
        
        if scoreRulesTransformSatisfy.contains(where: { (satisfy, _, _, _) in
            satisfy
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
        
        if currentTime - currentStateTime.time > sport.scoreTimeLimit {
//            print("时间间隔3秒")
            currentStateTime = StateTime(sportState: .startState, time: currentTime, poseMap: poseMap)
        }
        
        // 如果返回顺序错误 则丢弃
        if lastTime > currentTime {
            return
        }
        
        var allCurrentFrameWarnings : Set<Warning> = []

        
        let transforms = sport.stateTransForm.filter { currentStateTime.sportState.id == $0.from }
        
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
            if !violateRulesTransformSatisfy[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(violateRulesTransformSatisfy[0].1)
            }
        } else if violateRulesTransformSatisfy.count > 1 {
            let allRulesSatisfySorted = violateRulesTransformSatisfy.sorted(by: {($0).2 >= ($1).2})
            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
            }
        }
        
        if violateRulesTransformSatisfy.contains(where: { (satisfy, _, _, _) in
            satisfy
        }) {
            allCurrentFrameWarnings = []
        }

//        计分逻辑 状态未切换时判断
        
        let scoreRulesTransformSatisfy = transforms.map { transform -> (Bool, Set<Warning>, Int, Int) in
            
            if let toState = sport.findFirstStateByStateId(stateId: transform.to), transform.from == currentStateTime.sportState.id {
                
                nextState = toState
                
                let satisfy = toState.rulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, object: object, targetObject: targetObject, frameSize: frameSize)
                if satisfy.0  {
                    currentStateTime = StateTime(sportState: toState, time: currentTime, poseMap: poseMap)
                }
                return satisfy
            }
            return (false, [], 0, 0)
            
        }
        
        if scoreRulesTransformSatisfy.count == 1 {
            if !scoreRulesTransformSatisfy[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(scoreRulesTransformSatisfy[0].1)
            }
        } else if scoreRulesTransformSatisfy.count > 1 {
            let allRulesSatisfySorted = scoreRulesTransformSatisfy.sorted(by: {($0).2 >= ($1).2})
            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
            }
        }
        
        if scoreRulesTransformSatisfy.contains(where: { (satisfy, _, _, _) in
            satisfy
        }) {
            allCurrentFrameWarnings = []
        }
        
        // 长度等于计数序列开始判断是否满足计分条件
        
        sport.violateStateSequence.forEach({ _violateStateSequence in
            if stateTimeHistory.count >= _violateStateSequence.stateIds.count {
                let allStateSatisfy = _violateStateSequence.stateIds.indices.allSatisfy{ index in
                    _violateStateSequence.stateIds[index] == stateTimeHistory[index + stateTimeHistory.count - _violateStateSequence.stateIds.count].sportState.id
                }
                
                if allStateSatisfy {
                    allCurrentFrameWarnings = allCurrentFrameWarnings.union([_violateStateSequence.warning])
                }
                
            }
            
        })
        
        sport.scoreStateSequence.forEach({ _scoreStateSequence in
            if stateTimeHistory.count >= _scoreStateSequence.count {
                let allStateSatisfy = _scoreStateSequence.indices.allSatisfy{ index in
                    _scoreStateSequence[index] == stateTimeHistory[index + stateTimeHistory.count - _scoreStateSequence.count].sportState.id
                }
                var timeSatisfy = true
                let timeLimit = sport.scoreTimeLimit
                if  _scoreStateSequence.count > 1, let startTime = stateTimeHistory.first?.time, let endTime = stateTimeHistory.last?.time {
                    if endTime - startTime > timeLimit {
                        timeSatisfy = false
                    }
                }
                // 时间间隔不满足 抛出warning
                if !timeSatisfy {
                    allCurrentFrameWarnings = allCurrentFrameWarnings.union([Warning(content: "太久不上分啦", triggeredWhenRuleMet: true, delayTime: 0.0)])
                }
                
                if allStateSatisfy && timeSatisfy {
                    // 检查状态改变后是否满足多帧条件 决定是否计分
                    scoreTimes.append(
                        ScoreTime(stateId: currentStateTime.sportState.id, time: currentTime, vaild: true)
                    )

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
