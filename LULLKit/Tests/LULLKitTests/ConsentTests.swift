import XCTest
@testable import LULLKit

/// The one rule, in tests: default-deny, grants are per-sensor, revoke is
/// immediate, and the panic switch clears everything. These invariants ship
/// green from commit one and must never regress — the game's ethics are not a
/// feature to be traded away later.
final class ConsentTests: XCTestCase {

    func testDefaultIsDeny() {
        let ledger = ConsentLedger()
        for sensor in Sensor.allCases {
            XCTAssertFalse(ledger.mayUse(sensor),
                           "\(sensor) must not be usable without explicit consent")
        }
    }

    func testGrantIsScopedToOneSensor() {
        var ledger = ConsentLedger()
        ledger.grant(.camera)
        XCTAssertTrue(ledger.mayUse(.camera))
        XCTAssertFalse(ledger.mayUse(.microphone),
                       "granting one sensor grants only that one")
    }

    func testRevokeStopsAccessImmediately() {
        var ledger = ConsentLedger(granted: [.camera, .microphone])
        ledger.revoke(.camera)
        XCTAssertFalse(ledger.mayUse(.camera), "revoked access stops at once")
        XCTAssertTrue(ledger.mayUse(.microphone), "revoking one leaves the rest")
    }

    func testPanicRevokeAllClearsEverything() {
        var ledger = ConsentLedger(granted: Set(Sensor.allCases))
        ledger.revokeAll()
        XCTAssertTrue(ledger.activeSensors.isEmpty,
                      "the panic switch withdraws all consent")
    }

    func testEverySensorHasAnHonestRationale() {
        for sensor in Sensor.allCases {
            XCTAssertFalse(sensor.rationale.isEmpty,
                           "\(sensor) must explain itself before the OS prompt")
        }
    }
}
