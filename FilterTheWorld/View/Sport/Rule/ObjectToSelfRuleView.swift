

import SwiftUI

/*
 * 物体与上一状态相比相对自身位移
 */

struct ObjectToSelfRuleView: View {
    
    @EnvironmentObject var sportManager: SportsManager
    
    @State var toggle = false
    @State var warning = ""
    @State var fromObjectId = ""
    @State var direction = Direction.UP
    @State var xLowerBound = 0.0
    @State var yLowerBound = 0.0
    
    
    func setInitData() {
        if toggle {

            
            sportManager.setRuleObjectToSelf(objectId: fromObjectId, direction: direction, xLowerBound: xLowerBound, yLowerBound: yLowerBound, warning: warning)
         
        }

    }
    
    func resetInitData() {
        if toggle {
            sportManager.updateRuleObjectToSelf(objectId: fromObjectId, direction: direction, xLowerBound: xLowerBound, yLowerBound: yLowerBound, warning: warning)
        }
       
    }
 
    
    func updateLocalData() {
        if toggle {

        }
 
    }
    
    func updateRemoteData() {
        if toggle {
            sportManager.updateRuleObjectToSelf(xLowerBound: xLowerBound, yLowerBound: yLowerBound)
        }
    }
    
    
    func toggleOff() {
        warning = ""
        if self.sportManager.findSelectedObjects().count > 1 {
            fromObjectId = self.sportManager.findSelectedObjects().first(where: { object in
                object.label != ObjectLabel.POSE.rawValue
            })!.label
        }else {
            fromObjectId = self.sportManager.findSelectedObjects().first!.label
        }
        
        direction = Direction.UP
        xLowerBound = 0.0
        yLowerBound = 0.0
    }
    
    var body: some View {
        VStack {
            Toggle("物体相对自身位移", isOn: $toggle.didSet { isOn in
                if isOn {
                    setInitData()
                    updateLocalData()
                } else {
                    sportManager.setRuleToStateLandmark(toStateLandmark: nil)
                    toggleOff()
                }
                
            })
            VStack{
                HStack {
                    Text("提醒:")
                    TextField("提醒...", text: $warning) { flag in
                        if !flag {
                            resetInitData()
                        }
                        
                    }
                }
                VStack {
                    HStack {
                        Text("物体")
                        Picker("物体", selection: $fromObjectId.didSet{ _ in
                            resetInitData()
                            updateLocalData()
                            
                        }) {
                            ForEach(sportManager.findSelectedObjects()) { object in
                                Text(object.label).tag(object.label)
                            }
                        }
                        Spacer()
                        Text("方向")
                        Picker("方向", selection: $direction.didSet{ _ in
                            resetInitData()
                            updateLocalData()
                            
                        }) {
                            ForEach(Direction.allCases) { direction in
                                Text(direction.rawValue).tag(direction)
                            }
                        }
                    }
                    
                    
                    HStack {
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
                
            }.disabled(!toggle)
        }
        .onAppear{
            if let objectToSelf = sportManager.getRuleObjectToSelf() {
                warning = objectToSelf.warning
                fromObjectId = objectToSelf.objectId
                direction = objectToSelf.toDirection
                xLowerBound = objectToSelf.xLowerBound
                yLowerBound = objectToSelf.yLowerBound
                
                toggle = true

            }else {
                if self.sportManager.findSelectedObjects().count > 1 {
                    fromObjectId = self.sportManager.findSelectedObjects().first(where: { object in
                        object.label != ObjectLabel.POSE.rawValue
                    })!.label
                }else {
                    if let object = self.sportManager.findSelectedObjects().first {
                        fromObjectId = object.label
                    }
                }
            }
            
        }
    }
}

