# Changelog

All notable changes to nativehaul are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html) (ADR 0051).

`scripts/release.sh` publishes the section for the version it releases as that release's notes, both on GitHub and
in the update window.

## [1.0.0] - Unreleased

The first public release: a shelf for Switch ports and emulated games on Apple Silicon Macs.

### Added
- **Adoption:** existing nxnative builds and ROM folders join the shelf with no rebuilding. A build's Switch title
  ID is read from the app itself.
- **Switch builds:** an on-by-default build pipeline driven by your own copy of nxnative, using your own keys and
  game files.
- **Emulators:** RetroArch, Dolphin, PCSX2, melonDS and PPSSPP are detected, and ROMs are matched to systems and
  launched in your emulator.
- **Library:** Home, Jump Back In and Recently Added, plus collections, series and stats.
- **Playtime:** hours played are tracked per game, and every figure shows its source.
- **Guides:** linked from GameFAQs with credit to the author. HowLongToBeat figures are labelled as estimates.
- **Media:** official Nintendo eShop images and descriptions via titledb. With your own keys, IGDB and SteamGridDB
  fill in the rest, and trailers play on game pages.
- **RetroAchievements:** progress and badges for emulated games, using your own username and API key.
- **Updates:** nativehaul updates itself through Sparkle, with signed updates and a daily check that asks before
  installing.
- **Privacy:** no telemetry, no account and no sign-in. Keys you paste stay in your Keychain.

[1.0.0]: https://github.com/studiojrba/nativehaul/releases/tag/v1.0.0
