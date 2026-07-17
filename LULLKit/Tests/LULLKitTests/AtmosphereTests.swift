import XCTest
@testable import LULLKit

/// The voice, pinned. Narration is pure text over the tested phase machine, so
/// the register mapping, the hush, and the beat-wrap are all provable without a
/// screen — and, by construction, nothing here can touch a sensor.
final class AtmosphereTests: XCTestCase {

    /// Each act speaks in its intended register: Kafka at the threshold, Beckett
    /// in the lull, Poe in the watch.
    func testEachActSpeaksInItsRegister() {
        XCTAssertEqual(Atmosphere.narration(for: .seekingConsent)?.voice, .kafka)
        XCTAssertEqual(Atmosphere.narration(for: .watching)?.voice, .beckett)
        XCTAssertEqual(Atmosphere.narration(for: .noticing)?.voice, .poe)
        XCTAssertEqual(Atmosphere.narration(for: .awake)?.voice, .poe)
        XCTAssertEqual(Atmosphere.narration(for: .denied)?.voice, .kafka)
        XCTAssertEqual(Atmosphere.narration(for: .released)?.voice, .beckett)
    }

    /// Every phase the player can reach has something to say — except the one
    /// before anything has started.
    func testOnlyDormantIsSilent() {
        XCTAssertNil(Atmosphere.narration(for: .dormant), "nothing has begun; nothing speaks")
        XCTAssertTrue(Atmosphere.script(for: .dormant).isEmpty)
        for phase: EyeSession.Phase in [.seekingConsent, .watching, .noticing, .awake, .denied, .released] {
            XCTAssertFalse(Atmosphere.script(for: phase).isEmpty, "\(phase) must have a voice")
            XCTAssertNotNil(Atmosphere.narration(for: phase))
        }
    }

    /// A lingering phase keeps breathing: beats advance through its lines and
    /// wrap, deterministically, rather than freezing or crashing.
    func testBeatsWrapDeterministically() {
        let lines = Atmosphere.script(for: .watching)
        XCTAssertGreaterThan(lines.count, 1)
        XCTAssertEqual(Atmosphere.narration(for: .watching, beat: 0), lines.first)
        XCTAssertEqual(Atmosphere.narration(for: .watching, beat: lines.count), lines.first,
                       "one full cycle returns to the first line")
        XCTAssertEqual(Atmosphere.narration(for: .watching, beat: -1), lines.last,
                       "negative beats wrap too — never a crash")
    }

    /// The dread deepens with time: the first line the player meets on the calm
    /// is the gentle one; later beats reach the sharper lines.
    func testTimeDeepensTheLine() {
        XCTAssertEqual(Atmosphere.beat(forElapsed: 0), 0)
        XCTAssertEqual(Atmosphere.beat(forElapsed: Atmosphere.beatSeconds - 0.01), 0)
        XCTAssertEqual(Atmosphere.beat(forElapsed: Atmosphere.beatSeconds), 1)
        XCTAssertEqual(Atmosphere.beat(forElapsed: -5), 0, "elapsed never goes negative, but be safe")
    }

    /// Saying no stays a mercy: the denial line reassures, and never threatens.
    func testDenialLineIsMerciful() {
        let denial = Atmosphere.narration(for: .denied)?.text.lowercased() ?? ""
        XCTAssertTrue(denial.contains("sleep well"), "declining must always feel safe")
    }

    /// Bulgakov is registered as a fourth voice alongside the original three.
    func testBulgakovIsARegisteredVoice() {
        XCTAssertTrue(Voice.allCases.contains(.bulgakov))
        XCTAssertEqual(Voice.allCases.count, 4)
    }

