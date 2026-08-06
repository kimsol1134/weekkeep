# Weekkeep 문서 인덱스

| 항목 | 값 |
|---|---|
| 문서 버전 | 0.5-approved |
| 기준일 | 2026-08-05 |
| 상태 | Approved |
| 단계 | Implementation |
| 제품 책임 | Kim Sol + Codex |
| Canonical repository | `/Users/solkim/Dev/weekkeep` |

## 1. 제품 정의 한 장 요약

### 제품 문장

**Weekkeep은 바쁜 부모가 기기가 먼저 제안한 지난 일주일의 가족 사진 최대 7장을 1분 안에 확인하고 주간 기록으로 남기게 해주는, 프라이버시 중심 iPhone 앱이다.**

### 핵심 약속

- 사진을 더 정리하라고 요구하지 않는다.
- AI가 결정을 빼앗지 않고 첫 선택을 대신 준비한다.
- 사용자는 7장을 확인하고 마음에 들지 않는 사진만 교체한다.
- 사진은 가능한 한 기기 안에서만 처리한다.
- 저장 후 실제 사진으로 만든 로컬 공유 이미지를 명시적 사용자 행동으로 내보내 한 주의 결과를 보상한다.
- 매주 작은 기록 하나가 쌓이는 경험에만 집중한다.

### 핵심 지표

`Weekly Memory Completed`  
사용자가 하나의 주간 기록을 검토하고 저장한 사건입니다.

## 2. 문서별 단일 책임과 SSOT

문서 전체에 일률적인 우선순위를 두지 않습니다. 같은 사실을 여러 문서가 소유하지 않도록 아래 책임별 원본을 따릅니다.

| 기준 문서 | 유일하게 소유하는 것 | 소유하지 않는 것 |
|---|---|---|
| 이 문서 | 문서 지도, ID·상태 체계, Decision Registry, 가설 | 상세 사용자 흐름과 구현 방식 |
| [PRD](01-PRD.md) | 문제, 목표, V1 범위, FR/NFR/BR | 화면 전이와 기술 선택의 승인 상태 |
| [Use Cases](02-USE-CASES.md) | 사용자의 정상·대안·오류 시나리오 | UI 레이아웃과 DB 알고리즘 |
| [IA](03-IA.md) | 내비게이션, 화면 책임, 배타적 UI 상태, 제스처의 상태·화면 결과 | 제품 범위, 시각 token, persistence 구현 |
| [TRD](04-TRD.md) | 기술 계약, 데이터 모델, ADR의 기술적 결과 | 제품 결정의 승인 상태 |
| [Design Guide](05-DESIGN-GUIDE.md) | 시각 token, component 표현, motion, 접근성·copy 표현 규칙 | 제품 범위, 내비게이션, 제스처의 상태 결과, 일정 |
| [Traceability](06-TRACEABILITY.md) | ID 연결, 검증 항목, Gate의 파생 판정 | 새로운 결정값 |
| [Delivery Plan](07-DELIVERY-PLAN.md) | 일정, 담당, 단계별 증거와 출시 운영 | 제품·기술 계약의 재정의 |
| [App Privacy Label](09-APP-PRIVACY-LABEL.md) | App Store Connect privacy 답변, SDK manifest와 실제 collection의 release matrix | 제품 기능 범위와 SDK 기술 선택 |
| [App Store Metadata](10-APP-STORE-METADATA.md) | App Store 이름·설명·키워드·URL·IAP metadata·review notes | 제품 범위, 가격, privacy 답변의 재정의 |
| [Shipaton Submission](11-SHIPATON-SUBMISSION.md) | Devpost copy, category 전략, demo, Build in Public, 제출 evidence | App Store metadata와 제품 결정의 재정의 |

디자인 자료의 단일 진입점은 [Design SSOT](../design/README.md)이며, 위 기준 문서의 책임을 시각 자료에 매핑합니다.

결정의 **값과 상태는 이 문서의 Decision Registry만** 수정합니다. 다른 문서는 Decision ID를 참조하고 자기 책임에 해당하는 결과만 설명합니다. 제품 범위를 바꾸는 하위 문서는 허용하지 않습니다.

## 3. 요구사항 ID 체계

