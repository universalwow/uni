
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
                LineDrawerView().padding()
            }
            .tabItem{
                Text("Draw Line")
            }
            
            VStack {
                LoginView()
            }.tabItem{
                Text("Login")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
