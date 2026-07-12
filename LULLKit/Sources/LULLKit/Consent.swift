/// The sensors LULL is *permitted* to touch. Membership in this enum is the
/// entire allow-list — and there is deliberately no case for photos, contacts,
/// location, or health. "Horror by permission" is enforced by the type system:
/// code that wanted to reach a forbidden sensor cannot even name one.
public enum Sensor: String, CaseIterable, Sendable, Codable {
    /// The front camera — "the eye". It watches the player, and reacts.
    case camera
    /// The microphone — "the room". The silence, and what breaks it.
    case microphone
    /// Local notifications — "the reach". A message at 3am, app closed.
    case notifications
    /// Haptics — "the pulse". A heartbeat in the palm that is not quite yours.
    case haptics
    /// Device motion — the stillness of the room, and when it stops being still.
    case motion

    /// A short, honest reason shown to the player *before* the OS prompt.
    /// (App Review reads these adversarially; so do we.)
    public var rationale: String {
        switch self {
        case .camera:        return "So LULL can see your face in the dark. You can turn this off at any time."
        case .microphone:    return "So LULL can hear the room. You can turn this off at any time."
        case .notifications: return "So LULL can reach you after you have closed it. You can turn this off at any time."
        case .haptics:       return "So LULL can be felt, not only seen."
        case .motion:        return "So LULL knows when the room goes still."
        }
    }
}

/// A revocable, explicit record of what the player has agreed to let LULL use.
///
/// The whole ethical spine of the game lives here: **default is deny** — nothing
/// is usable until the player explicitly grants it — and **every grant is
/// revocable**, instantly, including all of them at once (the panic switch).
public struct ConsentLedger: Sendable, Equatable, Codable {
    private var granted: Set<Sensor>

    public init(granted: Set<Sensor> = []) { self.granted = granted }

    /// Whether LULL may currently use `sensor`. Absent an explicit grant: no.
    public func mayUse(_ sensor: Sensor) -> Bool { granted.contains(sensor) }

    /// Record the player's explicit consent for one sensor.
    public mutating func grant(_ sensor: Sensor) { granted.insert(sensor) }

    /// Withdraw consent for one sensor. Access must stop immediately.
    public mutating func revoke(_ sensor: Sensor) { granted.remove(sensor) }

    /// The panic switch: withdraw everything. The player always has this.
    public mutating func revokeAll() { granted.removeAll() }

    /// The sensors currently in use, for an always-visible "LULL can see/hear
    /// you" affordance — the player should never be surprised by what is on.
    public var activeSensors: Set<Sensor> { granted }
}
