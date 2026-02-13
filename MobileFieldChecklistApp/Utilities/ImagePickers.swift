import SwiftUI
import UIKit
import PhotosUI

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onPicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(dismiss: dismiss, onPicked: onPicked) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let dismiss: DismissAction
        let onPicked: (UIImage) -> Void

        init(dismiss: DismissAction, onPicked: @escaping (UIImage) -> Void) {
            self.dismiss = dismiss
            self.onPicked = onPicked
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                onPicked(img)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

@MainActor
final class PhotoPickerModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem?

    func loadImage() async -> UIImage? {
        guard let item = selectedItem else { return nil }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                return img
            }
        } catch {}
        return nil
    }
}
