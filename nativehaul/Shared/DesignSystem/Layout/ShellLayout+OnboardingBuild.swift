import SwiftUI

// Scene metrics are token source (make-export-nov13 Onboarding.tsx, 1:1), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ShellLayout {
    /// Onboarding's build tutorial, emulator and closing scenes (0.1.1): Make's Tailwind values, 1:1.
    enum OnboardingBuild {
        /// The frosted panel's radius (`rounded-[36px]`).
        static let panelRadius: CGFloat = 36
        /// The panel's `surface` opacity (`bg-surface/55`).
        static let panelOpacity: Double = 0.55
        /// Panel padding (`p-8`).
        static let panelPadding: CGFloat = 32
        /// Smaller panel padding (`p-7`).
        static let panelPaddingCompact: CGFloat = 28
        /// Steps and demo panel maximum width (`max-w-[650px]`).
        static let panelMaxWidth: CGFloat = 650
        /// Folder card maximum width (`max-w-[620px]`).
        static let folderMaxWidth: CGFloat = 620
        /// Eyebrow to content (`mt-6`).
        static let contentTop: CGFloat = 24

        /// Step card grid gap (`gap-4`).
        static let stepGap: CGFloat = 16
        /// Step card radius (`rounded-[24px]`).
        static let stepRadius: CGFloat = 24
        /// Step card padding (`p-5`).
        static let stepPadding: CGFloat = 20
        /// Step icon chip (`h-9 w-9`).
        static let stepChip: CGFloat = 36
        /// Step icon chip radius (`rounded-xl`).
        static let stepChipRadius: CGFloat = 12
        /// Step icon (`size={17}`).
        static let stepIcon: CGFloat = 17
        /// Chip to number (`gap-3`).
        static let stepChipGap: CGFloat = 12
        /// Chip row to title (`mt-5`).
        static let stepTitleTop: CGFloat = 20
        /// Step title size (`text-[17px]`).
        static let stepTitle: CGFloat = 17
        /// Title to note (`mt-1`).
        static let stepNoteTop: CGFloat = 4

        /// Folder card: cover to text (`gap-8`).
        static let folderGap: CGFloat = 32
        /// Folder card cover width (`w-44`).
        static let folderCover: CGFloat = 176
        /// Folder card cover radius (`rounded-[24px]`).
        static let folderCoverRadius: CGFloat = 24
        /// Folder card title (`text-[42px]`).
        static let folderTitle: CGFloat = 42
        /// Eyebrow to title (`mt-3`).
        static let folderTitleTop: CGFloat = 12
        /// Title to the parts list (`mt-6`).
        static let partsTop: CGFloat = 24
        /// Parts list top padding (`pt-4`).
        static let partsPadding: CGFloat = 16
        /// Between parts (`space-y-2`).
        static let partsGap: CGFloat = 8
        /// Part check icon (`size={14}`).
        static let partCheck: CGFloat = 14
        /// List to the pill (`mt-4`).
        static let pillTop: CGFloat = 16
        /// Pill horizontal padding (`px-3`).
        static let pillHorizontal: CGFloat = 12
        /// Pill vertical padding (`py-1.5`).
        static let pillVertical: CGFloat = 6

        /// Demo: cover size (`h-24 w-18`).
        static let demoCover = CGSize(width: 72, height: 96)
        /// Demo: cover radius (`rounded-[16px]`).
        static let demoCoverRadius: CGFloat = 16
        /// Demo: cover to title (`gap-5`).
        static let demoHeaderGap: CGFloat = 20
        /// Demo: title (`text-[34px]`).
        static let demoTitle: CGFloat = 34
        /// Demo: eyebrow to title (`mt-1`).
        static let demoTitleTop: CGFloat = 4
        /// Demo: percentage pill accent opacity (`bg-accent/15`).
        static let percentFill: Double = 0.15
        /// Demo: header to stages (`mt-7`).
        static let stagesTop: CGFloat = 28
        /// Demo: between stages (`gap-1.5`).
        static let stagesGap: CGFloat = 6
        /// Demo: stage bar height (`h-2`).
        static let stageBar: CGFloat = 8
        /// Demo: bar to label (`mt-2`).
        static let stageLabelTop: CGFloat = 8
        /// Demo: stages to log (`mt-6`).
        static let logTop: CGFloat = 24
        /// Demo: one run from 0 to 100% (seconds).
        static let demoRun: Double = 4.4
        /// Demo: run plus rest before looping (seconds).
        static let demoLoop: Double = 5.0
        /// Demo: refresh interval (seconds).
        static let demoTick: Double = 0.07

        /// Launch: the first cover (`w-36`).
        static let launchFirst: CGFloat = 144
        /// Launch: the other covers (`w-28`).
        static let launchOther: CGFloat = 112
        /// Launch: other covers' opacity (`opacity-65`).
        static let launchOtherOpacity: Double = 0.65
        /// Launch: cover radius (`rounded-[20px]`).
        static let launchRadius: CGFloat = 20
        /// Launch: covers gap (`gap-5`).
        static let launchGap: CGFloat = 20
        /// Launch: the Play pill hangs this far below the cover (`-bottom-4`).
        static let playDrop: CGFloat = 16
        /// Launch: Play pill horizontal padding (`px-4`).
        static let playHorizontal: CGFloat = 16
        /// Launch: Play pill vertical padding (`py-2`).
        static let playVertical: CGFloat = 8
        /// Launch: Play icon (`size={13}`).
        static let playIcon: CGFloat = 13
        /// Launch: covers to the footer (`mt-10`).
        static let footerTop: CGFloat = 40
        /// Launch: footer radius (`rounded-[20px]`).
        static let footerRadius: CGFloat = 20
        /// Launch: footer icon (`size={16}`).
        static let footerIcon: CGFloat = 16
        /// Covers shown on the launch card.
        static let launchCovers = 4

        /// Shelf tile grouping badge text (`text-[7px]`).
        static let badgeSize: CGFloat = 7
        /// Badge inset (`inset-x-1 bottom-1`).
        static let badgeInset: CGFloat = 4
        /// Badge padding (`px-1 py-1`).
        static let badgePadding: CGFloat = 4
        /// Badge radius (`rounded-md`).
        static let badgeRadius: CGFloat = 6
        /// Badge `bezel` opacity (`bg-bezel/85`).
        static let badgeOpacity: Double = 0.85

        /// Closing: maximum width (`max-w-[560px]`).
        static let closingMaxWidth: CGFloat = 560
        /// Closing: radius (`rounded-[40px]`).
        static let closingRadius: CGFloat = 40
        /// Closing: horizontal padding (`px-10`).
        static let closingHorizontal: CGFloat = 40
        /// Closing: vertical padding (`py-12`).
        static let closingVertical: CGFloat = 48
        /// Closing: the mark (`h-32 w-32`).
        static let closingMark: CGFloat = 128
        /// Closing: the check badge (`h-10 w-10`).
        static let checkBadge: CGFloat = 40
        /// Closing: the badge's offset past the mark's corner (`-bottom-2 -right-2`).
        static let checkOffset: CGFloat = 8
        /// Closing: the check glyph (`size={20}`).
        static let checkIcon: CGFloat = 20
        /// Closing: mark to title (`mt-8`).
        static let closingTitleTop: CGFloat = 32
        /// Closing: title (`text-[48px]`).
        static let closingTitle: CGFloat = 48
        /// Closing: title to subtitle (`mt-4`).
        static let closingSubTop: CGFloat = 16
        /// Closing: subtitle to card (`mt-7`).
        static let closingCardTop: CGFloat = 28
        /// Closing: card radius (`rounded-[22px]`).
        static let closingCardRadius: CGFloat = 22
        /// Closing: card horizontal padding (`px-5`).
        static let closingCardHorizontal: CGFloat = 20
        /// Closing: card vertical padding (`py-4`).
        static let closingCardVertical: CGFloat = 16
        /// Closing: card icon (`size={18}`).
        static let closingCardIcon: CGFloat = 18
        /// Closing: card icon to text (`gap-4`).
        static let closingCardGap: CGFloat = 16
        /// Closing: card title to sub (`mt-0.5`).
        static let closingCardSubTop: CGFloat = 2

        /// Emulators: banner horizontal padding (`px-5`).
        static let bannerHorizontal: CGFloat = 20
        /// Emulators: banner vertical padding (`py-3`).
        static let bannerVertical: CGFloat = 12
        /// Emulators: banner `mint` opacity (`bg-mint/70`).
        static let bannerOpacity: Double = 0.70
        /// Emulators: card radius (`rounded-[26px]`).
        static let cardRadius: CGFloat = 26
        /// Emulators: unselected card `surface` opacity (`bg-surface/45`).
        static let cardDimFill: Double = 0.45
        /// Emulators: icon chip (`h-14 w-14`).
        static let chip: CGFloat = 56
        /// Emulators: chip radius (`rounded-[18px]`).
        static let chipRadius: CGFloat = 18
        /// Emulators: chip initial (`text-[28px]`).
        static let chipInitial: CGFloat = 28
        /// Emulators: tick box (`h-5 w-5`).
        static let tickBox: CGFloat = 20
        /// Emulators: tick box radius (`rounded-md`).
        static let tickRadius: CGFloat = 6
        /// Emulators: tick glyph (`size={13}`).
        static let tickIcon: CGFloat = 13
        /// Emulators: installed check (`size={19}`).
        static let installedIcon: CGFloat = 19
        /// Emulators: chip to name (`mt-5`).
        static let nameTop: CGFloat = 20
        /// Emulators: name (`text-[18px]`).
        static let name: CGFloat = 18
        /// Emulators: status top (`mt-4`).
        static let statusTop: CGFloat = 16
        /// Emulators: status tracking (`tracking-[0.14em]`).
        static let statusTrackingEm: CGFloat = 0.14
        /// Emulators: the tick box's border: `ink` at this opacity (`border-ink/20`).
        static let tickBorderOpacity: Double = 0.20
        /// Most cards shown.
        static let maximumCards = 6
    }
}

// swiftlint:enable no_magic_numbers
