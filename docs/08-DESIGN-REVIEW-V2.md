# Weekkeep Design Review V2 — Parent & Shipaton Lens

| 항목 | 값 |
|---|---|
| 버전 | 0.4 |
| 상태 | Approved |
| 역할 | Non-normative decision rationale |
| 기준일 | 2026-08-05 |
| 검토 대상 | [`design/app-screens-v1`](../design/app-screens-v1/README.md) |
| 목표 카테고리 | Shipaton 2026 RevenueCat Design Award |
| 결론 | V1은 polished mockup이지만 수상작 수준의 고유 UX는 부족함 |
| 반영 결과 | [`App Screens V2`](../design/app-screens-v2/README.md), [`Seven-stitch System`](../design/system/SEVEN-STITCH.md) |
| 현재 기준 | [`Design SSOT`](../design/README.md) |

이 문서는 V1→V2 판단 근거를 보존합니다. 결정값·동작·시각 규칙은 Design SSOT가 연결한 Decision Registry·IA·Design Guide를 따릅니다.

## 1. 냉정한 판정

V1은 보기 좋고 신뢰감도 있습니다. 그러나 지금 그대로라면 심사자가 수백 개의 앱을 빠르게 넘겨볼 때 **“따뜻한 크림색 사진 앱” 중 하나로 기억될 가능성**이 높습니다.

| 평가 축 | V1 | 문제 |
|---|---:|---|
| 부모 문제 공감 | 5/10 | 예쁜 결과는 보이지만 “사진은 많고 정리할 시간은 없다”는 실제 피로가 전면에 없음 |
| 첫 10초 가치 이해 | 7/10 | 7장은 이해되지만 얼마나 쉬운지, 내가 할 일이 무엇인지 약함 |
| 신뢰·프라이버시 | 9/10 | 기기 내 처리 메시지는 강점 |
| 사용자 통제 | 6/10 | Review의 `교체`가 어느 사진을 바꾸는지 모호함 |
| 시각적 고유성 | 4/10 | 대형 고딕 제목, 크림 카드, 플럼 그라디언트가 흔한 AI UI 조합처럼 보임 |
| 사진 진정성 | 4/10 | 모든 가족사진이 같은 베이지 옷·완벽한 미소·스튜디오 조명이라 실제 카메라롤보다 광고 이미지에 가까움 |
| Shipaton Design Award 적합 | 5/10 | 미감은 있으나 독창적 UX·제스처·애니메이션 signature가 없음 |

## 2. 부모 관점에서 바꿀 것

1. **예쁜 약속보다 현실의 문제를 먼저 말한다.**  
   `아이와 보낸 일주일`보다 `사진은 많은데, 정리할 시간은 없으니까.`가 부모의 현재 상태를 더 정확히 짚습니다.

2. **초안이라는 사실을 명확히 한다.**  
   앱이 완벽하게 판단한다고 말하거나 shortlist 수를 원본 수처럼 보이지 않고 `이번 주의 순간 7장을 골랐어요`라고 설명합니다.

3. **내가 할 일이 작아 보여야 한다.**  
   `사진 고르기`보다 `7장 확인하기`, `이번 주 남기기`보다 `이 7장 남기기`가 task 크기를 분명히 합니다.

4. **교체 대상을 눈에 보이게 한다.**  
   Review에서 사진을 탭하면 선택 상태가 되고, 선택 사진 바로 아래에 `이 사진 바꾸기`가 나타납니다.

5. **사진을 덜 완벽하게 만든다.**  
   서로 다른 옷, 집의 작은 생활감, 비대칭 구도, 자연스러운 표정, 일부 motion blur가 있는 실제 iPhone snapshot 톤을 사용합니다.

## 3. 폰트 결정

### 선택: LINE Seed Sans KR

