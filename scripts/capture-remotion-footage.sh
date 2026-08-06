#!/usr/bin/env bash
set -euo pipefail

# The opt-in XCTest launch uses -ui-fixtures and bundled SamplePhotoFixtures.
# This is deterministic UI footage, not PhotoKit ingestion evidence.

project_root="$(cd "$(dirname "$0")/.." && pwd)"
device_id="9C794F17-634B-4B7A-86A9-AEE88EE575FF"
device_name="Weekkeep AppStore 6.9"
device_type_id="com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max"
runtime_id="com.apple.CoreSimulator.SimRuntime.iOS-26-5"
project_file="Weekkeep.xcodeproj"
scheme="Weekkeep"
configuration="Debug"
bundle_id="com.solkim.weekkeep"
test_specifier="WeekkeepUITests/RemotionFootageCaptureTests/testCaptureRemotionFootage"
raw_root="$project_root/videos/weekkeep-remotion/capture/raw"
recording_file="$raw_root/weekkeep-remotion-ui.mp4"
overwrite=0
capture_directory=""
temporary_recording_file=""

usage() {
  echo "Usage: scripts/capture-remotion-footage.sh [--overwrite]" >&2
  echo "  Records the opt-in English Weekkeep UI flow to:" >&2
  echo "  videos/weekkeep-remotion/capture/raw/weekkeep-remotion-ui.mp4" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --overwrite)
      overwrite=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "FAIL: unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

for required_command in xcodegen xcodebuild xcrun jq; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "FAIL: required command is missing: $required_command" >&2
    exit 1
  fi
done

# The destination is intentionally fixed. The script accepts no arbitrary
# output or simulator path, so broad/ambiguous paths cannot be recorded into
# release evidence or another user's directory by accident.
expected_raw_root="$project_root/videos/weekkeep-remotion/capture/raw"
expected_recording_file="$expected_raw_root/weekkeep-remotion-ui.mp4"
if [[ "$raw_root" != "$expected_raw_root" || "$recording_file" != "$expected_recording_file" ]]; then
  echo "FAIL: capture paths do not match the canonical local Remotion raw path." >&2
  exit 1
fi
if [[ -L "$raw_root" || -L "$recording_file" ]]; then
  echo "FAIL: refusing a symlinked capture path." >&2
  exit 1
fi

mkdir -p "$raw_root"
if [[ -e "$recording_file" ]]; then
  if [[ ! -f "$recording_file" ]]; then
    echo "FAIL: refusing to overwrite a non-file capture target: $recording_file" >&2
    exit 1
  fi
  if [[ "$overwrite" != "1" ]]; then
    echo "FAIL: capture already exists; pass --overwrite explicitly to replace it: $recording_file" >&2
    exit 2
  fi
fi

simulator_record="$(xcrun simctl list devices -j | jq -r \
  --arg requested "$device_id" \
  --arg name "$device_name" \
  --arg type "$device_type_id" \
  --arg runtime "$runtime_id" \
  'first(.devices[$runtime][]? | select(.udid == $requested and .name == $name and .deviceTypeIdentifier == $type and (.isAvailable // true))) // empty')"
if [[ -z "$simulator_record" ]]; then
  echo "FAIL: canonical simulator $device_name ($device_id) is not available on iOS 26.5." >&2
  exit 1
fi
if [[ "$(jq -r '.state' <<<"$simulator_record")" != "Booted" ]]; then
  echo "FAIL: $device_name ($device_id) must already be booted; refusing to boot or erase another simulator." >&2
  exit 1
fi

cd "$project_root"
xcodegen generate --spec project.yml >/dev/null

build_root="$(mktemp -d /tmp/weekkeep-remotion-capture.XXXXXX)"
record_pid=""

stop_recording() {
  if [[ -n "${record_pid:-}" ]]; then
    if kill -0 "$record_pid" >/dev/null 2>&1; then
      kill -INT "$record_pid" >/dev/null 2>&1 || true
      for ((attempt = 0; attempt < 60; attempt++)); do
        if ! kill -0 "$record_pid" >/dev/null 2>&1; then
          break
        fi
        sleep 0.1
      done
      if kill -0 "$record_pid" >/dev/null 2>&1; then
        kill -TERM "$record_pid" >/dev/null 2>&1 || true
      fi
    fi
    wait "$record_pid" >/dev/null 2>&1 || true
    record_pid=""
  fi
}

cleanup() {
  stop_recording
  if [[ -n "${build_root:-}" && -d "$build_root" ]]; then
    rm -rf "$build_root"
  fi
  if [[ -n "${capture_directory:-}" && -d "$capture_directory" ]]; then
    rm -rf "$capture_directory"
  fi
}

trap cleanup EXIT
trap 'exit 130' INT TERM

# Compile and prepare the test runner before recording so the raw asset begins
# near the app launch instead of containing dependency/build wait time.
build_log="$build_root/build-for-testing.log"
xcodebuild \
  -project "$project_file" \
  -scheme "$scheme" \
  -configuration "$configuration" \
  -destination "id=$device_id" \
  -derivedDataPath "$build_root/DerivedData" \
  build-for-testing >"$build_log" 2>&1

capture_directory="$(mktemp -d "$raw_root/.capture.XXXXXX")"
temporary_recording_file="$capture_directory/weekkeep-remotion-ui.mp4"
record_log="$build_root/record-video.log"
echo "RECORD: $recording_file"
xcrun simctl io "$device_id" recordVideo --codec=h264 "$temporary_recording_file" >"$record_log" 2>&1 &
record_pid=$!

recording_started=0
for ((attempt = 0; attempt < 100; attempt++)); do
  if grep -Fq "Recording started" "$record_log"; then
    recording_started=1
    break
  fi
  if ! kill -0 "$record_pid" >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done
if [[ "$recording_started" != "1" ]]; then
  echo "FAIL: simulator screen recording did not start." >&2
  sed -n '1,80p' "$record_log" >&2 || true
  exit 1
fi

xcodebuild_log="$build_root/xcodebuild.log"
set +e
(
  TEST_RUNNER_WK_CAPTURE_REMOTION_FOOTAGE=1 \
  WK_CAPTURE_REMOTION_FOOTAGE=1 \
  xcodebuild \
    -project "$project_file" \
    -scheme "$scheme" \
    -configuration "$configuration" \
    -destination "id=$device_id" \
    -derivedDataPath "$build_root/DerivedData" \
    -resultBundlePath "$build_root/RemotionFootage.xcresult" \
    -only-testing:"$test_specifier" \
    test-without-building
) >"$xcodebuild_log" 2>&1
test_status=$?
set -e

stop_recording

if [[ "$test_status" != "0" ]]; then
  tail -120 "$xcodebuild_log" >&2 || true
  echo "FAIL: Remotion footage UI test failed with exit $test_status." >&2
  exit "$test_status"
fi
if grep -Fq "Remotion footage capture is opt-in" "$xcodebuild_log"; then
  tail -80 "$xcodebuild_log" >&2 || true
  echo "FAIL: Remotion footage UI test was skipped." >&2
  exit 1
fi
if [[ ! -s "$temporary_recording_file" ]]; then
  echo "FAIL: recording did not produce a non-empty MP4." >&2
  exit 1
fi

# Replace the canonical raw capture only after a complete test and non-empty
# recording. A failed overwrite attempt therefore preserves the prior asset.
mv -f "$temporary_recording_file" "$recording_file"

echo "PASS: actual English Weekkeep UI footage captured locally at $recording_file."
echo "PASS: no destination was selected and no upload/publish step was run."
