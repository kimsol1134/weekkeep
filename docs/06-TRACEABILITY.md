# Weekkeep Requirements Traceability & Consistency

| 항목 | 값 |
|---|---|
| 버전 | 0.5-approved |
| 기준일 | 2026-08-05 |
| 상태 | Approved |
| 구현 | Not started |

## 1. 목적

이 문서는 ‘문서를 많이 썼는가’가 아니라 아래 질문에 답합니다.

- 모든 PRD 요구사항에 사용자 흐름이 있는가?
- 모든 핵심 흐름에 화면과 상태가 있는가?
- 모든 요구사항에 구현 책임과 검증 방법이 있는가?
- 서로 다른 문서가 같은 숫자와 약속을 사용하고 있는가?

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
| `FR-009` 한 화면 검토 | UC-04, UC-06 | SCR-WK-03, SCR-WK-04 | Features/WeeklyCuration | TST-009 | Covered |
| `FR-010` 개별 교체 | UC-06 | SHEET-REP-01 | Features/WeeklyCuration | TST-010 | Covered |
| `FR-011` 취소와 재시도 | UC-04, UC-12 | SCR-WK-02, SCR-WK-03 | WeeklyFlowModel | TST-011 | Covered |
| `FR-012` 멱등 저장 | UC-07 | SCR-WK-05 | Data/Persistence | TST-012 | Covered |
| `FR-013` Weeks 보관함 | UC-08 | SCR-ARC-01, SCR-ARC-02 | Features/Archive | TST-013 | Covered |
| `FR-014` 원본 변경 처리 | UC-08, UC-12 | SCR-ARC-01, SCR-ARC-02 | Photos + Archive | TST-014 | Covered |
| `FR-015` 로컬 알림 | UC-09 | SHEET-NOT-01, SCR-WK-01 | Integrations/Notifications | TST-015 | Covered |
| `FR-016` 무료 한도/Plus gate | UC-05, UC-10 | SCR-WK-01, SHEET-PAY-01 | Domain/Policy + Paywall | TST-016, TST-033 | Covered |
| `FR-017` 구매/복원 | UC-10, UC-11 | SHEET-PAY-01, SCR-SET-01 | Integrations/Purchases | TST-017 | Covered |
| `FR-018` Settings | UC-03, UC-11, UC-13 | SCR-SET-01–03 | Features/Settings | TST-018 | Covered |
| `FR-019` privacy analytics | UC-02, UC-04, UC-06, UC-07, UC-10 | all measured surfaces | Integrations/Analytics | TST-019 | Covered |
| `FR-020` 한국어/영어 | all | all | Resources + all features | TST-020 | Covered |
| `FR-021` 오류 회복 | UC-12 | affected screens | Domain/Errors + features | TST-021, TST-033 | Covered |
| `FR-022` 로컬 보존 범위 안내 | UC-08, UC-11, UC-13 | SCR-ARC-01, SCR-SET-01/02, SHEET-PAY-01 | Persistence + Settings + Paywall | TST-032 | Covered |

현재 `MISSING` 기능 요구사항: **0**

## 3. 비기능 요구사항 추적

| Requirement | Technical control | Verification | Test |
|---|---|---|---|
| `NFR-001` Privacy | network boundary, event allowlist, replay off | proxy audit + schema snapshot | TST-022 |
| `NFR-002` Performance | 100 cap, downsample, bounded concurrency, signposts | device benchmark | TST-023 |
| `NFR-003` Accessibility | semantic custom-font styles/actions, Reduce Motion | Inspector + manual matrix | TST-024, TST-035 |
| `NFR-004` Offline core | local Photo/SwiftData; cached entitlement | airplane-mode flow | TST-025 |
| `NFR-005` Reliability | unique weekKey, transaction upsert, rollback | race/failure injection | TST-026 |
| `NFR-006` Swift concurrency | actor isolation, Sendable values | strict build + concurrency tests | TST-027 |
| `NFR-007` Battery/thermal | target-size images, concurrency backoff | Instruments/thermal run | TST-028 |
| `NFR-008` Maintainability | protocol adapters, pure engine | dependency boundary lint/review | TST-029 |
| `NFR-009` App size | no bundled ML model in V1, dependency audit | archive size report | TST-030 |
| `NFR-010` Localization | String Catalog, format styles | key lint + pseudo localization | TST-031 |

## 4. Shipaton/사업 요구사항 추적

