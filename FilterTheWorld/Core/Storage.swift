import Foundation

public class Storage {
    
    fileprivate init() { }
    
    enum Directory {
        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents
        
        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        case caches
    }
    
    /// Returns URL constructed from specified directory
  static fileprivate func getURL(for directory: Directory, secondaryDirectory:String = "sports") -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory
        
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }
        
        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
          let secondaryDirectory = url.appendingPathComponent(secondaryDirectory, isDirectory: true)
          if !FileManager.default.fileExists(atPath: secondaryDirectory.path) {
            try? FileManager.default.createDirectory(at: secondaryDirectory, withIntermediateDirectories: true, attributes: nil)
            print("getURL \(secondaryDirectory.path)")
          }
            return secondaryDirectory
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }
    
    
    /// Store an encodable struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
  static func store<T: Encodable>(_ object: T, to directory: Directory = .documents, secondaryDirectory: String = "sports", as fileName: String) {
    let url = getURL(for: directory, secondaryDirectory:secondaryDirectory)
        .appendingPathComponent(fileName, isDirectory: false)
        
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            
          
            let result = FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
          print("store \(url.path) - \(result)")
          
        } catch {
            fatalError(error.localizedDescription)
        }
    }
  
  static func delete(to directory: Directory = .documents, secondaryDirectory: String = "sports", as fileName: String) {
    let url = getURL(for: directory, secondaryDirectory:secondaryDirectory)
        .appendingPathComponent(fileName, isDirectory: false)
                
        do {
          if FileManager.default.fileExists(atPath: url.path) {
              try FileManager.default.removeItem(at: url)
          }
          
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
  static func retrieve<T: Decodable>(_ fileName: String, from directory: Directory, secondaryDirectory: String = "sports", as type: T.Type) -> T {
    let url = getURL(for: directory, secondaryDirectory:secondaryDirectory)
      .appendingPathComponent(fileName, isDirectory: false)
        
    return retrieve(url: url, as: T.self)
    }
  
  
  static func retrieve<T: Decodable>(url: URL, as type: T.Type) -> T {
        if !FileManager.default.fileExists(atPath: url.path) {
            print("File at path \(url.path) does not exist!")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("No data at \(url.path)!")
        }
    }
    
    /// Remove all files at specified directory
    static func clear(_ directory: Directory,secondaryDirectory: String = "sports") {
      let url = getURL(for: directory, secondaryDirectory:secondaryDirectory)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
  
  
  static func allFiles(_ directory: Directory, secondaryDirectory: String = "sports") ->  [URL] {
    let url = getURL(for: directory,secondaryDirectory:secondaryDirectory)
      do {
          return try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
          
      } catch {
          fatalError(error.localizedDescription)
      }
  }
  
  
  
    
    /// Remove specified file from specified directory
    static func remove(_ fileName: String, from directory: Directory, secondaryDirectory: String = "sports") {
        let url = getURL(for: directory,secondaryDirectory: secondaryDirectory)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    /// Returns BOOL indicating whether file exists at specified directory with specified file name
    static func fileExists(_ fileName: String, in directory: Directory,secondaryDirectory: String = "sports") -> Bool {
      let url = getURL(for: directory,secondaryDirectory:secondaryDirectory).appendingPathComponent(fileName, isDirectory: false)
        print("fileExists \(url.path) - \(FileManager.default.fileExists(atPath: url.path))")
        return FileManager.default.fileExists(atPath: url.path)
    }
}