| 후보 | Weekkeep 적합성 | 판정 |
|---|---|---|
| 원티드 산스 | 안전하고 균형적이지만 차별성이 약함 | 보류 |
| SUIT | 좁은 폭과 UI 효율은 좋지만 기록 앱에는 조금 차가움 | 2순위 |
| 스포카 한 산스 Neo | 안정적이나 핀테크/과거 토스 인상이 강함 | 제외 |
| IBM Plex Sans KR | 기술적이고 지적인 인상이 프라이버시에는 맞지만 가족 기억에는 딱딱함 | 제외 |
| **LINE Seed Sans KR** | 둥근 획이 친근하지만 유아용처럼 흐물거리지 않고, 사진 중심 UI에 고유한 목소리를 줌 | **채택** |

적용:

- Display/Title/Button: `LINE Seed Sans KR Bold`
- Body/Caption/Navigation: `LINE Seed Sans KR Regular`
- V1의 과도한 56–64pt형 제목을 34–40pt 범위로 낮춤
- Title line height 1.18, body line height 1.45
- 제목 tracking `-0.02em`, 본문 tracking `0`
- CTA는 18pt Bold, 56pt 높이, solid Plum 배경
- serif wordmark와 다른 sans 혼용 금지

공식 LINE Seed는 SIL Open Font License 1.1로 배포되며 개인·상업 사용이 가능합니다. 프로젝트에는 Regular/Bold 원본 TTF와 OFL 전문을 보관합니다.

## 4. V2만의 디자인 시그니처

### Seven-stitch rail

얇은 Linen 선 위에 7개의 짧은 둥근 stitch를 놓습니다. 이는 날짜 streak가 아니라 **남길 7장의 사진**을 뜻합니다.

반복 개수는 image generation에 맡기지 않습니다. [`design/system`](../design/system/SEVEN-STITCH.md)의 코드 기반 벡터 geometry를 SwiftUI와 최종 screenshot export에서 직접 렌더링하며, `stitchCount == 7`을 snapshot test로 고정합니다.

- Welcome: 7개 muted-rainbow stitch가 차례로 나타남
- Curation: 분석이 진행될수록 index별 muted-rainbow stitch가 opacity와 progress geometry로 채워짐
- Review: 현재 선택한 사진의 stitch만 길어지고 해당 사진과 연결됨
- Save: 7개 index별 muted-rainbow stitch가 낮은/완료 opacity로 앨범의 binding처럼 모임
- Archive: tab icon에는 같은 exact-7 geometry를 쓰고, Week card는 장식을 반복하지 않고 `사진 n장`을 명시

### Week-to-album transition

저장 버튼을 누르면 Review의 사진 grid가 축소·정렬되어 Archive의 Week card가 되는 matched-geometry 전환을 사용합니다. 정적인 성공 아이콘보다 제품의 핵심 행위인 **한 주가 앨범이 되는 순간**을 보여줍니다.

### Photo interaction

- 사진 tap: 선택 + `이 사진 바꾸기` reveal
- 다시 tap: full-screen zoom
- viewer horizontal swipe: 7장 이동
- replacement: selected candidate crossfade + light haptic
- Reduce Motion: 모든 이동을 0.2s fade로 대체

## 5. V2 시각 계약

- hero+2+4 7장 layout, 1–6장 adaptive layout (`D-024`)
- Light mode only (`D-026`)
- LINE Seed Sans KR only (`D-027`)
- Seven-stitch count는 모든 상태에서 정확히 7 (`D-028`)
- 첫 tap 선택/reveal, 선택 photo 두 번째 tap viewer, 접근성 direct action (`D-029`)
- solid Plum CTA; gradient 금지
- flat Paper surface + 1px Linen border; glow/shadow 최소화
- 대형 제목이 화면의 절반을 차지하지 않음
- tab icon에서 AI sparkle 및 decorative seven-stitch 금지; 기능별 고유 Plum semantic glyph 사용
- 가족사진은 lifestyle campaign이 아니라 ordinary iPhone snapshot처럼 보여야 함
- 같은 장면·옷·미소를 반복하지 않음
- stitch는 D-030의 index별 muted rainbow를 사용하고 선택/progress/muted 의미는 opacity와 geometry로 표현; Sage는 privacy/success surface에만 사용
- 화면당 primary action 하나

