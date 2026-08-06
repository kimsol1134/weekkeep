#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
repository_root="$(cd "$project_root/../.." && pwd)"
submission_assets="$project_root/assets"
bgm_metadata="$project_root/bgm_status.json"
audio_engine_metadata="$project_root/audio_engine_meta.json"
bgm_path="$project_root/assets/bgm/track.wav"
line_license_source="$repository_root/Weekkeep/Resources/Licenses/LINESeedKR-OFL.txt"
line_license="$project_root/licenses/LINESeedKR-OFL.txt"
jetbrains_license="$project_root/licenses/JetBrainsMono-OFL.txt"
generation_script="$project_root/scripts/generate-original-bgm.sh"

expected_bgm_sha256="10d9340c16c3234826451c4a71808aa9125a91b67af04288df66bc9996f63ce0"
expected_jetbrains_license_sha256="cdc03ce910dc69ddf53357137be87f619ccc344cd767be2f9aaa9671a61116f3"
failures=0

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

pass() {
  echo "PASS: $1"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "required local command is missing: $1"
  fi
}

for command_name in cmp ffprobe jq rg shasum; do
  require_command "$command_name"
done

for required_file in \
  "$submission_assets" \
  "$bgm_metadata" \
  "$audio_engine_metadata" \
  "$bgm_path" \
  "$line_license_source" \
  "$line_license" \
  "$jetbrains_license" \
  "$generation_script"; do
  if [[ ! -e "$required_file" ]]; then
    fail "required video provenance file is missing: ${required_file#$repository_root/}"
  fi
done

if (( failures > 0 )); then
  exit 1
fi

legacy_asset_paths="$(find "$submission_assets" -type f \( -iname 'bgm-*.log' -o -iname '*musicgen*' \) -print)"
if [[ -n "$legacy_asset_paths" ]]; then
  fail "MusicGen logs or track remain in the submission asset tree: $legacy_asset_paths"
else
  pass "submission asset tree contains no MusicGen logs or track."
fi

if jq -e \
  --arg expected_sha256 "$expected_bgm_sha256" \
  '(.provider == "procedural_ffmpeg_original") and
   (.mode == "procedural_ffmpeg_original") and
   (.path == "assets/bgm/track.wav") and
   (.generation_script == "scripts/generate-original-bgm.sh") and
   (.sha256 == $expected_sha256) and
   (.provenance.identifier == "procedural_ffmpeg_original") and
   (.provenance.generator == "ffmpeg") and
   (.provenance.external_samples == false) and
   (.provenance.ml_model == null)' \
  "$bgm_metadata" >/dev/null; then
  pass "BGM metadata records procedural_ffmpeg_original provenance."
else
  fail "BGM metadata does not match the procedural FFmpeg provenance contract."
fi

if jq -e \
  '(.bgm.path == "assets/bgm/track.wav") and
   (.bgm.mode == "procedural_ffmpeg_original") and
   (.bgm.generation_script == "scripts/generate-original-bgm.sh") and
   (.bgm.provenance.identifier == "procedural_ffmpeg_original") and
   (.bgm_external_samples == false) and
   (.bgm_ml_model == null)' \
  "$audio_engine_metadata" >/dev/null; then
  pass "audio engine metadata agrees with the procedural BGM contract."
else
  fail "audio engine metadata does not agree with the procedural BGM contract."
fi

actual_bgm_sha256="$(shasum -a 256 "$bgm_path" | awk '{print $1}')"
if [[ "$actual_bgm_sha256" == "$expected_bgm_sha256" ]]; then
  pass "BGM SHA-256 matches the expected procedural original."
else
  fail "BGM SHA-256 mismatch: expected $expected_bgm_sha256, found $actual_bgm_sha256."
fi

if probe_json="$(ffprobe -v error \
  -show_entries format=duration,format_name:stream=codec_name,sample_rate,channels,bits_per_sample \
  -of json "$bgm_path")"; then
  if jq -e \
    '(.format.format_name == "wav") and
     ((.format.duration | tonumber) == 72) and
     (.streams | length == 1) and
     (.streams[0].codec_name == "pcm_s16le") and
     ((.streams[0].sample_rate | tonumber) == 48000) and
     (.streams[0].channels == 2) and
     ((.streams[0].bits_per_sample | tonumber) == 16)' \
    <<<"$probe_json" >/dev/null; then
    pass "BGM duration and WAV/PCM format match 72s, 48kHz, stereo, 16-bit PCM."
  else
    fail "BGM duration or WAV/PCM format does not match the release contract."
  fi
else
  fail "ffprobe could not inspect the procedural BGM."
fi

if cmp -s "$line_license_source" "$line_license"; then
  pass "LINE Seed Sans KR OFL text is byte-identical to the app source license."
else
  fail "bundled LINE Seed Sans KR OFL text differs from Weekkeep/Resources/Licenses/LINESeedKR-OFL.txt."
fi

actual_jetbrains_license_sha256="$(shasum -a 256 "$jetbrains_license" | awk '{print $1}')"
if [[ "$actual_jetbrains_license_sha256" == "$expected_jetbrains_license_sha256" ]]; then
  pass "JetBrains Mono OFL 1.1 text matches the bundled official contract."
else
  fail "JetBrains Mono OFL 1.1 text hash mismatch: found $actual_jetbrains_license_sha256."
fi

if [[ -x "$generation_script" ]]; then
  pass "procedural BGM generation script is executable."
else
  fail "procedural BGM generation script is not executable."
fi

if (( failures > 0 )); then
  echo "Video provenance validation failed with $failures failure(s)." >&2
  exit 1
fi

echo "Video provenance validation passed."
