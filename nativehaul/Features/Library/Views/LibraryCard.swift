import SwiftUI

/// A Library card (spec §3.2): the 3:4 cover with `elev` (`elev-lg` on hover), a build badge when not ready, then the
/// short title with its playtime (tabular, single biggest source) and when it was last played.
struct LibraryCard: View {
    /// The game.
    let game: Game
    /// Its build badge, if any.
    let badge: LibraryBuildBadge?
    /// Reference time.
    let now: Date
    /// Opens Detail.
    let open: () -> Void

    @State private var isHovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: open) {
            VStack(alignment: .leading, spacing: 0) {
                cover
                HStack(alignment: .firstTextBaseline, spacing: ShellLayout.Library.textGap) {
                    Text(ShortTitle.make(from: game.title))
                        .font(Typeface.sans(TypeStyle.Size.label, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(DesignTokens.Lines.single)
                        .truncationMode(.tail)
                    Spacer(minLength: 0)
                    if let playtime {
                        Text(playtime)
                            .font(Typeface.sans(TypeStyle.Size.small))
                            .monospacedDigit()
                            .foregroundStyle(Theme.inkMute)
                            .fixedSize()
                    }
                }
                .padding(.top, ShellLayout.Library.textTop)
                Text(lastPlayed)
                    .font(Typeface.sans(TypeStyle.Size.small))
                    .foregroundStyle(Theme.inkMute)
                    .lineLimit(DesignTokens.Lines.single)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressButtonStyle())
        .onHover { isHovered = $0 }
        .accessibilityElement(children: .combine)
    }

    private var cover: some View {
        let shape = RoundedRectangle(cornerRadius: KitMetrics.Radius.libraryCover, style: .continuous)
        return Color.clear
            .aspectRatio(ShellLayout.Library.coverAspect, contentMode: .fit)
            .overlay { ArtworkFill(path: game.coverImagePath, title: game.title) }
            .clipShape(shape)
            .elevation(isHovered ? .large : .regular)
            .animation(reduceMotion ? nil : Motion.settle(), value: isHovered)
            .overlay(alignment: .topLeading) {
                if let badge {
                    LibraryBadgePill(badge: badge)
                        .padding(ShellLayout.Library.badgeInset)
                }
            }
    }

    /// "11h 40m", or nothing before any play is recorded.
    private var playtime: String? {
        let seconds = game.biggestRealPlaytimeSeconds
        return seconds > 0 ? DurationFormatting.playtime(seconds: seconds) : nil
    }

    private var lastPlayed: String {
        game.lastPlayedDate.map { LastPlayedPhrase.phrase(for: $0, now: now) } ?? "Not played yet"
    }
}

#Preview {
    AppearancePreviewPair {
        LibraryCard(game: Game(title: "Lantern Coast"), badge: .building, now: .now) {}
            .frame(width: ShellLayout.Library.minimumCardWidth)
            .padding(KitMetrics.Spacing.section)
    }
}
