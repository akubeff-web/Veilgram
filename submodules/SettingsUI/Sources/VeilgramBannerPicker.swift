import Foundation
import UIKit
import AVFoundation
import TelegramCore

/// Veilgram: picks the own profile header's photo or video from the photo library and stores it in
/// the app's Documents folder.
final class VeilgramBannerPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private static var current: VeilgramBannerPicker?

    private let kind: VeilgramSettings.ProfileBannerKind

    private init(kind: VeilgramSettings.ProfileBannerKind) {
        self.kind = kind
        super.init()
    }

    static func present(kind: VeilgramSettings.ProfileBannerKind, from view: UIView?) {
        guard var top = view?.window?.rootViewController else {
            return
        }
        while let presented = top.presentedViewController {
            top = presented
        }
        let picker = VeilgramBannerPicker(kind: kind)
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        if kind == .video {
            controller.mediaTypes = ["public.movie"]
            controller.allowsEditing = true
            controller.videoMaximumDuration = 30.0
            controller.videoExportPreset = AVAssetExportPresetPassthroughValue
        } else {
            controller.mediaTypes = ["public.image"]
        }
        controller.delegate = picker
        VeilgramBannerPicker.current = picker
        top.present(controller, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        defer {
            picker.dismiss(animated: true)
            VeilgramBannerPicker.current = nil
        }
        guard let destination = VeilgramSettings.profileBannerFileURL(kind: self.kind) else {
            return
        }
        switch self.kind {
        case .photo:
            guard let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.9) else {
                return
            }
            do {
                try data.write(to: destination, options: .atomic)
            } catch {
                return
            }
        case .video:
            guard let url = info[.mediaURL] as? URL else {
                return
            }
            do {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: url, to: destination)
            } catch {
                return
            }
        case .color:
            return
        }
        VeilgramSettings.setProfileBanner(kind: self.kind)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        VeilgramBannerPicker.current = nil
    }
}