## 6. Shipaton 승리 전략과 연결

Shipaton 2026 Design Award는 혁신적 아이디어와 아름다운 디자인·애니메이션을 평가합니다. V2는 다음 장면을 제출 영상 첫 45초 안에 보여주는 것을 목표로 합니다.

1. `사진은 많은데, 정리할 시간은 없으니까.` — 부모 문제
2. Photos 허용 후 7-stitch가 채워지는 로컬 분석
3. 실제 같은 7장 초안 + 사진 한 장 교체
4. grid가 Week card로 변하는 저장 transition
5. 저장 직후 Story/Post local share preview와 `Made with Weekkeep` attribution
6. 지난 주들이 쌓인 archive

## 7. 제품 계약 대조에서 추가로 고친 것

V2의 미감뿐 아니라 실제 foreground 처리와 V1 범위까지 맞췄습니다.

| 발견 | 잘못된 인상 | V2 수정 |
|---|---|---|
| 분석 전 `7장의 초안이 준비됐어요` | 앱이 background에서 이미 분석한 것처럼 보임 | `지난주를 남겨볼까요?` → `7장 초안 만들기` → Progress |
| Sunday reminder | `D-013`, `FR-015`와 충돌 | Primer와 Settings 모두 Monday 20:30 |
| archive 3개에 year filter | 기록이 적은데 탐색 UI가 과함 | 12개 전에는 year/month filter 없음 |
| detail share button/overflow | local share와 social surface의 경계가 필요 | 읽기 전용 detail에 restrained local share action만 추가; social feed/likes/comments/cloud upload는 제외 |
| `이번 주` 검토/완료 | 진행 중인 주가 섞인 듯함 | Regular flow는 `지난주`로 통일 |
| 평생 이용권의 영구 보존 오해 | Plus 복원과 album 복원을 혼동 | paywall에 `이 iPhone에서`, Settings/Privacy에 별도 백업 없음 명시 |
| stitch 6/8개 혼재 | 핵심 `7장` 제약 자체가 흔들림 | 생성 결과가 아닌 code-rendered exact-7 component |

## 8. 현재 수상 가능성 판정

V2는 V1보다 분명히 Design Award 경쟁력이 높습니다. 부모의 문제, privacy 경계, selective replacement, 저장 후 7장 순차 reveal, Seven-stitch가 하나의 이야기로 연결되기 때문입니다. 다만 정적 mockup만으로 1등을 보장할 수는 없습니다.

| 평가 축 | V1 | V2 목표 | 아직 필요한 증거 |
|---|---:|---:|---|
| 부모 문제 공감 | 5 | 9 | 부모 5명 첫 화면 설명 test |
| 첫 10초 가치 이해 | 7 | 9 | 실제 prototype 15초 이해율 |
| 신뢰·프라이버시 | 9 | 9 | network payload audit |
| 사용자 통제 | 6 | 9 | 교체 action 10초 발견율 |
| 시각적 고유성 | 4 | 8 | 실제 LINE Seed/CMP-12 SwiftUI capture |
| Design Award 적합 | 5 | 8 | 순차 reveal, haptic, Reduce Motion 실기기 영상 |

현실적인 1순위는 **RevenueCat Design Award**입니다. Grand Prize 경쟁력은 공개 출시 뒤 실제 traction과 growth momentum 증거가 추가되어야 생깁니다. 정적 화면보다 실제 45초 흐름과 부모 usability 결과가 최종 차이를 만듭니다.

참고:

- [Shipaton 2026 — How we judge](https://www.shipaton.com/blog/how-we-judge-shipaton)
- [Shipaton 2026 — Design Award criteria](https://www.shipaton.com/pt-br/rules)
- [LINE Seed official](https://seed.line.me/)
