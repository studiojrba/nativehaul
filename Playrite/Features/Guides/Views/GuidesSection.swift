import SwiftUI

/// Detail-screen block listing GameFAQs guide links (link-out only).
struct GuidesSection: View {
    @State private var viewModel: GuidesViewModel
    @State private var isAddingGuide = false
    @State private var chapterTarget: GuideLink?

    /// Creates the section.
    init(viewModel: GuidesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Guides", caption: "GameFAQs · opens in your browser")
            if viewModel.guides.isEmpty {
                Text("No guides linked.").foregroundStyle(Theme.secondaryText)
            }
            ForEach(viewModel.guides) { guide in
                GuideRow(guide: guide, viewModel: viewModel) { chapterTarget = guide }
            }
            Button("Link a Guide…") { isAddingGuide = true }
        }
        .sheet(isPresented: $isAddingGuide) {
            AddGuideSheet(
                onAdd: { viewModel.addGuide(title: $0, author: $1, url: $2) },
                errorMessage: viewModel.errorMessage
            )
        }
        .sheet(item: $chapterTarget) { guide in
            AddChapterSheet(
                guideTitle: guide.title,
                onAdd: { viewModel.addChapter(to: guide, title: $0, url: $1) },
                errorMessage: viewModel.errorMessage
            )
        }
    }
}

#Preview {
    GuidesSection(viewModel: AppEnvironment.preview.makeGuidesViewModel(for: Game(title: "Tideborn")))
        .padding(DesignTokens.Spacing.lg)
}
