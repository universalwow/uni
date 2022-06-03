
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
                Text("Sports")
            }
            
            VStack {
//                VideoView()
                VideoAnalysorView().padding()
//                VideoPlayerCoreImageView().padding()
            }
            .tabItem{
                Text("Video Player")
            }
            
            VStack {
//                VideoView()
                WarningsView()
//                WarningView(warning: "aaaaa",  offset: CGSize(width: 400, height: 0)).padding()
//                VideoPlayerCoreImageView().padding()
            }
            .tabItem{
                Text("warning")
            }
            
            
            
            
//            VStack {
//                LineDrawerView().padding()
//            }
//            .tabItem{
//                Text("Draw Line")
//            }
            
            
            
            VStack {
                LoginView()
            }.tabItem{
                Text("Login")
            }
        }
    }
}


