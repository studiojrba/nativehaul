import Foundation
import Observation

/// Drives the Steam setup flow: signed out → signed in, key needed → ready to sync.
///
/// Sign-in only proves which Steam account is the user's. Reading the library, playtime and achievements needs a
/// Steam API key, so the flow never presents the key as optional for syncing.
@MainActor
@Observable
final class SteamConnectionViewModel {
    /// The key being pasted (cleared after saving; the stored key is never read back).
    var keyInput = ""
    /// Account name and avatar, after the key was checked.
    private(set) var profile: SteamProfileSummary?
    /// Downloaded avatar bytes (the avatar is never hotlinked).
    private(set) var avatarData: Data?
    /// A problem to explain, if any.
    private(set) var notice: SteamSetupNotice?
    /// Result of the last sync.
    private(set) var lastSummary: SteamSyncSummary?
    /// `true` while signing in, checking the key or syncing.
    private(set) var isWorking = false
    /// Manual fallback (SteamID64 + key typed by hand).
    let manual: SteamSettingsViewModel

    private let account: any SteamAccountStoring
    private let signInService: any SteamSigningIn
    private let sync: any SteamSyncing
    private let opener: any URLOpening
    private let http: (any HTTPClient)?
    private let onChanged: @MainActor () -> Void
    private var revision = 0

    /// Creates the view model. `http` downloads the avatar; `onChanged` runs after the account or library changes.
    init(
        account: any SteamAccountStoring,
        signIn: any SteamSigningIn,
        sync: any SteamSyncing,
        opener: any URLOpening,
        http: (any HTTPClient)? = nil,
        onChanged: @escaping @MainActor () -> Void = {}
    ) {
        self.account = account
        signInService = signIn
        self.sync = sync
        self.opener = opener
        self.http = http
        self.onChanged = onChanged
        manual = SteamSettingsViewModel(account: account)
        manual.onSaved = { [weak self] in self?.accountDidChange() }
    }

    /// The current state, derived from what is stored.
    var stage: SteamSetupStage {
        _ = revision
        if account.steamID == nil {
            return .signedOut
        }
        return account.hasAPIKey ? .readyToSync : .keyNeeded
    }

    /// The linked SteamID64, for display.
    var steamID: String? {
        _ = revision
        return account.steamID?.rawValue
    }

    /// Name to greet the user with.
    var accountName: String {
        profile?.personaName ?? steamID.map { "Steam account \($0)" } ?? "Steam account"
    }

    /// "Sign in through Steam".
    func signIn() async {
        await work {
            _ = try await signInService.signIn()
            accountDidChange()
            if stage == .readyToSync {
                await checkKey()
            }
        }
    }

    /// Unlinks the Steam account. The key stays in the Keychain until removed.
    func signOut() {
        signInService.signOut()
        profile = nil
        avatarData = nil
        notice = nil
        lastSummary = nil
        accountDidChange()
    }

    /// Opens steamcommunity.com/dev/apikey.
    func openKeyPage() {
        SteamLinks.apiKeyPage.map(opener.open)
    }

    /// Opens the user's Steam privacy settings.
    func openPrivacySettings() {
        SteamLinks.privacySettings.map(opener.open)
    }

    /// Saves the pasted key to the Keychain, then checks it with one lightweight call.
    func saveKey() async {
        guard !keyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        await work {
            try account.saveAPIKey(keyInput)
            keyInput = ""
            accountDidChange()
            await checkKey()
        }
    }

    /// Removes the key from the Keychain.
    func removeKey() {
        try? account.removeAPIKey()
        profile = nil
        avatarData = nil
        accountDidChange()
    }

    /// Re-checks the stored key and loads the account name (on appear, when ready).
    func refreshProfile() async {
        guard stage == .readyToSync, profile == nil, !isWorking else { return }
        await work { await checkKey() }
    }

    /// Imports owned games and Steam playtime.
    func syncNow() async {
        guard stage == .readyToSync else { return }
        await work {
            do {
                lastSummary = try await sync.syncOwnedGames()
                notice = nil
                onChanged()
            } catch {
                notice = Self.notice(for: error)
            }
        }
    }

    private func checkKey() async {
        do {
            profile = try await sync.loadProfile()
            notice = profile?.isProfilePublic == false ? .privateGameDetails : nil
            await loadAvatar()
        } catch SteamError.invalidAPIKey {
            try? account.removeAPIKey()
            accountDidChange()
            notice = .keyRejected
        } catch {
            notice = Self.notice(for: error)
        }
    }

    private func loadAvatar() async {
        guard let http, let url = profile?.avatarURL,
              let (data, _) = try? await http.data(for: URLRequest(url: url)),
              ImageFormat.detect(data) != nil
        else { return }
        avatarData = data
    }

    private func work(_ body: () async throws -> Void) async {
        guard !isWorking else { return }
        isWorking = true
        defer { isWorking = false }
        do {
            try await body()
        } catch SteamSignInError.cancelled {
            notice = nil
        } catch {
            notice = Self.notice(for: error)
        }
    }

    private func accountDidChange() {
        revision += 1
        onChanged()
    }

    private static func notice(for error: any Error) -> SteamSetupNotice {
        switch error {
        case SteamError.profileNotPublic: .privateGameDetails
        case SteamError.invalidAPIKey: .keyRejected
        default: .message(error.localizedDescription)
        }
    }
}