| 접두사 | 의미 | 기준 문서 | 예시 |
|---|---|---|---|
| `D` | 제품·기술 결정 | 이 문서 | `D-007` |
| `H` | 검증 전 가설 | 이 문서 | `H-003` |
| `GOAL` | 제품 목표 | PRD | `GOAL-01` |
| `FR` | 기능 요구사항 | PRD | `FR-007` |
| `NFR` | 비기능 요구사항 | PRD | `NFR-003` |
| `BR` | 사업/대회 요구사항 | PRD | `BR-002` |
| `UC` | 유스케이스 | Use Cases | `UC-06` |
| `SCR` | 화면/표면 | IA | `SCR-WK-02` |
| `TAB` | 최상위 탭 | IA | `TAB-WEEK` |
| `SHEET` | modal 표면 | IA | `SHEET-PAY-01` |
| `ADR` | 기술 결정 | TRD | `ADR-004` |
| `CMP` | 디자인 컴포넌트 | Design Guide | `CMP-03` |
| `EVT` | 분석 이벤트 | PRD/TRD | `EVT-album_saved` |
| `TST` | 검증 항목 | Traceability | `TST-012` |
| `GATE` | 구현 전 승인 묶음 | Traceability | `GATE-07` |

## 4. 상태 정의

| 상태 | 의미 |
|---|---|
| `Draft` | 논의 가능한 초안 |
| `Proposed` | 구현 후보로 구체화됨 |
| `Approved` | 코드의 기준으로 사용 가능 |
| `Implemented` | 코드와 테스트로 구현됨 |
| `Validated` | 실제 사용자/데이터로 검증됨 |
| `Rejected` | 검토 결과 채택하지 않음; 이력은 보존 |
| `Deprecated` | 더 이상 적용하지 않지만 이력 보존 |

문서, 요구사항, 결정, 가설은 위 영문 상태만 사용합니다. `확정`, `제안`, `가설`, `Accepted`, `Pending` 같은 별도 상태어를 만들지 않습니다. Gate의 `Ready/Open`은 아래 결정 상태에서 계산되는 결과이지 새로운 승인 상태가 아닙니다. 현재 0.5 기준 문서 세트는 2026-08-05 사용자 지시로 `Approved`되었고 구현 변경은 이 기준선을 따릅니다.

## 5. Decision Registry — 결정값과 상태의 SSOT

