

import SwiftUI
import Charts

struct ReportDetail: View {
    @Binding var report: SportReport
    @State private var isDragging = false
    @State private var selectedIndex: Double? = nil
    
    @State private var domain:ClosedRange<Double> = 0...70
    
    @State private var stateIdToDescription:[Int:StateDescription] = [:]
    
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
                            Text("总计分次数:\(report.scoreTimes.count)/\(report.interactionScoreTimes?.count ?? 0)")
                        }
                        
                        if let stateDescriptions = report.statesDescription {
                            ForEach(stateDescriptions) { stateDescription in
                                let stateScores = report.findStateScoreTimes(stateId: stateDescription.stateId)
                                let stateInteractionScores = report.findStateInteractionScoreTimes(stateId: stateDescription.stateId)

                                HStack {
                                    Text("状态:\(stateDescription.stateName)")
                                    Text("计分次数:\(stateScores.count)/\(stateInteractionScores.count)")
                                    if let checkCycle = stateDescription.checkCycle {
                                        Text("计分时长:\(Double(stateScores.count) * checkCycle)/\(Double(stateInteractionScores.count) * checkCycle)")
                                    }
                                }
                            }
                        }
                        
                        
                        if let allStateTime = report.allStateTimes {
                            
                            VStack {
                                DomainGesture($domain) {
                                    Chart {
                                        ForEach(allStateTime) { scoreTime in

                                            
                                            let stateDescription = stateIdToDescription[scoreTime.stateId] ?? report.findStateDescription(stateId: scoreTime.stateId)
                                            
                                            LineMark(x: .value("Time", scoreTime.time), y: .value("State", scoreTime.stateId))
                                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
//                                                .foregroundStyle(isDragging ? .red : .blue)
                                            
                                            PointMark(
                                                x: .value("Time", scoreTime.time), y: .value("State", scoreTime.stateId)
                                            ).foregroundStyle(by: .value("StateName", stateDescription.stateName))
                                            
                                            if report.scoreTimes.contains { _scoreTime in
                                                _scoreTime.time == scoreTime.time && _scoreTime.stateId == scoreTime.stateId
                                            } {
                                                
                                                
                                                PointMark(
                                                    x: .value("Time", scoreTime.time), y: .value("State", scoreTime.stateId)
                                                )
//                                                .symbolSize(10)
//
                                                    .symbol {
                                                        Image(systemName: "s.circle")
                                                            .resizable()
                                                            .frame(width: 16, height: 16)
                                                            .foregroundColor(.black)
                                                                        
                                                    }
                                                    
//                                                    .foregroundStyle(by: .value("StateName", "Score"))
                                                
                                            }
                                            
                                            
                                            
                                            
                                        }
                                    }.chartXScale(domain: domain)
                                }
                                
//                                Chart {
//                                    ForEach(allStateTime) { scoreTime in
//                                        LineMark(x: .value("Time", scoreTime.time), y: .value("State", scoreTime.stateId))
//                                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
//                                            .foregroundStyle(isDragging ? .red : .blue)
//
//                                        if let selectedIndex, abs(selectedIndex - scoreTime.time) < 0.1  {
//                                                            RectangleMark(
//                                                                x: .value("Time", scoreTime.time),
//                                                                yStart: .value("State", 0),
//                                                                yEnd: .value("State", scoreTime.stateId),
//                                                                width: 4
//                                                            )
//                                                            .opacity(0.4)
//                                                        }
//
//                                        PointMark(
//                                            x: .value("Time", scoreTime.time), y: .value("State", scoreTime.stateId)
//                                                        )
//                                    }
//                                }
//                                .chartOverlay { chart in
//                                    GeometryReader { geometry in
//                                        Rectangle()
//                                            .fill(Color.yellow.opacity(0.3))
//                                            .contentShape(Rectangle())
//                                            .gesture(
//                                                DragGesture()
//                                                    .onChanged { value in
//                                                        let currentX = value.location.x - geometry[chart.plotAreaFrame].origin.x
//                                                        guard currentX >= 0, currentX < chart.plotAreaSize.width else {
//                                                            return
//                                                        }
//
//
//                                                        guard let index = chart.value(atX: currentX, as: Double.self) else {
//                                                            return
//                                                        }
//                                                        print("selectedIndex -------- \(index)- \(index)")
//                                                        selectedIndex = index
//                                                        isDragging = true
//                                                    }
//                                                    .onEnded { _ in
//                                                        selectedIndex = nil
//                                                        isDragging = false
//                                                    }
//                                            )
//                                    }
//                                }
                            }
                            
     
//                            Section("时间轴") {
//                                VStack(alignment: .leading) {
//                                    HStack {
//                                        HStack {
//                                            Text("时间")
//                                            Spacer()
//                                        }
//
//                                        .frame(width: UIScreen.screenWidth/3)
//                                        HStack {
//                                            Text("相对时间")
//                                            Spacer()
//                                        }
//                                        .frame(width: UIScreen.screenWidth/3)
//
//                                        HStack {
//                                            Text("状态")
//                                            Spacer()
//                                        }
//                                        .frame(width: UIScreen.screenWidth/3)
//                                    }
//
//
//                                    ForEach(allStateTime) { scoreTime in
//
//                                        let stateDescription = stateIdToDescription[scoreTime.stateId] ?? report.findStateDescription(stateId: scoreTime.stateId)
//
//                                        HStack {
//                                            HStack {
//                                                Text(SportReport.timeFormater(time: scoreTime.time))
//                                                Spacer()
//                                            }
//                                            .frame(width: UIScreen.screenWidth/3)
//                                            HStack {
//                                                Text(SportReport.secondFormater(time: scoreTime.time - report.startTime))
//                                                Spacer()
//                                            }
//                                            .frame(width: UIScreen.screenWidth/3)
//
//                                            HStack {
//                                                Text(stateDescription.stateName)
//                                                Spacer()
//                                            }
//                                            .frame(width: UIScreen.screenWidth/3)
//                                        }
//                                    }
//                                }
//
//                            }
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
//
                        
                        
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
                                                Text(warningData.warning.content)
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
        }.onAppear {
            if let allStateTimes = report.allStateTimes, allStateTimes.count > 1 {
                domain = allStateTimes.first!.time...allStateTimes.last!.time
                
                allStateTimes.forEach { stateTime in
                    if !stateIdToDescription.keys.contains(stateTime.stateId) {
                        stateIdToDescription[stateTime.stateId] = report.findStateDescription(stateId: stateTime.stateId)
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
                                    Text("创建时间:\(SportReport.timeFormater(time: report.createTime ?? 0.0))")
                                    Spacer()
                                }
                                
                            }
                        }
                        
                    })
                    .onDelete(perform: { indexSet in
                        let removedReport = indexSet.map( { index in
                            sportsReport.reports[index]
                        })
                        sportsReport.removeReports(reports: removedReport)
                        sportsReport.reports.remove(atOffsets: indexSet)
                        
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


