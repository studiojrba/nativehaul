import SwiftUI

/// Install / Update button with honest progress and the signature status shown before installing.
struct ComponentInstallControl: View {
    @State private var viewModel: ComponentInstallViewModel

    /// Creates the control.
    init(viewModel: ComponentInstallViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if let stage = viewModel.stage {
                stageContent(stage)
            } else {
                statusContent
            }
        }
        .font(DesignTokens.Typography.caption)
    }

    @ViewBuilder private var statusContent: some View {
        switch viewModel.status {
        case .notInstalled:
            Button("Install \(viewModel.entry.name)", systemImage: "arrow.down.circle") { viewModel.start() }
        case let .updateAvailable(current, latest, isManaged):
            TagLabel(
                text: "Update available: \(current ?? "?") → \(latest)",
                symbolName: "arrow.up.circle",
                tint: Theme.info
            )
            if isManaged {
                Button("Update") { viewModel.start() }
            } else {
                Text("You installed this copy yourself. Let NX Shelf manage and update it?")
                    .foregroundStyle(Theme.secondaryText)
                Button("Manage and Update") { viewModel.takeOverAndUpdate() }
            }
        case let .upToDate(version):
            Text(version.map { "Up to date (\($0))" } ?? "Installed").foregroundStyle(Theme.secondaryText)
        case nil:
            EmptyView()
        }
    }

    @ViewBuilder private func stageContent(_ stage: ComponentInstallStage) -> some View {
        switch stage {
        case .downloading: ComponentProgressRow(text: "Downloading from the official source…")
        case .verifyingChecksum: ComponentProgressRow(text: "Checking the published checksum…")
        case .unpacking: ComponentProgressRow(text: "Unpacking…")
        case .checkingSignature: ComponentProgressRow(text: "Asking macOS about its signature…")
        case .installing: ComponentProgressRow(text: "Installing into ~/Applications…")
        case let .awaitingConfirmation(signature):
            Label(
                signature.summary,
                systemImage: signature.allowsUnattendedInstall ? "checkmark.seal" : "exclamationmark.shield"
            )
            HStack(spacing: DesignTokens.Spacing.sm) {
                Button("Install") { viewModel.confirm() }.buttonStyle(.borderedProminent)
                Button("Cancel") { viewModel.dismiss() }
            }
        case let .installed(path):
            Text("Installed at \(path).").foregroundStyle(Theme.success)
        case let .failed(reason):
            Text(reason).foregroundStyle(Theme.danger)
            Button("OK") { viewModel.dismiss() }
        }
    }
}

#Preview {
    let updater = MockComponentUpdater()
    if let entry = updater.catalog.components.first {
        ComponentInstallControl(viewModel: ComponentInstallViewModel(entry: entry, updater: updater))
            .padding(DesignTokens.Spacing.lg)
    }
}
