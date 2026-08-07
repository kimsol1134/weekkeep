#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
metadata="$project_root/release/app-store-metadata.json"
privacy="$project_root/release/privacy-manifest.json"
shipaton="$project_root/release/shipaton-manifest.json"
core_document="$project_root/docs/11-SHIPATON-SUBMISSION.md"
release_config="$project_root/Config/Release.xcconfig"
remotion_project="$project_root/videos/weekkeep-remotion"
provenance_script="$project_root/videos/weekkeep-shipaton/scripts/validate-provenance.sh"
strict=0
run_build=0
core_only=0
failures=0
warnings=0
canonical_repository_url="https://github.com/kimsol1134/weekkeep"
canonical_raw_license_url="https://raw.githubusercontent.com/kimsol1134/weekkeep/main/LICENSE"
canonical_checked_at="2026-08-07T07:03:22+09:00"
canonical_main_commit="282ae29a0efddaca439177b447676ec2cbe90f0e"
validated_public_source_evidence="validated_public_source_repository;repository_url=${canonical_repository_url};owner=kimsol1134;name=weekkeep;visibility=PUBLIC;isPrivate=false;source_availability=Validated;source_url=${canonical_repository_url};source_http_status=200;logged_out_verification=Validated;checked_at=${canonical_checked_at};logged_out_repository_url=${canonical_repository_url};logged_out_repository_http_status=200;raw_license_url=${canonical_raw_license_url};raw_license_http_status=200;github_license_evidence=GitHub recognizes root LICENSE as MIT;default_branch=main;git_ls_remote_main_commit=${canonical_main_commit}"

for argument in "$@"; do
  case "$argument" in
    --strict) strict=1 ;;
    --build) run_build=1 ;;
    --shipaton-core-only) core_only=1 ;;
    -h|--help)
      cat <<'USAGE'
Usage: scripts/validate-release.sh [--strict] [--build] [--shipaton-core-only]

  default   Validate tracked release contracts and report credential/public-state blockers.
  --strict  Treat missing authenticated release state as a failure.
  --build   Also run a Release iOS Simulator build with signing disabled.
  --shipaton-core-only  Validate the Devpost core-readiness invariant without regenerating the Xcode project.
USAGE
      exit 0
      ;;
    *)
      echo "FAIL: unknown argument: $argument" >&2
      exit 2
      ;;
  esac
done

cd "$project_root"

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

validate_shipaton_core_readiness() {
  local expected_field_headings
  local actual_field_headings
  local core_copy
  local core_block_count
  local empty_core_blocks
  local core_placeholder_lines
  local disallowed_placeholder_lines
  local demo_timeline_beat_count

  if ! jq -e '
    .intake_filter.gates.required_fields_and_category_answers.status == "pending_external"
    and .intake_filter.gates.required_fields_and_category_answers.core_readiness.status == "ready_to_paste"
    and .intake_filter.gates.required_fields_and_category_answers.core_readiness.external_submission_status == "pending_external"
    and .intake_filter.gates.required_fields_and_category_answers.core_readiness.source_document == "docs/11-SHIPATON-SUBMISSION.md"
    and .intake_filter.gates.required_fields_and_category_answers.core_readiness.source_section == "## 3. Devpost 기본 입력 — English"
    and .intake_filter.gates.required_fields_and_category_answers.core_readiness.field_range == "### Project name through ### Built with"
    and .intake_filter.gates.required_fields_and_category_answers.core_readiness.placeholder_invariant == "zero_bracket_placeholders_in_core_copy_blocks"
    and .intake_filter.gates.required_fields_and_category_answers.category_readiness.conditional_categories == "gated_not_evaluated"
    and .intake_filter.gates.required_fields_and_category_answers.category_readiness.post_launch_metrics == "excluded_until_evidence"
    and .intake_filter.gates.required_fields_and_category_answers.placeholder_policy.core == "forbidden"
    and .intake_filter.gates.required_fields_and_category_answers.placeholder_policy.allowed_scopes_are_excluded_from_core_readiness == true
    and .intake_filter.gates.required_fields_and_category_answers.placeholder_policy.allowed_sections == [
      "### Post-launch metrics — excluded until evidence",
      "## 6. Peace Prize answer — conditional English draft",
      "### Grand Prize submission block — English (stretch; conditional)",
      "### Most Viral App (Noise) submission block — English (conditional; gated)",
      "## 9. Launch evidence dashboard — post-launch metrics (excluded until evidence)"
    ]
  ' "$shipaton" >/dev/null; then
    fail "Shipaton manifest core-readiness status or placeholder policy is missing or inconsistent."
  else
    pass "Shipaton manifest distinguishes paste-ready core copy from pending external submission and gated sections."
  fi

  if ! expected_field_headings="$(jq -er '.intake_filter.gates.required_fields_and_category_answers.core_readiness.required_field_headings[]' "$shipaton")"; then
    fail "Shipaton manifest does not define the required Devpost core field headings."
    return
  fi

  actual_field_headings="$(awk '
    /^## 3\. Devpost 기본 입력 — English$/ { in_core = 1; next }
    /^## 4\. Design Award answer — English$/ { in_core = 0 }
    in_core && /^### / { sub(/^### /, ""); print }
  ' "$core_document")"
  if [[ "$actual_field_headings" == "$expected_field_headings" ]]; then
    pass "Devpost core field headings match the manifest source contract in order."
  else
    fail "Devpost core field headings do not match the manifest source contract."
    echo "Expected headings:" >&2
    printf '%s\n' "$expected_field_headings" >&2
    echo "Actual headings:" >&2
    printf '%s\n' "$actual_field_headings" >&2
  fi

  core_block_count="$(awk '
    /^## 3\. Devpost 기본 입력 — English$/ { in_core = 1; next }
    /^## 4\. Design Award answer — English$/ { in_core = 0 }
    in_core && /^```text$/ { in_copy = 1; seen = 0; next }
    in_core && in_copy && /^```$/ { if (seen) { count += 1 }; in_copy = 0; next }
    in_core && in_copy && /[^[:space:]]/ { seen = 1 }
    END { print count + 0 }
  ' "$core_document")"
  empty_core_blocks="$(awk '
    /^## 3\. Devpost 기본 입력 — English$/ { in_core = 1; next }
    /^## 4\. Design Award answer — English$/ { in_core = 0 }
    in_core && /^### / { heading = $0 }
    in_core && /^```text$/ { in_copy = 1; seen = 0; next }
    in_core && in_copy && /^```$/ {
      if (!seen) { print heading }
      in_copy = 0
      next
    }
    in_core && in_copy && /[^[:space:]]/ { seen = 1 }
  ' "$core_document")"
  if [[ "$core_block_count" == "12" && -z "$empty_core_blocks" ]]; then
    pass "All 12 Devpost core fields contain non-empty text blocks."
  else
    fail "Devpost core fields must contain exactly 12 non-empty text blocks (found ${core_block_count:-0})."
    [[ -z "$empty_core_blocks" ]] || printf '%s\n' "$empty_core_blocks" >&2
  fi

  core_copy="$(awk '
    /^## 3\. Devpost 기본 입력 — English$/ { in_core = 1; next }
    /^## 4\. Design Award answer — English$/ { in_core = 0 }
    in_core && /^```text$/ { in_copy = 1; next }
    in_core && in_copy && /^```$/ { in_copy = 0; next }
    in_core && in_copy { print NR ":" $0 }
  ' "$core_document")"
  core_placeholder_lines="$(printf '%s\n' "$core_copy" | rg -n '\[[^]]*\]' || true)"
  if [[ -n "$core_placeholder_lines" ]]; then
    fail "Devpost core copy contains bracket placeholders."
    printf '%s\n' "$core_placeholder_lines" >&2
  else
    pass "Devpost core copy from Project name through Built with contains zero bracket placeholders."
  fi

  disallowed_placeholder_lines="$(awk '
    function is_placeholder(line) {
      return line ~ /\[INSERT/ \
        || line ~ /\[Replace with/ \
        || line ~ /\[UTC dates\]/ \
        || line ~ /\[n([ \/;%\]]|$)/ \
        || line ~ /\[number([\/,;\]]|$)/ \
        || line ~ /\[specific,/ \
        || line ~ /\[\$\]/ \
        || line ~ /\[pending\]/
    }
    function allowed_section(section) {
      return section == "### Post-launch metrics — excluded until evidence" \
        || section == "## 6. Peace Prize answer — conditional English draft" \
        || section == "### Grand Prize submission block — English (stretch; conditional)" \
        || section == "### Most Viral App (Noise) submission block — English (conditional; gated)" \
        || section == "## 9. Launch evidence dashboard — post-launch metrics (excluded until evidence)"
    }
    /^## / { section = $0 }
    /^### / { section = $0 }
    is_placeholder($0) && !allowed_section(section) { print NR ":" section ":" $0 }
  ' "$core_document")"
  if [[ -n "$disallowed_placeholder_lines" ]]; then
    fail "Shipaton placeholders appear outside explicitly gated conditional or excluded post-launch sections."
    printf '%s\n' "$disallowed_placeholder_lines" >&2
  else
    pass "Intentionally gated conditional and excluded post-launch placeholders are outside core readiness evaluation."
  fi

  demo_timeline_beat_count="$(rg -F -c '| 0:39.5–0:44.5 |' "$core_document" || true)"
  if [[ "$demo_timeline_beat_count" == "1" ]]; then
    pass "The canonical 0:39.5–0:44.5 save-to-share beat appears once in the submission timeline; approved video timing and hash records remain untouched."
  else
    fail "The 0:39.5–0:44.5 save-to-share beat must have exactly one submission-timeline reference (found ${demo_timeline_beat_count:-0})."
  fi
}

validate_share_contract() {
  local share_source="$project_root/Weekkeep/Features/Sharing/WeeklyAlbumShare.swift"
  local analytics_source="$project_root/Weekkeep/Integrations/Analytics/AnalyticsClient.swift"
  local localization_catalog="$project_root/Weekkeep/Resources/Localizable.xcstrings"
  local english_invitation
  local korean_invitation

  english_invitation=$'A week with our family 🌈\nMade with Weekkeep.\nHow was your family\x27s week?'
  korean_invitation=$'우리 가족의 일주일 🌈\nWeekkeep으로 남겼어요.\n너희 가족의 이번 주는 어땠어?'

  if [[ ! -f "$share_source" || ! -f "$analytics_source" || ! -f "$localization_catalog" ]]; then
    fail "share/privacy contract inputs are missing"
    return
  fi

  if rg -q 'applicationActivities: nil' "$share_source" \
    && rg -q '\[imageSource, invitationSource, installURLSource\]' "$share_source" \
    && rg -q 'WeeklyAlbumShareContract\.canonicalInstallURL' "$share_source" \
    && rg -q 'completionHandler\(for completion' "$share_source" \
    && ! rg -q 'installURL:' "$share_source" \
    && ! rg -q 'init\(url:' "$share_source"; then
    pass "Native sharing is explicit, image-first, canonical-link-only, and has no caller-configurable install URL."
  else
    fail "native share contract must keep the local image first, use the canonical URL, and avoid arbitrary URL injection"
  fi

  if rg -q '"share_sheet_opened": \["format", "entry_point"\]' "$analytics_source" \
    && rg -q '"share_completed": \["format", "entry_point"\]' "$analytics_source" \
    && rg -q 'case \("share_completed", "format"\)' "$analytics_source" \
    && rg -q 'case \("share_completed", "entry_point"\)' "$analytics_source"; then
    pass "Share analytics remains restricted to format and entry point."
  else
    fail "share analytics schema is missing its strict two-property allowlist"
  fi

  if jq -e --arg english_invitation "$english_invitation" --arg korean_invitation "$korean_invitation" '
    .strings["share.invitation"].localizations.en.stringUnit.value == $english_invitation
    and .strings["share.invitation"].localizations.ko.stringUnit.value == $korean_invitation
  ' "$localization_catalog" >/dev/null; then
    pass "English and Korean share invitations match the native share contract."
  else
    fail "localized share invitations are missing or drifted"
  fi

  if rg -q 'canonical HTTPS URL' "$core_document" \
    && rg -q 'no recipient, destination, activity type, returned items, error, message contents' "$core_document" \
    && rg -q 'no QR code, loud ad overlay, Kakao SDK, upload' "$core_document"; then
    pass "Shipaton copy records explicit sharing, canonical-link separation, and privacy-safe measurement boundaries."
  else
    fail "Shipaton share/privacy contract copy is incomplete"
  fi
}

validate_judging_evidence() {
  if jq -e '
    .judging_evidence.status == "local_evidence_ready_external_submission_pending"
    and .judging_evidence.source_document == "docs/11-SHIPATON-SUBMISSION.md"
    and .judging_evidence.prescreening_messages.targeted_categories == [
      "RevenueCat Design Award",
      "HAMM Award (Help Apps Make Money)"
    ]
    and .judging_evidence.categories["RevenueCat Design Award"].decision == "Focus"
    and .judging_evidence.categories["RevenueCat Design Award"].role == "primary"
    and .judging_evidence.categories["RevenueCat Design Award"].answer_section == "## 4. Design Award answer — English"
    and (.judging_evidence.categories["RevenueCat Design Award"].local_evidence_refs | index("docs/06-TRACEABILITY.md:TST-041")) != null
    and (.judging_evidence.categories["RevenueCat Design Award"].local_evidence_refs | index("release/local/visual-qa/20260807-build7-shipaton-sharing-v12/final")) != null
    and .judging_evidence.categories["HAMM Award (Help Apps Make Money)"].decision == "Focus"
    and .judging_evidence.categories["HAMM Award (Help Apps Make Money)"].role == "secondary"
    and .judging_evidence.categories["HAMM Award (Help Apps Make Money)"].answer_section == "## 5. HAMM Award (Help Apps Make Money) answer — English"
    and .judging_evidence.categories["HAMM Award (Help Apps Make Money)"].post_launch_metrics_status == "excluded_until_evidence"
    and .judging_evidence.categories["#BuildInPublic"].evidence_status == "excluded_until_public_links_and_feedback_evidence"
    and (.judging_evidence.categories["#BuildInPublic"].local_evidence_refs | length) == 0
    and .judging_evidence.no_metric_claims_without_external_evidence == true
  ' "$shipaton" >/dev/null; then
    pass "Design, HAMM, and #BuildInPublic judging evidence are mapped without inventing external metrics or links."
  else
    fail "judging evidence map is missing, inconsistent, or overclaims external evidence"
  fi

  if rg -q '^### Current judging evidence map — local readiness only$' "$core_document" \
    && rg -q 'RevenueCat Design Award.*TST-019.*TST-041.*TST-042.*TST-049' "$core_document" \
    && rg -q 'HAMM Award \(Help Apps Make Money\).*TST-016.*TST-017' "$core_document" \
    && rg -q '#BuildInPublic.*No public-feedback evidence is claimed' "$core_document"; then
    pass "Submission SSOT exposes the category evidence map and its external blockers."
  else
    fail "submission SSOT category evidence map is incomplete"
  fi
}

validate_build_identity_boundary() {
  local project_marketing_version
  local project_build
  local manifest_current_build
  local historical_pre_upload_build
  local boundary_document

  project_marketing_version="$(awk '/^[[:space:]]+MARKETING_VERSION:/ { gsub(/"/, "", $2); print $2; exit }' "$project_root/project.yml")"
  project_build="$(awk '/^[[:space:]]+CURRENT_PROJECT_VERSION:/ { gsub(/"/, "", $2); print $2; exit }' "$project_root/project.yml")"
  manifest_current_build="$(jq -er '.current_release_build.build' "$shipaton")"
  historical_pre_upload_build="$(jq -er '.historical_local_build_7_pre_upload.build' "$shipaton")"

  if [[ "$project_marketing_version" == "1.0.0" && "$project_build" == "7" && "$manifest_current_build" == "7" && "$historical_pre_upload_build" == "7" ]]; then
    pass "project.yml and the release manifest identify marketing version 1.0.0, build 7 as the canonical submitted build; the pre-upload validation snapshot is historical."
  else
    fail "project.yml and Shipaton release SSOT must agree on 1.0.0 (build 7), with a separate historical pre-upload snapshot (project=${project_marketing_version:-missing} (${project_build:-missing}), current=${manifest_current_build:-missing}, historical=${historical_pre_upload_build:-missing})."
  fi

  if [[ -f "$metadata" ]] && jq -e '
    .app.bundle_id == "com.solkim.weekkeep"
    and .app.version == "1.0.0"
    and .app.build == "7"
    and .app.current_build.build == "7"
    and .app.current_build.upload_state == "uploaded"
    and .app.current_build.asc_build_id == "1c51b451-d37f-4704-89c9-e426b1ee5725"
    and .app.current_build.asc_processing_state == "VALID"
    and .app.current_build.app_store_version_attachment == "ATTACHED"
    and .app.current_build.review_submission_id == "6d2feeff-0f90-4b34-b0c8-b22a3b1928b7"
    and .app.current_build.review_submission_state == "WAITING_FOR_REVIEW"
  ' "$metadata" >/dev/null; then
    pass "App Store metadata records the canonical submitted remote 1.0.0 build-7 record."
  else
    fail "App Store metadata must record the canonical submitted remote 1.0.0 build-7 record."
  fi

  if jq -e '
    .build_identity_contract.submitted_remote_build_ref == "current_release_build"
    and .build_identity_contract.historical_pre_upload_build_7_ref == "historical_local_build_7_pre_upload"
    and .build_identity_contract.roles_are_mutually_exclusive == true
    and .build_identity_contract.remote_build_state_is_unchanged == true
    and .build_identity_contract.local_candidate_must_not_claim_remote_submission == true
    and .current_release_build.app_id == "6798449478"
    and .current_release_build.bundle_id == "com.solkim.weekkeep"
    and .current_release_build.version == "1.0.0"
    and .current_release_build.build == "7"
    and .current_release_build.upload_state == "uploaded"
    and .current_release_build.asc_build_id == "1c51b451-d37f-4704-89c9-e426b1ee5725"
    and .current_release_build.asc_processing_state == "VALID"
    and .current_release_build.app_store_version_attachment == "ATTACHED"
    and .current_release_build.version_state == "WAITING_FOR_REVIEW"
    and .current_release_build.release_method == "manual"
    and .current_release_build.asc_review_submission_id == "6d2feeff-0f90-4b34-b0c8-b22a3b1928b7"
    and .current_release_build.asc_review_submission_submitted_at == "2026-08-07T15:33:05.463Z"
    and .current_release_build.asc_review_submission_item_count == 2
    and (.current_release_build.asc_review_submission_item_details | all(.[]; .state == "READY_FOR_REVIEW"))
    and .current_release_build.ipa_local_verification.size_bytes == 23420062
    and .current_release_build.ipa_local_verification.sha256 == "25c2c1ff17b14bd976392f3d8d6d1c103bd5488de66b866cadb8a5339f627889"
    and .current_release_build.ipa_local_verification.build == "7"
    and .current_release_build.apple_server_validation.status == "VERIFY_SUCCEEDED"
    and .current_release_build.apple_server_validation.validated == true
    and .current_release_build.apple_server_validation.errors == []
    and .current_release_build.apple_server_validation.before_upload == true
    and .historical_local_build_7_pre_upload.app_id == "6798449478"
    and .historical_local_build_7_pre_upload.bundle_id == "com.solkim.weekkeep"
    and .historical_local_build_7_pre_upload.version == "1.0.0"
    and .historical_local_build_7_pre_upload.build == "7"
    and .historical_local_build_7_pre_upload.source_ssot == "project.yml"
    and .historical_local_build_7_pre_upload.status == "HISTORICAL_PRE_UPLOAD_VALIDATION"
    and .historical_local_build_7_pre_upload.upload_state == "NOT_UPLOADED"
    and .historical_local_build_7_pre_upload.asc_build_id == null
    and .historical_local_build_7_pre_upload.asc_processing_state == "NOT_UPLOADED"
    and .historical_local_build_7_pre_upload.app_store_version_attachment == "NOT_ATTACHED"
    and .historical_local_build_7_pre_upload.review_submission_state == "NOT_SUBMITTED"
    and .historical_local_build_7_pre_upload.live_state == "NOT_LIVE"
    and .historical_local_build_7_pre_upload.external_validation_status == "APPLE_SERVER_VALIDATED_ONLY"
    and .historical_local_build_7_pre_upload.apple_server_validation.status == "VERIFY_SUCCEEDED"
    and .historical_local_build_7_pre_upload.apple_server_validation.validated == true
    and .historical_local_build_7_pre_upload.apple_server_validation.scope == "exported_ipa_only"
    and .historical_local_build_7_pre_upload.apple_server_validation.command == "asc xcode validate"
    and .historical_local_build_7_pre_upload.apple_server_validation.remote_registration == "NOT_PERFORMED"
    and .historical_local_build_7_pre_upload.apple_server_validation.ipa_sha256 == "6d8b62a2d8d354debf777791cbc795ddde662c01bdb0da91f31640c101b8d2bf"
    and (.historical_local_build_7_pre_upload.next_sharing_improvements | sort) == [
      "conversational_prompt_and_invitation",
      "cumulative_family_week_ordinal",
      "privacy_safe_share_completed"
    ]
  ' "$shipaton" >/dev/null; then
    pass "Shipaton manifest records current submitted build 7 and a separately labeled historical pre-upload build-7 validation snapshot, with the replacement lifecycle and IPA evidence exact."
  else
    fail "Shipaton manifest build identity boundary is inconsistent: current submitted build 7 and its historical pre-upload snapshot must remain distinct."
  fi

  for boundary_document in "$project_root/release/README.md" "$project_root/docs/07-DELIVERY-PLAN.md" "$core_document"; do
    if rg -q 'build 7' "$boundary_document" \
      && rg -q -i 'uploaded.*(VALID|attached)|VALID.*attached' "$boundary_document" \
      && rg -q -i 'WAITING_FOR_REVIEW' "$boundary_document" \
      && rg -q -i 'approval.*pending|public release.*pending|not.*public.*release' "$boundary_document" \
      && ! rg -q -i 'build 7[^\n]*(not uploaded|unuploaded|not attached|unattached|not submitted|validation[- ]only)' "$boundary_document"; then
      pass "$(basename "$boundary_document") documents build 7 as the uploaded/attached review build with approval and release still pending."
    else
      fail "$(basename "$boundary_document") must document build 7 as uploaded/attached/in review while keeping approval and public release pending."
    fi
  done
}

