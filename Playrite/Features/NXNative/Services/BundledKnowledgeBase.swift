import Foundation

/// Live ``KnowledgeBaseProviding`` reading `TroubleshootingKnowledgeBase.json` from the app bundle.
struct BundledKnowledgeBase: KnowledgeBaseProviding {
    private static let resourceName = "TroubleshootingKnowledgeBase"
    private let bundle: Bundle

    /// Creates the provider.
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func cases() -> [TroubleshootingCase] {
        guard let url = bundle.url(forResource: Self.resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return [] }
        return (try? JSONDecoder().decode([TroubleshootingCase].self, from: data)) ?? []
    }
}
