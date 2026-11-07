import SwiftUI

/// Title for a content section, with optional trailing caption (ADR 0025).
///
/// `.display` is the big, tight page-level header; `.panel` (the default) is the calm header used inside dense panels
/// such as the detail page, so data screens stay quiet.
struct SectionHeader: View {
    /// How loud the header is.
    enum Style {
        case display
        case panel
    }

    /// Section title.
    let title: String
    /// Optional secondary text.
    var caption: String?
    /// How loud the header is.
    var style = Style.panel

    var body: some View {
        Group {
            switch style {
            case .display:
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    titleText
                    captionText
                }
            case .panel:
                FlowLayout(spacing: DesignTokens.Spacing.sm) {
                    titleText
                    captionText
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var captionText: some View {
        if let caption {
            Text(caption)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
        }
    }

    @ViewBuilder private var titleText: some View {
        switch style {
        case .display:
            Text(title).font(DesignTokens.Typography.display).tracking(DesignTokens.Typography.displayTracking)
        case .panel:
            Text(title).font(DesignTokens.Typography.title)
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        SectionHeader(title: "Most played", caption: "real hours", style: .display)
        SectionHeader(title: "Playtime", caption: "by source")
    }
    .padding(DesignTokens.Spacing.lg)
}
