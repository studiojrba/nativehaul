#!/usr/bin/env bash
# Generates the project, builds the app, and runs unit tests.
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/bootstrap.sh
xcodebuild -project Playrite.xcodeproj -scheme Playrite -destination 'platform=macOS,arch=arm64' \
  -derivedDataPath build/DerivedData build test 2>&1 | tee build/xcodebuild.log | grep -E "\.swift:[0-9]+:[0-9]+: (error|warning)|\*\* (BUILD|TEST)|Test run|✘" || true
grep -q "\*\* TEST SUCCEEDED \*\*" build/xcodebuild.log
