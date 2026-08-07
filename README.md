# Weekkeep

> 아이와 보낸 일주일, 사진 7장으로 남겨요.  
> Keep your week in seven photos.

Weekkeep은 바쁜 부모가 매주 사진첩을 다시 뒤지지 않아도, 기기가 먼저 제안한 지난 일주일의 가족 사진 최대 7장을 1분 안에 확인하고 하나의 주간 기록으로 남기게 돕는 iPhone 앱입니다.

현재 단계는 **Implementation / release review pending**입니다. App Store Connect build 6 (`1.0.0 (6)`, `0ffa7586-619f-4df9-abc5-ae7ebbd068b1`)이 `VALID` 처리되어 version `ac4f183e-1019-4ffc-827f-f5514f0d349b`에 첨부되었고, manual release의 current review submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00`은 `WAITING_FOR_REVIEW`입니다. TestFlight `Weekkeep Internal QA` 그룹에는 `READY_FOR_BETA_TESTING` build 6과 초대된 verified account-holder tester 1명이 있으며, internal distribution은 ready/invited 상태일 뿐 설치·purchase·restore test는 아직 확인하지 않았습니다. builds 1–5는 historical/non-target evidence로 분리하며, build 4는 `VALID`/미첨부 상태입니다. build 6의 `WeekkeepTests`는 122/122, 일반 `WeekkeepUITests`는 12/12 통과했고 opt-in 캡처 테스트는 설계대로 제외/skip되었습니다. 알림 집중 테스트는 21/21, build-6 bilingual notification-settings capture는 2/2 통과했습니다. 공개 GitHub 저장소 [kimsol1134/weekkeep](https://github.com/kimsol1134/weekkeep)의 source availability와 logged-out verification은 2026-08-07에 검증되었고, 공식 YouTube demo upload와 logged-out playback/duration verification은 `Validated`입니다. App Review/public release, RevenueCat sandbox purchase/restore와 judge redemption, target-device footage, Devpost receipt는 아직 외부 게이트로 남아 있습니다. 이 상태는 App Store 승인이나 공개 출시를 주장하지 않습니다. 세부 evidence와 blocker 상태는 [traceability](docs/06-TRACEABILITY.md#12-release-blockers--완료-전-implemented로-닫지-않음)에서 추적합니다.

## 문서

| 순서 | 문서 | 질문 |
|---|---|---|
| 0 | [문서 인덱스·Decision Registry](docs/00-INDEX.md) | 어떤 문서가 무엇을 소유하고 어떤 결정이 승인됐는가? |
| 1 | [PRD](docs/01-PRD.md) | 누구의 어떤 문제를 어떤 범위로 해결하는가? |
| 2 | [Use Cases](docs/02-USE-CASES.md) | 사용자는 실제로 어떤 경로와 예외를 겪는가? |
| 3 | [IA](docs/03-IA.md) | 정보와 화면, 상태, 내비게이션은 어떻게 구성되는가? |
| 4 | [TRD](docs/04-TRD.md) | 그 경험을 안전하고 현실적으로 어떻게 구현하는가? |
| 5 | [Design Guide](docs/05-DESIGN-GUIDE.md) | Weekkeep답게 보이고 느껴지는 기준은 무엇인가? |
| 6 | [Traceability](docs/06-TRACEABILITY.md) | 요구사항·화면·기술·테스트가 빠짐없이 연결되는가? |
| 7 | [Delivery Plan](docs/07-DELIVERY-PLAN.md) | 언제 무엇을 만들고 어떤 기준으로 출시하는가? |
| — | [Design SSOT](design/README.md) | 승인된 디자인 기준을 관심사별로 어디에서 확인하는가? |
| — | [V2 Design Review](docs/08-DESIGN-REVIEW-V2.md) | 부모와 Shipaton 심사 관점에서 무엇을 개선했는가? |
| 9 | [App Privacy Label](docs/09-APP-PRIVACY-LABEL.md) | App Store privacy 답변과 실제 Release collection이 일치하는가? |
| 10 | [App Store Metadata](docs/10-APP-STORE-METADATA.md) | 스토어에 어떤 이름·설명·IAP·심사 메모를 입력하는가? |
| 11 | [Shipaton Submission](docs/11-SHIPATON-SUBMISSION.md) | 어떤 카테고리·영상·증거로 제출하는가? |
| — | [V2 App Screens](design/app-screens-v2/README.md) | 승인된 14개 happy-path 화면은 어떻게 보이는가? |
| — | [Visual Concepts](design/concepts/README.md) | 폐기된 5개 초기 탐색 방향은 무엇이었는가? |

## 승인된 제품 결정 요약

아래는 빠른 진입을 위한 요약이며 결정값과 상태의 SSOT는 [Decision Registry](docs/00-INDEX.md#5-decision-registry--결정값과-상태의-ssot)입니다.

## 오픈 소스와 라이선스

Weekkeep의 공개 소스 배포 기준은 저장소 루트의 [MIT License](LICENSE)이며, 저작권 표기는 `© 2026 Sol Kim`입니다. 공개 저장소는 [https://github.com/kimsol1134/weekkeep](https://github.com/kimsol1134/weekkeep)으로 확인되었고, 로그아웃 상태에서 repository와 raw `LICENSE`가 HTTP 200으로 접근되며 GitHub가 root `LICENSE`를 MIT로 인식하는 것을 확인했습니다. 공개 소스 gate는 `Validated`이고, App Review·스토어 공개·구매·Shipaton 제출 상태와는 별개입니다.

공개 소스 검사는 다음 명령으로 실행합니다.

```sh
scripts/validate-public-source.sh
```

## Build locally

Prerequisites:

- macOS with Xcode and an iOS 18+ Simulator runtime. `project.yml` targets iOS 18.0; it does not pin an Xcode patch version. The current local validation baseline used Xcode 26.6 (build 17F113).
- XcodeGen **2.46.0**, which `scripts/validate-release.sh` enforces. Verify with `xcodegen --version`.
- `git`, `jq`, `rg`, `xmllint`, `node`, `npm`, and `npx`; `xcodebuild`, `xcrun`, `plutil`, and `sips` come with Xcode and are also checked by release validation.

Clone the repository, then generate the ignored Xcode project from the SSOT:

```sh
git clone https://github.com/kimsol1134/weekkeep weekkeep
cd weekkeep
xcodegen --version
xcodegen generate --spec project.yml
```

The iOS build does not need Node dependencies. If you also run the release validator's canonical Remotion checks, install that project's checked-in lockfile dependencies once:

```sh
(cd videos/weekkeep-remotion && npm ci)
```

For a local configuration file, copy the safe example and edit only the ignored copy:

```sh
cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig
```

The example contains no service credentials. Its RevenueCat SDK key and PostHog token are blank. A blank RevenueCat key keeps `AppEnvironment` on `DisabledPurchaseClient`, even if the Release flag says purchases are enabled, so the app can build and local fixture tests can run but a real purchase smoke test cannot pass. A RevenueCat mobile SDK key is public-client configuration, not a server secret; keep it in the ignored file for environment separation and never add private server credentials. Analytics remains disabled by the checked-in defaults.

Build and run the ordinary simulator suite with an available device/runtime:

```sh
xcodebuild -project Weekkeep.xcodeproj -scheme Weekkeep \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build

