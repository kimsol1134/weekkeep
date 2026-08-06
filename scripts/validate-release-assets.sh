#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
icon="$project_root/Weekkeep/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
master_png="$project_root/design/app-icon/weekkeep-app-icon-master.png"
master_svg="$project_root/design/app-icon/weekkeep-app-icon-master.svg"
tab_icon_root="$project_root/Weekkeep/Resources/Assets.xcassets"
tab_icon_view="$project_root/Weekkeep/DesignSystem/Components/WeekkeepTabIcon.swift"
onboarding_view="$project_root/Weekkeep/Features/Onboarding/OnboardingView.swift"
photo_story_view="$project_root/Weekkeep/DesignSystem/Components/PhotoStoryMosaic.swift"
ready_view="$project_root/Weekkeep/Features/WeeklyCuration/WeeklyViews.swift"
paywall_view="$project_root/Weekkeep/Features/Paywall/PlusPaywallView.swift"
site_page="$project_root/site/app/page.tsx"
site_styles="$project_root/site/app/globals.css"
seven_stitch_rail="$project_root/Weekkeep/DesignSystem/Components/SevenStitchRail.swift"
remotion_tokens="$project_root/videos/weekkeep-remotion/src/tokens.ts"
remotion_rail="$project_root/videos/weekkeep-remotion/src/components/SevenStitchRail.tsx"
tab_icon_names=("ThisWeekTabIcon" "WeeksTabIcon" "SettingsTabIcon")
tab_icon_semantics=("semantic-calendar" "semantic-album-stack" "semantic-sliders")
tab_icon_semantic_rect_counts=(1 4 3)

if [[ "${#tab_icon_names[@]}" != "3" ]] || [[ "$(printf '%s\n' "${tab_icon_names[@]}" | sort -u | wc -l | tr -d ' ')" != "3" ]]; then
  echo "FAIL: semantic tab icon asset names must be three unique names."
  exit 1
fi

for required_file in "$icon" "$master_png" "$master_svg" "$tab_icon_view" "$onboarding_view" "$photo_story_view" "$ready_view" "$paywall_view" "$site_page" "$site_styles" "$seven_stitch_rail" "$remotion_tokens" "$remotion_rail"; do
  if [[ ! -f "$required_file" ]]; then
    echo "FAIL: required release asset is missing: $required_file"
    exit 1
  fi
done

width="$(sips -g pixelWidth "$icon" | awk '/pixelWidth/ { print $2 }')"
height="$(sips -g pixelHeight "$icon" | awk '/pixelHeight/ { print $2 }')"
has_alpha="$(sips -g hasAlpha "$icon" | awk '/hasAlpha/ { print $2 }')"
profile="$(sips -g profile "$icon" | awk -F': ' '/profile/ { print $2 }')"

if [[ "$width" != "1024" || "$height" != "1024" ]]; then
  echo "FAIL: AppIcon.png must be 1024x1024; found ${width}x${height}."
  exit 1
fi

if [[ "$has_alpha" != "no" ]]; then
  echo "FAIL: AppIcon.png must be opaque with no alpha channel; found hasAlpha=${has_alpha}."
  exit 1
fi

if [[ "$profile" != sRGB* ]]; then
  echo "FAIL: AppIcon.png must embed an sRGB profile; found profile=${profile:-none}."
  exit 1
fi

if ! cmp -s "$master_png" "$icon"; then
  echo "FAIL: Xcode AppIcon.png is not byte-identical to the canonical PNG master."
  exit 1
fi

