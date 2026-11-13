# ADR 0054 — The 0.1.0 design system: one token set, bundled fonts, Dark by default

**Status:** Accepted · 2026-11-13 (0.1.0 overnight run, Phase 1; spec `nativehaul-swift-spec.md` §1, §2, §3.0, §4)

## Context
0.1.0 replaces the Meebits-era look (near-black canvas, heavy rounded type, one gradient) with the Figma Make design:
warm paper by day, the same room in the evening by night, Instrument Serif headlines over Geist UI text, one ember
accent. Later phases (shell, Home, Library, Detail, Builds, Settings, Onboarding, Couch) build only on these tokens.
The spec requires both appearances from one token set, Dark on first launch with no flash of Light, and colour beyond
the palette to come only from game artwork.

## Decision
**Token map** (all under `nativehaul/Shared/DesignSystem/`):

| Spec | Swift |
|---|---|
| §2.1 core, §2.2 washes, §2.3 frost fill/edge | `ThemeTokens` (`.light` / `.dark`, raw `RGBA`); `Theme.paper`, `Theme.ink`, `Theme.wash(.sky)`… (appearance-following `Color`s) |
| Locked palette, `EVENING`, `AMBER`, traffic lights, ready dot | `Palette` |
| `mix()` | `RGBA.mixed(with:by:)` (linear sRGB lerp, 8-bit rounding) |
| §2.4 `elev-sm/elev/elev-lg` | `Elevation` + `.elevation(_:)` (two `ShadowLayer`s; CSS spread folded into the radius) |
| §2.5 `wash/glow/lift` | `GameTones` (`@Environment(\.gameTones)`), `GamePalette` |
| §2.6 ember, glow, focus, night artwork | `EmberFill`, `EmberButtonStyle`, `.accentGlow()`, `.focusRing(_:)`, `.nightArtwork()`, `AccentTokens` |
| §2.3 frosted glass | `.frostedGlass(in:)` (system material + frost fill + dark edge); `.smokedGlass(in:)` over artwork |
| §2.7 type | `Typeface.display/displayItalic/sans(_:weight:)`, `SansWeight`, `TypeStyle`, `Eyebrow`, `DisplayHeadline` |
| §2.8, §4.1, §4.2, §4.4 motion | `Motion` (`settle(_:)`, durations, rise/fade/float), `HeroTiming`, `ShelfPhysics`, `TypingTiming`, `CubicBezier` |
| §3 layout | `ShellLayout` (content column, nav island, top bar, wash, launch overlay), `KitMetrics` |
| §3–4 components | `Components/`: `FrostPill`, `SurfacePillButtonStyle`, `PressButtonStyle` + `.pressFeedback`, `ToggleSwitchStyle`/`ToggleSwitchTrack`, `SegmentedPill`, `WashBackground`, `ChevronButton`, `PillProgressBar`, `.riseIn()` |

- **One token set, resolved by the environment.** `Theme` colours are `NSColor`s with a dynamic provider, so SwiftUI
  resolves them through the view's `colorScheme` and AppKit through the effective appearance. Treatments that differ
  by more than colour (ember, glow, elevation) read `@Environment(\.colorScheme)` inside one component. No per-mode
  component forks.
- **Existing screens re-pointed, not redesigned.** The old role names (`Theme.canvas`, `secondaryText`, `surface`,
  `DesignTokens.Typography.*`, `EnergyLevel` fonts) now map onto the new tokens, so every screen picks up paper, ink,
  ember, warm elevation and the new faces. Pure black (trailer backdrop, artwork scrim) became the evening tones; the
  cold `.ultraThinMaterial` capsules over artwork became smoked glass; the sampled artwork tint is warmed through the
  dark `glow` formula at night. The old `Palette` pairs and the rail's black shadow were removed.
- **Fonts are bundled** (SIL OFL 1.1, from github.com/google/fonts): `Geist-Variable.ttf`,
  `InstrumentSerif-Regular.ttf`, `InstrumentSerif-Italic.ttf` and their OFL texts, registered per process with
  `CTFontManagerRegisterFontsForURL` before the first window. Geist weights are set on its `wght` axis through a
  Core Text descriptor (deterministic, tested at 400/500/600). If registration fails, display falls back to New York
  and sans to SF Pro.
- **Dark before first paint.** `AppearanceController` (in `AppEnvironment`, Features/Appearance) owns the choice;
  `UserDefaultsAppearanceStore` persists it. `AppDelegate.applicationWillFinishLaunching` sets `NSApp.appearance`
  from the saved choice (Dark when none) before any window exists, and the root scenes add `.preferredColorScheme`.
  Settings → Appearance (a `SegmentedPill`) toggles it instantly; the sidebar toggle arrives with the new shell.
- **Palette from artwork.** `GamePaletteExtracting` (live `ArtworkPaletteExtractor`: ImageIO thumbnail at 32 px, off
  the main actor; `MockGamePaletteExtractor`) feeds `PaletteAnalysis`: chroma-weighted hue histogram for `mid`,
  darkest quarter settled toward evening for `deep`, tints for `light`/`wash`/`ink`; `GamePalette.neutral` when there
  is no art.
- **Convenience wins (ADR 0016):** Dark is the default without asking; nothing to configure.

## Consequences
- The accent-discipline test now also allows the design-system components that own accent treatments.
- Warm structural colours are tested for warmth (no cold or pure-black structure) instead of the old neutral greys.
- CSS shadows, blur saturation (1.4) and `brightness(1.03)` are approximations in SwiftUI; the look needs J.R's visual
  pass in both modes.
- The Make code's nested `mix(mix(…))` actually yields `NaN` (its `hex()` cannot parse the `rgb()` string `mix`
  returns); the Swift version implements the spec's stated formula.
- `DesignIntensity`/`EnergyLevel` stay (Home still reads them); Phase 2 replaces Home and can retire them.
