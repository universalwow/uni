
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
        let landmarkInAreas = sportManager.getRuleLandmarkInAreasForShowArea()
        let landmarkInAreasForAreaRule = sportManager.getRuleLandmarkInAreasForShowAreaForAreaRule()

        ZStack {
            ForEach(landmarkInAreas, content: { landmarkInArea in
                let rect = landmarkInArea.areaToRect.rectToFit(imageSize: landmarkInArea.imageSize.cgSize, viewSize: viewSize)
                Rectangle()
                    .stroke(landmarkInArea.satisfy ? .gray : .red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(rect.center)
                    .overlay(content: {
                        Text("\(landmarkInArea.landmark.id)")
                            .position(x: rect.center.x, y: rect.center.y - rect.height/2 - 10)
                            .foregroundColor(landmarkInArea.satisfy ? .gray : .red)
                    })
                
            })
            
            ForEach(landmarkInAreasForAreaRule, content: { landmarkInArea in
                let rect = landmarkInArea.areaToRect.rectToFit(imageSize: landmarkInArea.imageSize.cgSize, viewSize: viewSize)
                Rectangle()
                    .stroke(landmarkInArea.satisfy ? .gray : .red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(rect.center)
                    .overlay(content: {
                        Text("\(landmarkInArea.landmark.id)")
                            .position(x: rect.center.x, y: rect.center.y - rect.height/2 - 10)
                            .foregroundColor(landmarkInArea.satisfy ? .gray : .red)
                    })
                
            })
        }
    }
}


struct RectViewForSporter: View {
    
    @EnvironmentObject var sportGround: SportsGround
    var viewSize:CGSize
    
    var body: some View {
        let landmarkInAreas = sportGround.areas()
        let dynamicLandmarkInAreas = sportGround.dynamicAreas()
        ZStack {
            Text("区域数目\(landmarkInAreas.count)/\(dynamicLandmarkInAreas.count)")
            ForEach(landmarkInAreas.indices, id: \.self,content: { landmarkInAreaIndex in
                let landmarkInArea = landmarkInAreas[landmarkInAreaIndex]
                let rect = landmarkInArea.areaToRect.rectToFit(imageSize: landmarkInArea.imageSize.cgSize, viewSize: viewSize)
                Rectangle()
                    .stroke(.red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(rect.center)
                    .overlay(content: {
                        Text("\(landmarkInArea.landmark.id)")
                            .position(x: rect.center.x, y: rect.center.y - rect.height/2 - 10)
                            .foregroundColor(.red)
                    })
                
            })
            
            ForEach(dynamicLandmarkInAreas, content: { landmarkInArea in
                let rect = landmarkInArea.areaToRect.rectToFit(imageSize: landmarkInArea.imageSize.cgSize, viewSize: viewSize)
                Rectangle()
                    .stroke(.red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(rect.center)
                    .overlay(content: {
                        Text("\(landmarkInArea.landmark.id) - \(landmarkInArea.dynamicAreaId)")
                            .position(x: rect.center.x, y: rect.center.y - rect.height/2 - 10)
                            .foregroundColor(.red)
                    })
                
            })
        }
    }
}


struct ObjectsViewForSetupRule: View {
    @EnvironmentObject var sportManager: SportsManager
    @EnvironmentObject var imageAnalysis:ImageAnalysis
    var imageSize:CGSize
    var viewSize:CGSize
    var body: some View {
        let objects = sportManager.findSelectedObjects()
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
//    @EnvironmentObject var sportManager: SportsManager
//    @EnvironmentObject var imageAnalysis:ImageAnalysis
//    @EnvironmentObject var sportGround: SportsGround
    var objects:[Observation]
    var imageSize:CGSize
    var viewSize:CGSize
    var body: some View {
        ZStack {
            ForEach(objects) { object in
                ObjectView(object: object, imageSize: imageSize, viewSize: viewSize)
            }
        }
 
        
        
    }
}

