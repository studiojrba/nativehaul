import SwiftUI

/// "Manage" sheet: status, self-reported hours, artwork, tracked app and HLTB entry.
struct GameManageSheet: View {
    /// Detail state.
    @Bindable var viewModel: GameDetailViewModel
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.dismiss) private var dismiss
    @State private var pickingArtwork: ArtworkKind?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                SectionHeader(title: "Manage \(viewModel.game.title)")
                LabeledValueRow(label: "Status") {
                    Picker("Status", selection: $viewModel.status) {
                        ForEach(GameStatus.allCases) { Text($0.displayName).tag($0) }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
                LabeledValueRow(label: "Self-reported hours") {
                    TextField("Hours", value: $viewModel.selfReportedHours, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .fixedSize()
                    PlaytimeSourceTag(source: .selfReported)
                }
                HStack(spacing: DesignTokens.Spacing.md) {
                    Button("Choose Cover…", systemImage: "photo") { pickingArtwork = .cover }
                    Button("Choose Hero Image…", systemImage: "photo.on.rectangle") { pickingArtwork = .hero }
                }
                TrackedAppSection(viewModel: environment.makeTrackedAppViewModel(for: viewModel.game))
                HLTBSection(viewModel: environment.makeHLTBViewModel(for: viewModel.game))
            }
            .padding(DesignTokens.Spacing.xl)
        }
        .frame(minWidth: DesignTokens.Layout.detailMinWidth, minHeight: DesignTokens.Layout.windowMinHeight)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
        }
        .fileImporter(
            isPresented: Binding(get: { pickingArtwork != nil }, set: {
                if !$0 {
                    pickingArtwork = nil
                }
            }),
            allowedContentTypes: [.image]
        ) { result in
            guard case let .success(url) = result else { return }
            switch pickingArtwork {
            case .cover: viewModel.setCoverImagePath(url.path)
            case .hero: viewModel.setHeroImagePath(url.path)
            case nil: break
            }
        }
    }

    /// Which image is being chosen.
    enum ArtworkKind {
        case cover
        case hero
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        GameManageSheet(viewModel: environment.makeGameDetailViewModel(for: game))
            .environment(environment)
    }
}
