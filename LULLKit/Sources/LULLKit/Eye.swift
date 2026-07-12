import Foundation

/// The camera, abstracted so game logic stays testable and platform-free.
/// The app provides an AVFoundation-backed implementation; tests provide a fake.
/// Access is only ever requested *after* the player has consented in-app
/// (`ConsentLedger`) and seen the rationale — the OS prompt is never the first
/// thing they meet.
public protocol CameraGate: AnyObject {
    /// Ask the OS for camera access. Returns whether it was granted. Only ever
    /// called after in-app consent and the rationale — never as first contact.
    func requestAccess() async -> Bool
    /// Begin delivering frames.
    func start() async
    /// Stop immediately — the player's revoke must take effect at once.
    func stop() async
}

/// The vertical-slice experience: **THE EYE.** The app asks to watch; then it
/// watches, calm at first; then it starts to react to being watched back; then
/// it stops behaving like software. A small, deterministic state machine with
/// no camera and no UI, so it is fully testable — the app drives it with real
/// time and a real camera, the tests drive it with fake time and assertions.
public struct EyeSession: Sendable, Equatable {

    public enum Phase: String, Sendable, Equatable, Codable {
        /// Nothing has started.
        case dormant
        /// Asking, in-app, before any OS prompt.
        case seekingConsent
        /// The player said no — respected, fully and finally.
        case denied
        /// Consented. The eye is open. Calm, for now.
        case watching
        /// It has begun to notice that it is being watched back.
        case noticing
        /// It has stopped behaving like software.
        case awake
        /// The player closed the eye (revoked). Always allowed, from anywhere.
        case released
    }

    public private(set) var phase: Phase
    public private(set) var elapsed: TimeInterval

    /// How long the calm lasts before it starts to notice.
    public var calmSeconds: TimeInterval
    /// How long "noticing" lasts before it is fully awake.
    public var noticingSeconds: TimeInterval

    public init(calmSeconds: TimeInterval = 40, noticingSeconds: TimeInterval = 30) {
        self.phase = .dormant
        self.elapsed = 0
        self.calmSeconds = calmSeconds
        self.noticingSeconds = noticingSeconds
    }

    /// Begin the flow by asking for consent, in-app, first.
    public mutating func begin() {
        guard phase == .dormant else { return }
        phase = .seekingConsent
    }

    /// The player's answer to the in-app consent request, before the OS prompt.
    /// `false` is a real ending — `denied` is terminal, and nothing watches.
    public mutating func consent(_ granted: Bool) {
        guard phase == .seekingConsent else { return }
        phase = granted ? .watching : .denied
        elapsed = 0
    }

    /// Advance the experience by `dt` seconds. Only meaningful while the eye is
    /// open; a negative or huge `dt` (e.g. after backgrounding) is clamped.
    public mutating func advance(by dt: TimeInterval) {
        guard phase == .watching || phase == .noticing else { return }
        elapsed += min(max(0, dt), 5)
        if elapsed >= calmSeconds + noticingSeconds {
            phase = .awake
        } else if elapsed >= calmSeconds {
            phase = .noticing
        }
    }

    /// The player closes the eye — a revoke, honored at any time, from any phase.
    /// This is the panic switch made concrete for the slice.
    public mutating func release() {
        phase = .released
    }

    /// Whether the camera should be running right now, given the phase. The app
    /// asks this and nothing else — the eye is only ever open when the machine
    /// says so, never by accident.
    public var wantsCamera: Bool {
        switch phase {
        case .watching, .noticing, .awake: return true
        case .dormant, .seekingConsent, .denied, .released: return false
        }
    }
}
