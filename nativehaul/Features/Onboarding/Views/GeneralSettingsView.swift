import SwiftUI

/// Settings → General: re-run the first-run walkthrough.
struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Section {
                Button("Run setup again", systemImage: "sparkles") { OnboardingRequest.post() }
            } footer: {
                Text("Walks through finding your Switch ports, ROM folders and emulators. Everything is optional, and "
                    + "nativehaul works without it.")
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettingsView()
}
