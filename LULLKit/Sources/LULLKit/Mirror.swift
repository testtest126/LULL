import Foundation

/// **THE MIRROR** — a surface that should show you yourself, and lies. Its own
/// slice, reusing `CameraGate`/`ConsentLedger` exactly as `EyeSession` does —
/// no new sensor, same panic switch — but a separate session, so THE EYE's
/// tested behavior is never touched by this mechanic.
///
/// Design source of truth: `docs/ideation/mirror-and-still-here.md` and the
/// moodboard's "Ideation art → THE MIRROR" entry. Nothing here should go
/// beyond what those describe.
public struct MirrorSession: Sendable, Equatable {

    /// The escalation ladder from the design doc: clear → lag → drift →
    /// independence → contact (the ceiling). `denied`/`released` are the same
    /// two endings `EyeSession` has, for the same reasons — a "no" is
    /// terminal and merciful, and the panic switch is honored from anywhere.
    public enum Phase: String, Sendable, Equatable, Codable {
        /// Nothing has started.
        case dormant
        /// Asking, in-app, before any OS prompt.
        case seekingConsent
        /// The player said no — respected, fully and finally.
        case denied
        /// Consented. The reflection matches. Trust has to be earned first.
        case clear
        /// The reflection is a beat behind — easy to mistake for a hitch.
        case lag
        /// The reflection stops matching exactly. Still deniable.
        case drift
        /// The reflection does something the player didn't do. The first
        /// true rule break.
        case independence
        /// Contact — the ceiling. The reflection writes on the glass.
        /// `MirrorSession` goes no further than this.
        case contact
        /// The player closed the mirror (revoked). Always allowed, from
        /// anywhere.
        case released
    }

    public private(set) var phase: Phase
    /// How far into the ladder the session has advanced. Mirrors
    /// `EyeSession.elapsed`: it marks *when* `contact` (the ceiling) was
    /// reached, then holds — it is not "how long has the player stayed."
    public private(set) var elapsed: TimeInterval
    /// How long the player has lingered at `contact`. Mirrors
    /// `EyeSession.awakeElapsed`: starts at zero the instant the ceiling is
    /// reached and counts for as long as the player stays, independently of
    /// `elapsed`. Drives whether the full "I AM STILL HERE" scrawl ever
    /// appears — see `Atmosphere.mirrorScrawlThresholdBeats`.
    public private(set) var contactElapsed: TimeInterval

    /// How long the reflection matches cleanly before it starts to lag.
    public var clearSeconds: TimeInterval
    /// How long the lag lasts before the reflection starts to drift.
    public var lagSeconds: TimeInterval
    /// How long the drift lasts before the reflection acts independently.
    public var driftSeconds: TimeInterval
    /// How long independence lasts before contact — the ceiling.
    public var independenceSeconds: TimeInterval

    /// Timings aren't specified in the design doc (it only fixes the order
    /// of the ladder), so these default to the same total run-up as
    /// `EyeSession`'s calm+noticing (70s) — clear+lag as the long "still
    /// deniable" stretch, drift+independence as the shorter approach to the
    /// ceiling. A judgment call, flagged for the owner in the PR.
    public init(
        clearSeconds: TimeInterval = 20,
        lagSeconds: TimeInterval = 20,
        driftSeconds: TimeInterval = 15,
        independenceSeconds: TimeInterval = 15
    ) {
        self.phase = .dormant
        self.elapsed = 0
        self.contactElapsed = 0
        self.clearSeconds = clearSeconds
        self.lagSeconds = lagSeconds
        self.driftSeconds = driftSeconds
        self.independenceSeconds = independenceSeconds
    }

    /// Begin the flow by asking for consent, in-app, first.
    public mutating func begin() {
        guard phase == .dormant else { return }
        phase = .seekingConsent
    }

    /// The player's answer to the in-app consent request, before the OS
    /// prompt. `false` is a real ending — `denied` is terminal, and nothing
    /// watches. Reuses `Sensor.camera` — the mirror is the same sensor as
    /// THE EYE, never a new one.
    public mutating func consent(_ granted: Bool) {
        guard phase == .seekingConsent else { return }
        phase = granted ? .clear : .denied
        elapsed = 0
    }

    /// Advance the experience by `dt` seconds. A negative or huge `dt` (e.g.
    /// after backgrounding) is clamped, exactly as `EyeSession` clamps it —
    /// time skipping ahead cannot skip the ladder.
    public mutating func advance(by dt: TimeInterval) {
        let clamped = min(max(0, dt), 5)
        switch phase {
        case .clear, .lag, .drift, .independence:
            elapsed += clamped
            let toLag = clearSeconds
            let toDrift = toLag + lagSeconds
            let toIndependence = toDrift + driftSeconds
            let toContact = toIndependence + independenceSeconds
            if elapsed >= toContact {
                phase = .contact
            } else if elapsed >= toIndependence {
                phase = .independence
            } else if elapsed >= toDrift {
                phase = .drift
            } else if elapsed >= toLag {
                phase = .lag
            }
        case .contact:
            // The ceiling has no further phase to escalate into by the
            // clock — `elapsed` intentionally stops here, exactly as
            // `EyeSession.awake` does. `contactElapsed` is the separate,
            // ongoing count of how long the player has stayed.
            contactElapsed += clamped
        case .dormant, .seekingConsent, .denied, .released:
            return
        }
    }

    /// The player closes the mirror — a revoke, honored at any time, from
    /// any phase. The same panic switch as THE EYE, made concrete here too.
    public mutating func release() {
        phase = .released
    }

    /// Whether the camera should be running right now. The mirror is only
    /// ever open when the machine says so, never by accident — identical
    /// contract to `EyeSession.wantsCamera`.
    public var wantsCamera: Bool {
        switch phase {
        case .clear, .lag, .drift, .independence, .contact: return true
        case .dormant, .seekingConsent, .denied, .released: return false
        }
    }

    /// How many seconds the displayed reflection should lag behind the live
    /// feed, for the phases that still show a live (distorted) feed at all.
    /// `.clear` is exact — trust has to be established before anything is
    /// wrong — then the delay grows through `.lag` and `.drift`, per the
    /// design doc's "frame-delay ring buffer" note. Beyond `.drift` the
    /// question is moot: see `requiresAuthoredAsset`.
    public var frameDelay: TimeInterval {
        switch phase {
        case .clear: return 0
        case .lag: return 0.5
        case .drift: return 1.5
        case .independence, .contact, .dormant, .seekingConsent, .denied, .released: return 0
        }
    }

    /// Whether the reflection shown right now must be a pre-authored asset
    /// rather than the live camera feed. The design doc is explicit and this
    /// is a hard constraint, not a suggestion: "anything past drift is a
    /// canned authored asset caught on look-back, never live generation" —
    /// live face-tracking/generation is exactly what the doc rules out for
    /// `.independence` and `.contact`.
    public var requiresAuthoredAsset: Bool {
        switch phase {
        case .independence, .contact: return true
        default: return false
        }
    }
}