validate_local_physical_screenshot_evidence() {
  local evidence_directory
  local evidence_summary
  local evidence_checksums
  local image_name
  local image_path
  local image_facts
  local actual_width
  local actual_height
  local actual_alpha
  local actual_sha
  local expected_sha

  if ! command -v shasum >/dev/null 2>&1 || ! command -v sips >/dev/null 2>&1; then
    fail "physical screenshot evidence requires shasum and sips"
    return
  fi

  if ! evidence_directory="$(jq -er '.local_build6_debug_fixture_physical_screenshot_evidence.evidence_directory' "$shipaton")"; then
    fail "Shipaton manifest does not define local build-6 physical screenshot evidence"
    return
  fi

  evidence_summary="$project_root/$evidence_directory/QA-SUMMARY.md"
  evidence_checksums="$project_root/$evidence_directory/SHA256SUMS.txt"
  if [[ ! -d "$project_root/$evidence_directory" || ! -f "$evidence_summary" || ! -f "$evidence_checksums" ]]; then
    fail "local physical screenshot evidence directory or summary/checksum file is missing"
    return
  fi

  for image_name in 01-onboarding-physical.png 02-ready-physical.png; do
    image_path="$project_root/$evidence_directory/$image_name"
    if [[ ! -f "$image_path" ]]; then
      fail "local physical screenshot evidence is missing $image_name"
      continue
    fi
    if ! expected_sha="$(jq -er --arg name "$image_name" '.local_build6_debug_fixture_physical_screenshot_evidence.screenshots[] | select(.name == $name) | .sha256' "$shipaton")" \
      || ! actual_sha="$(shasum -a 256 "$image_path" | awk '{print $1}')"; then
      fail "could not resolve or calculate the exact SHA256 for $image_name"
    elif [[ "$actual_sha" == "$expected_sha" ]]; then
      pass "$image_name matches the exact SHA256 recorded in the Shipaton manifest."
    else
      fail "$image_name SHA256 does not match the Shipaton manifest (got $actual_sha, expected $expected_sha)"
    fi
  done

  if (cd "$project_root/$evidence_directory" && shasum -a 256 -c SHA256SUMS.txt >/dev/null); then
    pass "local physical screenshot evidence destination hashes match SHA256SUMS.txt."
  else
    fail "local physical screenshot evidence destination hashes do not match SHA256SUMS.txt"
  fi

  for image_name in 01-onboarding-physical.png 02-ready-physical.png; do
    image_path="$project_root/$evidence_directory/$image_name"
    if ! image_facts="$(sips -g pixelWidth -g pixelHeight -g hasAlpha "$image_path" 2>/dev/null)"; then
      fail "could not inspect local physical screenshot dimensions/alpha for $image_name"
      continue
    fi
    actual_width="$(printf '%s\n' "$image_facts" | awk '/pixelWidth:/{print $2}')"
    actual_height="$(printf '%s\n' "$image_facts" | awk '/pixelHeight:/{print $2}')"
    actual_alpha="$(printf '%s\n' "$image_facts" | awk '/hasAlpha:/{print $2}')"
    if [[ "$actual_width" == "1206" && "$actual_height" == "2622" && "$actual_alpha" == "no" ]]; then
      pass "$image_name is exactly 1206x2622 and has no alpha."
    else
      fail "$image_name must be exactly 1206x2622 with no alpha (got ${actual_width:-missing}x${actual_height:-missing}, alpha=${actual_alpha:-missing})"
    fi
  done

  if jq -e '
    .local_build6_debug_fixture_physical_screenshot_evidence.status == "validated_local_debug_fixture_only"
    and .local_build6_debug_fixture_physical_screenshot_evidence.scope == "local_debug_fixture_not_remote_asc_build_6"
    and .local_build6_debug_fixture_physical_screenshot_evidence.remote_build_ref == "current_release_build"
    and .local_build6_debug_fixture_physical_screenshot_evidence.current_build_7_ref == "current_release_build"
    and .local_build6_debug_fixture_physical_screenshot_evidence.bundle_id == "com.solkim.weekkeep"
    and .local_build6_debug_fixture_physical_screenshot_evidence.build == "6"
    and (.local_build6_debug_fixture_physical_screenshot_evidence.screenshots | length) == 2
    and (.local_build6_debug_fixture_physical_screenshot_evidence.screenshots | all(.[]; .width == 1206 and .height == 2622 and .alpha == false and .opacity == "opaque"))
    and .local_build6_debug_fixture_physical_screenshot_evidence.visual_finding.finding == "ready_primary_start_cta_below_initial_viewport"
    and .local_build6_debug_fixture_physical_screenshot_evidence.visual_finding.contract == "no_scroll_first_cta"
    and .local_build6_debug_fixture_physical_screenshot_evidence.visual_finding.build7_physical_verification == "resolved_in_local_debug_fixture_build7"
    and .local_build6_debug_fixture_physical_screenshot_evidence.visual_finding.remote_replacement_authorization == "explicit_user_authorization_required"
    and .current_release_build.build == "7"
    and .current_release_build.asc_build_id == "1c51b451-d37f-4704-89c9-e426b1ee5725"
    and .current_release_build.upload_state == "uploaded"
    and .current_release_build.app_store_version_attachment == "ATTACHED"
    and .historical_local_build_7_pre_upload.build == "7"
    and .historical_local_build_7_pre_upload.upload_state == "NOT_UPLOADED"
    and .historical_local_build_7_pre_upload.asc_build_id == null
    and .intake_filter.gates.target_device_footage.status == "pending_external"
    and .intake_filter.gates.target_device_footage.local_physical_screenshot_status == "validated_local_debug_fixture_build6_and_local_build7_screenshot_evidence"
    and .intake_filter.gates.target_device_footage.local_physical_screenshot_scope == "build6_historical_finding_preserved_build7_local_physical_screenshots_not_remote_asc_or_production_photokit"
    and (.external_evidence.target_device_physical_screenshots | startswith("validated_local_debug_fixture_build6"))
    and (.local_build6_debug_fixture_physical_screenshot_evidence.non_claims | index("local_build7_physical_behavior") != null)
    and (.local_build6_debug_fixture_physical_screenshot_evidence.non_claims | index("native_share_sheet_and_share_delivery") != null)
    and (.local_build6_debug_fixture_physical_screenshot_evidence.non_claims | index("purchase_and_restore") != null)
    and (.local_build6_debug_fixture_physical_screenshot_evidence.non_claims | index("actual_photokit_performance") != null)
    and (.local_build6_debug_fixture_physical_screenshot_evidence.non_claims | index("remote_asc_binary_identity") != null)
    and (.local_build6_debug_fixture_physical_screenshot_evidence.non_claims | index("public_app_store_release") != null)
    and (.local_build6_debug_fixture_physical_screenshot_evidence.non_claims | index("devpost_submission") != null)
  ' "$shipaton" >/dev/null; then
    pass "Shipaton manifest records physical screenshot facts, the CTA finding, and the remote-build-6/local-build-7 boundary without overclaiming."
  else
    fail "Shipaton manifest physical screenshot evidence, CTA finding, or build boundary is inconsistent"
  fi

  if rg -F -q -- 'Local DEBUG fixture evidence only' "$evidence_summary" \
    && rg -F -q -- 'not remote App Store Connect build 6' "$evidence_summary" \
    && rg -F -q -- 'local build 7' "$evidence_summary" \
    && rg -F -q -- 'primary start CTA below the initial viewport' "$evidence_summary" \
    && rg -F -q -- 'no-scroll-first-CTA UX requirement' "$evidence_summary" \
    && rg -F -q -- 'This evidence does not prove:' "$evidence_summary" \
    && rg -F -q -- 'public App Store release' "$evidence_summary" \
    && rg -F -q -- "xcrun devicectl device process launch --device 'iPhone' --terminate-existing com.solkim.weekkeep -- -ui-fixtures" "$evidence_summary" \
    && rg -F -q -- "xcrun devicectl device process launch --device 'iPhone' --terminate-existing --environment-variables '{\"WK_UI_TEST_FIXTURES\":\"1\",\"WK_UI_FIXTURE_SCREEN\":\"ready\"}' com.solkim.weekkeep -- -ui-fixtures -ui-fixtures-skip-notification" "$evidence_summary"; then
    pass "Physical screenshot QA summary preserves exact fixture launches, the CTA finding, and explicit non-claims."
  else
    fail "Physical screenshot QA summary is missing the required boundary, launch, finding, or non-claim text"
  fi
}

