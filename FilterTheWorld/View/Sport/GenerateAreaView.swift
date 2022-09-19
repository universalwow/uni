
import SwiftUI

struct GenerateAreaView: View {
    @State var width: Double = 0.1
    @State var heightToWidthRatio = 1.0
    @State var centerX: Double = 0
    @State var centerY: Double = 0

    
    @State var leftTopX = 0.0
    @State var leftTopY = 0.0
    @State var rightBottomX = 0.0
    @State var rightBottomY = 0.0
    

    
    func generatorCenter(imageSize: CGSize) {
        centerX = Double.random(in: leftTopX*imageSize.width...rightBottomX*imageSize.width)
        centerY = Double.random(in: leftTopY*imageSize.height...rightBottomY*imageSize.height)
    }
    
    func topX(imageSize: CGSize) -> Double {
        centerX - width * imageSize.width/2.0
    }
    
    func topY(imageSize: CGSize) -> Double {
        centerY - (width * imageSize.width) * heightToWidthRatio/2.0
    }
    
    func width(imageSize: CGSize) -> Double {
        width * imageSize.width
    }
    
    func height(imageSize: CGSize) -> Double {
        width(imageSize: imageSize)*heightToWidthRatio
    }
    
    var body: some View {
        GeometryReader { proxy in
            
            ZStack {
                ObjectView(object: Observation(id: "test", label: "test", confidence: "0.5", rect: CGRect(x: topX(imageSize: proxy.size), y: topY(imageSize: proxy.size), width: width(imageSize: proxy.size), height: height(imageSize: proxy.size))), imageSize: proxy.size, viewSize: proxy.size)
                
                VStack {
                    Spacer()
                    HStack {
                        
                        Text("中心点区域:")
                        VStack {
                            HStack {
                                TextField("leftTopX", value: $leftTopX, formatter: formatter) { flag in
                                    if !flag {
    //                                    updateRemoteData()
                                    }
                                }
    //                            .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                TextField("leftTopY", value: $leftTopY, formatter: formatter) {flag in
                                    if !flag {
    //                                    updateRemoteData()
                                    }
                                    
                                }
    //                            .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            }
                            HStack {
                                TextField("rightBottomX", value: $rightBottomX, formatter: formatter) {flag in
                                    if !flag {
    //                                    updateRemoteData()
                                    }
                                    
                                }
    //                            .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                
                                TextField("rightBottomY", value: $rightBottomY, formatter: formatter){flag in
                                    if !flag {
    //                                    updateRemoteData()
                                    }
                                    
                                }
                                
    //                            .foregroundColor(landmarkInAreaTextColor)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            }
                        }
                        
                        Button("生成中心点", action: {
                            generatorCenter(imageSize: proxy.size)
                        })
                    }
                    
                    HStack {
                        
                        TextField("区域宽度", value: $width, formatter: formatter,onEditingChanged: { flag in
                            if !flag {
    //                            updateRemoteData()
                            }

                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        
                        TextField("高宽比", value: $heightToWidthRatio, formatter: formatter,onEditingChanged: { flag in
                            if !flag {
    //                            updateRemoteData()
                            }

                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        
                        
                        
                        Button(action: {
                            
                            
                        }, label: {
                            Text("生成区域")
                        })
                    }
                    
                }
                
            }
            .background(content: {
                Color.green
            })
        }
    }
}


