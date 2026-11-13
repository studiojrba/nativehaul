import SwiftUI

/// One Settings row (spec §3.5): a label block on the left — 15pt medium label, optional badge, 13pt sub-line that
/// truncates — and the control on the right, 24pt apart.
struct SettingsRow<Control: View>: View {
    /// The label.
    let label: String
    /// The sub-line, if any.
    var sub: String?
    /// Shows the sub-line in monospace `ink-soft` (paths).
    var isSubMonospaced = false
    /// A badge beside the label ("Valid", "Saved"), if any.
    var badge: String?
    /// A second, quiet line under the sub-line, if any.
    var footnote: String?
    /// The control.
    @ViewBuilder let control: () -> Control

    var body: some View {
        HStack(spacing: ShellLayout.Settings.rowGap) {
            VStack(alignment: .leading, spacing: ShellLayout.Settings.subTop) {
                HStack(spacing: ShellLayout.Settings.badgeGap) {
                    Text(label)
                        .font(Typeface.sans(TypeStyle.Size.label, weight: .medium))
                        .foregroundStyle(Theme.ink)
                    if let badge {
                        CheckBadge(text: badge)
                    }
                }
                if let sub {
                    Text(sub)
                        .font(isSubMonospaced ? subMonospaced : Typeface.sans(TypeStyle.Size.small))
                        .foregroundStyle(isSubMonospaced ? Theme.inkSoft : Theme.inkMute)
                        .lineLimit(DesignTokens.Lines.single)
                        .truncationMode(isSubMonospaced ? .middle : .tail)
                        .help(sub)
                }
                if let footnote {
                    Text(footnote)
                        .font(Typeface.sans(TypeStyle.Size.small))
                        .foregroundStyle(Theme.inkMute)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            control()
                .fixedSize()
        }
        .padding(.vertical, ShellLayout.Settings.rowVertical)
        .accessibilityElement(children: .contain)
    }

    private var subMonospaced: Font {
        .system(size: TypeStyle.Size.small, design: .monospaced)
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(spacing: 0) {
            SettingsRow(
                label: "Library key",
                sub: "~/Switch/Keys",
                isSubMonospaced: true,
                badge: "Valid"
            ) {
                Button("Change…") {}.buttonStyle(CreamPillButtonStyle())
            }
            SettingsRow(label: "Music", sub: "Plays softly while you browse.") {
                ToggleSwitchTrack(isOn: .constant(true))
            }
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
