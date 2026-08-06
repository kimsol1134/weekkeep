# Weekkeep Requirements Traceability & Consistency

| 항목 | 값 |
|---|---|
| 버전 | 0.5-approved |
| 기준일 | 2026-08-07 |
| 상태 | Approved |
| 구현 | Core implemented and tested / ASC build 6 is uploaded, `VALID`, attached to version `ac4f183e-1019-4ffc-827f-f5514f0d349b`, and in the current Apple review submission; build 4 is `VALID` but unattached; builds 1–5 remain historical/non-target evidence; App Privacy is published for the current 1.0.0 app version and Apple review is `WAITING_FOR_REVIEW`; public source repository verification is `Validated`; approval, public release, and later external gates remain pending |

## 1. 목적

이 문서는 ‘문서를 많이 썼는가’가 아니라 아래 질문에 답합니다.

- 모든 PRD 요구사항에 사용자 흐름이 있는가?
- 모든 핵심 흐름에 화면과 상태가 있는가?
- 모든 요구사항에 구현 책임과 검증 방법이 있는가?
- 서로 다른 문서가 같은 숫자와 약속을 사용하고 있는가?

## 1.1 집중 릴리스 검증 증거 — 2026-08-06

이번 패스는 iOS core loop, launch metadata, weekly route, UI-test fixture, 공식 SDK adapter, privacy manifest, 공개 정책 사이트, 제출 문서까지 하나의 release candidate 기준선으로 검증했다. 이는 App Store 공개 완료를 뜻하지 않는다.

