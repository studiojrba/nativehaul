import SwiftUI

/// Sheet for queueing a staged title. Architecture must be set explicitly; 32-bit titles are refused at preflight.
struct AddBuildJobSheet: View {
    /// Called with source path and title info.
    let onAdd: (String, TitleInfo) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var sourcePath = ""
    @State private var name = ""
    @State private var titleID = ""
    @State private var architecture: TitleArchitecture = .unknown

    var body: some View {
        Form {
            Section {
                ProvideFilePrompt(request: EngineConfiguration.gameFileRequest) { sourcePath = $0 }
                ProvideFilePrompt(request: EngineConfiguration.switch2GameRequest) { sourcePath = $0 }
                if !sourcePath.isEmpty {
                    Label((sourcePath as NSString).lastPathComponent, systemImage: "checkmark.circle")
                        .foregroundStyle(Theme.success)
                }
            }
            TextField("Real title (used to name the app)", text: $name)
            TextField("Title ID (16 hex digits; optional for Switch 2)", text: $titleID)
            Picker("Architecture", selection: $architecture) {
                ForEach(TitleArchitecture.allCases) { Text($0.displayName).tag($0) }
            }
            NXNativeDisclaimer()
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.lg)
        .frame(minWidth: DesignTokens.Layout.detailMinWidth)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add to Queue") {
                    onAdd(sourcePath, TitleInfo(titleID: titleID.uppercased(), name: name, architecture: architecture))
                    dismiss()
                }
                .disabled(sourcePath.isEmpty || name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

#Preview {
    AddBuildJobSheet { _, _ in }
}
