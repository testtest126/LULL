import SwiftUI
import LULLKit

/// What the mirror shows — a thin view over the tested `MirrorSession`
/// ladder. **Needs a real device to actually see anything**: the Simulator's
/// front camera is a no-op (same caveat as `EyeView`), so this renders the
/// phase/motif logic correctly but shows an empty preview there.
///
/// Deliberately *not* wired into `RootView`/`LULLApp` yet — this is a draft
/// mechanic the owner reviews before it becomes part of the shipped flow.
struct MirrorView: View {
    @ObservedObject var model: MirrorModel

    private var phase: MirrorSession.Phase { model.mirror.phase }

    var body: some View {
        ZStack {
            reflection
                .ignoresSafeArea()
                .overlay(Theme.ink.opacity(vignette).ignoresSafeArea())

            VStack {
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(Theme.red).frame(width: 7, height: 7)
                        Text(phase.rawValue)
                            .font(Theme.label).textCase(.uppercase).tracking(2)
                            .foregroundStyle(Theme.dim)
                    }
                    Spacer()
                    Button {
                        model.closeTheMirror()
                    } label: {
                        Text("close the mirror")
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

    /// The reflection itself. Below `.independence`, this is the player's
    /// own live feed, desaturated and contrast-crushed, with `frameDelay`
    /// noting how far behind it should lag (true ring-buffered delay is
    /// real AVFoundation sample-buffer work — out of scope for this thin
    /// stub; the value is exposed and tested in `MirrorSession` so the app
    /// layer has what it needs to implement it later). From `.independence`
    /// on, `requiresAuthoredAsset` is `true` and this branch structurally
    /// never touches the live camera session — a placeholder stands in for
    /// the pre-authored asset the design doc calls for, so "never live
    /// generation" holds even here in the stub, not just in a comment.
    @ViewBuilder
    private var reflection: some View {
        if model.mirror.requiresAuthoredAsset {
            AuthoredAssetPlaceholder()
        } else {
            CameraPreview(session: model.camera.session)
                .saturation(0)
                .contrast(1.35)
                .brightness(-0.08)
                .opacity(previewOpacity)
        }
    }

    /// The line comes from LULLKit's tested narration layer. `.contact`'s
    /// very first beat is a deliberate silence (`mirrorNarration` returns
    /// `nil`) — that renders here as simply no text, which is the point.
    private var line: String {
        if phase == .contact {
            let dwellBeats = Atmosphere.beat(forElapsed: model.mirror.contactElapsed)
            return Atmosphere.mirrorNarration(for: phase, beat: dwellBeats, contactDwellBeats: dwellBeats)?.text ?? ""
        }
        let beat = Atmosphere.beat(forElapsed: model.mirror.elapsed)
        return Atmosphere.mirrorNarration(for: phase, beat: beat)?.text ?? ""
    }

    private var previewOpacity: Double {
        switch phase {
        case .clear: return 0.5
        case .lag: return 0.4
        case .drift: return 0.3
        default: return 0.5
        }
    }

    private var vignette: Double {
        switch phase {
        case .clear: return 0.35
        case .lag: return 0.4
        case .drift: return 0.5
        case .independence: return 0.55
        case .contact: return 0.6
        default: return 0.35
        }
    }
}

/// Stands in for the pre-authored asset the design doc calls for from
/// `.independence` onward. Intentionally inert and camera-free — a real
/// build swaps this for an actual authored image/video asset; what matters
/// structurally is that nothing here can read a live camera frame.
private struct AuthoredAssetPlaceholder: View {
    var body: some View {
        Rectangle()
            .fill(Theme.ink)
            .overlay(
                Text("[ authored asset — not yet supplied ]")
                    .font(Theme.label)
                    .foregroundStyle(Theme.faint)
            )
    }
}
