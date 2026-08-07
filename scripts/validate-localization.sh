#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
catalog="$project_root/Weekkeep/Resources/Localizable.xcstrings"
legacy_en="$project_root/Weekkeep/Resources/en.lproj/Localizable.strings"
legacy_ko="$project_root/Weekkeep/Resources/ko.lproj/Localizable.strings"
failures=0

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

pass() {
  echo "PASS: $1"
}

for command_name in jq rg xcrun comm; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    fail "required command is missing: $command_name"
  fi
done

if [[ ! -f "$catalog" ]]; then
  fail "String Catalog is missing: ${catalog#$project_root/}"
fi

if [[ -e "$legacy_en" || -e "$legacy_ko" ]]; then
  fail "legacy Localizable.strings files must not coexist with the String Catalog"
else
  pass "legacy Localizable.strings SSOT is absent."
fi

catalog_count="$(rg --files "$project_root/Weekkeep/Resources" -g 'Localizable.xcstrings' | wc -l | tr -d ' ')"
if [[ "$catalog_count" == "1" ]]; then
  pass "Weekkeep has exactly one Localizable.xcstrings source."
else
  fail "expected exactly one Weekkeep/Resources/Localizable.xcstrings; found $catalog_count"
fi

if (( failures > 0 )); then
  exit 1
fi

catalog_user_values="$(jq -r '
  def strings:
    if type == "object" then [to_entries[] | .value | strings] | add
    elif type == "array" then map(strings) | add
    elif type == "string" then [.] else [] end;
  [.strings[] | .localizations | strings] | add[]
' "$catalog")"

if printf '%s\n' "$catalog_user_values" | rg -n -i 'draft|초안' >/dev/null; then
  fail "user-visible String Catalog values contain draft/초안 jargon"
else
  pass "recursive String Catalog values contain no user-visible draft/초안 jargon."
fi

if printf '%s\n' "$catalog_user_values" | rg -n -i \
  -e 'photos? (stay|remain) on (this|your) (iphone|device)' \
  -e 'photos? (never )?leave (the )?(device|iphone)' \
  -e '사진은 .*iPhone을 떠나' \
  -e '사진.*기기를 떠나' \
  -e '사진.*기기 밖' \
  -e '사진.*밖으로 (나가|보내)' \
  -e '사진은 .*iPhone 안에서만' \
  -e '이 iPhone에서만 분석' \
  -e '사진 정보.*밖으로' >/dev/null; then
  fail "user-visible String Catalog values contain a disallowed absolute photo-privacy phrase"
else
  pass "recursive String Catalog values contain no disallowed absolute photo-privacy phrase."
fi

if jq -e '
  .sourceLanguage == "en" and
  .version == "1.0" and
  (.strings | type == "object") and
  all(.strings[];
    .localizations as $localizations |
    (($localizations | keys | sort) == ["en", "ko"]) and
    all(["en", "ko"][];
      . as $locale |
      (($localizations[$locale].stringUnit.value? | type) == "string") or
      (($localizations[$locale].variations.plural? | type) == "object")
    )
  )
' "$catalog" >/dev/null; then
  pass "catalog has sourceLanguage en and complete en/ko localization records."
else
  fail "catalog is missing sourceLanguage en, en/ko localization, or a localized value"
fi

if jq -e '(.strings | has("CFBundleDisplayName") or has("NSPhotoLibraryUsageDescription")) | not' "$catalog" >/dev/null; then
  if [[ -f "$project_root/Weekkeep/Resources/en.lproj/InfoPlist.strings" && -f "$project_root/Weekkeep/Resources/ko.lproj/InfoPlist.strings" ]]; then
    pass "InfoPlist localization remains separate from Localizable.xcstrings."
  else
    fail "InfoPlist.strings localization files are missing"
  fi
else
  fail "InfoPlist keys must not be moved into the app Localizable.xcstrings"
fi

required_plural_keys=(
  week.photoCount
  review.body
  review.bodyCount
  review.keep
  save.metadata
  archive.photoCount
  detail.savedOnDevice
  paywall.overlineCount
)

