#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
manifest="$project_root/release/shipaton-manifest.json"
example_config="$project_root/Config/Secrets.example.xcconfig"
scratch_dir="$(mktemp -d "${TMPDIR:-/tmp}/weekkeep-public-source.XXXXXX")"
trap 'rm -rf "$scratch_dir"' EXIT

failures=0
warnings=0
canonical_repository_url="https://github.com/kimsol1134/weekkeep"
canonical_raw_license_url="https://raw.githubusercontent.com/kimsol1134/weekkeep/main/LICENSE"
canonical_checked_at="2026-08-07T07:03:22+09:00"
canonical_main_commit="af1faab05739e95c5ffb2645d4e0ad396c8d97b3"
validated_public_source_evidence="validated_public_source_repository;repository_url=${canonical_repository_url};owner=kimsol1134;name=weekkeep;visibility=PUBLIC;isPrivate=false;source_availability=Validated;source_url=${canonical_repository_url};source_http_status=200;logged_out_verification=Validated;checked_at=${canonical_checked_at};logged_out_repository_url=${canonical_repository_url};logged_out_repository_http_status=200;raw_license_url=${canonical_raw_license_url};raw_license_http_status=200;github_license_evidence=GitHub recognizes root LICENSE as MIT;default_branch=main;git_ls_remote_main_commit=${canonical_main_commit}"

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

warn() {
  echo "WARN: $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "PASS: $1"
}

cd "$project_root"

if [[ ! -f LICENSE ]]; then
  fail "root LICENSE is missing"
else
  if rg -q '^MIT License$' LICENSE; then
    pass "root license is labeled MIT."
  else
    fail "root LICENSE is not labeled MIT"
  fi
  if rg -q '^Copyright \(c\) 2026 Sol Kim$' LICENSE; then
    pass "root license names the 2026 Sol Kim copyright holder."
  else
    fail "root LICENSE has the required 2026 Sol Kim holder line"
  fi
fi

if [[ ! -f "$manifest" ]] || ! jq empty "$manifest" >/dev/null 2>&1; then
  fail "Shipaton manifest is missing or invalid JSON"
else
  if jq -e '
    .intake_filter.gates.public_source_repository.required == true
    and (.intake_filter.gates.public_source_repository.status | IN("pending_external", "Validated"))
    and (.intake_filter.gates.public_source_repository.repository_url == null
         or (.intake_filter.gates.public_source_repository.repository_url | type) == "string")
    and .intake_filter.gates.public_source_repository.repository_visibility_status
    == (if .intake_filter.gates.public_source_repository.status == "pending_external"
        then "pending_publication"
        else "public"
        end)
    and .intake_filter.gates.public_source_repository.source_availability.required == true
    and (.intake_filter.gates.public_source_repository.source_availability.status
         | IN("pending_external", "Validated"))
    and .intake_filter.gates.public_source_repository.logged_out_verification.required == true
    and (.intake_filter.gates.public_source_repository.logged_out_verification.status
         | IN("pending_external", "Validated"))
    and (.intake_filter.gates.public_source_repository.logged_out_verification.checked_at == null
         or (.intake_filter.gates.public_source_repository.logged_out_verification.checked_at | type) == "string")
    and .intake_filter.gates.public_source_repository.license.path == "LICENSE"
    and .intake_filter.gates.public_source_repository.license.spdx_id == "MIT"
    and .intake_filter.gates.public_source_repository.license.osi_approved == true
    and .intake_filter.gates.public_source_repository.license.holder == "Sol Kim"
    and .intake_filter.gates.public_source_repository.license.local_status == "validated_local"
    and (.intake_filter.gates.public_source_repository.evidence_ref
         == "external_evidence.public_source_repository")
    and ((.external_evidence.public_source_repository | type) == "string")
  ' "$manifest" >/dev/null; then
    pass "public-source/license gate schema is present and structurally valid."
  else
    fail "public-source/license gate schema is missing or malformed"
  fi

  if jq -e --arg canonical_repository_url "$canonical_repository_url" \
    --arg canonical_raw_license_url "$canonical_raw_license_url" \
    --arg canonical_checked_at "$canonical_checked_at" \
    --arg canonical_main_commit "$canonical_main_commit" \
    --arg expected_evidence "$validated_public_source_evidence" '
    .intake_filter.gates.public_source_repository.status == "Validated"
    and .intake_filter.gates.public_source_repository.repository_url == $canonical_repository_url
    and .intake_filter.gates.public_source_repository.repository_visibility_status == "public"
    and .intake_filter.gates.public_source_repository.source_availability.status == "Validated"
    and .intake_filter.gates.public_source_repository.source_availability.evidence_ref == "external_evidence.public_source_repository"
    and .intake_filter.gates.public_source_repository.logged_out_verification.status == "Validated"
    and .intake_filter.gates.public_source_repository.logged_out_verification.checked_at == $canonical_checked_at
    and .intake_filter.gates.public_source_repository.logged_out_verification.evidence_ref == "external_evidence.public_source_repository"
    and .intake_filter.gates.public_source_repository.license.path == "LICENSE"
    and .intake_filter.gates.public_source_repository.license.spdx_id == "MIT"
    and .intake_filter.gates.public_source_repository.license.osi_approved == true
    and .intake_filter.gates.public_source_repository.license.holder == "Sol Kim"
    and .intake_filter.gates.public_source_repository.license.local_status == "validated_local"
    and ($expected_evidence | contains("raw_license_url=" + $canonical_raw_license_url + ";raw_license_http_status=200"))
    and ($expected_evidence | contains("default_branch=main;git_ls_remote_main_commit=" + $canonical_main_commit))
    and .external_evidence.public_source_repository == $expected_evidence
  ' "$manifest" >/dev/null; then
    pass "public-source gate records completed public verification."
  elif jq -e '
    .intake_filter.gates.public_source_repository.status == "pending_external"
    and .intake_filter.gates.public_source_repository.repository_url == null
    and .intake_filter.gates.public_source_repository.repository_visibility_status == "pending_publication"
    and .intake_filter.gates.public_source_repository.source_availability.status == "pending_external"
    and .intake_filter.gates.public_source_repository.logged_out_verification.status == "pending_external"
    and .intake_filter.gates.public_source_repository.logged_out_verification.checked_at == null
    and (.external_evidence.public_source_repository | startswith("pending_"))
  ' "$manifest" >/dev/null; then
    warn "public repository publication and logged-out verification remain pending."
  else
    fail "public-source gate lifecycle state is incoherent"
  fi
