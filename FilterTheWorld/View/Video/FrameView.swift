

import SwiftUI

struct FrameView: View {
    var cgImage: CGImage?
    var body: some View {
        if let cgImage = cgImage {
            Image(uiImage: UIImage(cgImage: cgImage))
                .resizable()
        }else{
            Image(systemName: "photo.fill")
                .resizable()
        }
    }
}

struct FrameView_Previews: PreviewProvider {
    static var previews: some View {
        FrameView()
    }
}
