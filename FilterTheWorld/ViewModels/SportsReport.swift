

import Foundation


class SportsReport: ObservableObject {
    @Published var reports :[SportReport] = SportsReport.allReports
    
    
}

extension SportsReport {
    static var allReports: [SportReport] {
//        MARK: 此处加载的项目 从服务端加载时去掉图片等大资源。提升存储和网络效率
        Storage.allFiles(.documents, secondaryDirectory: "sportsReport")
        .map{ url in
            return Storage.retrieve(url: url, as: SportReport.self)
        }.sorted(by: { (first, second) in
            first.startTime < second.endTime
        })
    }
    
    func updateReports() {
        reports = Storage.allFiles(.documents, secondaryDirectory: "sportsReport")
            .map{ url in
                Storage.retrieve(url: url, as: SportReport.self)
            }.sorted(by: { (first, second) in
                first.startTime < second.endTime
            })
    }
}
