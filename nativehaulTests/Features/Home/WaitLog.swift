import Foundation

/// Records how long the hero carousel asked to wait (``HeroCarouselTests``).
actor WaitLog {
    private(set) var values: [Double] = []

    func record(_ seconds: Double) {
        values.append(seconds)
    }
}
