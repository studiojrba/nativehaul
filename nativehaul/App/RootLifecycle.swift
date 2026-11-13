import AppKit
import SwiftUI

/// The main window's non-visual duties (kept from the pre-0.1.0 root): whether onboarding is up (first run, or the
/// replay from Settings; ``RootView`` shows it in place of the shell), the playtime watcher, quiet upkeep, library
/// reloads, the shell sounds and music,
/// telling the shell (and couch) when a launched game has taken over, opening in the saved mode (couch only after
/// onboarding, which always runs at the desk), and offering Resume/Close when nativehaul comes forward over a game in
/// couch (ADR 0058).
struct RootLifecycle: ViewModifier {
    /// App dependencies.
    let environment: AppEnvironment
    /// The shared library.
    let libraryViewModel: LibraryViewModel
    /// The shell.
    let shell: ShellViewModel
    /// Couch mode.
    let couch: CouchViewModel
    /// Whether onboarding is up.
    @Binding var isOnboarding: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: environment.handoff.isGameRunning) { _, isRunning in
                environment.audio.gameRunningDidChange(isRunning)
                couch.gameRunningDidChange(isRunning)
                if isRunning {
                    shell.handoffCompleted()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
                shell.handoffCompleted()
                couch.handoffCompleted()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                if shell.mode == .couch {
                    couch.appDidBecomeActive()
                }
            }
            .onChange(of: isOnboarding) { _, onboarding in
                if onboarding {
                    shell.exitCouch()
                    environment.audio.shellDidDisappear()
                } else {
                    environment.audio.shellDidAppear()
                    openInSavedMode()
                }
            }
            .task {
                isOnboarding = !environment.onboarding.hasCompletedOnboarding
                if !isOnboarding {
                    environment.audio.shellDidAppear()
                    openInSavedMode()
                }
                environment.watcher.start()
                await libraryViewModel.runAutomaticUpkeep()
            }
            .onReceive(NotificationCenter.default.publisher(for: OnboardingRequest.name)) { _ in isOnboarding = true }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                environment.watcher.stop()
            }
            .onReceive(NotificationCenter.default.publisher(for: LibraryChangeNotification.name)) { _ in
                libraryViewModel.reload()
                Task { await libraryViewModel.fetchMetadataQuietly() }
            }
    }

    /// "Open in" (TV plan Q7): couch when that is the saved choice.
    private func openInSavedMode() {
        if environment.modePreferences.defaultMode == .couch {
            shell.enterCouch()
        }
    }
}
