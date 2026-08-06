#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
metadata="$project_root/release/app-store-metadata.json"
privacy="$project_root/release/privacy-manifest.json"
shipaton="$project_root/release/shipaton-manifest.json"
release_config="$project_root/Config/Release.xcconfig"
remotion_project="$project_root/videos/weekkeep-remotion"
provenance_script="$project_root/videos/weekkeep-shipaton/scripts/validate-provenance.sh"
strict=0
run_build=0
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
    -h|--help)
      cat <<'USAGE'
Usage: scripts/validate-release.sh [--strict] [--build]

  default   Validate tracked release contracts and report credential/public-state blockers.
  --strict  Treat missing authenticated release state as a failure.
  --build   Also run a Release iOS Simulator build with signing disabled.
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

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "required command is missing: $1"
  fi
}

for command_name in xcodegen xcodebuild jq plutil sips xmllint rg node npm npx; do
  require_command "$command_name"
done

for required_file in \
  "$metadata" \
  "$privacy" \
  "$shipaton" \
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

xcodegen_version="$(xcodegen --version | awk '{print $NF}')"
if [[ "$xcodegen_version" != "2.46.0" ]]; then
  fail "XcodeGen 2.46.0 is required; found $xcodegen_version"
else
  pass "XcodeGen is pinned to 2.46.0."
fi

if ! git check-ignore -q Weekkeep.xcodeproj; then
  fail "generated Weekkeep.xcodeproj must remain ignored; project.yml is the SSOT"
fi

# Regenerate the ignored project so the validator checks the actual project.yml
# graph and source discovery, while never changing a tracked project file.
if xcodegen generate --spec project.yml >/dev/null; then
  pass "project.yml generates the Xcode project successfully."
else
  fail "XcodeGen could not generate the project from project.yml"
fi

if [[ -f Weekkeep.xcodeproj/xcshareddata/xcschemes/Weekkeep.xcscheme ]] && rg -q 'WeekkeepTests.xctest' Weekkeep.xcodeproj/xcshareddata/xcschemes/Weekkeep.xcscheme; then
  pass "Generated Weekkeep scheme contains the app and test targets."
else
  fail "Generated Weekkeep scheme is missing or incomplete"
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
  if jq -e --arg candidate_build "$candidate_build" --arg candidate_screenshot_directory "$candidate_screenshot_directory" --arg candidate_visual_qa_directory "$candidate_visual_qa_directory" --arg canonical_repository_url "$canonical_repository_url" --arg canonical_raw_license_url "$canonical_raw_license_url" --arg canonical_checked_at "$canonical_checked_at" --arg canonical_main_commit "$canonical_main_commit" --arg expected_evidence "$validated_public_source_evidence" "$expression" "$shipaton" >/dev/null; then
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

