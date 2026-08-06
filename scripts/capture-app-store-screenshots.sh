#!/usr/bin/env bash
set -euo pipefail

# App Store captures are DEBUG-only bundled-fixture UI evidence. They do not
# import media into Simulator Photos, grant Photos permission, or exercise
# PhotoKit. Real PhotoKit behavior is validated by separate adapter/device QA.

project_root="$(cd "$(dirname "$0")/.." && pwd)"
requested_device_id="${WK_APPSTORE_SIMULATOR_UDID:-9C794F17-634B-4B7A-86A9-AEE88EE575FF}"
device_id="$requested_device_id"
device_name="Weekkeep AppStore 6.9"
device_type_id="com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max"
runtime_id="com.apple.CoreSimulator.SimRuntime.iOS-26-5"
bundle_id="com.solkim.weekkeep"
raw_root="${WK_APPSTORE_RAW_ROOT:-$project_root/release/local/app-store-6.9-raw}"
final_root="${WK_APPSTORE_FINAL_ROOT:-$project_root/release/screenshots/app-store-6.9}"
fixture_root="$project_root/design/fixtures/app-store-family-moments"
erase_device=1

usage() {
  echo "Usage: scripts/capture-app-store-screenshots.sh [--no-erase]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-erase)
      erase_device=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

if [[ ! -d "$fixture_root" ]]; then
  echo "FAIL: fixture directory is missing: $fixture_root" >&2
  exit 1
fi

fixture_files=()
while IFS= read -r fixture_file; do
  fixture_files+=("$fixture_file")
done < <(find "$fixture_root" -maxdepth 1 -type f -name '[0-9][0-9]-*.png' -print | sort)
if [[ "${#fixture_files[@]}" != "7" ]]; then
  echo "FAIL: expected exactly seven screenshot fixture PNGs; found ${#fixture_files[@]}." >&2
  exit 1
fi

simulator_list_json="$(xcrun simctl list devices -j)"
device_id="$(jq -r \
  --arg requested "$requested_device_id" \
  --arg name "$device_name" \
  --arg type "$device_type_id" \
  --arg runtime "$runtime_id" \
  'first(.devices[$runtime][]? | select(.udid == $requested and .name == $name and .deviceTypeIdentifier == $type and (.isAvailable // true)) | .udid) // empty' \
  <<<"$simulator_list_json")"

if [[ -z "$device_id" ]]; then
  device_id="$(jq -r \
    --arg name "$device_name" \
    --arg type "$device_type_id" \
    --arg runtime "$runtime_id" \
    'first(.devices[$runtime][]? | select(.name == $name and .deviceTypeIdentifier == $type and (.isAvailable // true)) | .udid) // empty' \
    <<<"$simulator_list_json")"
fi

if [[ -z "$device_id" ]]; then
  existing_named_device="$(jq -r \
    --arg name "$device_name" \
    'first([.devices[][]? | select(.name == $name)] | .[]) // empty' \
    <<<"$simulator_list_json")"
  if [[ -n "$existing_named_device" ]]; then
    echo "FAIL: $device_name exists but is not an available iPhone 17 Pro Max on iOS 26.5; refusing to erase or replace it." >&2
    exit 1
  fi
  device_id="$(xcrun simctl create "$device_name" "$device_type_id" "$runtime_id")"
  echo "CREATE: $device_name ($device_id)"
fi

device_record="$(xcrun simctl list devices -j | jq -r \
  --arg id "$device_id" \
  --arg name "$device_name" \
  --arg type "$device_type_id" \
  --arg runtime "$runtime_id" \
  'first(.devices[$runtime][]? | select(.udid == $id and .name == $name and .deviceTypeIdentifier == $type and (.isAvailable // true))) // empty')"
if [[ -z "$device_record" ]]; then
  echo "FAIL: resolved simulator $device_name ($device_id) is not an available iPhone 17 Pro Max on iOS 26.5." >&2
  exit 1
fi

if [[ -e "$raw_root" ]]; then
  echo "FAIL: screenshot raw output already exists; refusing to overwrite evidence: $raw_root" >&2
  exit 1
fi
mkdir -p "$raw_root"
touch "$raw_root/.weekkeep-managed"
if [[ -e "$final_root" ]]; then
  echo "FAIL: screenshot final output already exists; refusing to overwrite evidence: $final_root" >&2
  exit 1
fi
mkdir -p "$final_root"
touch "$final_root/.weekkeep-managed"

build_root="$(mktemp -d /tmp/weekkeep-app-store-capture.XXXXXX)"
cleanup() {
  rm -rf "$build_root"
}
trap cleanup EXIT

attachment_exported_name() {
  local manifest="$1"
  local locale="$2"
  local slug="$3"
  local prefix="$locale-$slug"
  local matches_json
  local match_count

  # XCTest attachment names are generated as <locale>-<slug>_0_<suffix>.
  # Match the complete generated prefix so 03-review cannot consume the
  # similarly prefixed 03-review-bottom attachment.
  matches_json="$(jq -c --arg prefix "$prefix" \
    '[.[] | .attachments[] | select(.suggestedHumanReadableName | startswith($prefix + "_0_")) | .exportedFileName]' \
    "$manifest")"
  match_count="$(jq 'length' <<<"$matches_json")"
  if [[ "$match_count" != "1" ]]; then
    echo "FAIL: expected exactly one attachment for generated prefix ${prefix}_0_; found $match_count." >&2
    jq -r '.[] | "MATCH: \(.)"' <<<"$matches_json" >&2 || true
    exit 1
  fi
  jq -er '.[0]' <<<"$matches_json"
}

cd "$project_root"
xcodegen generate

echo "BOOT: $device_name ($device_id)"
if [[ "$erase_device" == "1" ]]; then
  xcrun simctl shutdown "$device_id" >/dev/null 2>&1 || true
  xcrun simctl erase "$device_id"
fi
xcrun simctl boot "$device_id" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$device_id" -b

# A fixed status-bar clock keeps the two locale runs visually stable.
sim_time_display="${WK_APPSTORE_SIM_TIME:-12:00}"
case "$sim_time_display" in
  [0-2][0-9]:[0-5][0-9]) ;;
  *)
    echo "FAIL: WK_APPSTORE_SIM_TIME must be HH:MM; found $sim_time_display" >&2
    exit 1
    ;;
