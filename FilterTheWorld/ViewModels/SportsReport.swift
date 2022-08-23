

import Foundation


class SportsReport: ObservableObject {
    @Published var reports :[SportReport] = SportsReport.allReports
    
    
}

extension SportsReport {
    
    static var secondaryDirectory: String {
        "sportsReport"
    }
    
    static var allReports: [SportReport] {
//        MARK: 此处加载的项目 从服务端加载时去掉图片等大资源。提升存储和网络效率
        Storage.allFiles(.documents, secondaryDirectory: secondaryDirectory)
        .map{ url in
            return Storage.retrieve(url: url, as: SportReport.self)
        }.sorted(by: { (first, second) in
            first.createTime ?? 0.0 >= second.createTime ?? 0.0
        })
    }
    
    func updateReports() {
        reports = Storage.allFiles(.documents, secondaryDirectory: SportsReport.secondaryDirectory)
            .map{ url in
                Storage.retrieve(url: url, as: SportReport.self)
            }.sorted(by: { (first, second) in
                first.createTime ?? 0.0 >= second.createTime ?? 0.0
            })
    }
    func removeReports(reports: [SportReport]) {
        reports.forEach{ report in
            Storage.delete(to: .documents, secondaryDirectory: SportsReport.secondaryDirectory, as: report.fileName)
            
        }
    }
}
