

import SwiftUI




struct TransferToOtherRulesView: View {
    @Binding var sport:Sport
    var rule: ComplexRule
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
            let state = sportManager.findFirstSportState(editedSport: sport, sportStateUUID: ruleTranferToState.id)!
            if ruleTransferToRulesType == .SCORE {
                Picker("规则集", selection: $ruleTransferToRulesIndex) {
                    if ruleTransferToRulesType == .SCORE {
                        ForEach(state.complexScoreRules.indices, id: \.self) { rulesIndex in
                            Text("索引 \(rulesIndex)").tag(rulesIndex)
                        }
                    }else {
                        ForEach(state.complexViolateRules.indices, id: \.self) { rulesIndex in
                            Text("索引 \(rulesIndex)").tag(rulesIndex)
                        }
                    }
                    
                }.frame(width: 50)
            }
            
            Button("迁移") {
                sportManager.upsertRule(
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




struct SportView: View {
    
    @Binding var sport:Sport
    @State var sportName = ""
    @State var sportDescription = ""
    @State var stateName = ""
    @State var stateDescription = ""
    
    @State var fromState = SportState.startState
    @State var toState = SportState.endState
    
    @State var scoreState = SportState.startState
    
    @State var keyFrameFlag = false
    @State var editRuleFlag = false
    @State var selectedLandmarkSegment = LandmarkSegment.initValue()
    
//    @State var ruleTranferToState = SportState.startState
//    @State var ruleTransferToRulesIndex = 0
//    @State var ruleTransferToRulesType = RuleType.SCORE

    
    @EnvironmentObject var sportManager: SportsManager
    
    
    struct StaticValue {
        static let padding: CGFloat = 5
    }
    
    
    var basicMessage: some View {
        VStack {
            HStack {
                Text("基础信息")
                Spacer()
                Button(action: {
                    sportManager.updateSport(editedSport: sport, sportName: sportName, sportDescription: sportDescription)
                    
                }) {
                    Text("保存名称/简介")
                }
            }
            
            HStack{
                Text("名称")
                TextField("名称", text: $sportName)
            }
            HStack{
                Text("简介")
                TextField("简介", text: $sportDescription)
            }
            
        }.padding()
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
                    HStack {
                        Text("\(state.name)/\(state.id)")
                        Spacer()
                        
                        Button(action: {
                            
                            sportManager.setCurrentSportState(editedSport: sport, editedSportState: state)
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
                    }.padding([.vertical])
                    
                    // 规则集
                    ForEach(state.complexScoreRules.indices, id: \.self) { scoreRulesIndex in
                        let scoreRules = state.complexScoreRules[scoreRulesIndex]
                        Divider()
                        HStack {
                            Text("\(state.name)/\(scoreRules.description)/\(scoreRulesIndex)")
                            Spacer()
                            
                            Button(action: {
                                
                                sportManager.setCurrentSportStateRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: nil, ruleType: .SCORE)
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
                        ForEach(scoreRules.rules) { rule in
                            Divider()
                            VStack {
                                
                                HStack {
                                    Text("规则:")
                                    Text(rule.id)
                                    
                                    Spacer()
                                    
                                    
                                    Button(action: {
                                        sportManager.setCurrentSportStateRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: rule, ruleType: .SCORE)
                                        
                                        selectedLandmarkSegment = LandmarkSegment.init(startLandmark: Landmark.init(position: Point3D.zero, landmarkType: rule.landmarkSegmentType.startLandmarkType), endLandmark: Landmark(position: Point3D.zero, landmarkType: rule.landmarkSegmentType.endLandmarkType))
                                        self.editRuleFlag = true
                                    }) {
                                        Text("修改")
                                    }
                                    Button(action: {
                                        sportManager.deleteRule(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleType: .SCORE, ruleId: rule.id)
                                    }) {
                                        Text("删除")
                                    }
                                    
                                    
                                }.padding([.top], StaticValue.padding)
                                   
                                TransferToOtherRulesView(sport: $sport, rule: rule)
                                RuleDescriptionView(rule: Binding.constant(rule))

                                
                            }.background(Color.yellow)
                        }
                    }
                }
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
                    if let fromState = sport.findFirstSportStateByUUID(editedStateUUID: transform.from), let toState = sport.findFirstSportStateByUUID(editedStateUUID: transform.to) {
                        //                        Divider()
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
                
                Divider()
                HStack {
                    Text("成绩状态序列")
                    Spacer()
                    Picker("成绩序列", selection: $scoreState) {
                        ForEach(sport.allStates) { state in
                            Text(state.name).tag(state)
                        }
                    }
                    Spacer()
                    Button(action: {
                        sportManager.addSportStateScoreSequence(sport: sport, scoreState: scoreState)
                        
                    }) {
                        Text("添加成绩序列")
                    }
                    
                }
                ForEach(sport.scoreStateSequence.indices, id: \.self) { stateIndex in
                    HStack {
                        Text(sport.scoreStateSequence[stateIndex].name)
                        Spacer()
                        Button(action: {
                            sportManager.deleteSportStateFromScoreSequence(sport: sport, stateIndex: stateIndex)
                        }) {
                            Text("删除")
                        }
                    }.padding([.top], StaticValue.padding)
                    
                }
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
            RuleView(selectedLandmarkSegment: selectedLandmarkSegment)
        }
        .sheet(isPresented: $keyFrameFlag, onDismiss: {
            
        }) {
            FramesView()
        }
        
        .task {
            if let sport = sportManager.findFirstSport(sport: self.sport) {
                self.sportName = sport.name
                self.sportDescription = sport.description
            }
        }
    }
}

struct SportView_Previews: PreviewProvider {
    static var previews: some View {
        SportView(sport: Binding.constant(Sport.newSport))
    }
}
