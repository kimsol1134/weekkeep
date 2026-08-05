# Weekkeep Design SSOT

| 항목 | 값 |
|---|---|
| 상태 | Approved |
| 역할 | Current design baseline |
| 승인일 | 2026-08-05 |
| 승인 근거 | `codex://threads/019fcf07-80f5-7b13-877b-771bee4e572c` 및 현재 사용자 지시 |
| 대상 | Weekkeep V1 |
| 화면 기준 | [App Screens V2](app-screens-v2/README.md) |

이 문서는 Weekkeep 디자인의 **단일 진입점**입니다. 디자인 관련 사실은 관심사별로 아래 한 곳만 기준으로 삼으며, 생성 PNG의 예시 문구나 숫자가 제품·동작 계약을 덮어쓰지 않습니다.

## 관심사별 기준 문서

| 관심사 | 기준 문서 | 소유하는 것 |
|---|---|---|
| 디자인 결정값·승인 상태 | [Decision Registry](../docs/00-INDEX.md#5-decision-registry--결정값과-상태의-ssot) | `D-024`, `D-026`–`D-029` |
| 화면 책임·상태·탭·제스처 | [IA](../docs/03-IA.md) | 화면 전이, 선택 상태, viewer·교체 계약 |
| 시각·컴포넌트·모션·접근성·카피 규칙 | [Design Guide](../docs/05-DESIGN-GUIDE.md) | 토큰, `CMP-*`, 표현 규칙 |
| 승인된 화면 방향 | [App Screens V2](app-screens-v2/README.md) | 14개 happy-path 화면의 위계·사진 톤·구성 |
| Seven-stitch geometry | [Seven-stitch System](system/SEVEN-STITCH.md) | 정확히 7개인 code-rendered vector |
| 제품 폰트 binary·license | [LINE Seed source](../resources/fonts/line-seed-kr/SOURCE.md) | Regular/Bold TTF와 OFL |
| 디자인 판단 근거 | [V2 Design Review](../docs/08-DESIGN-REVIEW-V2.md) | V1→V2 비평과 선택 이유; 비규범 기록 |

## 승인된 V1 기준선 — 파생 요약

아래는 빠른 구현 진입을 위한 요약입니다. 결정값·상태 변경은 Decision Registry에서만 수행합니다.

- Light appearance only (`D-026`)
- LINE Seed Sans KR Regular/Bold (`D-027`)
- solid Plum primary CTA
- ordinary iPhone camera-roll에 가까운 가족사진
- 7장은 hero+2+4, 1–6장은 실제 장수에 맞는 adaptive layout (`D-024`)
- SevenStitchRail은 모든 상태에서 code-rendered exact 7 (`D-028`)
- Review에서 첫 tap은 사진 선택과 `이 사진 바꾸기` 노출, 선택된 사진의 두 번째 tap은 viewer (`D-029`)
- VoiceOver custom action은 순차 tap을 요구하지 않고 `크게 보기`와 `사진 교체`로 직접 실행
- 저장 시 grid-to-album matched-geometry 전환, Reduce Motion에서는 0.2초 fade

## 생성 화면 해석 규칙

PNG는 위계·간격·사진 방향·상호작용 의도를 보여주는 시각 기준입니다. 동적 값, 상품 가격, 사진 수, 날짜, 보존 문구는 fixture이며 PRD·IA·Design Guide의 현재 계약을 따릅니다. 실제 앱과 제출 screenshot은 SwiftUI, 등록된 LINE Seed TTF, code-rendered SevenStitchRail로 다시 렌더링합니다.

## 비규범 아카이브

- [App Screens V1](app-screens-v1/README.md): Deprecated visual baseline
- [5개 방향 탐색](concepts/README.md): Deprecated exploration
- [V2 생성 후보](app-screens-v2/explorations/README.md): Rejected/non-canonical candidates

이 자료는 결정 이력을 설명할 때만 사용하며 production 화면·카피·동작을 복사하지 않습니다.
