import SwiftUI
import SpriteKit

/// Bridges `AtmosphereScene` into SwiftUI as a background layer. Purely
/// additive: it renders behind whatever content sits on top of it in a
/// `ZStack` and holds no reference to `GameModel`, consent, or the camera.
struct AtmosphereBackground: View {
    private let scene: SKScene = {
        let scene = AtmosphereScene()
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}
