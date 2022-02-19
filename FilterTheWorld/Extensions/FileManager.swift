import Foundation

extension FileManager {
  
    static func findUrls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true) -> [URL]? {
      let documentsURL = FileManager.default.urls(for: directory, in: .userDomainMask)[0]
      let fileURLs = try? FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
