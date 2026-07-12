import SwiftUI
import LULLKit

/// The honest consent step: the reason, in plain words, *before* the OS prompt —
/// and a real way to say no.
struct ConsentView: View {
    @ObservedObject var model: GameModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text("LULL")
                .font(Theme.title).tracking(8)
                .foregroundStyle(Theme.bone)
            Text("a sleep aid")
                .font(Theme.label).textCase(.uppercase).tracking(4)
                .foregroundStyle(Theme.faint)

            // The threshold, in Kafka's register: a faint epigraph, clearly
            // atmosphere. The honest consent copy below is never touched by it.
            if let epigraph = Atmosphere.narration(for: .seekingConsent)?.text {
                Text(epigraph)
                    .font(.system(.footnote, design: .serif)).italic()
                    .foregroundStyle(Theme.faint)
                    .padding(.top, 6)
            }

            Text(Sensor.camera.rationale)
                .font(Theme.body)
                .foregroundStyle(Theme.dim)
                .padding(.top, 10)

            Text("Nothing is recorded. Nothing leaves your phone. You can close the eye at any time.")
                .font(.footnote)
                .foregroundStyle(Theme.faint)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    Task { await model.allowTheEye() }
                } label: {
                    Text("Let it watch")
                        .font(Theme.label).textCase(.uppercase).tracking(3)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .foregroundStyle(Theme.bone)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Theme.red.opacity(0.55)))
                }
                Button("Not tonight") { model.declineTheEye() }
                    .font(Theme.label).textCase(.uppercase).tracking(3)
                    .foregroundStyle(Theme.faint)
            }
        }
        .padding(28)
        .onAppear { model.begin() }
    }
}