assert_jq '.app.bundle_id == "com.solkim.weekkeep" and .app.sku == "WEEKKEEP-IOS-2026" and .app.version == "1.0.0" and .app.build == $candidate_build and .app.release_method == "manual" and .app.current_build.build == $candidate_build and .app.current_build.status == "ASC_CURRENT_ATTACHED" and .app.current_build.upload_state == "uploaded" and .app.current_build.asc_build_id == "0ffa7586-619f-4df9-abc5-ae7ebbd068b1" and .app.current_build.asc_processing_state == "VALID" and .app.current_build.uploaded_at == "2026-08-06T15:31:16-07:00" and .app.current_build.app_store_version_attachment == "ATTACHED" and .app.current_build.app_store_version_id == "ac4f183e-1019-4ffc-827f-f5514f0d349b" and .app.current_build.review_submission_id == "a9b0a18f-6cf6-4af4-8e6f-c77009831e00" and .app.current_build.visual_qa_evidence_directory == $candidate_visual_qa_directory and .app.current_build.visual_qa_evidence_scope == "current_build6_settings_visual_qa_not_app_store_screenshot_evidence"' "App identity and current build-6 attachment match the release contract."
assert_jq '.app.asc_state.app_id == "6798449478" and .app.asc_state.version_id == "ac4f183e-1019-4ffc-827f-f5514f0d349b" and .app.asc_state.build_id == "0ffa7586-619f-4df9-abc5-ae7ebbd068b1" and .app.asc_state.build_processing_state == "VALID" and .app.asc_state.build_uploaded_at == "2026-08-06T15:31:16-07:00" and .app.asc_state.version_state == "WAITING_FOR_REVIEW" and .app.asc_state.app_store_version_attachment == "ATTACHED" and .app.asc_state.remote_build_scope == "current_build_6_attached" and .app.asc_state.review_submission_id == "a9b0a18f-6cf6-4af4-8e6f-c77009831e00" and .app.asc_state.review_submission_submitted_at == "2026-08-06T22:44:38.573Z" and .app.asc_state.review_submission_item_count == 2 and (.app.asc_state.review_submission_item_details | all(.[]; .state == "READY_FOR_REVIEW")) and .app.asc_state.iap_id == "6798491084" and .app.asc_state.iap_product_id == "weekkeep_plus_lifetime" and .app.asc_state.iap_version_id == "cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f" and .app.asc_state.iap_version_state == "WAITING_FOR_REVIEW" and .app.remote_unattached_valid_build.build == "4" and .app.remote_unattached_valid_build.asc_build_id == "6e92c470-c044-4512-9276-71491fe97685" and .app.remote_unattached_valid_build.status == "VALID_UNATTACHED" and .app.remote_unattached_valid_build.asc_processing_state == "VALID" and .app.remote_unattached_valid_build.app_store_version_attachment == "UNATTACHED" and .app.asc_state.current_build == $candidate_build' "Current build 6 review, IAP, and build 4 unattached state are distinct and exact."
assert_jq '.app.primary_category_identifier == "public.app-category.photo-video"' "App category matches Info.plist."
assert_jq '
  .app.current_build.testflight_internal_qa.group_name == "Weekkeep Internal QA"
  and .app.current_build.testflight_internal_qa.group_id == "576fd29a-7a64-4521-9164-9697ec1c256f"
  and .app.current_build.testflight_internal_qa.group_builds == ["6"]
  and .app.current_build.testflight_internal_qa.group_build_count == 1
  and .app.current_build.testflight_internal_qa.build_status == "READY_FOR_BETA_TESTING"
  and .app.current_build.testflight_internal_qa.tester_count == 1
  and .app.current_build.testflight_internal_qa.public_ssot_contains_tester_email == false
  and ((.app.current_build.testflight_internal_qa.testers | length) == 1)
  and ((.app.current_build.testflight_internal_qa.testers[0] | has("email")) | not)
  and .app.current_build.testflight_internal_qa.testers[0].role == "account_holder"
  and .app.current_build.testflight_internal_qa.testers[0].tester_id == "bef018ab-9514-4388-804d-bcd363f601d4"
  and .app.current_build.testflight_internal_qa.testers[0].state == "INVITED"
  and .app.current_build.testflight_internal_qa.testers[0].account_holder_verified == true
  and .app.current_build.testflight_internal_qa.distribution_status == "ready_invited"
  and .app.current_build.testflight_internal_qa.installed == false
  and .app.current_build.testflight_internal_qa.purchase_tested == false
  and .app.current_build.testflight_internal_qa.restore_tested == false