xcrun simctl list devices available
xcodebuild -project Weekkeep.xcodeproj -scheme Weekkeep \
  -destination 'platform=iOS Simulator,name=<available-device>,OS=<available-runtime>' \
  test
```

The opt-in App Store screenshot and Remotion-footage capture tests are not part of the ordinary test result; use their dedicated scripts only when intentionally producing local evidence.

Run the public-source and release gates from the repository root:

```sh
scripts/validate-public-source.sh
scripts/validate-localization.sh
scripts/validate-release-assets.sh
scripts/validate-release.sh
git diff --check
```

`scripts/validate-release.sh --build` additionally performs the generic iOS Simulator Release build. `--strict` is for a later authenticated release state and is expected to report the remaining store and other external blockers. Generated `Weekkeep.xcodeproj` and all local credentials/evidence remain uncommitted.

- 대상: 0–6세 아이를 둔, 사진은 많이 찍지만 기록은 꾸준히 못 하는 iPhone 사용자
- 핵심 루프: 주간 사진 수집 → 기기 내 분석 → 최대 7장 검토/교체 → 주간 기록 저장 → branded Story/Post 공유 (`D-004`, `D-005`, `D-034`)
- 첫 경험: 최근 7일의 사진으로 즉시 만드는 `Welcome Week`
- 반복 기준: 완료된 월–일 기록을 다음 월–일 동안 저장 (`D-012`)
- 기본 리마인더: 월요일 20:30 로컬 알림, 이미 준비됐다는 표현 없이 앱으로 초대 (`D-009`, `D-013`)
- 반복 경험: 초안을 확인하며 활성 조작 목표는 분석 대기 제외 60초 이하 (`D-014`)
- 놓친 주: streak·밀린 목록 없이 가장 최근 완료 주 하나부터 다시 시작 (`D-015`)
- 프라이버시: 사진 분석과 사진 식별자는 기기 밖으로 보내지 않음 (`D-006`)
- 플랫폼: iPhone, iOS 18 이상 (`D-003`)
- 승인 디자인: Light only, LINE Seed Sans KR, hero+2+4/adaptive grid, code-rendered exact-7 stitch (`D-024`, `D-026`–`D-028`)
- Review 상호작용: 첫 tap은 사진 선택·교체 action 노출, 선택된 사진의 두 번째 tap은 viewer; 접근성은 직접 action 제공 (`D-029`)
- App icon and in-app rails: same index-ordered muted seven-stitch palette; rail state uses opacity and geometry rather than tone-specific single colors (`D-030`)
- Brand mark: onboarding and compact in-app surfaces use the canonical lowercase Plum wordmark resource; web/Shipaton may use the external exact-seven lockup (`D-031`)
- V1 저장: 현재 iPhone 앱에 로컬 저장하며 앱 자체 백업·기기 간 복원을 제공하지 않아 앱 삭제·기기 변경 시 사라질 수 있음 (`D-007`, `D-021`, `D-022`)
- 수익화: Welcome 포함 저장 기록 2개 무료, 사진이 있는 세 번째 미저장 기록 생성부터 Plus; 비소모성 평생 이용권 US 기준 $19.99·storefront 자동 현지화 (`D-008`, `D-023`)
- Shipaton 필수 연동: RevenueCat 구매 흐름

## 문서 변경 규칙

1. 결정의 값이나 상태는 `docs/00-INDEX.md`의 Decision Registry에서만 바꾼다.
2. 기능 범위 변경은 PRD에서 먼저 승인한다.
3. 사용자 흐름 변경은 Use Case와 IA를 함께 바꾼다.
4. 구현 방식 변경은 TRD에 이유와 영향을 기록하되 승인 상태를 중복 기록하지 않는다.
5. 요구사항 ID를 삭제하지 않는다. 폐기 시 `Deprecated`로 남긴다.
6. 코드 구현 전 [Traceability](docs/06-TRACEABILITY.md)의 `MISSING`과 공개 `CONFLICT`를 확인한다.

Codex와 Claude Code는 각각 [AGENTS.md](AGENTS.md)와 [CLAUDE.md](CLAUDE.md)를 진입점으로 사용하며, 두 도구 모두 같은 문서와 제품 계약을 따릅니다.

## 상태

- 문서 버전: `0.5-approved`
- 기준일: `2026-08-05`
- 제품 공동 책임: Kim Sol + Codex
- 최근 로컬 검증: ASC build 6, `WeekkeepTests` 122/122, 일반 `WeekkeepUITests` 12/12, focused notification tests 21/21, bilingual notification-settings capture 2/2; localization, release-assets, public-source, `scripts/validate-release.sh --build`, `git diff --check` 통과
- 외부 상태: ASC build 6은 `VALID`/version 첨부, current review submission은 `WAITING_FOR_REVIEW`, TestFlight Internal QA distribution은 `READY_FOR_BETA_TESTING`/`INVITED`만 확인, builds 1–5는 historical/non-target이며 build 4는 `VALID`/미첨부. 공개 GitHub source availability·logged-out verification과 공식 YouTube demo·logged-out playback/duration verification은 `Validated`이고, App Review 승인/public release와 RevenueCat purchase/restore, judge, target-device, Devpost receipt 등 Shipaton external gates는 pending
