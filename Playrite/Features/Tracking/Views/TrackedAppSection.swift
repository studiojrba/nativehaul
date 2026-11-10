import SwiftUI

/// Detail-screen block: tracked `.app` bundle and self-reported session logging.
struct TrackedAppSection: View {
    @State private var viewModel: TrackedAppViewModel
    @State private var isChoosingApp = false
    @State private var isLoggingSession = false

    /// Creates the section.
    init(viewModel: TrackedAppViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Tracking")
            LabeledValueRow(label: "Tracked app") {
                Text(viewModel.bundlePath ?? "Not tracked")
                    .font(DesignTokens.Typography.figuresSmall)
                    .lineLimit(DesignTokens.Lines.single)
                    .truncationMode(.middle)
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                Button(viewModel.bundlePath == nil ? "Track App…" : "Change App…") { isChoosingApp = true }
                if viewModel.bundlePath != nil {
                    Button("Stop Tracking") { viewModel.clearBundle() }
                }
                Button("Log Session…") { isLoggingSession = true }
            }
            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(Theme.danger)
            }
        }
        .fileImporter(isPresented: $isChoosingApp, allowedContentTypes: [.application]) { result in
            if case let .success(url) = result {
                viewModel.setBundle(url)
            }
        }
        .sheet(isPresented: $isLoggingSession) {
            LogSessionSheet { viewModel.logSelfReportedSession(startedAt: $0, hours: $1) }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    TrackedAppSection(viewModel: environment.makeTrackedAppViewModel(for: Game(title: "Tideborn")))
        .padding(DesignTokens.Spacing.lg)
}