validate_local_build7_physical_screenshot_evidence() {
  local evidence_directory
  local evidence_summary
  local evidence_checksums
  local image_name
  local image_path
  local source_label
  local image_facts
  local actual_width
  local actual_height
  local actual_alpha
  local actual_sha
  local expected_sha
  local expected_checksum_file
  local actual_checksum_file
  local debug_launch_command

  debug_launch_command="xcrun devicectl device process launch --device 'iPhone' --terminate-existing --environment-variables '{\"WK_UI_TEST_FIXTURES\":\"1\",\"WK_UI_FIXTURE_SCREEN\":\"ready\"}' com.solkim.weekkeep -- -ui-fixtures -ui-fixtures-skip-notification"

  if ! evidence_directory="$(jq -er '.local_build7_physical_screenshot_evidence.evidence_directory' "$shipaton")"; then
    fail "Shipaton manifest does not define local build-7 physical screenshot evidence"
    return
  fi

  evidence_summary="$project_root/$evidence_directory/QA-SUMMARY.md"
  evidence_checksums="$project_root/$evidence_directory/SHA256SUMS.txt"
  if [[ ! -d "$project_root/$evidence_directory" || ! -f "$evidence_summary" || ! -f "$evidence_checksums" ]]; then
    fail "local build-7 physical screenshot evidence directory or summary/checksum file is missing"
    return
  fi

  if ! jq -e '
    .local_build7_physical_screenshot_evidence.status == "validated_local_physical_screenshots_only"
    and .local_build7_physical_screenshot_evidence.evidence_directory == "release/local/target-device-qa/20260807T2033KST-build7-physical-screenshots"
    and .local_build7_physical_screenshot_evidence.summary == "release/local/target-device-qa/20260807T2033KST-build7-physical-screenshots/QA-SUMMARY.md"
    and .local_build7_physical_screenshot_evidence.sha256sums == "release/local/target-device-qa/20260807T2033KST-build7-physical-screenshots/SHA256SUMS.txt"
    and .local_build7_physical_screenshot_evidence.bundle_id == "com.solkim.weekkeep"
    and .local_build7_physical_screenshot_evidence.version == "1.0.0"
    and .local_build7_physical_screenshot_evidence.build == "7"
    and .local_build7_physical_screenshot_evidence.scope == "local_physical_device_screenshots_not_production_photokit"
    and .local_build7_physical_screenshot_evidence.remote_build_ref == "current_release_build"
    and .local_build7_physical_screenshot_evidence.current_build_ref == "current_release_build"
    and .local_build7_physical_screenshot_evidence.remote_asc_build_7_identity_recorded == true
    and .local_build7_physical_screenshot_evidence.device == "iPhone 16 Pro"
    and .local_build7_physical_screenshot_evidence.os == "iOS 26.5.2"
    and .local_build7_physical_screenshot_evidence.installed_on_device_note == "DEBUG build 7 after second install"
    and .local_build7_physical_screenshot_evidence.install_sequence[0].artifact_path == "LOCAL_ARCHIVE_BUILD7/Weekkeep.xcarchive/Products/Applications/Weekkeep.app"
    and .local_build7_physical_screenshot_evidence.install_sequence[0].pre_install_version == "1.0.0"
    and .local_build7_physical_screenshot_evidence.install_sequence[0].pre_install_build == "7"
    and .local_build7_physical_screenshot_evidence.install_sequence[0].development_signed == true
    and .local_build7_physical_screenshot_evidence.install_sequence[0].get_task_allow == true
    and .local_build7_physical_screenshot_evidence.install_sequence[1].artifact_path == "SIGNED_DEBUG_FIXTURE_BUILD7/Build/Products/Debug-iphoneos/Weekkeep.app"
    and .local_build7_physical_screenshot_evidence.install_sequence[1].pre_install_version == "1.0.0"
    and .local_build7_physical_screenshot_evidence.install_sequence[1].pre_install_build == "7"
    and .local_build7_physical_screenshot_evidence.install_sequence[1].development_signed == true
    and .local_build7_physical_screenshot_evidence.install_sequence[1].get_task_allow == true
    and .local_build7_physical_screenshot_evidence.install_sequence[1].executable_mtime == "2026-08-07 19:20:27 +0900"
    and .local_build7_physical_screenshot_evidence.launch_commands.archive_waiting.command == "Launched without a DEBUG fixture environment."
    and .local_build7_physical_screenshot_evidence.launch_commands.archive_waiting.standalone_shell_command_supplied == false
    and .local_build7_physical_screenshot_evidence.launch_commands.debug_fixture_ready == "xcrun devicectl device process launch --device \u0027iPhone\u0027 --terminate-existing --environment-variables \u0027{\"WK_UI_TEST_FIXTURES\":\"1\",\"WK_UI_FIXTURE_SCREEN\":\"ready\"}\u0027 com.solkim.weekkeep -- -ui-fixtures -ui-fixtures-skip-notification"
    and (.local_build7_physical_screenshot_evidence.screenshots | length) == 2
    and (.local_build7_physical_screenshot_evidence.screenshots | any(.[]; .name == "01-production-waiting-physical.png" and .source_path == "PHYSICAL_DEVICE_CAPTURE/01-production-waiting-physical.png" and .surface == "local_archive_waiting_surface" and .width == 1206 and .height == 2622 and .alpha == false and .opacity == "opaque" and .sha256 == "ff9a9d359f64c7baa604d229d30600619c14199e86c0c8dbf6e7ada8401f485c"))
    and (.local_build7_physical_screenshot_evidence.screenshots | any(.[]; .name == "02-debug-fixture-ready-physical.png" and .source_path == "PHYSICAL_DEVICE_CAPTURE/02-debug-fixture-ready-physical.png" and .surface == "signed_debug_fixture_ready_surface" and .width == 1206 and .height == 2622 and .alpha == false and .opacity == "opaque" and .sha256 == "b679c7bb0c83853701b4216535f06291d00b1139327ec9027933a2c4e103df21"))
    and .local_build7_physical_screenshot_evidence.finding_resolution.historical_build6_finding == "ready_primary_start_cta_below_initial_viewport"
    and .local_build7_physical_screenshot_evidence.finding_resolution.contract == "no_scroll_first_cta"
    and .local_build7_physical_screenshot_evidence.finding_resolution.status == "resolved_in_local_debug_fixture_build7"
    and .local_build7_physical_screenshot_evidence.finding_resolution.scope == "local_debug_fixture_only"
    and .local_build7_physical_screenshot_evidence.finding_resolution.remote_replacement == "not_performed_or_authorized"
    and (.local_build7_physical_screenshot_evidence.pending_gates | index("native_share_sheet_and_share_delivery") != null)
    and (.local_build7_physical_screenshot_evidence.pending_gates | index("remote_asc_registration_attachment_review_approval_release") != null)
    and (.local_build7_physical_screenshot_evidence.non_claims | index("purchase_and_restore") != null)
    and (.local_build7_physical_screenshot_evidence.non_claims | index("actual_photokit_performance") != null)
    and (.local_build7_physical_screenshot_evidence.non_claims | index("remote_asc_build_7_binary_identity") != null)
    and (.local_build7_physical_screenshot_evidence.non_claims | index("app_store_live_or_public_release") != null)
    and (.local_build7_physical_screenshot_evidence.non_claims | index("physical_device_video") != null)
    and .local_build6_debug_fixture_physical_screenshot_evidence.visual_finding.build7_physical_verification == "resolved_in_local_debug_fixture_build7"
  ' "$shipaton" >/dev/null; then
    fail "Shipaton manifest build-7 physical screenshot evidence, hashes, scope, or finding resolution is inconsistent"
  else
    pass "Shipaton manifest records exact build-7 physical screenshot hashes, build/scope boundaries, CTA resolution, and pending non-claims."
  fi

  for image_name in 01-production-waiting-physical.png 02-debug-fixture-ready-physical.png; do
    image_path="$project_root/$evidence_directory/$image_name"
    case "$image_name" in
      01-production-waiting-physical.png)
        source_label="PHYSICAL_DEVICE_CAPTURE/01-production-waiting-physical.png"
        expected_sha="ff9a9d359f64c7baa604d229d30600619c14199e86c0c8dbf6e7ada8401f485c"
        ;;
      02-debug-fixture-ready-physical.png)
        source_label="PHYSICAL_DEVICE_CAPTURE/02-debug-fixture-ready-physical.png"
        expected_sha="b679c7bb0c83853701b4216535f06291d00b1139327ec9027933a2c4e103df21"
        ;;
    esac

    if [[ ! -f "$image_path" ]]; then
      fail "local build-7 physical screenshot destination is missing for $image_name"
      continue
    fi
    if ! actual_sha="$(shasum -a 256 "$image_path" | awk '{print $1}')"; then
      fail "could not calculate destination SHA256 for $image_name"
    elif [[ "$actual_sha" == "$expected_sha" ]]; then
      pass "$image_name destination matches the exact manifest SHA256 for public source label $source_label."
    else
      fail "$image_name destination SHA256 does not match the exact expected hash (destination=$actual_sha, expected=$expected_sha, source_label=$source_label)"
    fi
    if ! image_facts="$(sips -g pixelWidth -g pixelHeight -g hasAlpha "$image_path" 2>/dev/null)"; then
      fail "could not inspect local build-7 physical screenshot dimensions/alpha for $image_name"
      continue
    fi
    actual_width="$(printf '%s\n' "$image_facts" | awk '/pixelWidth:/{print $2}')"
    actual_height="$(printf '%s\n' "$image_facts" | awk '/pixelHeight:/{print $2}')"
    actual_alpha="$(printf '%s\n' "$image_facts" | awk '/hasAlpha:/{print $2}')"
    if [[ "$actual_width" == "1206" && "$actual_height" == "2622" && "$actual_alpha" == "no" ]]; then
      pass "$image_name is exactly 1206x2622 and has no alpha."
    else
      fail "$image_name must be exactly 1206x2622 with no alpha (got ${actual_width:-missing}x${actual_height:-missing}, alpha=${actual_alpha:-missing})"
    fi
  done

  expected_checksum_file=$'ff9a9d359f64c7baa604d229d30600619c14199e86c0c8dbf6e7ada8401f485c  01-production-waiting-physical.png\nb679c7bb0c83853701b4216535f06291d00b1139327ec9027933a2c4e103df21  02-debug-fixture-ready-physical.png'
  actual_checksum_file="$(< "$evidence_checksums")"
  if [[ "$actual_checksum_file" == "$expected_checksum_file" ]]; then
    pass "SHA256SUMS.txt contains exactly the two manifest hashes and filenames."
  else
    fail "SHA256SUMS.txt does not contain the exact manifest hashes and filenames"
  fi
  if (cd "$project_root/$evidence_directory" && shasum -a 256 -c SHA256SUMS.txt >/dev/null); then
    pass "local build-7 physical screenshot destination hashes match SHA256SUMS.txt."
  else
    fail "local build-7 physical screenshot destination hashes do not match SHA256SUMS.txt"
  fi

  if rg -F -q -- 'local archive build-7 waiting surface' "$evidence_summary" \
    && rg -F -q -- 'local DEBUG fixture build-7 ready surface' "$evidence_summary" \
    && rg -F -q -- 'fully visible in the initial viewport' "$evidence_summary" \
    && rg -F -q -- 'no-scroll-first-CTA' "$evidence_summary" \
    && rg -F -q -- 'distinct three-item bottom navigation' "$evidence_summary" \
    && rg -F -q -- 'distinct calendar/photo/settings bottom-nav icons' "$evidence_summary" \
    && rg -F -q -- 'native share/share delivery and the external lifecycle gates remain pending' "$evidence_summary" \
    && rg -F -q -- "$debug_launch_command" "$evidence_summary" \
    && rg -F -q -- 'current installed app note above is intentionally explicit because the DEBUG install occurred after the archive install' "$evidence_summary" \
    && rg -F -q -- 'No device serial, UDID, contact information, credentials' "$evidence_summary" \
    && rg -F -q -- 'App Store upload, attachment, review approval, public release, or live-store availability' "$evidence_summary"; then
    pass "Build-7 physical screenshot summary records exact provenance, visual findings, scope boundaries, pending gates, and non-claims."
  else
    fail "Build-7 physical screenshot summary is missing exact provenance, visual findings, scope boundaries, pending gates, or non-claims"
  fi
}

