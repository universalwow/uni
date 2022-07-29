

import SwiftUI

struct SportsGroundView: View {
    @EnvironmentObject var sportGround: SportsGround
    @State private var loading = false
    
    var body: some View {
        
        NavigationView {
            ZStack(alignment: .topTrailing) {
                ScrollView([.vertical]) {
                    LazyVGrid(columns: [GridItem(),GridItem(),GridItem(),GridItem()]) {
                        ForEach(sportGround.sports) { sport in
                            NavigationLink(
                                destination:
                                    CameraPlayingView(sport: sport)
                                    .navigationTitle(Text("\(sport.name)-\(sport.sportClass!.rawValue)-\(sport.sportPeriod!.rawValue)"))
                                    .navigationBarTitleDisplayMode(.inline)
                                
                                
                                
                            ) {
                                CardView(card: Card(
                                    content: sport.name,
                                    sportClass: sport.sportClass ?? .None,
                                    sportPeriod: sport.sportPeriod ?? .None,
                                    backColor: .green))
                            }
                            
                        }
                    }
                }    .navigationBarTitle("")
                    .navigationBarHidden(true)
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding()
                    .foregroundColor(.yellow)
                    .rotationEffect(self.loading ?  Angle(degrees: 0) : Angle(degrees: 360))
                    .onTapGesture {
                        withAnimation(Animation.linear(duration: 1)) {
                            self.loading.toggle()
                        }
                        sportGround.updateSports()
                    }
            }
            
            
        }.navigationViewStyle(.stack)
        
        
        
    }
}


