import SwiftUI
import Charts


struct DataPoint: Hashable {
    let x: Double
    let y: Double
}

struct ChartView: View {
    @State var domain: ClosedRange<Double> = 0...100
    @State var dataPoints = (0..<100).map {
        DataPoint(
            x: Double($0),
            y: .random(in: 0...10)
        )
    }
    
    var dataPointsInDomain: Array<DataPoint> {
        dataPoints.filter { domain.contains($0.x) }
    }
    
    var body: some View {
        DomainGesture($domain) {
            Chart(dataPointsInDomain, id: \.self) {
                LineMark(
                    x: .value("X", $0.x),
                    y: .value("Y", $0.y)
                )
            }.chartXScale(domain: domain)
        }.padding()
    }
}


struct Workout: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
}
extension Workout {
    static let walkWorkout: [Workout] = [
        .init(day: "Mon", minutes: 35),
        .init(day: "Mon", minutes: 20),
        .init(day: "Tue", minutes: 35),
        .init(day: "Wed", minutes: 55),
        .init(day: "Thu", minutes: 30),
        .init(day: "Fri", minutes: 15),
        .init(day: "Sat", minutes: 65),
        .init(day: "Sun", minutes: 81),
    ]
}

//struct ChartView: View {
//    @State private var isDragging = false
//    @State private var selectedIndex: Int? = nil
//        @State private var numbers = (0...10).map { _ in
//            Int.random(in: 0...10)
//        }
//        
//        var body: some View {
//            Chart {
//                ForEach(Array(zip(numbers, numbers.indices)), id: \.1) { number, index in
//                    
//                    if let selectedIndex, selectedIndex == index {
//                                        RectangleMark(
//                                            x: .value("Index", index),
//                                            yStart: .value("Value", 0),
//                                            yEnd: .value("Value", number),
//                                            width: 16
//                                        )
//                                        .opacity(0.4)
//                                    }
//                    LineMark(
//                        x: .value("Index", index),
//                        y: .value("Value", number)
//                    )
//                    .foregroundStyle(isDragging ? .red : .blue)
//                }
//            }
//            .chartOverlay { chart in
//                        GeometryReader { geometry in
//                            Rectangle()
//                                .fill(Color.clear)
//                                .contentShape(Rectangle())
//                                .gesture(
//                                    DragGesture()
//                                        .onChanged { value in
//                                            let currentX = value.location.x - geometry[chart.plotAreaFrame].origin.x
//                                            guard currentX >= 0, currentX < chart.plotAreaSize.width else {
//                                                return
//                                            }
//                                            
//                                            guard let index = chart.value(atX: currentX, as: Int.self) else {
//                                                return
//                                            }
//                                            selectedIndex = index
//                                            isDragging = true
//                                        }
//                                        .onEnded { _ in
//                                            selectedIndex = nil
//                                            isDragging = false
//                                        }
//                                )
//                        }
//                    }
//    
//        }
//}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
