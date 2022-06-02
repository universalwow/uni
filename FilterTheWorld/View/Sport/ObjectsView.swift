
import SwiftUI


struct ObjectView: View {
    var object:Observation
    var imageSize:CGSize
    var viewSize:CGSize

    var objectColor: Color {
        object.selected ? Color.yellow : object.color
    }
    
    var body: some View {
        let rect = object.rect.rectToFit(imageSize: imageSize, viewSize: viewSize)
        Rectangle()
            .stroke(objectColor, lineWidth: 2)
            .frame(width: rect.width, height: rect.height)
            .position(rect.center)
            .overlay(content: {
                Text("\(object.id)")
                    .position(x: rect.center.x, y: rect.center.y - rect.height/2 - 10)
                    .foregroundColor(objectColor)
            })
    }
}

struct RectView: View {
    
    @EnvironmentObject var sportManager:SportsManager
    
    var viewSize:CGSize
    var body: some View {
        if let state = sportManager.findFirstSportState(),
            let rule = sportManager.findCurrentSportStateRule(),
           let landmarkInArea = rule.landmarkInArea,
           !landmarkInArea.area.isEmpty {
            let imageSize = state.image!.imageSize
            let rect = landmarkInArea.areaToRect.rectToFit(imageSize: imageSize, viewSize: viewSize)
            
            Rectangle()
                .stroke(.pink, lineWidth: 2)
                .frame(width: rect.width, height: rect.height)
                .position(rect.center)
                .overlay(content: {
                    Text("\(landmarkInArea.landmarkType.rawValue)")
                        .position(x: rect.center.x, y: rect.center.y - rect.height/2 - 10)
                        .foregroundColor(.pink)
                })

        }
        
    }
}


struct ObjectsViewForSetupRule: View {
    @EnvironmentObject var sportManager: SportsManager
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    var objects:[Observation]
    var imageSize:CGSize
    var viewSize:CGSize
    var body: some View {
        ForEach(objects) { object in
            ObjectView(object: object, imageSize: imageSize, viewSize: viewSize)
                .onTapGesture {
//                    // 选择检测框
//                    imageAnalysis.selectObject(object: object)
//                    
//                    sportManager.updateSportState(image: imageAnalysis.sportData.frame, objects: imageAnalysis.selectedObjects())
                }
            
            
        }
        
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
                    // 选择检测框
                    imageAnalysis.selectObject(object: object)
                    
                    sportManager.updateSportState(image: imageAnalysis.sportData.frame, objects: imageAnalysis.selectedObjects())
                }
            
            
        }
        
    }
}

struct ObjectsViewForSportsGround: View {
    @EnvironmentObject var sportManager: SportsManager
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    var objects:[Observation]
    var imageSize:CGSize
    var viewSize:CGSize
    var body: some View {
        ForEach(objects) { object in
            ObjectView(object: object, imageSize: imageSize, viewSize: viewSize)
        }
        
    }
}

