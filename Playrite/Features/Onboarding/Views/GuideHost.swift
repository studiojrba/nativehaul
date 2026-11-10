import SwiftUI
import UniformTypeIdentifiers

/// Hosts the guided tour in the main window (ADR 0040): starts it on first launch, restarts it on "Run setup again",
/// moves to each step's place, shows Retriever's bubble (never over a running game, ADR 0030), and offers to resume
/// an exited tour. The Steam step's bubble shows in Settings instead.
struct GuideHost: ViewModifier {
    /// The tour.
    let guide: OnboardingGuide
    /// Whether a game is in front (the tour waits).
    let isGameRunning: Bool
    /// Moves to a step's place.
    let onNavigate: (GuideDestination) -> Void
    /// Adds the folders chosen in the library step.
    let onChooseFolders: ([URL]) -> Void
    @State private var isChoosingFolders = false

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let step = guide.currentStep, !isGameRunning, step.destination != .steamSettings {
                    GuideBubble(
                        guide: guide,
                        step: step,
                        primaryAction: step == .library
                            ? { isChoosingFolders = true }
                            : nil
                    )
                    .padding(DesignTokens.Spacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .fileImporter(
                        isPresented: $isChoosingFolders,
                        allowedContentTypes: [.folder],
                        allowsMultipleSelection: true
                    ) { result in
                        if case let .success(urls) = result, !urls.isEmpty {
                            onChooseFolders(urls)
                        }
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if guide.canResume, !isGameRunning {
                    GuideResumePill(guide: guide).padding(DesignTokens.Spacing.xl)
                }
            }
            .task { guide.startIfFirstRun() }
            .onReceive(NotificationCenter.default.publisher(for: OnboardingRequest.name)) { _ in guide.restart() }
            .onChange(of: guide.currentStep, initial: true) { _, step in
                if let step {
                    onNavigate(step.destination)
                }
            }
    }
}