| Requirement | 구현/산출물 | 검증 증거 | Coverage |
|---|---|---|---|
| `BR-001` 첫 공개 릴리스 | 신규 bundle/앱 레코드 | App Store public URL | Covered |
| `BR-002` RevenueCat 실제 구매 | PurchaseClient + offering | dashboard + sandbox/TestFlight recording | Covered |
| `BR-003` US availability | App Store territories | storefront check | Covered |
| `BR-004` <2분 공개 데모 | demo script/video | public video duration/URL | Covered |
| `BR-005` 아이콘/screenshot 규격 | design export checklist | 1024 asset + 1179×2556 file | Covered |
| `BR-006` 무료 접근 수단 | free album allowance/promo note | clean install judge flow | Covered |
| `BR-007` 영어 제출 | en localization/metadata | native-language review | Covered |
| `BR-008` 마감 | internal T-72h cutoff | submission receipt | Covered |

## 5. Test Specification Catalog

| ID / 종류 | 검증 내용 | 성공 조건 |
|---|---|---|
| `TST-001` UI | clean install Welcome | 한 화면에서 가치/privacy/CTA, 다른 권한 요청 없음 |
| `TST-002` Integration | Photos request timing | user CTA 전 system prompt 0회 |
| `TST-003` UI/Integration | full/limited/denied/restricted | 각 상태에 정확한 UI와 recovery |
| `TST-004` Unit | week range fixtures | 연말/DST/timezone, 월요일 open·다음 월요일 close, latest-only, in-flight weekKey pin 기대값 일치 |
| `TST-005` Unit/Integration | asset filtering/sampling | 범위 밖·screenshot·hidden 없음, max 100 |
| `TST-006` Integration | on-device pipeline | 네트워크 없이 local 사진 분석 가능 |
| `TST-007` Unit | selection invariant | selected ≤7, alternatives ≤7, 교집합 0 |
| `TST-008` UI | 0/1/6 photo | backfill/가짜 slot 없이 실제 상태 표시 |
| `TST-009` UI/Usability | review/viewer | 첫 tap은 선택·교체 action reveal만, 선택 photo 두 번째 tap은 viewer, swipe/dismiss current index 유지, VoiceOver direct view/replace, 선택 없이 CTA 1회 저장, 활성 검토 중앙값 ≤60초 |
| `TST-010` UI/Unit | replace | 선택 또는 direct action의 정확한 한 위치만 변경, 중복 0, cancel 무변경 |
| `TST-011` Integration | cancel/retry | Photos/Vision task 취소, 같은 range 재시도 |
| `TST-012` Integration | double save/upsert | 같은 weekKey row 1개, count 1회 |
| `TST-013` UI/Integration | archive | 최신순 list, detail, empty state |
| `TST-014` Integration/UI | deleted/revoked asset | crash 0, placeholder, silent substitute 0 |
| `TST-015` Integration | notification | first save 후만 prompt, Monday 20:30, 정확한 reminder copy, 직전 완료 주 deep link |
| `TST-016` Unit/UI | free gate | album 0/1 create, album 2+eligible photo locks, album 2+zero photo는 empty state, archive always open |
| `TST-017` Integration/UI | product/purchase matrix | non-consumable lifetime→`plus` mapping, US $19.99 기준·자동 등가 storefront·현지화 가격, success/cancel/pending/fail/restore 상태 일치 |
| `TST-018` UI | Settings state | Photos/notification/Plus 현재값과 진입점 |
| `TST-019` Unit/Manual | analytics allowlist | 금지 key compile/test 실패, photo payload 0 |
| `TST-020` UI | ko/en localization | missing key/truncation 0 |
| `TST-021` UI/Integration | error recovery | 각 오류에 올바른 next action, draft 보존 |
| `TST-022` Manual/Automated | privacy network audit | vendor request에 사진 관련 값 0 |
| `TST-023` Performance | 30/50/100 fixtures | PRD budget 또는 승인된 scope reduction |
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
| `TST-034` Unit/Snapshot | SevenStitchRail invariant | 모든 크기·색·선택·progress·vertical 상태에서 slot/capsule count 정확히 7, filled+remaining=7 |
| `TST-035` UI/Bundle | LINE Seed registration + Dynamic Type | Regular/Bold PostScript name resolve, system fallback 0, Accessibility 5에서 clipping/blocker 0 |

## 6. 화면–컴포넌트 추적

