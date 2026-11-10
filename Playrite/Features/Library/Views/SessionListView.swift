import SwiftUI

/// Chronological list of play sessions with their source labels.
struct SessionListView: View {
    /// Sessions, newest first.
    let sessions: [PlaySession]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Sessions", caption: "\(sessions.count)")
            if sessions.isEmpty {
                Text("No sessions yet.").foregroundStyle(Theme.secondaryText)
            }
            ForEach(sessions) { session in
                FlowLayout(spacing: DesignTokens.Spacing.md) {
                    Text(session.startedAt, format: .dateTime.year().month().day().hour().minute())
                    Text(DurationFormatting.compact(seconds: session.durationSeconds))
                        .font(DesignTokens.Typography.figures)
                    PlaytimeSourceTag(source: session.source)
                }
            }
        }
    }
}

#Preview {
    SessionListView(sessions: [PlaySession(
        startedAt: .now.addingTimeInterval(-3600),
        endedAt: .now,
        source: .macTracked
    )])
    .padding(DesignTokens.Spacing.lg)
}
