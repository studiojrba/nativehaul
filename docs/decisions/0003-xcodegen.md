# ADR 0003 — XcodeGen for a reproducible project

**Status:** Accepted · 2026-11-06

## Context
`.pbxproj` files are hard to review and conflict constantly across feature branches.

## Decision
`project.yml` (XcodeGen) is the single source of truth. The generated `Playrite.xcodeproj` is git-ignored and
recreated with `./scripts/bootstrap.sh`. Folder structure on disk = group structure in Xcode.

## Consequences
- Clean diffs; adding a file only needs it to exist in the right folder.
- Contributors need `brew install xcodegen` and must re-run bootstrap after adding/removing files.
- Build settings (Swift 6, strict concurrency, arm64, macOS 15) are reviewable in plain YAML.
