import SwiftUI

/// Empty state shown when no Steam key is configured. The rest of the app keeps working.
struct SteamNotConfiguredView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Steam Not Connected", systemImage: "cloud.slash")
        } description: {
            Text("Add your Steam Web API key and SteamID64 to import your Steam library and playtime.")
        } actions: {
            SettingsLink { Text("Open Settings…") }
        }
    }
}

#Preview {
    SteamNotConfiguredView()
}
