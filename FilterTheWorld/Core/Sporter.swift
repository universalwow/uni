

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
    var interactionScoreTimes: [ScoreTime]? = []
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
    
    func findStateInteractionScoreTimes(stateId: Int) -> [ScoreTime] {
        self.interactionScoreTimes?.filter( { scoreTime in
            scoreTime.stateId == stateId
        }) ?? []
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
    
    


    
    func getFixedAreas() -> [FixedAreaForSport] {
        var areas : Set<String> = []
        sport.stateTransForm.filter({ transform in
            transform.from == currentStateTime.stateId
        }).map({ transform in
            transform.to
        }).forEach({ stateId in
            let state = sport.states.first(where: { state in
                state.id == stateId
            })!
            areas.formUnion(state.getFixedAreas())
        })
        
//        if sport.interactionType == .MultipleChoice {
//            areas.insert("问题")
//        }
        
        
        
        if [InteractionType.MultipleChoice,
            InteractionType.SingleChoice].contains(sport.interactionType)
             && question != nil {
            var fixedAreas : [FixedAreaForSport] = []
            question!.choices.indices.forEach({ index in
                if self.answerSet.contains(index) {
                    sport.fixedAreas[index].selected = true
                }else{
                    sport.fixedAreas[index].selected = false
                }
                sport.fixedAreas[index].content = question!.choices[index]
                fixedAreas.append(sport.fixedAreas[index])
            })
//                    问题
            sport.fixedAreas[4].content = question!.question
            fixedAreas.append(sport.fixedAreas[4])
            return fixedAreas
        }
        
        
        
        return sport.fixedAreas.filter({ area in
            areas.contains(area.id)
        })
        
        
    }
    
    func getDynamicAreas() -> [DynamicAreaForSport] {
        var areas : Set<String> = []
        sport.stateTransForm.filter({ transform in
            transform.from == currentStateTime.stateId
        }).map({ transform in
            transform.to
        }).forEach({ stateId in
            let state = sport.states.first(where: { state in
                state.id == stateId
            })!
            areas.formUnion(state.getDynamicAreas())
        })
        
        if [InteractionType.OrdinalTouch].contains(sport.interactionType) && orderTouchStart == true
              {
            var dynamicAreas : [DynamicAreaForSport] = []
            (0..<sport.dynamicAreaNumber!).forEach( { index in
                sport.dynamicAreas[index].content = "\(index + 1)"

                if self.answerSet.contains(index) {
                    sport.dynamicAreas[index].selected = true
                }else{
                    sport.dynamicAreas[index].selected = false
                }
                dynamicAreas.append(sport.dynamicAreas[index])

            })

            return dynamicAreas
        }
        
        return sport.dynamicAreas.filter({ area in
            areas.contains(area.id)
        })
    }
    
    
    func generatorDynamicArea() {
        // 需要更新的areaId
        var areas : Set<String> = []
        let stateIds = sport.stateTransForm.filter({ transform in
            transform.from == currentStateTime.stateId
        }).map({ transform in
            transform.to
        })
        stateIds.forEach({ stateId in
            let state = sport.states.first(where: { state in
                state.id == stateId
            })!
            areas.formUnion(state.getDynamicAreas())
        })
        
        areas.forEach({ areaId in
            
            let dynamicArea = sport.dynamicAreas.first(where: { dynamicArea in
                dynamicArea.id == areaId
            })!
            let area = sport.generatorDynamicArea(imageSize: dynamicArea.imageSize!, areaId: areaId)
            sport.updateDynamicArea(areaId: areaId, area: area)
            sport.generatorDynamicArea(areaId: areaId, area: area)
        })
    }
    
    var allStateTimeHistory :[ScoreTime] = []
    
    var nextStatePreview = SportState.startState
    
    var question: Question?
    var answerSet: Set<Int> = []
    
    var orderTouchStart = false

    
    var currentStateTime = StateTime(stateId: SportState.startState.id, time: 0, poseMap: [:], object: nil) {
        
        didSet {
            allStateTimeHistory.append(ScoreTime(stateId: currentStateTime.stateId, time: currentStateTime.time, vaild: true, poseMap: currentStateTime.poseMap, object: currentStateTime.object))
            
            // 长度等于计数序列开始判断是否满足计分条件
            var allCurrentFrameWarnings : Set<Warning> = []
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
            updateNoDelayWarnings(currentTime: currentStateTime.time, allCurrentFrameWarnings: allCurrentFrameWarnings)
            
            
            
            switch sport.interactionType {
                
            case .SingleChoice:
                if currentStateTime.stateId == SportState.interAction_1.id {
                    answerSet = []
                    let question = sport.questions.randomElement()!
                    self.question = question
    
                } else if currentStateTime.stateId == SportState.interAction_2.id {
                    if self.question!.answerIndexs == answerSet {
                        if sport.sportClass == .Counter {
                            interactionScoreTimes.append(
                                ScoreTime(stateId: currentStateTime.stateId, time: currentStateTime.time, vaild: true, poseMap: currentStateTime.poseMap, object: currentStateTime.object)
                            )
                        }
                    }
                    self.question = nil
                    self.answerSet = []
                } else if [SportState.interAction_a.id, SportState.interAction_b.id, SportState.interAction_c.id, SportState.interAction_d.id].contains(currentStateTime.stateId) {
                    if self.answerSet.contains(currentStateTime.stateId) {
                        self.answerSet.remove(currentStateTime.stateId)
                    }else {
                        // 单选只有一个答案
                        self.answerSet = [currentStateTime.stateId]
                    }
                }
            case .MultipleChoice:
                if currentStateTime.stateId == SportState.interAction_1.id {
                    answerSet = []
                    //多项选择 往框中塞答案
                    let question = sport.questions.randomElement()!
                    self.question = question
    
                } else if currentStateTime.stateId == SportState.interAction_2.id {
                    if self.question!.answerIndexs == answerSet {
                        if sport.sportClass == .Counter {
                            interactionScoreTimes.append(
                                ScoreTime(stateId: currentStateTime.stateId, time: currentStateTime.time, vaild: true, poseMap: currentStateTime.poseMap, object: currentStateTime.object)
                            )
                        }
                    }
                    self.question = nil
                    self.answerSet = []
                } else if [SportState.interAction_a.id, SportState.interAction_b.id, SportState.interAction_c.id, SportState.interAction_d.id].contains(currentStateTime.stateId) {
                    if self.answerSet.contains(currentStateTime.stateId) {
                        self.answerSet.remove(currentStateTime.stateId)
                    }else {
                        self.answerSet.insert(currentStateTime.stateId)
                    }
                    
                }
                
                
            case .SingleTouch:
                generatorDynamicArea()
            case .OrdinalTouch:
                
                if currentStateTime.stateId == SportState.interAction_1.id {
                    self.answerSet = []
                    orderTouchStart = true
                    generatorDynamicArea()

                } else if [SportState.interAction_a.id, SportState.interAction_b.id, SportState.interAction_c.id, SportState.interAction_d.id].contains(currentStateTime.stateId) {
                    self.answerSet.insert(currentStateTime.stateId)
                    if self.answerSet.count == sport.dynamicAreaNumber {
                        if sport.sportClass == .Counter {
                            interactionScoreTimes.append(
                                ScoreTime(stateId: currentStateTime.stateId, time: currentStateTime.time, vaild: true, poseMap: currentStateTime.poseMap, object: currentStateTime.object)
                            )
                            
                            
                        }
                        currentStateTime = StateTime(stateId: SportState.startState.id, time: currentStateTime.time, poseMap: [:], object: nil)
                        orderTouchStart = false
                    }
                    if self.answerSet.count == 1 {
                        if self.answerSet != [SportState.interAction_a.id] {
                            currentStateTime = StateTime(stateId: SportState.startState.id, time: currentStateTime.time, poseMap: [:], object: nil)
                            orderTouchStart = false
                        }
                    }else if self.answerSet.count == 2 {
                        if self.answerSet != [SportState.interAction_a.id, SportState.interAction_b.id] {
                            currentStateTime = StateTime(stateId: SportState.startState.id, time: currentStateTime.time, poseMap: [:], object: nil)
                            orderTouchStart = false
                        }
                    } else if self.answerSet.count == 3 {
                        if self.answerSet != [SportState.interAction_a.id, SportState.interAction_b.id, SportState.interAction_c.id] {
                            currentStateTime = StateTime(stateId: SportState.startState.id, time: currentStateTime.time, poseMap: [:], object: nil)
                            orderTouchStart = false
                        }
                    }
                }
                
            case .None:
                break
            }
            
//            if sport.name == "交互" && currentStateTime.stateId == SportState.interAction_1.id {
//                let question = questions.randomElement()!
//                question.choices.indices.forEach({ index in
//                    sport.fixedAreas[index].content = question.choices[index]
//                })
//                sport.fixedAreas[question.choices.count].content = question.question
//
//            }else {
//                sport.fixedAreas.indices.forEach({ index in
//                    sport.fixedAreas[index].content = nil
//                })
//            }
            
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
                            if [SportClass.Counter,SportClass.TimeRanger].contains(sport.sportClass) {
                                scoreTimes.append(
                                    ScoreTime(stateId: currentStateTime.stateId, time: currentStateTime.time, vaild: true, poseMap: currentStateTime.poseMap, object: currentStateTime.object)
                                )

                            } else {
                                scoreTimes.append(contentsOf: timerScoreTimes)
                            }

                        }
                        
                    }
                    
                })
                

