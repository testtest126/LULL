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

    /// A player who reaches `awake` and leaves quickly meets Bulgakov's
    /// triumphant reveal — the default, and the only pairing that existed
    /// before this fork. See docs/ideation/two-devils-wit-and-paralysis.md.
    func testAwakeStaysTriumphantWhenDwellIsShort() {
        for dwell in [0, Atmosphere.awakeParalysisThresholdBeats - 1] {
            let lines = Atmosphere.script(for: .awake, dwellBeats: dwell)
            let bulgakovText = lines.filter { $0.voice == .bulgakov }.map(\.text).joined().lowercased()
            XCTAssertTrue(bulgakovText.contains("burn"), "dwell \(dwell): should still be the triumphant pairing")
            XCTAssertFalse(bulgakovText.contains("no longer remember"), "dwell \(dwell): not the paralysis pairing yet")
            XCTAssertEqual(lines.count, 6, "poe's four lines plus one bulgakov pairing")
        }
        // Calling without dwellBeats at all must match dwellBeats: 0 exactly —
        // existing call sites (and testBulgakovCurdlesFromHospitableToRevealed)
        // must keep seeing today's triumphant lines by default.
        XCTAssertEqual(Atmosphere.script(for: .awake), Atmosphere.script(for: .awake, dwellBeats: 0))
    }

    /// A player who lingers at the ceiling meets the other devil: Bulgakov's
    /// paralysis pairing, in the register of Dante's frozen, mute Lucifer —
    /// Poe's own four lines are unchanged either way; only Bulgakov's aside forks.
    func testAwakeSwitchesToParalysisWhenThePlayerLingers() {
        for dwell in [Atmosphere.awakeParalysisThresholdBeats, Atmosphere.awakeParalysisThresholdBeats + 5] {
            let lines = Atmosphere.script(for: .awake, dwellBeats: dwell)
            let bulgakovText = lines.filter { $0.voice == .bulgakov }.map(\.text).joined().lowercased()
            XCTAssertTrue(bulgakovText.contains("no longer remember"), "dwell \(dwell): should be the paralysis pairing")
            XCTAssertFalse(bulgakovText.contains("burn"), "dwell \(dwell): not the triumphant pairing anymore")
            XCTAssertEqual(lines.count, 6, "poe's four lines plus one bulgakov pairing, same shape either way")

            let poeText = lines.filter { $0.voice == .poe }.map(\.text)
            XCTAssertEqual(poeText, Atmosphere.script(for: .awake, dwellBeats: 0).filter { $0.voice == .poe }.map(\.text),
                           "poe's lines don't change with dwell time — only bulgakov's pairing forks")
        }
    }

    /// The beat-wrap (testBeatsWrapDeterministically) holds identically for
    /// whichever `awake` pairing dwell time selects — lingering doesn't
    /// break narration, it just changes which six lines are being cycled.
    func testAwakeBeatWrapHoldsForBothPairings() {
        for dwell in [0, Atmosphere.awakeParalysisThresholdBeats] {
            let lines = Atmosphere.script(for: .awake, dwellBeats: dwell)
            XCTAssertEqual(Atmosphere.narration(for: .awake, beat: 0, dwellBeats: dwell), lines.first)
            XCTAssertEqual(Atmosphere.narration(for: .awake, beat: lines.count, dwellBeats: dwell), lines.first,
                           "one full cycle returns to the first line, dwell \(dwell)")
            XCTAssertEqual(Atmosphere.narration(for: .awake, beat: -1, dwellBeats: dwell), lines.last,
                           "negative beats wrap too, dwell \(dwell)")
        }
    }

    /// The paralysis lines are original prose, not a quotation or paraphrase
    /// of any published English translation of the Inferno's closing canto.
    /// The frozen/mute/three-mouths imagery is centuries-old public domain;
    /// a translator's specific phrasing of it is not, so this pins a few of
    /// the most recognizable phrases across well-known translations
    /// (Longfellow, Ciardi/Mandelbaum-style renderings) as a smoke check —
    /// notably, Dante's Lucifer never speaks a word in the poem itself, so
    /// there is no dialogue in the source to have echoed in the first place.
    func testParalysisLinesAreNotVerbatimQuotationsOfInferno() {
        let bannedPhrases = [
            "emperor of the kingdom dolorous",
            "if he was fair as he is hideous now",
            "with six eyes did he weep",
            "three chins",
            "bloody foam",
            "the woe of all the universe",
        ]
        let paralysisText = Atmosphere.script(for: .awake, dwellBeats: Atmosphere.awakeParalysisThresholdBeats)
            .filter { $0.voice == .bulgakov }
            .map(\.text).joined(separator: " ").lowercased()
        for phrase in bannedPhrases {
            XCTAssertFalse(paralysisText.contains(phrase),
                           "paralysis copy must stay original, not quote a known Inferno translation")
        }
    }
}