' "TestFlight internal QA distribution is ready/invited only and exact, with tester email omitted from public SSOT."
assert_jq '.iap.product_id == "weekkeep_plus_lifetime" and .iap.entitlement_id == "plus" and .iap.offering_id == "default" and .iap.type == "non-consumable" and .iap.us_base_price_usd == 19.99' "RevenueCat/App Store IAP identifiers and US price match."
assert_jq '.screenshots.shipaton_proof.width == 1179 and .screenshots.shipaton_proof.height == 2556 and .screenshots.shipaton_proof.alpha == false and .screenshots.shipaton_proof.device_frame == false' "Shipaton screenshot contract is explicit."
assert_jq '.screenshots.app_store.evidence_build == "5" and .screenshots.app_store.evidence_directory == $candidate_screenshot_directory and .screenshots.app_store.evidence_scope == "historical_local_build5_candidate_not_target" and .screenshots.app_store.current_build_visual_qa_directory == $candidate_visual_qa_directory and .screenshots.app_store.current_build_visual_qa_scope == "current_build6_settings_visual_qa_not_app_store_screenshot_evidence" and .screenshots.app_store.asc_screenshot_replacement_verified == false and .screenshots.app_store.remote_review_evidence_scope == "historical_build3_evidence_replaced_by_build6_review_submission"' "Historical build-5/build-3 screenshot evidence remains separate from current build-6 visual QA."
assert_privacy_jq '.target.app_id == "6798449478" and .target.build == "6" and .target.asc_build_id == "0ffa7586-619f-4df9-abc5-ae7ebbd068b1" and .target.app_store_version_id == "ac4f183e-1019-4ffc-827f-f5514f0d349b" and .target.review_submission_id == "a9b0a18f-6cf6-4af4-8e6f-c77009831e00" and .target.review_submission_state == "WAITING_FOR_REVIEW" and .target.review_submission_submitted_at == "2026-08-06T22:44:38.573Z" and .target.review_submission_item_count == 2 and .target.review_submission_item_state == "READY_FOR_REVIEW" and .target.iap_id == "6798491084" and .target.iap_product_id == "weekkeep_plus_lifetime" and .target.iap_version_id == "cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f" and .target.iap_version_state == "WAITING_FOR_REVIEW" and .target.app_privacy_publish_state == "PUBLISHED_CURRENT_APP_VERSION" and .target.app_privacy_scope == "current_app_version_1.0.0" and .target.ipa_evidence == null and .target.ipa_evidence_status == "verified_local_without_tracked_evidence_file" and .target.ipa_local_verification.size_bytes == 23338085 and .target.ipa_local_verification.sha256 == "feccbf6e94b4b848d119eb242994f9626106595b79d6e8acc0d8d8e2dc55f06a" and .target.ipa_local_verification.bundle_id == "com.solkim.weekkeep" and .target.ipa_local_verification.version == "1.0.0" and .target.ipa_local_verification.build == "6" and .target.ipa_local_verification.purchases == true and .target.ipa_local_verification.analytics == false and .target.ipa_local_verification.privacy_info_present == true and .target.ipa_local_verification.signing_identity == "Apple Distribution sol kim" and .target.ipa_local_verification.team_id == "D48DDX5D5W" and .remote_unattached_valid_build.build == "4" and .remote_unattached_valid_build.asc_build_id == "6e92c470-c044-4512-9276-71491fe97685" and .remote_unattached_valid_build.processing_state == "VALID" and .remote_unattached_valid_build.app_store_version_attachment == "UNATTACHED" and .historical_build_3.build == "3" and .historical_build_3.review_submission_state == "CANCELED_REPLACED" and .historical_local_candidate_build_5.build == "5"' "Privacy manifest scopes publication to the current app version and keeps build-6 PrivacyInfo evidence separate."
assert_jq '.locales | keys == ["en-US", "ko"]' "English and Korean metadata locales are present."
assert_jq '(.review.notes_en | contains("Keep the last 7 days")) and (.review.notes_en | contains("Replace this photo")) and (.review.notes_en | contains("Learn about Weekkeep Plus"))' "App Review notes use shipped action labels."