| ID | 결정의 유일한 값 | 상태 | 책임 | 승인일 | 연결 기록 |
|---|---|---|---|---|---|
| `D-001` | 제품명은 Weekkeep | `Approved` | Product | 2026-08-05 | README |
| `D-002` | 독립 프로젝트 `/Users/solkim/Dev/weekkeep` | `Approved` | Product+Engineering | 2026-08-05 | `ADR-001` |
| `D-003` | V1은 iPhone·iOS 18+ | `Approved` | Product+Engineering | 2026-08-05 | `ADR-002`, `GATE-01` |
| `D-004` | 한 기록의 결과는 1–7장 | `Approved` | Product | 2026-08-05 | `FR-007`, `FR-008` |
| `D-005` | 초기 shortlist는 선택 7장과 교체 후보 7장을 합쳐 최대 14장 | `Approved` | Product+Engineering | 2026-08-05 | `ADR-006`, `GATE-02` |
| `D-006` | 사진 데이터와 사진 식별자는 외부 분석으로 전송하지 않음 | `Approved` | Product+Engineering | 2026-08-05 | `NFR-001` |
| `D-007` | V1 persistence는 SwiftData 기기 로컬 전용이며 계정·백엔드·CloudKit을 제외 | `Approved` | Product+Engineering | 2026-08-05 | `ADR-004`, `GATE-07` |
| `D-008` | Welcome을 포함해 저장 기록 2개까지 무료이며, 사진 1장 이상인 세 번째 미저장 target의 `만들기`부터 Plus gate 적용; 기존 저장 기록 열람은 무료 | `Approved` | Product | 2026-08-05 | `H-003`, `FR-016`, `GATE-05` |
| `D-009` | V1 재방문 수단은 원격 푸시가 아닌 로컬 알림 | `Approved` | Product+Engineering | 2026-08-05 | `ADR-008` |
| `D-010` | 아이 식별과 얼굴 신원 학습을 V1에서 약속하지 않음 | `Approved` | Product | 2026-08-05 | `FR-007` |
| `D-011` | 신규 코드베이스로 구현하고 Peeka는 계약·fixture를 거친 알고리즘 참고만 허용 | `Approved` | Engineering | 2026-08-05 | `ADR-001` |
| `D-012` | Regular Week는 완료된 월–일을 다음 월요일부터 일요일까지 저장 가능 | `Approved` | Product | 2026-08-05 | `FR-004`, `GATE-03` |
| `D-013` | 기본 리마인더는 월요일 20:30 로컬 시간 | `Approved` | Product | 2026-08-05 | `FR-015`, `GATE-03` |
| `D-014` | 반복 경험은 초안 검토이며 활성 조작 목표는 분석 대기 제외 60초 이하 | `Approved` | Product+Design | 2026-08-05 | `GOAL-01`, `FR-009` |
| `D-015` | 놓친 주는 backlog·streak 없이 최신 완료 주 하나만 제안 | `Approved` | Product | 2026-08-05 | `FR-004`, `GATE-04` |
| `D-016` | UI는 SwiftUI + Observation, 동시성은 Swift 6 strict 기준 | `Approved` | Engineering | 2026-08-05 | `ADR-003` |
| `D-017` | 사진 큐레이션은 사용자가 앱을 연 foreground에서 실행 | `Approved` | Product+Engineering | 2026-08-05 | `ADR-005` |
| `D-018` | Photos·구매·알림·분석 SDK는 protocol adapter 뒤에 격리 | `Approved` | Engineering | 2026-08-05 | `ADR-007` |
| `D-019` | 분석 provider는 PostHog EU Cloud이며 익명 explicit allowlist events만 전송; identify·person profile·autocapture·screen capture·session replay·survey·feature flag·tracing은 V1에서 비활성 | `Approved` | Product+Engineering | 2026-08-05 | `ADR-009`, `TST-019`, `TST-022`, `GATE-08` |
| `D-020` | XcodeGen 2.46.0의 `project.yml`을 프로젝트 설정 SSOT로 사용하고 생성된 `.xcodeproj`는 commit하지 않으며 Engineering이 local·CI generation을 소유 | `Approved` | Engineering | 2026-08-05 | `ADR-010`, `GATE-09` |
| `D-021` | 사진 원본 binary는 앱 sandbox에 복제하지 않고 Photos 자산을 참조 | `Approved` | Product+Engineering | 2026-08-05 | `ADR-011` |
| `D-022` | V1은 앱 관리형 백업·기기 간 복원을 제공하거나 보장하지 않아 앱 삭제·기기 변경 시 기록이 사라질 수 있음; 구매 복원은 Plus만 복원 | `Approved` | Product+Engineering | 2026-08-05 | `FR-022`, `GATE-07` |
| `D-023` | Plus는 비소모성 평생 이용권 1개; US 기준 가격은 $19.99, 다른 storefront는 Apple 자동 등가 가격을 사용하고 앱에는 StoreKit/RevenueCat 현지화 가격만 표시하며 KR 초기 예상은 약 ₩29,000 | `Approved` | Product | 2026-08-05 | `H-004`, `FR-017`, `GATE-06` |
| `D-024` | 7장 기본 layout은 hero+2+4, 1–6장은 실제 장수별 adaptive layout이며 44pt touch target·지원 폭을 만족하지 못하면 2-column으로 fallback | `Approved` | Product+Design | 2026-08-05 | Design SSOT, `GATE-10` |
| `D-025` | OneSignal·원격 푸시·NSE는 V1 baseline에서 제외 | `Approved` | Product+Engineering | 2026-08-05 | `GATE-11` |
| `D-026` | V1 appearance는 Light only이며 Dark Mode UI·토큰·QA는 범위에서 제외 | `Approved` | Product+Design | 2026-08-05 | Design Guide, `GATE-10` |
| `D-027` | V1 제품 글꼴은 LINE Seed Sans KR Regular/Bold 한 family를 사용 | `Approved` | Product+Design | 2026-08-05 | Design Guide, font resources, `GATE-10` |
| `D-028` | Weekkeep의 7장 시그니처는 정확히 7개 slot의 code-rendered SevenStitchRail이며 생성 이미지가 count를 결정하지 않음 | `Approved` | Product+Design | 2026-08-05 | `CMP-12`, `GATE-10` |
| `D-029` | Weekly Review에서 첫 photo tap은 대상을 선택하고 교체 action을 노출하며, 선택된 photo의 두 번째 tap은 viewer를 연다; 접근성 custom action은 두 행동을 직접 제공 | `Approved` | Product+Design | 2026-08-05 | `FR-009`, `FR-010`, `GATE-10` |
| `D-030` | 앱 아이콘과 인앱 SevenStitchRail은 왼쪽부터 `#E97A68`, `#E39455`, `#E5A84B`, `#66836E`, `#5F879B`, `#686286`, `#8A6386`의 정확한 7색 muted rainbow를 index별로 사용한다. rail의 filled/unfilled, selected, progress, muted 의미는 같은 index 색의 opacity와 geometry로 표현하며 어떤 상태도 단색 rail로 접히지 않는다. 모든 visible stitch는 opacity floor `0.58`을 지킨다. TabView label은 `ThisWeekTabIcon`, `WeeksTabIcon`, `SettingsTabIcon` 세 original-rendering vector asset을 사용하며, 각 tab은 calendar/week·stacked album/pages·adjustment sliders의 고유한 Plum semantic silhouette만 렌더링한다. bottom tab bar에는 decorative seven-stitch signature를 렌더링하지 않는다. 이번 visual revision은 AppIcon source/master를 변경하지 않는다 | `Approved` | Product+Design | 2026-08-06 | Design Guide, IA, TRD, `TST-034`, `TST-043`, `BR-005`, `GATE-10` |
| `D-031` | primary wordmark는 사용자가 제공한 canonical lowercase `weekkeep` wordmark asset의 Plum flat fill을 사용한다. `design/brand/weekkeep-wordmark.png`를 iOS image resource로 byte-preserving bundle하며 onboarding upper-left와 compact in-app header에서 wordmark-only로 사용한다. Onboarding keepsake preview는 wordmark 아래 하나의 warm paper/cream album card, vertical exact-seven binding, 일곱 fixture 사진을 사용하고 faux-content capsule bar나 overlapping card stack을 포함하지 않는다. exact-seven muted rainbow lockup은 외부 브랜드 surface에만 허용하고 AppIcon은 별도 asset contract를 따른다 | `Approved` | Product+Design | 2026-08-06 | Design Guide, Brand Assets, `TST-038`, `TST-043`, `GATE-10` |
| `D-032` | metadata scan은 적격 descriptor를 최대 500개까지 읽되, Vision에 보내는 후보는 deterministic local-day/time-bucket prefilter로 최대 21개(7일×3개)로 제한한다. favorite·resolution은 coverage 이후의 tie-breaker이며 analysis thumbnail target은 384–448px 범위(현재 416px), per-asset/전체 foreground budget은 약 1.5초/12초다 | `Approved` | Product+Engineering | 2026-08-06 | `FR-005`, `NFR-002`, `ADR-013`, `GATE-12` |
| `D-033` | Weekly Review replacement의 initial candidate set은 사용자의 display timezone에서 선택 사진과 같은 calendar day만 보여준다. same-day 후보가 없거나 사용자가 명시적으로 선택한 경우에만 다른 날짜를 명확히 그룹화해 보여주며, 분석 결과가 허용하면 selected day마다 미사용 강한 후보를 shortlist에 우선 보존한다 | `Approved` | Product+Design+Engineering | 2026-08-05 | `FR-010`, `ADR-014`, `GATE-13` |
| `D-034` | 저장된 앨범은 실제 PhotoKit 이미지로 기기에서만 렌더링하는 두 local share format을 제공한다: Story `1080×1920` (9:16), Post `1080×1350` (4:5). native share sheet는 명시적 사용자 행동으로만 열며, V1에는 social feed·comments·likes·account·cloud upload·server rendering이 없다 | `Approved` | Product+Design+Engineering | 2026-08-05 | `FR-023`, `ADR-015`, `GATE-14` |
| `D-035` | 설명용 photo-story surface는 승인된 일곱 개의 fictional fixture PNG만 공유하는 하나의 flat hero+2+4 mosaic vocabulary를 사용한다. onboarding은 vertical exact-seven binding, Ready와 Plus는 compact exact-seven rail을 사용하며, gradient/SF Symbol fake-photo art·겹친 카드·faux device chrome·abstract keepsake-cover는 production surface에서 금지한다. Plus는 item-driven full-screen surface로 표시해 sheet chrome을 만들지 않는다. website hero와 `og.png`도 같은 flat photo-story 방향을 따르며 canonical lowercase wordmark를 사용한다 | `Approved` | Product+Design+Engineering | 2026-08-06 | Design SSOT, `ADR-016`, `TST-045`, `GATE-10` |

