import XCTest
@testable import LULLKit

/// The vertical slice's logic, pinned: consent comes first, "no" is respected
/// and terminal, the dread escalates on a clock, and the player can close the
/// eye from anywhere. All without a camera — the mechanic is provable before a
/// single pixel is drawn.
final class EyeSessionTests: XCTestCase {

    func testBeginAsksForConsentFirst() {
        var eye = EyeSession()
        XCTAssertEqual(eye.phase, .dormant)
        XCTAssertFalse(eye.wantsCamera, "nothing watches before consent")
        eye.begin()
        XCTAssertEqual(eye.phase, .seekingConsent)
        XCTAssertFalse(eye.wantsCamera, "still nothing watches while merely asking")
    }

    func testDenialIsRespectedAndTerminal() {
        var eye = EyeSession()
        eye.begin()
        eye.consent(false)
        XCTAssertEqual(eye.phase, .denied)
        XCTAssertFalse(eye.wantsCamera)
        eye.advance(by: 1000)          // time must not resurrect a denied session
        XCTAssertEqual(eye.phase, .denied)
    }

    func testConsentOpensTheEyeCalm() {
        var eye = EyeSession()
        eye.begin()
        eye.consent(true)
        XCTAssertEqual(eye.phase, .watching)
        XCTAssertTrue(eye.wantsCamera, "the camera runs only once consented")
    }

    func testDreadEscalatesOnTheClock() {
        var eye = EyeSession(calmSeconds: 10, noticingSeconds: 10)
        eye.begin(); eye.consent(true)
        advance(&eye, seconds: 9)
        XCTAssertEqual(eye.phase, .watching, "calm until the first beat")
        advance(&eye, seconds: 2)
        XCTAssertEqual(eye.phase, .noticing, "then it starts to notice")
        advance(&eye, seconds: 10)
        XCTAssertEqual(eye.phase, .awake, "then it stops behaving like software")
    }

    func testReleaseClosesTheEyeFromAnyPhase() {
        for setup in [
            { (e: inout EyeSession) in e.begin() },
            { (e: inout EyeSession) in e.begin(); e.consent(true) },
            { (e: inout EyeSession) in e.begin(); e.consent(true); e.advance(by: 999) },
        ] {
            var eye = EyeSession(calmSeconds: 1, noticingSeconds: 1)
            setup(&eye)
            eye.release()
            XCTAssertEqual(eye.phase, .released, "the player can always close the eye")
            XCTAssertFalse(eye.wantsCamera, "and the camera stops the instant they do")
        }
    }

    func testBackgroundingCannotFastForwardTheHorror() {
        var eye = EyeSession(calmSeconds: 10, noticingSeconds: 10)
        eye.begin(); eye.consent(true)
        eye.advance(by: 10_000)        // one giant jump (app was backgrounded) is clamped
        XCTAssertEqual(eye.phase, .watching, "a single huge dt cannot skip the whole arc")
    }

    /// Drives the clock in small steps, the way the app's timer does.
    private func advance(_ eye: inout EyeSession, seconds: TimeInterval) {
        var remaining = seconds
        while remaining > 0 {
            let step = min(1, remaining)
            eye.advance(by: step)
            remaining -= step
        }
    }
}
