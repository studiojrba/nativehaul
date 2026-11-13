import AppKit
import SwiftUI

/// The main window's non-visual duties (kept from the pre-0.1.0 root): whether onboarding is up (first run, or the
/// replay from Settings; ``RootView`` shows it in place of the shell), the playtime watcher, quiet upkeep, library
/// reloads, the shell sounds and music,
/// and telling the shell when a launched game has taken over.
struct RootLifecycle: ViewModifier {
    /// App dependencies.
    let environment: AppEnvironment
    /// The shared library.
    let libraryViewModel: LibraryViewModel
    /// The shell.
    let shell: ShellViewModel
    /// Whether onboarding is up.
    @Binding var isOnboarding: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: environment.handoff.isGameRunning) { _, isRunning in
                environment.audio.gameRunningDidChange(isRunning)
                if isRunning {
                    shell.handoffCompleted()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
                shell.handoffCompleted()
            }
            .onChange(of: isOnboarding) { _, onboarding in
                if onboarding {
                    environment.audio.shellDidDisappear()
                } else {
                    environment.audio.shellDidAppear()
                }
            }
            .task {
                isOnboarding = !environment.onboarding.hasCompletedOnboarding
                if !isOnboarding {
                    environment.audio.shellDidAppear()
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
}
