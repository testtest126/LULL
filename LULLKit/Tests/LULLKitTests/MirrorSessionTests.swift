import XCTest
@testable import LULLKit

/// THE MIRROR's logic, pinned exactly the way `EyeSessionTests` pins THE EYE:
/// consent comes first, "no" is respected and terminal, the ladder escalates
/// on a clock, the player can close the mirror from anywhere, and the
/// rendering constraints from the design doc (`docs/ideation/mirror-and-still-here.md`)
/// are real, checked invariants — not just prose.
final class MirrorSessionTests: XCTestCase {

    func testBeginAsksForConsentFirst() {
        var mirror = MirrorSession()
        XCTAssertEqual(mirror.phase, .dormant)
        XCTAssertFalse(mirror.wantsCamera, "nothing watches before consent")
        mirror.begin()
        XCTAssertEqual(mirror.phase, .seekingConsent)
        XCTAssertFalse(mirror.wantsCamera, "still nothing watches while merely asking")
    }

    func testDenialIsRespectedAndTerminal() {
        var mirror = MirrorSession()
        mirror.begin()
        mirror.consent(false)
        XCTAssertEqual(mirror.phase, .denied)
        XCTAssertFalse(mirror.wantsCamera)
        mirror.advance(by: 1000)          // time must not resurrect a denied session
        XCTAssertEqual(mirror.phase, .denied)
    }

    func testConsentOpensTheMirrorClear() {
        var mirror = MirrorSession()
        mirror.begin()
        mirror.consent(true)
        XCTAssertEqual(mirror.phase, .clear)
        XCTAssertTrue(mirror.wantsCamera, "the camera runs only once consented")
    }

    /// The full ladder, in order: clear → lag → drift → independence →
    /// contact. Nothing may be skipped, and nothing may run backwards.
    func testLadderEscalatesOnTheClockInOrder() {
        var mirror = MirrorSession(clearSeconds: 10, lagSeconds: 10, driftSeconds: 10, independenceSeconds: 10)
        mirror.begin(); mirror.consent(true)

        advance(&mirror, seconds: 9)
        XCTAssertEqual(mirror.phase, .clear, "clear until the first threshold")
        advance(&mirror, seconds: 2)
        XCTAssertEqual(mirror.phase, .lag, "then it starts to lag")
        advance(&mirror, seconds: 10)
        XCTAssertEqual(mirror.phase, .drift, "then it drifts")
        advance(&mirror, seconds: 10)
        XCTAssertEqual(mirror.phase, .independence, "then it acts on its own")
        advance(&mirror, seconds: 10)
        XCTAssertEqual(mirror.phase, .contact, "then contact — the ceiling")
    }

    func testReleaseClosesTheMirrorFromAnyPhase() {
        for setup in [
            { (m: inout MirrorSession) in m.begin() },
            { (m: inout MirrorSession) in m.begin(); m.consent(true) },
            { (m: inout MirrorSession) in m.begin(); m.consent(true); m.advance(by: 999) },
        ] {
            var mirror = MirrorSession(clearSeconds: 1, lagSeconds: 1, driftSeconds: 1, independenceSeconds: 1)
            setup(&mirror)
            mirror.release()
            XCTAssertEqual(mirror.phase, .released, "the player can always close the mirror")
            XCTAssertFalse(mirror.wantsCamera, "and the camera stops the instant they do")
        }
    }

    func testBackgroundingCannotFastForwardTheHorror() {
        var mirror = MirrorSession(clearSeconds: 10, lagSeconds: 10, driftSeconds: 10, independenceSeconds: 10)
        mirror.begin(); mirror.consent(true)
        mirror.advance(by: 10_000)        // one giant jump (app was backgrounded) is clamped
        XCTAssertEqual(mirror.phase, .clear, "a single huge dt cannot skip the whole ladder")
    }

