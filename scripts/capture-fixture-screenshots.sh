#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
if [[ $# -ne 1 ]]; then
  echo "Usage: scripts/capture-fixture-screenshots.sh OUTPUT_DIRECTORY" >&2
  exit 2
fi

output_directory="$1"
if [[ "$output_directory" != /* ]]; then
  echo "FAIL: use an absolute output directory so capture artifacts cannot be mistaken for tracked submission assets." >&2
  exit 2
fi
if [[ -e "$output_directory" ]]; then
  echo "FAIL: output directory already exists; choose a new directory to avoid overwriting evidence." >&2
  exit 2
fi

mkdir -p "$output_directory"
attachments="$output_directory/attachments"

if [[ -n "${WK_FIXTURE_RESULT_BUNDLE:-}" ]]; then
  result_bundle="$WK_FIXTURE_RESULT_BUNDLE"
  if [[ ! -d "$result_bundle" ]]; then
    echo "FAIL: WK_FIXTURE_RESULT_BUNDLE is not an existing xcresult bundle." >&2
    exit 1
  fi
else
  device_id="${WK_SIMULATOR_UDID:-}"
  if [[ -z "$device_id" ]]; then
    device_id="$(xcrun simctl list devices booted | awk -F '[()]' '/iPhone/ { print $2; exit }')"
  fi
  if [[ -z "$device_id" ]]; then
    echo "FAIL: boot an iPhone Simulator first or set WK_SIMULATOR_UDID." >&2
    exit 1
  fi

  result_bundle="$output_directory/fixture-capture.xcresult"
  cd "$project_root"
  TEST_RUNNER_WK_CAPTURE_SCREENSHOTS=1 \
  WK_CAPTURE_SCREENSHOTS=1 \
  xcodebuild \
    -project Weekkeep.xcodeproj \
    -scheme Weekkeep \
    -configuration Debug \
    -destination "id=$device_id" \
    -only-testing:WeekkeepUITests/WeekkeepUITests/testCaptureDeterministicFixtureMilestonesWhenRequested \
    -resultBundlePath "$result_bundle" \
    test
fi

xcrun xcresulttool export attachments \
  --path "$result_bundle" \
  --output-path "$attachments"

png_count=0
while IFS= read -r -d '' image; do
  png_count=$((png_count + 1))
  width="$(sips -g pixelWidth "$image" | awk '/pixelWidth/ { print $2 }')"
  height="$(sips -g pixelHeight "$image" | awk '/pixelHeight/ { print $2 }')"
  alpha="$(sips -g hasAlpha "$image" | awk '/hasAlpha/ { print $2 }')"
  if [[ -z "$width" || -z "$height" ]]; then
    echo "FAIL: unable to inspect screenshot dimensions: $image" >&2
    exit 1
  fi
  echo "CAPTURED: $(basename "$image") ${width}x${height}, alpha=${alpha}"
done < <(find "$attachments" -type f -name '*.png' -print0 | sort -z)

if (( png_count != 4 )); then
  echo "FAIL: expected four deterministic fixture screenshots; found $png_count." >&2
  exit 1
fi

echo "Fixture screenshot evidence exported to $attachments."
