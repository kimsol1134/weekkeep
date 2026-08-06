#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
if [[ $# -lt 4 ]]; then
  echo "Usage: scripts/validate-app-store-screenshots.sh --output-root PATH --fixture-root PATH [--raw-root PATH]" >&2
  exit 2
fi

tool_root="$(mktemp -d /tmp/weekkeep-app-store-validate.XXXXXX)"
cleanup() { rm -rf "$tool_root"; }
trap cleanup EXIT

xcrun swiftc \
  "$project_root/scripts/validate-app-store-screenshots.swift" \
  -parse-as-library \
  -o "$tool_root/validate" \
  -framework CoreGraphics -framework ImageIO
cd "$project_root"
"$tool_root/validate" "$@"
