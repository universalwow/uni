

import SwiftUI


struct WarningView: View {
    @Binding var warning: String
    @Binding var warningBack: String
    
    var offset: CGSize
    
    var show : Bool {
        warning != ""
    }
    
    var body: some View {
        
        Text(warning != "" ? warning : warningBack)
            .padding(10)
            .padding([.horizontal], 20)
            .frame(minWidth: offset.width/5)
            .background(Capsule().fill(Color.green))
            .font(.largeTitle)
            .offset(x: show ? offset.width * 2 / 3 : offset.width + 30, y: 0)
            .animation(
                .linear(duration: 0.5), value: show)
    }
}

struct WarningsView:View {
    @EnvironmentObject var sportGround: SportsGround

    
    //    当前正在展示的提示消息
    @State var warningFirst: String = ""
    @State var warningSecond: String = ""
    @State var warningThird: String = ""

    @State var inUsingTime : [Int: Double] = [:]
    var allChannel = [1,2,3]
    
    @State var warningFirstBack: String = ""
    @State var warningSecondBack: String = ""
    @State var warningThirdBack: String = ""
    

    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                WarningView(warning: self.$warningFirst, warningBack: $warningFirstBack, offset: geometry.size)
                WarningView(warning: self.$warningSecond,warningBack: $warningSecondBack, offset: geometry.size)
                WarningView(warning: self.$warningThird, warningBack: $warningThirdBack, offset: geometry.size)
                                
            }.onChange(of: sportGround.warnings) { _ in
                
                // 找到在轨道但不在warningArray中的的提示 清空对应轨道
                if !sportGround.warnings.contains(warningFirst) && warningFirst != "" {
                    
                    warningFirstBack = warningFirst
                    warningFirst = ""
                }
                if !sportGround.warnings.contains(warningSecond) && warningSecond != "" {
                    warningSecondBack = warningSecond
                    warningSecond = ""
                }
                
                if !sportGround.warnings.contains(warningThird) && warningThird != "" {
                    warningThirdBack = warningThird
                    warningThird = ""

                }
                
                sportGround.warnings.forEach { warning in
//                    如果提示消息不在展示 找到空闲时间最长的轨道
                    
                    if ![warningFirst, warningSecond, warningThird].contains(warning) {
                        
                        let allNotInUseChannels = allChannel.filter { channel in
                            !inUsingTime.keys.contains(channel)
                        }
                        
                        if allNotInUseChannels.count > 0 {
                            let channel = allNotInUseChannels.first!
                            if channel == 1 {
                                warningFirst = warning
                                inUsingTime.updateValue(Date().milliStamp, forKey: 1)
                            }else if channel == 2 {
                                warningSecond = warning
                                inUsingTime.updateValue(Date().milliStamp, forKey: 2)

                            }else if channel == 3 {
                                warningThird = warning
                                inUsingTime.updateValue(Date().milliStamp, forKey: 3)
                            }
                        } else {

                            let channelToUse = inUsingTime.sorted { (leftElement, rightElement) -> Bool  in
                                leftElement.value < rightElement.value
                            }.first!
                            
                            if Date().milliStamp - channelToUse.value > 2000 {
                                let channel = channelToUse.key
                                if channel == 1 {
                                    warningFirst = warning
                                    inUsingTime.updateValue(Date().milliStamp, forKey: 1)
                                }else if channel == 2 {
                                    warningSecond = warning
                                    inUsingTime.updateValue(Date().milliStamp, forKey: 2)

                                }else if channel == 3 {
                                    warningThird = warning
                                    inUsingTime.updateValue(Date().milliStamp, forKey: 3)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


struct SporterView: View {
    @EnvironmentObject var sportGround: SportsGround
    var body: some View {
        VStack {
            if let sporter = sportGround.sporters.first {
                HStack{
                    Text("\(sporter.sport.name):\(sporter.name)").padding()
                        .background(Capsule().fill(Color.green))
                    Spacer()
                    HStack {
                        Text("\(sporter.sport.findFirstStateByStateId(stateId: sporter.currentStateTime.stateId)!.name)/\(sporter.nextStatePreview.name)/\(sporter.nextState.name)?")
                            .padding()
                            .background(Capsule().fill(Color.green))
                        Text("\(sporter.scoreTimes.count)").padding()
                            .background(Capsule().fill(Color.green))
                    }
                    
                    
                    
                    
                }.foregroundColor(.white)
            }
            Spacer()
            WarningTest()
//                .background(Color.green)
                .padding([.bottom], 20)
                .opacity(0.5)
            
        }.padding()
    }
}
