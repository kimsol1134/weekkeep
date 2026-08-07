# Weekkeep — Shipaton 2026 Submission SSOT

| 항목 | 값 |
|---|---|
| 기준일 | 2026-08-07 |
| 프로젝트 | Weekkeep |
| 공식 규칙 스냅샷 | 2026-08-06 — [Shipaton 2026 Official Rules](https://revenuecat-shipaton-2026.devpost.com/rules) |
| 공개 릴리스·제출 창 | 2026-07-31 08:00 PDT–2026-09-30 23:45 PDT |
| 심사 종료 | 2026-10-13 12:00 PDT |
| 수상자 발표 | 2026-10-21 |
| Sponsor/Admin/Judges 무료 접근 기한 | 2026-10-13 12:00 PDT 종료 시점까지, 그 이후로 Offer Code 만료 설정 |
| 내부 제출 마감 | 2026-09-28 15:45 KST |
| 공식 제출 마감 | 2026-10-01 15:45 KST |
| 상태 | ASC build 6 (`0ffa7586-619f-4df9-abc5-ae7ebbd068b1`) is the attached and processed-`VALID` review build for version `ac4f183e-1019-4ffc-827f-f5514f0d349b`; build 4 (`6e92c470-c044-4512-9276-71491fe97685`) is `VALID` but unattached; build 3 submission `88c157ee-ce87-41c3-8a4a-71e614993a58` is historical canceled/replaced; current submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00` has exactly 2 `READY_FOR_REVIEW` items and is `WAITING_FOR_REVIEW`; IAP remains `WAITING_FOR_REVIEW`; the canonical public source repository and logged-out verification are `Validated`; app approval, public release, production judge code, and later external gates remain pending; the approved 72-second video remains unchanged |
| 현재 App Store 후보 | ASC `1.0.0 (build 6)` is `VALID`, uploaded and attached under manual release; builds 1–5 are historical/non-target, with build 4 still valid but unattached |

이 문서는 Devpost 제출 문구, 수상 카테고리 전략, 데모 영상, Build in Public, 제출 증거를 소유합니다. App Store 필드는 [App Store Metadata](10-APP-STORE-METADATA.md), 제품 결정은 [Decision Registry](00-INDEX.md#5-decision-registry--결정값과-상태의-ssot)를 따릅니다.

## 0. Current App Store release evidence — 2026-08-07

| 항목 | 현재 검증 상태 |
|---|---|
| App/version/build | ASC app `6798449478` / bundle `com.solkim.weekkeep` / `1.0.0` / build `6`; ASC build `0ffa7586-619f-4df9-abc5-ae7ebbd068b1` was uploaded at `2026-08-06T15:31:16-07:00`, processed `VALID`, and attached to version `ac4f183e-1019-4ffc-827f-f5514f0d349b` |
| Release method | Manual release |
| TestFlight internal QA | Group `Weekkeep Internal QA` (`576fd29a-7a64-4521-9164-9697ec1c256f`) contains exactly build 6 in `READY_FOR_BETA_TESTING` and exactly one invited verified account-holder tester (tester ID `bef018ab-9514-4388-804d-bcd363f601d4`, state `INVITED`) | Internal distribution ready/invited only; not installed, purchase-tested, or restore-tested |
| Remote build 4 | `1.0.0 (4)`, ASC ID `6e92c470-c044-4512-9276-71491fe97685`, is `VALID` and unattached; it remains historical/non-target |
| Historical local candidate build 5 | `project.yml` previously defined `1.0.0 (5)`; its local evidence remains historical only, not uploaded or attached |
| Signed build-6 IPA local verification | No tracked evidence file was created; 23,338,085 bytes, SHA256 `feccbf6e94b4b848d119eb242994f9626106595b79d6e8acc0d8d8e2dc55f06a`, bundle `com.solkim.weekkeep`, version `1.0.0`, build `6`, purchases `YES`, analytics `NO`, PrivacyInfo present, Apple Distribution `sol kim`, team `D48DDX5D5W` |
| App Store screenshots | Historical build-3 final set in `release/local/visual-qa/20260806-app-store-build3-onboarding-rerun1/final/`, mirrored to `release/screenshots/app-store-6.9/`; exactly six opaque `APP_IPHONE_67` JPEGs per en-US/ko, each `1320×2868`; no new build-6 screenshot evidence is claimed |
| App/IAP commerce | App free price + USA/KOR availability; IAP `6798491084` / `weekkeep_plus_lifetime` non-consumable, US base `$19.99`, USA/KOR availability, version `cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f` and product/version state `WAITING_FOR_REVIEW` |
| Compliance metadata | Photo & Video / Lifestyle, no third-party content, all-none age questionnaire, public `/support` and `/privacy` URLs, copyright `© 2026 Sol Kim`; iPhone VoiceOver-only declaration remains saved as draft because Apple gates its publication until the app is live |
| App Privacy | Published 2026-08-06 for the current `1.0.0` app version with exactly: Customer Support = App Functionality, linked to user, no tracking; User ID = App Functionality, not linked, no tracking; Purchase History = App Functionality, not linked, no tracking. Build 6 contains `PrivacyInfo`; no separate build-6 publication event is claimed |
| Review and validation | Review detail remains configured; no demo account. Current submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00`, submitted `2026-08-06T22:44:38.573Z`, has exactly two `READY_FOR_REVIEW` items: app version `ac4f183e-1019-4ffc-827f-f5514f0d349b` and IAP version `cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f`; state `WAITING_FOR_REVIEW`. |
| Physical target-device QA | After the lock wait, the build-6 fixture-only UI runner started but initialization failed with LocalAuthentication Code `-4` (authentication canceled); the process was safely terminated. The result bundle is invalid/incomplete because `Info.plist` is missing and is not evidence | Physical UI attachments, purchase/restore verification, target-device footage, actual-library performance, and icon QA remain pending; no credentials were requested or handled and Photos/notification permissions and private pixels were not changed |
| Shipaton judge-access Offer Code | ASC app `6798449478` / IAP `6798491084`; `Shipaton Judge Access 2026` offer ID `bb4f7fd6-2b08-4aa7-9f55-e140a3e94e28`, free prices `USA:FREE` and `KOR:FREE`, eligibilities `NON_SPENDER`, `ACTIVE_SPENDER`, `CHURNED_SPENDER`; SANDBOX batch ID `7791e39d-f462-4647-be72-e00c75a50eff` | Configured and generated remotely; batch has 10 codes expiring `2026-10-31`; redemption is not tested; production judge code is blocked until app `Ready for Distribution` and IAP `Approved` |

Builds 1–5 remain historical/non-target evidence. Build 3 (`81697c0b-a68e-482a-be6f-50806e56fbff`) remains `VALID` historical evidence, but its former review submission `88c157ee-ce87-41c3-8a4a-71e614993a58` was canceled/replaced. The current submission is `a9b0a18f-6cf6-4af4-8e6f-c77009831e00` and is `WAITING_FOR_REVIEW`. No public release, production Offer Code, sandbox redemption test, public video, or Devpost submission was performed. The remote judge-access offer is configured free in USA/KOR and its SANDBOX batch is generated, but the batch has not been redeemed.

The prior iOS review submission `260abf1a-886b-4014-8262-541d261e60e2` is historical: it was submitted at `2026-08-06T10:27:11.249Z`, then canceled and is now `COMPLETE`; its build-2 attachment and review items are no longer current. The former build-3 submission `88c157ee-ce87-41c3-8a4a-71e614993a58` was canceled/replaced and is historical. The current submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00` contains exactly 2 `READY_FOR_REVIEW` items: `appStoreVersion` `ac4f183e-1019-4ffc-827f-f5514f0d349b` and IAP version `cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f`. It was submitted at `2026-08-06T22:44:38.573Z` and is `WAITING_FOR_REVIEW`; App version `1.0.0` build `6` remains manual release. This record claims neither approval nor public release.

## 0.1 Historical remote build 3 review evidence — 2026-08-06

| 항목 | 현재 검증 상태 |
|---|---|
| App/version/build | `6798449478` / `1.0.0` / historical build `3`; ASC build `81697c0b-a68e-482a-be6f-50806e56fbff` remains `VALID` evidence only |
| Release binary | `release/local/asc-release-build3-20260806-onboarding-rerun1/exported/Weekkeep.ipa`; Apple Distribution signature, `get-task-allow=false`, analytics off, purchases on, no fixture launch markers |
| Local App Store screenshots | `release/local/visual-qa/20260806-app-store-build3-onboarding-rerun1/final/`; en-US/ko exactly six opaque `1320×2868` JPEGs; canonical local tree mirrors this set; remote replacement is verified |
| Local visual QA | `release/local/visual-qa/20260806-build3-photo-story-rerun1/attachments/`; onboarding 1+3+3 and Ready/Plus compact hero+2+4 inspected without clipping/overlap |
| Version attachment boundary | Build 3 evidence is historical; current build 6 `appStoreVersion` relationship points to `ac4f183e-1019-4ffc-827f-f5514f0d349b`; release method remains manual |
| Review replacement boundary | Former submission `88c157ee-ce87-41c3-8a4a-71e614993a58` was canceled/replaced; current submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00` is `WAITING_FOR_REVIEW` with exactly 2 `READY_FOR_REVIEW` items |
| Evidence | `release/local/asc-release-build3-20260806-onboarding-rerun1/RELEASE-EVIDENCE.md` |

## 0.2 Historical local build 5 candidate — 2026-08-07

| 항목 | 현재 검증 상태 |
|---|---|
| Project version | `project.yml` / `1.0.0 (5)`; generated Xcode project is derived from this SSOT |
| App Store screenshots | `release/local/visual-qa/20260807-build5-app-store-candidate-rerun8/final/`; six opaque `1320×2868` JPEGs per `en-US`/`ko`, composed only from `release/local/visual-qa/20260807-spacing-refinement-rerun7/raw/` |
| Provenance/checksums | Candidate `PROVENANCE.md`, `manifest.json`, and standard checksum-only `SHA256SUMS.txt` record the raw source paths and composed output hashes; older build-3 and build-5 rerun1 evidence is untouched |
| External state | Historical local candidate only; no ASC upload, attachment, submission, review, approval, or release is claimed for build 5 |

## 0.3 Current ASC build 6 — 2026-08-07

| 항목 | 현재 검증 상태 |
|---|---|
| Project/version | `project.yml` / `1.0.0 (6)`; ASC build `0ffa7586-619f-4df9-abc5-ae7ebbd068b1` is the current uploaded build |
| FR-015 implementation surface | Settings notification authorization is disabled and informational until at least one album is saved; saved-user states retain request/open-settings behavior; post-save primer avoids a second system request |
| Settings visual QA | Evidence directory `release/local/visual-qa/20260807-build6-notification-settings-rerun1/final/`; four bilingual opaque `1320×2868` PNGs cover zero-saved informational and saved-user action states; it remains separate from App Store screenshot evidence |
| ASC state | Uploaded `2026-08-06T15:31:16-07:00`, processing `VALID`, attached to version `ac4f183e-1019-4ffc-827f-f5514f0d349b`; current review submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00` is `WAITING_FOR_REVIEW` |

## 1. 승리 전략

### 카테고리 우선순위

| 우선순위 | 카테고리 | 적합도 | 승리 논리 | 제출 조건 |
|---:|---|---:|---|---|
| 1 | RevenueCat Design Award | Focus / primary | 매일 붙잡지 않는 주간 ritual, exact-seven visual language, photo-first restraint, select→replace interaction, 저장→Story/Post 공유 reward, local-first trust copy가 하나의 경험으로 연결됨 | motion이 보이는 demo와 특정 화면·interaction 설명 |
| 2 | HAMM Award (Help Apps Make Money) | Focus / secondary | 첫 두 기록 뒤에만 나타나는 $19.99 lifetime paywall, 반복 서버비가 없는 local-first 구조, 구독 피로가 큰 부모에게 맞춘 단순한 packaging | 실제 RevenueCat 구매, 가격·paywall·conversion·revenue 증거 |
| 보조 | #BuildInPublic | Focus / supporting | commit 수가 아니라 부모의 문제, 선택의 이유, 받은 피드백, 그 피드백으로 바꾼 제품을 공개 | 공개 post 링크와 public building이 제품을 개선한 짧은 설명 |
| 조건부 | Grand Prize | Conditional / stretch | 출시·성장 traction이 확인된 뒤에만 전체 제품 결과로 확장 | 공개 출시와 검증된 release/growth metrics |
| 조건부 | RevenueCat Peace Prize | Conditional | 가족 기록 부담과 프라이버시에 대한 직접적인 부모 evidence가 있을 때만 | 실제 부모 beta의 이해·부담 감소 근거 |
| 조건부 | Most Viral App | Conditional | 실제 Noise campaign/account를 사용하고 측정한 경우에만 | live Noise campaign와 검증된 viral metrics |

Peace Prize는 “가족을 구한다” 같은 과장으로 쓰지 않습니다. 5명 prototype/20명 beta에서 부모가 기록 부담이나 프라이버시 안도감을 실제로 언급했을 때만 체크합니다.

### Official category decision matrix — all 21 categories

이 표가 카테고리 전략의 유일한 분류입니다. `Focus`, `Conditional`, `Exclude`는 서로 배타적이며 전체 공식 21개 카테고리를 빠짐없이 포함합니다. 조건부 블록은 요구 evidence가 검증되기 전까지 제출하지 않습니다.

| 공식 카테고리 | 결정 | Weekkeep 판단과 제출 조건 |
|---|---|---|
| Grand Prize | Conditional | Stretch only after verified public launch and release/growth metrics; 현재는 submission-ready 아님 |
| #BuildInPublic | Focus | Supporting target; public links와 public building이 제품을 개선한 짧은 설명이 확인될 때 제출 |
| Best Game | Exclude | 게임이 아니며 게임 기능·scope를 추가하지 않음 |
| RevenueCat Peace Prize | Conditional | 직접 참여한 부모의 mental-load/privacy evidence가 확인될 때만 제출 |
| RevenueCat Design Award | Focus | Primary target; interaction, visual system, restraint, and local-first trust를 실제 영상으로 설명 |
| Catvertising | Exclude | This category is about creative/effective use of RevenueCat Ads, not cat-themed advertising. Weekkeep does not use RevenueCat Ads and will not add interruptive ads merely to chase the category because that conflicts with the calm product experience. |
| Next Gen | Exclude | Weekkeep은 non-Next-Gen 앱 track으로 다루며 이 분류를 위해 재정의하지 않음 |
| HAMM Award (Help Apps Make Money) | Focus | Secondary target; pricing, paywall, conversion, and revenue evidence가 확인될 때 제출 |
| Conflict of Interest | Exclude | 해당 category를 정당화하는 qualifying conflict-of-interest case가 없음 |
| Productivity / Christopher Lawley | Exclude | 일반 생산성 도구가 아니라 부모의 weekly memory product이며 positioning을 바꾸지 않음 |
| Nutrition & Healthy Eating / Abbey’s Kitchen | Exclude | 영양·식습관 제품이 아님 |
| Yoga & Fitness / Simone Sharice | Exclude | 요가·피트니스 제품이 아님 |
| Career Coaching / Leadership Heather | Exclude | 커리어 코칭 제품이 아님 |
| Gaming / Mr Lewis Blogs Gaming | Exclude | 게임이 아니며 gaming scope를 추가하지 않음 |
| Ship Kotlin Everywhere / JetBrains | Exclude | Swift/iOS 앱이며 Kotlin 지원이나 SDK를 추가하지 않음 |
| Most Viral App / Noise | Conditional | 실제 Noise campaign/account를 사용하고 measured campaign evidence가 있을 때만 제출 |
| Best App for Galaxy / Samsung | Exclude | Galaxy target device/스토어 앱이 아니며 Android scope를 추가하지 않음 |
| Idea to Income / Replit | Exclude | Replit으로 만들었다는 verified evidence가 없고 이를 위해 개발 환경을 바꾸지 않음 |
| Keep Them Coming Back / OneSignal | Exclude | V1은 local notification이며 OneSignal·remote push를 제외함 |
| Growth Loop / Layers | Exclude | Layers integration이나 별도 growth-loop scope가 없으며 SDK를 추가하지 않음 |
| Funnel Vision / Stripe | Exclude | The official category requires a live web-to-app funnel using RevenueCat Funnels with Stripe. Weekkeep has no such live funnel; V1 uses a native App Store non-consumable purchase through RevenueCat, and we will not add a web funnel only to chase the category. |

### 심사위원이 20초 안에 이해해야 할 문장

> Weekkeep is a calm, private weekly ritual that turns a crowded camera roll into up to seven family moments worth keeping—in about one quiet minute.

### 우리가 이기려는 방식

1. 문제를 개발자의 생산성이 아니라 부모의 미완성 camera roll로 시작합니다.
2. 핵심 flow 하나를 완성도 높게 보여줍니다: 제안 → 한 장 교체 → 저장 → Story 공유 → 다시 보기.
3. “사진은 기기 밖으로 나가지 않는다”를 설명이 아니라 처리 구조와 화면 copy로 증명합니다.
4. Seven-stitch, 7장 구성, 1분 interaction, 두 번 무료라는 숫자를 하나의 기억법으로 만듭니다.
5. 매출은 과장하지 않고 설치→무료 기록→paywall→구매를 cohort와 기간까지 명시해 보고합니다.

## 2. 공식 자격 요건 체크

| 요구사항 | Weekkeep 대응 | 상태/증거 |
|---|---|---|
| iOS/iPadOS/macOS/Android 중 하나 | iPhone iOS 18+ non-Next-Gen app | 구현 완료; external release evidence pending |
| RevenueCat qualifying purchase/ads | non-consumable `weekkeep_plus_lifetime` → `plus` via RevenueCat | 계정·상품 연결·실제 구매 evidence 대기 |
| 첫 public release가 submission window 안 | non-Next-Gen 앱의 첫 public store release가 2026-07-31 08:00 PDT 이후, 2026-09-30 23:45 PDT 이전 | 공개 전 App Store 상태 캡처 필요 |
| fully published eligible store | US App Store에서 실제 다운로드 가능한 published listing이어야 함 | 최소 마감 1주 전 심사 제출 |
| 미국에서 접근 가능 | US storefront에서 로그아웃 상태로 다운로드 가능 | storefront smoke 대기 |
| 영어 text/material | Devpost와 video narration 영어 | copy·자막·72초 local master source 완료 |
| 공개 demo video <2분 | 정확히 72초 `WeekkeepShipaton72` composition, YouTube/Vimeo public visibility | source·voice·BGM·23 caption groups·10 scenes·local final MP4/cut QA 완료; 공개 업로드·로그아웃 재생·target-device footage 대기 |
| YouTube 또는 Vimeo 공개 URL | unlisted가 아니라 publicly visible로 확인 | 업로드 대기 |
| 앱이 target device에서 동작하는 footage | Release/TestFlight iPhone screen recording에서 프로젝트가 실제로 동작하는 장면 | build 3 fixture-safe install과 argument launch command proof 완료; build-6 fixture-only UI runner는 lock wait 뒤 시작했지만 LocalAuthentication Code `-4` authentication canceled로 initialization failed, process terminated; result bundle is invalid/incomplete (`Info.plist` missing) and is not evidence. QuickTime preview/recording은 gray라서 target-device footage로 인정하지 않음 (`release/local/target-device-qa/20260806T2102KST-build3/`) |
| 1024×1024 app icon | 사용자 원안 기반 exact-seven rainbow opaque master | 자동 검증·@3x 축소 QA 통과; 실제 iPhone 확인 대기 |
| screenshot 최소 1장 | `1179×2556`, alpha 없음, device frame 없음 | 한국어·영어 bundled-fixture UI 각 4장 로컬 규격·시각 QA 완료; 최종 선정·업로드 대기 |
| Sponsor/Admin/Judges 무료·무제한 접근 | `weekkeep_plus_lifetime`용 Apple free IAP Offer Code를 US에서 everyone eligible로 발행; Devpost field에서는 promo code라고 부를 수 있음 | `Shipaton Judge Access 2026` offer 구성과 USA/KOR free price, 세 eligibility 확인; 10개 SANDBOX batch 생성(만료 `2026-10-31`)했지만 redemption은 미테스트이며 production judge code는 app `Ready for Distribution` 및 IAP `Approved` 전까지 차단 |
| third-party 권리 | SDK license, LINE Seed OFL, 허가된 fixture photo | license bundle 완료; 사진 consent 대기 |

대회 규칙상 일반 카테고리 앱은 “심사 중”이 아니라 실제 스토어 공개 상태여야 합니다. 내부 일정은 App Store 공개를 공식 마감보다 7일 이상 앞당깁니다.

### Devpost intake filter

이 표는 제품 결정이 아니라 Devpost intake 통과에 필요한 제출 증거만 관리합니다. 카테고리 우선순위와 답변 원문은 이 문서의 해당 섹션을 기준으로 하며, 로컬 자산 완료와 외부 검증 완료를 같은 상태로 취급하지 않습니다.

| Intake gate | Devpost가 확인하는 것 | Weekkeep 증거와 exit criterion | 현재 상태 |
|---|---|---|---|
| Bundle/package identifier + RevenueCat SDK | RevenueCat SDK integration을 확인할 수 있는 유효한 bundle ID 또는 package name | `com.solkim.weekkeep`와 published store record를 연결하고 RevenueCat integration 검증 증거를 남김 | 외부 검증 대기 |
| Required fields + category answers | 모든 required Devpost fields와 선택한 Focus/검증된 Conditional category questions의 답변 | 이 문서의 영어 입력과 검증된 category blocks만 제출; core 입력에 bracketed placeholder가 남아 있으면 제출하지 않음. 조건부 category와 명시적으로 제외한 post-launch metrics의 placeholder는 readiness에서 제외 | 외부 제출 대기 |
| Published store page URL | 공개된 App Store/Google Play 또는 허용된 store page URL | US App Store 공개 URL, 로그아웃 상태에서 열기·설치 확인 | 외부 공개 대기 |
| Public demo video | 공개 YouTube 또는 Vimeo의 앱 demo URL | `videos/weekkeep-remotion/`의 `WeekkeepShipaton72` approved 72-second final render와 QA를 완료했고 GitHub Release backup URL/asset은 HTTP 200; 첫 2분에 elevator pitch·app in use·targeted categories를 명확히 포함 | GitHub backup은 공식 gate가 아님; 실기기 footage·YouTube/Vimeo 공개 업로드·로그아웃 재생 대기 |
| 1024×1024 app icon | 1024×1024 icon | opaque exact-seven master와 외부 전달/실기기 QA | 로컬 master 준비, 외부 QA 대기 |
| 1179×2556 screenshot | 최소 1장의 1179×2556 screenshot, device frame 없음 | 로컬 bundled-fixture UI가 규격을 통과하고 최종 선정·업로드 | 로컬 bundled-fixture UI 완료, 외부 선정·업로드 대기 |
| Public source repository + OSI license | 공개 source repository URL, source availability, visible OSI-approved license, and logged-out verification | `https://github.com/kimsol1134/weekkeep` is public and logged-out verified; repository and raw `LICENSE` URLs returned HTTP 200; GitHub recognizes root `LICENSE` as MIT | `Validated` — checked at `2026-08-07T07:03:22+09:00`; default branch `main`, unauthenticated `git ls-remote main` commit `282ae29a0efddaca439177b447676ec2cbe90f0e` |
| Judge unlock | Sponsor/Admin/Judges가 심사 종료까지 모든 premium feature를 무료·무제한으로 확인할 수 있는 경로 | Apple Offer Code를 US·everyone eligible·non-consumable `weekkeep_plus_lifetime`로 구성했고, Devpost가 요구하면 production code를 promo code field로 외부 전달; sandbox batch redemption은 미테스트이고 code/credential은 git에 넣지 않음 | Offer configured / sandbox redemption pending / production code blocked until app `Ready for Distribution` and IAP `Approved` |

Prescreeners는 submission을 읽고 video의 첫 2분을 봅니다. 따라서 이 canonical 72초 Remotion composition을 최종 render한 video는 첫 2분 안에 elevator pitch, app in use, targeted categories를 모두 이해하게 해야 합니다. 이 기준은 [How we judge Shipaton](https://www.shipaton.com/blog/how-we-judge-shipaton)을 따릅니다.

### Public source and license gate

The local source package includes the root `LICENSE`, validated as the OSI-approved MIT license with copyright holder `Sol Kim` and year 2026. `scripts/validate-public-source.sh` checks the license, ignored secret/evidence paths, forbidden candidate paths, and output-redacted token, judge-code, private-key, and reviewer-contact patterns. The canonical public GitHub repository is `https://github.com/kimsol1134/weekkeep`; source availability and logged-out verification are recorded as `Validated` in the manifest from supplied external evidence. This gate closure does not claim App Review approval, public App Store release, purchase/restore validation, judge redemption, target-device footage, public video upload, or Devpost completion.

### Judge access plan — English

현재 상태: `NOT SUBMISSION-READY — the Offer Code configuration is complete and a SANDBOX batch is generated, but redemption is not tested; production judge-code generation is blocked until the app is Ready for Distribution and the IAP is Approved.` 실제 one-time code 값은 저장소에 기록하지 않습니다.

Apple의 현재 용어는 In-App Purchase용 **Offer Code**입니다. Devpost가 이 심사 경로를 `promo code`라고 부를 수 있으므로 제출 field에서는 그 표현을 따르되, Weekkeep의 실제 계획은 다음과 같습니다.

```text
Provide a free Apple IAP Offer Code for the non-consumable product `weekkeep_plus_lifetime`. The offer is eligible to everyone in the United States and unlocks the complete Weekkeep Plus experience for Sponsor, Admin, and Judge review. Configure the offer to remain valid through the end of judging, 2026-10-13 12:00 PDT, with expiry after that deadline. The real code will be generated in the authenticated App Store workflow, shared only through the private Devpost judge-access field if requested, and never committed to Git.
```

Remote status on 2026-08-07: the offer remains configured free in USA/KOR on ASC app `6798449478` / IAP `6798491084`, and the SANDBOX batch was generated with 10 codes expiring `2026-10-31`; redemption has not been tested. An attempted production custom code `WEEKKEEPJUDGES` was rejected because the parent IAP is not approved, and no production code was created. Production judge access remains blocked until the app is `Ready for Distribution` and the IAP is `Approved`. The judge-access gate remains `pending_external` until redemption, production delivery, and the remaining private-access evidence are verified together. A configured offer and local plan are not evidence that the final external access path is ready.

## 3. Devpost 기본 입력 — English

### Project name

```text
Weekkeep
```

### Tagline

```text
A week worth keeping—in seven private moments.
```

### Short description

```text
Weekkeep is a calm, privacy-first iPhone app for busy parents. It prepares a draft of up to seven photos from the past week on device, lets the parent replace only what feels wrong, saves the result as a small weekly album, and can render that saved album locally as a shareable Story or Post image.
```

### Full description

```text
Parents do not have a shortage of photos. They have a shortage of time to decide which moments matter.

Weekkeep turns that unfinished camera roll into one small weekly ritual. On the first visit, a parent can start with the most recent seven days. After that, each completed week becomes available on Monday. Weekkeep examines eligible photos on the iPhone, prepares a draft of up to seven moments, and asks for one gentle decision: keep the draft, or replace only the photos that do not feel right.

The product is deliberately not a daily habit tracker. There are no streaks, backlogs, countdowns, or guilt. If a family took only five usable photos, Weekkeep shows five. The parent remains the editor, and every saved week can be revisited or explicitly exported in a quiet local archive.

The saved-week reward is a local share artifact: Story is 1080×1920 and Post is 1080×1350. It uses the real saved Photos images, warm paper, the canonical Weekkeep wordmark, the exact seven muted rainbow stitches, the date range, and a restrained “Made with Weekkeep” signature. Rendering happens on device and the native iOS share sheet appears only after the parent chooses to share; there is no photo upload service, account, or server rendering.

Privacy is part of the interaction, not a footer. Photo analysis runs in the foreground on device. Photo pixels, thumbnails, Photos identifiers, filenames, capture times, and locations are not sent to Weekkeep, RevenueCat, or analytics services. The first App Store release has no Weekkeep account, no photo upload, no CloudKit album sync, and no session replay.

Weekkeep uses RevenueCat for a simple business model that fits the product. The first two weekly albums are free, so parents can feel the value before seeing a paywall. A one-time $19.99 Weekkeep Plus purchase unlocks future album creation. There is no subscription. RevenueCat provides the localized store product, purchase state, lifetime entitlement, and restoration flow while the photo experience stays local.

The visual language is built around seven rounded stitches: one for each possible moment in a week. The same constraint shapes the progress rail, adaptive photo composition, app icon, and save transition. It makes the limit understandable without turning the week into a score.

Weekkeep is for parents who want to remember ordinary family life without turning memory keeping into another job.
```

### Inspiration

```text
The idea came from a familiar parenting contradiction: the camera roll keeps growing, but the albums never get made. The problem was not taking or storing photos. It was the repeated emotional and practical cost of sorting them. We wanted to reduce that decision to one quiet minute a week without uploading a family's photo library or asking parents to build another daily habit.
```

### What it does

```text
Weekkeep requests Photos access only after explaining why, finds eligible photos for the week, analyzes them on device, suggests up to seven diverse moments, lets the user view and replace individual choices, saves one idempotent local weekly album, offers a local Story/Post share artifact after explicit action, and brings the parent back with an optional local Monday reminder. Two albums are free; RevenueCat powers the lifetime Plus purchase and restoration flow.
```

### How we built it

```text
Weekkeep is a native SwiftUI app for iOS 18+ using Swift 6 strict concurrency. PhotoKit supplies authorized assets, Vision produces on-device quality and similarity signals, and a deterministic curation engine enforces the seven-photo and no-duplicate contracts. SwiftData stores album metadata locally; a local renderer creates the two share formats without server rendering. RevenueCat purchases-ios maps the App Store non-consumable to the `plus` entitlement through the `default` offering. The UI uses a bundled LINE Seed Sans KR family and a code-rendered exact-seven stitch system with VoiceOver, Dynamic Type, Reduce Motion, Full/Limited Photos access, and Korean/English localization.
```

### Challenges

```text
The hardest part was not ranking photos; it was deciding what the app should refuse to do. Weekkeep does not identify a child, upload a library, fabricate empty slots, create a backlog, or claim that an algorithm knows the family's “best” memory. The implementation had to keep PhotoKit, Vision, local persistence, week boundaries, purchase state, and cancellation behavior consistent while preserving that restraint in every screen.
```

### Accomplishments

```text
We built the complete first-value loop with real Photos permission states, foreground on-device curation, an adaptive one-to-seven-photo review, same-day-first one-photo replacement, atomic local save, a polished local Story/Post share artifact, a Weeks archive, local reminders, bilingual accessibility, and a RevenueCat purchase boundary. The same seven-moment rule is expressed consistently across the product, interaction, visual system, share output, and monetization story.
```

### What we learned

```text
Our documented product iteration led to four practical lessons. First, Weekkeep should be weekly, not daily: the product returns a parent to one completed week without streaks or guilt. Second, the post-save reward should be useful and shareable, so the saved weekly album leads to a local Story/Post artifact. Third, calm is structural: we refined the design around non-overlapping layouts, semantic spacing, and a distinct navigation hierarchy. Finally, we shifted the message to start with the parent's unfinished camera roll and limited time, not commit counts, model counts, or implementation volume. These are lessons from our product decisions and iteration, not claims about interviews, cohorts, public feedback, installs, purchases, conversion, revenue, or other unverified metrics.
```

### What’s next

```text
After launch we will follow the first real cohorts through two eligible weekly cycles. We will measure completion, initial-photo acceptance, reminder return, purchase conversion, and save-confirmation share-sheet intent by Story/Post format without collecting photo identifiers, content, recipients, destinations, or claiming an external post completed. Those results will decide whether to improve curation, timing, pricing, or the local share reward before considering family sharing or cloud backup.
```

### Built with

```text
Swift, SwiftUI, SwiftData, PhotoKit, Vision, RevenueCat, StoreKit, UserNotifications, XcodeGen, XCTest
```

## 4. Design Award answer — English

```text
Weekkeep is designed as a quiet weekly ritual, not an engagement machine.

Please look for five connected design decisions:

1. The exact-seven stitch system communicates the maximum album size without behaving like a streak or score. The icon and every in-app rail keep the same seven muted rainbow colors; progress and selection are expressed through opacity and geometry rather than recoloring the stitches.
2. The photo composition adapts honestly from one to seven real images. Seven uses a hero + 2 + 4 editorial layout when touch targets allow; smaller sets never receive fake placeholders.
3. Review uses a deliberate select-then-replace interaction. The first tap selects a photo and reveals the replacement action; a second tap opens the viewer. VoiceOver exposes direct “View larger” and “Replace photo” actions so sequential tapping is not required.
4. The save moment moves the reviewed grid into a calm album state and makes a local Story/Post image the next reward. Reduce Motion receives a short fade rather than losing feedback.
5. Privacy and emotional tone are part of the visual hierarchy. Photos dominate; controls are restrained; permission, local processing, explicit share-sheet handoff, missing-photo, and local-storage limits are stated honestly. There are no streaks, countdowns, celebratory confetti, or claims that AI knows a family's best moment.

The demo shows the Weekkeep rail, adaptive seven-photo review, one-photo replacement, save-to-share reward, archive, and paywall in motion.
```

## 5. HAMM Award (Help Apps Make Money) answer — English

```text
Weekkeep's monetization is intentionally small and aligned with its cost structure.

The first two saved weekly albums are free. This lets a parent experience the complete value twice before the third album-creation attempt opens the paywall. Existing albums always remain readable. Weekkeep Plus is a single non-consumable lifetime purchase at a US base price of $19.99, with Apple's localized equivalent shown in every storefront. There is no subscription and no artificial urgency.

That packaging fits both the audience and the product. Parents already face subscription fatigue, while Weekkeep has no recurring photo-storage or server-analysis expense: photo curation and album storage stay on the iPhone. A one-time purchase can therefore feel honest to the parent and remain economically sustainable as the user base grows.

RevenueCat is the source of truth for the `plus` entitlement. The App Store product `weekkeep_plus_lifetime` is attached to the `default` offering. The app requests the localized product and price, handles purchase cancellation/pending/failure, and restores lifetime access on another device without falsely claiming to restore locally stored albums.

### Post-launch metrics — excluded until evidence

The following values are not part of the current paste-ready answer and remain excluded until verified with RevenueCat/App Store data.

Post-launch metrics — excluded from the current submission until verified with RevenueCat/App Store data:
• Measurement window: [UTC dates]
• App installs: [n]
• First album completed: [n / %]
• Users who naturally reached the third-album paywall: [n]
• Purchases: [n]
• Paywall-to-purchase conversion: [n / %; include denominator definition]
• Gross revenue: [$]
• Refunds: [n]

We will not combine fixture paywall tests with real purchase conversion, and we will report zero or small numbers honestly.
```

## 6. Peace Prize answer — conditional English draft

이 섹션은 parent beta에서 직접 근거를 얻은 경우에만 제출합니다.

```text
Weekkeep addresses a small but widespread source of family mental load: parents accumulate thousands of meaningful photos while the work of sorting them remains unfinished. The app reduces that task to one calm decision a week and avoids the guilt mechanics commonly used to increase engagement.

The privacy model matters because family photos can reveal children, homes, routines, and locations. Weekkeep analyzes photos on device and does not upload photo content or identifiers. Parents can use the core experience without creating an account.

Observed impact (required before submission): [number] parents completed a first weekly album; [number/percentage] could accurately explain where their photos were processed; and [specific, consented, anonymized finding] showed how the one-minute format reduced the burden of memory keeping.
```

## 7. 72-second demo master

영상은 영어 voice-over, DEBUG `-ui-fixtures`로 캡처한 bundled-fixture UI footage, 허가된 fixture photos로 구성합니다. 이 capture는 deterministic UI evidence이며 simulator PhotoKit ingestion을 exercise하지 않습니다. 최종 공개본에서 실기기 작동 증거가 필요한 beat는 Release/TestFlight screen recording으로 교체하고 동일한 narration·시간표를 유지합니다. Live PhotoKit behavior는 이 capture와 별도의 adapter/device QA path에서 검증합니다. 저작권 음악과 타사 상표가 들어간 화면은 쓰지 않습니다.

| Time | Footage | Voice-over |
|---:|---|---|
| 0:00–0:06 | 저장된 7장 앨범과 exact-seven rail로 시작 | `Parents don't need another app to open every day. They need one quiet minute to keep the week.` |
| 0:06–0:12 | Weekkeep 소개와 review surface | `Weekkeep turns a crowded camera roll into up to seven family moments worth keeping.` |
| 0:12–0:23.5 | 권한 primer, on-device와 no-upload boundary | `Photos access is requested only after this explanation. Analysis runs here, on the iPhone; photo content and identifiers are not uploaded.` |
| 0:23.5–0:32.5 | draft와 seven-is-a-limit 증거 | `A draft is already prepared. Seven is a limit, not a target—if the week has fewer usable photos, Weekkeep shows fewer.` |
| 0:32.5–0:39.5 | 선택한 한 장만 교체 | `The parent stays the editor. Keep the draft, or change only the moment that doesn't feel right.` |
| 0:39.5–0:44.5 | Save confirmation → production-rendered 9:16 Story artifact, `READY TO SHARE` | `One tap saves a small weekly album locally.` |
| 0:44.5–0:50.5 | Weeks list/detail와 no-streak/no-account | `Each week stays easy to revisit, with no streak, backlog, or account.` |
| 0:50.5–0:57.5 | Privacy와 local reminder Settings | `An optional Monday reminder is scheduled on device, and the privacy boundary stays visible.` |
| 0:57.5–1:07.5 | Plus paywall, 현지화 price, restore, RevenueCat | `Two albums are free. Then a one-time lifetime purchase, powered by RevenueCat, unlocks future weeks—no subscription.` |
| 1:07.5–1:12 | approved wordmark + exact-seven rainbow stitches | `Weekkeep. A week worth keeping.` |

Canonical final composition/project는 `videos/weekkeep-remotion/`의 `WeekkeepShipaton72`입니다. 계약은 1920×1080, 30fps, 2160 frames, 정확히 72.00초, 10 scenes와 scene boundary마다 restrained 12-frame fade, 승인된 `audio_meta.json`에서 파생된 23 semantic caption groups입니다. `npm run check`와 `npx remotion compositions src/index.ts`가 이 로컬 composition 계약을 검증하며, approved final MP4 full decode와 current-source cut/caption QA가 완료되었습니다. 승인된 72-second MP4는 변경하지 않았고, GitHub Release [backup](https://github.com/kimsol1134/weekkeep/releases/tag/shipaton-demo-v1) 및 [direct asset](https://github.com/kimsol1134/weekkeep/releases/download/shipaton-demo-v1/weekkeep-shipaton-72.mp4)은 각각 HTTP 200으로 확인되었으며 asset SHA256 `9d4afb5332d3bbaeb0fc40e5d1d71c6a66b7cf2d72b79ed8a7ab3c2864e5a01a`가 보호된 승인 MP4와 일치하지만 공식 YouTube/Vimeo gate를 충족하지 않습니다. `videos/weekkeep-shipaton/`은 source media와 license/provenance origin만 보유하며 `scripts/validate-provenance.sh`의 실행 대상입니다. 공개 YouTube/Vimeo upload, 로그아웃 재생 확인, 실기기 functioning footage 교체는 pending입니다. 엔드카드에는 음성·자막을 바꾸지 않고 `RevenueCat Design Award · HAMM Award`라는 단일 restrained category cue만 표시합니다.

## 8. Build in Public — 부모 문제 중심 plan

### 원칙

- `193 commits`, 사용한 모델 수, 생성한 코드 줄 수를 headline으로 쓰지 않습니다.
- 부모가 답할 수 있는 질문, 실제 screen, 받은 반응, 그 반응으로 바꾼 결정을 한 post 안에서 연결합니다.
- audience size보다 feedback→product change의 선명도를 목표로 합니다.
- 한국어 post는 Devpost에 영어 요약을 함께 제공합니다.
- 모든 관련 post에 `#Shipaton`을 넣고 필요할 때 `#BuildInPublic`을 추가합니다.

### 공개 evidence sequence

| 순서 | 공개할 이야기 | 질문/CTA | 제품에 반영할 evidence |
|---:|---|---|---|
| 1 | `사진은 많은데 정리할 시간은 없으니까` 문제와 7장 prototype | 부모라면 5/7/10장 중 무엇이 부담 없나? | 선택과 이유, `H-002` |
| 2 | “매일 쓰지 않아도 되는 앱”과 weekly completion window | 어느 요일·시간에 1분을 낼 수 있나? | 월요일 20:30 copy/timing |
| 3 | select→replace screen recording | 교체 방법을 설명 없이 찾는가? | 실제 interaction/copy 변경 |
| 4 | 사진 on-device 처리와 로컬 보존 한계 | 신뢰에 필요한 설명은 무엇인가? | privacy copy 이해도 |
| 5 | 두 번 무료 뒤 $19.99 lifetime | 구독과 평생 이용권 중 무엇이 맞는가, 왜인가? | pricing objection·packaging |
| 6 | App Store 공개와 실제 첫 cohort | 무엇을 출시했고 무엇을 아직 약속하지 않는가? | installs, activation, feedback |
| 7 | Shipaton retrospective | 공개 피드백으로 바뀐 세 가지 | post link→commit/screen evidence |

각 post는 게시 URL, UTC timestamp, 핵심 반응 수, 채택한 feedback, 바뀐 화면/문구 링크를 `evidence/build-in-public.csv`에 기록합니다. 디렉터리와 CSV는 첫 게시 시 생성합니다.

### 피해야 할 headline

```text
I Made 193 Commits in Seven Days—and Still Didn't Ship
```

### 사용할 수 있는 headline 방향

```text
Parents don't need another photo-organizing project. They need one quiet minute.
```

```text
What if a family photo app was designed to be opened once a week?
```

```text
Seven photos, no streaks: the constraint we're testing for Weekkeep.
```

실제 인터뷰나 poll 결과가 없는 상태에서 `parents chose`라고 단정하지 않습니다. 검증 전에는 질문형 또는 `the constraint we're testing`으로 씁니다.

### #BuildInPublic submission block — English (supporting; gated)

상태: `NOT SUBMISSION-READY — this supporting category is excluded until public links and verified feedback-to-change evidence exist.` 이 category는 public links와 public building이 앱을 어떻게 개선했는지에 대한 짧은 설명을 모두 요구합니다. 현재 package에는 public feedback, public post, 또는 그 결과를 주장하는 문구를 포함하지 않습니다.

```text
Excluded from the current submission pending public links and verified feedback-to-change evidence. No public build claim is made here.
```

제출 전 gate: public links가 로그인 없이 열리고, feedback→change 연결이 확인된 뒤에만 이 category를 `Validated`로 바꿉니다.

### Grand Prize submission block — English (stretch; conditional)

상태: `NOT SUBMISSION-READY — stretch category; submit only after the public release and launch/growth metrics are verified.` Grand Prize는 현재 Focus가 아니며, 아래 수치를 채우기 위해 placeholder를 추정하지 않습니다.

```text
Weekkeep launched publicly in the United States on [INSERT FIRST PUBLIC RELEASE UTC TIMESTAMP WITHIN THE SUBMISSION WINDOW], after being fully published in the eligible App Store. It turns a crowded camera roll into up to seven family moments in one quiet weekly review, while keeping photo processing on device.

Verified launch and growth evidence for [INSERT UTC MEASUREMENT WINDOW]:
- Public release and store URL: [INSERT VERIFIED URL AND RELEASE RECORD]
- App installs or first-time downloads: [INSERT VERIFIED NUMBER AND SOURCE]
- First weekly album completion: [INSERT VERIFIED NUMBER / DENOMINATOR]
- Return or second eligible-week completion: [INSERT VERIFIED NUMBER / DENOMINATOR]
- Third-album paywall reached: [INSERT VERIFIED NUMBER / DENOMINATOR]
- Weekkeep Plus purchases and gross revenue: [INSERT VERIFIED NUMBERS, CURRENCY, AND SOURCE]

These results show [INSERT concise, evidence-backed growth or product outcome]. We report the measurement window and denominators so the result is reproducible and do not mix fixture tests with live launch metrics.
```

제출 전 gate: release date가 공식 창 안에 있고, US download/store evidence와 release/growth metrics가 모두 `Validated`일 때만 제출합니다.

### Most Viral App (Noise) submission block — English (conditional; gated)

상태: `NOT SUBMISSION-READY — omit this category unless a live Noise campaign/account was actually used and measured.` Noise integration, campaign, or metric을 만들기 위해 Weekkeep scope를 확장하지 않습니다.

```text
Weekkeep used a live Noise campaign at [INSERT PUBLIC CAMPAIGN LINK OR VERIFIED ACCOUNT REFERENCE] during [INSERT UTC CAMPAIGN WINDOW]. The campaign asked parents to share the problem of unfinished family photo memories, not private photo content.

Measured campaign evidence:
- Reach/impressions: [INSERT VERIFIED NUMBER AND SOURCE]
- Shares or invitations: [INSERT VERIFIED NUMBER AND DENOMINATOR]
- Attributed visits or installs: [INSERT VERIFIED NUMBER AND ATTRIBUTION METHOD]
- Viral or referral conversion: [INSERT VERIFIED RATE AND DENOMINATOR]

The campaign changed [INSERT documented product or messaging learning], supported by [INSERT public or consented evidence link].
```

제출 전 gate: live Noise campaign/account 사용과 측정 결과가 외부 evidence로 확인된 경우에만 `Validated`; 그렇지 않으면 `Exclude from submission`으로 유지합니다.

## 9. Launch evidence dashboard — post-launch metrics (excluded until evidence)

| Metric | 정의 | Source | 제출값 |
|---|---|---|---|
| First public date | US App Store에서 처음 `Ready for Distribution`이 된 UTC 시각 | App Store Connect | `[pending]` |
| Installs | 측정 창의 App Units/first-time downloads | App Store Connect | `[pending]` |
| First album completed | privacy-safe activation event 또는 beta roster | consented analytics/manual beta | `[pending]` |
| Third-album paywall reached | Welcome+W1 저장 후 자연 발생한 세 번째 target | consented analytics/manual cohort | `[pending]` |
| Paying customers | active `plus` unique purchasers | RevenueCat | `[pending]` |
| Gross revenue | RevenueCat measured revenue, currency/UTC window 명시 | RevenueCat | `[pending]` |
| Refunds | 같은 측정 창의 refund count | RevenueCat/App Store Connect | `[pending]` |
| Photo acceptance | selected_count=7 기록의 kept/7 | consented analytics/beta | `[pending]` |

PostHog를 동의 없이 켜서 숫자를 만들지 않습니다. V1 Release가 analytics off라면 App Store Connect, RevenueCat, 동의한 beta roster만 사용하고 unavailable metric은 `not collected`로 적습니다.
이 표의 bracketed values는 post-launch evidence가 확인되기 전까지 현재 제출 package에서 명시적으로 제외합니다.

## 10. 제출 직전 package

저장소 안의 출시 입력값은 [release/app-store-metadata.json](../release/app-store-metadata.json), [release/privacy-manifest.json](../release/privacy-manifest.json), [release/shipaton-manifest.json](../release/shipaton-manifest.json)에 기계 판독 가능한 형태로 고정하고 `scripts/validate-release.sh`로 검사합니다. 이 파일들은 외부 계정의 증거를 가장하지 않으며, Apple Offer Code(Devpost field의 `promo code`)·API key·비공개 사진은 계속 git 밖에 둡니다. Shipaton proof와 Remotion UI footage는 bundled `SamplePhotoFixtures`를 사용하는 `-ui-fixtures` 경로를 사용하고, App Store 6.9-inch screenshot은 `-ui-app-store-fixtures` 경로를 사용합니다. 두 캡처 모두 PhotoKit ingestion evidence가 아니며 live PhotoKit은 별도 adapter/device QA에서 검증합니다.

```text
submission/
├── app-store-url.txt
├── devpost-copy.md
├── design-award.md
├── hamm-award.md
├── peace-prize.md              # evidence가 있을 때만
├── demo-script.md
├── demo-public-url.txt
├── icon-1024.png
├── screenshot-1179x2556.png
├── judge-offer-code.txt        # 실제 code는 git 금지, 비공개 전달
├── revenuecat-evidence/
├── app-store-evidence/
└── build-in-public-links.md
```

`judge-offer-code.txt`, 실제 Offer Code, API key, App Store private key, sandbox 계정 정보는 git에 넣지 않습니다.

## 11. 최종 제출 체크리스트

- [ ] Devpost 등록과 participant form 완료
- [ ] RevenueCat project 생성, first test purchase, Store API call, first real purchase 증거
- [ ] 앱의 첫 공개 버전이 기간 안에 출시됨
- [ ] US App Store URL을 로그아웃 상태에서 열고 설치 가능
- [ ] production build의 실제 purchase/restore smoke 통과
- [ ] US everyone-eligible free IAP Offer Code for `weekkeep_plus_lifetime`가 모든 premium feature를 열고, 2026-10-13 12:00 PDT 이후까지 유효함; offer configuration과 SANDBOX 10-code batch 생성은 완료했지만 redemption은 미테스트이고, production custom code `WEEKKEEPJUDGES` 시도는 parent IAP 미승인으로 거절되어 production code는 생성되지 않았으며 app `Ready for Distribution` 및 IAP `Approved` 전까지 차단; Devpost가 요구하면 private judge field에만 전달
- [ ] icon `1024×1024`, opaque, exact-seven muted rainbow
- [ ] screenshot `1179×2556`, alpha 없음, device frame 없음
- [x] 공개 source repository URL, source availability, visible OSI-approved MIT `LICENSE`, and logged-out verification are externally verified; the manifest records the canonical URL, HTTP 200 checks, GitHub MIT recognition, and the checked timestamp
- [ ] `scripts/validate-public-source.sh` and `scripts/validate-release.sh` pass without adding secrets, private reviewer contact values, judge codes, or local evidence
- [ ] video 정확히 1:12, 필요한 실기기 evidence beat, 영어 voice-over/영문 자막, 공개 URL
- [ ] 설명의 모든 기능이 공개 build에서 재현됨
- [ ] Design/HAMM Award (Help Apps Make Money) 추가 답변이 실제 evidence와 일치
- [ ] Build in Public post URL과 feedback→change 설명 포함
- [ ] core Devpost input과 제출 대상 답변의 placeholder 0개; 조건부 category와 명시적으로 제외한 post-launch metrics는 evidence 전까지 제출하지 않음
- [ ] 사진·음악·폰트·SDK license와 인물 동의 확인
- [ ] 제출 preview를 다른 사람과 영어로 최종 검수
- [ ] 2026-09-28 15:45 KST 이전 내부 제출·receipt 저장

## 12. 공식 근거

- [Shipaton 2026 Official Rules](https://revenuecat-shipaton-2026.devpost.com/rules)
- [Shipaton FAQ](https://www.shipaton.com/faq)
- [RevenueCat Design Award](https://www.shipaton.com/categories/revenuecat-design-award)
- [HAMM Award (Help Apps Make Money)](https://www.shipaton.com/categories/hamm-award)
- [Build in Public partners](https://www.shipaton.com/build-in-public)
- [How we judge Shipaton](https://www.shipaton.com/blog/how-we-judge-shipaton)
