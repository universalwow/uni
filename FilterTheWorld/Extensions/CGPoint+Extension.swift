import SwiftUI
import simd


extension CGPoint {
  func pointToFit(imageSize: CGSize,
                   viewSize: CGSize) -> CGPoint {
    let imageRatio = 1.0/imageSize.ratio()
    let viewRatio = 1.0/viewSize.ratio()
    
    return imageRatio >= viewRatio ? CGPoint(
      x:
        viewSize.width/2 + (self.x - imageSize.width/2)/imageSize.height * viewSize.height,
      y: self.y/imageSize.height * viewSize.height
    ) : CGPoint(
      x:
        self.x/imageSize.width * viewSize.width
        ,
    y: viewSize.height/2 + (self.y - imageSize.height/2)/imageSize.width * viewSize.width

     )

  }
  
  
  func viewPointToImagePoint(imageOffset: CGSize, imageSize: CGSize,
                             viewSize: CGSize, scale: CGFloat) -> CGPoint {
    
//    image_x_to_view = (image_x - image_width/2)*scale + view_width/2 + image_offset_x
//    image_y_to_view = (image_y - image_height/2)*scale + view_height/2 + image_offset_y
    
    let imageX = (self.x - imageOffset.width - viewSize.width/2)/scale + imageSize.width/2
    let imageY = (self.y - imageOffset.height - viewSize.height/2)/scale + imageSize.height/2
    
    return CGPoint(x: imageX, y: imageY)
  }
  
  
  func imagePointToViewPoint(imageOffset: CGSize, imageSize: CGSize,
                             viewSize: CGSize, scale: CGFloat) -> CGPoint {
    let viewX = (self.x - imageSize.width/2) * scale + viewSize.width/2 + imageOffset.width
    let viewY = (self.y - imageSize.height/2) * scale + viewSize.height/2 + imageOffset.height
    
    return CGPoint(x: viewX, y: viewY)
  }
  
  
  func viewPointToOffset(viewSize: CGSize, scale: CGFloat, parentPanOffset: CGSize) -> CGSize {
    
    CGSize(width: (self.x - viewSize.width/2 - parentPanOffset.width)/scale, height: (self.y - viewSize.height/2 - parentPanOffset.height)/scale)
  }
  
  
  
  
  func proportionToRealPosition(imageSize:CGSize) -> CGPoint{
    CGPoint(x: self.x*imageSize.width, y: (1 - self.y)*imageSize.height)
  }
  
  func perspectiveTransform(matrix: float3x3) -> CGPoint {
    var  scaledVector = matrix * simd_float3(x: self.x.float, y: self.y.float, z: 1)
    scaledVector = scaledVector/scaledVector.z
    print("scaledVector \( scaledVector)")
    return CGPoint(x: Double(scaledVector.x), y: Double(scaledVector.y))
  }
  
  
  var roundedString: String {
    "\(self.x.roundedString)/\(self.y.roundedString)"
  }
  
}
