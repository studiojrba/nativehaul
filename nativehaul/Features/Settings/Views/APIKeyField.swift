import SwiftUI

/// The pasted-key field (spec §3.5): a `paper-2` pill with a monospaced input, a show/hide eye and a **Save** button
/// that
/// stays faint until there is something new to save. It always starts empty — a stored secret is never read back into
/// it — and the field clears once saved.
struct APIKeyField: View {
    /// What is typed.
    @Binding var text: String
    /// The placeholder.
    var placeholder = "Paste your key"
    /// Whether Save does anything.
    let canSave: Bool
    /// Saves to the Keychain.
    let save: () -> Void

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: ShellLayout.Settings.keyFieldPadding) {
            input
                .textFieldStyle(.plain)
                .font(.system(size: TypeStyle.Size.small, design: .monospaced))
                .foregroundStyle(Theme.ink)
                .focused($isFocused)
                .onSubmit {
                    if canSave {
                        save()
                    }
                }
                .frame(maxWidth: .infinity)
            Button { isRevealed.toggle() } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .font(.system(size: ShellLayout.Settings.eyeIcon))
                    .foregroundStyle(Theme.inkMute)
                    .frame(width: ShellLayout.Settings.eyeSize, height: ShellLayout.Settings.eyeSize)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .pointerStyle(.link)
            .accessibilityLabel(isRevealed ? "Hide key" : "Show key")
            Button("Save", action: save)
                .buttonStyle(.plain)
                .font(Typeface.sans(TypeStyle.Size.caption, weight: .medium))
                .foregroundStyle(Theme.paper)
                .padding(.horizontal, ShellLayout.Settings.saveHorizontal)
                .frame(height: ShellLayout.Settings.saveHeight)
                .background(Capsule().fill(Theme.ink))
                .opacity(canSave ? 1 : ShellLayout.Settings.saveDisabledOpacity)
                .disabled(!canSave)
                .pointerStyle(canSave ? .link : nil)
        }
        .padding(ShellLayout.Settings.keyFieldPadding)
        .padding(.leading, ShellLayout.Settings.keyFieldLeading - ShellLayout.Settings.keyFieldPadding)
        .frame(width: ShellLayout.Settings.keyFieldWidth)
        .background(Capsule().fill(Theme.paper2))
        .accentOutline(isFocused, opacity: ShellLayout.Settings.focusOpacity, width: ShellLayout.Settings.focusWidth)
    }

    @ViewBuilder private var input: some View {
        if isRevealed {
            TextField(placeholder, text: $text)
        } else {
            SecureField(placeholder, text: $text)
        }
    }
}

#Preview {
    @Previewable @State var empty = ""
    @Previewable @State var typed = "sgdb-typed"
    AppearancePreviewPair {
        VStack(spacing: DesignTokens.Spacing.lg) {
            APIKeyField(text: $empty, canSave: false) {}
            APIKeyField(text: $typed, canSave: true) {}
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
