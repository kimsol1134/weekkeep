#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
if [[ $# -ne 1 ]]; then
  echo "Usage: scripts/capture-build6-notification-settings.sh ABSOLUTE_OUTPUT_DIRECTORY" >&2
  exit 2
fi

output_root="$1"
if [[ "$output_root" != /* ]]; then
  echo "FAIL: use an absolute output directory so build-6 evidence cannot be mistaken for tracked submission assets." >&2
  exit 2
fi
if [[ -e "$output_root" ]]; then
  echo "FAIL: output directory already exists; refusing to overwrite build-6 evidence: $output_root" >&2
  exit 2
fi

device_id="${WK_BUILD6_SIMULATOR_UDID:-9C794F17-634B-4B7A-86A9-AEE88EE575FF}"
mkdir -p "$output_root"

cd "$project_root"
xcodegen generate

for locale in en-US ko; do
  locale_root="$output_root/$locale"
  result_bundle="$locale_root/SettingsNotification.xcresult"
  exported="$locale_root/attachments"
  mkdir -p "$locale_root"

  (
    TEST_RUNNER_WK_CAPTURE_BUILD6_NOTIFICATION_SETTINGS=1 \
    TEST_RUNNER_WK_BUILD6_NOTIFICATION_SETTINGS_LOCALE="$locale" \
    WK_CAPTURE_BUILD6_NOTIFICATION_SETTINGS=1 \
    WK_BUILD6_NOTIFICATION_SETTINGS_LOCALE="$locale" \
    xcodebuild \
      -project Weekkeep.xcodeproj \
      -scheme Weekkeep \
      -configuration Debug \
      -destination "id=$device_id" \
      -resultBundlePath "$result_bundle" \
      -only-testing:WeekkeepUITests/WeekkeepUITests/testCaptureBuild6NotificationSettingsWhenRequested \
      test >"$locale_root/xcodebuild.log" 2>&1
  )

  if rg -q 'Test skipped -|skipped \(' "$locale_root/xcodebuild.log"; then
    tail -80 "$locale_root/xcodebuild.log" >&2
    echo "FAIL: build-6 notification-settings capture was skipped for $locale." >&2
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

  for state in settings-zero-saved settings-saved; do
    exported_name="$(jq -er --arg prefix "$locale-$state" \
      '[.[] | .attachments[] | select(.suggestedHumanReadableName | startswith($prefix + "_0_")) | .exportedFileName] | if length == 1 then .[0] else error("expected one attachment") end' \
      "$manifest")"
    source="$exported/$exported_name"
    target="$locale_root/$state.png"
    if [[ ! -f "$source" ]]; then
      echo "FAIL: missing exported screenshot for $locale/$state." >&2
      exit 1
    fi
    cp "$source" "$target"
    width="$(sips -g pixelWidth "$target" | awk '/pixelWidth/ { print $2 }')"
    height="$(sips -g pixelHeight "$target" | awk '/pixelHeight/ { print $2 }')"
    alpha="$(sips -g hasAlpha "$target" | awk '/hasAlpha/ { print $2 }')"
    echo "CAPTURED: $locale/$state ${width}x${height}, alpha=${alpha}"
    if [[ "$width" != "1320" || "$height" != "2868" || "$alpha" != "no" ]]; then
      echo "FAIL: build-6 notification-settings screenshot contract failed for $locale/$state." >&2
      exit 1
    fi
  done
done

final_root="$output_root/final"
mkdir -p "$final_root"
for locale in en-US ko; do
  mkdir -p "$final_root/$locale"
  cp "$output_root/$locale/settings-zero-saved.png" "$final_root/$locale/settings-zero-saved.png"
  cp "$output_root/$locale/settings-saved.png" "$final_root/$locale/settings-saved.png"
  cp "$output_root/$locale/attachments/manifest.json" "$final_root/$locale/manifest.json"
done

cat >"$output_root/PROVENANCE.md" <<EOF
# Build 6 notification-settings visual evidence

- Scope: local build 6 candidate only; not uploaded, attached, or submitted.
- Capture: opt-in XCTest fixture flow on the dedicated iPhone 17 Pro Max / iOS 26.5 simulator.
- Locales: en-US and ko.
- States: zero saved albums (static informational gate) and one saved album (contextual action).
- Source: bundled fixture data only; no Photos library pixels or private contact data.
EOF

find "$output_root" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) -print0 \
  | sort -z \
  | xargs -0 shasum -a 256 >"$output_root/SHA256SUMS.txt"

echo "PASS: bilingual build-6 notification-settings visual evidence captured at $output_root."
