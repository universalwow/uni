

import SwiftUI


struct TransferToOtherRulesView: View {
    @Binding var sport:Sport
    var rule: Ruler
    @State var ruleTranferToState = SportState.startState
    @State var ruleTransferToRulesType = RuleType.SCORE
    @State var ruleTransferToRulesIndex = 0
    
    @EnvironmentObject var sportManager: SportsManager
    
    var body: some View {
        HStack {
            Text("迁移到其他规则集")
            
            Spacer()
            Text("状态")
            Picker("状态", selection: $ruleTranferToState) {
                ForEach(sport.allStates) { state in
                    Text(state.name).tag(state)
                }
            }
            Text("规则类型")
            Picker("类型", selection: $ruleTransferToRulesType) {
                ForEach(RuleType.allCases) { ruleType in
                    Text(ruleType.rawValue).tag(ruleType)
                }
            }

            Text("\(ruleTransferToRulesType.rawValue)规则集")
            if let state = sportManager.findFirstState(sportId: sport.id, stateId: ruleTranferToState.id) {
                Picker("规则集", selection: $ruleTransferToRulesIndex) {
                    if ruleTransferToRulesType == .SCORE {
                        ForEach(state.scoreRules.indices, id: \.self) { rulesIndex in
                            Text("索引 \(rulesIndex)").tag(rulesIndex)
                        }
                    }else {
                        ForEach(state.violateRules.indices, id: \.self) { rulesIndex in
                            Text("索引 \(rulesIndex)").tag(rulesIndex)
                        }
                    }
                    
                }.frame(width: 50)
            }
            
            
            
            Button("迁移") {
                sportManager.transferRuleTo(
                    sportId: sport.id,
                    stateId:ruleTranferToState.id,
                    ruleType:ruleTransferToRulesType,
                    rulesIndex:ruleTransferToRulesIndex,
                    rule: rule
                )
            }
                
            
                                                
        }.padding([.top], StaticValue.padding)
    }
}



struct StateTimerView: View {
    @EnvironmentObject var sportManager: SportsManager

    var sport:Sport
    var state:SportState
    
