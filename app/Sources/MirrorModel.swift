import SwiftUI
import Combine
import LULLKit

/// Coordinates the pure `MirrorSession` state machine with a real camera and
/// a real clock — the same shape as `GameModel`, for the same reason: every
/// *decision* lives in LULLKit (and is tested there); this object only wires
/// those decisions to time and hardware, and to the consent ledger that
/// gates it all. A separate `CameraController` instance from THE EYE's, so
/// the two mechanics never share camera state — but the same `Sensor.camera`
/// rationale and the same panic-switch contract.
@MainActor
final class MirrorModel: ObservableObject {
    @Published private(set) var mirror = MirrorSession()
    @Published private(set) var consent = ConsentLedger()

    let camera = CameraController()
    private var clock: AnyCancellable?

    /// Enter the flow: it asks, in-app, before anything watches.
    func begin() { mirror.begin() }

    /// The player agreed in-app. Record consent, then ask the OS; a refusal
    /// at either level is a real "no", and the mirror never opens.
    func allowTheMirror() async {
        consent.grant(.camera)
        guard await camera.requestAccess() else {
            consent.revoke(.camera)
            mirror.consent(false)
            return
        }
        mirror.consent(true)
        await camera.start()
        startClock()
    }

    /// The player declined in-app, before any OS prompt.
    func declineTheMirror() { mirror.consent(false) }

    /// Close the mirror — the panic switch. Revokes consent and stops the
    /// camera at once, from any point in the experience.
    func closeTheMirror() {
        clock?.cancel()
        mirror.release()
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
                self.mirror.advance(by: dt)
                if !self.mirror.wantsCamera { self.clock?.cancel() }
            }
    }
}
