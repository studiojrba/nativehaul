/// Plays the looping background music.
@MainActor
protocol MusicPlaying: AnyObject {
    /// Whether music is currently audible or fading in.
    var isPlaying: Bool { get }
    /// Starts (or resumes) the loop, fading in to `volume`.
    func play(volume: Double)
    /// Changes the volume of the playing loop at once.
    func setVolume(_ volume: Double)
    /// Fades the loop out, then stops it.
    func fadeOutAndStop()
}
