#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
if [[ $# -ne 1 ]]; then
  echo "Usage: scripts/archive-release.sh ABSOLUTE_OUTPUT_DIRECTORY" >&2
  exit 2
fi

output_directory="$1"
if [[ "$output_directory" != /* ]]; then
  echo "FAIL: output directory must be an absolute path." >&2
  exit 2
fi
if [[ -e "$output_directory" ]]; then
  echo "FAIL: output directory already exists; refusing to overwrite a release archive." >&2
  exit 2
fi

secrets="$project_root/Config/Secrets.xcconfig"
if [[ ! -f "$secrets" ]] || ! rg -q '^WK_REVENUECAT_API_KEY = *[^[:space:]]' "$secrets"; then
  echo "BLOCKED: Config/Secrets.xcconfig must provide the RevenueCat public SDK key before a Release archive is allowed." >&2
  echo "        The key is read only by Xcode configuration; it is never printed or uploaded by this script." >&2
  exit 3
fi
if rg -n '^WK_ANALYTICS_ENABLED = (YES|true|1)$|^WK_POSTHOG_PROJECT_TOKEN = *[^[:space:]]' "$secrets" >/dev/null; then
  echo "BLOCKED: V1 Release analytics must stay disabled and the PostHog token must remain empty." >&2
  exit 3
fi

cd "$project_root"
xcodegen generate --spec project.yml >/dev/null
mkdir -p "$output_directory"

# This is intentionally archive-only. It has no provisioning-update, upload,
# publish, or App Store Connect transport step.
xcodebuild \
  -project Weekkeep.xcodeproj \
  -scheme Weekkeep \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$output_directory/Weekkeep.xcarchive" \
  archive

echo "Release archive created at $output_directory/Weekkeep.xcarchive."
echo "Export, TestFlight, App Review, and public release remain explicit human-controlled steps."