//                timerScoreTimes = []
//
//                if currentStateTime.stateId != SportState.readyState.id {
//                    self.onStateChange()
//                }
                
//              基于交互的计分
                sport.interactionScoreStateSequence?.forEach({ _scoreStateSequence in
                    if stateTimeHistory.count >= _scoreStateSequence.count {
                        let allStateSatisfy = _scoreStateSequence.indices.allSatisfy{ index in
                            _scoreStateSequence[index] == stateTimeHistory[index + stateTimeHistory.count - _scoreStateSequence.count].stateId
                        }
          
                        if allStateSatisfy {
                            // 检查状态改变后是否满足多帧条件 决定是否计分
                            if sport.sportClass == .Counter {
                                interactionScoreTimes.append(
                                    ScoreTime(stateId: currentStateTime.stateId, time: currentStateTime.time, vaild: true, poseMap: currentStateTime.poseMap, object: currentStateTime.object)
                                )

                            } else {
                                interactionScoreTimes.append(contentsOf: timerScoreTimes)
                            }

                        }
                        
                    }
                    
                })
                timerScoreTimes = []
                
                if currentStateTime.stateId != SportState.readyState.id {
                    self.onStateChange()
                }
                
                if let directToStateId = sport.findFirstStateByStateId(stateId: currentStateTime.stateId)?.directToStateId {
                    if directToStateId != SportState.endState.id && directToStateId != -100 {
                        DispatchQueue.main.async {
                            self.currentStateTime = StateTime(stateId: directToStateId, time: self.currentStateTime.time, poseMap: self.currentStateTime.poseMap, object: self.currentStateTime.object, dynamicObjectsMaps: self.currentStateTime.dynamicObjectsMaps, dynamicPoseMaps: self.currentStateTime.dynamicPoseMaps)
                        }
                        
                    }
                    
                }
                
            }
            
        
        }
    }
    
    var nextState = SportState.startState
    
    var scoreTimes: [ScoreTime] = [] {
        didSet {
            // 计分保留最后一个状态
            
            if oldValue.count > scoreTimes.count {
                return
            }
            
            if sport.interactionType != InteractionType.None && scoreTimes.count % sport.interactionScoreCycle! == 0 {
//                切换到交互状态
                currentStateTime = StateTime(stateId: -1, time: scoreTimes.last!.time, poseMap: scoreTimes.last!.poseMap, object: scoreTimes.last?.object)
            }
//            stateTimeHistory = [stateTimeHistory.last!]
        }
    }
    
