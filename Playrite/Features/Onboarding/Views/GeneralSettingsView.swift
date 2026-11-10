import SwiftUI

/// Settings → General: take the guided tour again (ADR 0040).
struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Section {
                Button("Run setup again", systemImage: "sparkles") { OnboardingRequest.post() }
            } footer: {
                Text("Retriever shows you around again: your library, a game page, Builds and Steam. Every step "
                    + "is optional, and Retriever works without it.")
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettingsView()
}
