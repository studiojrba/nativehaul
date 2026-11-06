import SwiftUI

/// One guide with attribution, current chapter and chapter links.
struct GuideRow: View {
    /// The guide.
    let guide: GuideLink
    /// Guides state.
    let viewModel: GuidesViewModel
    /// Requests the add-chapter sheet.
    let onAddChapter: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: "book")
                Text(guide.title).font(DesignTokens.Typography.headline)
                Spacer(minLength: DesignTokens.Spacing.none)
                Button(guide.currentChapter.map { "Continue: \($0.title)" } ?? "Open Guide") {
                    viewModel.continueReading(guide)
                }
            }
            Text(guide.attribution).font(DesignTokens.Typography.caption).foregroundStyle(Theme.secondaryText)
            if !guide.chapters.isEmpty {
                Picker("Current chapter", selection: Binding(
                    get: { guide.currentChapterID },
                    set: { id in viewModel.setCurrentChapter(guide.chapters.first { $0.id == id }, in: guide) }
                )) {
                    Text("Not started").tag(UUID?.none)
                    ForEach(guide.chapters) { Text($0.title).tag(Optional($0.id)) }
                }
                .fixedSize()
                ForEach(guide.chapters) { chapter in
                    Button(chapter.title, systemImage: "arrow.up.right.square") { viewModel.open(chapter) }
                        .buttonStyle(.link)
                }
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Add Chapter…", action: onAddChapter)
                Button("Remove Link", role: .destructive) { viewModel.remove(guide) }
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let game = Game(title: "Tideborn")
    let guide = GuideLink(
        title: "Walkthrough",
        author: "Sample Author",
        url: "https://gamefaqs.gamespot.com/switch/1-tideborn/faqs/1"
    )
    GuideRow(guide: guide, viewModel: environment.makeGuidesViewModel(for: game)) {}
        .padding(DesignTokens.Spacing.lg)
}
