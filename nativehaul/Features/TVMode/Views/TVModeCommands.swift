import SwiftUI

/// "Enter TV Mode" in the View menu (⌃⌘T).
struct TVModeCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Button("Enter TV Mode") { TVModeRequest.post() }
                .keyboardShortcut("t", modifiers: [.control, .command])
        }
    }
}
