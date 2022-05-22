

import SwiftUI
import PhotosUI

struct MediaPicker: UIViewControllerRepresentable {
    
    var mediaType:PHPickerFilter?
    @Binding var image: UIImage?
    @Binding var video: URL?
    
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = mediaType
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MediaPicker
        
        init(_ parent: MediaPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                }
            }
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                //                provider.loadItem(forTypeIdentifier: "public.movie", options: nil)

                provider.loadFileRepresentation(forTypeIdentifier: "public.movie"){ [weak self] (url, error) in
                    guard let url = url else {
                        return
                    }
                    
                    let fileName = "\(Int(Date().timeIntervalSince1970)).\(url.pathExtension)"
                    // create new URL
                    let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                    // copy item to APP Storage
                    try? FileManager.default.copyItem(at: url, to: newUrl)
                    self?.parent.video = newUrl
    
//                    let asset = AVURLAsset(url: url)
//                    print("asset \(url) \n \(asset.duration.seconds)")
//                    self?.parent.video = url
//                    print(FileManager.default.fileExists(atPath: url.path))
                }
            }
        }
    }
}