| 범위 | 증거 | 결과 |
|---|---|---|
| XcodeGen SSOT | `xcodegen generate` with XcodeGen 2.46.0 | Pass |
| Launch/build metadata | Debug simulator build 산출물 `Weekkeep.app/Info.plist`: iPhone-only `UIDeviceFamily = [1]`, `UILaunchScreen`, portrait, Light, scene manifest, `weekkeep` URL scheme, base Photos usage key, fonts, category, version, `ITSAppUsesNonExemptEncryption = false` | Pass |
| Signing/release safety | target `TARGETED_DEVICE_FAMILY = 1`; project.yml에 global `CODE_SIGN_IDENTITY = -` 또는 `CODE_SIGNING_ALLOWED = NO` 없음 | Pass |
| Official SDKs | RevenueCat purchases-ios `5.83.0`, PostHog posthog-ios `3.69.0`, exact product/entitlement/offer contract and EU host adapter | Pass |
| Privacy manifests | app 자체 manifest와 built app의 RevenueCat·PostHog·PHPLCrashReporter manifest를 검사하고, 실제 Release collection 차이를 [privacy label SSOT](09-APP-PRIVACY-LABEL.md)에 분리 기록 | Pass |
| Full automated tests | 2026-08-06 `xcodebuild test` on `Weekkeep AppStore 6.9`, result `release/local/regression-20260806T205200KST/Weekkeep.xcresult` — 111 tests discovered, 109 passed, 0 failed, 2 intentional opt-in skips: `AppStoreScreenshotTests/testCaptureBundledFixtureAppStoreScreenshots()` and `RemotionFootageCaptureTests/testCaptureRemotionFootage()` | Pass |
| Weekly UI flow | 105개 passing test가 `SCR-WK-03-Save`, wide 16:10 hero와 save-after-grid, share-first reward, replacement same-day disclosure/other-day opt-in, reward-before-notification, `SCR-WK-05-Title`, full-screen portrait bounds/identifier uniqueness, 0/1/6-photo honest states를 검증; screenshot/Remotion footage capture는 명시적 opt-in이라 별도 visual-QA artifact로 검증함 | Pass |
| Local share visual/native smoke | `release/local/visual-qa/20260805-weekly-share-v3/`의 실제 1080×1920 Story, 1080×1350 Post와 iOS native share sheet screenshot; canonical wordmark, hero+2+4, exact-seven rainbow, date, `Made with Weekkeep`, JPEG/no-alpha, single temporary artifact 확인 | Pass — 외부 전송 없음 |
| Physical-device install/launch | Historical build-3 fixture-safe Debug arm64 app evidence in `release/local/target-device-qa/20260806T2102KST-build3/` installed in place on the paired physical `iPhone 16 Pro`; its argument launch succeeded while unlocked. For the build-6 fixture-only physical UI attempt, the lock wait ended, the UI runner started, then initialization failed with LocalAuthentication Code `-4` (authentication canceled) and the process was safely terminated. The result bundle is invalid/incomplete because `Info.plist` is missing and is not evidence. No credentials were requested or handled; Photos/notification permissions and private pixels were not changed | Partial — physical XCTest UI attachments, target-device footage, purchase/restore verification, actual library performance, and icon QA remain pending |
| Failure/transition hardening | Welcome 0-photo honest state, out-of-range/invalid replacement rejection, unavailable durable store failure, PhotoKit one-shot continuation, Vision fallback, foreground-only review timer, post-save reward-before-notification, restore resume, foreground refresh를 코드·unit/UI 회귀로 검증 | Pass |
| Native window / submission surface | UI test가 iPhone portrait full-screen bounds를 기기 독립적으로 검증하고, 별도 iPhone 15 Pro capture simulator에서 한국어·영어 각 4장의 Shipaton 증거를 exact `1179×2556`, no-alpha JPEG로 검증 | Pass |
| Release configuration | Signed build-6 IPA local verification: 23,338,085 bytes; SHA256 `feccbf6e94b4b848d119eb242994f9626106595b79d6e8acc0d8d8e2dc55f06a`; bundle `com.solkim.weekkeep`; version `1.0.0`, build `6`; purchases `YES`, analytics `NO`, PrivacyInfo present, Apple Distribution `sol kim`, team `D48DDX5D5W`; no tracked evidence file was created | Pass — ASC build 6 (`0ffa7586-619f-4df9-abc5-ae7ebbd068b1`) is `VALID`, attached, and in the current `WAITING_FOR_REVIEW` submission; key value is never recorded |
| TestFlight internal QA distribution — 2026-08-07 | Internal group `Weekkeep Internal QA`, ID `576fd29a-7a64-4521-9164-9697ec1c256f`, contains exactly build `6` with status `READY_FOR_BETA_TESTING` and exactly one invited verified account-holder tester, tester ID `bef018ab-9514-4388-804d-bcd363f601d4`, state `INVITED` | Ready/invited distribution only — not installed or purchase-tested; purchase/restore evidence remains pending |
| Release static analysis | `xcodebuild analyze`, Release, generic iOS Simulator | Pass |
| Signing pipeline proof | Apple Distribution archive `/tmp/Weekkeep-20260805-c.xcarchive`와 export `/tmp/WeekkeepExport-20260805-d/Weekkeep.ipa`; explicit App ID/profile·Distribution signature 검증 | Pass — final submission binary 아님 |
| Public web surfaces | `/`, `/privacy`, `/terms`, `/support`; lint, 7 server-render tests, production build, dependency audit 0 vulnerabilities, mobile/desktop visual check; logged-out HTTP verification | Pass — existing Sites project version 4 is public at `https://weekkeep-app.kimsol1134.chatgpt.site` (deployment `2026-08-06T09:35:40.860943+00:00`); all four routes returned 200, rendered the intended public support contact, and had zero internal tester-domain address matches |
| Public source repository — 2026-08-07 | `https://github.com/kimsol1134/weekkeep` is public and logged-out reachable; repository URL HTTP 200; raw `https://raw.githubusercontent.com/kimsol1134/weekkeep/main/LICENSE` HTTP 200; GitHub recognizes root `LICENSE` as MIT; checked at `2026-08-07T07:03:22+09:00`; default branch `main`; unauthenticated `git ls-remote main` commit `282ae29a0efddaca439177b447676ec2cbe90f0e` | Validated — source availability and logged-out verification are closed in `release/shipaton-manifest.json`; no App Store approval or public app release is implied |
| Release contract package | `release/*.json`, `scripts/validate-release.sh`, deterministic XCTest fixture capture path | Pass — authenticated/public evidence remains external |
| Historical build 1 evidence — 2026-08-06 | ASC build `1`, ID `f372c63f-63f0-483b-8266-f4d1c2fa78fc`, preserved in ignored `release/local/asc-release-20260806-rXACJ3/RELEASE-EVIDENCE.json` | Historical only — predates the photo-first screenshot correction and is not the ship target |
| Authenticated build 2 evidence — 2026-08-06 | Historical ASC app `6798449478`, version `1.0.0` (`ac4f183e-1019-4ffc-827f-f5514f0d349b`), build `2`, ID `45143852-bfb5-4f0c-8ca7-d509fa0a673f`; signed IPA and inspection evidence are in ignored `release/local/asc-release-build2-20260806-rerun7/` | Historical pass — ASC processing was `VALID`, build 2 was the prior attached review binary, and its prior submission is now `COMPLETE` after replacement |
| Historical build 3 evidence — 2026-08-06 | ASC app `6798449478`, version `1.0.0`, build `3`, ID `81697c0b-a68e-482a-be6f-50806e56fbff`; distribution IPA, archive, screenshot, and polling evidence are in ignored `release/local/asc-release-build3-20260806-onboarding-rerun1/` | Historical pass — ASC processing `VALID`; former submission `88c157ee-ce87-41c3-8a4a-71e614993a58` was canceled/replaced and is not current |
| ASC metadata and availability — 2026-08-07 | App `6798449478`, bundle `com.solkim.weekkeep`, version `1.0.0` ID `ac4f183e-1019-4ffc-827f-f5514f0d349b`, manual release; categories Photo & Video/Lifestyle, content rights `DOES_NOT_USE_THIRD_PARTY_CONTENT`, all-none age questionnaire, app free price, USA/KOR app availability, IAP USA/KOR availability, public support/privacy URLs, copyright `© 2026 Sol Kim`, and final review contact | Pass — App Privacy is published; IAP `6798491084` / `weekkeep_plus_lifetime` / version `cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f` is `WAITING_FOR_REVIEW`; current build is `1.0.0 (6)` |
| App Privacy publication — 2026-08-06 | Published for the current `1.0.0` app version with exactly: Customer Support = App Functionality, linked to user, no tracking; User ID = App Functionality, not linked, no tracking; Purchase History = App Functionality, not linked, no tracking | Pass — App Privacy is published with exactly these three entries; build 6 `PrivacyInfo` presence is separate binary evidence |
| Review submission boundary — 2026-08-07 | Current iOS review submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00`; exactly 2 `READY_FOR_REVIEW` items: `appStoreVersion` `ac4f183e-1019-4ffc-827f-f5514f0d349b` and IAP version `cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f`; submitted at `2026-08-06T22:44:38.573Z` | `WAITING_FOR_REVIEW` — app version `1.0.0` build `6` remains manual release; build-3 submission `88c157ee-ce87-41c3-8a4a-71e614993a58` is historical canceled/replaced; approval and public release are not claimed |
| Remote build 4 state — 2026-08-07 | App Store Connect build `4`, ID `6e92c470-c044-4512-9276-71491fe97685`, processing `VALID`, not attached | Historical/non-target external truth |
| Historical local build 5 release-candidate evidence — 2026-08-07 | `project.yml` previously defined `CURRENT_PROJECT_VERSION: "5"`; historical local App Store candidate `release/local/visual-qa/20260807-build5-app-store-candidate-rerun8/final/` | Pass — composition/manifest/provenance/standard checksum validator passed; build 5 remains not uploaded, attached, submitted, reviewed, approved, or released |
| Current build 6 release evidence — 2026-08-07 | `project.yml` `CURRENT_PROJECT_VERSION: "6"`; ASC build `0ffa7586-619f-4df9-abc5-ae7ebbd068b1` uploaded `2026-08-06T15:31:16-07:00`, `VALID`, attached to version `ac4f183e-1019-4ffc-827f-f5514f0d349b`; Settings visual-QA evidence remains at `release/local/visual-qa/20260807-build6-notification-settings-rerun1/final/` | Pass — current review is `WAITING_FOR_REVIEW`; App Store screenshot evidence remains separately labeled as historical build-3/build-5 evidence; approval, public release, and target-device footage are not claimed |
| Latest implementation verification — 2026-08-07 | Dedicated `Weekkeep AppStore 6.9` simulator; focused hardening tests, full `WeekkeepTests`, regular fixture `WeekkeepUITests`, and opt-in bilingual build-6 notification-settings capture | Pass — focused `ReleaseCandidateHardeningTests` 21/21, full `WeekkeepTests` 122/122, regular fixture UI 12/12, and build-6 notification-settings capture 2/2 locale runs, all with 0 failures |

Apple Developer bundle ID와 App Store distribution profile은 생성했고, App Store Connect app record와 current build 6의 processing/attachment를 확인했다. TestFlight internal group `Weekkeep Internal QA`는 build 6 `READY_FOR_BETA_TESTING`과 verified account-holder tester의 `INVITED` 상태까지 확인했지만 설치·purchase test는 확인하지 않았다. Historical build-3 en-US/ko screenshot six-set과 build-5 local candidate evidence는 각각 역사적 evidence로 보존한다. IAP `6798491084` / `weekkeep_plus_lifetime`는 ASC에 US $19.99로 존재하고 version `cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f`와 product/version state는 `WAITING_FOR_REVIEW`다. Final App Review contact를 구성했고, App Privacy data-usage 답변은 2026-08-06에 현재 `1.0.0` 앱 버전 범위로 게시되었다. Build 6의 로컬 IPA 검증은 `PrivacyInfo` 포함만 확인하며 별도 build-6 privacy publication event를 뜻하지 않는다. current review submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00`에는 `appStoreVersion` `ac4f183e-1019-4ffc-827f-f5514f0d349b`와 IAP version `cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f`의 정확히 2개 `READY_FOR_REVIEW` item이 포함되었고, 2026-08-06T22:44:38.573Z에 제출되어 `WAITING_FOR_REVIEW` 상태다. App version 1.0.0 build 6은 manual release로 유지한다. Previous build-2/build-3 submissions and attachments are retained as historical evidence. RevenueCat dashboard mapping은 owner-authenticated configuration으로 기록하고 sandbox purchase/restore는 pending으로 유지한다. Public policy/support site는 기존 Sites project의 version 4로 공개 배포·로그아웃 검증을 완료했다. `Shipaton Judge Access 2026` offer는 app `6798449478` / IAP `6798491084`에 ID `bb4f7fd6-2b08-4aa7-9f55-e140a3e94e28`로 USA/KOR free configuration과 세 customer eligibility로 유지되고 있다. SANDBOX one-time-code batch ID `7791e39d-f462-4647-be72-e00c75a50eff`는 10개·`2026-10-31` 만료로 생성되었지만 redemption은 테스트하지 않았다. Production custom code `WEEKKEEPJUDGES` 시도는 parent IAP 미승인으로 거절되었고 production code는 생성되지 않았다. 현재 IAP product/version이 `WAITING_FOR_REVIEW`이므로 production judge code는 app이 `Ready for Distribution`에 도달하고 IAP가 `Approved`가 될 때까지 차단한다. US public App Store release, Apple approval, Shipaton official video upload, redemption/production judge code delivery, Devpost submission은 계속 대기 중이다. GitHub Release backup URL은 공개 다운로드 보조 증거일 뿐 공식 YouTube/Vimeo gate를 충족하지 않는다. PostHog는 V1 Release에서 의도적으로 비활성이다.

Build 3 was archived/exported locally and uploaded as ASC build `81697c0b-a68e-482a-be6f-50806e56fbff`; it remains `VALID` historical evidence, while its former submission was canceled/replaced. Its local evidence is `release/local/asc-release-build3-20260806-onboarding-rerun1/RELEASE-EVIDENCE.md`. The current attached review binary is build 6; no new build-6 evidence file is created by this status sync.