view_box="$(xmllint --xpath "string(/*[local-name()='svg']/@viewBox)" "$master_svg")"
background="$(xmllint --xpath "string((/*[local-name()='svg']/*[local-name()='rect'])[1]/@fill)" "$master_svg")"
background_rx="$(xmllint --xpath "string((/*[local-name()='svg']/*[local-name()='rect'])[1]/@rx)" "$master_svg")"

if [[ "$view_box" != "0 0 1024 1024" || "$background" != "#FBF7F2" || -n "$background_rx" ]]; then
  echo "FAIL: SVG master must be a full-bleed 1024 Cream canvas without pre-rounded corners."
  exit 1
fi

stitch_count="$(xmllint --xpath "count(//*[local-name()='g' and @id='seven-stitches']/*[local-name()='rect'])" "$master_svg")"
if [[ "$stitch_count" != "7" ]]; then
  echo "FAIL: SVG master must contain exactly seven decorative stitches; found ${stitch_count}."
  exit 1
fi

expected_colors=("#E97A68" "#E39455" "#E5A84B" "#66836E" "#5F879B" "#686286" "#8A6386")
expected_x=("183" "281" "379" "477" "575" "673" "771")

for icon_index in "${!tab_icon_names[@]}"; do
  icon_name="${tab_icon_names[$icon_index]}"
  tab_icon_contents="$tab_icon_root/${icon_name}.imageset/Contents.json"
  tab_icon_svg="$tab_icon_root/${icon_name}.imageset/${icon_name}.svg"
  semantic_id="${tab_icon_semantics[$icon_index]}"
  expected_semantic_rects="${tab_icon_semantic_rect_counts[$icon_index]}"

  if [[ ! -f "$tab_icon_contents" || ! -f "$tab_icon_svg" ]]; then
    echo "FAIL: required semantic tab icon asset is missing: ${icon_name}."
    exit 1
  fi

  asset_filename="$(jq -r '.images[0].filename // empty' "$tab_icon_contents")"
  if [[ "$asset_filename" != "${icon_name}.svg" ]]; then
    echo "FAIL: ${icon_name} Contents.json points to an unexpected vector filename: ${asset_filename}."
    exit 1
  fi

  tab_rendering_intent="$(jq -r '.properties["template-rendering-intent"] // empty' "$tab_icon_contents")"
  if [[ "$tab_rendering_intent" != "original" ]] || ! rg -q '\.renderingMode\(\.original\)' "$tab_icon_view"; then
    echo "FAIL: ${icon_name} must use original rendering so iOS preserves its semantic glyph."
    exit 1
  fi

  tab_view_box="$(xmllint --xpath "string(/*[local-name()='svg']/@viewBox)" "$tab_icon_svg")"
  tab_stitch_count="$(xmllint --xpath "count(//*[local-name()='g' and @id='seven-stitches']/*[local-name()='rect'])" "$tab_icon_svg")"
  semantic_group_count="$(xmllint --xpath "count(//*[local-name()='g' and @id='${semantic_id}'])" "$tab_icon_svg")"
  semantic_rect_count="$(xmllint --xpath "count(//*[local-name()='g' and @id='${semantic_id}']/*[local-name()='rect'])" "$tab_icon_svg")"
  semantic_plum_count="$(xmllint --xpath "count(//*[local-name()='g' and @id='${semantic_id}']//*[contains(@fill, '#5B415E') or contains(@stroke, '#5B415E')])" "$tab_icon_svg")"
  if [[ "$tab_view_box" != "0 0 28 24" || "$tab_stitch_count" != "0" || "$semantic_group_count" != "1" || "$semantic_rect_count" != "$expected_semantic_rects" || "$semantic_plum_count" == "0" ]]; then
    echo "FAIL: ${icon_name} must have only its unique plum semantic silhouette and no decorative stitches; found viewBox=${tab_view_box}, stitches=${tab_stitch_count}, semanticRects=${semantic_rect_count}."
    exit 1
  fi
done

if ! rg -q 'ThisWeekTabIcon|WeeksTabIcon|SettingsTabIcon' "$tab_icon_view"; then
  echo "FAIL: WeekkeepTabIcon must reference all three unique tab icon assets."
  exit 1
fi

if rg -q 'KeepsakePageHeader|Capsule\(\)|rotationEffect|SamplePhotoArt' "$onboarding_view" \
  || ! rg -q 'FixturePhotoStory\(style: \.onboarding\)|OnboardingKeepsakePreviewContract\.fixtureIndices' "$onboarding_view"; then
  echo "FAIL: onboarding keepsake preview is not using the shared fixture photo story contract."
  exit 1
fi

if rg -q 'SamplePhotoArt|LinearGradient|Image\(systemName:' "$photo_story_view" \
  || ! rg -q 'SamplePhotoFixtures\.assetNames\.indices|WeeklyPhotoGridLayout\.sevenPhotoGeometry' "$photo_story_view" \
  || ! rg -q 'FixturePhotoStory\(style: \.compact\)' "$ready_view" \
  || ! rg -q 'FixturePhotoStory\(style: \.compact\)' "$paywall_view" \
  || rg -q 'SamplePhotoArt' "$project_root/Weekkeep"; then
  echo "FAIL: production photo-story surfaces still contain placeholder art or are not sharing approved fixtures."
  exit 1
fi

if rg -q 'keepsake-cover|keepsake-visual|keepsake-shadow|keepsake-label' "$site_page" "$site_styles" \
  || ! rg -q 'PhotoStoryMosaic' "$site_page" \
  || ! rg -q 'photo-story-grid|photo-story-tile' "$site_styles"; then
  echo "FAIL: website still contains the legacy abstract keepsake-cover hero."
  exit 1
fi

fixture_count="$(find "$project_root/Weekkeep/Resources/Assets.xcassets" -maxdepth 1 -type d -name 'OnboardingMoment*.imageset' | wc -l | tr -d ' ')"
if [[ "$fixture_count" != "7" ]]; then
  echo "FAIL: onboarding keepsake preview must bundle exactly seven fixture image sets; found ${fixture_count}."
  exit 1
fi

swift_floor="$(sed -n 's/.*minimumVisibleOpacity: Double = \([0-9.]*\).*/\1/p' "$seven_stitch_rail" | head -n 1)"
remotion_floor="$(sed -n 's/.*SEVEN_STITCH_VISIBILITY_FLOOR = \([0-9.]*\).*/\1/p' "$remotion_tokens" | head -n 1)"
remotion_palette="$(sed -n '/stitches: \[/,/  \] as const/p' "$remotion_tokens" | rg -o '#[A-F0-9]{6}' | tr '\n' ',' | sed 's/,$//' || true)"
expected_palette="$(printf '%s\n' "${expected_colors[@]}" | paste -sd ',' -)"
if [[ "$swift_floor" != "0.58" || "$remotion_floor" != "0.58" ]]; then
  echo "FAIL: Swift and Remotion seven-stitch visibility floors must both be 0.58; found ${swift_floor:-missing}/${remotion_floor:-missing}."
  exit 1
fi
if [[ "$remotion_palette" != "$expected_palette" ]] || ! rg -q 'SEVEN_STITCH_COUNT = 7' "$remotion_tokens" || ! rg -q 'Array\.from\(\{ length: SEVEN_STITCH_COUNT \}' "$remotion_rail" || ! rg -q 'opacity: interpolate\(frame, \[0, 12\], \[SEVEN_STITCH_VISIBILITY_FLOOR, targetOpacity\]' "$remotion_rail"; then
  echo "FAIL: Remotion SevenStitchRail must preserve the canonical seven-color order and exact-seven render contract."
  exit 1
fi

for index in {1..7}; do
  xpath="(//*[local-name()='g' and @id='seven-stitches']/*[local-name()='rect'])[${index}]"
  color="$(xmllint --xpath "string(${xpath}/@fill)" "$master_svg")"
  x="$(xmllint --xpath "string(${xpath}/@x)" "$master_svg")"
  y="$(xmllint --xpath "string(${xpath}/@y)" "$master_svg")"
  width="$(xmllint --xpath "string(${xpath}/@width)" "$master_svg")"
  height="$(xmllint --xpath "string(${xpath}/@height)" "$master_svg")"
  radius="$(xmllint --xpath "string(${xpath}/@rx)" "$master_svg")"

  array_index=$((index - 1))
  if [[ "$color" != "${expected_colors[$array_index]}" || "$x" != "${expected_x[$array_index]}" || "$y" != "170" || "$width" != "70" || "$height" != "30" || "$radius" != "15" ]]; then
    echo "FAIL: stitch ${index} does not match the approved color/order/equal-geometry contract."
    exit 1
  fi
done

effect_count="$(xmllint --xpath "count(//*[local-name()='linearGradient' or local-name()='radialGradient' or local-name()='filter'])" "$master_svg")"
if [[ "$effect_count" != "0" ]]; then
  echo "FAIL: SVG master must not contain gradients or filters."
  exit 1
fi

echo "PASS: AppIcon.png is the canonical opaque 1024x1024 sRGB master."
echo "PASS: SVG master has full-bleed Cream, no pre-rounded corner, and exact-seven flat rainbow geometry."
echo "MANUAL: verify the Apple-masked icon on an actual iPhone at 29pt, 40pt, and 60pt."
