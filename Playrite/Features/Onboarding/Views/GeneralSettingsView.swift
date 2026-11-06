import SwiftUI

/// Settings → General: re-run the first-run walkthrough.
struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Section {
                Button("Run setup again", systemImage: "sparkles") { OnboardingRequest.post() }
            } footer: {
                Text("Walks through finding games, Steam, CrossOver and Switch ports. Everything is optional, and "
                    + "Retriever works without it.")
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettingsView()
}