esac
sim_time_override="${WK_APPSTORE_SIM_TIME_OVERRIDE:-2026-08-05T${sim_time_display}:00.000+09:00}"
set_status_bar_time() {
  xcrun simctl status_bar "$device_id" override --time "$sim_time_override" >/dev/null 2>&1
}
assert_status_bar_time() {
  status_bar_overrides="$(xcrun simctl status_bar "$device_id" list)"
  printf '%s\n' "$status_bar_overrides" | grep -Fqx "Time: $sim_time_display"
}
if ! set_status_bar_time; then
  echo "FAIL: simulator rejected status-bar time override $sim_time_override" >&2
  exit 1
fi
if ! assert_status_bar_time; then
  echo "FAIL: simulator status-bar preflight did not report Time: $sim_time_display" >&2
  xcrun simctl status_bar "$device_id" list >&2 || true
  exit 1
fi
xcrun simctl io "$device_id" screenshot "$build_root/simulator-frame.png" >/dev/null
frame_width="$(sips -g pixelWidth "$build_root/simulator-frame.png" | awk '/pixelWidth/ { print $2 }')"
frame_height="$(sips -g pixelHeight "$build_root/simulator-frame.png" | awk '/pixelHeight/ { print $2 }')"
echo "SIMULATOR_FRAMEBUFFER: ${frame_width}x${frame_height}"
if [[ "$frame_width" != "1320" || "$frame_height" != "2868" ]]; then
  echo "FAIL: dedicated simulator framebuffer is ${frame_width}x${frame_height}; expected 1320x2868." >&2
  exit 1