fi

if git ls-files --error-unmatch Config/Secrets.xcconfig >/dev/null 2>&1; then
  fail "ignored secret configuration is tracked"
else
  pass "secret configuration is not tracked."
fi

if [[ ! -f "$example_config" ]]; then
  fail "safe example configuration is missing"
elif git check-ignore -q --no-index -- Config/Secrets.example.xcconfig; then
  fail "safe example configuration must remain a public candidate"
elif awk '
  BEGIN {
    bad = 0
    purchases = 0
    analytics = 0
    revenuecat = 0
    posthog_token = 0
    posthog_host = 0
  }
  /^[[:space:]]*(\/\/|$)/ { next }
  /^[[:space:]]*WK_PURCHASES_ENABLED[[:space:]]*=[[:space:]]*(YES|NO)[[:space:]]*$/ {
    purchases = 1
    next
  }
  /^[[:space:]]*WK_ANALYTICS_ENABLED[[:space:]]*=[[:space:]]*NO[[:space:]]*$/ {
    analytics = 1
    next
  }
  /^[[:space:]]*WK_REVENUECAT_API_KEY[[:space:]]*=[[:space:]]*$/ {
    revenuecat = 1
    next
  }
  /^[[:space:]]*WK_POSTHOG_PROJECT_TOKEN[[:space:]]*=[[:space:]]*$/ {
    posthog_token = 1
    next
  }
  /^[[:space:]]*WK_POSTHOG_HOST[[:space:]]*=[[:space:]]*https:\/\$\(\)\/eu\.i\.posthog\.com[[:space:]]*$/ {
    posthog_host = 1
    next
  }
  { bad = 1 }
  END {
    exit !(!bad && purchases && analytics && revenuecat && posthog_token && posthog_host)
  }
' "$example_config"; then
  pass "safe example configuration is present and placeholder-only."
else
  fail "safe example configuration contains an unexpected or non-placeholder assignment"
fi

required_ignored_paths=(
  "Config/Secrets.xcconfig"
  ".asc/probe.json"
  ".env"
  ".env.local"
  "node_modules/probe/package.json"
  "DerivedData/probe"
  "build/probe"
  "release/local/probe.txt"
  "release/evidence/probe.txt"
  "submission/local/probe.txt"
  "submission/evidence/probe.txt"
  "submission/promo-code.txt"
  "private-key.p8"
  "private-key.pem"
  "private-key.key"
  "judge-codes/probe.txt"
  "submission/judge-codes/probe.txt"
  "videos/weekkeep-shipaton/.waveform-cache/probe.json"
  "videos/weekkeep-shipaton/.thumbnails/probe.jpg"
  "videos/weekkeep-shipaton/.hyperframes/probe.txt"
  "videos/weekkeep-shipaton/.media/probe.txt"
  "videos/weekkeep-shipaton/snapshots/probe.png"
  "videos/weekkeep-shipaton/capture/probe.mp4"
  "videos/weekkeep-remotion/capture/probe.mp4"
  "videos/weekkeep-remotion/qa/probe.png"
  "videos/weekkeep-remotion/out/probe.mp4"
  "site/.next/probe.js"
)
ignore_failure=0
for ignored_path in "${required_ignored_paths[@]}"; do
  if ! git check-ignore -q --no-index -- "$ignored_path"; then
    ignore_failure=1
  fi
