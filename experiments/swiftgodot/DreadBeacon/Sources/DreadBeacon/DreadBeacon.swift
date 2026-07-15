import Foundation
import SwiftGodot

/// A minimal spike node: does the SwiftGodot toolchain compile and register a
/// custom class at all? Everything here is throwaway — no dependency on
/// LULLKit, no shared code with the shippable app. See ../ASSESSMENT.md.
///
/// LULL-flavored only in spirit: a light that pulses on a slow "dread beat"
/// and dims the longer it runs, echoing the pacing instinct in
/// `LULLKit/Sources/LULLKit/Atmosphere.swift` (a 9-second beat) and
/// `EyeSession` (calm, then noticing, then awake) — reimplemented here from
/// scratch for the spike, not imported.
@Godot
class DreadBeacon: Node3D {
    /// Same slow-breath cadence as `Atmosphere.beatSeconds`.
    private let beatSeconds: Double = 9
    private var elapsed: Double = 0
    private var light: OmniLight3D?

    override func _ready() {
        let omni = OmniLight3D()
        omni.lightEnergy = 0.2
        omni.lightColor = Color(r: 0.9, g: 0.15, b: 0.15, a: 1)
        addChild(node: omni)
        light = omni
    }

    override func _process(delta: Double) {
        elapsed += delta
        guard let light else { return }
        let phase = elapsed.truncatingRemainder(dividingBy: beatSeconds) / beatSeconds
        let pulse = 0.5 + 0.5 * sin(phase * 2 * Double.pi)
        // Decays toward a dim, held glow — the room's light "going", the way
        // Atmosphere's beckett lines describe it, not blinking out.
        let decay = max(0.15, 1.0 - elapsed / 120.0)
        light.lightEnergy = pulse * decay * 1.5
    }
}
