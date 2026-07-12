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
    private var line: String {
        switch phase {
        case .watching: return "close your eyes.\nlet it watch for you."
        case .noticing: return "you're still awake.\nso is it."
        case .awake:    return "it knows your face now."
        default:        return ""
        }
    }
}
