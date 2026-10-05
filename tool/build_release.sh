#!/usr/bin/env bash
# Build the Play release bundle with obfuscated Dart AND keep the symbols, then
# upload them to Crashlytics so Dart stack traces are readable.
#
#   ./tool/build_release.sh            # build + upload symbols
#   ./tool/build_release.sh --no-upload
#
# Until 1.0.4 obfuscation came from `extra-gen-snapshot-options=--obfuscate` in
# android/gradle.properties, which threw the symbol map away: every Dart crash
# in Crashlytics read like `iq.ahb (tVe:1221)`. Symbols land in
# symbols/<version>/ (gitignored); keep that folder for every shipped build.
set -euo pipefail

cd "$(dirname "$0")/.."

# Firebase app id of in.getsnapdrop.app (android/app/google-services.json).
APP_ID="1:62956973537:android:1ef1c3da152991e12ef6a0"
VERSION="$(sed -n 's/^version: *//p' pubspec.yaml)"
SYMBOLS="symbols/${VERSION}"

flutter build appbundle --release --obfuscate --split-debug-info="$SYMBOLS"

AAB="build/app/outputs/bundle/release/app-release.aab"
jarsigner -verify "$AAB" >/dev/null
if unzip -p "$AAB" base/manifest/AndroidManifest.xml | strings \
    | grep -qE "AD_ID|READ_MEDIA|EXTERNAL_STORAGE"; then
  echo "error: manifest carries an ad-id/media/storage permission" >&2
  exit 1
fi

if [[ "${1:-}" != "--no-upload" ]]; then
  firebase crashlytics:symbols:upload --app="$APP_ID" "$SYMBOLS"
fi

echo "Built $AAB ($VERSION); symbols in $SYMBOLS"
