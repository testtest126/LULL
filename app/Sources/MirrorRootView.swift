import SwiftUI
import LULLKit

/// Routes on the pure `MirrorSession` phase, exactly as `RootView` routes on
/// `EyeSession` — the UI is a function of the state machine, nothing more.
///
/// Not referenced from `LULLApp`'s `@main` scene: THE MIRROR is a draft
/// mechanic under review, and swapping the shipped default away from THE EYE
/// is the owner's call to make, not something this PR decides on its own.
/// To try it on a real device ahead of that decision, swap `RootView()` for
/// `MirrorRootView()` in `LULLApp.swift` locally.
struct MirrorRootView: View {
    @StateObject private var model = MirrorModel()

    var body: some View {
        ZStack {
            Theme.ink.ignoresSafeArea()
            switch model.mirror.phase {
            case .dormant, .seekingConsent:
                MirrorConsentView(model: model)
            case .clear, .lag, .drift, .independence, .contact:
                MirrorView(model: model)
            case .denied:
                EndingView(text: Atmosphere.mirrorNarration(for: .denied)?.text ?? "")
            case .released:
                EndingView(text: Atmosphere.mirrorNarration(for: .released)?.text ?? "")
            }
        }
        .animation(.easeInOut(duration: 0.7), value: model.mirror.phase)
    }
}
