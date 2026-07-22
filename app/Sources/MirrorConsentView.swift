import SwiftUI
import LULLKit

/// THE MIRROR's threshold — the same honest, refusable shape as
/// `ConsentView`, reusing the identical `Sensor.camera` rationale (this
/// mechanic asks for nothing new).
struct MirrorConsentView: View {
    @ObservedObject var model: MirrorModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text("THE MIRROR")
                .font(Theme.title).tracking(4)
                .foregroundStyle(Theme.bone)
            Text("draft — for review")
                .font(Theme.label).textCase(.uppercase).tracking(4)
                .foregroundStyle(Theme.faint)

            if let epigraph = Atmosphere.mirrorNarration(for: .seekingConsent)?.text {
                Text(epigraph)
                    .font(.system(.footnote, design: .serif)).italic()
                    .foregroundStyle(Theme.faint)
                    .padding(.top, 6)
            }

            Text(Sensor.camera.rationale)
                .font(Theme.body)
                .foregroundStyle(Theme.dim)
                .padding(.top, 10)

            Text("Nothing is recorded. Nothing leaves your phone. You can close the mirror at any time.")
                .font(.footnote)
                .foregroundStyle(Theme.faint)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    Task { await model.allowTheMirror() }
                } label: {
                    Text("Let it show you")
                        .font(Theme.label).textCase(.uppercase).tracking(3)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .foregroundStyle(Theme.bone)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Theme.red.opacity(0.55)))
                }
                Button("Not tonight") { model.declineTheMirror() }
                    .font(Theme.label).textCase(.uppercase).tracking(3)
                    .foregroundStyle(Theme.faint)
            }
        }
        .padding(28)
        .onAppear { model.begin() }
    }
}
