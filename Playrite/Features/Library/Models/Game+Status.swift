import Foundation

extension Game {
    /// Changes status, stamping or clearing ``completedAt`` as appropriate.
    func updateStatus(_ newStatus: GameStatus, at date: Date = .now) {
        guard newStatus != status else { return }
        status = newStatus
        completedAt = newStatus == .completed ? date : nil
    }
}
