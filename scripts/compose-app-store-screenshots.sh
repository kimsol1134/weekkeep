#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
if [[ $# -lt 6 ]]; then
  echo "Usage: scripts/compose-app-store-screenshots.sh --raw-root PATH --output-root PATH --fixture-root PATH --device-id UDID --device-name NAME" >&2
  exit 2
fi

tool_root="$(mktemp -d /tmp/weekkeep-app-store-compose.XXXXXX)"
cleanup() { rm -rf "$tool_root"; }
trap cleanup EXIT

xcrun swiftc \
  "$project_root/scripts/compose-app-store-screenshots.swift" \
  -parse-as-library \
  -o "$tool_root/compose" \
  -framework AppKit -framework CoreGraphics -framework CoreText -framework ImageIO
cd "$project_root"
"$tool_root/compose" "$@"
