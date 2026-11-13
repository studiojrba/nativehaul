import SwiftUI

/// Settings → Appearance: the Light/Dark choice (spec §1.4, §3.5). Applies instantly and is remembered.
struct AppearanceSettingsView: View {
    /// The app's appearance.
    @Bindable var controller: AppearanceController

    var body: some View {
        Form {
            Section {
                LabeledContent("Appearance") {
                    SegmentedPill(
                        options: AppearancePreference.allCases,
                        selection: $controller.preference,
                        title: \.title,
                        symbol: { $0.symbolName }
                    )
                }
            } footer: {
                Text("Dark is the same room in the evening. Your choice applies everywhere, straight away.")
                    .font(Typeface.sans(TypeStyle.Size.small))
                    .foregroundStyle(Theme.inkMute)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(Theme.paper)
    }
}

#Preview {
    AppearancePreviewPair {
        AppearanceSettingsView(controller: .preview)
    }
}