    @State var checkCycle = 1.0
    @State var passingRate = 0.8
    @State var keepTime = 5.0
    

    
    var body: some View {
        HStack {
            HStack {
                Text("检查周期(s)")
                TextField("检查周期", value: $checkCycle, formatter: formatter, onEditingChanged: { flag in
                    if !flag {
                        sportManager.updateSport(editedSport: sport, state: state, checkCycle: checkCycle, passingRate: passingRate, keepTime: keepTime)
                    }
                    
                }).textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
            
            HStack {
                Text("通过率")
                TextField("通过率", value: $passingRate, formatter: formatter, onEditingChanged: { flag in
                    if !flag {
                        sportManager.updateSport(editedSport: sport, state: state, checkCycle: checkCycle, passingRate: passingRate, keepTime: keepTime)
                        
                    }
                    
                }).textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
            
            HStack {
                Text("计分周期")
                TextField("记分周期数", value: $keepTime, formatter: formatter, onEditingChanged: { flag in
                    if !flag {
                        sportManager.updateSport(editedSport: sport, state: state, checkCycle: checkCycle, passingRate: passingRate, keepTime: keepTime)
                        
                    }
                    
                }).textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                
            }
            Spacer()
            
        }.onAppear(perform: {
            checkCycle = state.checkCycle ?? 1.0
            passingRate = state.passingRate ?? 0.8
            keepTime = state.keepTime ?? 5.0
        })
    }
    
}


struct SportView: View {
    
    @Binding var sport:Sport
    @State var sportName = ""
    @State var sportDescription = ""
    @State var stateName = ""
    @State var stateDescription = ""
    
    @State var fromState = SportState.startState
    @State var toState = SportState.endState
    
    @State var scoreState = SportState.startState
    @State var interactionScoreState = SportState.startState
    @State var violateState = SportState.startState
    @State var scoreSequenceIndex = 0
    
    @State var selectedLandmarkType = LandmarkType.LeftAnkle
    @State var collectedObjectId = ObjectLabel.POSE.rawValue
    
    @State var keyFrameFlag = false
    @State var editRuleFlag = false
    @State var showSetupRule = false
    @State var ruleClass = RuleClass.LandmarkSegment

    
    
    @State var scoreTimeLimit = 1.0
    @State var warningDelay = 1.0
    @State var sportClass = SportClass.None
    @State var sportPeriod = SportPeriod.None
    @State var sportDiscrete = SportPeriod.None
    @State var noStateWarning = ""
    @State var violateSequenceWarning = ""
    @State var isGestureController = false
    @State var interactionType = InteractionType.None
    @State var interactionScoreCycle = 1
    @State var dynamicAreaNumber = 3

    
    
    @EnvironmentObject var sportManager: SportsManager
    
    
    struct StaticValue {
        static let padding: CGFloat = 5
    }
    
    
    func updateBasicMessage() {
        sportManager.updateSport(editedSport: sport,
                                 sportName: sportName,
                                 sportDescription: sportDescription,
                                 sportClass: sportClass,
                                 sportPeriod: sportPeriod,
                                 sportDiscrete: sportDiscrete,
                                 noStateWarning: noStateWarning,
                                 isGestureController: isGestureController,
                                 interactionType: interactionType,
                                 dynamicAreaNumber: dynamicAreaNumber
        )
    }
    
    
    var basicMessage: some View {
        VStack {
            HStack {
                Text("基础信息")
                Text(":左/7 右/8 上/9 下/10 进入/11").opacity(isGestureController ? 0.8 : 0)
                Spacer()
                Text("交互属性")
                Picker("交互属性", selection: $interactionType.didSet({ _ in
                    updateBasicMessage()
                    
                })) {
                    ForEach(InteractionType.allCases) { _interactionType in
                        Text(_interactionType.rawValue).tag(_interactionType)
                    }
                }
                Toggle(isOn: $isGestureController.didSet { _ in
                    updateBasicMessage()
                }, label: {
                    Text("手势控制项目?").frame(maxWidth: .infinity, alignment: .trailing)
                })
                
               
                
            }
            
            if interactionType != .None {
                HStack {
                    Text("切换周期:")
                    TextField("切换周期:", value: $interactionScoreCycle, formatter: formatter, onEditingChanged: { flag in
                        if !flag {
                            sportManager.updateSport(editedSport: sport, scoreTimeLimit: scoreTimeLimit, interactionScoreCycle: interactionScoreCycle, warningDelay: warningDelay)
                        }
                        
                    }).textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    if interactionType == .OrdinalTouch {
                        Text("动态框数:")
                        TextField("动态框数:", value: $dynamicAreaNumber, formatter: formatter, onEditingChanged: { flag in
                            if !flag {
                                updateBasicMessage()
                            }
                            
                        }).textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    
                }
            }
            
            HStack{
                Text("名称:")
                TextField("名称", text: $sportName, onEditingChanged: { flag in
                    if !flag {
                        updateBasicMessage()
                    }
                    
                })
                Spacer()
//                Text("无状态提醒:")
//                TextField("无状态提醒", text: $noStateWarning, onEditingChanged: { flag in
//                    if !flag {
//                        updateBasicMessage()
//                    }
//
//                })
                Text("类型")
                Picker("运动类型", selection: $sportClass) {
                    ForEach(SportClass.allCases) { _sportClass in
                        Text(_sportClass.rawValue).tag(_sportClass)
                    }
                }
                
                Text("周期性")
                Picker("周期性", selection: $sportPeriod.didSet({ _ in
                    updateBasicMessage()
                    
                })) {
                    ForEach(SportPeriod.filteredPeriodCases(sportClass: sportClass)) { _sportPeriod in
                        Text(_sportPeriod.rawValue).tag(_sportPeriod)
                    }
                }
                
                Text("连续性")
                Picker("连续性", selection: $sportDiscrete.didSet({ _ in
                    updateBasicMessage()
                })) {
                    ForEach(SportPeriod.filteredDiscreteCases(sportClass: sportClass)) { _sportDiscrete in
                        Text(_sportDiscrete.rawValue).tag(_sportDiscrete)
                    }
                }
            }
            HStack{
                Text("简介:")
                TextField("简介", text: $sportDescription, onEditingChanged: { flag in
                    if !flag {
                        updateBasicMessage()
                    }
                    
                })
            }
            
        }.padding()
   

    }
    
    
    func interactionMessageView(sport: Sport) -> some View {
        VStack {
            Divider()
            HStack {
                Text("交互成绩状态序列")
                Spacer()
                HStack {
                    Text("状态")
                    Picker("成绩序列", selection: $interactionScoreState) {
                        ForEach(sport.allStates) { state in
                            Text(state.name).tag(state)
                        }
                    }
                }
                Spacer()
                Button(action: {
                    sportManager.addSportStateInteractionScoreSequence(sport: sport)
                    
                }) {
                    Text("添加成绩序列")
                }
            }
            
            if sport.interactionScoreStateSequence != nil {
                ForEach(sport.interactionScoreStateSequence!.indices, id: \.self) { sequenceIndex in
                    Divider()
                    HStack {
                        Text("序列\(sequenceIndex)")
                        Spacer()
                        
                        
                        Button(action: {
                           sportManager.addSportStateInteractionScoreSequence(sport: sport, index: sequenceIndex, scoreState: interactionScoreState)

                       }) {
                           Text("添加状态")
                       }
                        
                    }.padding([.top], StaticValue.padding)
                    
                            ForEach(sport.interactionScoreStateSequence![sequenceIndex].indices, id: \.self) { stateIndex in
                                HStack {
                                    Text(sport.findFirstStateByStateId(stateId: sport.interactionScoreStateSequence![sequenceIndex][stateIndex])!.name)
                                    Spacer()
                                    Button(action: {
                                        sportManager.deleteSportStateFromInteractionScoreSequence(sport: sport, sequenceIndex: sequenceIndex, stateIndex: stateIndex)
                                    }) {
                                        Text("删除")
                                    }
                                }.padding([.top], StaticValue.padding)

                            }
                    
                }
            }
            
            
        }
    }
    
    
    
    func collectedMessageView(sport: Sport) -> some View {
        VStack {
            VStack {
                Divider()
                HStack {
                    Text("需要收集极值的关节点")
                    Spacer()
                    Picker("关节点", selection: $selectedLandmarkType) {
                        ForEach(LandmarkType.allCases) { landmarkType in
                            Text(landmarkType.rawValue).tag(landmarkType)
                        }
                    }
                    Spacer()
                    Button(action: {
                        sportManager.updateSport(sport: sport, landmarkType: selectedLandmarkType)
                        
                    }) {
                        Text("添加关节点")
                    }
                    
                }
                ForEach(sport.selectedLandmarkTypes) { landmarkType in
                    HStack {
                        Text(landmarkType.id)
                        Spacer()
                        Button(action: {
                            sportManager.deleteSport(sport: sport, landmarkType: landmarkType)
                        }) {
                            Text("删除")
                        }
                    }.padding([.top], StaticValue.padding)
                }
            }
            
            
            VStack {
                Divider()
                HStack {
                    Text("需要收集的物体位置")
                    Spacer()
                    Picker("物体", selection: $collectedObjectId ) {
                        ForEach(sport.objects, id: \.self.id) { object in
                            Text(object.label).tag(object.label)
                        }
                    }
                    Spacer()
                    Button(action: {
                        sportManager.updateSport(sport: sport, objectId: collectedObjectId)

                    }) {
                        Text("添加物体")
                    }

                }
                ForEach(sport.collectedObjects, id: \.self) { objectId in
                    HStack {
                        Text(objectId)
                        Spacer()
                        Button(action: {
                            sportManager.deleteSport(sport: sport, objectId: objectId)
                        }) {
                            Text("删除")
                        }
                    }.padding([.top], StaticValue.padding)
                }
            }
            
            
            
            VStack {
                Divider()
                HStack {
                    HStack {
                        Text("计分周期:")
                        TextField("计分周期:", value: $scoreTimeLimit, formatter: formatter, onEditingChanged: { flag in
                            if !flag {
                                sportManager.updateSport(editedSport: sport, scoreTimeLimit: scoreTimeLimit, interactionScoreCycle: interactionScoreCycle, warningDelay: warningDelay)
                            }
                            
                        }).textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        Text("提示延迟:")
                        TextField("提示延迟:", value: $warningDelay, formatter: formatter, onEditingChanged: { flag in
                            if !flag {
                                sportManager.updateSport(editedSport: sport, scoreTimeLimit: scoreTimeLimit, interactionScoreCycle: interactionScoreCycle, warningDelay: warningDelay)
                            }
                            
                        }).textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)

                        
                    }
                    
                    
                }
            }
        }
    }
    
    
    
    var stateMessage: some View {
        VStack {
            HStack {
                Text("添加状态")
                TextField("状态", text: $stateName)
            }
            
            HStack {
                Text("状态描述")
                TextField("状态描述", text: $stateDescription)
            }
            
            if let sport = sportManager.findFirstSport(sport: sport) {
                VStack {
                    HStack {
                        Text("状态列表")
                        Spacer()
                        Button(action: {
                            sportManager.addSportState(editedSport: sport, stateName: stateName, stateDescription: stateDescription)
                            
                        }) {
                            Text("添加状态")
                        }
                    }
                    
                    ForEach(sport.allStates) { state in
                        Divider()
                        
                        VStack {
                            HStack {
                                Text("\(state.name)/\(state.id)")
                                Spacer()
                                
                                
                                
                                Button(action: {
                                    
                                    sportManager.setState(editedSport: sport, editedSportState: state)
                                    self.keyFrameFlag = true
                                    
                                }) {
                                    Text("添加关键帧")
                                        .foregroundColor(sportManager.keyFrameSetted(sport: sport, state: state) ? Color.green : Color.blue)
                                }
                                
                                
                                Button(action: {
                                    sportManager.addNewRules(editedSport: sport, editedSportState: state, ruleType: .SCORE)
                                    
                                    //                            self.editRuleFlag = true
                                    
                                }) {
                                    Text("添加计分规则集")
                                }
                                
                                Button(action: {
                                    sportManager.addNewRules(editedSport: sport, editedSportState: state, ruleType: .VIOLATE)
                                    //                            self.editRuleFlag = true
                                    
                                }) {
                                    Text("添加违规规则集")
                                }
                                
                                Button(action: {
                                    sportManager.deleteSportState(editedSport: sport, editedSportState: state)
                                    
                                }) {
                                    Text("删除")
                                }
                            }
                            if [SportClass.Timer, SportClass.TimeCounter].contains(sportClass) {
                                StateTimerView(sport: sport, state: state)
                            }
                            
                        }
                        .padding([.vertical])
                        
                        // 计分规则集
                        ForEach(state.scoreRules.indices, id: \.self) { scoreRulesIndex in
                            let scoreRules = state.scoreRules[scoreRulesIndex]
                            Divider()
                            HStack {
                                Text("\(state.name)/\(scoreRules.description)/\(scoreRulesIndex)")
                                Spacer()
                                
                                Button(action: {
                                    
                                    sportManager.setRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: nil, ruleType: .SCORE, ruleClass: .LandmarkSegment)
                                    self.editRuleFlag = true
                                }) {
                                    Text("添加规则")
                                }
                                
                                Button(action: {
                                    sportManager.deleteRules(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleType: .SCORE)
                                }) {
                                    Text("删除")
                                }
                            }.padding([.top], StaticValue.padding)
                            ForEach(scoreRules.landmarkSegmentRules) { rule in
                                Divider()
                                VStack {
                                    HStack {
                                        Text("规则: \(rule.id)")
                                        Spacer()
                                        
                                        
                                        Button(action: {
                                            sportManager.setRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: rule, ruleType: .SCORE, ruleClass: .LandmarkSegment)
                                            ruleClass = .LandmarkSegment
                                            self.showSetupRule = true
                                            
                                        }) {
                                            Text("修改")
                                        }
                                        Button(action: {
                                            sportManager.deleteRule(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleId: rule.id, ruleType: .SCORE, ruleClass: .LandmarkSegment)
                                            
                                        }) {
                                            Text("删除")
                                        }
                                        
                                        
                                    }.padding([.top], StaticValue.padding)
                                       
                                    TransferToOtherRulesView(sport: $sport, rule: rule)
                                    LandmarkSegmentRuleDescriptionView(rule: Binding.constant(rule))
                                }.background(Color.yellow)
                            }
                            
                            ForEach(scoreRules.landmarkRules) { rule in
                                Divider()
                                VStack {
                                    HStack {
                                        Text("规则: \(rule.id)")
                                        Spacer()
                                        
                                        Button(action: {
                                            sportManager.setRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: rule, ruleType: .SCORE, ruleClass: .Landmark)
                                            ruleClass = .Landmark

                                            self.showSetupRule = true
                                        }) {
                                            Text("修改")
                                        }
                                        Button(action: {
                                            sportManager.deleteRule(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleId: rule.id, ruleType: .SCORE, ruleClass: .Landmark)
                                        }) {
                                            Text("删除")
                                        }
                                        
                                        
                                    }.padding([.top], StaticValue.padding)
                                       
                                    TransferToOtherRulesView(sport: $sport, rule: rule)
                                    LandmarkRuleDescriptionView(rule: Binding.constant(rule))
                                }.background(Color.yellow)
                            }
                            
                            ForEach(scoreRules.observationRules) { rule in
                                Divider()
                                VStack {
                                    HStack {
                                        Text("规则: \(rule.id)")
                                        Spacer()
                                        
                                        
                                        Button(action: {
                                            sportManager.setRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: rule, ruleType: .SCORE, ruleClass: .Observation)
                                            ruleClass = .Observation

                                            self.showSetupRule = true
                                        }) {
                                            Text("修改")
                                        }
                                        Button(action: {
                                            sportManager.deleteRule(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleId: rule.id, ruleType: .SCORE, ruleClass: .Observation)
                                        }) {
                                            Text("删除")
                                        }
                                        
                                        
                                    }.padding([.top], StaticValue.padding)
                                       
                                    TransferToOtherRulesView(sport: $sport, rule: rule)
                                    ObservationRuleDescriptionView(rule: Binding.constant(rule))
                                }.background(Color.yellow)
                            }
                            
                            ForEach(scoreRules.fixedAreaRules) { rule in
                                Divider()
                                VStack {
                                    HStack {
                                        Text("规则:\(rule.id)")
                                        Spacer()
                                        
                                        Button(action: {
                                            sportManager.setRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: rule, ruleType: .SCORE, ruleClass: .FixedArea)
                                            ruleClass = .FixedArea

                                            self.showSetupRule = true
                                        }) {
                                            Text("修改")
                                        }
                                        Button(action: {
                                            sportManager.deleteRule(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleId: rule.id, ruleType: .SCORE, ruleClass: .FixedArea)
                                        }) {
                                            Text("删除")
                                        }
                                        
                                        
                                    }.padding([.top], StaticValue.padding)
                                       
                                    TransferToOtherRulesView(sport: $sport, rule: rule)
                                    FixedAreaRuleDescriptionView(rule: Binding.constant(rule))
                                }.background(Color.yellow)
                            }
                            
                            ForEach(scoreRules.dynamicAreaRules) { rule in
                                Divider()
                                VStack {
                                    HStack {
                                        Text("规则:\(rule.id)")
                                        Spacer()
                                        
                                        Button(action: {
                                            sportManager.setRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: rule, ruleType: .SCORE, ruleClass: .DynamicArea)
                                            ruleClass = .DynamicArea

                                            self.showSetupRule = true
                                        }) {
                                            Text("修改")
                                        }
                                        Button(action: {
                                            sportManager.deleteRule(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleId: rule.id, ruleType: .SCORE, ruleClass: .DynamicArea)
                                        }) {
                                            Text("删除")
                                        }
                                        
                                        
                                    }.padding([.top], StaticValue.padding)
                                       
                                    TransferToOtherRulesView(sport: $sport, rule: rule)
                                    DynamicAreaRuleDescriptionView(rule: Binding.constant(rule))
                                }.background(Color.yellow)
                            }
                        }
                        
                        
//                         违规规则集
                        ForEach(state.violateRules.indices, id: \.self) { scoreRulesIndex in
                            let scoreRules = state.violateRules[scoreRulesIndex]
                            Divider()
                            HStack {
                                Text("\(state.name)/\(scoreRules.description)/\(scoreRulesIndex)")
                                Spacer()

                                Button(action: {

                                    sportManager.setRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: nil, ruleType: .VIOLATE, ruleClass: .LandmarkSegment)
                                    
                                    self.editRuleFlag = true
                                }) {
                                    Text("添加规则")
                                }

                                Button(action: {
                                    sportManager.deleteRules(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleType: .VIOLATE)
                                }) {
                                    Text("删除")
                                }
                            }.padding([.top], StaticValue.padding)
                            ForEach(scoreRules.landmarkSegmentRules) { rule in
                                Divider()
                                VStack {

                                    HStack {
                                        Text("规则:")
                                        Text(rule.id)
                                        Spacer()
                                        Button(action: {
                                            sportManager.setRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: rule, ruleType: .VIOLATE, ruleClass: .LandmarkSegment)
                                            ruleClass = .LandmarkSegment

                                            self.showSetupRule = true
                                        }) {
                                            Text("修改")
                                        }
                                        Button(action: {
                                            sportManager.deleteRule(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleId: rule.id, ruleType: .VIOLATE, ruleClass: .LandmarkSegment)

                                        }) {
                                            Text("删除")
                                        }


                                    }.padding([.top], StaticValue.padding)

                                    TransferToOtherRulesView(sport: $sport, rule: rule)
                                    LandmarkSegmentRuleDescriptionView(rule: Binding.constant(rule))


                                }.background(Color.gray)
                            }
                            