Registry 운영 규칙:

1. 결정의 문구·값·상태·승인일은 이 표에서만 바꿉니다.
2. PRD·IA·TRD는 `D-*`를 참조하고 자기 책임에 해당하는 요구사항과 결과만 적습니다.
3. ADR은 기술적 이유와 파급을 기록하며 별도의 `Accepted/Proposed` 상태를 갖지 않습니다.
4. Gate는 연결된 모든 Decision이 `Approved` 이상일 때만 `Ready`로 계산합니다.
5. `Proposed → Approved/Rejected`, `Approved → Implemented → Validated` 전이에는 책임자와 증거를 남깁니다.

## 6. 검증 전 가설

| ID | 가설 | 상태 | 검증 방법 | 판정 시점 |
|---|---|---|---|---|
| `H-001` | 부모는 ‘사진 정리’보다 ‘일주일을 남긴다’는 표현에 반응한다 | `Proposed` | 랜딩 카피 A/B 및 5명 인터뷰 | 개발 1주차 |
| `H-002` | 7장이 부담과 만족의 균형점이다 | `Proposed` | 5/7/10장 프로토타입 테스트 | 디자인 프로토타입 |
| `H-003` | 첫 2개 무료 기록이면 구매 판단에 충분하다 | `Proposed` | 자연 발생 세 번째 기록 paywall cohort | Retention Pilot W2 종료 |
| `H-004` | US $19.99를 기준으로 현지화된 평생 이용권 가격이 수용 가능하다 | `Proposed` | RevenueCat paywall→purchase 전환 및 인터뷰 | 출시 후 4주 |
| `H-005` | 자동 선택 7장 중 평균 5장 이상을 그대로 수용한다 | `Proposed` | 교체 로그(사진 ID 제외) | Usability Beta 20명 |
| `H-006` | 월요일 20:30 로컬 알림이 가족 주간 회고에 적합하다 | `Proposed` | 두 번의 실제 eligible cycle 알림 복귀/완료 | Retention Pilot 2026-09-28 |

