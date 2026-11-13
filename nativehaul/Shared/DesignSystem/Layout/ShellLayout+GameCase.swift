import SwiftUI

// The case's reference build is token source (spec §3.3 `BoxCase`), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ShellLayout {
    /// The game case on Detail (spec §3.3 `BoxCase`), built at its reference size — a 105 × 170 mm face, 20 deep, as
    /// 300 × 484 × 20pt — and scaled to fit its column.
    enum GameCase {
        /// Face width.
        static let width: CGFloat = 300
        /// Face height.
        static let height: CGFloat = 484
        /// Depth (the spine's width).
        static let depth: CGFloat = 20
        /// Extra width around the case for the drag area (`W + 120`).
        static let areaExtraWidth: CGFloat = 120
        /// Extra height around the case for the drag area (`H + 90`).
        static let areaExtraHeight: CGFloat = 90
        /// Perspective distance (CSS `perspective: 1800px`).
        static let perspective: CGFloat = 1800
        /// Outer corner radius.
        static let outerRadius: CGFloat = 6
        /// Cover / inner panel radius.
        static let innerRadius: CGFloat = 3
        /// Header band height, as a share of the face's height.
        static let headerShare: CGFloat = 0.09
        /// Margin around the cover and inner panel, as a share of the face's width.
        static let insetShare: CGFloat = 0.025
        /// Header band side padding, as a share of the face's width (front).
        static let headerSideShare: CGFloat = 0.06
        /// Header band side padding on the back.
        static let backHeaderSideShare: CGFloat = 0.04
        /// Gap between the mark and the label, as a share of the face's width.
        static let headerGapShare: CGFloat = 0.04
        /// The mark's height, as a share of the header band.
        static let markShare: CGFloat = 0.52
        /// "Game Card" label size on the front (`0.5em` of 18px).
        static let frontLabelSize: CGFloat = 9
        /// "Game Card" label size on the back.
        static let backLabelSize: CGFloat = 9
        /// Label letter spacing (em).
        static let labelTrackingEm: CGFloat = 0.14
        /// Back panel padding.
        static let backPadding: CGFloat = 16
        /// Gap between the back panel's parts.
        static let backGap: CGFloat = 12
        /// Back heading size (display).
        static let backHeadingSize: CGFloat = 22
        /// Back screenshot gap.
        static let backShotGap: CGFloat = 6
        /// Back screenshot radius.
        static let backShotRadius: CGFloat = 2
        /// Back screenshot aspect (16:9).
        static let backShotAspect: CGFloat = 16.0 / 9.0
        /// Back screenshots shown at most (2 × 2).
        static let backShotCount = 4
        /// Back description size.
        static let backDescriptionSize: CGFloat = 9.5
        /// Back description line spacing (line-height 1.5).
        static let backDescriptionLineSpacing: CGFloat = 4.75
        /// Back description lines at most.
        static let backDescriptionLines = 9
        /// Back footer size.
        static let footerSize: CGFloat = 8
        /// Back footer letter spacing (em, Tailwind `tracking-wider`).
        static let footerTrackingEm: CGFloat = 0.05
        /// Barcode height.
        static let barcodeHeight: CGFloat = 28
        /// Gap between barcode bars.
        static let barcodeGap: CGFloat = 1.5
        /// Spine vertical padding.
        static let spinePadding: CGFloat = 12
        /// Spine mark size.
        static let spineMark: CGFloat = 12
        /// Spine title size.
        static let spineTitleSize: CGFloat = 10
        /// Spine mark to title.
        static let spineTitleTop: CGFloat = 12
        /// Sheen gradient base angle (CSS degrees).
        static let sheenBaseAngle: Double = 105
        /// Sheen angle per degree of facing.
        static let sheenAnglePerDegree: Double = 0.3
        /// Sheen: where the band starts.
        static let sheenStart: CGFloat = 0.30
        /// Sheen: where it peaks.
        static let sheenMiddle: CGFloat = 0.48
        /// Sheen: where it ends.
        static let sheenEnd: CGFloat = 0.62
        /// Sheen peak white alpha.
        static let sheenPeak: Double = 0.28
        /// Floor shadow width: base share of the face width.
        static let floorBase: CGFloat = 0.75
        /// Floor shadow width: extra share at full facing (`|cos(rotateY)| × 0.2`).
        static let floorFacing: CGFloat = 0.20
        /// Floor shadow height.
        static let floorHeight: CGFloat = 40
        /// Floor shadow blur radius (CSS `blur-2xl`).
        static let floorBlur: CGFloat = 20
        /// Floor shadow distance above the drag area's bottom (`bottom-2`).
        static let floorBottom: CGFloat = 8
        /// Turn button: gap above it.
        static let buttonTop: CGFloat = 8
        /// Turn button: horizontal padding.
        static let buttonHorizontal: CGFloat = 16
        /// Turn button: vertical padding.
        static let buttonVertical: CGFloat = 8
        /// Turn button: rotate icon size.
        static let buttonIcon: CGFloat = 14
        /// Turn button: gap between its parts.
        static let buttonGap: CGFloat = 8
        /// Room the turn button takes under the case at full size (gap, padding and a line).
        static let turnButtonRoom: CGFloat = 50
        /// Back screenshot columns.
        static let backShotColumns = 2
        /// The case never scales below this share of its reference size.
        static let minimumScale: CGFloat = 0.45
    }
}

// swiftlint:enable no_magic_numbers
