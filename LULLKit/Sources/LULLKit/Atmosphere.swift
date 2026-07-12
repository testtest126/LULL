import Foundation

/// LULL's voice.
///
/// The game speaks in three literary registers, each governing one act of the
/// experience. They are a design language, not a citation: the lines below are
/// original prose written *in the register of* each author, never quotations —
/// so nothing here reproduces a copyrighted text, and the dread is never broken
/// by a name on screen. Who is credited, and why, lives in the README.
///
/// - `kafka`  — the **threshold**: a record opened in your name, consent asked,
///   the verdict withheld. Governs the consent step and its endings.
/// - `beckett` — the **lull**: waiting, stillness, the failing light, the nothing
///   that is also a mercy. Governs the calm, and the closing.
/// - `poe`    — the **watch**: the eye that will not blink, the heart beneath the
///   floor that will not stop. Governs the escalation to `awake`.
public enum Voice: String, Sendable, Codable, CaseIterable {
    case kafka
    case beckett
    case poe
}

/// A single line of narration, tagged with the register it belongs to.
public struct Line: Sendable, Equatable, Codable {
    public let text: String
    public let voice: Voice
    public init(_ text: String, _ voice: Voice) {
        self.text = text
        self.voice = voice
    }
}

/// The game's narration: a **pure** mapping from the tested `EyeSession.Phase`
/// (and how long it has run) to a line of text. It holds no state, touches no
/// hardware, and reaches no sensor — so it is fully testable, and it cannot,
/// even in principle, widen what LULL is permitted to do. The app renders what
/// this returns and adds nothing of its own.
public enum Atmosphere {

    /// The ordered lines for a phase — earlier beats first, deepening as they go.
    /// The hush is deliberate: lowercase, two-breath lines, never a shout.
    public static func script(for phase: EyeSession.Phase) -> [Line] {
        switch phase {
        case .dormant:
            return []

        // KAFKA — the threshold. A file opening in your name; you may still
        // choose what goes in it. (Shown *beside* the honest consent copy, which
        // is never altered for atmosphere.)
        case .seekingConsent:
            return [
                Line("a file is opening in your name.", .kafka),
                Line("you have done nothing.\nthat was never the question.", .kafka),
            ]

        // BECKETT — the lull. Nothing happens, and that is the whole of it.
        case .watching:
            return [
                Line("close your eyes.\nlet it watch for you.", .beckett),
                Line("nothing yet.\nthat is the idea.", .beckett),
                Line("the light is going.\nlet it go.", .beckett),
                Line("be still. stiller.\nthere is nowhere to be.", .beckett),
            ]

        // POE — the watch stirs. Something turns to face you; a small sound
        // begins, yours or the floor's.
        case .noticing:
            return [
                Line("you're still awake.\nso is it.", .poe),
                Line("something behind the glass\nhas turned to face you.", .poe),
                Line("a small sound now.\nyours, or the floor's.", .poe),
                Line("the eye has found you\nand will not blink.", .poe),
            ]

        // POE — the climax. The vulture eye open all the way; the tell-tale
        // heart, louder, louder.
        case .awake:
            return [
                Line("it knows your face now.", .poe),
                Line("louder now — that beating.\nyou hear it too.", .poe),
                Line("it was always this eye.\nit is open all the way.", .poe),
                Line("put the phone down.\nit will keep your face.", .poe),
            ]

        // KAFKA — the case that never opened. Merciful, and honest: nothing was
        // written down. Saying no is always safe here.
        case .denied:
            return [
                Line("you said no.\nnothing was written down. sleep well.", .kafka),
            ]

        // BECKETT — the closing. Nothing watches now; nothing was. Only a game.
        case .released:
            return [
                Line("the eye is closed.\nnothing watches now. it was only a game.", .beckett),
            ]
        }
    }

    /// The line to show for `phase` at a given `beat`. Beats advance with time
    /// (see `beat(forElapsed:)`) and wrap, so a phase that lingers keeps
    /// breathing rather than freezing on one line. Returns `nil` only for phases
    /// that say nothing (`dormant`).
    public static func narration(for phase: EyeSession.Phase, beat: Int = 0) -> Line? {
        let lines = script(for: phase)
        guard !lines.isEmpty else { return nil }
        let i = ((beat % lines.count) + lines.count) % lines.count   // wrap, incl. negatives
        return lines[i]
    }

    /// How many seconds one line is held before the next. A slow breath.
    public static let beatSeconds: TimeInterval = 9

    /// Which beat the experience is on, from the session's elapsed time. Pure and
    /// monotonic: the app feeds it `eye.elapsed`, and gets back a stable index.
    public static func beat(forElapsed elapsed: TimeInterval) -> Int {
        max(0, Int(elapsed / beatSeconds))
    }
}