assert_shipaton_jq '(.schema_version == 2) and (.intake_filter.schema_version == 2) and ((.intake_filter.gates | keys | sort) == ["app_icon", "bundle_package_identifier", "judge_unlock", "public_demo_video", "public_source_repository", "published_store_page_url", "required_fields_and_category_answers", "screenshot", "target_device_footage"])' "Shipaton manifest schema and intake gate names are present."
assert_shipaton_jq '.current_release_build.app_id == "6798449478" and .current_release_build.bundle_id == "com.solkim.weekkeep" and .current_release_build.build == $candidate_build and .current_release_build.release_method == "manual" and .current_release_build.upload_state == "uploaded" and .current_release_build.asc_build_id == "0ffa7586-619f-4df9-abc5-ae7ebbd068b1" and .current_release_build.asc_processing_state == "VALID" and .current_release_build.uploaded_at == "2026-08-06T15:31:16-07:00" and .current_release_build.app_store_version_attachment == "ATTACHED" and .current_release_build.app_store_version_id == "ac4f183e-1019-4ffc-827f-f5514f0d349b" and .current_release_build.asc_review_submission_id == "a9b0a18f-6cf6-4af4-8e6f-c77009831e00" and .current_release_build.asc_review_submission_state == "WAITING_FOR_REVIEW" and .current_release_build.asc_review_submission_submitted_at == "2026-08-06T22:44:38.573Z" and .current_release_build.asc_review_submission_item_count == 2 and (.current_release_build.asc_review_submission_item_details | all(.[]; .state == "READY_FOR_REVIEW")) and .current_release_build.ipa_local_verification.size_bytes == 23338085 and .current_release_build.ipa_local_verification.sha256 == "feccbf6e94b4b848d119eb242994f9626106595b79d6e8acc0d8d8e2dc55f06a" and .current_release_build.ipa_local_verification.bundle_id == "com.solkim.weekkeep" and .current_release_build.ipa_local_verification.version == "1.0.0" and .current_release_build.ipa_local_verification.build == "6" and .current_release_build.ipa_local_verification.purchases == true and .current_release_build.ipa_local_verification.analytics == false and .current_release_build.ipa_local_verification.privacy_info_present == true and .current_release_build.ipa_local_verification.signing_identity == "Apple Distribution sol kim" and .current_release_build.ipa_local_verification.team_id == "D48DDX5D5W" and .current_release_build.app_store_screenshot_evidence_scope == "historical_local_build5_candidate_not_target" and .current_release_build.visual_qa_evidence == $candidate_visual_qa_directory and .current_release_build.visual_qa_evidence_scope == "current_build6_settings_visual_qa_not_app_store_screenshot_evidence" and .remote_review_build_3.build == "3" and .remote_review_build_3.asc_processing_state == "VALID" and .remote_review_build_3.app_store_version_attachment == "HISTORICAL_REPLACED_BY_BUILD_6" and .remote_review_build_3.review_submission_state == "CANCELED_REPLACED" and .remote_unattached_valid_build_4.build == "4" and .remote_unattached_valid_build_4.asc_build_id == "6e92c470-c044-4512-9276-71491fe97685" and .remote_unattached_valid_build_4.asc_processing_state == "VALID" and .remote_unattached_valid_build_4.app_store_version_attachment == "UNATTACHED"' "Shipaton manifest records the current build-6 review state and preserves build-3/build-4 history."
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
  and ([(.intake_filter.gates | to_entries[] | select(.key != "public_source_repository") | .value.status)] | all(. == "pending_external"))
  and .intake_filter.gates.bundle_package_identifier.revenuecat_sdk_verification_status == "pending_external"
  and .intake_filter.gates.judge_unlock.offer.external_offer_status == "pending_external"
  and .release_eligibility.first_public_release.status == "pending_external"
  and .release_eligibility.published_eligible_store.status == "pending_external"
  and .release_eligibility.downloadable_in_us.status == "pending_external"
  and .release_eligibility.revenuecat_qualifying_path.status == "pending_external"
