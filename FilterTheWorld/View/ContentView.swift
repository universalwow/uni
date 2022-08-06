
import SwiftUI

struct ContentView: View {
    
    
    var body: some View {
        TabView {
            VStack {
                SportsManagerView().padding()
            }
            .tabItem{
                Text("Sports Manager")
            }
            
            VStack {
                SportsGroundView().padding()
            }
            .tabItem{
                Text("Sports Ground")
            }
            
            VStack {
//                VideoView()
                VideoAnalysorView().padding()
//                VideoPlayerCoreImageView().padding()
            }
            .tabItem{
                Text("Video Test")
            }
            
            VStack {
//                VideoView()
                SportReportView()
//                WarningView(warning: "aaaaa",  offset: CGSize(width: 400, height: 0)).padding()
//                VideoPlayerCoreImageView().padding()
            }
            .tabItem{
                Text("Reports")
            }
            
            
            
            
            VStack {
                
                LabelImageView().padding()
            }
            .tabItem{
                Text("Label Me")
            }
            
            
            
            VStack {
                LoginView()
            }.tabItem{
                Text("Login")
            }
            
            VStack {
                WarningTest()
            }.tabItem{
                Text("Warnings")
            }
        }
    }
}


