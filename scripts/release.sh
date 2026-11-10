#!/usr/bin/env bash
# Builds a signed, notarized and stapled nativehaul DMG plus its Sparkle appcast (ADR 0051).
#
#   scripts/release.sh                      full release build into build/release/<version>/ (no upload)
#   scripts/release.sh --skip-notarize      everything except notarization and stapling (for local checks)
#   scripts/release.sh --publish            also tags v<version> and creates the GitHub release with the DMG
#                                           and appcast.xml (asks for confirmation first)
#
# One-time setup on the release Mac:
#   - a "Developer ID Application" certificate in the login Keychain;
#   - notarization credentials saved under the profile below, for example:
#       xcrun notarytool store-credentials nativehaul-notary --apple-id <apple-id> --team-id <team-id>
#     (it prompts for an app-specific password; nothing is stored in the repo);
#   - the Sparkle update key in the login Keychain (generate_keys --account nativehaul, ADR 0050).
#
# The version comes from project.yml (MARKETING_VERSION, semantic; CURRENT_PROJECT_VERSION, an integer that must
# grow with every release because Sparkle compares it). The notes come from that version's CHANGELOG.md section.
set -euo pipefail
cd "$(dirname "$0")/.."

notary_profile="${NOTARY_PROFILE:-nativehaul-notary}"
sparkle_account="nativehaul"
repo="studiojrba/nativehaul"
notarize=true
publish=false
for arg in "$@"; do
  case "$arg" in
    --skip-notarize) notarize=false ;;
    --publish) publish=true ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done
if $publish && ! $notarize; then
  echo "--publish needs notarization; drop --skip-notarize." >&2
  exit 2
fi

fail() { echo "release: $*" >&2; exit 1; }
step() { printf '\n==> %s\n' "$*"; }

version=$(awk -F'"' '/MARKETING_VERSION:/{print $2; exit}' project.yml)
build=$(awk -F'"' '/CURRENT_PROJECT_VERSION:/{print $2; exit}' project.yml)
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "MARKETING_VERSION '$version' is not semantic (MAJOR.MINOR.PATCH)."
[[ "$build" =~ ^[0-9]+$ ]] || fail "CURRENT_PROJECT_VERSION '$build' is not an integer."
grep -q "^## \[$version\]" CHANGELOG.md || fail "CHANGELOG.md has no '## [$version]' section."

step "Preflight for nativehaul $version ($build)"
identity=$(security find-identity -v -p codesigning | awk -F'"' '/Developer ID Application/{print $2; exit}')
[[ -n "$identity" ]] || fail "No 'Developer ID Application' certificate in the Keychain."
team=$(sed -E 's/.*\(([A-Z0-9]{10})\)$/\1/' <<<"$identity")
echo "Signing as: $identity"
if $notarize; then
  xcrun notarytool history --keychain-profile "$notary_profile" >/dev/null 2>&1 \
    || fail "No notarization credentials under profile '$notary_profile' (see the setup notes at the top)."
fi
if $publish; then
  [[ -z "$(git status --porcelain)" ]] || fail "The working tree has uncommitted changes."
  git rev-parse "v$version" >/dev/null 2>&1 && fail "Tag v$version already exists."
fi

out="build/release/$version"
rm -rf "$out"
mkdir -p "$out"
archive="$out/nativehaul.xcarchive"

step "Archive (Release, Developer ID, hardened runtime)"
./scripts/bootstrap.sh
xcodebuild -project nativehaul.xcodeproj -scheme nativehaul -configuration Release \
  -destination 'generic/platform=macOS' -archivePath "$archive" archive \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="Developer ID Application" DEVELOPMENT_TEAM="$team" \
  OTHER_CODE_SIGN_FLAGS="--timestamp" ENABLE_HARDENED_RUNTIME=YES ENABLE_TESTABILITY=NO \
  >"$out/archive.log" 2>&1 || { tail -30 "$out/archive.log"; fail "Archive failed (log: $out/archive.log)."; }

step "Export for Developer ID"
cat >"$out/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>developer-id</string>
  <key>signingStyle</key><string>manual</string>
  <key>signingCertificate</key><string>Developer ID Application</string>
  <key>teamID</key><string>$team</string>
