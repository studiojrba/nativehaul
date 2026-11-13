import SwiftUI

/// The build tutorial's scene for each beat (notes 8–11): the four steps, one game's files found together, a build
/// running to Ready with its log, then the finished game back on the shelf. It uses the user's own games from the scan
/// where it can, and says "For example" where it can't.
struct BuildTutorialScene: View {
    /// The beat.
    let beat: OnboardingBeat
    /// The real state.
    let facts: OnboardingFacts

    private static let exampleTitle = "Your game"

    var body: some View {
        switch beat {
        case .buildIntro:
            BuildStepsCard()
        case .buildFolder:
            if let grouped = facts.scan?.firstGrouped, let contents = grouped.contents {
                BuildFolderCard(
                    title: grouped.title,
                    imagePath: grouped.imagePath,
                    contents: contents,
                    isExample: false
                )
            } else {
                // An illustration: never pin made-up files on one of the user's real games.
                BuildFolderCard(
                    title: Self.exampleTitle,
                    imagePath: nil,
                    contents: ScanContents.example,
                    isExample: true
                )
            }
        case .buildBegin:
            BuildDemoCard(title: example?.title ?? Self.exampleTitle, imagePath: example?.imagePath)
        default:
            BuildLaunchCard(covers: facts.scan?.covers ?? [])
        }
    }

    private var example: ScanCover? {
        facts.scan?.firstGrouped ?? facts.scan?.covers.first
    }
}

#Preview {
    AppearancePreviewPair {
        BuildTutorialScene(beat: .buildIntro, facts: OnboardingFacts()).padding(DesignTokens.Spacing.xl)
    }
}
