

import SwiftUI

struct ReportDetail: View {
    @Binding var report: SportReport
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack{
                    Text("Sporter:\(report.sporterName)")
                    Text("Sport:\(report.sportName)")
                    Spacer()
                    Text("运动时长: \(report.sportTime)")
                }
                VStack(alignment: .leading) {
                    
                    
                    Group {
                        Divider()
                        Text("Score Analysis:")
                        HStack{
                            Text("总计分次数:\(report.scoreTimes.count)")
                        }
                        
                        if let stateDescriptions = report.statesDescription {
                            ForEach(stateDescriptions) { stateDescription in
                                let stateScores = report.findStateScoreTimes(stateId: stateDescription.stateId)
                                HStack {
                                    Text("状态:\(stateDescription.stateName)")
                                    Text("计分次数:\(stateScores.count)")
                                    if let checkCycle = stateDescription.checkCycle {
                                        Text("计分时长:\(Double(stateScores.count) * checkCycle)")
                                    }
                                }
                            }
                        }
                        
                        
                        
//                        Chart(report.scoreStates) {
//                                BarMark(
//                                    x: .value("Category", $0.category),
//                                    y: .value("Value", $0.value)
//                                )
//                                .foregroundStyle(.green)
//                            }
                        
                        
                        
                        Section("时间轴") {
                            VStack(alignment: .leading) {
                                HStack {
                                    HStack {
                                        Text("时间")
                                        Spacer()
                                    }
                                    
                                    .frame(width: UIScreen.screenWidth/3)
                                    HStack {
                                        Text("相对时间")
                                        Spacer()
                                    }
                                    .frame(width: UIScreen.screenWidth/3)
                                    
                                    HStack {
                                        Text("状态")
                                        Spacer()
                                    }
                                    .frame(width: UIScreen.screenWidth/3)
                                }
                                
                                
                                ForEach(report.scoreTimes) { scoreTime in
                                    let stateDescription = report.findStateDescription(stateId: scoreTime.stateId)
                                    HStack {
                                        HStack {
                                            Text(SportReport.timeFormater(time: scoreTime.time))
                                            Spacer()
                                        }
                                        .frame(width: UIScreen.screenWidth/3)
                                        HStack {
                                            Text(SportReport.secondFormater(time: scoreTime.time - report.startTime))
                                            Spacer()
                                        }
                                        .frame(width: UIScreen.screenWidth/3)
                                        
                                        HStack {
                                            Text(stateDescription.stateName)
                                            Spacer()
                                        }
                                        .frame(width: UIScreen.screenWidth/3)
                                    }
                                }
                            }
                            
                        }
                        
                        
                    }
                    
                    Group {
                        Divider()
                        Text("Warning Analysis:")
                        HStack{
                            Text("提示总数:\(report.warnings.count)")
                        }
                        ForEach(report.warningsGroupByContents, id: \.self) { warningContent in
                            Text("\(warningContent):\(                           report.filterWarningsByContent(content: warningContent))")
                        }
                        
//                        Chart(report.scoreStates) {
//                                BarMark(
//                                    x: .value("Category", $0.category),
//                                    y: .value("Value", $0.value)
//                                )
//                                .foregroundStyle(.green)
//                            }
                        
                        
                        
                        Section("时间轴") {
                                VStack(alignment: .leading) {
                                    HStack {
                                        HStack {
                                            Text("时间")
                                            Spacer()
                                        }
                                        .frame(width: UIScreen.screenWidth/3)
                                        HStack {
                                            Text("相对时间")
                                            Spacer()
                                        }
                                        .frame(width: UIScreen.screenWidth/3)
                                        
                                        HStack {
                                            Text("提示消息")
                                            Spacer()
                                        }
                                        .frame(width: UIScreen.screenWidth/3)
                                    }
                                    
                                    
                                    ForEach(report.sortWarningsByTime) { warningData in
                                        HStack {
                                            HStack {
                                                Text(SportReport.timeFormater(time: warningData.time))
                                                Spacer()
                                            }
                                            .frame(width: UIScreen.screenWidth/3)
                                            HStack {
                                                Text(SportReport.secondFormater(time: warningData.time - report.startTime))
                                                Spacer()
                                            }
                                            .frame(width: UIScreen.screenWidth/3)
                                            
                                            HStack {
                                                Text(warningData.content)
                                                Spacer()
                                            }
                                            .frame(width: UIScreen.screenWidth/3)
                                        }
                                    }
                                }
                        }
                        
                        
                    }
                    
                }
                
            }
        }
        
    }
}

struct SportReportView: View {
    
    @ObservedObject var sportsReport = SportsReport()
    @State private var loading = false
    init() {
           UITableView.appearance().backgroundColor = .clear
       }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            NavigationView {
                List {
                    ForEach(sportsReport.reports, content: { report in
                        NavigationLink(destination: {
                            ReportDetail(report: Binding.constant(report))
                                .padding()
                        }) {
                            VStack {
                                HStack{
                                    Text(report.sporterName)
                                    Text(report.sportFullName)
                                    Spacer()
                                }
                                HStack {
                                    Text("开始时间:\(SportReport.timeFormater(time: report.startTime))")
                                    Text("结束时间:\(SportReport.timeFormater(time: report.endTime))")
                                    Spacer()
                                }
                                
                            }
                        }
                        
                    })
                    .listRowInsets(EdgeInsets())
                }.navigationBarTitle(Text("运动报告"))
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
            
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .padding()
                .foregroundColor(.yellow)
                .rotationEffect(self.loading ?  Angle(degrees: 0) : Angle(degrees: 360))
                .onTapGesture {
                    withAnimation(Animation.linear(duration: 1)) {
                        self.loading.toggle()
                    }
                    sportsReport.updateReports()
                }
        }
        
    }
}