//    交互计分
    var interactionScoreTimes: [ScoreTime] = []
    
    
    var delayWarnings: Set<Warning> = []
    var noDelayWarnings: Set<Warning> = []
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
    
  
    var cancelableWarningMap: [Warning: Timer] = [:]
    
    var warningsData: [WarningData] = []
    
    func warningTimer(warning: WarningData) -> Timer {
        let timer =
        Timer.scheduledTimer(
            withTimeInterval: warning.warning.delayTime, repeats: false) { [self] timer in

                DispatchQueue.main.async {
                    self.delayWarnings.insert(warning.warning)
                    self.warningsData.append(warning)
                }
        
                timer.invalidate()
                cancelableWarningMap.removeValue(forKey: warning.warning)
                
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
    
    
    func updateCurrentStateObjectBounds(objects: [Observation], objectLabels: [String]) {
        if stateTimeHistory.isEmpty {
            return
        }
        let index = stateTimeHistory.endIndex - 1
        
        
        objectLabels.forEach { objectLabel in
            var collectedObject : Observation? = nil
            if let _object = objects.first(where: { object in
                object.label == objectLabel
                
            }) {
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
    
    func updateNoDelayWarnings(currentTime: Double, allCurrentFrameWarnings: Set<Warning>) {
//        noDelayWarnings = []
        allCurrentFrameWarnings.forEach { warning in
            DispatchQueue.main.async {
                self.noDelayWarnings.insert(warning)
            }
            print("warning... 10 \(warning.content)")
            self.warningsData.append(WarningData(warning: warning, stateId: currentStateTime.stateId, time: currentTime))
        }
    }
    
    func updateWarnings(currentTime: Double, allCurrentFrameWarnings: Set<Warning>) {
//        noDelayWarnings = []
        allCurrentFrameWarnings.forEach { warning in
            if warning.delayTime < 0.3 {
                DispatchQueue.main.async {
                    self.noDelayWarnings.insert(warning)
                }
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
                warning.content == newWarning.warning.content
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
                warning.content == newWarning.warning.content
            })
        }.forEach { newWarning in
            if newWarning.warning.delayTime >= 0.3 {
                cancelableWarningMap[newWarning.warning] = warningTimer(warning: newWarning)
            }
            
        }
    }
    
    func play(poseMap:PoseMap, objects: [Observation], frameSize: Point2D, currentTime: Double) {

        switch sport.sportClass {
            case .Counter:
                playCounter(poseMap: poseMap, objects: objects, frameSize: frameSize, currentTime: currentTime)
            case .Timer:
                playTimer(poseMap: poseMap, objects: objects, frameSize: frameSize, currentTime: currentTime)
            case .TimeCounter:
                
                playTimeCounter(poseMap: poseMap, objects: objects, frameSize: frameSize, currentTime: currentTime)
            case .TimeRanger:
                playTimeRanger(poseMap: poseMap, objects: objects, frameSize: frameSize, currentTime: currentTime)
            case .None: break
        
            
        }
        

        
    }
    
    // 时间区间内项目流程
    
    func playTimeRanger(poseMap:PoseMap, objects: [Observation], frameSize: Point2D, currentTime: Double) {
        // 如果返回顺序错误 则丢弃
        if lastTime > currentTime {
            return
        }
        
//      收集最低点和最高点
        if !sport.selectedLandmarkTypes.isEmpty {
            updateCurrentStateLandmarkBounds(poseMap: poseMap, landmarkTypes: sport.selectedLandmarkTypes)
        }
        
        if !sport.collectedObjects.isEmpty {
            updateCurrentStateObjectBounds(objects: objects, objectLabels: sport.collectedObjects)
        }
        
        
        // 3秒没切换状态 则重置状态为开始
////        MARK: 添加重置为开始条件 当前太粗暴
        var allCurrentFrameWarnings : Set<Warning> = []
        
        let allHasRuleStates = sport.states.filter({ state in
            return state.checkTimeRanges != nil && !state.checkTimeRanges!.isEmpty
        })
        
//        let violateRulesTransformSatisfy = allHasRuleStates.map { state -> (Bool, Set<Warning>, Int, Int) in
//
//            if let toState = sport.findFirstStateByStateId(stateId: state.id) {
//                let satisfy = toState.rulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, objects: objects, frameSize: frameSize)
//                return satisfy
//            }
//            return (false, [], 0, 0)
//
//        }
//        // 违规逻辑 1.如果只有一个转换 则直接给提醒 2.如果有多个转换, 提示符合条多的那一个
//        // 如果有满足条件的违规 则清空
//
//        if violateRulesTransformSatisfy.count == 1 {
//            allCurrentFrameWarnings = allCurrentFrameWarnings.union(violateRulesTransformSatisfy[0].1)
//        } else if violateRulesTransformSatisfy.count > 1 {
//            let allRulesSatisfySorted = violateRulesTransformSatisfy.sorted(by: {($0).2 >= ($1).2})
//            if allRulesSatisfySorted.count > 1 && allRulesSatisfySorted[0].2 > allRulesSatisfySorted[1].2 && !allRulesSatisfySorted[0].0 {
//                allCurrentFrameWarnings = allCurrentFrameWarnings.union(allRulesSatisfySorted[0].1)
//            }
//
//            allRulesSatisfySorted.filter{ (_, warnings, _ , _) in
//                warnings.contains(where: { warning in
//                    warning.triggeredWhenRuleMet
//                })
//            }.forEach({ (_, warnings, _ , _) in
//                allCurrentFrameWarnings = allCurrentFrameWarnings.union(warnings)
//            }
//            )
//
//        }
//
//        if violateRulesTransformSatisfy.contains(where: { (satisfy, warnings, _, _) in
//            satisfy && !warnings.contains(where: { warning in
//                warning.triggeredWhenRuleMet
//            })
//        }) {
//            allCurrentFrameWarnings = allCurrentFrameWarnings.filter({ warning in
//                warning.changeStateClear == false
//            })        }
//
////        计分逻辑 状态未切换时判断
        
        let scoreRulesTransformSatisfy = allHasRuleStates.filter{ state in
            state.checkTimeRanges!.contains(where: { timeRange in
                timeRange.range.contains(currentTime)
            })
        }.map { state -> (Bool, Set<Warning>, Int, Int) in
            
            if let toState = sport.findFirstStateByStateId(stateId: state.id), currentStateTime.stateId != state.id {
                                
                let satisfy = toState.rulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, objects: objects, frameSize: frameSize)
                if satisfy.0  {
                    currentStateTime = StateTime(stateId: toState.id, time: currentTime, poseMap: poseMap, object:  objects.first(where: { object in
                        object.label != ObjectLabel.POSE.rawValue
                        
                    }))
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
            allCurrentFrameWarnings = allCurrentFrameWarnings.filter({ warning in
                warning.changeStateClear == false
            })        }
        

        
        allCurrentFrameWarnings.remove(Warning(content: "", triggeredWhenRuleMet: true, delayTime: 0.0))
        updateWarnings(currentTime: currentTime, allCurrentFrameWarnings: allCurrentFrameWarnings)
        
        if currentTime > lastTime {
            lastTime = currentTime
        }

    }
    
    // 计时类项目流程
    func playTimer(poseMap:PoseMap, objects: [Observation], frameSize: Point2D, currentTime: Double) {
        
        if lastTime > currentTime {
            return
        }
        
        if !sport.selectedLandmarkTypes.isEmpty {
            updateCurrentStateLandmarkBounds(poseMap: poseMap, landmarkTypes: sport.selectedLandmarkTypes)
        }
        
        if !sport.collectedObjects.isEmpty {
            updateCurrentStateObjectBounds(objects: objects, objectLabels: sport.collectedObjects)
        }
        
        var allCurrentFrameWarnings : Set<Warning> = []

        let allHasRuleStates = sport.states.filter({ state in
            sport.scoreStateSequence.flatMap({ states in
                states
            }).contains(state.id)
        })
        
        //如果有一个状态满足
        
        let allRulesSatisfy = allHasRuleStates.map({state -> (Bool, Set<Warning>, Int, Int) in
            
            let satisfy = state.rulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, objects: objects, frameSize: frameSize)
            if satisfy.0 {
//                如果不包含该状态 则建立计时器
                if !inCheckingStatesTimer.keys.contains(state.name) {
                    inCheckingStatesTimer[state.name] = checkStateTimer(state: state, currentTime: currentTime, withTimeInterval: state.checkCycle!, poseMap: poseMap, object: objects.first(where: { object in
                        object.label != ObjectLabel.POSE.rawValue
                    }))
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
            allCurrentFrameWarnings = allCurrentFrameWarnings.filter({ warning in
                warning.changeStateClear == false
            })
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
    
    func playTimeCounter(poseMap:PoseMap, objects: [Observation], frameSize: Point2D, currentTime: Double) {
        
        // 如果返回顺序错误 则丢弃
        if lastTime > currentTime {
            return
        }
        
        
//      收集最低点和最高点
        if !sport.selectedLandmarkTypes.isEmpty {
            updateCurrentStateLandmarkBounds(poseMap: poseMap, landmarkTypes: sport.selectedLandmarkTypes)
        }
        
        if !sport.collectedObjects.isEmpty {
            updateCurrentStateObjectBounds(objects: objects, objectLabels: sport.collectedObjects)
        }
        
 
    
        var allCurrentFrameWarnings : Set<Warning> = []

//        违规逻辑
        let transforms = sport.stateTransForm.filter { currentStateTime.stateId == $0.from }
        
        let violateRulesTransformSatisfy = transforms.map { transform -> (Bool, Set<Warning>, Int, Int) in

            if let toState = sport.findFirstStateByStateId(stateId: transform.to) {
                let satisfy = toState.rulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, objects: objects, frameSize: frameSize)
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
            allCurrentFrameWarnings = allCurrentFrameWarnings.filter({ warning in
                warning.changeStateClear == false
            })        }

//        计分逻辑 状态未切换时判断
   
        let scoreRulesTransformSatisfy = transforms.map { transform -> (Bool, Set<Warning>, Int, Int) in
            
            if let toState = sport.findFirstStateByStateId(stateId: transform.to), transform.from == currentStateTime.stateId {
                nextState = toState
                let satisfy = toState.rulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, objects: objects, frameSize: frameSize)
                if satisfy.0  {
                    if !inCheckingStatesTimer.keys.contains(toState.name) {
                        inCheckingStatesTimer[toState.name] = checkStateTimer(state: toState, currentTime: currentTime, withTimeInterval: toState.checkCycle!, poseMap: poseMap, object: objects.first(where: { object in
                            object.label != ObjectLabel.POSE.rawValue
                            
                        }))
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
            allCurrentFrameWarnings = allCurrentFrameWarnings.filter({ warning in
                warning.changeStateClear == false
            })        }
        
        allCurrentFrameWarnings.remove(Warning(content: "", triggeredWhenRuleMet: true, delayTime: 0.0))
        updateWarnings(currentTime: currentTime, allCurrentFrameWarnings: allCurrentFrameWarnings)
        
        // 长度等于计数序列开始判断是否满足计分条件
        
        if currentTime > lastTime {
            lastTime = currentTime
        }
    }
    
    
    func playCounter(poseMap:PoseMap, objects: [Observation], frameSize: Point2D, currentTime: Double) {
        
        
        // 如果返回顺序错误 则丢弃
        if lastTime > currentTime {
            return
        }
        
//      收集最低点和最高点
        if !sport.selectedLandmarkTypes.isEmpty {
            updateCurrentStateLandmarkBounds(poseMap: poseMap, landmarkTypes: sport.selectedLandmarkTypes)
        }
        
        if !sport.collectedObjects.isEmpty {
            updateCurrentStateObjectBounds(objects: objects, objectLabels: sport.collectedObjects)
        }
        
        
        // 3秒没切换状态 则重置状态为开始
////        MARK: 添加重置为开始条件 当前太粗暴
        var allCurrentFrameWarnings : Set<Warning> = []

//
        if currentStateTime.time > 1 && currentTime - currentStateTime.time > sport.scoreTimeLimit {
//            print("时间间隔3秒")
            currentStateTime = StateTime(stateId: SportState.startState.id, time: currentTime, poseMap: poseMap, object: objects.first(where: { object in
                object.label != ObjectLabel.POSE.rawValue
                
            }))
            allCurrentFrameWarnings = allCurrentFrameWarnings.union([
                Warning(content: "状态变换间隔太久", triggeredWhenRuleMet: true, delayTime: 0)
            ])
        }
        

        let transforms = sport.stateTransForm.filter { currentStateTime.stateId == $0.from }
        
        let violateRulesTransformSatisfy = transforms.map { transform -> (Bool, Set<Warning>, Int, Int) in

            if let toState = sport.findFirstStateByStateId(stateId: transform.to) {
                let satisfy = toState.rulesSatisfy(ruleType: .VIOLATE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, objects: objects, frameSize: frameSize)
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
            allCurrentFrameWarnings = allCurrentFrameWarnings.filter({ warning in
                warning.changeStateClear == false
            })        }

//        计分逻辑 状态未切换时判断
        
        let scoreRulesTransformSatisfy = transforms.map { transform -> (Bool, Set<Warning>, Int, Int) in
            
            if let toState = sport.findFirstStateByStateId(stateId: transform.to), transform.from == currentStateTime.stateId {
                
                nextState = toState
                
                let satisfy = toState.rulesSatisfy(ruleType: .SCORE, stateTimeHistory: stateTimeHistory, poseMap: poseMap, objects: objects, frameSize: frameSize)
                if satisfy.0  {
                    currentStateTime = StateTime(stateId: toState.id, time: currentTime, poseMap: poseMap, object:  objects.first(where: { object in
                        object.label != ObjectLabel.POSE.rawValue
                        
                    }))
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
            allCurrentFrameWarnings = allCurrentFrameWarnings.filter({ warning in
                warning.changeStateClear == false
            })        }
        

        
        allCurrentFrameWarnings.remove(Warning(content: "", triggeredWhenRuleMet: true, delayTime: 0.0))
        updateWarnings(currentTime: currentTime, allCurrentFrameWarnings: allCurrentFrameWarnings)
        
        if currentTime > lastTime {
            lastTime = currentTime
        }
        
    }
    
    
    
}
