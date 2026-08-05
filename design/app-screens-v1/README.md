# Weekkeep App Screens V1

> **Legacy visual exploration — 구현 금지.** 이 세트에는 현재 제품 계약과 다른 system font, sparkle tab, 일요일 알림 등의 과거 표현이 남아 있습니다. 구현과 제출의 canonical source는 [App Screens V2](../app-screens-v2/README.md)와 [Design Guide](../../docs/05-DESIGN-GUIDE.md)입니다.

| 항목 | 결정 |
|---|---|
| 상태 | Deprecated |
| 역할 | Legacy visual exploration |
| 기준일 | 2026-08-05 |
| 기준 IA | [`docs/03-IA.md`](../../docs/03-IA.md) |
| 시각 기준 | Warm Private Family Album |
| Appearance | **Light mode only** |
| 생성 방식 | OpenAI built-in `image_gen`, `ui-mockup` |
| 기준 비율 | 853 × 1844 portrait |

## 디자인 결정

- `00-style-reference.png`는 당시 V1 탐색 세트 안에서만 사용한 기준이었으며 현재 구현 권한은 없습니다.
- V1은 라이트 모드만 구현합니다. 다크 모드 화면·토큰·QA는 범위에서 제외합니다.
- Cream 배경, Ink 타이포, Plum primary action, Coral accent, Sage privacy/status를 공통으로 사용합니다.
- 사진을 가장 큰 시각 요소로 두고, 한 화면에는 primary action 하나만 강조합니다.
- 동일한 가상의 한국인 가족(부모 2명과 미취학 아이 1명)을 fixture로 유지했습니다.
- 시스템 Photos/Notifications/App Store 팝업은 앱 자체 화면이 아니므로 이 세트에 포함하지 않았습니다.

## 화면 인벤토리

| 순서 | IA ID | 파일 | 용도 |
|---:|---|---|---|
| 00 | Reference | `00-style-reference.png` | 전체 화면의 색·타이포·사진·여백 기준 |
| 01 | `SCR-ONB-01` | `01-onboarding-welcome.png` | 첫 가치·프라이버시·Photos CTA |
| 02 | `SCR-WK-01` | `02-this-week-ready.png` | 반복 실행 ready 상태와 분석 시작 |
| 03 | `SCR-WK-02` | `03-curation-progress.png` | 로컬 사진 분석 진행과 취소 |
| 04 | `SCR-WK-03` | `04-weekly-review.png` | 7장 검토·교체·저장 기준 화면 |
| 05 | `SCR-WK-04` | `05-photo-viewer.png` | 라이트 모드 사진 확대·탐색 |
| 06 | `SCR-WK-05` | `06-save-confirmation.png` | 저장 완료 보상과 기록 열기 |
| 07 | `SHEET-REP-01` | `07-replace-photo-sheet.png` | 후보 사진 즉시 교체 |
| 08 | `SHEET-NOT-01` | `08-notification-primer.png` | 첫 저장 뒤 알림 가치 설명 |
| 09 | `SHEET-PAY-01` | `09-plus-paywall.png` | 평생 이용권 구매·복원 |
| 10 | `SCR-ARC-01` | `10-weeks-archive.png` | 저장한 주 최신순 탐색 |
| 11 | `SCR-ARC-02` | `11-week-detail.png` | 저장한 한 주 읽기 전용 상세 |
| 12 | `SCR-SET-01` | `12-settings.png` | 사진·알림·Plus·지원 상태 |
| 13 | `SCR-SET-02` | `13-privacy.png` | 기기 내 처리와 비수집 설명 |
| 14 | `SCR-SET-03` | `14-about-support.png` | 도움말·문의·약관·버전 |

## 보존 목적

- 이 이미지는 V1→V2 디자인 판단의 before 자료로만 보존합니다.
- 화면 copy, font, tab icon, reminder schedule을 production 구현으로 복사하지 않습니다.
- production typography는 LINE Seed Sans KR + semantic Dynamic Type, TAB-WEEK은 `CMP-12 SevenStitchRail`을 사용합니다.
- Paywall의 `₩29,000`은 디자인 fixture입니다. 제품에서는 RevenueCat/App Store의 현지화 가격만 표시합니다.
- 실제 가족 사진 대신 개발·테스트용 라이선스 fixture를 사용하고 App Store 제출 전 권리 관계를 확인합니다.
- `This Week`의 denied, limited, empty, saved, error는 같은 root의 상태 변형이며 별도 route가 아닙니다. 구현 단계에서 [`docs/03-IA.md`](../../docs/03-IA.md)의 상태 매트릭스로 확장합니다.

과거 재생성 기록은 [`PROMPTS.md`](PROMPTS.md)에 남기되 새 화면은 V2 prompt set만 사용합니다.