if (( core_only == 1 )); then
  if ! command -v jq >/dev/null 2>&1; then
    fail "required command is missing: jq"
  elif [[ ! -f "$shipaton" || ! -f "$core_document" ]]; then
    fail "Shipaton manifest or submission SSOT is missing"
  elif ! jq empty "$shipaton" >/dev/null; then
    fail "invalid JSON: release/shipaton-manifest.json"
  else
    validate_shipaton_core_readiness
    validate_share_contract
    validate_judging_evidence
    validate_local_physical_screenshot_evidence
    validate_local_build7_physical_screenshot_evidence
    validate_build_identity_boundary
  fi

  if (( failures > 0 )); then
    echo "Shipaton core validation failed with $failures failure(s)." >&2
    exit 1
  fi
  echo "Shipaton core validation passed."
  exit 0
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "required command is missing: $1"
  fi
}

for command_name in xcodegen xcodebuild jq plutil sips shasum xmllint rg node npm npx; do
  require_command "$command_name"
done

for required_file in \
  "$metadata" \
  "$privacy" \
  "$shipaton" \
  "$core_document" \
  "$release_config" \
  "$remotion_project/package.json" \
  "$remotion_project/package-lock.json" \
  "$remotion_project/src/index.ts" \
  "$remotion_project/src/Root.tsx" \
  "$remotion_project/src/data/audio_meta.json" \
  "$remotion_project/src/data/caption_groups.json" \
  "$provenance_script"; do
  if [[ ! -f "$required_file" ]]; then
    fail "required release file is missing: ${required_file#$project_root/}"
  fi
done

if (( failures > 0 )); then
  exit 1
fi

for json_file in "$metadata" "$privacy" "$shipaton"; do
  if ! jq empty "$json_file" >/dev/null; then
    fail "invalid JSON: ${json_file#$project_root/}"
  fi
done

validate_shipaton_core_readiness
validate_share_contract
validate_judging_evidence
validate_local_physical_screenshot_evidence
validate_local_build7_physical_screenshot_evidence
validate_build_identity_boundary

xcodegen_version="$(xcodegen --version | awk '{print $NF}')"
if [[ "$xcodegen_version" != "2.46.0" ]]; then
  fail "XcodeGen 2.46.0 is required; found $xcodegen_version"
else
  pass "XcodeGen is pinned to 2.46.0."
fi

if ! git check-ignore -q Weekkeep.xcodeproj; then
  fail "generated Weekkeep.xcodeproj must remain ignored; project.yml is the SSOT"
fi

# Resolve the project spec without writing an .xcodeproj. The repository
# contract makes project.yml the SSOT and this validator must remain read-only.
project_summary="$(xcodegen dump --spec project.yml --type summary 2>&1)"
if printf '%s\n' "$project_summary" \
  | rg -q '^Name: Weekkeep$' \
  && printf '%s\n' "$project_summary" | rg -q '^  Weekkeep: iOS application$' \
  && printf '%s\n' "$project_summary" | rg -q '^  WeekkeepTests: iOS unitTestBundle$' \
  && printf '%s\n' "$project_summary" | rg -q '^  WeekkeepUITests: iOS uiTestBundle$'; then
  pass "project.yml resolves to the Weekkeep app, unit-test, and UI-test targets without generating an Xcode project."
else
  fail "XcodeGen could not resolve the required target graph from project.yml"
fi

if "$project_root/scripts/validate-localization.sh"; then
  pass "String Catalog, plural, format, and localized call-site contracts pass."
else
  fail "localization validation failed"
fi

if bash "$project_root/scripts/validate-public-source.sh"; then
  pass "Public-source, license, ignore, and redacted candidate scans pass."
else
  fail "public-source validation failed"
fi

if "$project_root/scripts/validate-release-assets.sh" >/dev/null; then
  pass "canonical app icon and exact-seven vector contracts pass."
else
  fail "release asset validation failed"
fi

# This validator is intentionally local-only: it inspects frozen assets and
# runs the canonical Remotion checks/listing without installing packages or
# rendering an MP4. The original tree remains the provenance origin.
if "$provenance_script"; then
  pass "source-media/license provenance and deterministic BGM contracts pass."
else
  fail "video provenance validation failed"
fi

validate_remotion_project() {
  local remotion_root="$remotion_project/src/Root.tsx"
  local caption_groups="$remotion_project/src/data/caption_groups.json"
  local remotion_out="$remotion_project/out"
  local out_existed=0
  local composition_output
  local scene_count
  local transition_count
  local fade_count
  local timing_count
  local preview_approval_status

  if [[ -e "$remotion_out" ]]; then
    out_existed=1
  fi

  if [[ ! -d "$remotion_project/node_modules" || ! -x "$remotion_project/node_modules/.bin/remotion" ]]; then
    fail "canonical Remotion dependencies are unavailable at ${remotion_project#$project_root/}; install from the checked-in lockfile before rerunning (this validator never installs packages or uses the network)."
    return
  fi

  if (cd "$remotion_project" && npm run check); then
    pass "canonical Remotion npm run check passes."
  else
    fail "canonical Remotion npm run check failed in ${remotion_project#$project_root/}"
  fi

  if composition_output="$(cd "$remotion_project" && npx --no-install remotion compositions src/index.ts 2>&1)"; then
    if printf '%s\n' "$composition_output" | rg -q 'WeekkeepShipaton72[[:space:]]+30[[:space:]]+1920x1080[[:space:]]+2160[[:space:]]+\(72\.00 sec\)'; then
      pass "canonical Remotion composition listing matches WeekkeepShipaton72 at 1920x1080, 30fps, 2160 frames, and 72.00 seconds."
    else
      fail "Remotion composition listing did not contain the required WeekkeepShipaton72 contract."
      printf '%s\n' "$composition_output" >&2
    fi
  else
    fail "canonical Remotion composition listing failed; no renderer was invoked."
    printf '%s\n' "$composition_output" >&2
  fi

  scene_count="$(rg -c '<TransitionSeries\.Sequence name=' "$remotion_root" || true)"
  transition_count="$(rg -c '<TransitionSeries\.Transition' "$remotion_root" || true)"
  fade_count="$(rg -c 'presentation=\{fade\(\)\}' "$remotion_root" || true)"
  timing_count="$(rg -c 'linearTiming\(\{ durationInFrames: 12 \}\)' "$remotion_root" || true)"
  if [[ "$scene_count" == "10" && "$transition_count" == "9" && "$fade_count" == "9" && "$timing_count" == "9" ]]; then
    pass "Remotion source contains 10 scenes with 9 restrained 12-frame fades."
  else
    fail "Remotion scene transition contract drifted (scenes=$scene_count, transitions=$transition_count, fades=$fade_count, 12-frame timings=$timing_count; expected 10, 9, 9, 9)."
  fi

  if jq -e '.groups | length == 23' "$caption_groups" >/dev/null; then
    pass "Remotion caption data contains exactly 23 semantic groups."
  else
    fail "Remotion caption data must contain exactly 23 semantic groups."
  fi

  if (( out_existed == 0 )) && [[ -e "$remotion_out" ]]; then
    fail "Remotion validation created ${remotion_out#$project_root/}; checks must not create an output directory."
  else
    pass "Remotion validation did not create ${remotion_out#$project_root/}."
  fi
  preview_approval_status="$(jq -r '.demo.preview_approval_status' "$shipaton")"
  case "$preview_approval_status" in
    pending_external)
      if [[ -f "$remotion_out/weekkeep-shipaton-72.mp4" ]]; then
        fail "final MP4 is present at ${remotion_out#$project_root/}/weekkeep-shipaton-72.mp4 even though preview approval is pending."
      else
        pass "final Remotion MP4 is not present; preview approval remains pending."
      fi
      ;;
    Validated)
      if [[ -f "$remotion_out/weekkeep-shipaton-72.mp4" ]]; then
        pass "final Remotion MP4 is present only after preview approval was externally validated."
      else
        fail "preview approval is Validated but final Remotion MP4 is missing."
      fi
      ;;
    *)
      fail "unsupported Remotion preview approval status: $preview_approval_status"
      ;;
  esac
}

validate_remotion_project

candidate_build="$(jq -er '.app.current_build.build' "$metadata")"
candidate_screenshot_directory="$(jq -er '.screenshots.app_store.evidence_directory' "$metadata")"
candidate_visual_qa_directory="$(jq -er '.app.current_build.visual_qa_evidence_directory' "$metadata")"
local_candidate_build="$(jq -er '.historical_local_build_7_pre_upload.build' "$shipaton")"

metadata_field() {
  jq -er "$1" "$metadata"
}

assert_jq() {
  local expression="$1"
  local message="$2"
  if jq -e --arg candidate_build "$candidate_build" --arg candidate_screenshot_directory "$candidate_screenshot_directory" --arg candidate_visual_qa_directory "$candidate_visual_qa_directory" "$expression" "$metadata" >/dev/null; then
    pass "$message"
  else
    fail "$message"
  fi
}

