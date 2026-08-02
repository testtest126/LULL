import XCTest
@testable import LULLKit

/// THE MIRROR's voice and its "I AM STILL HERE" motif, pinned. The design doc
/// (`docs/ideation/mirror-and-still-here.md` §2, §5) is explicit about the
/// restraint rules this encodes: the motif stays under-shown until the
/// ceiling, a full scrawl only ever appears for a player who lingers there,
/// and there is exactly one silence beat right before the ceiling speaks.
final class MirrorAtmosphereTests: XCTestCase {

    /// Kafka at the threshold, Beckett through the "still deniable" stretch
    /// of the ladder, Poe once the watch truly stirs — same register
    /// discipline as THE EYE, mapped onto the mirror's own five-phase ladder.
    func testEachPhaseSpeaksInItsRegister() {
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.seekingConsent)?.voice, .kafka)
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.denied)?.voice, .kafka)
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.clear)?.voice, .beckett)
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.lag)?.voice, .beckett)
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.drift)?.voice, .beckett)
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.independence)?.voice, .poe)
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.contact, beat: 1)?.voice, .poe)
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.released)?.voice, .beckett)
    }

    /// Dormant is silent because nothing has begun. Every other phase has
    /// something to say — with `.contact` treated separately below, since
    /// its very first beat is a deliberate silence, not an empty script.
    func testOnlyDormantIsSilent() {
        XCTAssertNil(Atmosphere.mirrorNarration(for: MirrorSession.Phase.dormant))
        XCTAssertTrue(Atmosphere.mirrorScript(for: MirrorSession.Phase.dormant).isEmpty)
        let speakingPhases: [MirrorSession.Phase] = [.seekingConsent, .clear, .lag, .drift, .independence, .denied, .released]
        for phase in speakingPhases {
            XCTAssertFalse(Atmosphere.mirrorScript(for: phase).isEmpty, "\(phase) must have a voice")
            XCTAssertNotNil(Atmosphere.mirrorNarration(for: phase))
        }
        XCTAssertFalse(Atmosphere.mirrorScript(for: MirrorSession.Phase.contact).isEmpty, ".contact has a script — it just doesn't speak on beat 0")
    }

    /// "One true silence before the ceiling": `.contact`'s beat 0 is
    /// deliberately mute. Because `contactElapsed` only ever counts upward
    /// while the player stays (never resets — see `MirrorSession`), beat 0
    /// is visited exactly once per session, so this silence cannot recur.
    func testContactOpensWithOneTrueSilenceBeforeItSpeaks() {
        XCTAssertNil(Atmosphere.mirrorNarration(for: MirrorSession.Phase.contact, beat: 0),
                     "the ceiling's first beat must be silent")
        XCTAssertNil(Atmosphere.mirrorNarration(for: MirrorSession.Phase.contact),
                     "the default beat is 0 — silent by default, not accidentally speaking")
        XCTAssertNotNil(Atmosphere.mirrorNarration(for: MirrorSession.Phase.contact, beat: 1),
                        "the ceiling does speak from beat 1 onward")
        let lines = Atmosphere.mirrorScript(for: MirrorSession.Phase.contact)
        XCTAssertNotNil(Atmosphere.mirrorNarration(for: MirrorSession.Phase.contact, beat: 1 + lines.count),
                        "a full cycle past beat 1 must return to speaking, not back to silence")
    }

    /// A lingering pre-ceiling phase keeps breathing: beats advance through
    /// its lines and wrap, deterministically. Same guarantee as THE EYE.
    func testBeatsWrapDeterministicallyBeforeContact() {
        let lines = Atmosphere.mirrorScript(for: MirrorSession.Phase.clear)
        XCTAssertGreaterThan(lines.count, 1)
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.clear, beat: 0), lines.first)
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.clear, beat: lines.count), lines.first,
                       "one full cycle returns to the first line")
        XCTAssertEqual(Atmosphere.mirrorNarration(for: MirrorSession.Phase.clear, beat: -1), lines.last,
                       "negative beats wrap too — never a crash")
    }

    /// The motif must stay fogged/half-wiped before the ceiling — never the
    /// full phrase. `.independence` is where it first appears at all.
    func testMotifStaysFoggedBeforeContact() {
        for phase: MirrorSession.Phase in [.clear, .lag, .drift] {
            let text = Atmosphere.mirrorScript(for: phase).map(\.text).joined(separator: " ").lowercased()
            XCTAssertFalse(text.contains(Atmosphere.stillHereMotif),
                           "\(phase) is still deniable; the motif hasn't surfaced yet")
        }
        let independenceText = Atmosphere.mirrorScript(for: MirrorSession.Phase.independence)
            .map(\.text).joined(separator: " ").lowercased()
        XCTAssertFalse(independenceText.contains(Atmosphere.stillHereMotif),
                       "independence is fogged and partial, not the full scrawl")
        XCTAssertTrue(independenceText.contains("still"), "independence should carry a half-legible fragment")
    }

    /// "Full scrawl once at the ceiling, if at all": a player who reaches
    /// `.contact` and leaves before lingering never sees the phrase in full.
    func testFullScrawlIsAbsentWhenContactDwellIsShort() {
        for dwell in [0, Atmosphere.mirrorScrawlThresholdBeats - 1] {
            let text = Atmosphere.mirrorScript(for: MirrorSession.Phase.contact, contactDwellBeats: dwell)
                .map(\.text).joined(separator: " ").lowercased()
            XCTAssertFalse(text.contains(Atmosphere.stillHereMotif),
                           "dwell \(dwell): too soon for the full scrawl")
        }
    }

    /// A player who lingers at the ceiling is the only one who ever meets
    /// the phrase spelled out in full.
    func testFullScrawlAppearsOnlyWhenContactDwellReachesThreshold() {
        for dwell in [Atmosphere.mirrorScrawlThresholdBeats, Atmosphere.mirrorScrawlThresholdBeats + 5] {
            let lines = Atmosphere.mirrorScript(for: MirrorSession.Phase.contact, contactDwellBeats: dwell)
            let text = lines.map(\.text).joined(separator: " ").lowercased()
            XCTAssertTrue(text.contains(Atmosphere.stillHereMotif),
                          "dwell \(dwell): the full scrawl should be legible now")
            XCTAssertTrue(lines.allSatisfy { $0.voice == .poe }, "the ceiling stays in Poe's register throughout")
        }
        // Calling without contactDwellBeats at all must match dwell 0 exactly.
        XCTAssertEqual(Atmosphere.mirrorScript(for: MirrorSession.Phase.contact),
                       Atmosphere.mirrorScript(for: MirrorSession.Phase.contact, contactDwellBeats: 0))
    }

    /// Saying no stays a mercy here too — never a threat.
    func testDenialLineIsMerciful() {
        let denial = Atmosphere.mirrorNarration(for: MirrorSession.Phase.denied)?.text.lowercased() ?? ""
        XCTAssertTrue(denial.contains("sleep well"), "declining must always feel safe")
    }

    /// The design doc explicitly considered and rejected a fourth voice for
    /// this motif. Bulgakov belongs to THE EYE's arc; he must not leak in.
    func testBulgakovNeverAppearsInTheMirror() {
        let allPhases: [MirrorSession.Phase] = [.dormant, .seekingConsent, .denied, .clear, .lag, .drift, .independence, .contact, .released]
        for phase in allPhases {
            let voices = Set(Atmosphere.mirrorScript(for: phase, contactDwellBeats: 10).map(\.voice))
            XCTAssertFalse(voices.contains(.bulgakov), "\(phase) must not carry a bulgakov line")
        }
    }
}
