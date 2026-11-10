import Foundation

/// Writes a recipe into a bottle's `cxbottle.conf`, under `[EnvironmentVariables]`.
///
/// The bottle was created moments earlier for this one game, but the original file is still copied to
/// `cxbottle.conf.nxshelf-backup` first, so the change can be undone by hand.
enum BottleConfigEditor {
    /// Section that holds the bottle's environment.
    static let section = "[EnvironmentVariables]"
    /// Key CrossOver reads for the graphics backend (unverified against a live CrossOver; adjust here).
    static let graphicsBackendKey = "CX_GRAPHICS_BACKEND"
    /// Backup file suffix.
    static let backupSuffix = ".nxshelf-backup"

    /// The variables a recipe sets.
    static func variables(for recipe: GameRecipe) -> [String: String] {
        var variables = recipe.environment
        variables[graphicsBackendKey] = recipe.graphicsBackend.settingValue
        variables[recipe.syncMode.environmentVariable] = "1"
        return variables
    }

    /// `text` with the recipe's variables set (existing keys replaced, the section added if missing).
    static func applying(_ recipe: GameRecipe, to text: String) -> String {
        let variables = variables(for: recipe)
        var lines = text.components(separatedBy: "\n").filter { line in
            !variables.keys.contains { key in line.trimmingCharacters(in: .whitespaces).hasPrefix("\"\(key)\"") }
        }
        let newLines = variables.keys.sorted().compactMap { key in variables[key].map { "\"\(key)\" = \"\($0)\"" } }
        if let index = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == section }) {
            lines.insert(contentsOf: newLines, at: index + 1)
        } else {
            if lines.last?.isEmpty == false {
                lines.append("")
            }
            lines += [section] + newLines
        }
        return lines.joined(separator: "\n")
    }

    /// Backs up and rewrites the bottle's config.
    static func apply(_ recipe: GameRecipe, toConfigAt path: String, files: any FileOperating) throws {
        guard files.fileExists(atPath: path) else { throw BottleInstallError.bottleConfigMissing }
        let original = try String(bytes: files.readData(atPath: path), encoding: .utf8) ?? ""
        let backup = path + backupSuffix
        if !files.fileExists(atPath: backup) {
            try files.copyItem(atPath: path, toPath: backup)
        }
        try files.writeData(Data(applying(recipe, to: original).utf8), toPath: path)
    }
}