assert_shipaton_jq() {
  local expression="$1"
  local message="$2"
  if jq -e --arg candidate_build "$candidate_build" --arg local_candidate_build "$local_candidate_build" --arg candidate_screenshot_directory "$candidate_screenshot_directory" --arg candidate_visual_qa_directory "$candidate_visual_qa_directory" --arg canonical_repository_url "$canonical_repository_url" --arg canonical_raw_license_url "$canonical_raw_license_url" --arg canonical_checked_at "$canonical_checked_at" --arg canonical_main_commit "$canonical_main_commit" --arg expected_evidence "$validated_public_source_evidence" "$expression" "$shipaton" >/dev/null; then
    pass "$message"
  else
    fail "$message"
  fi
}

assert_privacy_jq() {
  local expression="$1"
  local message="$2"
  if jq -e --arg candidate_build "$candidate_build" --arg candidate_screenshot_directory "$candidate_screenshot_directory" --arg candidate_visual_qa_directory "$candidate_visual_qa_directory" "$expression" "$privacy" >/dev/null; then
    pass "$message"
  else
    fail "$message"
  fi
}

assert_text_limit() {
  local expression="$1"
  local limit="$2"
  local mode="$3"
  local label="$4"
  local value
  local count
  value="$(metadata_field "$expression")"
  if [[ "$mode" == "bytes" ]]; then
    count="$(printf '%s' "$value" | LC_ALL=C wc -c | tr -d ' ')"
  else
    count="$(jq -er "$expression | length" "$metadata")"
  fi
  if (( count <= limit )); then
    pass "$label is within its ${limit}${mode/bytes/ byte} limit (${count})."
  else
    fail "$label exceeds its ${limit}${mode/bytes/ byte} limit (${count})."
  fi
}

assert_jq '.app.bundle_id == "com.solkim.weekkeep" and .app.sku == "WEEKKEEP-IOS-2026" and .app.version == "1.0.0" and .app.build == $candidate_build and .app.release_method == "manual" and .app.current_build.build == $candidate_build and .app.current_build.status == "ASC_CURRENT_ATTACHED" and .app.current_build.upload_state == "uploaded" and .app.current_build.asc_build_id == "1c51b451-d37f-4704-89c9-e426b1ee5725" and .app.current_build.asc_processing_state == "VALID" and .app.current_build.uploaded_at == "2026-08-07T08:28:29-07:00" and .app.current_build.app_store_version_attachment == "ATTACHED" and .app.current_build.app_store_version_id == "ac4f183e-1019-4ffc-827f-f5514f0d349b" and .app.current_build.review_submission_id == "6d2feeff-0f90-4b34-b0c8-b22a3b1928b7" and .app.current_build.review_submission_state == "WAITING_FOR_REVIEW" and .app.current_build.review_submission_item_count == 2 and (.app.current_build.review_submission_item_details | all(.[]; .state == "READY_FOR_REVIEW")) and .app.current_build.ipa_local_verification.size_bytes == 23420062 and .app.current_build.ipa_local_verification.sha256 == "25c2c1ff17b14bd976392f3d8d6d1c103bd5488de66b866cadb8a5339f627889" and .app.current_build.ipa_local_verification.build == "7" and .app.current_build.apple_server_validation.status == "VERIFY_SUCCEEDED" and .app.current_build.apple_server_validation.validated == true and .app.current_build.apple_server_validation.errors == [] and .app.current_build.apple_server_validation.before_upload == true and .app.current_build.visual_qa_evidence_directory == $candidate_visual_qa_directory and .app.current_build.visual_qa_evidence_scope == "historical_build6_settings_visual_qa_not_app_store_screenshot_evidence"' "App identity and canonical build-7 attachment match the release contract."
assert_jq '.app.asc_state.app_id == "6798449478" and .app.asc_state.version_id == "ac4f183e-1019-4ffc-827f-f5514f0d349b" and .app.asc_state.build_id == "1c51b451-d37f-4704-89c9-e426b1ee5725" and .app.asc_state.build_processing_state == "VALID" and .app.asc_state.build_uploaded_at == "2026-08-07T08:28:29-07:00" and .app.asc_state.version_state == "WAITING_FOR_REVIEW" and .app.asc_state.app_store_version_attachment == "ATTACHED" and .app.asc_state.remote_build_scope == "current_build_7_attached" and .app.asc_state.review_submission_id == "6d2feeff-0f90-4b34-b0c8-b22a3b1928b7" and .app.asc_state.review_submission_submitted_at == "2026-08-07T15:33:05.463Z" and .app.asc_state.review_submission_item_count == 2 and (.app.asc_state.review_submission_item_details | all(.[]; .state == "READY_FOR_REVIEW")) and .app.asc_state.iap_id == "6798491084" and .app.asc_state.iap_product_id == "weekkeep_plus_lifetime" and .app.asc_state.iap_version_id == "cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f" and .app.asc_state.iap_version_state == "WAITING_FOR_REVIEW" and .app.remote_unattached_valid_build.build == "4" and .app.remote_unattached_valid_build.asc_build_id == "6e92c470-c044-4512-9276-71491fe97685" and .app.remote_unattached_valid_build.status == "VALID_UNATTACHED" and .app.remote_unattached_valid_build.asc_processing_state == "VALID" and .app.remote_unattached_valid_build.app_store_version_attachment == "UNATTACHED" and .app.asc_state.current_build == $candidate_build and .app.asc_state.historical_review_submission_id == "a9b0a18f-6cf6-4af4-8e6f-c77009831e00" and .app.asc_state.historical_review_submission_state == "COMPLETE" and .app.asc_state.historical_review_submission_build == "6" and .app.asc_state.historical_build_3_review_submission_id == "88c157ee-ce87-41c3-8a4a-71e614993a58"' "Current build-7 review, IAP, and historical build-6/build-3 state are distinct and exact."
assert_jq '.app.primary_category_identifier == "public.app-category.photo-video"' "App category matches Info.plist."
assert_jq '
  .app.current_build.historical_build_6_testflight_internal_qa.group_name == "Weekkeep Internal QA"
  and .app.current_build.historical_build_6_testflight_internal_qa.group_id == "576fd29a-7a64-4521-9164-9697ec1c256f"
  and .app.current_build.historical_build_6_testflight_internal_qa.group_builds == ["6"]
  and .app.current_build.historical_build_6_testflight_internal_qa.group_build_count == 1
  and .app.current_build.historical_build_6_testflight_internal_qa.build_status == "READY_FOR_BETA_TESTING"
  and .app.current_build.historical_build_6_testflight_internal_qa.tester_count == 1
  and .app.current_build.historical_build_6_testflight_internal_qa.public_ssot_contains_tester_email == false
  and ((.app.current_build.historical_build_6_testflight_internal_qa.testers | length) == 1)
  and ((.app.current_build.historical_build_6_testflight_internal_qa.testers[0] | has("email")) | not)
  and .app.current_build.historical_build_6_testflight_internal_qa.testers[0].role == "account_holder"
  and .app.current_build.historical_build_6_testflight_internal_qa.testers[0].tester_id == "bef018ab-9514-4388-804d-bcd363f601d4"
  and .app.current_build.historical_build_6_testflight_internal_qa.testers[0].state == "INVITED"
  and .app.current_build.historical_build_6_testflight_internal_qa.testers[0].account_holder_verified == true
  and .app.current_build.historical_build_6_testflight_internal_qa.distribution_status == "ready_invited"
  and .app.current_build.historical_build_6_testflight_internal_qa.installed == false
  and .app.current_build.historical_build_6_testflight_internal_qa.purchase_tested == false
  and .app.current_build.historical_build_6_testflight_internal_qa.restore_tested == false
' "Historical build-6 TestFlight internal QA distribution is ready/invited only and exact, with tester email omitted from public SSOT."
assert_jq '.iap.product_id == "weekkeep_plus_lifetime" and .iap.entitlement_id == "plus" and .iap.offering_id == "default" and .iap.type == "non-consumable" and .iap.us_base_price_usd == 19.99' "RevenueCat/App Store IAP identifiers and US price match."
assert_jq '.screenshots.shipaton_proof.width == 1179 and .screenshots.shipaton_proof.height == 2556 and .screenshots.shipaton_proof.alpha == false and .screenshots.shipaton_proof.device_frame == false' "Shipaton screenshot contract is explicit."
assert_jq '.screenshots.app_store.evidence_build == "5" and .screenshots.app_store.evidence_directory == $candidate_screenshot_directory and .screenshots.app_store.evidence_scope == "historical_local_build5_candidate_not_target" and .screenshots.app_store.current_build_visual_qa_directory == $candidate_visual_qa_directory and .screenshots.app_store.current_build_visual_qa_scope == "historical_build6_settings_visual_qa_not_app_store_screenshot_evidence" and .screenshots.app_store.asc_screenshot_replacement_verified == false and .screenshots.app_store.remote_review_evidence_scope == "historical_build3_evidence_replaced_by_build7_review_submission"' "Historical build-5/build-3 screenshot evidence remains separate from current build-7 lifecycle and historical build-6 visual QA."
assert_privacy_jq '.target.app_id == "6798449478" and .target.build == "7" and .target.asc_build_id == "1c51b451-d37f-4704-89c9-e426b1ee5725" and .target.app_store_version_id == "ac4f183e-1019-4ffc-827f-f5514f0d349b" and .target.review_submission_id == "6d2feeff-0f90-4b34-b0c8-b22a3b1928b7" and .target.review_submission_state == "WAITING_FOR_REVIEW" and .target.review_submission_submitted_at == "2026-08-07T15:33:05.463Z" and .target.review_submission_item_count == 2 and .target.review_submission_item_state == "READY_FOR_REVIEW" and .target.iap_id == "6798491084" and .target.iap_product_id == "weekkeep_plus_lifetime" and .target.iap_version_id == "cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f" and .target.iap_version_state == "WAITING_FOR_REVIEW" and .target.app_privacy_publish_state == "PUBLISHED_CURRENT_APP_VERSION" and .target.app_privacy_scope == "current_app_version_1.0.0" and .target.ipa_evidence == null and .target.ipa_evidence_status == "verified_local_without_tracked_evidence_file" and .target.ipa_local_verification.size_bytes == 23420062 and .target.ipa_local_verification.sha256 == "25c2c1ff17b14bd976392f3d8d6d1c103bd5488de66b866cadb8a5339f627889" and .target.ipa_local_verification.bundle_id == "com.solkim.weekkeep" and .target.ipa_local_verification.version == "1.0.0" and .target.ipa_local_verification.build == "7" and .target.ipa_local_verification.purchases == true and .target.ipa_local_verification.analytics == false and .target.ipa_local_verification.privacy_info_present == true and .target.ipa_local_verification.signing_identity == "Apple Distribution sol kim" and .target.ipa_local_verification.team_id == "D48DDX5D5W" and .remote_unattached_valid_build.build == "4" and .remote_unattached_valid_build.asc_build_id == "6e92c470-c044-4512-9276-71491fe97685" and .remote_unattached_valid_build.processing_state == "VALID" and .remote_unattached_valid_build.app_store_version_attachment == "UNATTACHED" and .historical_replaced_build_6.build == "6" and .historical_replaced_build_6.review_submission_state == "COMPLETE" and .historical_build_3.build == "3" and .historical_build_3.review_submission_state == "CANCELED_REPLACED" and .historical_local_candidate_build_5.build == "5"' "Privacy manifest scopes publication to the current build-7 app version and preserves historical build-6/build-3 evidence."
assert_jq '.locales | keys == ["en-US", "ko"]' "English and Korean metadata locales are present."
assert_jq '.locales["en-US"].subtitle == "Up to seven moments each week" and .locales.ko.subtitle == "최대 7장으로 남기는 일주일" and (.locales["en-US"].description | contains("Photo selection and share rendering are processed on your iPhone")) and (.locales["en-US"].description | contains("Sharing starts only when you explicitly choose it")) and (.locales["en-US"].description | contains("analytics services")) and (.locales["en-US"].description | contains("measurement services") | not) and (.locales.ko.description | contains("사진 고르기와 공유 이미지 만들기는 이 iPhone에서 처리해요")) and (.locales.ko.description | contains("직접 선택할 때만 시작되고"))' "Store subtitles and privacy copy use truthful up-to-seven, on-device, analytics, and explicit-sharing wording."
assert_jq '(.review.notes_en | contains("Choose your first week")) and (.review.notes_en | contains("Change this photo")) and (.review.notes_en | contains("Learn about Weekkeep Plus"))' "App Review notes use shipped action labels."
assert_jq '(.review.notes_en | contains("Photo selection and share rendering are processed on the iPhone")) and (.review.notes_en | contains("analytics services")) and (.review.notes_en | contains("measurement services") | not) and (.review.notes_en | contains("explicit user action"))' "App Review privacy notes distinguish on-device processing from explicit sharing and use analytics terminology."

