
import SwiftUI


struct ObjectView: View {
    var object:Observation
    var imageSize:CGSize
    var viewSize:CGSize
    var body: some View {
        let rect = object.rect.rectToFit(imageSize: imageSize, viewSize: viewSize)
        Rectangle()
            .stroke(object.color, lineWidth: 2)
            .frame(width: rect.width, height: rect.height)
            .position(rect.center)
            .overlay(content: {
                Text("\(object.label)-\(object.confidence)")
                    .position(x: rect.center.x, y: rect.center.y - rect.height/2 - 20)
                    .foregroundColor(object.color)
            })
    }
}

struct ObjectsView: View {
    @EnvironmentObject var sportManager: SportsManager
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    var objects:[Observation]
    var imageSize:CGSize
    var viewSize:CGSize
    var body: some View {
        ForEach(objects) { object in
            ObjectView(object: object, imageSize: imageSize, viewSize: viewSize)
                .onTapGesture {
                    
//                    sportManager.updateSportState(image: , objects: <#T##[Observation]#>)
                }
           
            
        }
        
    }
}

