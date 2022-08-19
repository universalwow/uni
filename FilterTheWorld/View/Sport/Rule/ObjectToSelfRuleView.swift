

import SwiftUI

/*
 * 物体与上一状态相比相对自身位移
 */

struct ObjectToSelfRuleView: View {
    var objectToSelf: ObjectToSelf
    
    @EnvironmentObject var sportManager: SportsManager
    
    @State var warningContent = ""
    @State var triggeredWhenRuleMet = false
    @State var delayTime: Double = 2.0

    @State var direction = Direction.UP
    @State var xLowerBound = 0.0
    @State var yLowerBound = 0.0
    
    
    func updateLocalData() {

 
    }
    
    func updateRemoteData() {
        sportManager.updateRuleObjectToSelf(direction: direction, xLowerBound: xLowerBound, yLowerBound: yLowerBound, warningContent: warningContent, triggeredWhenRuleMet: triggeredWhenRuleMet, delayTime: delayTime, id: objectToSelf.id)

    }
    

    
    var body: some View {
        VStack {
            
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $warningContent) { flag in
                        if !flag {
                            updateRemoteData()
                        }
                        
                    }
                    Spacer()
                    Text("延迟(s):")
                    TextField("延迟时长", value: $delayTime, formatter: formatter,onEditingChanged: { flag in
                        if !flag {
                            updateRemoteData()
                        }
                        
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    Toggle("规则满足时提示", isOn: $triggeredWhenRuleMet.didSet{ _ in
                        updateRemoteData()
                    })
                }
                HStack {
                    Text("方向")
                    Picker("方向", selection: $direction.didSet{ _ in
                        updateRemoteData()
                        updateLocalData()
                        
                    }) {
                        ForEach(Direction.allCases) { direction in
                            Text(direction.rawValue).tag(direction)
                        }
                    }
                    
                    Text("X最小值:")
                    TextField("X最小值", value: $xLowerBound, formatter: formatter) { flag in
                        if !flag {
                            updateRemoteData()

                        }
                        
                    }
                        .foregroundColor(.black)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    Spacer()
                    Text("Y最小值:")
                    TextField("Y最小值", value: $yLowerBound, formatter: formatter) { flag in
                        if !flag {
                            updateRemoteData()
                        }
                        
                    }
                        .foregroundColor(.black)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
            }
        }
        .onAppear{
            let objectToSelf = sportManager.getRuleObjectToSelf(id: objectToSelf.id)
            warningContent = objectToSelf.warning.content
            triggeredWhenRuleMet = objectToSelf.warning.triggeredWhenRuleMet
            delayTime = objectToSelf.warning.delayTime
            
            direction = objectToSelf.toDirection
            xLowerBound = objectToSelf.xLowerBound
            yLowerBound = objectToSelf.yLowerBound
            
        }
    }
}