## 1.1.1 RC hardening focused regression — 2026-08-07

`WeekkeepTests/ReleaseCandidateHardeningTests.swift` covers the Settings restricted/denied/authorized/limited/notDetermined Photos action contract, request-without-UIApplication behavior, the notification status × saved-album-count matrix for nil/zero/one-or-more across all five notification states, no-premature notification request, saved-user request behavior, no-second post-save primer request, zero-candidate replacement Close-only state, injected timezone date formatting at a calendar boundary, orchestration-level monotonic aggregate request progress, in-paywall purchase/restore outcome mapping, restored Continue/pending entitlement confirmation, dismissal refresh, visible outcome-banner identifiers, and caller-supplied saved-album analytics counts for Weekly and Settings callers. Pass — the focused XCTest run on the dedicated iOS 26.5 simulator executed 21 tests with 0 failures.

## 1.3 Urgent visual-quality correction evidence — 2026-08-06

온보딩 preview, shared explanatory photo-story, bottom-tab icon, Weekly Review photo-first correction은 현재 구현 기준으로 다음 증거를 남긴다. AppIcon source/master는 이 패스에서 변경하지 않았다.

| 범위 | 증거 | 결과 |
|---|---|---|
| Onboarding keepsake | `/tmp/weekkeep-onboarding-after-top.png` 및 `/tmp/weekkeep-onboarding-after-bottom.png` (dedicated `Weekkeep AppStore 6.9`, each `1320×2868`) | Pass — one paper card, full-height vertical exact-seven binding, seven fixture photos without faux-content bars or overlapping stack, all four bottom photos contained, CTA reachable after scroll |
| Bottom tab shell | `/tmp/weekkeep-tabs-after.png` (dedicated `Weekkeep AppStore 6.9`, `1320×2868`) | Pass — This Week calendar, Weeks stacked album/pages, Settings sliders remain distinct at tab-bar size; localized labels and `TAB-*` identifiers present |
| Visual-fix RC — onboarding mosaic + bottom tab bar | `release/local/visual-qa/20260806-photo-story-tabbar-fix-rc1/attachments/3B16622C-CC76-406C-962B-6620B048F1E8.png` (onboarding top), `50F92874-5914-4716-B0E8-BFC68B368706.png` (onboarding bottom), `1BE0F5AD-2CAE-4D1F-B49C-392FAA4DF2F0.png` (raw bottom), `1E7A4757-8ACD-4E6A-84F4-DD9695E45829.png` (Ready + tab bar), `992B9110-5E94-43AA-88EF-9EFF82FCFB87.png` (Plus) and `attachments/manifest.json` | Pass — fresh deterministic `Weekkeep AppStore 6.9` capture; onboarding renders distinct 1+3+3 tiles with visible gutters and clipping; Ready/Plus retain separated compact hero+2+4; bottom tab bar shows semantic icons only with zero decorative rainbow stitches; all five PNGs are opaque `1320×2868` |
| Weekly Review photo-first visual QA | Historical `release/local/visual-qa/20260806-app-store-build2-photo-first-rerun8/raw/{en-US,ko}/` captures plus current canonical `release/screenshots/app-store-6.9/{en-US,ko}/` final set | Pass — compact header cluster, independent seven-stitch signature, full-width 16:10 hero + square 2+4 collage, quiet inline privacy note, normal-flow save CTA below the complete grid; corrected build-3 set was visually inspected and used for ASC |
| Weekly Review semantic spacing audit — final simulator evidence | `release/local/visual-qa/20260806-spacing-audit-rerun7/raw/{en-US,ko}/{03-review,04-replace,03-review-bottom}.png`, both raw `AppStoreScreenshot.xcresult` bundles, representative raw screens, `release/local/visual-qa/20260806-spacing-audit-rerun7/final/contact-sheet.jpg`, and `final/PROVENANCE.md`; full unit result `/Users/solkim/Library/Developer/XcodeBuildMCP/workspaces/solkim_new-b5a60066b69d/result-bundles/test_sim_2026-08-06T15-05-45-644Z_pid68060_f66e15a4.xcresult` | Pass as the pre-refinement baseline — clean top story and intentionally scrolled lower-action captures retain the prior production spacing; 8pt photo gutters, one platform safe area plus 16pt content breathing room, Korean/English copy, replacement/privacy/save order, and representative onboarding/progress/archive/Plus/tab-shell surfaces were visually inspected. The first meaningful header row after y=150 is y=248 versus the rejected double-inset candidate's y=434; 98 unit tests, both locale capture UI runs, the top-inset upper-bound regression, capture pipeline, and static validator passed. The current spacing refinement changes the semantic contract to responsive 20pt/16pt root edges and stronger Weekly Review boundaries; the fresh-capture gate is superseded by the final bilingual simulator evidence in the row below. |
| Weekly Review spacing refinement — final bilingual simulator evidence | `release/local/visual-qa/20260807-spacing-refinement-rerun1/` (raw `ko`/`en-US`, manifests, `PROVENANCE.md`, `SHA256SUMS.txt`); `/tmp/weekkeep-spacing-ko-rerun-after-indicator.xcresult`; `/tmp/weekkeep-spacing-en-rerun-after-indicator.xcresult` | Pass — dedicated `Weekkeep AppStore 6.9` (`9C794F17-634B-4B7A-86A9-AEE88EE575FF`, iOS 26.5); both locale `AppStoreScreenshotTests` passed 1/1 through XcodeBuildMCP after final scroll-indicator restoration. Visual inspection verified responsive 20pt regular / 16pt compact root edges, Weekly Review `32/12/32` semantic boundaries, 8pt grid, `16/16/24` lower actions, Korean/English wrapping, representative surfaces, and no visible scroll indicator. Lower-action frames are intentionally scrolled validator frames, not the clean top submission frame. |
| Weekly Review safe-area correction — historical Build 5 bilingual evidence | `release/local/visual-qa/20260807-spacing-refinement-rerun7/raw/` with raw `PROVENANCE.md`, `SHA256SUMS.txt`, locale xcodebuild logs; composed candidate `release/local/visual-qa/20260807-build5-app-store-candidate-rerun8/final/` | Pass — existing build-5 evidence is preserved and is not relabeled. |
| Settings notification timing — new Build 6 bilingual evidence | `release/local/visual-qa/20260807-build6-notification-settings-rerun1/final/` with `en-US`/`ko` screenshots and manifests | Pass — static disabled/informational zero-saved state and saved-user action states are captured locally; no ASC evidence is implied. |
| Weekly Review safe-area resolver refinement — 2026-08-07 | `Weekkeep/DesignSystem/Theme/WeekkeepTheme.swift`, `Weekkeep/App/RootView.swift`, `Weekkeep/Features/WeeklyCuration/ReviewViews.swift`, `WeekkeepTests/SystemSafeAreaResolverTests.swift`; `/tmp/weekkeep-safe-area-dd.XdcDLd/resolver.xcresult`; `/tmp/weekkeep-visual-dd.cBWOsY/visual.xcresult`; `/tmp/weekkeep-unit-dd.UYychy/unit.xcresult`; `/tmp/weekkeep-screenshot-en-dd.KPb6py/en-US.xcresult` | Pass — pure production resolver cases cover runtime `max(window inset, status + 8)` and geometry-only `440×956→62`, `375×667→28`, `390×844→55`, `393×852→62`; focused resolver 2/2, VisualSystemContractTests 15/15, full WeekkeepTests 116/116, and focused en-US App Store screenshot 1/1 passed. Existing rerun7/rerun8 evidence directories were not written or regenerated. |
| Build 3 onboarding/compact visual QA | `release/local/visual-qa/20260806-build3-photo-story-rerun1/attachments/` plus `release/local/visual-qa/20260806-app-store-build3-onboarding-rerun1/final/` | Pass — onboarding is one hero + three equal + three equal with real gaps; Ready/Plus retain compact hero+2+4; en-US/ko App Store sets are exact six opaque `1320×2868` JPEGs and the corrected collage was visually inspected without clipping/overlap |
| Static visual contracts | `WeekkeepTests/VisualSystemContractTests` focused run 15 passed; `scripts/validate-release-assets.sh` | Pass — onboarding 1+3+3/no-overlap/min-gutter, compact hero+2+4, exact-seven canonical order/floor, shared photo-first source contracts, wide hero/non-overlap/action-order contracts, icon and release assets |
| Focused regression | `WeekkeepUITests/WeekkeepUITests/testReviewTapContractIsAccessibleInFixtureFlow` passed; full suite below | Pass — core flow, wide hero and save-after-grid assertions, under-seven states, replacement, share-first reward, shell reachability and localized tab identifiers |
| Screenshot extractor collision regression | `scripts/capture-app-store-screenshots.sh` exact generated-stem selector `startswith($prefix + "_0_")`, exactly-one assertion for all seven slugs, and explicit `03-review`/`03-review-bottom` non-alias guard | Pass — rerun8 captured distinct top and bottom attachments in both locales; final six-set was synced and uploaded |
| Build/release | `mcp__xcodebuildmcp__build_run_sim` Debug fixture run; `scripts/validate-release.sh --build` | Pass — dedicated simulator build/run and generic iOS Simulator Release build; release script returned 0 with only pre-existing external-state warnings |

