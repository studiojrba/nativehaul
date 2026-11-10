#!/usr/bin/env bash
# Formats then lints. Pass --check to fail instead of rewriting.
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${1:-}" == "--check" ]]; then
  swiftformat NXShelf NXShelfTests --lint
else
  swiftformat NXShelf NXShelfTests
fi
swiftlint lint --strict --quiet
