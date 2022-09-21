
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

        ZStack {
            if let fixedArea = sportManager.getFixedArea() {
                let imageSize = sportManager.findFirstState()!.image!.imageSize
                let rect = fixedArea.areaToRect.rectToFit(imageSize: imageSize, viewSize: viewSize)
                Rectangle()
                    .stroke(.red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(rect.center)
                    .overlay(content: {
                        Text("\(fixedArea.id)")
                            .position(x: rect.center.x, y: rect.center.y - rect.height/2 - 10)
                            .foregroundColor(.red)
                    })
            }
            if let dynamicArea = sportManager.getDynamicArea() {
                let imageSize = sportManager.findFirstState()!.image!.imageSize
                let rect = dynamicArea.areaToRect.rectToFit(imageSize: imageSize, viewSize: viewSize)
                Rectangle()
                    .stroke(.red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(rect.center)
                    .overlay(content: {
                        Text("\(dynamicArea.id)")
                            .position(x: rect.center.x, y: rect.center.y - rect.height/2 - 10)
                            .foregroundColor(.red)
                    })

            }
        }
            
        
        
            
    }
}


struct RectViewForSporter: View {
    
    @EnvironmentObject var sportGround: SportsGround
    var viewSize:CGSize
    
    var body: some View {
        let fixedAreas = sportGround.fixedAreas()
        let dynamicAreas = sportGround.dynamicAreas()
        
        ZStack {
            Text("区域数目(静/动):\(fixedAreas.count)/\(dynamicAreas.count)\n当前答案:\(sportGround.getAnswer())")
            
            ForEach(fixedAreas, content: { fixedArea in

                let rect = fixedArea.areaToRect.rectToFit(imageSize: fixedArea.imageSize!.cgSize, viewSize: viewSize)
                Rectangle()
                    .stroke(fixedArea.selected == true ? .green : .red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(rect.center)
                    .overlay(content: {
                        Text("\(fixedArea.content ?? "")")
                            .position(x: rect.center.x, y: rect.center.y - rect.height/2 - 10)
                            .foregroundColor(.red)
                    })
                
            })
            
            ForEach(dynamicAreas, content: { dynamicArea in

                let rect = dynamicArea.areaToRect.rectToFit(imageSize: dynamicArea.imageSize!.cgSize, viewSize: viewSize)
                Rectangle()
                    .stroke(dynamicArea.selected == true ? .green : .red, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(rect.center)
                    .overlay(content: {
                        Text("\(dynamicArea.content ?? "")")
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

