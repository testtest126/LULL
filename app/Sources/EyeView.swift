import SwiftUI
import LULLKit

/// What the eye sees — degraded, never shown clean — with the dread escalating
/// on the `EyeSession` clock, and a "close the eye" control that is always there.
struct EyeView: View {
    @ObservedObject var model: GameModel

    private var phase: EyeSession.Phase { model.eye.phase }

    var body: some View {
        ZStack {
            CameraPreview(session: model.camera.session)
                .ignoresSafeArea()
                .saturation(0)
                .blur(radius: phase == .awake ? 1.5 : 4)
                .opacity(previewOpacity)
                .overlay(Theme.ink.opacity(vignette).ignoresSafeArea())

            GrainOverlay(opacity: grainOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack {
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(Theme.red).frame(width: 7, height: 7)
                        Text("watching")
                            .font(Theme.label).textCase(.uppercase).tracking(2)
                            .foregroundStyle(Theme.dim)
                    }
                    Spacer()
                    Button {
                        model.closeTheEye()
                    } label: {
                        Text("close the eye")
                            .font(Theme.label).textCase(.uppercase).tracking(2)
                            .foregroundStyle(Theme.faint)
                    }
                }

                Spacer()

                Text(line)
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(Theme.bone)
                    .multilineTextAlignment(.center)
                    .opacity(0.9)
                    .padding(.bottom, 44)
                    .animation(.easeInOut(duration: 1.4), value: line)
            }
            .padding(28)
        }
    }

    /// The line comes from LULLKit's tested narration layer — Beckett while it is
    /// calm, Poe as it wakes — advancing on the same clock that drives the dread.
    /// `elapsed` stops advancing once `awake` is reached (it marks when the
    /// ceiling arrived, not how long since), so `awake` beats — and which of
    /// Bulgakov's two pairings plays — instead follow `awakeElapsed`, the
    /// separate count of how long the player has stayed at the ceiling.
    private var line: String {
        if phase == .awake {
            let dwellBeats = Atmosphere.beat(forElapsed: model.eye.awakeElapsed)
            return Atmosphere.narration(for: phase, beat: dwellBeats, dwellBeats: dwellBeats)?.text ?? ""
        }
        let beat = Atmosphere.beat(forElapsed: model.eye.elapsed)
        return Atmosphere.narration(for: phase, beat: beat)?.text ?? ""
    }

    private var previewOpacity: Double {
        switch phase {
        case .watching: return 0.22
        case .noticing: return 0.5
        default:        return 0.8   // awake
        }
    }
    private var vignette: Double {
        switch phase {
        case .watching: return 0.55
        case .noticing: return 0.32
        default:        return 0.15
        }
    }

    /// Faint film-grain over the preview — the closest LULL comes to a
    /// low-light/VHS texture. Intensifies slightly on the same phase ladder
    /// as `previewOpacity`/`vignette`; kept low enough to read as texture,
    /// never a wash over the image.
    private var grainOpacity: Double {
        switch phase {
        case .watching: return 0.03
        case .noticing: return 0.05
        default:        return 0.08   // awake
        }
    }
}

/// A faint, phase-scaled grain layer — no bundled noise asset, no new
/// dependency: a coarse grid of random-opacity cells, drawn with `Canvas`.
/// Blended with `.screen`, not `.overlay` — LULL's palette is near-black
/// (`Theme.ink`) most of the time, and `.overlay`/`.multiply` barely lighten
/// a near-black base at all; `.screen` adds light instead, the way real
/// grain/sensor noise reads as scattered specks even in a dark scene.
/// Redraws on a modest cadence (not every frame) when animating; when
/// Reduce Motion is on, it draws once, from a fixed seed, and never redraws
/// — texture without a flicker.
private struct GrainOverlay: View {
    var opacity: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                GrainCanvas(seed: 1)
            } else {
                TimelineView(.periodic(from: .now, by: 0.09)) { timeline in
                    GrainCanvas(seed: UInt64(timeline.date.timeIntervalSinceReferenceDate * 10))
                }
            }
        }
        .blendMode(.screen)
        .opacity(opacity)
    }
}

/// The grain itself: a fine grid of sparse, randomly-lit cells — closer to
/// sensor noise than to blocky static. Only a fraction of cells are drawn
/// per pass, and drawing exactly that many (rather than rolling the dice on
/// every cell and rejecting most of them) keeps the redraw cost bounded and
/// small regardless of grid resolution. Deterministic from `seed`, so the
/// same seed always draws the same field — no bundled asset needed.
private struct GrainCanvas: View {
    let seed: UInt64
    private let gridColumns = 180
    private let coverage = 0.12

    var body: some View {
        Canvas { context, size in
            guard size.width > 0, size.height > 0 else { return }
            var rng = SeededGenerator(seed: seed)
            let cell = size.width / CGFloat(gridColumns)
            guard cell > 0 else { return }
            let columns = gridColumns
            let rows = Int(size.height / cell) + 1
            let dotCount = Int(Double(columns * rows) * coverage)
            for _ in 0..<dotCount {
                let column = Int.random(in: 0..<columns, using: &rng)
                let row = Int.random(in: 0..<rows, using: &rng)
                let shade = Double.random(in: 0.2...0.85, using: &rng)
                let rect = CGRect(x: CGFloat(column) * cell, y: CGFloat(row) * cell, width: cell, height: cell)
                context.fill(Path(rect), with: .color(.white.opacity(shade)))
            }
        }
    }
}

/// A tiny deterministic RNG (splitmix64) so a given seed always draws the
/// same grain field. Not for anything security-sensitive — purely so Reduce
/// Motion's single static frame is reproducible rather than relying on
/// `SystemRandomNumberGenerator`'s non-determinism.
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
