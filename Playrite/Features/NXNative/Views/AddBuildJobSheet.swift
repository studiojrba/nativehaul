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
    @State private var isChoosingFile = false

    var body: some View {
        Form {
            LabeledContent("Staged file") {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text(sourcePath.isEmpty ? "None" : (sourcePath as NSString).lastPathComponent)
                    Button("Choose…") { isChoosingFile = true }
                }
            }
            TextField("Real title (used to name the app)", text: $name)
            TextField("Title ID (16 hex digits)", text: $titleID)
            Picker("Architecture", selection: $architecture) {
                ForEach(TitleArchitecture.allCases) { Text($0.displayName).tag($0) }
            }
            NXNativeDisclaimer()
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.lg)
        .frame(minWidth: DesignTokens.Layout.detailMinWidth)
        .fileImporter(isPresented: $isChoosingFile, allowedContentTypes: [.data]) { result in
            if case let .success(url) = result {
                sourcePath = url.path
            }
        }
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
