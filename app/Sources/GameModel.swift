import SwiftUI
import Combine
import LULLKit

/// Coordinates the pure `EyeSession` state machine with the real camera and a
/// real clock. All the game's *decisions* live in LULLKit (and are tested);
/// this object just wires them to time and hardware, and to the consent ledger
/// that gates it all.
@MainActor
final class GameModel: ObservableObject {
    @Published private(set) var eye = EyeSession()
    @Published private(set) var consent = ConsentLedger()

    let camera = CameraController()
    private var clock: AnyCancellable?

    /// Enter the flow: it asks, in-app, before anything watches.
    func begin() { eye.begin() }

    /// The player agreed in-app. Record consent, then ask the OS; a refusal at
    /// either level is a real "no", and the eye never opens.
    func allowTheEye() async {
        consent.grant(.camera)
        guard await camera.requestAccess() else {
            consent.revoke(.camera)
            eye.consent(false)
            return
        }
        eye.consent(true)
        await camera.start()
        startClock()
    }

    /// The player declined in-app, before any OS prompt.
    func declineTheEye() { eye.consent(false) }

    /// Close the eye — the panic switch. Revokes consent and stops the camera
    /// at once, from any point in the experience.
    func closeTheEye() {
        clock?.cancel()
        eye.release()
        consent.revokeAll()
        Task { await camera.stop() }
    }

    private func startClock() {
        var last = Date()
        clock = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self else { return }
                let dt = now.timeIntervalSince(last)
                last = now
                self.eye.advance(by: dt)
                if !self.eye.wantsCamera { self.clock?.cancel() }
            }
    }
}