fi

derived_data="$build_root/DerivedData"
xcodebuild \
  -project Weekkeep.xcodeproj \
  -scheme Weekkeep \
  -configuration Debug \
  -destination "id=$device_id" \
  -derivedDataPath "$derived_data" \
  build | tee "$build_root/build.log"

app_path="$derived_data/Build/Products/Debug-iphonesimulator/Weekkeep.app"
if [[ ! -d "$app_path" ]]; then
  echo "FAIL: built app was not found at $app_path" >&2
  exit 1
fi
xcrun simctl install "$device_id" "$app_path"

swift_tool_root="$build_root/swift-tools"
mkdir -p "$swift_tool_root"
xcrun swiftc \
  "$project_root/scripts/compose-app-store-screenshots.swift" \
  -parse-as-library \
  -o "$swift_tool_root/compose-app-store-screenshots" \
  -framework AppKit -framework CoreGraphics -framework CoreText -framework ImageIO
xcrun swiftc \
  "$project_root/scripts/validate-app-store-screenshots.swift" \
  -parse-as-library \
  -o "$swift_tool_root/validate-app-store-screenshots" \
  -framework AppKit -framework CoreGraphics -framework ImageIO
xcrun swiftc \
  "$project_root/scripts/make-app-store-contact-sheet.swift" \
  -parse-as-library \
  -o "$swift_tool_root/make-app-store-contact-sheet" \
  -framework AppKit -framework CoreGraphics -framework CoreText -framework ImageIO

