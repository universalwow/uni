

import SwiftUI

struct FrameView: View {
    var uiImage: UIImage
//    @Binding var orientation: Image.Orientation
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
    }
}

//struct FrameView_Previews: PreviewProvider {
//    static var previews: some View {
//        FrameView()
//    }
//}
