import SwiftUI

/// Scrolling, auto-following view of streamed build output.
struct BuildLogConsole: View {
    /// Lines to show.
    let lines: [BuildLogLine]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Build Log", caption: "\(lines.count) lines")
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: DesignTokens.Spacing.none) {
                        ForEach(lines) { line in
                            Text(line.text)
                                .font(DesignTokens.Typography.figuresSmall)
                                .foregroundStyle(color(for: line.stream))
                                .textSelection(.enabled)
                                .id(line.id)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(DesignTokens.Spacing.sm)
                }
                .frame(minHeight: DesignTokens.Layout.logMinHeight)
                .background(RoundedRectangle(cornerRadius: DesignTokens.Radius.md).fill(Theme.surface))
                .onChange(of: lines.count) {
                    if let last = lines.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func color(for stream: BuildLogLine.Stream) -> Color {
        switch stream {
        case .stdout: Theme.primaryText
        case .stderr: Theme.danger
        case .system: Theme.info
        }
    }
}

#Preview {
    BuildLogConsole(lines: [
        BuildLogLine(timestamp: .now, stream: .stdout, text: "[engine] extracting"),
        BuildLogLine(timestamp: .now, stream: .stderr, text: "profile check failed: non-retail title id"),
    ])
    .padding(DesignTokens.Spacing.lg)
}
