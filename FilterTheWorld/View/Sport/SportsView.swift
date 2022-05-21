

import SwiftUI

struct SportsView: View {
    @EnvironmentObject var sportManager: SportsManager

    var newSport: some View {
        ZStack {
            Color.gray
            Image(systemName: "plus.square.dashed")
                .resizable()
                .scaleEffect(0.5)
                .foregroundColor(.white)
            
        }.aspectRatio(2/3, contentMode: .fit)
        
    }
    
    
    var body: some View {
        NavigationView {
            ScrollView([.vertical]) {
                LazyVGrid(columns: [GridItem(),GridItem(),GridItem(),GridItem()]) {
                    ForEach(sportManager.sports) { sport in
                        NavigationLink(
                            destination:
                                        SportView(sport: sport)
                            .navigationTitle(Text(sport.name))
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing:
                                                    Button(action: {
                                                        sportManager.saveSport(editedSport: sport)
                                                    }) {
                                                        Text("保存")
                                                    }
                                               )
                            
                                       
                        ) {
                            CardView(card: Card(content: "\(sport.name)", backColor: .green))
                        }
                        
                    }
                    newSport.onTapGesture {
                        let newSport = SportsManager.newSport
                        sportManager.addSport(sport: newSport)
                        
                    }
                }
            }    .navigationBarTitle("")
                .navigationBarHidden(true)
        }
        
        
        .navigationViewStyle(.stack)
        
        
    }
}

struct SportsView_Previews: PreviewProvider {
    static var previews: some View {
        SportsView()
    }
}
