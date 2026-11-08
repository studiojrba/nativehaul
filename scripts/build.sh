#!/usr/bin/env bash
# Generates the project, builds the app, and runs unit tests.
#
# One canonical build output (ADR 0029): this builds into Xcode's default DerivedData for the project — the same
# folder Xcode itself uses — so there is exactly one Retriever.app on this Mac to launch:
#   ~/Library/Developer/Xcode/DerivedData/Playrite-<hash>/Build/Products/Debug/Retriever.app
# Never pass -derivedDataPath here; a second build folder means a second launchable copy.
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/bootstrap.sh
mkdir -p build
xcodebuild -project Playrite.xcodeproj -scheme Playrite -configuration Debug -destination 'platform=macOS,arch=arm64' \
  build test 2>&1 | tee build/xcodebuild.log | grep -E "\.swift:[0-9]+:[0-9]+: (error|warning)|\*\* (BUILD|TEST)|Test run|✘" | awk '!seen[$0]++' || true
grep -q "\*\* TEST SUCCEEDED \*\*" build/xcodebuild.log
products=$(xcodebuild -project Playrite.xcodeproj -scheme Playrite -configuration Debug -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ BUILT_PRODUCTS_DIR /{print $2; exit}')
echo "Canonical app: $products/Retriever.app"
