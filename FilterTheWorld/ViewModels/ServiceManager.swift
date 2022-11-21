import Foundation
import Alamofire

struct Login: Codable {
  var email:String
  var password:String
}

struct LoginResponse: Codable {
  var success: Bool
  var status: String
}


struct SportFile: Codable {
    var success: Bool
    var data: [String]
}

class ServiceManager: NSObject, ObservableObject {
    
    struct StaticValue {
        static let IP = "192.168.1.173"
    }
  @Published var loginState: LoginResponse?
  
  @Published var sport: Sport?
  @Published var sportPaths : [String] = []
  
  func logout() {
    self.loginState = nil
  }
    
  
  
  func login(username: String, password: String) {
    print("login \(username)/\(password)")
    let url = URL(string: "https://\(StaticValue.IP):4001/users/log_in")
    guard let requestUrl = url else {
//            fatalError()
      print("url error")
      return
      
    }
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    // Set HTTP Request Header
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    request.setValue("strict-origin-when-cross-origin", forHTTPHeaderField: "Referrer Policy")
    let login = Login(email: username, password: password)
    let jsonData = try! JSONEncoder().encode(login)
    request.httpBody = jsonData
      let config = URLSessionConfiguration.ephemeral
    config.allowsConstrainedNetworkAccess = true
    let task = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main).dataTask(with: request) { (data, response, error) in
        
        if let error = error {
            print("Error took place \(error)")
            return
        }
      
        guard let data = data else {return}
      let response = try! JSONDecoder().decode(LoginResponse.self, from: data)
      self.loginState = response
      print("result \(response)")
          
//            do{
//                let todoItemModel = try JSONDecoder().decode(ToDoResponseModel.self, from: data)
//                print("Response data:\n \(todoItemModel)")
//                print("todoItemModel Title: \(todoItemModel.title)")
//                print("todoItemModel id: \(todoItemModel.id ?? 0)")
//            }catch let jsonErr{
//                print(jsonErr)
//           }
     
    }
    task.resume()
  }
}

extension ServiceManager:URLSessionDelegate {
  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    print("-----------------------")
          completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
      }
}


extension ServiceManager {
    
    
    func uploadData(sport: Sport) {
      let url = URL(string: "https://\(StaticValue.IP):4001/rules")
      guard let requestUrl = url else {
  //            fatalError()
        print("url error")
        return
        
      }
        
    let appVersion:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
      var request = URLRequest(url: requestUrl)
      request.httpMethod = "POST"
      // Set HTTP Request Header
      request.setValue("application/json", forHTTPHeaderField: "Accept")
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.setValue(appVersion, forHTTPHeaderField: "app-version")

      request.setValue("strict-origin-when-cross-origin", forHTTPHeaderField: "Referrer Policy")
      let jsonData = try! JSONEncoder().encode(
        sport
      )
      request.httpBody = jsonData
        let config = URLSessionConfiguration.ephemeral
      config.allowsConstrainedNetworkAccess = true
      let task = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main).dataTask(with: request) { (data, response, error) in
          
          if let error = error {
              print("Error took place \(error)")
              return
          }
        
          guard let data = data else {return}
//        let response = try! JSONDecoder().decode(LoginResponse.self, from: data)
        print("result \(data)")
      }
      task.resume()
    }
  
    
    static func uploadDocument<T: Encodable>(_ object: T, filename : String, handler : @escaping (String) -> Void) {
           let headers: HTTPHeaders = [
//               "Content-type": "multipart/form-data",
               "Accept": "application/json",
               "Content-Type":"application/json",
               "Referrer Policy":"strict-origin-when-cross-origin"
               
           ]
        

        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            
            let serverTrustManager = ServerTrustManager(allHostsMustBeEvaluated: true,

                                                        evaluators: [:])
            let manage  = Session(serverTrustManager: serverTrustManager)


            
            manage
                .upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(data, withName: "upload_data" , fileName: filename, mimeType: "application/json")
            },
                to: "https://\(StaticValue.IP):4001/rules", method: .post , headers: headers)
                .response { response in
                    if let responseData = response.data {
                        //handle the response however you like
                        print("aaaaaa")
                    }
                    
                    print("error \(response.result)")


                }
          
        } catch {
            fatalError(error.localizedDescription)
        }
           
    }
    
    func downloadDocuments(path: String) {
        let url1 = URL(string: path)!
        
        URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main).dataTask(with: url1) { [self] data, response, error in
              if let data = data {
                  
                  do {
                      let res = try JSONDecoder().decode(SportFile.self, from: data)
                      let appVersion:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                      sportPaths = res.data.filter( { sportName in
                          sportName.contains(appVersion)
                      })
                  } catch let error {
                     print(error)
                  }
               }
           }.resume()
    }
    
    func downloadDocument(path: String) {
        let url1 = URL(string: path)!
        
        URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main).dataTask(with: url1) { [self] data, response, error in
              if let data = data {
                  do {
                      let res = try JSONDecoder().decode(Sport.self, from: data)
                      sport = res
                      
                     print(res.name)
                  } catch let error {
                     print(error)
                  }
               }
           }.resume()
    }
}

extension URLSession {
    func decode<T: Decodable>(
        _ type: T.Type = T.self,
        from url: URL,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) async throws  -> T {
        let (data, _) = try await data(from: url)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy

        let decoded = try decoder.decode(T.self, from: data)
        return decoded
    }
}


//public final class CertificatePinnerTrustEvaluator: ServerTrustEvaluating {
//
//    public init() {}
//
//    func setupCertificatePinner(host: String) -> CertificatePinnerTrustEvaluator {
//
//        //get the CertificatePinner
//    }
//
//    public func evaluate(_ trust: SecTrust, forHost host: String) throws {
//
//        let pinner = setupCertificatePinner(host: host)
//
//        if (!pinner.validateCertificateTrustChain(trust)) {
//            print("failed: invalid certificate chain!")
//            throw AFError.serverTrustEvaluationFailed(reason: .noCertificatesFound)
//        }
//
//        if (!pinner.validateTrustPublicKeys(trust)) {
//            print ("couldn't validate trust for \(host)")
//
//            throw AFError.serverTrustEvaluationFailed(reason: .noCertificatesFound)
//        }
//    }
//}
//
//class CertificatePinnerServerTrustManager: ServerTrustManager {
//
//    let evaluator = CertificatePinnerTrustEvaluator()
//
//    init() {
//        super.init(allHostsMustBeEvaluated: true, evaluators: [:])
//    }
//
//    open override func serverTrustEvaluator(forHost host: String) throws -> ServerTrustEvaluating? {
//
//        return evaluator
//    }
//}
//
//
//
