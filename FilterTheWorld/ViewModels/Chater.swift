/// Copyright (c) 2023 Razeware LLC
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
import SwiftPhoenixClient

struct OnlineUser: Codable, Identifiable {
    var bindingTo:String
    var id: String
    var count: Int
}

struct OnlineMessage: Codable {
    var users:[OnlineUser]
}

class Chater: ObservableObject {
    @Published var contents:[String] = []
    @Published var onlines: [OnlineUser] = []
    
    var socket = Socket("ws://\(ServiceManager.StaticValue.IP):4000/socket")
    
    var channel: Channel
    var token = ""
    
    func setToken(token: String) {
        print("token ---------> \(token)")
        self.token = token
        
        if !socket.isConnected {
            socket = Socket("ws://\(ServiceManager.StaticValue.IP):4000/socket", params: ["token" : token])
            
            socket.onOpen { print("Socket Opened") }
            socket.onClose { print("Socket Closed") }
            socket.onError { (error) in print("Socket Error", error)}
            
            socket.connect()
        }
        
        if !channel.isJoined {
            channel.leave()
            socket.remove(channel)
            
            
//            channel.
//            socket.remove(channel)
            channel = socket.channel("sport:jumpRope", params: ["token" : self.token, "bindingTo": ""])
            
            channel.on("shout") { [weak self] (message) in
                let payload = message.payload
                DispatchQueue.main.async {
                    self!.contents.append(payload["body"] as! String)
                    print("sent the message: \(payload)")
                }
            }
            
            channel.on("online") { [weak self] (message) in
                let payload = message.payload
                //        let content = payload["content"] as? String
                //        let username = payload["username"] as? String
                
                DispatchQueue.main.async {
    
                    //                    JSONSerialization.data(withJSONObject: <#T##Any#>)
                    
                    self?.onlines = try! JSONDecoder().decode([OnlineUser].self, from: (payload["body"]! as! String).data(using: .utf16)!)
//                    print("aaaaaaaa-> \(a)")
                }
            }
            
            channel.join()
                .receive("ok") { message in print("Channel Joined") }
                .receive("error") { message in print("Failed to join 1", message.payload, token, "---") }
        }
   
        

        
    }
    
    
    init() {
        
        channel = socket.channel("sport:jumpRope", params: ["token": "Room Token"])
    }
    
    func send(message:String) {
        print("------------->send")
        channel
            .push("shout", payload: ["body": message])
//            .receive("ok", handler: { (payload) in print("Message Sent") })
    }
    
    
}
