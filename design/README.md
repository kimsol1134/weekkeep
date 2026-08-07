# Weekkeep Design SSOT

| 항목 | 값 |
|---|---|
| 상태 | Approved |
| 역할 | Current design baseline |
| 승인일 | 2026-08-07 |
| 승인 근거 | `codex://threads/019fcf07-80f5-7b13-877b-771bee4e572c` 및 현재 사용자 지시 |
| 대상 | Weekkeep V1 |
| 화면 기준 | [App Screens V2](app-screens-v2/README.md) |

이 문서는 Weekkeep 디자인의 **단일 진입점**입니다. 디자인 관련 사실은 관심사별로 아래 한 곳만 기준으로 삼으며, 생성 PNG의 예시 문구나 숫자가 제품·동작 계약을 덮어쓰지 않습니다.

## 관심사별 기준 문서

| 관심사 | 기준 문서 | 소유하는 것 |
|---|---|---|
| 디자인 결정값·승인 상태 | [Decision Registry](../docs/00-INDEX.md#5-decision-registry--결정값과-상태의-ssot) | `D-024`, `D-026`–`D-035` |
| 화면 책임·상태·탭·제스처 | [IA](../docs/03-IA.md) | 화면 전이, 선택 상태, viewer·교체 계약 |
| 시각·컴포넌트·모션·접근성·카피 규칙 | [Design Guide](../docs/05-DESIGN-GUIDE.md) | 토큰, `CMP-*`, 표현 규칙 |
| 승인된 화면 방향 | [App Screens V2](app-screens-v2/README.md) | 14개 happy-path 화면의 위계·사진 톤·구성 |
| Seven-stitch geometry | [Seven-stitch System](system/SEVEN-STITCH.md) | 정확히 7개인 code-rendered vector |
| 로고·App Icon 자산 | [Brand Marks](brand/README.md), [App Icon](app-icon/README.md) | wordmark 계층, 외부 lockup, opaque 1024 master |
| 제품 폰트 binary·license | [LINE Seed source](../resources/fonts/line-seed-kr/SOURCE.md) | Regular/Bold TTF와 OFL |
| 디자인 판단 근거 | [V2 Design Review](../docs/08-DESIGN-REVIEW-V2.md) | V1→V2 비평과 선택 이유; 비규범 기록 |

## 승인된 V1 기준선 — 파생 요약

아래는 빠른 구현 진입을 위한 요약입니다. 결정값·상태 변경은 Decision Registry에서만 수행합니다.

- Light appearance only (`D-026`)
- LINE Seed Sans KR Regular/Bold (`D-027`)
- solid Plum primary CTA
- ordinary iPhone camera-roll에 가까운 가족사진
- Weekly Review는 compact header cluster(뒤로가기·주차/날짜·정확히 7개의 독립 stitch) 뒤에 사진 collage를 우선 배치하고, 7장은 full-width 16:10 hero+2+4, 1–6장은 실제 장수에 맞는 adaptive layout (`D-024`)
- Weekly Review의 간격은 `WeeklyReviewSpacing` semantic hierarchy(screen edge → header → editorial → media → helper/replace → privacy → primary action)를 따르며, root edge는 `WeekkeepScreenLayout`의 20pt(폭 376pt 이상) / 16pt(폭 375pt 이하) responsive contract를 사용하고 header→editorial 32pt, title/body 12pt, editorial/body→media 32pt, photo gutter 8pt, lower actions 16pt·16pt·24pt를 유지함. Platform safe area는 root에서 한 번만 측정하고, hosted ScrollView의 unsafe top underlap은 같은 Cream surface로 invisibly occlude하며 72pt real runway로 lower frame을 안정시킴. App Store top/lower captures는 scroll position만 다르게 하며 production layout을 압축하지 않음
- Review 저장 CTA는 grid 전체와 helper/replacement action, quiet inline lock/privacy note 뒤의 normal scroll content에 놓이며 safe-area dock으로 collage를 덮지 않음
- `PrivacyBadge`는 full-width tinted container가 아닌 작은 lock + factual on-device-processing inline note로 표시
- SevenStitchRail은 모든 상태에서 code-rendered exact 7 (`D-028`)
- top-level tabs는 calendar/week·stacked album/pages·adjustment sliders의 고유 semantic Plum glyph만 사용하고 decorative exact-seven signature는 제외하며 localized labels와 accessibility identifiers를 유지한다 (`D-030`)
- Review에서 첫 tap은 사진 선택과 `이 사진 바꾸기` 노출, 선택된 사진의 두 번째 tap은 viewer (`D-029`)
- 카피의 SSOT는 `Weekkeep/Resources/Localizable.xcstrings`이며, Welcome CTA는 `첫 주 추억 고르기 / Choose your first week`, Ready CTA는 `지난주 추억 고르기 / Choose moments from last week`입니다. Welcome은 가장 최근 완료된 월–일 주에서 시작하고, 그 주가 비었을 때만 최근 7일 fallback을 명시합니다. 앱·IA·Design Guide·공개 메타데이터는 `초안`/`draft` 같은 내부 용어를 사용자 문구에 노출하지 않고, 최대 7장·사용자 교체·기기 내 처리·로컬 보존 한계를 함께 설명합니다.
- `preRegularWaiting`은 compact header의 기존 SevenStitchRail을 재사용하며 두 번째 rail을 추가하지 않습니다. 최신 저장 앨범의 실제 cover/placeholder, 날짜 범위, 정확한 다음 가능일, Archive 보기와 기존 local share action을 semantic card 안에서 normal flow로 제공합니다.
- 앱 아이콘과 인앱 rail은 왼쪽부터 `#E97A68`–`#E39455`–`#E5A84B`–`#66836E`–`#5F879B`–`#686286`–`#8A6386`의 index별 muted seven-stitch palette를 공유하며, rail state는 opacity와 geometry로 표현 (`D-030`)
- onboarding upper-left와 작은 인앱 header는 `brand/weekkeep-wordmark.*`에서 파생한 canonical Plum wordmark-only image resource를 사용하고, 외부 브랜드 surface만 exact-seven lockup을 사용할 수 있음 (`D-031`)
- onboarding·Ready·Plus explanatory preview는 `fixtures/app-store-family-moments/`의 승인된 seven fictional PNG만 공유하는 flat `FixturePhotoStory`를 사용한다. onboarding은 vertical binding, Ready/Plus는 compact exact-seven rail과 hero+2+4 mosaic를 사용하며 faux-content bars, gradient/SF fake-photo art, overlapping card stack, device chrome 없이 하나의 calm paper surface에 배치한다 (`D-031`, `D-035`)
- website hero와 `site/public/og.png`도 같은 fixture provenance와 flat photo-story geometry를 사용하며, canonical lowercase `weekkeep` wordmark 외 capitalized wordmark·3D album/device mockup을 사용하지 않는다 (`D-035`)
- VoiceOver custom action은 순차 tap을 요구하지 않고 `크게 보기`와 `사진 교체`로 직접 실행
- 저장 시 grid-to-album matched-geometry 전환, Reduce Motion에서는 0.2초 fade
- Save Confirmation은 share-first reward를 사용하고, Archive detail에도 local share entry를 둡니다 (`D-034`).
- local share artifact는 warm paper, canonical wordmark, exact-seven palette, date range, hero+2+4/adaptive layout, `Made with Weekkeep`를 실제 saved PhotoKit images로 on-device 렌더링합니다. Story `1080×1920`/Post `1080×1350`의 exact output을 사용하며 social feed·cloud upload·server rendering은 V1에 없습니다.

## 생성 화면 해석 규칙

PNG는 위계·간격·사진 방향·상호작용 의도를 보여주는 시각 기준입니다. 동적 값, 상품 가격, 사진 수, 날짜, 보존 문구는 fixture이며 PRD·IA·Design Guide의 현재 계약을 따릅니다. 실제 앱과 제출 screenshot은 SwiftUI, 등록된 LINE Seed TTF, code-rendered SevenStitchRail로 다시 렌더링합니다.

## 비규범 아카이브

- [App Screens V1](app-screens-v1/README.md): Deprecated visual baseline
- [5개 방향 탐색](concepts/README.md): Deprecated exploration
- [V2 생성 후보](app-screens-v2/explorations/README.md): Rejected/non-canonical candidates

이 자료는 결정 이력을 설명할 때만 사용하며 production 화면·카피·동작을 복사하지 않습니다.
