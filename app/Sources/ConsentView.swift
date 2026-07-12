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
