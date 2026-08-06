#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tool_path="/tmp/weekkeep-generate-site-og"

xcrun swiftc -parse-as-library \
  "$project_root/scripts/generate-site-og.swift" \
  -o "$tool_path"

cd "$project_root"
"$tool_path"
