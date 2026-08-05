# Weekkeep

> 아이와 보낸 일주일, 사진 7장으로 남겨요.  
> Keep your week in seven photos.

Weekkeep은 바쁜 부모가 매주 사진첩을 다시 뒤지지 않아도, 기기가 먼저 제안한 지난 일주일의 가족 사진 최대 7장을 1분 안에 확인하고 하나의 주간 기록으로 남기게 돕는 iPhone 앱입니다.

현재 단계는 **Implementation**입니다. 0.5 문서 기준선과 구현 Gate 11개가 모두 승인되었으며, 앱 코드·테스트·배포 증거는 이 계약에 맞춰 단계적으로 추가합니다.

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
| — | [V2 App Screens](design/app-screens-v2/README.md) | 승인된 14개 happy-path 화면은 어떻게 보이는가? |
| — | [Visual Concepts](design/concepts/README.md) | 폐기된 5개 초기 탐색 방향은 무엇이었는가? |

## 승인된 제품 결정 요약

아래는 빠른 진입을 위한 요약이며 결정값과 상태의 SSOT는 [Decision Registry](docs/00-INDEX.md#5-decision-registry--결정값과-상태의-ssot)입니다.

- 대상: 0–6세 아이를 둔, 사진은 많이 찍지만 기록은 꾸준히 못 하는 iPhone 사용자
- 핵심 루프: 주간 사진 수집 → 기기 내 분석 → 최대 7장 검토/교체 → 주간 기록 저장 (`D-004`, `D-005`)
- 첫 경험: 최근 7일의 사진으로 즉시 만드는 `Welcome Week`
- 반복 기준: 완료된 월–일 기록을 다음 월–일 동안 저장 (`D-012`)
- 기본 리마인더: 월요일 20:30 로컬 알림, 이미 준비됐다는 표현 없이 앱으로 초대 (`D-009`, `D-013`)
- 반복 경험: 초안을 확인하며 활성 조작 목표는 분석 대기 제외 60초 이하 (`D-014`)
- 놓친 주: streak·밀린 목록 없이 가장 최근 완료 주 하나부터 다시 시작 (`D-015`)
- 프라이버시: 사진 분석과 사진 식별자는 기기 밖으로 보내지 않음 (`D-006`)
- 플랫폼: iPhone, iOS 18 이상 (`D-003`)
- 승인 디자인: Light only, LINE Seed Sans KR, hero+2+4/adaptive grid, code-rendered exact-7 stitch (`D-024`, `D-026`–`D-028`)
- Review 상호작용: 첫 tap은 사진 선택·교체 action 노출, 선택된 사진의 두 번째 tap은 viewer; 접근성은 직접 action 제공 (`D-029`)
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
- 다음 게이트: `M1 First Value Prototype` 빌드·테스트
