# Playrite — Progress Log

Living status log. Each branch appends its section. Legend: ✅ built & compiles · 🧪 unit-tested · 🟡 stubbed · ⛔ blocked.

## Session decisions (overnight build, 2026-11-06)
- **Empty upstream repo**: `origin/main` had no commits. Since nothing may be committed to `main`, feature
  branches are **stacked** — each branches from the previous feature branch's tip. Merge in order 0 → 7.
- **Tooling**: installed `xcodegen`, `swiftformat`, `swiftlint` via Homebrew. Project generated from `project.yml`;
  `Playrite.xcodeproj` is git-ignored. Run `./scripts/bootstrap.sh` then open `Playrite.xcodeproj`.
- **Toolchain observed**: Xcode 27.2, Swift 6.4.2, macOS 26.6 host; deployment target macOS 15.0, arm64 only.
- **Targets**: single app target `Playrite` with strict feature folders (ADR 0005) + `PlayriteTests` (Swift Testing, app-hosted).
- **Push blocked**: `gh` active account `jr-resilia` gets 403 on `studiojrba/Playrite`; see `BLOCKED.md`. All branches are committed locally and must be pushed in the morning (one-liner in BLOCKED.md).
- **Standards addendum** applied from foundation: README, ADRs in `docs/decisions/`, Conventional Commits, mocks + previews, CI planned post-V1.
- **Not sandboxed** (needs `~/Switch/Games` observation, external engine launch, Trash moves). Ad-hoc signed locally.
- **UI**: owner will supply Figma designs later → all views token-driven (`DesignTokens`, `Theme`) and compositional.
  A SwiftLint custom rule blocks numeric literals in `.padding/.frame/.cornerRadius/.spacing` outside DesignSystem.
- Git author for this session: `studiojrba <jr@studiojrba.com>` (repo-local config).

## 0 · feature/project-foundation
- ✅ `CLAUDE.md` project rules, `README.md` quickstart + map, `docs/PLAN.md` roadmap (+ CI next step), ADRs 0001–0006.
- ✅ `project.yml` (XcodeGen), `.swiftformat`, `.swiftlint.yml`, `.gitignore` (blocks keys/game files).
- ✅ `scripts/bootstrap.sh`, `scripts/lint.sh`, `scripts/build.sh` (xcodebuild build + test).
- ✅ `Shared/DesignSystem/{DesignTokens,Theme}`, `App/` entry + placeholder root view with preview. 🧪 1 smoke test.
- ⛔ Not pushed (see BLOCKED.md).
- Build: `** BUILD SUCCEEDED **`, `** TEST SUCCEEDED **`. Lint: clean.
