import SwiftUI

/// The whole-shelf card at the foot of Home (spec §3.1): "The whole shelf", "{n} games, {hours} hours well spent."
/// (each game's single biggest source, summed across games only), and a round arrow that slides on hover. Opens
/// Library.
struct WholeShelfCard: View {
    /// The shelf in numbers.
    let summary: ShelfSummary
    /// Goes to Library.
    let action: () -> Void

    @State private var isHovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            HStack(spacing: KitMetrics.Spacing.roomy) {
                VStack(alignment: .leading, spacing: ShellLayout.WholeShelf.lineTop) {
                    Text("The whole shelf")
                        .font(Typeface.display(TypeStyle.DisplaySize.card))
                        .foregroundStyle(Theme.ink)
                    Text(summary.wholeShelfLine)
                        .font(Typeface.sans(TypeStyle.Size.label))
                        .foregroundStyle(Theme.inkSoft)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.right")
                    .font(.system(size: ShellLayout.WholeShelf.arrowSize))
                    .foregroundStyle(Theme.ink)
                    .frame(width: ShellLayout.WholeShelf.buttonSize, height: ShellLayout.WholeShelf.buttonSize)
                    .background(Circle().fill(Theme.surface))
                    .elevation(.small)
                    .offset(x: isHovered && !reduceMotion ? ShellLayout.WholeShelf.hoverSlide : 0)
                    .animation(Motion.settle(), value: isHovered)
            }
            .padding(.horizontal, ShellLayout.WholeShelf.horizontal)
            .padding(.vertical, ShellLayout.WholeShelf.vertical)
            .background(
                RoundedRectangle(cornerRadius: ShellLayout.WholeShelf.radius, style: .continuous)
                    .fill(Theme.cream.opacity(ShellLayout.WholeShelf.fillOpacity))
            )
            .elevation(.small)
            .contentShape(RoundedRectangle(cornerRadius: ShellLayout.WholeShelf.radius, style: .continuous))
        }
        .buttonStyle(PressButtonStyle())
        .onHover { isHovered = $0 }
    }
}

#Preview {
    AppearancePreviewPair {
        WholeShelfCard(summary: ShelfSummary(games: [Game(title: "Lantern Coast")])) {}
            .padding(KitMetrics.Spacing.section)
    }
}
