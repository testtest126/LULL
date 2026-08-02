import SpriteKit

/// A pure visual atmosphere layer: slow drifting fog, faint dust, a soft
/// vignette, an ambient pulse, and a rare flicker. It owns no state, reads no
/// sensor, and knows nothing about consent or `EyeSession` — it is decoration
/// that sits *behind* the real UI, not part of it. Delete this file and the
/// app behaves exactly as it did before.
final class AtmosphereScene: SKScene {

    // Palette mirrors `Theme.swift` by eye, not by reference — this file is
    // meant to be liftable/removable without touching the app's shared theme.
    private static let ink  = SKColor(red: 0.027, green: 0.031, blue: 0.039, alpha: 1)
    private static let dim  = SKColor(red: 0.510, green: 0.522, blue: 0.549, alpha: 1)
    private static let red  = SKColor(red: 0.733, green: 0.231, blue: 0.231, alpha: 1)

    private var vignette: SKSpriteNode?
    private var pulse: SKShapeNode?

    override func didMove(to view: SKView) {
        backgroundColor = Self.ink
        scaleMode = .resizeFill
        isUserInteractionEnabled = false

        addFog()
        addDust()
        addVignette()
        addPulse()
        scheduleFlicker()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        vignette?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        vignette?.size = size
        pulse?.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
    }

    // MARK: - Fog

    /// Slow, near-static haze drifting sideways — the sense of a room that
    /// is not quite empty, rather than any recognizable shape.
    private func addFog() {
        let fog = SKEmitterNode()
        fog.particleTexture = Self.softTexture
        fog.particleBirthRate = 0.5
        fog.particleLifetime = 46
        fog.particleLifetimeRange = 14
        fog.particlePositionRange = CGVector(dx: 0, dy: 900)
        fog.particleSpeed = 5
        fog.particleSpeedRange = 3
        fog.emissionAngle = 0
        fog.emissionAngleRange = .pi / 8
        fog.particleAlpha = 0.05
        fog.particleAlphaRange = 0.03
        fog.particleAlphaSpeed = -0.0015
        fog.particleScale = 7
        fog.particleScaleRange = 3
        fog.particleScaleSpeed = 0.03
        fog.particleColor = Self.dim
        fog.particleColorBlendFactor = 1
        fog.particleBlendMode = .add
        fog.position = CGPoint(x: -60, y: 0)
        fog.zPosition = -6
        fog.advanceSimulationTime(60) // don't start on an empty frame
        addChild(fog)
    }

    // MARK: - Dust

    /// Fine motes drifting upward, barely visible — the kind of thing you
    /// only notice once you've been looking at the dark for a while.
    private func addDust() {
        let dust = SKEmitterNode()
        dust.particleTexture = Self.softTexture
        dust.particleBirthRate = 1.2
        dust.particleLifetime = 22
        dust.particleLifetimeRange = 8
        dust.particlePositionRange = CGVector(dx: 900, dy: 0)
        dust.particleSpeed = 8
        dust.particleSpeedRange = 4
        dust.emissionAngle = .pi / 2
        dust.emissionAngleRange = .pi / 10
        dust.particleAlpha = 0.10
        dust.particleAlphaRange = 0.06
        dust.particleAlphaSpeed = -0.01
        dust.particleScale = 0.06
        dust.particleScaleRange = 0.04
        dust.particleColor = Self.dim
        dust.particleColorBlendFactor = 1
        dust.particleBlendMode = .add
        dust.position = CGPoint(x: size.width / 2, y: -20)
        dust.zPosition = -5
        dust.advanceSimulationTime(20)
        addChild(dust)
    }

    // MARK: - Vignette

    /// A static darkening toward the edges — pulls focus to the center of
    /// the screen the way a room feels smaller once your eyes adjust.
    private func addVignette() {
        let node = SKSpriteNode(texture: Self.vignetteTexture)
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        node.size = size
        node.zPosition = 10
        node.blendMode = .alpha
        node.alpha = 0.9
        addChild(node)
        vignette = node
    }

    // MARK: - Pulse

    /// A slow, barely-there red glow breathing in and out — not quite a
    /// heartbeat, just enough that the eye catches motion where there
    /// shouldn't be any.
    private func addPulse() {
        let glow = SKShapeNode(circleOfRadius: 140)
        glow.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        glow.fillColor = Self.red
        glow.strokeColor = .clear
        glow.alpha = 0.035
        glow.blendMode = .add
        glow.zPosition = -4
        glow.glowWidth = 60
        addChild(glow)
        pulse = glow

        let breathe = SKAction.sequence([
            SKAction.group([
                SKAction.fadeAlpha(to: 0.09, duration: 5.5),
                SKAction.scale(to: 1.12, duration: 5.5),
            ]),
            SKAction.group([
                SKAction.fadeAlpha(to: 0.035, duration: 5.5),
                SKAction.scale(to: 1.0, duration: 5.5),
            ]),
        ])
        breathe.timingMode = .easeInEaseOut
        glow.run(.repeatForever(breathe))
    }

    // MARK: - Flicker

    /// A rare, quick darkening — the visual equivalent of a held breath.
    /// Infrequent and brief on purpose: restraint is what makes it land.
    private func scheduleFlicker() {
        let flash = SKSpriteNode(color: .black, size: CGSize(width: 4000, height: 4000))
        flash.alpha = 0
        flash.zPosition = 20
        flash.blendMode = .alpha
        addChild(flash)

        let waitRange = SKAction.wait(forDuration: 14, withRange: 10)
        let flicker = SKAction.sequence([
            SKAction.fadeAlpha(to: CGFloat.random(in: 0.2...0.4), duration: 0.04),
            SKAction.fadeAlpha(to: 0, duration: 0.10),
            SKAction.wait(forDuration: 0.08),
            SKAction.fadeAlpha(to: CGFloat.random(in: 0.08...0.18), duration: 0.03),
            SKAction.fadeAlpha(to: 0, duration: 0.12),
        ])
        flash.run(.repeatForever(.sequence([waitRange, flicker])))
    }

    // MARK: - Generated textures

    /// A soft, radially-faded circle — used for both fog and dust so neither
    /// reads as a hard-edged sprite.
    private static let softTexture: SKTexture = {
        let size = CGSize(width: 128, height: 128)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let colors = [UIColor.white.withAlphaComponent(0.9).cgColor,
                          UIColor.white.withAlphaComponent(0).cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                             colors: colors, locations: [0, 1]) else { return }
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            ctx.cgContext.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                                              endCenter: center, endRadius: size.width / 2,
                                              options: [])
        }
        return SKTexture(image: image)
    }()

    /// A dark-to-clear radial gradient covering the full scene, used to fake
    /// a vignette without a shader.
    private static let vignetteTexture: SKTexture = {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let colors = [UIColor.black.withAlphaComponent(0).cgColor,
                          UIColor.black.withAlphaComponent(0).cgColor,
                          UIColor.black.withAlphaComponent(0.85).cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                             colors: colors, locations: [0, 0.55, 1]) else { return }
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            ctx.cgContext.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                                              endCenter: center, endRadius: size.width * 0.75,
                                              options: [])
        }
        return SKTexture(image: image)
    }()
}