| Screen | Required components | State coverage |
|---|---|---|
| `SCR-ONB-01` | CMP-01, CMP-03, CMP-04 preview, CMP-12 | idle/requesting/returning |
| `SCR-WK-01` | CMP-01, CMP-08, CMP-09, CMP-10, CMP-12 | loading/permissionBlocked/error/welcomePending/preRegularWaiting/saved/noEligiblePhotos/entitlementLocked/ready |
| `SCR-WK-02` | CMP-02, CMP-07, CMP-11, CMP-12 | fetch/iCloud/analyze/rank/partial/cancel/error |
| `SCR-WK-03` | CMP-01, CMP-04, CMP-05, CMP-11, CMP-12 | review(unselected/selected)/viewer/replace/save/saveError/missing |
| `SCR-WK-04` | CMP-05 + viewer chrome | load/available/missing |
| `SCR-WK-05` | CMP-01, CMP-04, CMP-12 | saved/firstSave |
| `SHEET-REP-01` | CMP-02, CMP-05, CMP-08 | candidates/empty/missing |
| `SHEET-NOT-01` | CMP-01, CMP-02 | undetermined/requesting/resolved |
| `SHEET-PAY-01` | CMP-01, CMP-02, CMP-10, CMP-11 | load/ready/purchase/pending/fail/restore/entitled |
| `SCR-ARC-01` | CMP-06, CMP-08, CMP-12 tab | empty/list/missingCover/error |
| `SCR-ARC-02` | CMP-04, CMP-05 | available/partial/allMissing |
| `SCR-SET-01` | CMP-09, CMP-10, CMP-12 tab | all permission/entitlement states |
| `SCR-SET-02` | text/link patterns | local storage/disclosure/online policy link |
| `SCR-SET-03` | native list rows | support/link unavailable |

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
| 아이 신원 식별 금지 | non-goal/FR-007 | copy/flow | pipeline prohibition | voice/icon/accessibility | ALIGNED |
| 사진 외부 전송 금지 | FR-006/019 | event table | trust boundary | PrivacyBadge | ALIGNED |
| local-only V1과 보존 한계 | scope/FR-022/NFR-004 | UC-08/11/13, IA Privacy | ADR-004/011, durability boundary | Settings/paywall privacy copy | ALIGNED |
| first 2 albums free | FR-016 | UC-10 | entitlement policy | paywall | ALIGNED |
| lifetime product·localized price | FR-017 | UC-10/IA paywall | V1 상품 구성 계약 | CMP-10 | ALIGNED |
| RevenueCat | BR-002/FR-017 | UC-10/11 | PurchaseClient | PlusCard | ALIGNED |
| 알림은 첫 저장 후 | FR-015 | UC-09 | UserNotifications | reward-before-request | ALIGNED |
| 알림은 월요일 20:30 reminder | FR-015 | UC-09/IA flow | foreground-only schedule | honest copy | ALIGNED |
| 분석 전 준비 완료 주장 금지 | D-017/FR-015 | SCR-WK-01 ready → WK-02 | ADR-005 | ready copy/uncurated photo stack | ALIGNED |
| 3 top-level tabs | scope | IA App Shell | AppTab | native shell | ALIGNED |
| 7장 hero+2+4·adaptive fallback | D-024 | SCR-WK-03 | ADR-012/WeeklyPhotoGrid | V2 screen set/Layout System | ALIGNED |
| Light only | D-026 | all screens | theme configuration | V2 screen set/QA matrix | ALIGNED |
| LINE Seed Sans KR | D-027 | all screens | bundled TTF registration | typography tokens/V2 screens | ALIGNED |
| SevenStitchRail count = 7 | D-028 | ONB/WK/ARC/SET | deterministic SwiftUI component | CMP-12/vector assets | ALIGNED |
| Review photo tap과 접근성 action | FR-009/010, D-029 | UC-06/WK-03/WK-04 | explicit selectedIndex/destination reducer | CMP-04/05, VoiceOver custom action | ALIGNED |
| iOS 18+ | NFR/platform | 해당 없음 | ADR-002 | current iOS patterns | ALIGNED |
| 한국어/영어 | FR-020 | accessibility copy | String Catalog | localization | ALIGNED |

### 공개 충돌 목록

