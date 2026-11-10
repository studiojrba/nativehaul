import SwiftUI

/// Settings tab for the nxnative module. Everything here is optional: the module is on and detects its files.
struct NXNativeSettingsView: View {
    @State private var viewModel: NXNativeSettingsViewModel
    @State private var isChoosingEngine = false

    /// Creates the view.
    init(viewModel: NXNativeSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                Toggle("Build native apps with nxnative", isOn: $viewModel.configuration.isEnabled)
                NXNativeDisclaimer()
            }
            Section("Your files (found automatically)") {
                LabeledContent("Engine") {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        pathText(viewModel.engineDescription)
                        Button("Choose…") { isChoosingEngine = true }
                        if viewModel.configuration.hasEngineOverride {
                            Button("Use Detected") { viewModel.useDetectedEngine() }
                        }
                    }
                }
                LabeledContent("prod.keys") { pathText(viewModel.keysDescription) }
                TextField(
                    "Arguments ({input} {output} {titleID} {title})",
                    text: $viewModel.configuration.argumentTemplate
                )
            }
            Section("Folders") {
                TextField("Staging folder", text: $viewModel.configuration.stagingDirectory)
                TextField("Work folder", text: $viewModel.configuration.workRoot)
                TextField("Output folder", text: $viewModel.configuration.outputDirectory)
                TextField("Hidden library folder", text: $viewModel.configuration.hiddenLibraryFolderName)
                Stepper(
                    "Require \(viewModel.configuration.spaceMultiplier)× source size free",
                    value: $viewModel.configuration.spaceMultiplier,
                    in: Self.multiplierRange
                )
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Save") { viewModel.save() }.keyboardShortcut(.defaultAction)
                if let message = viewModel.statusMessage {
                    Text(message).foregroundStyle(Theme.secondaryText)
                }
            }
        }
        .formStyle(.grouped)
        .fileImporter(isPresented: $isChoosingEngine, allowedContentTypes: [.item]) { result in
            if case let .success(url) = result {
                viewModel.setEngine(url)
            }
        }
    }

    private func pathText(_ text: String) -> some View {
        Text(text)
            .font(DesignTokens.Typography.figuresSmall)
            .lineLimit(DesignTokens.Lines.single)
            .truncationMode(.middle)
    }

    private static let maximumMultiplier = 10
    private static let multiplierRange = 1 ... maximumMultiplier
}

#Preview {
    NXNativeSettingsView(viewModel: NXNativeSettingsViewModel(
        store: InMemoryEngineConfigurationStore(),
        locator: NXNativeLocator(files: InMemoryFileOperations(), homeDirectory: "/Users/demo")
    ))
}
