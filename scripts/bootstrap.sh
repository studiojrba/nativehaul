#!/usr/bin/env bash
# Regenerates Playrite.xcodeproj from project.yml. Requires: brew install xcodegen swiftformat swiftlint
set -euo pipefail
cd "$(dirname "$0")/.."
for tool in xcodegen swiftformat swiftlint; do
  command -v "$tool" >/dev/null || { echo "Missing $tool — run: brew install $tool"; exit 1; }
done
xcodegen generate --spec project.yml