' "Root, overall, and all non-public-source intake/release gates remain pending."
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
assert_shipaton_jq '(.intake_filter.gates.public_demo_video.status == "pending_external") and (.intake_filter.gates.public_demo_video.public_url == null) and (.intake_filter.gates.public_demo_video.backup_release_url == "https://github.com/kimsol1134/weekkeep/releases/tag/shipaton-demo-v1") and (.intake_filter.gates.public_demo_video.backup_asset_url == "https://github.com/kimsol1134/weekkeep/releases/download/shipaton-demo-v1/weekkeep-shipaton-72.mp4") and (.intake_filter.gates.public_demo_video.backup_release_http_status == 200) and (.intake_filter.gates.public_demo_video.backup_asset_http_status == 200) and (.intake_filter.gates.public_demo_video.backup_asset_sha256 == "9d4afb5332d3bbaeb0fc40e5d1d71c6a66b7cf2d72b79ed8a7ab3c2864e5a01a") and (.intake_filter.gates.public_demo_video.official_platform_gate == "pending_external_youtube_or_vimeo_logged_out_playback")' "GitHub Release video backup is recorded separately from the pending official YouTube/Vimeo gate."
assert_shipaton_jq '(.intake_filter.gates.target_device_footage.required == true) and (.intake_filter.gates.target_device_footage.target_device == "iPhone") and (.intake_filter.gates.target_device_footage.must_show_functioning_project == true)' "Target-device functioning footage is an explicit pending gate."
assert_shipaton_jq '(.provenance.source_media_project == "videos/weekkeep-shipaton") and (.provenance.validation_script == "videos/weekkeep-shipaton/scripts/validate-provenance.sh") and (.demo.source_project == "videos/weekkeep-remotion") and ((.demo.preview_approval_status == "pending_external" and .demo.render_status == "composition_validated_final_mp4_not_rendered_preview_approval_pending") or (.demo.preview_approval_status == "Validated" and .demo.render_status == "rendered_after_user_preview_approval"))' "Video provenance origin, canonical Remotion source, and approval/render lifecycle are distinct."
assert_shipaton_jq '(.demo.validation.check == "passed") and (.demo.validation.composition_listing == "passed") and (.demo.validation.composition_id == "WeekkeepShipaton72") and (.demo.validation.width == 1920) and (.demo.validation.height == 1080) and (.demo.validation.fps == 30) and (.demo.validation.duration_in_frames == 2160) and (.demo.validation.duration_seconds == 72) and (.demo.validation.scene_count == 10) and (.demo.validation.transition_count == 9) and (.demo.validation.transition_style == "restrained_fade") and (.demo.validation.transition_duration_frames == 12) and (.demo.validation.caption_group_count == 23) and (.demo.validation.caption_source == "videos/weekkeep-remotion/src/data/audio_meta.json") and (.demo.validation.caption_groups_source == "videos/weekkeep-remotion/src/data/caption_groups.json") and (.demo.validation.caption_derivation == "derived_from_approved_audio_meta") and ((.demo.preview_approval_status == "pending_external" and .demo.validation.final_mp4 == "not_present_preview_approval_pending") or (.demo.preview_approval_status == "Validated" and .demo.validation.final_mp4 == "present_after_user_preview_approval"))' "Remotion composition validation preserves canonical facts and keeps final MP4 gated by preview approval."
assert_shipaton_jq '((.demo.preview_approval_status == "pending_external" and .external_evidence.final_video_approval_and_render == "pending_user_preview_approval") or (.demo.preview_approval_status == "Validated" and (.external_evidence.final_video_approval_and_render | startswith("validated_")))) and ((.intake_filter.gates.public_demo_video.status == "pending_external") or (.intake_filter.gates.public_demo_video.status == "Validated" and .demo.preview_approval_status == "Validated"))' "Final video approval/render and public demo publication have a future-valid lifecycle without weakening the current pending state."
assert_shipaton_jq '(.intake_filter.gates.app_icon.required == true) and (.intake_filter.gates.app_icon.width == 1024) and (.intake_filter.gates.app_icon.height == 1024) and (.intake_filter.gates.app_icon.alpha == false)' "Shipaton icon intake gate preserves the 1024x1024 opaque contract."
assert_shipaton_jq '(.intake_filter.gates.screenshot.required == true) and (.intake_filter.gates.screenshot.minimum_count >= 1) and (.intake_filter.gates.screenshot.width == 1179) and (.intake_filter.gates.screenshot.height == 2556) and (.intake_filter.gates.screenshot.alpha == false) and (.intake_filter.gates.screenshot.device_frame == false)' "Shipaton screenshot intake gate preserves the 1179x2556 no-frame contract."
assert_shipaton_jq '(.intake_filter.gates.judge_unlock.required == true) and (.intake_filter.gates.judge_unlock.audience == ["Sponsor", "Admin", "Judges"]) and (.intake_filter.gates.judge_unlock.free_and_unrestricted == true) and (.intake_filter.gates.judge_unlock.unlocks_all_premium_features == true) and (.intake_filter.gates.judge_unlock.valid_through == .official_rules.testing_access.valid_through) and (.official_rules.testing_access.offer_expiry_must_be_after == .intake_filter.gates.judge_unlock.valid_through) and (.intake_filter.gates.judge_unlock.offer.mechanism == "Offer Code") and (.intake_filter.gates.judge_unlock.offer.devpost_label == "promo code") and (.intake_filter.gates.judge_unlock.offer.product_id == "weekkeep_plus_lifetime") and (.intake_filter.gates.judge_unlock.offer.product_type == "non-consumable") and (.intake_filter.gates.judge_unlock.offer.price == "free") and (.intake_filter.gates.judge_unlock.offer.eligibility == "everyone") and (.intake_filter.gates.judge_unlock.offer.territories == ["US"]) and (.intake_filter.gates.judge_unlock.offer.real_code_stored_in_manifest == false) and (.intake_filter.gates.judge_unlock.offer.code_storage == "external_uncommitted") and ((.intake_filter.gates.judge_unlock.status == "pending_external" and .intake_filter.gates.judge_unlock.offer.external_offer_status == "pending_external") or (.intake_filter.gates.judge_unlock.status == "Validated" and .intake_filter.gates.judge_unlock.offer.external_offer_status == "Validated"))' "Judge access encodes the free IAP Offer Code plan, audience, US eligibility, and no-code-in-Git rule."
assert_shipaton_jq '(.intake_filter.gates.judge_unlock.offer.remote_configuration.status == "configured") and (.intake_filter.gates.judge_unlock.offer.remote_configuration.app_id == "6798449478") and (.intake_filter.gates.judge_unlock.offer.remote_configuration.iap_id == "6798491084") and (.intake_filter.gates.judge_unlock.offer.remote_configuration.offer_id == "bb4f7fd6-2b08-4aa7-9f55-e140a3e94e28") and (.intake_filter.gates.judge_unlock.offer.remote_configuration.free_prices == ["USA:FREE", "KOR:FREE"]) and (.intake_filter.gates.judge_unlock.offer.production_judge_code.generated == false) and (.intake_filter.gates.judge_unlock.offer.production_judge_code.attempted_custom_code == "WEEKKEEPJUDGES") and (.intake_filter.gates.judge_unlock.offer.production_judge_code.attempt_status == "rejected_parent_iap_not_approved") and (.intake_filter.gates.judge_unlock.offer.production_judge_code.production_code_created == false) and (.intake_filter.gates.judge_unlock.offer.production_judge_code.status == "blocked_until_app_ready_for_distribution_and_iap_approved")' "Judge offer configuration, rejected production custom-code attempt, and production-code block are exact."
assert_shipaton_jq '(.intake_filter.prescreening.submission_is_read == true) and (.intake_filter.prescreening.first_two_minutes.required == true) and (.intake_filter.prescreening.first_two_minutes.required_messages == ["elevator_pitch", "app_in_use", "targeted_categories"]) and (.intake_filter.prescreening.source == "https://www.shipaton.com/blog/how-we-judge-shipaton")' "Prescreening first-two-minute messages and official source are explicit."
assert_shipaton_jq '((.category_decisions | length) == 21) and (([.category_decisions[] | .category] | sort) == ["#BuildInPublic", "Best App for Galaxy / Samsung", "Best Game", "Career Coaching / Leadership Heather", "Catvertising", "Conflict of Interest", "Funnel Vision / Stripe", "Gaming / Mr Lewis Blogs Gaming", "Grand Prize", "Growth Loop / Layers", "HAMM Award (Help Apps Make Money)", "Idea to Income / Replit", "Keep Them Coming Back / OneSignal", "Most Viral App / Noise", "Next Gen", "Nutrition & Healthy Eating / Abbey’s Kitchen", "Productivity / Christopher Lawley", "RevenueCat Design Award", "RevenueCat Peace Prize", "Ship Kotlin Everywhere / JetBrains", "Yoga & Fitness / Simone Sharice"]) and (([.category_decisions[] | .decision] | unique | sort) == ["Conditional", "Exclude", "Focus"]) and (([.category_decisions[] | select(.decision == "Focus") | .category] | sort) == ["#BuildInPublic", "HAMM Award (Help Apps Make Money)", "RevenueCat Design Award"]) and (([.category_decisions[] | select(.decision == "Conditional") | .category] | sort) == ["Grand Prize", "Most Viral App / Noise", "RevenueCat Peace Prize"])' "All 21 official categories have MECE Focus, Conditional, or Exclude decisions."

