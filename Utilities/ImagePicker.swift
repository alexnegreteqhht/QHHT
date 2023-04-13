//
//  Previews.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/12/23.
//

import Foundation
import SwiftUI
import Photos

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var imageData: Data?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, imageData: $imageData)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator

        // Check and request photo library permission
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    picker.sourceType = .photoLibrary
                }
            }
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            picker.sourceType = .photoLibrary
        }

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        @Binding var imageData: Data?

        init(_ parent: ImagePicker, imageData: Binding<Data?>) {
            self.parent = parent
            _imageData = imageData
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = uiImage
                if let data = uiImage.jpegData(compressionQuality: 1.0) {
                    imageData = data
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