    /// `elapsed` marks *when* contact was reached and then holds; `contactElapsed`
    /// is the separate, ongoing count of how long the player has stayed — same
    /// contract as `EyeSession.elapsed` / `awakeElapsed`.
    func testContactElapsedTracksTimeSpentAtTheCeilingSeparatelyFromElapsed() {
        var mirror = MirrorSession(clearSeconds: 5, lagSeconds: 5, driftSeconds: 5, independenceSeconds: 5)
        mirror.begin(); mirror.consent(true)
        XCTAssertEqual(mirror.contactElapsed, 0, "hasn't reached the ceiling yet")

        advance(&mirror, seconds: 20)
        XCTAssertEqual(mirror.phase, .contact)
        let elapsedAtContact = mirror.elapsed
        XCTAssertEqual(mirror.contactElapsed, 0, "just arrived; hasn't lingered yet")

        advance(&mirror, seconds: 7)
        XCTAssertEqual(mirror.elapsed, elapsedAtContact,
                       "elapsed still marks when contact was reached, not how long since")
        XCTAssertEqual(mirror.contactElapsed, 7, "contactElapsed keeps counting while the player stays")
    }

    /// The design doc: reflection starts exact ("clear"), then the delay
    /// grows through lag and drift — never shrinks, never resets mid-ladder.
    func testFrameDelayGrowsThroughTheLiveFeedPhases() {
        let clear = MirrorSession()
        XCTAssertEqual(clear.frameDelay, 0, "clear must be an exact, undelayed reflection")

        var lag = MirrorSession(clearSeconds: 1, lagSeconds: 100, driftSeconds: 100, independenceSeconds: 100)
        lag.begin(); lag.consent(true); advance(&lag, seconds: 2)
        XCTAssertEqual(lag.phase, .lag)

        var drift = lag
        advance(&drift, seconds: 100)
        XCTAssertEqual(drift.phase, .drift)

        XCTAssertGreaterThan(lag.frameDelay, clear.frameDelay, "lag must delay more than clear")
        XCTAssertGreaterThan(drift.frameDelay, lag.frameDelay, "drift must delay more than lag")
    }

    /// The hard rendering constraint from the doc: "anything past drift is a
    /// canned authored asset caught on look-back, never live generation."
    func testAuthoredAssetIsRequiredOnlyPastDrift() {
        var mirror = MirrorSession(clearSeconds: 1, lagSeconds: 1, driftSeconds: 1, independenceSeconds: 1)
        mirror.begin(); mirror.consent(true)
        XCTAssertFalse(mirror.requiresAuthoredAsset, "clear is live feed")
        advance(&mirror, seconds: 1)
        XCTAssertEqual(mirror.phase, .lag)
        XCTAssertFalse(mirror.requiresAuthoredAsset, "lag is still live feed")
        advance(&mirror, seconds: 1)
        XCTAssertEqual(mirror.phase, .drift)
        XCTAssertFalse(mirror.requiresAuthoredAsset, "drift is still live feed")
        advance(&mirror, seconds: 1)
        XCTAssertEqual(mirror.phase, .independence)
        XCTAssertTrue(mirror.requiresAuthoredAsset, "independence must never be live-generated")
        advance(&mirror, seconds: 1)
        XCTAssertEqual(mirror.phase, .contact)
        XCTAssertTrue(mirror.requiresAuthoredAsset, "contact must never be live-generated")
    }

    /// THE MIRROR reuses the existing camera sensor and nothing else — the
    /// allow-list itself must be untouched by this mechanic.
    func testNoNewSensorWasIntroduced() {
        XCTAssertEqual(Sensor.allCases, [.camera, .microphone, .notifications, .haptics, .motion],
                       "THE MIRROR must not add, rename, or reorder a Sensor case")
        var ledger = ConsentLedger()
        XCTAssertFalse(ledger.mayUse(.camera))
        ledger.grant(.camera)
        XCTAssertTrue(ledger.mayUse(.camera), "the mirror is gated by the same camera consent as THE EYE")
    }

    /// Drives the clock in small steps, the way the app's timer does.
    private func advance(_ mirror: inout MirrorSession, seconds: TimeInterval) {
        var remaining = seconds
        while remaining > 0 {
            let step = min(1, remaining)
            mirror.advance(by: step)
            remaining -= step
        }
    }
}