assert_shipaton_jq '
  .current_release_build.testflight_internal_qa.group_name == "Weekkeep Internal QA"
  and .current_release_build.testflight_internal_qa.group_id == "576fd29a-7a64-4521-9164-9697ec1c256f"
  and .current_release_build.testflight_internal_qa.group_builds == ["6"]
  and .current_release_build.testflight_internal_qa.group_build_count == 1
  and .current_release_build.testflight_internal_qa.build_status == "READY_FOR_BETA_TESTING"
  and .current_release_build.testflight_internal_qa.tester_count == 1
  and .current_release_build.testflight_internal_qa.public_ssot_contains_tester_email == false
  and ((.current_release_build.testflight_internal_qa.testers | length) == 1)
  and ((.current_release_build.testflight_internal_qa.testers[0] | has("email")) | not)
  and .current_release_build.testflight_internal_qa.testers[0].role == "account_holder"
  and .current_release_build.testflight_internal_qa.testers[0].tester_id == "bef018ab-9514-4388-804d-bcd363f601d4"
  and .current_release_build.testflight_internal_qa.testers[0].state == "INVITED"
  and .current_release_build.testflight_internal_qa.testers[0].account_holder_verified == true
  and .current_release_build.testflight_internal_qa.distribution_status == "ready_invited"
  and .current_release_build.testflight_internal_qa.installed == false
  and .current_release_build.testflight_internal_qa.purchase_tested == false
  and .current_release_build.testflight_internal_qa.restore_tested == false
