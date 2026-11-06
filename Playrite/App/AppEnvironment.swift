import Foundation
import Observation
import SwiftData

/// Dependency container. Wires live services for the app and mocks for previews (ADR 0002).
@MainActor
@Observable
final class AppEnvironment {
    /// SwiftData container backing the repository.
    let container: ModelContainer
    /// Library persistence.
    let repository: any LibraryRepository
    /// JSON import/export.
    let transfer: any LibraryTransferring

    /// Creates an environment from explicit dependencies.
    init(container: ModelContainer, repository: any LibraryRepository, transfer: any LibraryTransferring) {
        self.container = container
        self.repository = repository
        self.transfer = transfer
    }

    /// Live environment using the on-disk store.
    static func live() throws -> AppEnvironment {
        let container = try ModelContainerFactory.make(inMemory: false)
        let repository = SwiftDataLibraryRepository(context: container.mainContext)
        return AppEnvironment(
            container: container,
            repository: repository,
            transfer: LibraryTransferService(repository: repository)
        )
    }

    /// Seeded in-memory environment for SwiftUI previews.
    static var preview: AppEnvironment {
        do {
            let repository = try MockLibraryRepository(seeded: true)
            return AppEnvironment(
                container: repository.container,
                repository: repository,
                transfer: LibraryTransferService(repository: repository)
            )
        } catch {
            fatalError("Preview environment could not be created: \(error)")
        }
    }

    /// Builds the library view model.
    func makeLibraryViewModel() -> LibraryViewModel {
        let viewModel = LibraryViewModel(repository: repository, transfer: transfer)
        viewModel.reload()
        return viewModel
    }
}
