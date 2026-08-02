// xcode: set sdk=iOS

import SwiftUI
import LULLKit

@main
struct LULLApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .statusBarHidden(true)
        }
    }
}

/// Routes on the pure `EyeSession` phase — the UI is a function of the state
/// machine, nothing more.
struct RootView: View {
    @StateObject private var model = GameModel()

    var body: some View {
        ZStack {
            // Experimental SpriteKit atmosphere layer (see AtmosphereScene.swift).
            // Purely additive: replace with `Theme.ink.ignoresSafeArea()` to
            // remove it, nothing downstream depends on it.
            AtmosphereBackground()
            switch model.eye.phase {
            case .dormant, .seekingConsent:
                ConsentView(model: model)
            case .watching, .noticing, .awake:
                EyeView(model: model)
            case .denied:
                EndingView(text: Atmosphere.narration(for: .denied)?.text ?? "")
            case .released:
                EndingView(text: Atmosphere.narration(for: .released)?.text ?? "")
            }
        }
        .animation(.easeInOut(duration: 0.7), value: model.eye.phase)
    }
}

struct EndingView: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(.title3, design: .serif))
            .foregroundStyle(Theme.dim)
            .multilineTextAlignment(.center)
            .padding()
    }
}
