#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
metadata="$project_root/release/app-store-metadata.json"

if [[ $# -ne 1 ]]; then
  echo "Usage: scripts/validate-submission-screenshots.sh ABSOLUTE_SCREENSHOT_DIRECTORY" >&2
  exit 2
fi

screenshot_directory="$1"
if [[ "$screenshot_directory" != /* ]] || [[ ! -d "$screenshot_directory" ]]; then
  echo "FAIL: provide an existing absolute screenshot directory." >&2
  exit 2
fi

expected_width="$(jq -er '.screenshots.shipaton_proof.width' "$metadata")"
expected_height="$(jq -er '.screenshots.shipaton_proof.height' "$metadata")"
milestones=(
  "01-welcome"
  "02-review"
  "03-review-selected"
  "04-save-confirmation"
)

for milestone in "${milestones[@]}"; do
  image="$screenshot_directory/$milestone.jpg"
  if [[ ! -f "$image" ]]; then
    echo "FAIL: missing required screenshot: $milestone.jpg" >&2
    exit 1
  fi

  width="$(sips -g pixelWidth "$image" | awk '/pixelWidth/ { print $2 }')"
  height="$(sips -g pixelHeight "$image" | awk '/pixelHeight/ { print $2 }')"
  alpha="$(sips -g hasAlpha "$image" | awk '/hasAlpha/ { print $2 }')"
  if [[ "$width" != "$expected_width" ]] || [[ "$height" != "$expected_height" ]]; then
    echo "FAIL: $milestone.jpg is ${width}x${height}; expected ${expected_width}x${expected_height}." >&2
    exit 1
  fi
  if [[ "$alpha" != "no" ]]; then
    echo "FAIL: $milestone.jpg has an alpha channel." >&2
    exit 1
  fi
  echo "PASS: $milestone.jpg is ${width}x${height} with no alpha."
done

unexpected_count="$(find "$screenshot_directory" -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' \) | wc -l | tr -d ' ')"
if [[ "$unexpected_count" != "4" ]]; then
  echo "FAIL: expected exactly four submission screenshots; found $unexpected_count." >&2
  exit 1
fi

echo "Submission screenshot contract passed."
