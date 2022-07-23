

import SwiftUI

struct SportsManagerView: View {
    @EnvironmentObject var sportManager: SportsManager
    @ObservedObject var serviceManager = ServiceManager()


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
                                SportView(sport: Binding.constant(sport))
                            .navigationTitle(Text(sport.name))
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarItems(trailing:
                                                    HStack {
                                                        Button(action: {
                                                            sportManager.saveSport(editedSport: sport)
                                                        }) {
                                                            Text("本地保存")
                                                        }
                                                        
                                                        Button(action: {
                                                            serviceManager.uploadData(sport: sport)

                                                        }) {
                                                            Text("上传文件")
                                                        }
                                                        
                                                        Button(action: {
                                                            sportManager.deleteSport(editedSport: sport)
                                                        }) {
                                                            Text("删除")
                                                        }
                                                    }
                                                    
                                               )
                            
                                       
                        ) {
                            CardView(card: Card(content: sport.name, sportClass: sport.sportClass ?? .None, backColor: .green))
                        }
                        
                    }
                    newSport.onTapGesture {
                        let newSport = SportsManager.newSport
                        sportManager.addSport(sport: newSport)
                        
                    }
                }
            }
            .navigationBarTitle(Text("项目管理"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        sportManager.saveSports()
                    }) {
                        Text("本地保存")
                    }
                    Button(action: {
                        
                        serviceManager.downloadDocuments(path: "https://\(ServiceManager.StaticValue.IP ):4001/rules/-1")
                        
                    }) {
                        Text("更新本地")
                    }
                    
                }
            )
            
//                .navigationBarHidden(true)
        }
        
        .onReceive(serviceManager.$sportPaths, perform: { fileNames in
            fileNames.forEach( { fileName in
                serviceManager.downloadDocument(path: "https://\(ServiceManager.StaticValue.IP ):4001/sports/\(fileName)")
            })
            
        })
        .onReceive(serviceManager.$sport, perform: { _sport in
            if let sport = _sport {
                sportManager.addSport(sport: sport)
            }
        })
        .navigationViewStyle(.stack)
        
//        .navigationBarTitle("项目管理")
        
        
    }
}

struct SportsView_Previews: PreviewProvider {
    static var previews: some View {
        SportsManagerView()
    }
}
