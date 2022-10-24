/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct LinesView: Shape {
   let lines:[[CGPoint]]
    let imageSize:CGSize
    let viewSize:CGSize
   func path(in rect: CGRect) -> Path {
       var path = Path()
       
       lines.forEach{ line in
           path.move(to: line[0].pointToFit(imageSize: imageSize, viewSize: viewSize))
           path.addLine(to: line[1].pointToFit(imageSize: imageSize, viewSize: viewSize))
       }
       
       return path
   }
}


struct MoveableCircle: View {
    @Binding var location: CGPoint
    let color: Color
    let imageSize:CGSize
    let viewSize:CGSize
    
    @GestureState private var startLocation: CGPoint? = nil // 1
    @GestureState private var fingerLocation: CGPoint? = nil

    var fingerDrag: some Gesture {
          DragGesture()
              .updating($fingerLocation) { (value, fingerLocation, transaction) in
                  fingerLocation = value.location
              }
      }
    
        var simpleDrag: some Gesture {
            DragGesture()
                .onChanged { value in
                    var newLocation = startLocation ?? location // 3
                    newLocation.x += value.translation.width
                    newLocation.y += value.translation.height
                    self.location = newLocation
                    print("location \(self.location)")
                }.updating($startLocation) { (value, startLocation, transaction) in
                    startLocation = startLocation ?? location // 2
                    print("location 1\(self.startLocation)")

                }
        }
    
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 20, height: 20)
                .position(location.pointToFit(imageSize: imageSize, viewSize: viewSize))
                .gesture(
                    simpleDrag.simultaneously(with: fingerDrag)
                )
            
            
            if let fingerLocation = fingerLocation {
                            Circle()
                                .stroke(Color.green, lineWidth: 2)
                                .frame(width: 44, height: 44)
                                .position(fingerLocation)
                        }
        }
    
    }
}


struct QuadrangleView: View {
    
    @Binding var leftTop: CGPoint
    @Binding var rightTop: CGPoint
    @Binding var rightBottom: CGPoint
    @Binding var leftBottom: CGPoint

     let imageSize:CGSize
     let viewSize:CGSize
    
    
    
    var body: some View {
        ZStack {
            MoveableCircle(location: $leftTop, color: .red, imageSize: imageSize, viewSize: viewSize)
            MoveableCircle(location: $rightTop, color: .yellow, imageSize: imageSize, viewSize: viewSize)
            MoveableCircle(location: $rightBottom, color: .green, imageSize: imageSize, viewSize: viewSize)
            MoveableCircle(location: $leftBottom, color: .blue, imageSize: imageSize, viewSize: viewSize)
            Quadrangle(points: [leftTop, rightTop, rightBottom, leftBottom], imageSize: imageSize, viewSize: viewSize)
                .stroke(lineWidth: 2)
        }
        
    }
    
}


struct Quadrangle: Shape {
   let points:[CGPoint]
    let imageSize:CGSize
    let viewSize:CGSize
   func path(in rect: CGRect) -> Path {
       var path = Path()
       path.move(to: points[0].pointToFit(imageSize: imageSize, viewSize: viewSize))
       points[1..<points.count].forEach{ point in
           path.addLine(to: point.pointToFit(imageSize: imageSize, viewSize: viewSize))
       }
       path.addLine(to: points[0].pointToFit(imageSize: imageSize, viewSize: viewSize))
       return path
   }
}


