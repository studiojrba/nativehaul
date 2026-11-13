/// Plays the short interface sounds.
@MainActor
protocol UISoundPlaying: AnyObject {
    /// Plays `sound` without blocking. Rapid repeats never pile up.
    func play(_ sound: UISound)
}