done
if (( ignore_failure == 0 )); then
  pass "secret, evidence, dependency, build, and judge-code paths are ignored."
else
  fail "one or more required public-source ignore rules are missing"
fi

candidate_paths_file="$scratch_dir/candidate-paths"
git ls-files --cached --others --exclude-standard -z >"$candidate_paths_file"
forbidden_candidate=0
while IFS= read -r -d '' candidate_path; do
  case "$candidate_path" in
    Config/Secrets.xcconfig|.asc/*|release/local/*|release/evidence/*|submission/local/*|submission/evidence/*|\
    node_modules/*|.build/*|DerivedData/*|build/*|dist/*|out/*|\
    */.cache/*|*/.hyperframes/*|*/.media/*|*/.next/*|*/.thumbnails/*|*/.turbo/*|*/.waveform-cache/*|\
    videos/*/capture/*|videos/*/out/*|videos/*/qa/*|videos/*/snapshots/*|\
    *.p8|*.pem|*.key|*.mobileprovision|*.ipa|*.xcarchive/*|*.xcresult/*|\
    *judge-code*|*promo-code*)
      forbidden_candidate=1
      ;;
  esac
done <"$candidate_paths_file"
if (( forbidden_candidate == 0 )); then
  pass "public-source candidate paths contain no forbidden secret or private-evidence locations."
else
  fail "forbidden secret, judge-code, build, or private-evidence path is a candidate"
fi

candidate_files=()
while IFS= read -r -d '' candidate_path; do
  case "$candidate_path" in
    Config/*|.asc/*|release/local/*|release/evidence/*|submission/local/*|submission/evidence/*|\
    node_modules/*|.build/*|DerivedData/*|build/*|dist/*|out/*|\
    *.xcresult/*|*.xcarchive/*|*.png|*.jpg|*.jpeg|*.gif|*.heic|*.pdf|*.mp4|\
    *.ipa|*.zip|*.dSYM|*.dSYM/*|*.ttf|*.otf|*.woff|*.woff2)
      continue
      ;;
  esac
  if [[ -f "$candidate_path" ]]; then
    candidate_files+=("$candidate_path")
  fi
done <"$candidate_paths_file"

scan_pattern() {
  local label="$1"
  local pattern="$2"
  local output="$scratch_dir/scan-${label}"
  local result

  if (( ${#candidate_files[@]} == 0 )); then
    pass "$label scan had no public text candidates."
    return
  fi

  set +e
  rg --pcre2 -I -l -e "$pattern" "${candidate_files[@]}" >"$output" 2>/dev/null
  result=$?
  set -e
  if (( result == 0 )); then
    fail "$label pattern found in public-source candidates"
  elif (( result == 1 )); then
    pass "$label scan found no matches."
  else
    fail "$label scan could not complete"
  fi
}

scan_pattern "private-key" '-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----'
scan_pattern "credential-token" '(?i)(sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{20,}|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}\.)'
scan_pattern "judge-code" '(?i)(?:judge|promo|offer)[_-]?(?:code|codes)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9][A-Za-z0-9_-]{7,}["'"'"']'
scan_pattern "private-reviewer-contact" '(?i)(?:reviewer[[:space:]_-]*(?:email|phone|contact)|review[[:space:]_-]+contact|private[[:space:]_-]+contact)[^\n]{0,160}(?:\+[0-9][0-9 ()-]{8,}[0-9]|[0-9]{2,4}[- ][0-9]{3,4}[- ][0-9]{4}|[[:alnum:]._%+-]+@[[:alnum:].-]+\.[A-Za-z]{2,})'
scan_pattern "reviewer-phone" '(?i)(?:reviewer[[:space:]_-]*phone|review[[:space:]_-]+contact|private[[:space:]_-]+contact)[^\n]{0,160}(?:\+[0-9][0-9 ()-]{8,}[0-9]|[0-9]{2,4}[- ][0-9]{3,4}[- ][0-9]{4})'

if (( failures > 0 )); then
  echo "Public-source validation failed with $failures failure(s) and $warnings warning(s)." >&2
  exit 1
fi

echo "Public-source validation passed with $warnings pending external warning(s)."
