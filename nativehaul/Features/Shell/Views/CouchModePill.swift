import SwiftUI

/// The top bar's right pill (spec §3.0): a TV icon, "Couch mode" and the switch graphic; hovering darkens the track and
/// nudges the knob, and a tap anywhere on the pill enters couch mode.
struct CouchModePill: View {
    /// Enters couch mode.
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: ShellLayout.Chrome.innerGap) {
                Image(systemName: "tv")
                    .font(.system(size: ShellLayout.Chrome.couchIcon))
                Text("Couch mode")
                    .font(Typeface.sans(TypeStyle.Size.body))
                SwitchGraphic(isOn: false, isHovered: isHovered)
            }
            .foregroundStyle(Theme.ink)
            .padding(.leading, ShellLayout.Chrome.pillPadding)
            .padding(.trailing, ShellLayout.Chrome.couchTrailingPadding)
            .frame(height: ShellLayout.TopBar.pillHeight)
            .frostedGlass()
            .elevation(.small)
            .contentShape(Capsule())
        }
        .buttonStyle(PressButtonStyle())
        .onHover { isHovered = $0 }
        .accessibilityLabel("Couch mode")
    }
}

#Preview {
    AppearancePreviewPair {
        CouchModePill {}.padding(DesignTokens.Spacing.xl)
    }
}
