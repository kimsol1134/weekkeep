#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
metadata="$project_root/release/app-store-metadata.json"

legacy=0
if [[ $# -eq 2 && "$1" == "--legacy" ]]; then
  legacy=1
  screenshot_directory="$2"
elif [[ $# -eq 1 ]]; then
  screenshot_directory="$1"
else
  echo "Usage: scripts/validate-submission-screenshots.sh [--legacy] ABSOLUTE_SCREENSHOT_DIRECTORY" >&2
  exit 2
fi

if [[ "$screenshot_directory" != /* ]] || [[ ! -d "$screenshot_directory" ]]; then
  echo "FAIL: provide an existing absolute screenshot directory." >&2
  exit 2
fi

expected_width="$(jq -er '.screenshots.shipaton_proof.width' "$metadata")"
expected_height="$(jq -er '.screenshots.shipaton_proof.height' "$metadata")"
if (( legacy == 1 )); then
  milestones=(
    "01-welcome"
    "02-review"
    "03-review-selected"
    "04-save-confirmation"
  )
  echo "Validating explicit legacy/historical screenshot names." >&2
else
  milestones=(
    "01-welcome"
    "02-review"
    "03-save-confirmation"
    "04-share-preview"
  )
fi

regular_file_count="$(find "$screenshot_directory" -maxdepth 1 -type f | wc -l | tr -d ' ')"
if [[ "$regular_file_count" != "4" ]]; then
  echo "FAIL: selected screenshot directory must contain exactly four files; found $regular_file_count." >&2
  exit 1
fi

for milestone in "${milestones[@]}"; do
  image="$screenshot_directory/$milestone.jpg"
  if [[ ! -f "$image" ]]; then
    echo "FAIL: missing required screenshot: $milestone.jpg" >&2
    exit 1
  fi

  width="$(sips -g pixelWidth "$image" | awk '/pixelWidth/ { print $2 }')"
  height="$(sips -g pixelHeight "$image" | awk '/pixelHeight/ { print $2 }')"
  alpha="$(sips -g hasAlpha "$image" | awk '/hasAlpha/ { print $2 }')"
  format="$(sips -g format "$image" | awk '/format/ { print $2 }')"
  space="$(sips -g space "$image" | awk '/space/ { print $2 }')"
  if [[ "$width" != "$expected_width" ]] || [[ "$height" != "$expected_height" ]]; then
    echo "FAIL: $milestone.jpg is ${width}x${height}; expected ${expected_width}x${expected_height}." >&2
    exit 1
  fi
  if [[ "$alpha" != "no" || "$format" != "jpeg" ]]; then
    echo "FAIL: $milestone.jpg must be an opaque JPEG (format=$format, alpha=$alpha)." >&2
    exit 1
  fi
  if [[ "$space" != "RGB" && "$space" != "sRGB" ]]; then
    echo "FAIL: $milestone.jpg must be an sRGB/RGB JPEG; reported color space: $space." >&2
    exit 1
  fi
  echo "PASS: $milestone.jpg is ${width}x${height}, opaque $format, color space $space."
done

echo "Submission screenshot contract passed."
