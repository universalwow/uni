
import SwiftUI

struct ContentView: View {
    
    
    var body: some View {
        
        TabView {
            
            VStack {
                ChatView().padding()
            }
            .tabItem{
                Text("Chats")
            }
            
            VStack {
                SportsManagerView().padding()
            }
            .tabItem{
                Text("运动实验室")
            }
            
            VStack {
                SportsGroundView().padding()
            }
            .tabItem{
                Text("运动场")
            }
            
            VStack {
//                VideoView()
                VideoAnalysorView().padding()
//                VideoPlayerCoreImageView().padding()
            }
            .tabItem{
                Text("视频测试")
            }
            
            VStack {
//                VideoView()
                SportReportView()
//                WarningView(warning: "aaaaa",  offset: CGSize(width: 400, height: 0)).padding()
//                VideoPlayerCoreImageView().padding()
            }
            .tabItem{
                Text("运动报告")
            }
            
            
            
//
//            VStack {
//
//                LabelImageView().padding()
//            }
//            .tabItem{
//                Text("图片标注")
//            }
            

            VStack {

                StandAndJumpSetting().padding()
            }
            .tabItem{
                Text("立定跳远")
            }
            
            VStack {
                
                GenerateAreaView().padding()
            }
            .tabItem{
                Text("生成区域")
            }
            
            
            
            VStack {
                LoginView()
            }.tabItem{
                Text("登录")
            }
            
//            VStack {
//                WarningTest()
//            }.tabItem{
//                Text("Warnings")
//            }
        }
    }
}