                            ForEach(scoreRules.landmarkRules) { rule in
                                Divider()
                                VStack {
                                    HStack {
                                        Text("规则: \(rule.id)")
                                        Spacer()
                                        
                                        Button(action: {
                                            sportManager.setRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: rule, ruleType: .VIOLATE, ruleClass: .Landmark)
                                            ruleClass = .Landmark

                                            self.showSetupRule = true
                                        }) {
                                            Text("修改")
                                        }
                                        Button(action: {
                                            sportManager.deleteRule(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleId: rule.id, ruleType: .VIOLATE, ruleClass: .Landmark)
                                        }) {
                                            Text("删除")
                                        }
                                        
                                        
                                    }.padding([.top], StaticValue.padding)
                                       
                                    TransferToOtherRulesView(sport: $sport, rule: rule)
                                    LandmarkRuleDescriptionView(rule: Binding.constant(rule))
                                }.background(Color.gray)
                            }
                            
                            ForEach(scoreRules.observationRules) { rule in
                                Divider()
                                VStack {
                                    HStack {
                                        Text("规则: \(rule.id)")
                                        Spacer()
                                        
                                        
                                        Button(action: {
                                            sportManager.setRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: rule, ruleType: .VIOLATE, ruleClass: .Observation)
                                            ruleClass = .Observation
                                            self.showSetupRule = true
                                            
                                        }) {
                                            Text("修改")
                                        }
                                        Button(action: {
                                            sportManager.deleteRule(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleId: rule.id, ruleType: .VIOLATE, ruleClass: .Observation)
                                        }) {
                                            Text("删除")
                                        }
                                        
                                        
                                    }.padding([.top], StaticValue.padding)
                                       
                                    TransferToOtherRulesView(sport: $sport, rule: rule)
                                    ObservationRuleDescriptionView(rule: Binding.constant(rule))
                                }.background(Color.gray)
                            }
                        }
                    }
                    
                    
                    
                }
                
                
                VStack {
                    Divider()
                    HStack{
                        Text("状态转换")
                        Spacer()
                        Picker("From", selection: $fromState) {
                            ForEach(sport.allStates) { state in
                                Text(state.name).tag(state)
                            }
                        }
                        Spacer()
                        Picker("To", selection: $toState) {
                            ForEach(sport.allStates) { state in
                                Text(state.name).tag(state)
                            }
                        }
                    }
                    HStack {
                        Text("状态转换列表")
                        Spacer()
                        Button(action: {
                            sportManager.addSportStatetransform(sport: sport, fromSportState: fromState, toSportState: toState)
                            let _fromState = fromState
                            fromState = toState
                            toState = _fromState
                            
                        }) {
                            Text("添加状态转换")
                        }
                    }
                    
                    
                    ForEach(sport.stateTransForm) { transform in
                        if let fromState = sport.findFirstStateByStateId(stateId: transform.from), let toState =
                            sport.findFirstStateByStateId(stateId: transform.to) {
                            HStack {
                                Text("\(fromState.name) -> \(toState.name)")
                                Spacer()
                                Button(action: {
                                    sportManager.deleteSportStateTransForm(sport: sport, fromSportState: fromState, toSportState: toState)
                                    
                                }) {
                                    Text("删除")
                                }
                                
                            }.padding([.top], StaticValue.padding)
                            
                            
                        }
                    }
                }
                
                
                VStack {
                    Divider()
                    HStack {
                        Text("成绩状态序列")
                        Spacer()
                        HStack {
                            Text("状态")
                            Picker("成绩序列", selection: $scoreState) {
                                ForEach(sport.allStates) { state in
                                    Text(state.name).tag(state)
                                }
                            }
                        }
                        Spacer()
                        Button(action: {
                            sportManager.addSportStateScoreSequence(sport: sport)
                            
                        }) {
                            Text("添加成绩序列")
                        }
                    }
                    
                    ForEach(sport.scoreStateSequence.indices, id: \.self) { sequenceIndex in
                        Divider()
                        HStack {
                            Text("序列\(sequenceIndex)")
                            Spacer()
                            
                            
                            Button(action: {
                               sportManager.addSportStateScoreSequence(sport: sport, index: sequenceIndex, scoreState: scoreState)
   
                           }) {
                               Text("添加状态")
                           }
                            
                        }.padding([.top], StaticValue.padding)
                        
                        ForEach(sport.scoreStateSequence[sequenceIndex].indices, id: \.self) { stateIndex in
                            HStack {
                                Text(sport.findFirstStateByStateId(stateId: sport.scoreStateSequence[sequenceIndex][stateIndex])!.name)
                                Spacer()
                                Button(action: {
                                    sportManager.deleteSportStateFromScoreSequence(sport: sport, sequenceIndex: sequenceIndex, stateIndex: stateIndex)
                                }) {
                                    Text("删除")
                                }
                            }.padding([.top], StaticValue.padding)
                            
                        }
                        
                    }
                }
                
                
                
                interactionMessageView(sport: sport)
                
                VStack {
                    Divider()
                    HStack {
                        Text("违规状态序列")
                        TextField("请输入违规提醒:请先输入提醒再添加状态!", text: $violateSequenceWarning)
                        Spacer()
                        HStack {
                            Text("状态")
                            Picker("违规序列", selection: $violateState) {
                                ForEach(sport.allStates) { state in
                                    Text(state.name).tag(state)
                                }
                            }
                        }
                        Spacer()
                        Button(action: {
                            sportManager.addSportStateViolateSequence(sport: sport)

                        }) {
                            Text("添加违规序列")
                        }
                    }

                    ForEach(sport.violateStateSequence.indices, id: \.self) { sequenceIndex in
                        Divider()
                        HStack {
                            Text("序列\(sequenceIndex)")
                            Spacer()

                            Text("提醒:\(sport.violateStateSequence[sequenceIndex].warning.content)")
                            

                            Button(action: {
                                sportManager.addSportStateViolateSequence(sport: sport, index: sequenceIndex, violateState: violateState, warning: violateSequenceWarning)

                           }) {
                               Text("添加状态")
                           }

                        }.padding([.top], StaticValue.padding)

                        ForEach(sport.violateStateSequence[sequenceIndex].stateIds.indices, id: \.self) { stateIndex in
                            HStack {
                                Text(sport.findFirstStateByStateId(stateId: sport.violateStateSequence[sequenceIndex].stateIds[stateIndex])!.name)
                                Spacer()
                                Button(action: {
                                    sportManager.deleteSportStateFromViolateSequence(sport: sport, sequenceIndex: sequenceIndex, stateIndex: stateIndex)
                                }) {
                                    Text("删除")
                                }
                            }.padding([.top], StaticValue.padding)

                        }

                    }
                }
                
                collectedMessageView(sport: sport)
                
            }
            
        }.padding()
        
    }
    
    var body: some View {
        UniScrollView{
            VStack {
                basicMessage
                Divider()
                stateMessage
                Spacer()
            }
        }
        .sheet(isPresented: $editRuleFlag, onDismiss: {
            
        }) {
            RuleView()
        }
        .sheet(isPresented: self.$showSetupRule) {
            
            switch ruleClass {
            case .LandmarkSegment:
                SetupLandmarkSegmentRuleView()
                
            case .Landmark:
                SetupLandmarkRuleView()
            case .Observation:
                SetupObservationRuleView()
            
            case .FixedArea:
//                SetupAreaRuleView()
                SetupFixedAreaRuleView()
            case .DynamicArea:
                SetupDynamicAreaRuleView()
            }
            
            
        }
        
        .sheet(isPresented: $keyFrameFlag, onDismiss: {
            
        }) {
            FramesView()
        }
        
        .task {
            if let sport = sportManager.findFirstSport(sport: self.sport) {
                self.sportName = sport.name
                self.sportDescription = sport.description
                self.sportClass = sport.sportClass
                self.sportPeriod = sport.sportPeriod
                self.sportDiscrete = sport.sportDiscrete ?? .None
                self.scoreTimeLimit = sport.scoreTimeLimit
                self.warningDelay = sport.warningDelay
                self.noStateWarning = sport.noStateWarning
                self.isGestureController = sport.isGestureController
                self.interactionType = sport.interactionType
                self.interactionScoreCycle = sport.interactionScoreCycle ?? 1
            }
        }
    }
}

struct SportView_Previews: PreviewProvider {
    static var previews: some View {
        SportView(sport: Binding.constant(Sport.newSport))
    }
}