assert_shipaton_jq '(.schema_version == 2) and (.intake_filter.schema_version == 2) and ((.intake_filter.gates | keys | sort) == ["app_icon", "bundle_package_identifier", "judge_unlock", "public_demo_video", "public_source_repository", "published_store_page_url", "required_fields_and_category_answers", "screenshot", "target_device_footage"])' "Shipaton manifest schema and intake gate names are present."
assert_shipaton_jq '.current_release_build.app_id == "6798449478" and .current_release_build.bundle_id == "com.solkim.weekkeep" and .current_release_build.build == $candidate_build and .current_release_build.release_method == "manual" and .current_release_build.upload_state == "uploaded" and .current_release_build.asc_build_id == "1c51b451-d37f-4704-89c9-e426b1ee5725" and .current_release_build.asc_processing_state == "VALID" and .current_release_build.uploaded_at == "2026-08-07T08:28:29-07:00" and .current_release_build.app_store_version_attachment == "ATTACHED" and .current_release_build.app_store_version_id == "ac4f183e-1019-4ffc-827f-f5514f0d349b" and .current_release_build.asc_review_submission_id == "6d2feeff-0f90-4b34-b0c8-b22a3b1928b7" and .current_release_build.asc_review_submission_state == "WAITING_FOR_REVIEW" and .current_release_build.asc_review_submission_submitted_at == "2026-08-07T15:33:05.463Z" and .current_release_build.asc_review_submission_item_count == 2 and (.current_release_build.asc_review_submission_item_details | all(.[]; .state == "READY_FOR_REVIEW")) and .current_release_build.ipa_local_verification.size_bytes == 23420062 and .current_release_build.ipa_local_verification.sha256 == "25c2c1ff17b14bd976392f3d8d6d1c103bd5488de66b866cadb8a5339f627889" and .current_release_build.ipa_local_verification.bundle_id == "com.solkim.weekkeep" and .current_release_build.ipa_local_verification.version == "1.0.0" and .current_release_build.ipa_local_verification.build == "7" and .current_release_build.ipa_local_verification.purchases == true and .current_release_build.ipa_local_verification.analytics == false and .current_release_build.ipa_local_verification.privacy_info_present == true and .current_release_build.ipa_local_verification.signing_identity == "Apple Distribution sol kim" and .current_release_build.ipa_local_verification.team_id == "D48DDX5D5W" and .current_release_build.apple_server_validation.status == "VERIFY_SUCCEEDED" and .current_release_build.apple_server_validation.validated == true and .current_release_build.apple_server_validation.errors == [] and .current_release_build.apple_server_validation.before_upload == true and .current_release_build.app_store_screenshot_evidence_scope == "historical_local_build5_candidate_not_target" and .current_release_build.visual_qa_evidence == $candidate_visual_qa_directory and .current_release_build.visual_qa_evidence_scope == "historical_build6_settings_visual_qa_not_app_store_screenshot_evidence" and .historical_replaced_build_6.build == "6" and .historical_replaced_build_6.asc_build_id == "0ffa7586-619f-4df9-abc5-ae7ebbd068b1" and .historical_replaced_build_6.review_submission_id == "a9b0a18f-6cf6-4af4-8e6f-c77009831e00" and .historical_replaced_build_6.review_submission_state == "COMPLETE" and .remote_review_build_3.build == "3" and .remote_review_build_3.asc_processing_state == "VALID" and .remote_review_build_3.app_store_version_attachment == "HISTORICAL_REPLACED_BY_BUILD_7" and .remote_review_build_3.review_submission_state == "CANCELED_REPLACED" and .remote_unattached_valid_build_4.build == "4" and .remote_unattached_valid_build_4.asc_build_id == "6e92c470-c044-4512-9276-71491fe97685" and .remote_unattached_valid_build_4.asc_processing_state == "VALID" and .remote_unattached_valid_build_4.app_store_version_attachment == "UNATTACHED"' "Shipaton manifest records the canonical build-7 review state and preserves build-6/build-3/build-4 history."
assert_shipaton_jq '.current_release_build.app_review_approval_state == "NOT_APPROVED" and .current_release_build.public_release_state == "NOT_RELEASED" and .current_release_build.next_action == "WAIT_FOR_APP_REVIEW_THEN_MANUALLY_RELEASE_AFTER_APPROVAL" and .verification_evidence.full_xcode_test_result == {"passed":174,"failed":0,"skipped":4,"total":178} and .verification_evidence.public_site_tests == {"passed":8,"failed":0,"total":8} and (.external_evidence.public_policy_site | contains("sites_version=5"))' "Release lifecycle, full Xcode tests, and Sites version-5 test evidence are exact while App Review and public release remain pending."
assert_shipaton_jq '
  .public_policy_site_evidence.project_id == "appgprj_6a72c9365eec81918b26c45fa645d052"
  and .public_policy_site_evidence.version_id == "appgprj_6a72c9365eec81918b26c45fa645d052~appgver_8f6f65e98d7481918e624d70677135a2"
  and .public_policy_site_evidence.version_number == 5
  and .public_policy_site_evidence.source_commit_sha == "600fe8201080a319a9f4d61ba052e27a57a8a078"
  and .public_policy_site_evidence.archive_storage == {
    "archive_format": "tar",
    "content_hash": "sha256:5d7aaaff4eb6e30c14cf75347e62134f9c44f24fc9cf6eb623b8a653a71ba164",
    "size_bytes": 23357440,
    "file_count": 100
  }
  and .public_policy_site_evidence.deployment_id == "appgdep_6a75fdfb2bdc8191bd8aeff13d9c3143"
  and .public_policy_site_evidence.provider_deployment_id == "kimsol1134--weekkeep-app"
  and .public_policy_site_evidence.deployment_status == "succeeded"
  and .public_policy_site_evidence.deployment_timestamp == "2026-08-07T15:48:08.282102+00:00"
  and .public_policy_site_evidence.access_mode == "public"
  and .public_policy_site_evidence.url == "https://weekkeep-app.kimsol1134.chatgpt.site"
  and .public_policy_site_evidence.routes == ["/", "/privacy", "/support", "/terms"]
  and .public_policy_site_evidence.logged_out_http_status == 200
  and .public_policy_site_evidence.http_verification_timestamp == "2026-08-07T16:15:44Z"
  and .public_policy_site_evidence.site_tests == {"passed":8,"failed":0,"total":8}
' "Current Sites version-5 provenance, deployment, archive, and four-route HTTP-200 evidence are exact."
assert_shipaton_jq '
  .public_policy_site_evidence.historical_version_4.source_commit_sha == "935e647562020d32dc9d2f6079a32c5042067af0"
  and .public_policy_site_evidence.historical_version_4.deployment_id == "appgdep_6a74555f5b488191bd12c8f047ba655b"
  and .public_policy_site_evidence.historical_version_4.deployment_timestamp == "2026-08-06T09:35:40.860943+00:00"
  and .public_policy_site_evidence.historical_version_4.http_verification_timestamp == "2026-08-06T09:37:49+00:00"
' "Historical Sites version-4 provenance remains separate and exact."
assert_shipaton_jq '
  .intake_filter.gates.public_source_repository.required == true
  and .intake_filter.gates.public_source_repository.status == "Validated"
  and .intake_filter.gates.public_source_repository.repository_url == $canonical_repository_url
  and .intake_filter.gates.public_source_repository.repository_visibility_status == "public"
  and .intake_filter.gates.public_source_repository.source_availability.required == true
  and .intake_filter.gates.public_source_repository.source_availability.status == "Validated"
  and .intake_filter.gates.public_source_repository.source_availability.evidence_ref == "external_evidence.public_source_repository"
  and .intake_filter.gates.public_source_repository.logged_out_verification.required == true
  and .intake_filter.gates.public_source_repository.logged_out_verification.status == "Validated"
  and .intake_filter.gates.public_source_repository.logged_out_verification.checked_at == $canonical_checked_at
  and .intake_filter.gates.public_source_repository.logged_out_verification.evidence_ref == "external_evidence.public_source_repository"
  and .intake_filter.gates.public_source_repository.license.path == "LICENSE"
  and .intake_filter.gates.public_source_repository.license.spdx_id == "MIT"
  and .intake_filter.gates.public_source_repository.license.osi_approved == true
  and .intake_filter.gates.public_source_repository.license.holder == "Sol Kim"
  and .intake_filter.gates.public_source_repository.license.local_status == "validated_local"
  and .external_evidence.public_source_repository == $expected_evidence
  and ($expected_evidence | contains("raw_license_url=" + $canonical_raw_license_url + ";raw_license_http_status=200"))
  and ($expected_evidence | contains("default_branch=main;git_ls_remote_main_commit=" + $canonical_main_commit))
' "Public-source repository, source availability, logged-out verification, and MIT license gates record the validated public repository evidence."
assert_shipaton_jq '
  .status == "internal_package_ready_external_evidence_pending"
  and .overall == null
  and ([(.intake_filter.gates | to_entries[] | select(.key != "public_source_repository" and .key != "public_demo_video") | .value.status)] | all(. == "pending_external"))
  and .intake_filter.gates.bundle_package_identifier.revenuecat_sdk_verification_status == "pending_external"
  and .intake_filter.gates.judge_unlock.offer.external_offer_status == "pending_external"
  and .release_eligibility.first_public_release.status == "pending_external"
  and .release_eligibility.published_eligible_store.status == "pending_external"
  and .release_eligibility.downloadable_in_us.status == "pending_external"
  and .release_eligibility.revenuecat_qualifying_path.status == "pending_external"
' "Root, overall, and all intake gates other than public source and public demo remain pending."
assert_shipaton_jq '
  def allowed_status: . == "pending_external" or . == "Validated";
  def pending_evidence: type == "string" and startswith("pending_");
  def validated_evidence: type == "string" and startswith("validated_");
  .status_contract.allowed_gate_states == ["pending_external", "Validated"]
  and .status_contract.pending_state_does_not_claim_external_completion == true
  and (.status_contract.transition.pending_external_to_Validated | type) == "string"
  and (.status_contract.validated_state_requirements | length) >= 3
  and (.intake_filter.gates | to_entries | all(.[];
    .value as $gate
    | ($gate.status | allowed_status)
  ))' "Shipaton lifecycle contract defines pending and future Validated states."
assert_shipaton_jq '
  . as $root
  | all($root.intake_filter.gates | to_entries[];
      .value as $gate
      | ($root | getpath(($gate.evidence_ref | split(".")))) as $evidence
      | (if $gate.status == "pending_external" then ($evidence | (type == "string" and startswith("pending_"))) else ($evidence | (type == "string" and startswith("validated_"))) end)
    )
  and (($root.intake_filter.gates.bundle_package_identifier.status == "pending_external" and $root.intake_filter.gates.bundle_package_identifier.revenuecat_sdk_verification_status == "pending_external") or ($root.intake_filter.gates.bundle_package_identifier.status == "Validated" and $root.intake_filter.gates.bundle_package_identifier.revenuecat_sdk_verification_status == "Validated"))' "Shipaton gate status and linked evidence remain coherent across pending and future Validated transitions."
assert_shipaton_jq '
  .official_rules.snapshot_date == "2026-08-06"
  and .official_rules.source == "https://revenuecat-shipaton-2026.devpost.com/rules"
  and .official_rules.submission_window.starts_at == "2026-07-31T08:00:00-07:00"
  and .official_rules.submission_window.ends_at == "2026-09-30T23:45:00-07:00"
  and .official_rules.judging_ends_at == "2026-10-13T12:00:00-07:00"
  and .official_rules.winners_announced_on == "2026-10-21"
  and .official_rules.non_next_gen_eligibility.track == "non_next_gen"
  and (.official_rules.non_next_gen_eligibility.acceptable_revenuecat_paths | sort) == ["IAP", "ads", "web_purchase"]' "Official dated rules snapshot and non-Next-Gen eligibility contract are explicit."
assert_shipaton_jq '
  . as $root
  | all(($root.release_eligibility | to_entries[] | select(.value | type == "object" and has("status")));
      (.value as $item
       | (($item.status == "pending_external" or $item.status == "Validated")
          and ((($root | getpath(($item.evidence_ref | split(".")))) as $evidence
                | if $item.status == "pending_external" then ($evidence | (type == "string" and startswith("pending_"))) else ($evidence | (type == "string" and startswith("validated_"))) end))))
    )
  and .release_eligibility.track == "non_next_gen"
  and ((.release_eligibility.first_public_release.status == "pending_external" and .release_eligibility.first_public_release.released_at == null) or (.release_eligibility.first_public_release.status == "Validated" and (.release_eligibility.first_public_release.released_at | type) == "string"))
  and ((.release_eligibility.published_eligible_store.status == "pending_external" and .release_eligibility.published_eligible_store.url == null) or (.release_eligibility.published_eligible_store.status == "Validated" and (.release_eligibility.published_eligible_store.url | type) == "string"))
  and .release_eligibility.revenuecat_qualifying_path.selected_path == "IAP"
  and .release_eligibility.revenuecat_qualifying_path.product_id == "weekkeep_plus_lifetime"' "Release eligibility evidence has a future-valid state path without claiming launch completion."
