#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
output_root="${1:-$project_root/release/local/visual-qa/20260806-photo-story-rerun8}"
device_id="${WK_SIMULATOR_UDID:-9C794F17-634B-4B7A-86A9-AEE88EE575FF}"

if [[ "$output_root" != /* ]]; then
  echo "FAIL: use an absolute output directory." >&2
  exit 2
fi
if [[ -e "$output_root" ]]; then
  echo "FAIL: refusing to overwrite existing visual QA evidence: $output_root" >&2
  exit 2
fi

mkdir -p "$output_root"
touch "$output_root/.weekkeep-managed"

cd "$project_root"
xcodegen generate
TEST_RUNNER_WK_CAPTURE_VISUAL_QA=1 \
WK_CAPTURE_VISUAL_QA=1 \
xcodebuild \
  -project Weekkeep.xcodeproj \
  -scheme Weekkeep \
  -configuration Debug \
  -destination "id=$device_id" \
  -resultBundlePath "$output_root/visual-qa.xcresult" \
  -only-testing:WeekkeepUITests/WeekkeepUITests/testCapturePhotoStoryVisualQAWhenRequested \
  test >"$output_root/xcodebuild.log" 2>&1

xcrun xcresulttool export attachments \
  --path "$output_root/visual-qa.xcresult" \
  --output-path "$output_root/attachments"

png_count=0
while IFS= read -r -d '' image; do
  png_count=$((png_count + 1))
  width="$(sips -g pixelWidth "$image" | awk '/pixelWidth/ { print $2 }')"
  height="$(sips -g pixelHeight "$image" | awk '/pixelHeight/ { print $2 }')"
  alpha="$(sips -g hasAlpha "$image" | awk '/hasAlpha/ { print $2 }')"
  echo "CAPTURED: $(basename "$image") ${width}x${height}, alpha=${alpha}"
done < <(find "$output_root/attachments" -type f -name '*.png' -print0 | sort -z)

if [[ "$png_count" != "5" ]]; then
  echo "FAIL: expected five visual QA captures; found $png_count." >&2
  exit 1
fi

find "$output_root/attachments" -type f -name '*.png' -print | sort >"$output_root/attachments-index.txt"
echo "Visual QA evidence exported to $output_root/attachments."
