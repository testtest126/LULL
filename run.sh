#!/usr/bin/env bash
# LULL — one-command build, install, and launch on an iOS Simulator.
#
# Usage: ./run.sh
#
# Does not touch LULLKit or app/Sources. Only generates app/LULL.xcodeproj
# (already gitignored) and builds into a temp derived-data dir outside the repo.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$ROOT_DIR/app"
PROJECT_YML="$APP_DIR/project.yml"

log()  { printf '\033[1;36m==>\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$1" >&2; exit 1; }

command -v xcodegen >/dev/null 2>&1 || die "xcodegen not found. Install it with:  brew install xcodegen"
command -v jq >/dev/null 2>&1 || die "jq not found. Install it with:  brew install jq"

# xcode-select may point at a bare Command Line Tools install, which can't
# build iOS apps or run the simulator. Find a real Xcode.
find_full_xcode() {
  local selected candidate
  selected="$(xcode-select -p 2>/dev/null | sed 's:/Contents/Developer$::')"
  for candidate in "$selected" /Applications/Xcode.app /Applications/Xcode-beta.app; do
    [ -n "$candidate" ] || continue
    if [ -d "$candidate/Contents/Developer/Platforms/iPhoneSimulator.platform" ]; then
      printf '%s/Contents/Developer\n' "$candidate"
      return 0
    fi
  done
  return 1
}

if ! DEVELOPER_DIR="$(find_full_xcode)"; then
  die "No full Xcode install found (only Command Line Tools, or nothing). Install Xcode from the App Store, launch it once to accept the license, then re-run."
fi
export DEVELOPER_DIR
log "Using Xcode at $DEVELOPER_DIR"

log "Generating Xcode project..."
(cd "$APP_DIR" && xcodegen generate) || die "xcodegen generate failed."

SCHEME="$(awk -F': *' '/^name:/{print $2; exit}' "$PROJECT_YML")"
BUNDLE_ID="$(awk -F': *' '/PRODUCT_BUNDLE_IDENTIFIER/{print $2; exit}' "$PROJECT_YML" | tr -d '"')"
[ -n "$SCHEME" ] && [ -n "$BUNDLE_ID" ] || die "Could not read scheme/bundle id from $PROJECT_YML."

log "Selecting a simulator..."
SIM_JSON="$(xcrun simctl list devices available -j)"
UDID="$(jq -r '
  [ .devices | to_entries[] |
    (.key | capture("iOS-(?<maj>[0-9]+)-(?<min>[0-9]+)"; "")) as $v |
    .value[] | select(.name | test("iPhone")) |
    { udid, state, maj: (($v.maj // "0") | tonumber), min: (($v.min // "0") | tonumber) }
  ] as $all
  | ($all | map(select(.state=="Booted"))) as $booted
  | if ($booted | length) > 0 then $booted[0].udid
    else ($all | sort_by(.maj, .min) | last | .udid // empty)
    end
' <<<"$SIM_JSON")"

[ -n "$UDID" ] && [ "$UDID" != "null" ] || die "No available iPhone simulator found. Open Xcode > Settings > Platforms and install an iOS simulator runtime."

SIM_NAME="$(jq -r --arg udid "$UDID" '.devices[][] | select(.udid==$udid) | .name' <<<"$SIM_JSON")"
log "Using simulator: $SIM_NAME ($UDID)"

log "Booting simulator (if needed)..."
xcrun simctl bootstatus "$UDID" -b >/dev/null || die "Simulator failed to boot."

open -a Simulator --args -CurrentDeviceUDID "$UDID" 2>/dev/null \
  || log "(Could not open the Simulator app UI — continuing headlessly. The app will still install and launch.)"

BUILD_DIR="${TMPDIR:-/tmp}/lull-sim-build"
log "Building LULL (this can take a minute the first time)..."
xcodebuild \
  -project "$APP_DIR/LULL.xcodeproj" \
  -scheme "$SCHEME" \
  -destination "id=$UDID" \
  -configuration Debug \
  -derivedDataPath "$BUILD_DIR" \
  build \
  || die "Build failed. See the log above."

APP_PATH="$BUILD_DIR/Build/Products/Debug-iphonesimulator/LULL.app"
[ -d "$APP_PATH" ] || die "Build succeeded but LULL.app was not found at $APP_PATH."

log "Installing..."
xcrun simctl install "$UDID" "$APP_PATH" || die "Install failed."

log "Launching..."
xcrun simctl launch "$UDID" "$BUNDLE_ID" || die "Launch failed."

open -a Simulator 2>/dev/null || true

log "LULL is running on $SIM_NAME. Enjoy — alone, in the dark."
