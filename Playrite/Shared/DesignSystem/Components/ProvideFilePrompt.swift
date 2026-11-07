import SwiftUI
import UniformTypeIdentifiers

/// "Please provide your ___": the one prompt for files only the user can supply. Plain copy, a file picker, nothing
/// else — no links, no hints about where to get the file.
struct ProvideFilePrompt: View {
    /// What is needed and why.
    let request: UserFileRequest
    /// Called with the picked file's path.
    let onProvide: (String) -> Void
    @State private var isPicking = false

    private var contentTypes: [UTType] {
        let types = request.allowedExtensions.compactMap { UTType(filenameExtension: $0) }
        let files = types.isEmpty ? [UTType.data] : types
        return request.allowsFolders ? files + [.folder] : files
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(request.prompt, systemImage: "doc.badge.plus").font(DesignTokens.Typography.headline)
            Text(request.reason)
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            Button(request.allowsFolders ? "Choose…" : "Choose File…", systemImage: "folder") { isPicking = true }
        }
        .fileImporter(isPresented: $isPicking, allowedContentTypes: contentTypes) { result in
            if case let .success(url) = result {
                onProvide(url.path(percentEncoded: false))
            }
        }
    }
}

#Preview {
    ProvideFilePrompt(request: UserFileRequest(
        fileDescription: "PlayStation 2 BIOS",
        reason: "The emulator needs it to start PlayStation 2 games.",
        destinationFolder: nil
    )) { _ in }
        .padding(DesignTokens.Spacing.lg)
}
