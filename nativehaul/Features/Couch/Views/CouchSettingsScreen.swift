import SwiftUI

/// Couch Settings (ADR 0058, undesigned — derived from §3.5): the couch-relevant groups only — Appearance, Audio
/// (music, volume, interface sounds), Couch mode ("Open in", controller rumble) and Exit to desktop. Everything that
/// needs typing or a file picker (folders, players, API keys) stays at the desk, and the note says so.
struct CouchSettingsScreen: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    private typealias Metrics = CouchLayout.Settings

    var body: some View {
        let scale = viewModel.scale
        let shape = RoundedRectangle(cornerRadius: scale(Metrics.radius), style: .continuous)
        VStack(alignment: .leading, spacing: scale(CouchLayout.Page.contentTop)) {
            CouchPageHeader(eyebrow: "Settings", title: "The back room.", scale: scale)
            VStack(spacing: 0) {
                ForEach(Array(CouchSettingsRow.allCases.enumerated()), id: \.offset) { offset, row in
                    CouchSettingsRowView(
                        row: row,
                        value: viewModel.settingValue(row),
                        volume: viewModel.audio.preferences.musicVolume,
                        isFocused: viewModel.state.area == .content && viewModel.state.settingsIndex == offset,
                        scale: scale
                    )
                }
            }
            .padding(scale(Metrics.padding))
            .frame(maxWidth: scale(Metrics.width))
            .frostedGlass(in: shape)
            .elevation(.regular)
            Text("Folders, players and API keys are set at the desk.")
                .font(Typeface.sans(scale(Metrics.note)))
                .foregroundStyle(Theme.inkMute)
        }
        .padding(.horizontal, scale(CouchLayout.gutter))
        .padding(.top, scale(CouchLayout.Page.top))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    let viewModel = CouchViewModel.preview
    viewModel.state.screen = .settings
    return CouchSettingsScreen(viewModel: viewModel)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
