import Foundation

/// LULL's voice.
///
/// The game speaks in four literary registers. Three each govern one act of
/// the experience; the fourth runs alongside them as a throughline. They are
/// a design language, not a citation: the lines below are original prose
/// written *in the register of* each author, never quotations — so nothing
/// here reproduces a copyrighted text, and the dread is never broken by a
/// name on screen. Who is credited, and why, lives in the README.
///
/// - `kafka`  — the **threshold**: a record opened in your name, consent asked,
///   the verdict withheld. Governs the consent step and its endings.
/// - `beckett` — the **lull**: waiting, stillness, the failing light, the nothing
///   that is also a mercy. Governs the calm, and the closing.
/// - `poe`    — the **watch**: the eye that will not blink, the heart beneath the
///   floor that will not stop. Governs the escalation to `awake`.
/// - `bulgakov` — the **guest**: an urbane, amused observer who arrives
///   hospitable and departs having revealed he was never a guest at all.
///   Does not govern a single act; it is present in the threshold, the lull,
///   and the watch, and curdles as they deepen — an aside spoken alongside
///   whichever register owns the moment, the one voice that lingers across
///   every act rather than yielding the floor.
public enum Voice: String, Sendable, Codable, CaseIterable {
    case kafka
    case beckett
    case poe
    case bulgakov
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

    /// How many beats a player has to linger at `awake` (see
    /// `EyeSession.awakeElapsed`) before the ceiling stops performing for
    /// them and Bulgakov's paralysis pairing replaces his triumphant one —
    /// see `docs/ideation/two-devils-wit-and-paralysis.md`. A player who
    /// reaches `awake` and closes the eye quickly only ever meets the
    /// triumphant reveal; one who stays meets the one that's gone still.
    public static let awakeParalysisThresholdBeats = 2

    /// The ordered lines for a phase — earlier beats first, deepening as they go.
    /// The hush is deliberate: lowercase, two-breath lines, never a shout.
    /// `dwellBeats` only matters for `.awake` (see `awakeParalysisThresholdBeats`);
    /// every other phase ignores it.
    public static func script(for phase: EyeSession.Phase, dwellBeats: Int = 0) -> [Line] {
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
                // BULGAKOV — the guest arrives. Hospitable, faintly amused,
                // already too familiar for a first meeting.
                Line("do come in. we've been expecting you\nfor rather longer than you'd guess.", .bulgakov),
                Line("a small formality, this file.\nyou may decline — i rarely take it personally.", .bulgakov),
            ]

        // BECKETT — the lull. Nothing happens, and that is the whole of it.
        case .watching:
            return [
                Line("close your eyes.\nlet it watch for you.", .beckett),
                Line("nothing yet.\nthat is the idea.", .beckett),
                Line("the light is going.\nlet it go.", .beckett),
                Line("be still. stiller.\nthere is nowhere to be.", .beckett),
                // BULGAKOV — still the charming guest, settling in.
                Line("take your time. i have an abundance of it,\nand find i rather enjoy watching yours pass.", .bulgakov),
                Line("such a well-kept quiet.\ni've admired worse rooms, and for longer.", .bulgakov),
            ]

        // POE — the watch stirs. Something turns to face you; a small sound
        // begins, yours or the floor's.
        case .noticing:
            return [
                Line("you're still awake.\nso is it.", .poe),
                Line("something behind the glass\nhas turned to face you.", .poe),
                Line("a small sound now.\nyours, or the floor's.", .poe),
                Line("the eye has found you\nand will not blink.", .poe),
                // BULGAKOV — the pleasantries begin to thin.
                Line("you're beginning to wonder\nwhether i was ever really a guest.", .bulgakov),
                Line("something soft and black crossed the room just now.\ndon't trouble yourself over it.", .bulgakov),
            ]

        // POE — the climax. The vulture eye open all the way; the tell-tale
        // heart, louder, louder. Poe's four lines hold regardless of how
        // long the player stays — only Bulgakov's pairing below forks.
        case .awake:
            let poe = [
                Line("it knows your face now.", .poe),
                Line("louder now — that beating.\nyou hear it too.", .poe),
                Line("it was always this eye.\nit is open all the way.", .poe),
                Line("put the phone down.\nit will keep your face.", .poe),
            ]
            if dwellBeats >= awakeParalysisThresholdBeats {
                // BULGAKOV, PARALYSIS — a player who stays finds the guest
                // has run out of room. Original prose, in the register of
                // Dante's frozen, mute Lucifer (Inferno's closing canto) —
                // not a quotation or paraphrase of any translation: in the
                // poem itself he never speaks at all, so there is no
                // dialogue to echo. See
                // docs/ideation/two-devils-wit-and-paralysis.md §5.
                return poe + [
                    Line("i have already said everything\ni am going to say.", .bulgakov),
                    Line("you can leave.\ni find i no longer remember how.", .bulgakov),
                ]
            } else {
                // BULGAKOV, WIT — the host curdles. The manuscript motif
                // ties the "I AM STILL HERE" persistence idea to Bulgakov's
                // signature theme: the thing that refuses to be destroyed.
                return poe + [
                    Line("manuscripts, they say, don't burn.\nneither, it turns out, do i.", .bulgakov),
                    Line("i did introduce myself at the door.\nyou were the one who invited me further in.", .bulgakov),
                ]
            }

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
    /// that say nothing (`dormant`). `dwellBeats` selects which `.awake` pairing
    /// plays — see `script(for:dwellBeats:)`; every other phase ignores it.
    public static func narration(for phase: EyeSession.Phase, beat: Int = 0, dwellBeats: Int = 0) -> Line? {
        let lines = script(for: phase, dwellBeats: dwellBeats)
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
