import AVFoundation
import SwiftUI
import LULLKit

/// The eye, made real. Wraps an `AVCaptureSession` on the front camera and
/// nothing else — no recording, no upload, no frames leave the device. It only
/// ever runs after the player has consented and the OS has said yes, and it
/// stops the instant it is asked to.
@MainActor
final class CameraController: NSObject, ObservableObject, CameraGate {
    let session = AVCaptureSession()
    @Published private(set) var isWatching = false

    private var configured = false

    func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
        default: return false
        }
    }

    func start() async {
        guard !isWatching else { return }
        configureIfNeeded()
        let session = self.session
        await Task.detached { session.startRunning() }.value
        isWatching = true
    }

    func stop() async {
        let session = self.session
        await Task.detached { if session.isRunning { session.stopRunning() } }.value
        isWatching = false
    }

    private func configureIfNeeded() {
        guard !configured else { return }
        session.beginConfiguration()
        session.sessionPreset = .high
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        }
        session.commitConfiguration()
        configured = true
    }
}

/// A live preview of what the eye sees. Deliberately never shown at full
/// clarity — the game dims and degrades it; here it is just the raw layer.
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
