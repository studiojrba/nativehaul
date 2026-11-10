@testable import NXShelf
import Testing

@MainActor
struct SteamSettingsViewModelTests {
    @Test func saveClearsKeyFieldAndReportsStored() {
        let account = MockSteamAccountStore(configured: false)
        let viewModel = SteamSettingsViewModel(account: account)
        viewModel.apiKeyInput = "KEY"
        viewModel.steamIDInput = "76561197960287930"
        viewModel.save()
        #expect(viewModel.apiKeyInput.isEmpty)
        #expect(viewModel.hasAPIKey)
        #expect(!viewModel.isError)
    }

    @Test func invalidSteamIDIsRejected() {
        let viewModel = SteamSettingsViewModel(account: MockSteamAccountStore(configured: false))
        viewModel.steamIDInput = "123"
        viewModel.save()
        #expect(viewModel.isError)
        #expect(!viewModel.hasAPIKey)
    }
}