| ID | 범위 | 충돌 | 영향 | 상태 |
|---|---|---|---|---|
| `CF-001` | Design source | Design Guide/App Screens V1과 Design Review V2·V2 이미지의 layout·서체·탭·알림·progress·photo gesture 표현이 일치하지 않았음 | `design/README.md`를 단일 진입점으로 지정하고 V2를 current baseline, V1·탐색안을 비규범 archive로 격리; `D-024`, `D-026`–`D-029`와 FR/UC/IA/TRD/TST 계약으로 통합 | `Resolved 2026-08-05` |

현재 공개 `CONFLICT`: **0 OPEN**. 디자인 기준선과 상호작용 결정이 모두 Approved이므로 `GATE-10`은 Ready입니다.

## 8. 구현 전 Gate — Decision Registry의 파생 뷰

Gate는 결정값이나 승인 상태를 소유하지 않습니다. [Decision Registry](00-INDEX.md#5-decision-registry--결정값과-상태의-ssot)의 연결 Decision이 모두 `Approved` 이상이고 공개 conflict가 없으면 `Ready`, 아니면 `Open`으로 계산합니다.

| Gate | 확인 범위 | Decision dependencies | 추가 조건 | 파생 판정 |
|---|---|---|---|---|
| `GATE-01` | 플랫폼 | `D-003` | — | `Ready` |
| `GATE-02` | 선택 상한 | `D-004`, `D-005` | — | `Ready` |
| `GATE-03` | Regular Week와 리마인더 | `D-009`, `D-012`, `D-013` | `TST-004`, `TST-015` 정의 | `Ready` |
| `GATE-04` | 놓친 주 처리 | `D-015` | `TST-004` 정의 | `Ready` |
| `GATE-05` | 무료 한도 | `D-008` | `H-003` 자연 발생 세 번째 기록 cohort 계획 | `Ready` |
| `GATE-06` | 상품·가격 | `D-023` | `TST-017` product/purchase matrix 정의; 실제 App Store/RevenueCat 구성은 M4 증거 | `Ready` |
| `GATE-07` | persistence·보존 한계 | `D-007`, `D-021`, `D-022` | `TST-025`, `TST-032` 정의 | `Ready` |
| `GATE-08` | analytics provider | `D-019` | deny-by-default config, `TST-019`·`TST-022` payload audit 계획 | `Ready` |
| `GATE-09` | project generation | `D-020` | Engineering owner, 2.46.0 pin, CI generation/build 계약 | `Ready` |
| `GATE-10` | layout·시각·review 상호작용 기준 | `D-024`, `D-026`, `D-027`, `D-028`, `D-029` | 공개 design conflict 0, `TST-009`, `TST-010`, `TST-034`, `TST-035` 정의 | `Ready` |
| `GATE-11` | 원격 푸시 제외 | `D-009`, `D-025` | capability audit | `Ready` |

현재 구현 전 Gate는 **11 Ready / 0 Open**입니다. 이는 결정과 검증 계약이 구현 기준으로 준비됐다는 뜻이며, 앱 코드·유료 계약·App Store product·RevenueCat offering이 이미 생성됐다는 뜻은 아닙니다. 그 실행 증거는 Delivery Plan의 M4와 release gate에서 확인합니다.

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
| layout·font·photo gesture 변경 | `D-024`, `D-026`–`D-029` → PRD/UC → IA → TRD → Design SSOT/Guide → `TST-009/010/034/035` |

## 10. 구현 진행 상태 표기

각 requirement의 lifecycle은 [공통 상태 정의](00-INDEX.md#4-상태-정의)만 사용합니다.

```text
Draft → Proposed → Approved → Implemented → Validated
```

- `Implemented`: production code 존재
- `Validated`: 연결된 TST가 통과하고 증거 링크 존재
- public build 확인 여부는 lifecycle 상태가 아니라 별도 release evidence 링크로 기록

코드가 생기면 `Technical owner`를 실제 파일 링크로 바꾸고 `Test`에 실제 test method/CI run을 연결합니다.

## 11. 문서 승인 체크리스트

- [x] Decision Registry의 모든 구현 의존 Decision이 `Approved` 이상
- [x] GATE-01–11 중 `Open` 0
- [x] FR-001–022 중 MISSING 0
- [x] NFR-001–010 모두 검증 방법 존재
- [x] BR-001–008 모두 산출물/증거 정의
- [x] 화면 인벤토리와 Use Case의 화면 ID 불일치 0
- [x] 컴포넌트 인벤토리와 Design Guide ID 불일치 0
- [x] 공개 cross-document `CONFLICT` 0
- [x] P0 test specification 누락 0
- [x] 승인 날짜와 문서 version 갱신