`D-008`과 `D-023`의 `Approved`는 구현 가능한 V1 출시 기본값을 뜻합니다. 무료 한도와 가격의 시장 적합성이 검증됐다는 뜻은 아니므로 `H-003`, `H-004`는 실제 행동 데이터가 나올 때까지 `Proposed`로 유지합니다.

## 7. 용어집

| 용어 | 정의 |
|---|---|
| 주간 기록 / Weekly Memory | 한 주에 속한 최대 7장의 사진과 주차 메타데이터 |
| 캘린더 주 | 사용자의 현재 시간대에서 월요일 00:00–일요일 23:59 |
| 완료 창 / Completion Window | 완료된 캘린더 주를 저장할 수 있는 다음 월요일 00:00–일요일 23:59의 7일 |
| Welcome Week | 최초 실행 시 오늘을 끝으로 하는 최근 7일 범위의 즉시 체험 기록 |
| 초기 선택 / Initial Selection | 알고리즘이 우선 제안한 최대 7장 |
| 교체 후보 / Alternatives | 초기 선택에 포함되지 않은 최대 7장 |
| 큐레이션 초안 / Draft | 저장 전이며 앱 재실행 시 재생성 가능한 임시 선택 |
| 저장 기록 / Saved Album | `weekKey` 기준으로 현재 앱 설치의 SwiftData에 저장된 주간 결과; 앱 관리형 백업·기기 간 복원을 뜻하지 않음 |
| 로컬 공유 이미지 / Local Share Artifact | 저장된 실제 사진과 Weekkeep brand treatment를 기기에서 합성한 일회성 Story/Post 이미지; Photos 원본을 복제하거나 서버에 업로드하는 백업이 아님 |
| 제한된 접근 / Limited Access | 사용자가 Photos에서 일부 사진만 허용한 상태 |
| Plus | 무료 한도 이후 기록 생성을 해제하는 유료 entitlement |
| W1/W2 eligible completion | Welcome 이후 첫 번째/두 번째 Regular Week의 완료 창 안에 해당 기록을 저장한 것; 설치 후 단순 1·2주차가 아님 |

## 8. V1 범위 밖에 남겨 둔 질문

- V2에서 iCloud 동기화를 추가할 것인가?
- 공동 부모/가족 공유를 지원할 것인가?
- 로컬 share artifact를 넘어 공동 부모/가족 공유를 지원할 것인가?
- 월간/연간 회고를 별도 상품 가치로 만들 것인가?
- 장기적으로 구독 모델이 필요한가?

V1의 로컬 이미지 export는 `D-034`로 확정된 핵심 loop입니다. 위 질문은 social network, recipient management, cloud sync 같은 범위 확장에 해당하므로 보류하며 현재 범위를 늘리는 근거로 사용하지 않습니다.

## 9. 승인 게이트

코드를 생성하기 전에 다음을 함께 확인합니다.

- [x] 타깃 사용자와 제품 한 문장에 동의
- [x] V1 포함/제외 범위에 동의
- [x] 구현 의존 Decision은 모두 `Approved`이고 구현 전 Gate는 `Open` 0임을 확인
- [x] IA의 화면 수와 핵심 경로에 동의
- [x] iOS 18+, 로컬 전용 구조와 앱 삭제·새 기기에서 기록 복원을 보장하지 않는 V1 한계에 동의
- [x] Design Guide의 브랜드 방향에 동의
- [x] Traceability에 `MISSING` 또는 `CONFLICT`가 없음