    /// Unlike Kafka/Beckett/Poe, Bulgakov doesn't govern a single act — it's a
    /// throughline, present as an aside in the threshold, the lull, and the
    /// watch, without displacing the register that owns each of those acts.
    func testBulgakovRunsAlongsideEveryActWithoutOwningTheFirstLine() {
        for phase: EyeSession.Phase in [.seekingConsent, .watching, .noticing, .awake] {
            let lines = Atmosphere.script(for: phase)
            XCTAssertTrue(lines.contains { $0.voice == .bulgakov },
                          "\(phase) should carry a bulgakov aside")
            XCTAssertNotEqual(lines.first?.voice, .bulgakov,
                              "\(phase)'s own register must still speak first")
        }
        // Bulgakov never intrudes on the two short, merciful endings.
        XCTAssertFalse(Atmosphere.script(for: .denied).contains { $0.voice == .bulgakov })
        XCTAssertFalse(Atmosphere.script(for: .released).contains { $0.voice == .bulgakov })
    }

    /// The register curdles across the arc: hospitable near the threshold,
    /// no longer pretending to be a guest by the time the eye is `awake` —
    /// and the `awake` line ties Bulgakov's "manuscripts don't burn" motif to
    /// the persistence theme, without quoting it.
    func testBulgakovCurdlesFromHospitableToRevealed() {
        let earlyText = Atmosphere.script(for: .seekingConsent)
            .filter { $0.voice == .bulgakov }.map(\.text).joined().lowercased()
        XCTAssertTrue(earlyText.contains("do come in") || earlyText.contains("expecting you"),
                      "the guest should arrive charming, not menacing")

        let lateText = Atmosphere.script(for: .awake)
            .filter { $0.voice == .bulgakov }.map(\.text).joined().lowercased()
        XCTAssertTrue(lateText.contains("burn"), "the persistence motif should surface by `awake`")
        XCTAssertTrue(lateText.contains("guest") == false, "by now he no longer calls himself a guest")
    }

    /// Every Bulgakov line is original prose — never a quotation from
    /// Bulgakov's actual texts. This is a smoke check, not a proof: it pins
    /// a couple of the most famous lines/phrases from published translations
    /// of "The Master and Margarita" so a future edit can't accidentally
    /// paste one in verbatim.
    func testBulgakovLinesAreNotVerbatimQuotations() {
        let bannedPhrases = [
            "who are you, then",
            "part of that power",
            "second-rate", // "Manuscripts don't burn" surrounding dialogue in well-known translations
            "cowardice is the most terrible of vices",
        ]
        let allPhases: [EyeSession.Phase] = [.dormant, .seekingConsent, .denied, .watching, .noticing, .awake, .released]
        let allBulgakovText = allPhases
            .flatMap { Atmosphere.script(for: $0) }
            .filter { $0.voice == .bulgakov }
            .map(\.text).joined(separator: " ").lowercased()
        for phrase in bannedPhrases {
            XCTAssertFalse(allBulgakovText.contains(phrase),
                           "bulgakov copy must stay original, not quote a known translation")
        }
    }

    /// A tiny half-seen touch: something crosses the edge of frame and is
    /// gone, in Poe's register, alongside his existing noticing lines — never
    /// shown, never described, only implied. Poe still speaks first at the
    /// default beat, so this doesn't change what the player meets on arrival.
    func testNoticingCarriesAnEdgeOfFrameLine() {
        let poeText = Atmosphere.script(for: .noticing)
            .filter { $0.voice == .poe }.map(\.text).joined(separator: " ").lowercased()
        XCTAssertTrue(poeText.contains("edge of frame"), "noticing should carry the edge-of-frame beat")
        XCTAssertEqual(Atmosphere.narration(for: .noticing)?.voice, .poe, "poe still speaks first by default")
    }

    /// A tiny, strictly retrospective glimpse at the ceiling — the closest
    /// this register comes to a "glimpsed face," and it stays uncanny, not
    /// gory: one frame, already corrected, nothing described or lingered on.
    func testAwakeCarriesAGlimpsedFaceLine() {
        let poeText = Atmosphere.script(for: .awake)
            .filter { $0.voice == .poe }.map(\.text).joined(separator: " ").lowercased()
        XCTAssertTrue(poeText.contains("wasn't your face"), "awake should carry the glimpsed-face beat")
        XCTAssertFalse(poeText.contains("scream"), "the glimpse stays suggestive, never depicted")
    }
}
