import SwiftUI

/// One Settings group (spec §3.5): a wash icon chip, a display title and a quiet note, over a frosted card whose rows
/// are separated by hairlines (none after the last).
struct SettingsGroup<Content: View>: View {
    /// The chip's SF Symbol.
    let symbolName: String
    /// The chip's wash.
    let tint: WashSlot
    /// The display title.
    let title: String
    /// The note under the title.
    let note: String
    /// The rows.
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: ShellLayout.Settings.cardTop) {
            HStack(spacing: ShellLayout.Settings.headerGap) {
                WashIconChip(symbolName: symbolName, slot: tint)
                VStack(alignment: .leading, spacing: ShellLayout.Settings.noteTop) {
                    Text(title)
                        .font(Typeface.display(TypeStyle.DisplaySize.group))
                        .foregroundStyle(Theme.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text(note)
                        .font(Typeface.sans(TypeStyle.Size.body))
                        .foregroundStyle(Theme.inkMute)
                }
            }
            VStack(spacing: 0) {
                Group(subviews: content()) { rows in
                    ForEach(rows) { row in
                        row
                        if row.id != rows.last?.id {
                            HairlineDivider()
                        }
                    }
                }
            }
            .padding(.horizontal, ShellLayout.Settings.cardHorizontal)
            .background {
                RoundedRectangle(cornerRadius: ShellLayout.Settings.cardRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: ShellLayout.Settings.cardRadius, style: .continuous)
                    .fill(Theme.surface.opacity(ShellLayout.Settings.cardOpacity))
            }
            .elevation(.small)
        }
        .padding(.top, ShellLayout.Settings.groupTop)
    }
}

#Preview {
    AppearancePreviewPair {
        SettingsGroup(symbolName: "folder", tint: .butter, title: "Directories", note: "Where your games are.") {
            SettingsRow(label: "Games folder", sub: "~/Switch/Games", isSubMonospaced: true) {
                Button("Change…") {}.buttonStyle(CreamPillButtonStyle())
            }
            SettingsRow(label: "Install location", sub: "~/Switch/Games", isSubMonospaced: true) {
                Button("Change…") {}.buttonStyle(CreamPillButtonStyle())
            }
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
