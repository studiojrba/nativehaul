import SwiftUI

/// The shared build log (notes 11, 15, 18; Make's `BuildLog`): a "BUILD LOG" header with a terminal icon over
/// monospaced lines, each after an accent chevron. It never collapses: it sits at a ~3-line default height, and plus
/// and minus switch between that and one fixed taller height (~12 lines, capped at 40% of the window). Minus is
/// disabled at the default, plus when expanded; there is no grab bar. The choice is remembered per screen. New lines
/// keep the newest in view unless the reader has scrolled up.
struct BuildLogPanel: View {
    /// The lines, oldest first (plain-language, see ``BuildLogNarrator``).
    let lines: [String]
    /// The screen it lives on.
    let screen: BuildLogScreen
    /// A build is running: a blinking caret follows the newest line.
    var isLive = false
    /// The window height, for the 40% cap (`nil`: no cap).
    var windowHeight: CGFloat?

    @AppStorage private var isExpanded: Bool
    @State private var position = ScrollPosition(edge: .bottom)
    @State private var isFollowing = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates the log.
    init(lines: [String], screen: BuildLogScreen, isLive: Bool = false, windowHeight: CGFloat? = nil) {
        self.lines = lines
        self.screen = screen
        self.isLive = isLive
        self.windowHeight = windowHeight
        _isExpanded = AppStorage(wrappedValue: false, screen.storageKey)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Rectangle()
                .fill(Theme.lamp.opacity(ShellLayout.BuildLog.dividerOpacity))
                .frame(height: DesignTokens.Stroke.hairline)
            logBody
        }
        .frame(height: isExpanded
            ? ShellLayout.BuildLog.expandedHeight(windowHeight: windowHeight)
            : ShellLayout.BuildLog.defaultHeight)
        .background(Theme.bezel.opacity(ShellLayout.BuildLog.fillOpacity))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.lamp.opacity(ShellLayout.BuildLog.highlightOpacity))
                .frame(height: DesignTokens.Stroke.hairline)
        }
        .clipShape(RoundedRectangle(cornerRadius: ShellLayout.BuildLog.radius, style: .continuous))
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.rise), value: isExpanded)
    }

    private var header: some View {
        HStack(spacing: ShellLayout.BuildLog.headerGap) {
            Image(systemName: "terminal").font(.system(size: ShellLayout.BuildLog.headerIcon))
            Text("Build log".uppercased())
                .font(Typeface.sans(ShellLayout.BuildLog.headerSize))
                .tracking(TypeStyle.tracking(
                    em: ShellLayout.BuildLog.headerTrackingEm,
                    size: ShellLayout.BuildLog.headerSize
                ))
            Spacer(minLength: 0)
            HStack(spacing: ShellLayout.BuildLog.stepGap) {
                BuildLogStepButton(symbol: "minus", label: "Show less of the build log", isEnabled: isExpanded) {
                    isExpanded = false
                }
                BuildLogStepButton(symbol: "plus", label: "Show more of the build log", isEnabled: !isExpanded) {
                    isExpanded = true
                }
            }
        }
        .foregroundStyle(Theme.lamp.opacity(ShellLayout.BuildLog.headerOpacity))
        .padding(.leading, ShellLayout.BuildLog.horizontal)
        .padding(.trailing, ShellLayout.BuildLog.headerTrailing)
        .frame(height: ShellLayout.BuildLog.headerHeight)
    }

    private var logBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                    row(line, isNewest: index == lines.count - 1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ShellLayout.BuildLog.horizontal)
            .padding(.vertical, ShellLayout.BuildLog.bodyVertical)
        }
        .scrollIndicators(.never)
        .scrollPosition($position)
        .defaultScrollAnchor(.bottom)
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentSize.height - geometry.contentOffset.y - geometry.containerSize.height
                < ShellLayout.BuildLog.followSlack
        } action: { _, isNearBottom in
            isFollowing = isNearBottom
        }
        .onChange(of: lines.count) {
            if isFollowing {
                position.scrollTo(edge: .bottom)
            }
        }
        .onChange(of: isExpanded) {
            if isFollowing {
                position.scrollTo(edge: .bottom)
            }
        }
    }

    private func row(_ line: String, isNewest: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("›")
                .foregroundStyle(Theme.accent.opacity(ShellLayout.BuildLog.chevronOpacity))
                .padding(.trailing, ShellLayout.BuildLog.chevronGap)
            Text(line)
                .foregroundStyle(Theme.lamp.opacity(ShellLayout.BuildLog.lineOpacity))
                .lineLimit(DesignTokens.Lines.single)
                .truncationMode(.tail)
            if isLive, isNewest {
                BlinkingCaret()
                    .padding(.leading, ShellLayout.BuildLog.caretGap)
            }
        }
        .font(.system(size: ShellLayout.BuildLog.lineSize, design: .monospaced))
        .frame(height: ShellLayout.BuildLog.lineHeight, alignment: .leading)
        .textSelection(.enabled)
        .transition(.opacity)
    }
}

#Preview {
    AppearancePreviewPair {
        BuildLogPanel(
            lines: ["Found the base game, an update and 2 DLC", "Reading the game files", "Checking every file"],
            screen: .builds,
            isLive: true
        )
        .padding(DesignTokens.Spacing.xl)
    }
}