assert_shipaton_jq '(.intake_filter.gates.bundle_package_identifier.required == true) and (.intake_filter.gates.bundle_package_identifier.bundle_id == "com.solkim.weekkeep") and (.intake_filter.gates.bundle_package_identifier.revenuecat_sdk_verification_status | . == "pending_external" or . == "Validated")' "Bundle identifier and RevenueCat SDK verification gate are explicit."
assert_shipaton_jq '(.intake_filter.gates.required_fields_and_category_answers.required == true) and (.intake_filter.gates.required_fields_and_category_answers.required_fields_source == "docs/11-SHIPATON-SUBMISSION.md") and (.intake_filter.gates.required_fields_and_category_answers.category_answers_source == "docs/11-SHIPATON-SUBMISSION.md")' "Required Devpost fields and category answers are linked to the submission SSOT."
assert_shipaton_jq '(.intake_filter.gates.published_store_page_url.required == true) and ((.intake_filter.gates.published_store_page_url.status == "pending_external" and .intake_filter.gates.published_store_page_url.url == null) or (.intake_filter.gates.published_store_page_url.status == "Validated" and (.intake_filter.gates.published_store_page_url.url | type) == "string"))' "Published store page URL gate is required and its pending/Validated value is coherent."
assert_shipaton_jq '(.intake_filter.gates.public_demo_video.required == true) and (.intake_filter.gates.public_demo_video.accepted_platforms == ["YouTube", "Vimeo"]) and (.intake_filter.gates.public_demo_video.duration_seconds == 72) and (.intake_filter.gates.public_demo_video.maximum_seconds == 120) and (.intake_filter.gates.public_demo_video.duration_seconds < .intake_filter.gates.public_demo_video.maximum_seconds) and (.intake_filter.gates.public_demo_video.public_visibility_required == true) and (.intake_filter.gates.public_demo_video.unlicensed_third_party_material_allowed == false) and (.intake_filter.gates.public_demo_video.source_project == "videos/weekkeep-remotion") and ((.intake_filter.gates.public_demo_video.status == "pending_external" and .intake_filter.gates.public_demo_video.public_url == null) or (.intake_filter.gates.public_demo_video.status == "Validated" and (.intake_filter.gates.public_demo_video.public_url | type) == "string")) and (.demo.target_seconds == 72)' "Public demo gate preserves the canonical under-two-minute Remotion contract and official publication rules."
assert_shipaton_jq '(.intake_filter.gates.public_demo_video.status == "Validated") and (.intake_filter.gates.public_demo_video.public_url == "https://youtu.be/WJP6xoWV440") and (.intake_filter.gates.public_demo_video.canonical_short_url == "https://youtu.be/WJP6xoWV440") and (.intake_filter.gates.public_demo_video.canonical_watch_url == "https://www.youtube.com/watch?v=WJP6xoWV440") and (.intake_filter.gates.public_demo_video.video_id == "WJP6xoWV440") and (.intake_filter.gates.public_demo_video.title == "Weekkeep — A Week Worth Keeping | Shipaton 2026") and (.intake_filter.gates.public_demo_video.channel == "sol kim") and (.intake_filter.gates.public_demo_video.visibility == "Public") and (.intake_filter.gates.public_demo_video.published_on == "2026-08-07") and (.intake_filter.gates.public_demo_video.backup_release_url == "https://github.com/kimsol1134/weekkeep/releases/tag/shipaton-demo-v1") and (.intake_filter.gates.public_demo_video.backup_asset_url == "https://github.com/kimsol1134/weekkeep/releases/download/shipaton-demo-v1/weekkeep-shipaton-72.mp4") and (.intake_filter.gates.public_demo_video.backup_release_http_status == 200) and (.intake_filter.gates.public_demo_video.backup_asset_http_status == 200) and (.intake_filter.gates.public_demo_video.backup_asset_sha256 == "9d4afb5332d3bbaeb0fc40e5d1d71c6a66b7cf2d72b79ed8a7ab3c2864e5a01a") and (.intake_filter.gates.public_demo_video.official_platform_gate == "validated_youtube_public_logged_out_playback_and_duration") and (.intake_filter.gates.public_demo_video.logged_out_verification.status == "Validated") and (.intake_filter.gates.public_demo_video.logged_out_verification.checked_on == "2026-08-07") and (.intake_filter.gates.public_demo_video.logged_out_verification.curl.short_url_followed == true) and (.intake_filter.gates.public_demo_video.logged_out_verification.curl.watch_url_http_status == 200) and (.intake_filter.gates.public_demo_video.logged_out_verification.oembed.status == "Validated") and (.intake_filter.gates.public_demo_video.logged_out_verification.oembed.title == "Weekkeep — A Week Worth Keeping | Shipaton 2026") and (.intake_filter.gates.public_demo_video.logged_out_verification.oembed.author == "sol kim") and (.intake_filter.gates.public_demo_video.logged_out_verification.oembed.embeddable_iframe == true) and (.intake_filter.gates.public_demo_video.logged_out_verification.oembed.thumbnail_present == true) and (.intake_filter.gates.public_demo_video.logged_out_verification.oembed.provider == "YouTube") and (.intake_filter.gates.public_demo_video.logged_out_verification.yt_dlp.status == "Validated") and (.intake_filter.gates.public_demo_video.logged_out_verification.yt_dlp.cookies == "none") and (.intake_filter.gates.public_demo_video.logged_out_verification.yt_dlp.duration_seconds == 72) and (.intake_filter.gates.public_demo_video.logged_out_verification.yt_dlp.availability == "public") and (.intake_filter.gates.public_demo_video.logged_out_verification.yt_dlp.live_status == "not_live") and (.intake_filter.gates.public_demo_video.logged_out_verification.yt_dlp.age_limit == 0) and (.intake_filter.gates.public_demo_video.logged_out_verification.yt_dlp.formats_count == 12) and (.intake_filter.gates.public_demo_video.logged_out_verification.yt_dlp.channel == "sol kim") and (.intake_filter.gates.public_demo_video.logged_out_verification.yt_dlp.upload_date == "20260807") and (.intake_filter.gates.public_demo_video.logged_out_verification.duration_verification.status == "Validated") and (.intake_filter.gates.public_demo_video.logged_out_verification.duration_verification.duration_seconds == 72) and (.intake_filter.gates.public_demo_video.logged_out_verification.duration_verification.maximum_seconds == 120) and (.intake_filter.gates.public_demo_video.logged_out_verification.duration_verification.constraint == "less_than_maximum") and (.intake_filter.gates.public_demo_video.youtube_metadata.language == "English (United States)") and (.intake_filter.gates.public_demo_video.youtube_metadata.category == "Science & Technology") and (.intake_filter.gates.public_demo_video.youtube_metadata.made_for_kids == false) and (.intake_filter.gates.public_demo_video.youtube_metadata.altered_or_synthetic_disclosure == "yes_approved_generated_narration_provenance") and (.intake_filter.gates.public_demo_video.youtube_metadata.embedding_allowed == true) and (.intake_filter.gates.public_demo_video.youtube_metadata.shorts_remix == "disabled") and (.intake_filter.gates.public_demo_video.copyright_check == "no_issues_found") and (.external_evidence.public_demo_video | startswith("validated_"))' "Official public YouTube demo, logged-out playback/duration evidence, and preserved backup are Validated."
assert_shipaton_jq '(.intake_filter.gates.target_device_footage.required == true) and (.intake_filter.gates.target_device_footage.target_device == "iPhone") and (.intake_filter.gates.target_device_footage.must_show_functioning_project == true)' "Target-device functioning footage is an explicit pending gate."
assert_shipaton_jq '(.provenance.source_media_project == "videos/weekkeep-shipaton") and (.provenance.validation_script == "videos/weekkeep-shipaton/scripts/validate-provenance.sh") and (.demo.source_project == "videos/weekkeep-remotion") and ((.demo.preview_approval_status == "pending_external" and .demo.render_status == "composition_validated_final_mp4_not_rendered_preview_approval_pending") or (.demo.preview_approval_status == "Validated" and .demo.render_status == "rendered_after_user_preview_approval"))' "Video provenance origin, canonical Remotion source, and approval/render lifecycle are distinct."
assert_shipaton_jq '(.demo.validation.check == "passed") and (.demo.validation.composition_listing == "passed") and (.demo.validation.composition_id == "WeekkeepShipaton72") and (.demo.validation.width == 1920) and (.demo.validation.height == 1080) and (.demo.validation.fps == 30) and (.demo.validation.duration_in_frames == 2160) and (.demo.validation.duration_seconds == 72) and (.demo.validation.scene_count == 10) and (.demo.validation.transition_count == 9) and (.demo.validation.transition_style == "restrained_fade") and (.demo.validation.transition_duration_frames == 12) and (.demo.validation.caption_group_count == 23) and (.demo.validation.caption_source == "videos/weekkeep-remotion/src/data/audio_meta.json") and (.demo.validation.caption_groups_source == "videos/weekkeep-remotion/src/data/caption_groups.json") and (.demo.validation.caption_derivation == "derived_from_approved_audio_meta") and ((.demo.preview_approval_status == "pending_external" and .demo.validation.final_mp4 == "not_present_preview_approval_pending") or (.demo.preview_approval_status == "Validated" and .demo.validation.final_mp4 == "present_after_user_preview_approval"))' "Remotion composition validation preserves canonical facts and keeps final MP4 gated by preview approval."
assert_shipaton_jq '((.demo.preview_approval_status == "pending_external" and .external_evidence.final_video_approval_and_render == "pending_user_preview_approval") or (.demo.preview_approval_status == "Validated" and (.external_evidence.final_video_approval_and_render | startswith("validated_")))) and ((.intake_filter.gates.public_demo_video.status == "pending_external") or (.intake_filter.gates.public_demo_video.status == "Validated" and .demo.preview_approval_status == "Validated"))' "Final video approval/render and public demo publication retain a coherent lifecycle."
assert_shipaton_jq '(.intake_filter.gates.app_icon.required == true) and (.intake_filter.gates.app_icon.width == 1024) and (.intake_filter.gates.app_icon.height == 1024) and (.intake_filter.gates.app_icon.alpha == false)' "Shipaton icon intake gate preserves the 1024x1024 opaque contract."
assert_shipaton_jq '(.intake_filter.gates.screenshot.required == true) and (.intake_filter.gates.screenshot.minimum_count == 4) and (.intake_filter.gates.screenshot.selected_names == ["01-welcome", "02-review", "03-save-confirmation", "04-share-preview"]) and (.intake_filter.gates.screenshot.width == 1179) and (.intake_filter.gates.screenshot.height == 2556) and (.intake_filter.gates.screenshot.alpha == false) and (.intake_filter.gates.screenshot.device_frame == false)' "Shipaton screenshot intake gate preserves the selected build-7 four-name 1179x2556 no-frame contract."
assert_shipaton_jq '(.intake_filter.gates.judge_unlock.required == true) and (.intake_filter.gates.judge_unlock.audience == ["Sponsor", "Admin", "Judges"]) and (.intake_filter.gates.judge_unlock.free_and_unrestricted == true) and (.intake_filter.gates.judge_unlock.unlocks_all_premium_features == true) and (.intake_filter.gates.judge_unlock.valid_through == .official_rules.testing_access.valid_through) and (.official_rules.testing_access.offer_expiry_must_be_after == .intake_filter.gates.judge_unlock.valid_through) and (.intake_filter.gates.judge_unlock.offer.mechanism == "Offer Code") and (.intake_filter.gates.judge_unlock.offer.devpost_label == "promo code") and (.intake_filter.gates.judge_unlock.offer.product_id == "weekkeep_plus_lifetime") and (.intake_filter.gates.judge_unlock.offer.product_type == "non-consumable") and (.intake_filter.gates.judge_unlock.offer.price == "free") and (.intake_filter.gates.judge_unlock.offer.eligibility == "everyone") and (.intake_filter.gates.judge_unlock.offer.territories == ["US"]) and (.intake_filter.gates.judge_unlock.offer.real_code_stored_in_manifest == false) and (.intake_filter.gates.judge_unlock.offer.code_storage == "external_uncommitted") and ((.intake_filter.gates.judge_unlock.status == "pending_external" and .intake_filter.gates.judge_unlock.offer.external_offer_status == "pending_external") or (.intake_filter.gates.judge_unlock.status == "Validated" and .intake_filter.gates.judge_unlock.offer.external_offer_status == "Validated"))' "Judge access encodes the free IAP Offer Code plan, audience, US eligibility, and no-code-in-Git rule."
assert_shipaton_jq '(.intake_filter.gates.judge_unlock.offer.remote_configuration.status == "configured") and (.intake_filter.gates.judge_unlock.offer.remote_configuration.app_id == "6798449478") and (.intake_filter.gates.judge_unlock.offer.remote_configuration.iap_id == "6798491084") and (.intake_filter.gates.judge_unlock.offer.remote_configuration.offer_id == "bb4f7fd6-2b08-4aa7-9f55-e140a3e94e28") and (.intake_filter.gates.judge_unlock.offer.remote_configuration.free_prices == ["USA:FREE", "KOR:FREE"]) and (.intake_filter.gates.judge_unlock.offer.production_judge_code.generated == false) and (.intake_filter.gates.judge_unlock.offer.production_judge_code.attempted_custom_code == "WEEKKEEPJUDGES") and (.intake_filter.gates.judge_unlock.offer.production_judge_code.attempt_status == "rejected_parent_iap_not_approved") and (.intake_filter.gates.judge_unlock.offer.production_judge_code.production_code_created == false) and (.intake_filter.gates.judge_unlock.offer.production_judge_code.status == "blocked_until_app_ready_for_distribution_and_iap_approved")' "Judge offer configuration, rejected production custom-code attempt, and production-code block are exact."
assert_shipaton_jq '(.intake_filter.prescreening.submission_is_read == true) and (.intake_filter.prescreening.first_two_minutes.required == true) and (.intake_filter.prescreening.first_two_minutes.required_messages == ["elevator_pitch", "app_in_use", "targeted_categories"]) and (.intake_filter.prescreening.source == "https://www.shipaton.com/blog/how-we-judge-shipaton")' "Prescreening first-two-minute messages and official source are explicit."
assert_shipaton_jq '((.category_decisions | length) == 21) and (([.category_decisions[] | .category] | sort) == ["#BuildInPublic", "Best App for Galaxy / Samsung", "Best Game", "Career Coaching / Leadership Heather", "Catvertising", "Conflict of Interest", "Funnel Vision / Stripe", "Gaming / Mr Lewis Blogs Gaming", "Grand Prize", "Growth Loop / Layers", "HAMM Award (Help Apps Make Money)", "Idea to Income / Replit", "Keep Them Coming Back / OneSignal", "Most Viral App / Noise", "Next Gen", "Nutrition & Healthy Eating / Abbey’s Kitchen", "Productivity / Christopher Lawley", "RevenueCat Design Award", "RevenueCat Peace Prize", "Ship Kotlin Everywhere / JetBrains", "Yoga & Fitness / Simone Sharice"]) and (([.category_decisions[] | .decision] | unique | sort) == ["Conditional", "Exclude", "Focus"]) and (([.category_decisions[] | select(.decision == "Focus") | .category] | sort) == ["#BuildInPublic", "HAMM Award (Help Apps Make Money)", "RevenueCat Design Award"]) and (([.category_decisions[] | select(.decision == "Conditional") | .category] | sort) == ["Grand Prize", "Most Viral App / Noise", "RevenueCat Peace Prize"])' "All 21 official categories have MECE Focus, Conditional, or Exclude decisions."

