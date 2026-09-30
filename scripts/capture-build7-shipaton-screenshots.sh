#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
expected_width=1179
expected_height=2556
expected_model="com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro"
expected_runtime="com.apple.CoreSimulator.SimRuntime.iOS-26-5"
capture_test="WeekkeepUITests/WeekkeepUITests/testCaptureBuild7ShipatonSubmissionScreenshotsWhenRequested"
capture_owner="WeekkeepUITests/testCaptureBuild7ShipatonSubmissionScreenshotsWhenRequested()"
stems=("01-welcome" "02-review" "03-save-confirmation" "04-share-preview")

if [[ $# -ne 1 ]]; then
  echo "Usage: scripts/capture-build7-shipaton-screenshots.sh ABSOLUTE_OUTPUT_DIRECTORY" >&2
  exit 2
fi

output_directory="$1"
if [[ "$output_directory" != /* ]]; then
  echo "FAIL: output directory must be absolute." >&2
  exit 2
fi
if [[ -e "$output_directory" ]]; then
  echo "FAIL: output directory already exists; refusing to overwrite evidence: $output_directory" >&2
  exit 2
fi

raw_directory="$output_directory/raw"
attachments_directory="$raw_directory/attachments"
marker_directory="$raw_directory/markers"
simulator_capture_directory="$raw_directory/simulator-captures"
final_directory="$output_directory/final"
result_bundle="$raw_directory/build7-shipaton-capture.xcresult"
capture_log="$output_directory/capture.log"
mkdir -p "$attachments_directory" "$marker_directory" "$simulator_capture_directory" "$final_directory"

device_id="${WK_SIMULATOR_UDID:-}"
if [[ -z "$device_id" ]]; then
  device_id="$(xcrun simctl list devices available -j | jq -r --arg model "$expected_model" --arg runtime "$expected_runtime" '
    .devices[$runtime][]? | select(.deviceTypeIdentifier == $model and .state == "Booted") | .udid
  ' | sed -n '1p')"
fi
if [[ -z "$device_id" || "$device_id" == "null" ]]; then
  echo "FAIL: boot a dedicated iPhone 15 Pro on iOS 26.5 or set WK_SIMULATOR_UDID." >&2
  exit 1
fi

device_record="$(xcrun simctl list devices available -j | jq -c -e --arg udid "$device_id" '
  .devices | to_entries[] as $runtime | $runtime.value[]
  | select(.udid == $udid)
  | {name, udid, state, deviceTypeIdentifier, runtime: $runtime.key}
' )"
if [[ -z "$device_record" ]]; then
  echo "FAIL: simulator UDID is not an available simulator: $device_id" >&2
  exit 1
fi

device_model="$(jq -r '.deviceTypeIdentifier' <<<"$device_record")"
device_runtime="$(jq -r '.runtime' <<<"$device_record")"
device_state="$(jq -r '.state' <<<"$device_record")"
device_name="$(jq -r '.name' <<<"$device_record")"
if [[ "$device_model" != "$expected_model" || "$device_runtime" != "$expected_runtime" || "$device_state" != "Booted" ]]; then
  echo "FAIL: source capture must use a booted iPhone 15 Pro on iOS 26.5; got $device_name ($device_model, $device_runtime, $device_state)." >&2
  exit 1
fi

result_bundle_input="${WK_FIXTURE_RESULT_BUNDLE:-}"
if [[ -n "$result_bundle_input" ]]; then
  echo "FAIL: build-7 exact simulator capture requires a fresh marker-coordinated XCTest run; WK_FIXTURE_RESULT_BUNDLE is not supported." >&2
  exit 1
else
  cd "$project_root"
  echo "Capturing $capture_test on $device_name ($device_id)." > "$capture_log"
  TEST_RUNNER_WK_CAPTURE_SCREENSHOTS=1 \
  WK_CAPTURE_BUILD7_SHIPATON_SCREENSHOTS=1 \
  TEST_RUNNER_WK_CAPTURE_BUILD7_SHIPATON_SCREENSHOTS=1 \
  WK_BUILD7_SHIPATON_LOCALE="${WK_BUILD7_SHIPATON_LOCALE:-en}" \
  TEST_RUNNER_WK_BUILD7_SHIPATON_LOCALE="${WK_BUILD7_SHIPATON_LOCALE:-en}" \
  WK_BUILD7_SIM_CAPTURE_MARKER_DIR="$marker_directory" \
  TEST_RUNNER_WK_BUILD7_SIM_CAPTURE_MARKER_DIR="$marker_directory" \
  xcodebuild \
    -project Weekkeep.xcodeproj \
    -scheme Weekkeep \
    -configuration Debug \
    -destination "id=$device_id" \
    -only-testing:"$capture_test" \
    -resultBundlePath "$result_bundle" \
    test >> "$capture_log" 2>&1 &
  xcodebuild_pid=$!

  capture_ready_markers() {
    local stem
    local ready
    local done
    local simulator_source
    for stem in "${stems[@]}"; do
      ready="$marker_directory/$stem.ready"
      done="$marker_directory/$stem.done"
      simulator_source="$simulator_capture_directory/$stem.jpeg"
      if [[ -f "$ready" && ! -f "$done" ]]; then
        if [[ -e "$simulator_source" ]]; then
          echo "FAIL: refusing to overwrite simulator capture: $simulator_source" >> "$capture_log"
          touch "$marker_directory/$stem.failed"
          continue
        fi
        if xcrun simctl io "$device_id" screenshot --type=jpeg "$simulator_source" >> "$capture_log" 2>&1; then
          touch "$done"
        else
          touch "$marker_directory/$stem.failed"
        fi
      fi
    done
  }

  while kill -0 "$xcodebuild_pid" 2>/dev/null; do
    capture_ready_markers
    sleep 0.1
  done
  capture_ready_markers
  xcodebuild_status=0
  wait "$xcodebuild_pid" || xcodebuild_status=$?
  echo "xcodebuild exit status: $xcodebuild_status" >> "$capture_log"
  if [[ "$xcodebuild_status" != "0" ]]; then
    echo "FAIL: XCTest capture failed; see $capture_log." >&2
    exit "$xcodebuild_status"
  fi
fi

if [[ ! -d "$result_bundle" ]]; then
  echo "FAIL: XCTest result bundle was not produced: $result_bundle" >&2
  exit 1
fi

marker_count="$(find "$marker_directory" -maxdepth 1 -type f -name '*.done' | wc -l | tr -d ' ')"
if [[ "$marker_count" != "4" ]]; then
  echo "FAIL: expected four acknowledged simulator capture markers; found $marker_count." >&2
  exit 1
fi
failed_marker_count="$(find "$marker_directory" -maxdepth 1 -type f -name '*.failed' | wc -l | tr -d ' ')"
if [[ "$failed_marker_count" != "0" ]]; then
  echo "FAIL: at least one exact simulator capture failed; see $capture_log." >&2
  exit 1
fi

simulator_image_count="$(find "$simulator_capture_directory" -maxdepth 1 -type f | wc -l | tr -d ' ')"
if [[ "$simulator_image_count" != "4" ]]; then
  echo "FAIL: expected exactly four raw simulator captures; found $simulator_image_count." >&2
  exit 1
fi

xcrun xcresulttool export attachments \
  --path "$result_bundle" \
  --output-path "$attachments_directory"

attachment_manifest="$attachments_directory/manifest.json"
if [[ ! -f "$attachment_manifest" ]]; then
  echo "FAIL: xcresult attachment manifest is missing." >&2
  exit 1
fi

attachment_count="$(jq '[.[]?.attachments[]?] | length' "$attachment_manifest")"
if [[ "$attachment_count" != "4" ]]; then
  echo "FAIL: expected exactly four XCTest attachments for $capture_test; found $attachment_count." >&2
  exit 1
fi
if ! jq -e --arg test "$capture_owner" '
  ([.[] | select(.testIdentifier == $test) | .attachments[]?] | length) == 4
' "$attachment_manifest" >/dev/null; then
  echo "FAIL: exported attachments are not exclusively owned by the build-7 capture test." >&2
  exit 1
fi

image_files=()
while IFS= read -r image_file; do
  image_files+=("$image_file")
done < <(
  find "$attachments_directory" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.tif' -o -iname '*.tiff' \) -print | sort
)
if (( ${#image_files[@]} != 4 )); then
  echo "FAIL: expected exactly four exported image attachments; found ${#image_files[@]}." >&2
  exit 1
fi

get_property() {
  local property="$1"
  local image="$2"
  sips -g "$property" "$image" 2>/dev/null | awk -F': ' -v key="$property" '{ field = $1; sub(/^[[:space:]]+/, "", field); if (field == key) { print $2; exit } }'
}

source_for_stem() {
  local stem="$1"
  local matches
  matches="$(jq -r --arg stem "$stem" '
    [.[]?.attachments[]?
      | select((.suggestedHumanReadableName // "") | test("^" + $stem + "_0_[A-Fa-f0-9-]+\\.png$"))
      | .exportedFileName
    ] | .[]
  ' "$attachment_manifest")"
  if [[ "$(wc -l <<<"$matches" | tr -d ' ')" != "1" ]]; then
    echo "FAIL: attachment name did not resolve to exactly one source: $stem" >&2
    exit 1
  fi
  local exported_name="${matches%%$'\n'*}"
  local source="$attachments_directory/$exported_name"
  if [[ ! -f "$source" ]]; then
    echo "FAIL: attachment manifest points to a missing image: $source" >&2
    exit 1
  fi
  printf '%s' "$source"
}

for stem in "${stems[@]}"; do
  attachment_source="$(source_for_stem "$stem")"
  attachment_format="$(get_property format "$attachment_source")"
  attachment_alpha="$(get_property hasAlpha "$attachment_source")"
  if [[ "$attachment_format" != "png" ]]; then
    echo "FAIL: $stem attachment anchor is $attachment_format, not an XCTest PNG attachment." >&2
    exit 1
  fi
  if [[ "$attachment_alpha" != "no" ]]; then
    echo "FAIL: $stem XCTest attachment anchor has an alpha channel." >&2
    exit 1
  fi

  source="$simulator_capture_directory/$stem.jpeg"
  source_format="$(get_property format "$source")"
  source_width="$(get_property pixelWidth "$source")"
  source_height="$(get_property pixelHeight "$source")"
  source_alpha="$(get_property hasAlpha "$source")"
  source_space="$(get_property space "$source")"
  if [[ "$source_format" != "jpeg" ]]; then
    echo "FAIL: $stem simulator source is $source_format, not a JPEG framebuffer capture." >&2
    exit 1
  fi
  if [[ "$source_width" != "$expected_width" || "$source_height" != "$expected_height" ]]; then
    echo "FAIL: $stem simulator source is ${source_width}x${source_height}; expected ${expected_width}x${expected_height}." >&2
    exit 1
  fi
  if [[ "$source_alpha" != "no" ]]; then
    echo "FAIL: $stem simulator source has an alpha channel; refusing to flatten an invalid capture." >&2
    exit 1
  fi

  destination="$final_directory/$stem.jpg"
  if [[ -e "$destination" ]]; then
    echo "FAIL: refusing to overwrite final screenshot: $destination" >&2
    exit 1
  fi
  sips -s format jpeg -s formatOptions best \
    -m "/System/Library/ColorSync/Profiles/sRGB Profile.icc" \
    --out "$destination" "$source" >/dev/null

  final_format="$(get_property format "$destination")"
  final_width="$(get_property pixelWidth "$destination")"
  final_height="$(get_property pixelHeight "$destination")"
  final_alpha="$(get_property hasAlpha "$destination")"
  final_space="$(get_property space "$destination")"
  if [[ "$final_format" != "jpeg" || "$final_width" != "$expected_width" || "$final_height" != "$expected_height" || "$final_alpha" != "no" ]]; then
    echo "FAIL: converted $stem is not an opaque ${expected_width}x${expected_height} JPEG." >&2
    exit 1
  fi
  printf '%s\n' "$stem: XCTest-anchor=$(basename "$attachment_source") $attachment_format alpha=$attachment_alpha; simulator-source=$source_format ${source_width}x${source_height} alpha=$source_alpha space=${source_space:-unknown}; final=$final_format ${final_width}x${final_height} alpha=$final_alpha space=${final_space:-unknown}" >&2
done

final_image_count="$(find "$final_directory" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | wc -l | tr -d ' ')"
if [[ "$final_image_count" != "4" ]]; then
  echo "FAIL: final directory must contain exactly four images; found $final_image_count." >&2
  exit 1
fi

(
  cd "$final_directory"
  shasum -a 256 "01-welcome.jpg" "02-review.jpg" "03-save-confirmation.jpg" "04-share-preview.jpg"
) > "$output_directory/SHA256SUMS.txt"

capture_timestamp="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
{
  printf '%s\n' "# Build-7 Shipaton screenshot provenance"
  printf '\n%s\n' '- Evidence status: `fixture-only-local-evidence`.'
  printf '%s\n' '- Submission status: not uploaded, not submitted, and not evidence of App Store Connect, Devpost, production Photos, or a released build.'
  printf '%s\n' '- Source contract: four XCTest attachments are exported and resolved by attachment name; each selected pixel source is a same-state `simctl` JPEG framebuffer capture from `SamplePhotoFixtures` on a booted iPhone 15 Pro simulator. No PhotoKit/private photos were read.'
  printf '%s\n' '- Share contract: `04-share-preview.jpg` is the real in-app Story/Post preview after local rendering. The Apple native share sheet was not opened and no content was sent.'
  printf '\n%s\n' '## Capture'
  printf '%s\n' "- Captured at (UTC): $capture_timestamp"
  printf '%s\n' "- XCTest test: \`$capture_test\`"
  printf '%s\n' "- Launch argument: \`-ui-fixtures\`"
  printf '%s\n' "- Capture environment: \`WK_CAPTURE_BUILD7_SHIPATON_SCREENSHOTS=1\`"
  printf '%s\n' "- Locale: \`${WK_BUILD7_SHIPATON_LOCALE:-en}\`"
  printf '%s\n' "- Simulator: $device_name"
  printf '%s\n' "- Simulator UDID: \`$device_id\`"
  printf '%s\n' "- Device model identifier: \`$device_model\`"
  printf '%s\n' "- Runtime identifier: \`$device_runtime\`"
  printf '%s\n' "- Source framebuffer: exactly ${expected_width}×${expected_height}; no resize or mockup compositing."
  printf '%s\n' "- Raw XCTest export: \`raw/attachments/manifest.json\` (the source attachment dimensions are retained as raw test evidence)."
  printf '%s\n' '- Exact simulator captures: `raw/simulator-captures/<screen>.jpeg`; these are the selected pixel sources and are not resized.'
  printf '%s\n' '- Result bundle: `raw/build7-shipaton-capture.xcresult`.'
  printf '\n%s\n' '## Selected images'
  for stem in "${stems[@]}"; do
    attachment_source="$(source_for_stem "$stem")"
    source="$simulator_capture_directory/$stem.jpeg"
    attachment_hash="$(shasum -a 256 "$attachment_source" | awk '{print $1}')"
    source_hash="$(shasum -a 256 "$source" | awk '{print $1}')"
    final_hash="$(shasum -a 256 "$final_directory/$stem.jpg" | awk '{print $1}')"
    printf '%s\n' "- \`final/$stem.jpg\`: XCTest anchor \`$(basename "$attachment_source")\` SHA256 \`$attachment_hash\`; exact simulator source \`$(basename "$source")\` SHA256 \`$source_hash\`; final SHA256 \`$final_hash\`."
  done
  printf '\n%s\n' '## Visual QA boundary'
  printf '%s\n' '- Final JPEGs are opaque, sRGB-converted, and exactly 1179×2556. Visual inspection must reject loading, clipping, overlap, stale stitch colors, placeholder-like surfaces, device frames, and marketing headline overlays.'
  printf '%s\n' '- The bundled fixtures are fictional family-photo artwork used only for local deterministic evidence.'
} > "$output_directory/PROVENANCE.md"

echo "Build-7 Shipaton fixture evidence written to $output_directory"
echo "Final screenshots: $final_directory"
