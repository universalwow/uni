

import SwiftUI

struct SportView: View {
    
    var sport:Sport
    @State var sportName = ""
    @State var sportDescription = ""
    @State var stateName = ""
    @State var stateDescription = ""
    
    @State var fromState = SportState.startState
    @State var toState = SportState.endState
    
    @State var scoreState = SportState.startState
    
    @State var keyFrameFlag = false
    @State var editRuleFlag = false
    
    
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
                        Text(state.name)
                        Spacer()
                        
                        Button(action: {
                            
                            sportManager.setCurrentSportState(editedSport: sport, editedSportState: state)
                            self.keyFrameFlag = true
                            
                        }) {
                            Text("添加关键帧")
                                .foregroundColor(sportManager.keyFrameSetted(sport: sport, state: state) ? Color.green : Color.blue)
                        }
                        
                        Button(action: {
                            sportManager.addNewSportStateRules(editedSport: sport, editedSportState: state, ruleType: .SCORE)

//                            self.editRuleFlag = true
                            
                        }) {
                            Text("添加计分规则集")
                        }
                        
                        Button(action: {
                            sportManager.addNewSportStateRules(editedSport: sport, editedSportState: state, ruleType: .VIOLATE)
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
                    ForEach(state.complexScoreRules) { scoreRules in
                        Divider()
                        HStack {
                            Text(scoreRules.description)
                            Spacer()
                            
                            Button(action: {
                                
                                sportManager.setCurrentSportStateRule(editedSport: sport, editedSportState: state, editedSportStateRules: scoreRules, editedSportStateRule: nil, ruleType: .SCORE)
                                self.editRuleFlag = true
                            }) {
                                Text("添加规则")
                            }
                            
                            Button(action: {
                                sportManager.deleteSportStateRules(editedSport: sport, editedSportState: state, editedRules: scoreRules, ruleType: .SCORE)
                            }) {
                                Text("删除")
                            }
                        }.padding([.top], StaticValue.padding)
                        
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
//                            print("scoreStateSequence \(sportManager.findFirstSport(sport: sport)?.scoreStateSequence.count)")
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
            RuleView()
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
        SportView(sport: Sport.newSport)
    }
}
