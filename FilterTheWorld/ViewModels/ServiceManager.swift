/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation



struct Login: Codable {
  var email:String
  var password:String
}

struct LoginResponse: Codable {
  var success: Bool
  var status: String
}

class ServiceManager: NSObject, ObservableObject {
  @Published var loginState: LoginResponse?
  
  
  func logout() {
    self.loginState = nil
  }
  
  func login(username: String, password: String) {
    print("login \(username)/\(password)")
    let url = URL(string: "https://192.168.0.103:4001/users/log_in")
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
    var config = URLSessionConfiguration.ephemeral
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
