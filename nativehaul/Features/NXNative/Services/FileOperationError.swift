import Foundation

/// Errors raised by ``InMemoryFileOperations``.
enum FileOperationError: Error, Equatable {
    case notFound(String)
    case alreadyExists(String)
}
