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
}
