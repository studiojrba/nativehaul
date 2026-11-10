#!/usr/bin/env bash
# Formats then lints. Pass --check to fail instead of rewriting.
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${1:-}" == "--check" ]]; then
  swiftformat nativehaul nativehaulTests --lint
else
  swiftformat nativehaul nativehaulTests
fi
swiftlint lint --strict --quiet
