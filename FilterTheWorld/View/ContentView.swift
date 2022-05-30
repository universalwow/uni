
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
                VideoAnalysisView().padding()
//                VideoPlayerCoreImageView().padding()
            }
            .tabItem{
                Text("Video Player")
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