for key in "${required_plural_keys[@]}"; do
  if jq -e --arg key "$key" '
    .strings[$key].localizations as $localizations |
    ($localizations.en.variations.plural // $localizations.en.substitutions.total.variations.plural) as $enPlural |
    ($localizations.ko.variations.plural // $localizations.ko.substitutions.total.variations.plural) as $koPlural |
    (["one", "other"] | sort) == ($enPlural | keys | sort) and
    (["one", "other"] | sort) == ($koPlural | keys | sort) and
    all(["en", "ko"][];
      . as $locale |
      all(["one", "other"][];
        . as $form |
        ((($localizations[$locale].variations.plural // $localizations[$locale].substitutions.total.variations.plural)[$form].stringUnit.value | type) == "string")
      )
    )
  ' "$catalog" >/dev/null; then
    pass "$key has deterministic one/other plural variants in en and ko."
  else
    fail "$key is missing a complete one/other plural definition in en or ko"
  fi
done

if jq -e '
  .strings["review.bodyCount"].localizations.en.stringUnit.value == "%2$lld / %#@total@" and
  .strings["review.bodyCount"].localizations.ko.stringUnit.value == "사진 %2$lld / %#@total@" and
  .strings["review.bodyCount"].localizations.en.substitutions.total.argNum == 1 and
  .strings["review.bodyCount"].localizations.ko.substitutions.total.argNum == 1 and
  .strings["review.bodyCount"].localizations.en.substitutions.total.formatSpecifier == "lld" and
  .strings["review.bodyCount"].localizations.ko.substitutions.total.formatSpecifier == "lld"
' "$catalog" >/dev/null; then
  pass "progress count uses an explicit typed total substitution."
else
  fail "progress count substitution or format argument order is malformed"
fi

if jq -e '
  .strings["review.photoLabel"].localizations.en.stringUnit.value == "Photo %2$lld of %1$lld" and
  .strings["review.photoLabel"].localizations.ko.stringUnit.value == "%1$lld장 중 %2$lld번째 사진" and
  .strings["viewer.position"].localizations.en.stringUnit.value == "%1$lld of %2$lld" and
  .strings["viewer.position"].localizations.ko.stringUnit.value == "%2$lld장 중 %1$lld번째" and
  .strings["accessibility.photo"].localizations.en.stringUnit.value == "Photo %2$lld of %1$lld" and
  .strings["accessibility.photo"].localizations.ko.stringUnit.value == "%1$lld장 중 %2$lld번째 사진"
' "$catalog" >/dev/null; then
  pass "viewer and accessibility format arguments use explicit numeric positions."
else
  fail "viewer/accessibility format argument order is malformed"
fi

for key in "${required_plural_keys[@]}"; do
  if jq -e --arg key "$key" '
    .strings[$key].localizations as $localizations |
    (if $key == "review.bodyCount" then
       [$localizations.en.substitutions.total.variations.plural.one.stringUnit.value,
        $localizations.en.substitutions.total.variations.plural.other.stringUnit.value,
        $localizations.ko.substitutions.total.variations.plural.one.stringUnit.value,
        $localizations.ko.substitutions.total.variations.plural.other.stringUnit.value]
     else
       [$localizations.en.variations.plural.one.stringUnit.value,
        $localizations.en.variations.plural.other.stringUnit.value,
        $localizations.ko.variations.plural.one.stringUnit.value,
        $localizations.ko.variations.plural.other.stringUnit.value]
     end)
    | all(.[]; (test("%lld") and (test("%@") | not)))
  ' "$catalog" >/dev/null; then
    pass "$key keeps numeric count placeholders typed as lld."
  else
    fail "$key contains a string placeholder or missing numeric count placeholder"
  fi
done

extract_root="$(mktemp -d -t weekkeep-localization-extract.XXXXXX)"
compile_root="$(mktemp -d -t weekkeep-localization-compile.XXXXXX)"
trap 'rm -rf "$extract_root" "$compile_root"' EXIT

if xcrun xcstringstool compile "$catalog" \
  --output-directory "$compile_root" \
  --format stringsAndStringsdict \
  --serialization-format text >/dev/null; then
  pass "xcstringstool compiled Localizable.xcstrings."
else
  fail "xcstringstool could not compile Localizable.xcstrings"
fi

if xcrun xcstringstool print "$catalog" >/dev/null; then
  pass "xcstringstool printed the catalog key index."
else
  fail "xcstringstool could not print Localizable.xcstrings"
fi

swift_sources=()
while IFS= read -r -d '' source_file; do
  swift_sources+=("$source_file")
done < <(rg --files --null --sort path -g '*.swift' "$project_root/Weekkeep")

if (( ${#swift_sources[@]} == 0 )); then
  fail "no Swift source files found under Weekkeep"
else
  if xcrun xcstringstool extract "${swift_sources[@]}" \
    --output-directory "$extract_root" \
    --output-format xcstrings \
    --SwiftUI \
    --modern-localizable-strings \
    -s string >/dev/null; then
    extracted_catalog="$extract_root/Localizable.xcstrings"
    if [[ -f "$extracted_catalog" ]]; then
      missing_keys="$(comm -23 \
        <(jq -r '.strings | keys[]' "$extracted_catalog" | sort -u) \
        <(jq -r '.strings | keys[]' "$catalog" | sort -u))"
      if [[ -z "$missing_keys" ]]; then
        pass "all extracted localized call-site keys exist in the catalog."
      else
        fail "localized call sites are missing from the catalog: $missing_keys"
      fi
    else
      fail "xcstringstool did not produce an extraction catalog"
    fi
  else
    fail "xcstringstool could not extract localized call sites"
  fi
fi

if (( failures > 0 )); then
  exit 1
fi

pass "localization validation completed."
