import Foundation
import ReplayKit
import UIKit

final class ScreenRecorderService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var lastError: String?

    private let recorder = RPScreenRecorder.shared()

    func setMicrophoneEnabled(_ enabled: Bool) {
        recorder.isMicrophoneEnabled = enabled
    }

    func start() {
        lastError = nil
        recorder.startRecording { [weak self] error in
            DispatchQueue.main.async {
                if let error {
                    self?.lastError = error.localizedDescription
                    self?.isRecording = false
                    return
                }
                self?.isRecording = true
            }
        }
    }

    func stopAndPreview(from presenter: UIViewController) {
        recorder.stopRecording { [weak self] previewVC, error in
            DispatchQueue.main.async {
                self?.isRecording = false
                if let error {
                    self?.lastError = error.localizedDescription
                    return
                }
                guard let previewVC else {
                    self?.lastError = "No preview available"
                    return
                }
                previewVC.previewControllerDelegate = self
                presenter.present(previewVC, animated: true)
            }
        }
    }
}

extension ScreenRecorderService: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true)
    }
}