for locale in en-US ko; do
  locale_raw="$raw_root/$locale"
  result_bundle="$locale_raw/AppStoreScreenshot.xcresult"
  exported="$locale_raw/attachments"
  mkdir -p "$locale_raw"

  echo "CAPTURE: $locale on $device_name"
  # xcodebuild sanitizes arbitrary host environment variables before it
  # launches XCTest. TEST_RUNNER_ variables are copied into that process;
  # keep the unprefixed values too for Xcode versions that do inherit them.
  set_status_bar_time
  if ! assert_status_bar_time; then
    echo "FAIL: simulator status-bar preflight did not report Time: $sim_time_display before $locale capture" >&2
    xcrun simctl status_bar "$device_id" list >&2 || true
    exit 1
  fi
  (
    TEST_RUNNER_WK_CAPTURE_APP_STORE_SCREENSHOTS=1 \
    TEST_RUNNER_WK_APP_STORE_SCREENSHOT_LOCALE="$locale" \
    WK_CAPTURE_APP_STORE_SCREENSHOTS=1 \
    WK_APP_STORE_SCREENSHOT_LOCALE="$locale" \
    xcodebuild \
      -project Weekkeep.xcodeproj \
      -scheme Weekkeep \
      -configuration Debug \
      -destination "id=$device_id" \
      -derivedDataPath "$derived_data" \
      -resultBundlePath "$result_bundle" \
      -only-testing:WeekkeepUITests/AppStoreScreenshotTests/testCaptureBundledFixtureAppStoreScreenshots \
      test >"$locale_raw/xcodebuild.log" 2>&1
  ) &
  test_pid=$!
  while kill -0 "$test_pid" >/dev/null 2>&1; do
    set_status_bar_time || true
    sleep 0.5
  done
  set +e
  wait "$test_pid"
  test_exit=$?
  set -e
  if [[ "$test_exit" != "0" ]]; then
    tail -100 "$locale_raw/xcodebuild.log" >&2
    echo "FAIL: screenshot UI test failed for $locale (exit $test_exit)." >&2
    exit "$test_exit"
  fi
  if rg -q 'Test skipped - App Store screenshot capture is opt-in|testCaptureBundledFixtureAppStoreScreenshots.*skipped' "$locale_raw/xcodebuild.log"; then
    tail -60 "$locale_raw/xcodebuild.log" >&2
    echo "FAIL: screenshot UI test was skipped for $locale." >&2
    exit 1
  fi

  xcrun xcresulttool export attachments \
    --path "$result_bundle" \
    --output-path "$exported"

  manifest="$exported/manifest.json"
  if [[ ! -f "$manifest" ]]; then
    echo "FAIL: attachment manifest missing for $locale." >&2
    exit 1
  fi
  attachment_count="$(jq '[.[] | .attachments[]] | length' "$manifest")"
  if [[ "$attachment_count" != "7" ]]; then
    echo "FAIL: expected six submission screenshots plus one Weekly Review bottom-state attachment for $locale; found $attachment_count." >&2
    exit 1
  fi

  review_exported_name=""
  required_slugs=(01-welcome 02-curation-progress 03-review 04-replace 05-saved-weeks 06-plus)
  for slug in "${required_slugs[@]}"; do
    exported_name="$(attachment_exported_name "$manifest" "$locale" "$slug")"
    if [[ "$slug" == "03-review" ]]; then
      review_exported_name="$exported_name"
    fi
    if [[ ! -f "$exported/$exported_name" ]]; then
      echo "FAIL: attachment for $locale/$slug was not exported." >&2
      exit 1
    fi
    cp "$exported/$exported_name" "$locale_raw/$slug.png"
    width="$(sips -g pixelWidth "$locale_raw/$slug.png" | awk '/pixelWidth/ { print $2 }')"
    height="$(sips -g pixelHeight "$locale_raw/$slug.png" | awk '/pixelHeight/ { print $2 }')"
    alpha="$(sips -g hasAlpha "$locale_raw/$slug.png" | awk '/hasAlpha/ { print $2 }')"
    echo "RAW: $locale/$slug ${width}x${height}, alpha=${alpha}"
    if [[ "$width" != "1320" || "$height" != "2868" || "$alpha" != "no" ]]; then
      echo "FAIL: raw screenshot contract failed for $locale/$slug." >&2
      exit 1
    fi
  done

  bottom_exported_name="$(attachment_exported_name "$manifest" "$locale" "03-review-bottom")"
  if [[ -z "$review_exported_name" || "$review_exported_name" == "$bottom_exported_name" ]]; then
    echo "FAIL: attachment collision regression: $locale/03-review and $locale/03-review-bottom resolved to $review_exported_name." >&2
    exit 1
  fi
  if [[ ! -f "$exported/$bottom_exported_name" ]]; then
    echo "FAIL: bottom-state attachment for $locale/03-review-bottom was not exported." >&2
    exit 1
  fi
  cp "$exported/$bottom_exported_name" "$locale_raw/03-review-bottom.png"
  bottom_width="$(sips -g pixelWidth "$locale_raw/03-review-bottom.png" | awk '/pixelWidth/ { print $2 }')"
  bottom_height="$(sips -g pixelHeight "$locale_raw/03-review-bottom.png" | awk '/pixelHeight/ { print $2 }')"
  bottom_alpha="$(sips -g hasAlpha "$locale_raw/03-review-bottom.png" | awk '/hasAlpha/ { print $2 }')"
  echo "RAW: $locale/03-review-bottom ${bottom_width}x${bottom_height}, alpha=${bottom_alpha}"
  if [[ "$bottom_width" != "1320" || "$bottom_height" != "2868" || "$bottom_alpha" != "no" ]]; then
    echo "FAIL: bottom-state raw screenshot contract failed for $locale." >&2
    exit 1
  fi
done

"$swift_tool_root/compose-app-store-screenshots" \
  --raw-root "$raw_root" \
  --output-root "$final_root" \
  --fixture-root "$fixture_root" \
  --device-id "$device_id" \
  --device-name "$device_name"

"$swift_tool_root/validate-app-store-screenshots" \
  --output-root "$final_root" \
  --raw-root "$raw_root" \
  --fixture-root "$fixture_root"

"$swift_tool_root/make-app-store-contact-sheet" \
  --output-root "$final_root"

echo "PASS: deterministic bundled-fixture App Store 6.9-inch screenshot pipeline completed in $final_root."
