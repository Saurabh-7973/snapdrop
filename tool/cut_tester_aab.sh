#!/usr/bin/env bash
# Cut the closed-test AAB with a Guidester key, without the key touching git,
# a transcript, or your shell history.
#
#   1. Rotate the key in the Guidester dashboard (Settings -> key panel).
#      Rotating invalidates every build already installed, so this happens
#      once, immediately before the bundle is cut. D62.
#   2. Put the new key in tool/.guidester_key — gitignored, never committed.
#   3. ./tool/cut_tester_aab.sh
#
# Deliberately NOT passing --obfuscate. It renames every Dart class, which
# removes the SDK's layer 4 entirely: four of this app's five screens would
# report UNKNOWN for the whole test and nothing in the dashboard would say why.
# See guidester DECISIONS.md D67. Play's own R8 shrinking is unaffected by this
# and still applies to the Java/Kotlin side.
set -euo pipefail

cd "$(dirname "$0")/.."

KEY_FILE="tool/.guidester_key"
if [[ ! -f "$KEY_FILE" ]]; then
  echo "error: $KEY_FILE not found. Put the rotated key in it (one line)." >&2
  exit 1
fi

KEY="$(tr -d '[:space:]' < "$KEY_FILE")"
if [[ -z "$KEY" ]]; then
  echo "error: $KEY_FILE is empty." >&2
  exit 1
fi

echo "Building appbundle with a key of ${#KEY} characters (not printed)."
flutter build appbundle --release --dart-define=GUIDESTER_KEY="$KEY"

echo
echo "Bundle: build/app/outputs/bundle/release/app-release.aab"
echo "Next: upload to the Play internal test track, install it on the test"
echo "phone FROM PLAY (a local build cannot install over a Play-signed one),"
echo "then check the dashboard's onboarding step reports the launch ping"
echo "before sending any invites."