assert_shipaton_jq '
  .current_release_build.historical_build_6_testflight_internal_qa.group_name == "Weekkeep Internal QA"
  and .current_release_build.historical_build_6_testflight_internal_qa.group_id == "576fd29a-7a64-4521-9164-9697ec1c256f"
  and .current_release_build.historical_build_6_testflight_internal_qa.group_builds == ["6"]
  and .current_release_build.historical_build_6_testflight_internal_qa.group_build_count == 1
  and .current_release_build.historical_build_6_testflight_internal_qa.build_status == "READY_FOR_BETA_TESTING"
  and .current_release_build.historical_build_6_testflight_internal_qa.tester_count == 1
  and .current_release_build.historical_build_6_testflight_internal_qa.public_ssot_contains_tester_email == false
  and ((.current_release_build.historical_build_6_testflight_internal_qa.testers | length) == 1)
  and ((.current_release_build.historical_build_6_testflight_internal_qa.testers[0] | has("email")) | not)
  and .current_release_build.historical_build_6_testflight_internal_qa.testers[0].role == "account_holder"
  and .current_release_build.historical_build_6_testflight_internal_qa.testers[0].tester_id == "bef018ab-9514-4388-804d-bcd363f601d4"
  and .current_release_build.historical_build_6_testflight_internal_qa.testers[0].state == "INVITED"
  and .current_release_build.historical_build_6_testflight_internal_qa.testers[0].account_holder_verified == true
  and .current_release_build.historical_build_6_testflight_internal_qa.distribution_status == "ready_invited"
  and .current_release_build.historical_build_6_testflight_internal_qa.installed == false
  and .current_release_build.historical_build_6_testflight_internal_qa.purchase_tested == false
  and .current_release_build.historical_build_6_testflight_internal_qa.restore_tested == false
' "Shipaton manifest records historical build-6 TestFlight internal QA ready/invited state without install or purchase claims, with tester email omitted from public SSOT."
assert_shipaton_jq '
  .current_release_build.target_device_qa_scope == "fixture_only_ui_runner_started_local_authentication_canceled_incomplete_result_not_evidence"
  and .current_release_build.target_device_qa_status == "blocked_local_authentication_code_-4_authentication_canceled"
  and .current_release_build.target_device_qa_result_bundle_status == "invalid_incomplete_info_plist_missing_not_evidence"
  and .current_release_build.target_device_qa_credentials == "none_requested_or_handled"
  and .current_release_build.target_device_qa_permissions_changed == false
  and .current_release_build.target_device_qa_private_pixels_changed == false
  and .intake_filter.gates.target_device_footage.status == "pending_external"
' "Physical build-6 UI failure is recorded with durable non-evidence status only while all target-device gates stay pending."
assert_shipaton_jq '
  .public_policy_site_evidence.internal_tester_domain_matches == 0
  and (.external_evidence.public_policy_site | contains("internal_tester_domain_matches=0"))
' "Public policy evidence keeps the intended support contact while recording zero internal tester-domain matches."
assert_text_limit '.locales["en-US"].name' 30 chars "en-US name"
assert_text_limit '.locales["en-US"].subtitle' 30 chars "en-US subtitle"
assert_text_limit '.locales["en-US"].promotional_text' 170 chars "en-US promotional text"
assert_text_limit '.locales["en-US"].keywords' 100 bytes "en-US keywords"
assert_text_limit '.locales["en-US"].description' 4000 chars "en-US description"
assert_text_limit '.locales.ko.name' 30 chars "Korean name"
assert_text_limit '.locales.ko.subtitle' 30 chars "Korean subtitle"
assert_text_limit '.locales.ko.promotional_text' 170 chars "Korean promotional text"
assert_text_limit '.locales.ko.keywords' 100 bytes "Korean keywords"
assert_text_limit '.locales.ko.description' 4000 chars "Korean description"
assert_text_limit '.iap.localizations["en-US"].display_name' 30 chars "en-US IAP display name"
assert_text_limit '.iap.localizations["en-US"].description' 45 chars "en-US IAP description"
assert_text_limit '.iap.localizations.ko.display_name' 30 chars "Korean IAP display name"
assert_text_limit '.iap.localizations.ko.description' 45 chars "Korean IAP description"

copy_scan_paths=(README.md Weekkeep site/app site/public release docs design project.yml)
absolute_privacy_pattern='photos? (stay|remain) on (this|your) (iphone|device)|photos? (never )?leave (the )?(device|iphone)|사진은 .*iPhone을 떠나|사진.*기기를 떠나|사진.*기기 밖|사진.*밖으로 (나가|보내)|사진은 .*iPhone 안에서만|이 iPhone에서만 분석|사진 정보.*밖으로'
if rg -n -i --glob '!release/local/**' --glob '!Config/Secrets.xcconfig' -e "$absolute_privacy_pattern" "${copy_scan_paths[@]}" >/dev/null; then
  fail "copy contains a disallowed absolute photo-privacy phrase"
else
  pass "recursive copy scan contains no disallowed absolute photo-privacy phrase."
fi
if rg -n -F --glob '!release/local/**' --glob '!Config/Secrets.xcconfig' \
  -e 'Seven photos. One quiet week.' \
  -e '일주일을 7장의 추억으로' \
  -e '사진 7장으로 남겨요.' \
  -e 'A week worth keeping—in seven private moments.' \
  -e 'Seven photos, no streaks:' \
  -e '일주일을 7장으로 남긴다' \
  "${copy_scan_paths[@]}" >/dev/null; then
  fail "copy contains a stale exact-seven marketing subtitle or tagline"
else
  pass "recursive copy scan contains no stale exact-seven marketing subtitle or tagline."
fi

if rg -n "Choose my week" docs release Weekkeep/Resources >/dev/null; then
  fail "release copy contains a stale onboarding action name"
else
  pass "App Review and Shipaton copy use the shipped onboarding action."
fi
if jq -e '.strings["onboarding.primary"].localizations.en.stringUnit.value == "Choose your first week"' Weekkeep/Resources/Localizable.xcstrings >/dev/null; then
  pass "English onboarding action matches the review notes."
else
  fail "English onboarding action is missing or drifted"
fi
if [[ -x scripts/capture-build7-shipaton-screenshots.sh ]] \
  && rg -n 'testCaptureBuild7ShipatonSubmissionScreenshotsWhenRequested' WeekkeepUITests/WeekkeepUITests.swift >/dev/null \
  && rg -q 'WK_CAPTURE_BUILD7_SHIPATON_SCREENSHOTS' scripts/capture-build7-shipaton-screenshots.sh; then
  pass "Build-7 Shipaton fixture screenshot capture is wired to the opt-in XCTest attachment path."
else
  fail "Build-7 Shipaton fixture screenshot capture path is incomplete"
fi
if [[ -x scripts/validate-submission-screenshots.sh ]] \
  && rg -q '01-welcome' scripts/validate-submission-screenshots.sh \
  && rg -q '02-review' scripts/validate-submission-screenshots.sh \
  && rg -q '03-save-confirmation' scripts/validate-submission-screenshots.sh \
  && rg -q '04-share-preview' scripts/validate-submission-screenshots.sh \
  && rg -q -- '--legacy' scripts/validate-submission-screenshots.sh; then
  pass "Submission screenshot validator enforces the selected build-7 names and explicit legacy mode."
else
  fail "Submission screenshot validation path is incomplete"
fi
if [[ -x scripts/archive-release.sh ]] && ! rg -n 'allowProvisioningUpdates|fastlane|xcrun .*upload|xcrun .*altool|[[:space:]](deliver|pilot)[[:space:]]' scripts/archive-release.sh >/dev/null; then
  pass "Release archive automation is local-only and contains no upload/publish step."
else
  fail "Release archive automation is missing or contains an unsafe external mutation step"
fi

if rg -n '^WK_ANALYTICS_ENABLED = NO$' "$release_config" >/dev/null; then
  pass "Release analytics is explicitly disabled by default."
else
  fail "Release analytics must remain disabled until its privacy gate is reopened"
fi
if rg -n '^WK_PURCHASES_ENABLED = YES$' "$release_config" >/dev/null; then
  pass "Release purchase integration is enabled at the configuration boundary."
else
  fail "Release purchases must be enabled at the configuration boundary"
fi
privacy_json="$(plutil -convert json -o - Weekkeep/Resources/PrivacyInfo.xcprivacy)"
if jq -e '.NSPrivacyTracking == false and (.NSPrivacyCollectedDataTypes | length) == 0' <<<"$privacy_json" >/dev/null; then
  pass "App privacy manifest declares no app-collected data and no tracking."
else
  fail "App privacy manifest does not match the local-only app contract"
fi
if jq -e '.release_configuration.analytics_enabled == false and .release_configuration.tracking == false and .network_boundary.photo_pixels == false and .network_boundary.photos_identifiers == false' "$privacy" >/dev/null; then
  pass "Release privacy manifest preserves the photo and analytics boundary."
else
  fail "release/privacy-manifest.json is inconsistent with the privacy contract"
fi

warn "RevenueCat key presence was intentionally not inspected; purchase smoke test and App Store release remain externally blocked."

external_states="$(jq -r '.external_evidence | to_entries[] | select(.value | test("^pending")) | .key' "$shipaton")"
if [[ -n "$external_states" ]]; then
  warn "external Shipaton/App Store evidence is still pending: $(printf '%s' "$external_states" | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
else
  pass "Shipaton external evidence manifest has no pending entries."
fi

intake_pending_states="$(jq -r '.intake_filter.gates | to_entries[] | select((.value.status == "pending_external") or (.value.revenuecat_sdk_verification_status == "pending_external")) | .key' "$shipaton")"
if [[ -n "$intake_pending_states" ]]; then
  warn "Shipaton intake filter remains externally pending: $(printf '%s' "$intake_pending_states" | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
else
  pass "Shipaton intake filter has no pending external gates."
fi

if (( run_build == 1 )); then
  if xcodebuild -project Weekkeep.xcodeproj -scheme Weekkeep -configuration Release -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build >/dev/null; then
    pass "Release configuration builds for the generic iOS Simulator destination."
  else
    fail "Release configuration build failed"
  fi
fi

if (( failures > 0 )); then
  echo "Release validation failed with $failures failure(s) and $warnings warning(s)." >&2
  exit 1
fi
if (( strict == 1 && warnings > 0 )); then
  echo "Strict release validation blocked by $warnings external-state warning(s)." >&2
  exit 2
fi

echo "Release validation passed with $warnings external-state warning(s)."