</dict>
</plist>
PLIST
xcodebuild -exportArchive -archivePath "$archive" -exportPath "$out/export" \
  -exportOptionsPlist "$out/ExportOptions.plist" >"$out/export.log" 2>&1 \
  || { tail -30 "$out/export.log"; fail "Export failed (log: $out/export.log)."; }
app="$out/export/nativehaul.app"

step "Verify the app's signature"
codesign --verify --deep --strict --verbose=2 "$app"
codesign -dv "$app" 2>&1 | grep -E "^(Authority=Developer ID Application|TeamIdentifier|Runtime Version)" \
  || fail "The app is not signed with Developer ID and the hardened runtime."
plist="$app/Contents/Info.plist"
[[ "$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$plist")" == "$version" ]] \
  || fail "Built version does not match $version."
[[ -d "$app/Contents/Frameworks/Sparkle.framework" ]] || fail "Sparkle.framework is missing."

notarize_and_staple() {
  local item="$1"
  step "Notarize $(basename "$item")"
  if [[ "$item" == *.app ]]; then
    local zip="$out/notarize-app.zip"
    ditto -c -k --keepParent "$item" "$zip"
    xcrun notarytool submit "$zip" --keychain-profile "$notary_profile" --wait
    rm -f "$zip"
  else
    xcrun notarytool submit "$item" --keychain-profile "$notary_profile" --wait
  fi
  xcrun stapler staple "$item"
  xcrun stapler validate "$item"
}
$notarize && notarize_and_staple "$app"

step "Build the DMG"
dmg="$out/nativehaul-$version.dmg"
staging="$out/dmg"
mkdir -p "$staging"
ditto "$app" "$staging/nativehaul.app"
ln -s /Applications "$staging/Applications"
hdiutil create -volname "nativehaul" -srcfolder "$staging" -fs HFS+ -format UDZO -ov "$dmg" >/dev/null
rm -rf "$staging"
codesign --force --timestamp --identifier "com.studiojrba.nativehaul.dmg" --sign "$identity" "$dmg"
codesign --verify --verbose=2 "$dmg"
$notarize && notarize_and_staple "$dmg"

if $notarize; then
  step "Gatekeeper assessment"
  spctl --assess --type open --context context:primary-signature --verbose=2 "$dmg"
  spctl --assess --type execute --verbose=2 "$app"
fi

step "Sparkle appcast"
sparkle_bin=$(find ~/Library/Developer/Xcode/DerivedData -path '*SourcePackages/artifacts/sparkle/Sparkle/bin' \
  -type d 2>/dev/null | head -1)
[[ -n "$sparkle_bin" ]] || fail "Sparkle's tools were not found; run scripts/bootstrap.sh and resolve packages."
updates="$out/updates"
mkdir -p "$updates"
cp "$dmg" "$updates/"
notes=$(awk -v v="$version" '
  $0 ~ "^## \\[" v "\\]" { on = 1; next }
  on && /^## \[/ { exit }
  on && /^\[[0-9]/ { next }
  on { print }' CHANGELOG.md)
printf '%s\n' "$notes" >"$out/notes.md"
# Sparkle uses a .md file named like the archive as that update's notes.
cp "$out/notes.md" "$updates/nativehaul-$version.md"
"$sparkle_bin/generate_appcast" --account "$sparkle_account" \
  --download-url-prefix "https://github.com/$repo/releases/download/v$version/" \
  --embed-release-notes \
  --link "https://github.com/$repo" -o "$out/appcast.xml" "$updates"
grep -q "sparkle:edSignature" "$out/appcast.xml" || fail "The appcast has no EdDSA signature."
grep -q "<sparkle:version>$build</sparkle:version>" "$out/appcast.xml" || fail "The appcast build number is not $build."

step "Done"
shasum -a 256 "$dmg" | tee "$out/SHA256SUMS"
echo "DMG:     $dmg"
echo "Appcast: $out/appcast.xml"
$notarize || echo "NOT notarized (--skip-notarize): for local checks only, never for publishing."

if $publish; then
  read -r -p "Tag v$version and publish the GitHub release with the DMG and appcast? [y/N] " answer
  [[ "$answer" == "y" ]] || fail "Not published."
  git tag -a "v$version" -m "nativehaul $version"
  git push origin "v$version"
  gh release create "v$version" "$dmg" "$out/appcast.xml" "$out/SHA256SUMS" -R "$repo" \
    --title "nativehaul $version" --notes-file "$out/notes.md"
fi