' "Shipaton manifest records exact TestFlight internal QA ready/invited state without install or purchase claims, with tester email omitted from public SSOT."
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

if rg -n "Choose my week" docs release Weekkeep/Resources >/dev/null; then
  fail "release copy contains a stale onboarding action name"
else
  pass "App Review and Shipaton copy use the shipped onboarding action."
fi
if jq -e '.strings["onboarding.primary"].localizations.en.stringUnit.value == "Keep the last 7 days"' Weekkeep/Resources/Localizable.xcstrings >/dev/null; then
  pass "English onboarding action matches the review notes."
else
  fail "English onboarding action is missing or drifted"
fi
if [[ -x scripts/capture-fixture-screenshots.sh ]] && rg -n 'testCaptureDeterministicFixtureMilestonesWhenRequested' WeekkeepUITests/WeekkeepUITests.swift >/dev/null; then
  pass "Deterministic fixture screenshot capture is wired to XCTest attachments."
else
  fail "Deterministic fixture screenshot capture path is incomplete"
fi
if [[ -x scripts/validate-submission-screenshots.sh ]] \
  && rg -q '01-welcome' scripts/validate-submission-screenshots.sh \
  && rg -q '02-review' scripts/validate-submission-screenshots.sh \
  && rg -q '03-review-selected' scripts/validate-submission-screenshots.sh \
  && rg -q '04-save-confirmation' scripts/validate-submission-screenshots.sh; then
  pass "Submission screenshot validator enforces the four canonical milestones."
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
if git ls-files --error-unmatch Config/Secrets.xcconfig >/dev/null 2>&1; then
  fail "Config/Secrets.xcconfig must never be tracked"
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

if [[ -f Config/Secrets.xcconfig ]]; then
  warn "Config/Secrets.xcconfig exists; its contents were intentionally not inspected, so the RevenueCat key gate remains external."
else
  warn "RevenueCat public key is not present; purchase smoke test and App Store release remain externally blocked."
fi

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