## 1.2 Release blockers — 완료 전 `Implemented`로 닫지 않음

| ID | Blocker | 현재 상태 | 종료 증거 |
|---|---|---|---|
| `RB-01` | 최종 앱 아이콘 | 사용자 원안을 flat exact-seven master로 재제작해 Xcode asset 교체·validator·29/40/60pt @3x·Simulator system mask QA 통과; 실제 iPhone 확인 대기 | 실제 iPhone에서 29/40/60pt 식별성 확인 + `scripts/validate-release-assets.sh` Pass |
| `RB-02` | 정책/지원 사이트 공개 | 기존 Sites project version 4를 `2026-08-06T09:35:40.860943+00:00`에 public URL로 배포했고 공개 access와 로그아웃 응답을 확인함 | `https://weekkeep-app.kimsol1134.chatgpt.site/`, `/privacy`, `/support`, `/terms` 모두 로그아웃 HTTP 200; Gmail contact 노출 및 Naver 0건 |
| `RB-03` | App Store Connect app record | `6798449478`, bundle `com.solkim.weekkeep`, version `1.0.0` ID `ac4f183e-1019-4ffc-827f-f5514f0d349b`, and manual release are verified; current build 6 ID `0ffa7586-619f-4df9-abc5-ae7ebbd068b1` is `VALID` and attached, build 4 ID `6e92c470-c044-4512-9276-71491fe97685` is valid but unattached, builds 1–5 are historical/non-target, public listing is pending | `Weekkeep`, bundle, SKU, build 1–6 state separation, metadata and release evidence |
| `RB-04` | 실제 수익화 구성 | ASC non-consumable `weekkeep_plus_lifetime`가 US $19.99와 USA/KOR availability로 존재하고 RevenueCat mapping/public SDK injection이 authenticated; product/version은 `WAITING_FOR_REVIEW`, replacement submission에 연결, sandbox purchase/restore pending; Shipaton offer 구성과 10개 SANDBOX batch 생성은 확인했지만 redemption은 미검증이고 production judge code는 app `Ready for Distribution` 및 IAP `Approved` 전까지 차단 | sandbox purchase/restore와 `plus` entitlement evidence |
| `RB-05` | 최종 배포 | Signed build-6 IPA local verification is recorded (23,338,085 bytes, SHA256 `feccbf6e94b4b848d119eb242994f9626106595b79d6e8acc0d8d8e2dc55f06a`, bundle/version/build, purchases/analytics, PrivacyInfo, signing identity/team); ASC build 6 is `VALID` and attached; build 4 is valid but unattached; historical build-3 screenshot six-sets and build-5 local candidate remain historical; current review `WAITING_FOR_REVIEW`, approval·public release pending | App Review approval → manual release/public URL; no approval or public release is claimed |
| `RB-06` | 대회 자산 | metadata/script와 canonical Remotion composition contract, 승인된 72초 MP4 render 및 cut/caption QA 완료; GitHub Release backup/asset HTTP 200과 보호된 MP4 digest 일치 확인; 한국어·영어 각 4장의 exact `1179×2556`, no-alpha fixture 로컬 검증 완료; Shipaton offer 구성과 10개 SANDBOX batch 생성은 확인했지만 redemption·production judge code delivery, 공식 YouTube/Vimeo upload·로그아웃 재생·target-device footage, App Store marketing artwork·Devpost receipt는 미완료 | [Shipaton checklist](11-SHIPATON-SUBMISSION.md#11-최종-제출-체크리스트) 전체 완료 |
| `RB-08` | 공개 소스 저장소와 라이선스 | root `LICENSE`의 MIT/Sol Kim/2026 local validation과 ignored-source scan, `https://github.com/kimsol1134/weekkeep`의 public visibility/source availability/logged-out verification, raw `LICENSE` HTTP 200, GitHub MIT 인식을 모두 확인 | Validated — checked at `2026-08-07T07:03:22+09:00`; default branch `main`, unauthenticated `git ls-remote main` commit `282ae29a0efddaca439177b447676ec2cbe90f0e`; manifest evidence is redacted and contains no local/private paths |
| `RB-07` | Build 6 review replacement | build 6 upload/`VALID` processing, version attachment, signed IPA local verification, and exact-two-item current submission are complete; build 3 submission `88c157ee-ce87-41c3-8a4a-71e614993a58` is canceled/replaced and remains historical, and the approved 72-second video is unchanged | App Review outcome, manual release, and external Shipaton gates remain pending |

## 2. 기능 요구사항 추적

| Requirement | Use Case | Screen | Technical owner | Test | Coverage |
|---|---|---|---|---|---|
| `FR-001` 가치 중심 첫 화면 | UC-01 | SCR-ONB-01 | Features/Onboarding | TST-001 | Covered |
| `FR-002` 맥락형 Photos 요청 | UC-01, UC-02 | SCR-ONB-01 | Data/Photos + Onboarding | TST-002 | Covered |
| `FR-003` 권한 상태 처리 | UC-02, UC-03 | SCR-WK-01, SCR-SET-01 | Data/Photos | TST-003, TST-033 | Covered |
| `FR-004` 주차 계산 | UC-05, UC-07 | SCR-WK-01 | Domain/Policies | TST-004, TST-033 | Covered |
| `FR-005` 날짜 범위 후보 수집 | UC-04, UC-05 | SCR-WK-02 | Data/Photos | TST-005 | Covered |
| `FR-006` 기기 내 분석 | UC-04, UC-12 | SCR-WK-02 | Data/Curation | TST-006 | Covered |
| `FR-007` 최대 7장 선택 | UC-04 | SCR-WK-02, SCR-WK-03 | Data/Curation | TST-007 | Covered |
| `FR-008` 7장 미만 결과 | UC-04, UC-05 | SCR-WK-01, SCR-WK-03 | Domain/Curation + UI | TST-008 | Covered |
| `FR-009` 한 화면 검토 | UC-04, UC-06 | SCR-WK-03, SCR-WK-04 | Features/WeeklyCuration | TST-009, TST-044 | Covered |
| `FR-010` 개별 교체 | UC-06 | SHEET-REP-01 | Features/WeeklyCuration | TST-010 | Covered |
| `FR-011` 취소와 재시도 | UC-04, UC-12 | SCR-WK-02, SCR-WK-03 | WeeklyFlowModel | TST-011 | Covered |
| `FR-012` 멱등 저장 | UC-07 | SCR-WK-05 | Data/Persistence | TST-012 | Covered |
| `FR-013` Weeks 보관함 | UC-08 | SCR-ARC-01, SCR-ARC-02 | Features/Archive | TST-013 | Covered |
| `FR-014` 원본 변경 처리 | UC-08, UC-12 | SCR-ARC-01, SCR-ARC-02 | Photos + Archive | TST-014 | Covered |
| `FR-015` 로컬 알림 | UC-09 | SHEET-NOT-01, SCR-WK-01 | Integrations/Notifications | TST-015, TST-046 | Covered |
| `FR-016` 무료 한도/Plus gate | UC-05, UC-10 | SCR-WK-01, SHEET-PAY-01 | Domain/Policy + Paywall | TST-016, TST-033 | Covered |
| `FR-017` 구매/복원 | UC-10, UC-11 | SHEET-PAY-01, SCR-SET-01 | Integrations/Purchases | TST-017 | Covered |
| `FR-018` Settings | UC-03, UC-11, UC-13 | SCR-SET-01–03 | Features/Settings | TST-018, TST-046 | Covered |
| `FR-019` privacy analytics | UC-02, UC-04, UC-06, UC-07, UC-10 | all measured surfaces | Integrations/Analytics | TST-019 | Covered |
| `FR-020` 한국어/영어 | all | all | Resources + all features | TST-020 | Covered |
| `FR-021` 오류 회복 | UC-12 | affected screens | Domain/Errors + features | TST-021, TST-033 | Covered |
| `FR-022` 로컬 보존 범위 안내 | UC-08, UC-11, UC-13 | SCR-ARC-01, SCR-SET-01/02, SHEET-PAY-01 | Persistence + Settings + Paywall | TST-032 | Covered |
| `FR-023` 로컬 weekly album share | UC-07, UC-08 | SCR-WK-05, SHEET-SHARE-01, SCR-ARC-02 | Features/Sharing + Photos adapter | TST-041, TST-042 | Covered |

현재 `MISSING` 기능 요구사항: **0**

## 3. 비기능 요구사항 추적

| Requirement | Technical control | Verification | Test |
|---|---|---|---|
| `NFR-001` Privacy | network boundary, event allowlist, replay off | proxy audit + schema snapshot | TST-022 |
| `NFR-002` Performance | descriptor scan ≤500, deterministic Vision candidate cap ≤21, 384–448px fast thumbnail, per-asset ≈1.5s/global ≈12s budget, signposts | contract tests plus device benchmark; device metric remains unverified | TST-023, TST-039 |
| `NFR-003` Accessibility | semantic custom-font styles/actions, Reduce Motion | Inspector + manual matrix | TST-024, TST-035 |
| `NFR-004` Offline core | local Photo/SwiftData; cached entitlement | airplane-mode flow | TST-025 |
| `NFR-005` Reliability | unique weekKey, transaction upsert, rollback | race/failure injection | TST-026 |
| `NFR-006` Swift concurrency | actor isolation, Sendable values | strict build + concurrency tests | TST-027 |
| `NFR-007` Battery/thermal | 384–448px analysis image, separate display/share path, bounded work | contract test plus Instruments/thermal run | TST-028, TST-039 |
| `NFR-008` Maintainability | protocol adapters, pure engine | dependency boundary lint/review | TST-029 |
| `NFR-009` App size | no bundled ML model in V1, dependency audit | archive size report | TST-030 |
| `NFR-010` Localization | String Catalog, format styles | key lint + pseudo localization | TST-031 |

## 4. Shipaton/사업 요구사항 추적

| Requirement | 구현/산출물 | 검증 증거 | 현재 상태 |
|---|---|---|---|
| `BR-001` 첫 공개 릴리스 | 신규 bundle과 distribution profile | App Store public URL | External pending — `RB-03`, `RB-05` |
| `BR-002` RevenueCat 실제 구매 | PurchaseClient와 exact offering contract | dashboard + sandbox/TestFlight recording | External pending — `RB-04` |
| `BR-003` US availability | App Store territories | storefront check | External pending — `RB-05` |
| `BR-004` <2분 공개 데모 | `videos/weekkeep-remotion`의 `WeekkeepShipaton72` composition contract: 1920×1080, 30fps, 2160 frames/72.00초, 10 scenes와 restrained 12-frame fades, 23 semantic caption groups | Remotion `npm run check`, composition listing, local MP4 ffprobe/full decode, current-source cut/caption/final-video contact sheets; public video URL remains separate | Local final render validated / public URL·로그아웃 재생·target-device footage pending — `RB-06` |
| `BR-005` 아이콘/screenshot 규격 | opaque 1024 master·exact-seven muted rainbow 계약 + validator | 최종 icon의 alpha/29·40·60pt 확인 + 1179×2556 screenshot | Asset pending — `RB-01`, `RB-06` |
| `BR-006` 무료 접근 수단 | 첫 2개 무료 policy + IAP promo code plan | clean install와 judge unlock | Offer configured; 10-code SANDBOX batch generated, redemption not tested; production judge code blocked until app `Ready for Distribution` and IAP `Approved`; clean-install/judge-unlock and other external submission evidence pending |
| `BR-007` 영어 제출 | app localization + App Store/Devpost copy | native-language review | Copy implemented / final review pending |
| `BR-008` 마감 | internal T-72h cutoff | submission receipt | Plan covered / receipt pending |

## 5. Test Specification Catalog

| ID / 종류 | 검증 내용 | 성공 조건 |
|---|---|---|
| `TST-001` UI | clean install Welcome | 한 화면에서 가치/privacy/CTA, 다른 권한 요청 없음 |
| `TST-002` Integration | Photos request timing | user CTA 전 system prompt 0회 |
| `TST-003` UI/Integration | full/limited/denied/restricted/notDetermined | 각 상태에 정확한 UI와 recovery; restricted 허위 CTA 0, notDetermined 권한 요청 |
| `TST-004` Unit | week range fixtures | 연말/DST/timezone, 월요일 open·다음 월요일 close, latest-only, in-flight weekKey pin 기대값 일치 |
| `TST-005` Unit/Integration | asset filtering/sampling | 범위 밖·screenshot·hidden 없음, descriptor max 500, 500 초과 chronological range의 first/last coverage·중복 0, Vision prefilter max 21 |
| `TST-006` Integration | on-device pipeline | iOS 18 Vision aesthetics primary/fallback과 bounded signals, 416px fast image, per-asset/global timeout, monotonic partial progress, 네트워크 없이 local 사진 분석 가능 |
| `TST-007` Unit | selection invariant | selected ≤7, alternatives ≤7, 교집합 0 |
| `TST-008` UI | 0/1/6 photo | backfill/가짜 slot 없이 실제 상태 표시 |
| `TST-009` UI/Usability | review/viewer | 첫 tap은 선택·교체 action reveal만, 선택 photo 두 번째 tap은 viewer, swipe/dismiss current index 유지, VoiceOver direct view/replace, 선택 없이 CTA 1회 저장, background 시간 제외 active review timer, 활성 검토 중앙값 ≤60초 |
| `TST-010` UI/Unit | replace | same-day initial candidates, explicit other-day opt-in/grouping, 선택 또는 direct action의 정확한 한 위치만 변경, 중복 0, cancel 무변경 |
| `TST-011` Integration | cancel/retry | Photos/Vision task 취소, 같은 range 재시도 |
| `TST-012` Integration | double save/upsert | 같은 weekKey row 1개, count 1회 |
| `TST-013` UI/Integration | archive | 최신순 list, detail, empty state |
| `TST-014` Integration/UI | deleted/revoked asset | crash 0, placeholder, silent substitute 0 |
| `TST-015` Integration | notification | first save 후 contextual primer, already-determined status에서 duplicate prompt 없음, Monday 20:30, 정확한 reminder copy, 직전 완료 주 deep link |
| `TST-016` Unit/UI | free gate | album 0/1 create, album 2+eligible photo locks, album 2+zero photo는 empty state, archive always open |
| `TST-017` Integration/UI | product/purchase matrix | non-consumable lifetime→`plus` mapping, US $19.99 기준·자동 등가 storefront·현지화 가격, success/cancel/pending/fail/restore acknowledged/Continue 상태 일치와 active entitlement confirmation |
| `TST-018` UI | Settings state | Photos/notification/Plus 현재값과 진입점; restricted no-CTA, saved-album count가 0이면 notification permission action 없음 |
| `TST-019` Unit/Manual | analytics allowlist | 금지 key compile/test 실패, photo payload 0, share intent는 format·entry point만 허용하고 destination·recipient·completion은 금지 |
| `TST-020` UI | ko/en localization | missing key/truncation 0, complete catalog count 206 |
| `TST-021` UI/Integration | error recovery | 각 오류에 올바른 next action, draft 보존 |
| `TST-022` Manual/Automated | privacy network audit | vendor request에 사진 관련 값 0 |
| `TST-023` Performance | device baseline for the max-21-candidate, ~1.5s-per-asset / 12s foreground design target | real-device metric is required before any measured-performance claim; no current pass is implied |
| `TST-024` Accessibility | VoiceOver/Dynamic Type/motion | P0 flow blocker 0 |
| `TST-025` Integration | airplane mode | local assets로 analyze/save/read, 명확한 purchase state |
| `TST-026` Stress | save race/failure | corruption/duplicate 0 |
| `TST-027` Build | Swift 6 strict | concurrency warning/error 0 |
| `TST-028` Performance | thermal/memory | kill 0, bounded memory, acceptable thermal state |
| `TST-029` Architecture | dependency boundary | feature target의 vendor import 0 |
| `TST-030` Release | archive size | budget baseline 기록, 불필요 model 0 |
| `TST-031` Localization | pseudo locale | clipping/overlap P0 0 |
| `TST-032` Integration/UI | local durability disclosure/restore isolation | Settings·구매/복원 맥락에 보존 한계 ko/en 표시, 영구 보존 표현 0, restore 전후 AlbumStore mutation 0 |
| `TST-033` Unit | WeekRootStateReducer exclusivity | 상태 snapshot matrix의 모든 행에서 정확히 한 state, 우선순위·limited·0-photo·saved·gate 조합 기대값 일치 |
| `TST-034` Unit/Snapshot/Release | SevenStitchRail invariant | 모든 크기·horizontal/vertical·selected/progress/muted tone 상태에서 slot count 정확히 7, D-030 palette order 유지, filled+remaining=7, 모든 visible opacity `≥0.58`, state opacity/geometry semantics 일치; Remotion floor/count도 release validation에서 확인 |
| `TST-035` UI/Bundle | LINE Seed registration + Dynamic Type | Regular/Bold PostScript name resolve, system fallback 0, Accessibility 5에서 clipping/blocker 0 |
| `TST-036` Release | final App Icon contract | 1024×1024, sRGB, alpha 0, pre-rounded 0, exact-seven rainbow order·equal geometry를 29/40/60pt에서 확인 |
| `TST-037` Release | metadata/privacy/fixture gate | `release/*.json` schema와 App Store limits, IAP identifiers, Release analytics/purchase flags, icon validator, stale copy, deterministic fixture capture script가 일치하고, generated attachment stem exact-match/one-match collision regression을 통과 |
| `TST-038` Unit/Bundle/UI | canonical wordmark + onboarding keepsake preview | wordmark PNG와 design source byte-identical, seven named fixture resources/order 존재, preview는 하나의 calm paper/cream card에서 exact-seven rail과 all-seven fixture contract를 유지하고 faux-content bars·overlapping card stack이 없으며 CTA가 ScrollView/Dynamic Type 경로에서 도달 가능 |
| `TST-039` Unit/Integration | fast curation policy | 100 eligible descriptors produce at most 21 analyzer calls, deterministic day/time distribution, 416px request, global/per-asset timeout, skipped partial draft, monotonic overall progress |
| `TST-040` Unit/UI | same-day replacement disclosure | same-day candidates are initial only, no silent date mixing, explicit other-day action/grouping, selected-day alternative retention, no duplicate/reorder |
| `TST-041` Unit | local share renderer | Story 1080×1920 and Post 1080×1350, nonempty JPEG, hero+2+4/adaptive frame invariants, no photo IDs/private metadata, temporary-file cleanup |
| `TST-042` Unit/UI | share-first reward | Save Confirmation share primary + view/done secondary actions, format/preview/loading/retry accessibility, native preview title/thumbnail without public URL, presentation-scoped privacy-safe share event gate, Archive detail share entry, no external send required |
| `TST-043` Unit/Release/UI | semantic tab icons + onboarding visual correction | `testBottomTabBarIconsHaveUniqueSemanticSilhouettesWithoutDecorativeStitches`, `testOnboardingPhotoStoryUsesOnePlusThreePlusThreeWithMinimumGutters`, `testCompactPhotoStoryRetainsHeroTwoPlusFourGeometry`, fresh simulator capture; `ThisWeekTabIcon`, `WeeksTabIcon`, `SettingsTabIcon`의 unique asset name/silhouette, original rendering, Plum primary glyph, bottom-tab decorative stitch count `0`, localized tab labels/identifiers; onboarding source/build는 all-seven fixtures를 사용하고 faux-content bars·overlapping card stack fallback이 없음 |
| `TST-044` Unit/UI/Screenshot | Weekly Review photo-first layout, semantic spacing, and truthful action framing | deterministic 7-photo geometry는 full-width 16:10 hero, square middle 2 + bottom 4, 8pt token gaps, non-overlap, 44pt minimum을 보장하고; `WeeklyReviewSpacing`은 screen edge → header → editorial(32pt boundary, 12pt title/body) → media(32pt boundary, 8pt gutters) → helper/replace(16pt) → privacy(16pt) → primary(24pt) hierarchy를 유지하며; `WeekkeepScreenLayout`은 custom root에 20pt regular / 16pt compact(≤375pt) edge를 제공한다. pure `WeekkeepSystemSafeAreaResolver`는 runtime `max(window safe-area top, status-bar height + 8pt)`를 우선하고 두 runtime 값이 모두 0일 때만 portrait geometry fallback을 사용하며 required compact/notch/expanded cases를 고정한다. UI fixture는 SpringBoard의 runtime status-bar frame과 8pt breathing gap을 읽어 03-review header/title/body/hero를 안전하게 정렬하고, lower-action/04-replace/QA bottom에서 editorial title/copy가 안전 경계 아래에 온전히 보이거나 완전히 Cream 뒤로 occluded되는지 확인한다. 선택된 tile → replacement → privacy → save CTA의 hittable 상태와 최소 8pt 순서/간격, 독립 SevenStitchRail, tinted surface 없는 PrivacyBadge를 함께 검증하며, production은 72pt real scroll runway와 동일 Cream occluder를 사용한다. screenshot-only 0–2pt feature stack/grid override는 정적 validator와 contract test가 거부한다 |
| `TST-045` Unit/UI/Screenshot/Web | shared explanatory photo-story and native Plus presentation | `FixturePhotoStory`가 승인된 7개 fixture를 재사용하고 gradient/SF Symbol fake art·overlap·device chrome을 만들지 않으며, onboarding/Ready/Plus 화면과 web hero/`og.png`가 같은 flat vocabulary를 사용하고, Plus가 item-driven full-screen으로 열리는 source/build/visual contracts를 통과 |
| `TST-046` Unit/UI | Settings notification authorization timing | pure status × saved-album-count matrix covers nil/0/1+ and notDetermined/authorized/provisional/denied/ephemeral; zero saved albums is static informational with no request/settings action; saved user retains request/open-settings actions; model action does not call notification client prematurely; post-save primer does not request twice; opt-in build-6 UI evidence verifies the English/Korean zero-saved and saved-user surfaces |

## 6. 화면–컴포넌트 추적

| Screen | Required components | State coverage |
|---|---|---|
| `SCR-ONB-01` | CMP-01, CMP-03, CMP-04 preview, CMP-12, CMP-14 | idle/requesting/returning; calm single-surface vertical photo story/no legacy stack |
| `SCR-WK-01` | CMP-01, CMP-08, CMP-09, CMP-10, CMP-12, CMP-14 | loading/permissionBlocked/error/welcomePending/preRegularWaiting/saved/noEligiblePhotos/entitlementLocked/ready; Ready explanatory compact photo story |
| `SCR-WK-02` | CMP-02, CMP-07, CMP-11, CMP-12 | fetch/iCloud/analyze/rank/partial/cancel/error |
| `SCR-WK-03` | CMP-01, CMP-03, CMP-04, CMP-05, CMP-11, CMP-12 | review(unselected/selected)/viewer/replace/save/saveError/missing; compact header, inline save order, photo-first geometry |
| `SCR-WK-04` | CMP-05 + viewer chrome | load/available/missing |
| `SCR-WK-05` | CMP-01, CMP-04, CMP-12 | saved/firstSave |
| `SHEET-REP-01` | CMP-02, CMP-05, CMP-08 | candidates/empty/missing |
| `SHEET-SHARE-01` | CMP-01, CMP-04, CMP-12 | loading/ready/retry/error, Story/Post, preview, native share |
| `SHEET-NOT-01` | CMP-01, CMP-02 | undetermined/requesting/resolved |
| `SHEET-PAY-01` | CMP-01, CMP-02, CMP-10, CMP-11, CMP-14 | load/ready/purchase/pending/fail/restore/entitled; native item-driven full-screen surface |
| `SCR-ARC-01` | CMP-06, CMP-08, CMP-13 | empty/list/missingCover/error |
| `SCR-ARC-02` | CMP-04, CMP-05, share action | available/partial/allMissing/share-disabled |
| `SCR-SET-01` | CMP-09, CMP-10, CMP-13 | all permission/entitlement states |
| `SCR-SET-02` | text/link patterns | local storage/disclosure/online policy link |
| `SCR-SET-03` | native list rows | public support/privacy/terms links, contact mailto, open-source license texts |

## 7. Cross-document invariants

| 계약 | PRD | Use Case/IA | TRD | Design | 결과 |
|---|---|---|---|---|---|
| 최대 7장 | FR-007/008 | UC-04, WK-03 | result contract | adaptive 1–7 grid | ALIGNED |
| shortlist 최대 14 | FR-007 | UC-04 | ADR-006/pipeline | replace max 7 | ALIGNED |
| Welcome rolling 7일 | scope | UC-04 | WeekRange | Welcome copy | ALIGNED |
| 첫 Regular는 Welcome 이후 새 전체 주 | FR-004 | UC-05/IA eligibility | regularCycleStartsAt lower bound | waiting copy | ALIGNED |
| Regular 월–일 완료 범위 | FR-004 | UC-05/IA eligibility | Week calculator | localized date | ALIGNED |
| 완료 창은 다음 월–일 7일 | FR-004 | UC-05/IA eligibility | eligibleFrom/Until | no countdown/guilt | ALIGNED |
| 초안 검토가 primary, 활성 조작 ≤60초 | GOAL-01/FR-009 | UC-06/WK-03 | foreground active timer | accept-as-is CTA | ALIGNED |
| 놓친 주는 최신 완료 주 하나 | FR-004 | UC-05/IA eligibility | latest-only policy | no streak/backlog | ALIGNED |
| 사진 부족 backfill 금지 | FR-005/008 | UC-04 | fetch/result invariant | no fake slots | ALIGNED |
| Descriptor scan vs Vision work | D-032/FR-005/NFR-002 | UC-04/05 | metadata prefilter max 500 scan, max 21 Vision, bounded foreground budget | honest progress/partial copy | ALIGNED |
| Same-day replacement first | D-033/FR-010 | UC-06/SHEET-REP-01 | timezone-aware domain filter + explicit opt-in | warm empty/disclosure, day grouping | ALIGNED |
| Local share reward | D-034/FR-023 | UC-07/08, SHEET-SHARE-01 | on-device renderer, exact Story/Post dimensions, temporary file lifecycle | paper/wordmark/stitches/date/signature, native share | ALIGNED |
| 아이 신원 식별 금지 | non-goal/FR-007 | copy/flow | pipeline prohibition | voice/icon/accessibility | ALIGNED |
| 사진 외부 전송 금지 | FR-006/019 | event table | trust boundary | PrivacyBadge | ALIGNED |
| local-only V1과 보존 한계 | scope/FR-022/NFR-004 | UC-08/11/13, IA Privacy | ADR-004/011, durability boundary | Settings/paywall privacy copy | ALIGNED |
| first 2 albums free | FR-016 | UC-10 | entitlement policy | paywall | ALIGNED |
| lifetime product·localized price | FR-017 | UC-10/IA paywall | V1 상품 구성 계약 | CMP-10 | ALIGNED |
| RevenueCat | BR-002/FR-017 | UC-10/11 | PurchaseClient | PlusCard | ALIGNED |
| 알림은 첫 저장 후 | FR-015 | UC-09/13 | UserNotifications + SettingsNotificationPresentation | reward-before-request; saved-album-count gating; no duplicate primer request | ALIGNED |
| 알림은 월요일 20:30 reminder | FR-015 | UC-09/IA flow | foreground-only schedule | honest copy | ALIGNED |
| 분석 전 준비 완료 주장 금지 | D-017/FR-015 | SCR-WK-01 ready → WK-02 | ADR-005 | ready copy/uncurated photo stack | ALIGNED |
| 3 top-level tabs with unique functional silhouettes | scope | IA App Shell | AppTab + `WeekkeepTabIcon` | three original-rendering semantic vector assets with no bottom-tab decorative stitch signature | ALIGNED |
| 7장 hero+2+4·adaptive fallback | D-024 | SCR-WK-03 | ADR-012/WeeklyPhotoGrid | V2 screen set/Layout System | ALIGNED |
| Weekly Review photo-first hierarchy and action order | D-024, D-026, D-029 | SCR-WK-03 | compact header + 16:10 hero+2+4 + normal-flow save after grid/helper/privacy | Design Guide/CMP-03/04/12 | ALIGNED |
| Light only | D-026 | all screens | theme configuration | V2 screen set/QA matrix | ALIGNED |
| LINE Seed Sans KR | D-027 | all screens | bundled TTF registration | typography tokens/V2 screens | ALIGNED |
| SevenStitchRail count = 7 | D-028 | ONB/WK/ARC/SET | deterministic SwiftUI component | CMP-12/code-rendered rail contract | ALIGNED |
| Review photo tap과 접근성 action | FR-009/010, D-029 | UC-06/WK-03/WK-04 | explicit selectedIndex/destination reducer | CMP-04/05, VoiceOver custom action | ALIGNED |
| App icon + in-app exact-seven rainbow and unique tab semantics | D-030/BR-005 | app icon·all SevenStitchRail surfaces·three tab labels·Remotion rail | release asset validator + deterministic rail/tab contracts | same index palette for AppIcon/SevenStitchRail; bottom tab icons are semantic-only with no decorative stitch; semantic tab glyphs are unique and original-rendered; AppIcon source/master unchanged in visual revision | ALIGNED — automated source/asset check and dedicated simulator UI capture required |
| Canonical wordmark와 외부 brand lockup | D-031 | onboarding·app header·web·Shipaton end card | bundled canonical PNG image resource | app uses exact wordmark-only resource; external exact-seven lockup only | ALIGNED — resource byte check and UI capture pending |
| Shared explanatory photo-story surfaces | D-035/D-030 | SCR-ONB-01, SCR-WK-01, SHEET-PAY-01, web hero, `og.png` | focused `FixturePhotoStory`, approved fixture bundle copies, deterministic web/OG compositor | one flat paper surface, seven approved fictional PNGs, shared hero+2+4 geometry, onboarding vertical binding, Ready/Plus compact rail, no fake art/overlap/device chrome | ALIGNED — bundle/web/UI capture pending |
| Native Plus presentation | D-035 | SHEET-PAY-01 | existing `WeeklySheet.paywall` filtered into `fullScreenCover(item:)` | no gray sheet chrome, nested sheet, bezel, or conflicting modal boolean; purchase/restore/loading/error/routing preserved | ALIGNED — UI capture pending |
| iOS 18+ | NFR/platform | 해당 없음 | ADR-002 | current iOS patterns | ALIGNED |
| 한국어/영어 | FR-020 | accessibility copy | String Catalog | localization | ALIGNED |

### 공개 충돌 목록

| ID | 범위 | 충돌 | 영향 | 상태 |
|---|---|---|---|---|
| `CF-001` | Design source | Design Guide/App Screens V1과 Design Review V2·V2 이미지의 layout·서체·탭·알림·progress·photo gesture 표현이 일치하지 않았음 | `design/README.md`를 단일 진입점으로 지정하고 V2를 current baseline, V1·탐색안을 비규범 archive로 격리; `D-024`, `D-026`–`D-031`과 FR/UC/IA/TRD/TST 계약으로 통합 | `Resolved 2026-08-05` |
| `CF-002` | milestone scope | old docs described 100 Vision work and no V1 share/export | D-032–D-034 + FR-023 + ADR-013–015 + TST-039–042 update the ownership chain; local artifact is separate from backup/social scope | `Resolved 2026-08-05` |

현재 공개 `CONFLICT`: **0 OPEN**. 디자인 기준선과 상호작용 결정이 모두 Approved이므로 `GATE-10`은 Ready입니다.

## 8. 구현 전 Gate — Decision Registry의 파생 뷰

Gate는 결정값이나 승인 상태를 소유하지 않습니다. [Decision Registry](00-INDEX.md#5-decision-registry--결정값과-상태의-ssot)의 연결 Decision이 모두 `Approved` 이상이고 공개 conflict가 없으면 `Ready`, 아니면 `Open`으로 계산합니다.

| Gate | 확인 범위 | Decision dependencies | 추가 조건 | 파생 판정 |
|---|---|---|---|---|
| `GATE-01` | 플랫폼 | `D-003` | — | `Ready` |
| `GATE-02` | 선택 상한 | `D-004`, `D-005` | — | `Ready` |
| `GATE-03` | Regular Week와 리마인더 | `D-009`, `D-012`, `D-013` | `TST-004`, `TST-015`, `TST-046` 정의 | `Ready` |
| `GATE-04` | 놓친 주 처리 | `D-015` | `TST-004` 정의 | `Ready` |
| `GATE-05` | 무료 한도 | `D-008` | `H-003` 자연 발생 세 번째 기록 cohort 계획 | `Ready` |
| `GATE-06` | 상품·가격 | `D-023` | `TST-017` product/purchase matrix 정의; 실제 App Store/RevenueCat 구성은 M4 증거 | `Ready` |
| `GATE-07` | persistence·보존 한계 | `D-007`, `D-021`, `D-022` | `TST-025`, `TST-032` 정의 | `Ready` |
| `GATE-08` | analytics provider | `D-019` | deny-by-default config, `TST-019`·`TST-022` payload audit 계획 | `Ready` |
| `GATE-09` | project generation | `D-020` | Engineering owner, 2.46.0 pin, CI generation/build 계약 | `Ready` |
| `GATE-10` | layout·시각·review·브랜드·아이콘 기준 | `D-024`, `D-026`, `D-027`, `D-028`, `D-029`, `D-030`, `D-031`, `D-035` | 공개 design conflict 0, `TST-009`, `TST-010`, `TST-034`–`TST-036`, `TST-043`–`TST-045` 정의 | `Ready` |
| `GATE-11` | 원격 푸시 제외 | `D-009`, `D-025` | capability audit | `Ready` |
| `GATE-12` | fast curation cap/budget | `D-032` | `TST-039` policy/timeout tests; device timing remains a release evidence gap | `Ready` |
| `GATE-13` | same-day replacement | `D-033` | `TST-040` domain/UI disclosure tests | `Ready` |
| `GATE-14` | local share formats | `D-034` | `TST-041`, `TST-042`, native share manual smoke without sending | `Ready` |

현재 구현 전 Gate는 **14 Ready / 0 Open**입니다. 이는 결정과 검증 계약이 구현 기준으로 준비됐다는 뜻이며, 앱 코드·유료 계약·App Store product·RevenueCat offering이 이미 생성됐다는 뜻은 아닙니다. 그 실행 증거는 Delivery Plan의 M4와 release gate에서 확인합니다.

## 9. 변경 영향 매트릭스

| 변경 | 반드시 함께 수정할 문서 |
|---|---|
| 사진 장수/shortlist | PRD → UC-04/06 → IA Review → TRD pipeline → Design grid → tests |
| week 기준/알림 시각 | PRD → UC-05/09 → IA eligibility → TRD calculator/notification → copy |
| 무료 한도/가격 | PRD → UC-10 → IA paywall → TRD entitlement → Design paywall |
| 사진 외부 처리 | PRD privacy/non-goal 전체 재승인 → TRD threat model → App privacy → copy |
| 계정/동기화 추가 | PRD scope → 모든 UC/IA → data model/backend/security → Settings |
| 백업/기기 이전 추가 | `D-022` → PRD FR-022 → UC-08/11/13 → IA Privacy → TRD persistence/security → tests/copy |
| 최소 OS 변경 | PRD audience → TRD API fallback/CI → device QA |
| OneSignal 추가 | PRD retention/BR → UC notification → IA consent → TRD capability/privacy |
| layout·font·photo gesture·brand mark·app icon 변경 | `D-024`, `D-026`–`D-031` → PRD/UC → IA → TRD → Design SSOT/Guide → `TST-009/010/034`–`TST-038`, `TST-044` |
| explanatory photo-story surface·Plus presentation·web/OG visual 변경 | `D-035` → IA/TRD → Design SSOT/Guide → screenshot metadata → `TST-045` |
| fast curation cap/budget 변경 | `D-032` → PRD FR/NFR → UC-04/05 → IA progress → TRD pipeline/ADR-013 → `TST-005/006/023/039` |
| replacement candidate policy 변경 | `D-033` → PRD FR-010 → UC-06 → IA SHEET-REP-01 → TRD/Design → `TST-010/040` |
| local share format/brand/privacy 변경 | `D-034` → PRD FR-023 → UC-07/08 → IA SHEET-SHARE-01 → TRD/Design → `TST-041/042` |

## 10. 구현 진행 상태 표기

각 requirement의 lifecycle은 [공통 상태 정의](00-INDEX.md#4-상태-정의)만 사용합니다.

```text
Draft → Proposed → Approved → Implemented → Validated
```

- `Implemented`: production code 존재
- `Validated`: 연결된 TST가 통과하고 증거 링크 존재
- public build 확인 여부는 lifecycle 상태가 아니라 별도 release evidence 링크로 기록

현재 production code와 automated test는 존재합니다. requirement 표의 logical owner는 유지하고, release evidence는 1.1과 `RB-*`에서 관리합니다. 외부 store·purchase·public URL 증거가 없는 항목은 자동 테스트 통과만으로 `Validated` 처리하지 않습니다.

## 11. 문서 승인 체크리스트

- [x] Decision Registry의 모든 구현 의존 Decision이 `Approved` 이상
- [x] GATE-01–14 중 `Open` 0
- [x] FR-001–023 중 MISSING 0
- [x] NFR-001–010 모두 검증 방법 존재
- [x] BR-001–008 모두 산출물/증거 정의
- [x] 화면 인벤토리와 Use Case의 화면 ID 불일치 0
- [x] 컴포넌트 인벤토리와 Design Guide ID 불일치 0
- [x] 공개 cross-document `CONFLICT` 0
- [x] P0 test specification 누락 0
- [x] 승인 날짜와 문서 version 갱신
