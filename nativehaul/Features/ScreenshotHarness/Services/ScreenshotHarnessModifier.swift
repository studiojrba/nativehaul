#if DEBUG
    import SwiftUI

    /// Applies a ``ScreenshotRequest`` to the main window once it is up (DEBUG only): sizes it, starts the demo builds
    /// where the screen shows them, and goes to the requested screen.
    struct ScreenshotHarnessModifier: ViewModifier {
        /// The request.
        let request: ScreenshotRequest?
        /// The shell.
        let shell: ShellViewModel
        /// The build queue.
        let queue: NXNativeViewModel
        /// The library.
        let library: LibraryViewModel

        private static let demoSource = "/Users/demo/Switch/Staging/Tideborn.nsp"
        private static let secondTitleID = "0100ABCD00020000"

        func body(content: Content) -> some View {
            content.task {
                guard let request else { return }
                ScreenshotHarness.sizeWindow(for: request)
                switch request.screen {
                case .onboarding, .home: break
                case .library: shell.go(to: .library)
                case .settings: shell.go(to: .settings)
                case .builds:
                    startDemoBuilds()
                    shell.go(to: .builds)
                case .detail:
                    startDemoBuilds()
                    if let game = library.games.first(where: { $0.title == HarnessLibrary.buildingTitle }) {
                        shell.open(gameID: game.id)
                    }
                }
            }
        }

        private func startDemoBuilds() {
            queue.enqueue(
                sourcePath: Self.demoSource,
                title: TitleInfo(
                    titleID: HarnessLibrary.buildingTitleID,
                    name: HarnessLibrary.buildingTitle,
                    architecture: .bit64
                )
            )
            queue.enqueue(
                sourcePath: Self.demoSource,
                title: TitleInfo(titleID: Self.secondTitleID, name: "Signal Lake", architecture: .bit64)
            )
            queue.selectedJobID = queue.jobs.first?.id
            queue.startQueue()
        }
    }
#endif
