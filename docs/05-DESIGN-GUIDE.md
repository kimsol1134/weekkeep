# Weekkeep Design Guide

| 항목 | 값 |
|---|---|
| 버전 | 0.5-approved |
| 기준일 | 2026-08-05 |
| 상태 | Approved |
| 디자인 기준선 | [Design SSOT](../design/README.md) / App Screens V2 (`Approved`) |
| 시각 방향 | Warm Private Family Album V2 |
| 대상 | iPhone app, App Store, Shipaton demo |

> 2026-08-05 visual exploration: [5개 디자인 방향과 비교](../design/concepts/README.md). 사용자가 `Warm Private Family Album` 방향을 선택한 뒤 [부모·Shipaton 관점의 V2 디자인 리뷰](08-DESIGN-REVIEW-V2.md)를 거쳤습니다. 디자인의 단일 진입점은 [Design SSOT](../design/README.md), 전체 화면 기준은 [App Screens V2](../design/app-screens-v2/README.md)입니다. **V1은 라이트 모드만 구현**하며 App Screens V1은 비교 자료로만 보존합니다.

제스처가 만드는 state·destination은 [IA](03-IA.md)가 소유합니다. 이 문서는 그 계약을 visual state, feedback, motion, VoiceOver 표현으로 구체화합니다.

## 1. 브랜드 핵심

### 한 문장

**Weekkeep은 가족의 평범한 일주일을 조용히 건져 올리는 도구다.**

### 사용자가 느껴야 하는 것

- ‘또 관리해야 할 앱’이 아니라 ‘이미 거의 다 준비된 작은 기록’
- AI의 놀라움보다 내 사진을 존중받는 안도감
- 육아의 성취를 평가받는 느낌보다 평범한 순간을 보존했다는 만족
- 귀엽지만 유아용처럼 보이지 않는 따뜻함

### 성격 스펙트럼

| 축 | Weekkeep의 위치 |
|---|---|
| 차가운 기술 — 따뜻한 기억 | 따뜻한 기억 80% |
| 장난스러움 — 차분함 | 차분함 75% |
| 장식적 — 사진 중심 | 사진 중심 85% |
| 자동화 — 통제 | 자동 초안 60%, 사용자 통제 100% |
| 아기자기 — 성숙함 | 성숙함 70% |

### 피해야 할 인상

- 분홍/파랑으로 성별을 암시하는 baby app
- 캐릭터와 badge로 가득한 육아 게임
- 얼굴 인식 성능을 과시하는 surveillance product
- streak를 잃었다며 죄책감을 주는 habit tracker
- 모든 사진을 자동으로 ‘완벽하게’ 판단한다는 AI 마케팅
- generic device/album mockup, abstract keepsake cover, gradient/SF Symbol fake-photo art

## 2. 디자인 원칙

1. **Memory before machinery**  
   알고리즘의 단계보다 사용자가 남길 사진을 먼저 보여줍니다.

2. **One gentle decision at a time**  
   한 화면에서 한 가지 primary action만 강조합니다.

3. **Reward before request**  
   알림 권한은 첫 기록을 저장한 뒤 요청합니다. paywall은 무료 가치 두 번 뒤에 나타납니다.

4. **Honest states**  
   5장뿐이면 5장으로 보여줍니다. 권한 없음, 사진 없음, 로딩, 오류를 구분합니다.

5. **Photo-first restraint**  
   색과 장식은 사진을 둘러싼 조용한 프레임이어야 합니다.

6. **Parent remains editor**  
   ‘선정 완료’보다 ‘이 순간들을 남길까요?’처럼 제안형 문장을 사용합니다.

7. **Inclusive family language**  
   엄마/아빠를 기본값으로 가정하지 않고 ‘가족’, ‘아이와 보낸 시간’, ‘당신의 일주일’을 씁니다.

8. **Weekly, not habit-forming theater**  
   매일 방문, countdown, streak를 만들지 않습니다. 한 번의 짧은 검토와 시간이 갈수록 쌓이는 보관함이 보상입니다.

## 3. 시각 방향

### 키워드

`warm editorial` · `golden hour` · `quiet confidence` · `paper album` · `modern iOS`

### 무드

- 배경은 순백보다 아주 옅은 종이색
- 텍스트와 primary action은 잉크/플럼 계열
- coral과 gold는 기억의 온기로 제한 사용
- 사진은 saturation filter 없이 원본을 존중
- 그림자보다 surface와 여백으로 hierarchy 형성
- 설명용 photo-story는 승인된 fictional fixture photo와 flat paper surface만 사용하며, 기기 bezel·중첩 카드·3D album chrome을 만들지 않음

## 4. Color System

색상 이름을 View에서 직접 사용하지 않고 semantic token을 통해 사용합니다.

### Foundation palette

| 이름 | Hex | 역할 |
|---|---|---|
| Ink | `#25212B` | light mode 주요 글자 |
| Cream | `#FBF7F2` | light mode 기본 배경 |
| Paper | `#FFFFFF` | card/sheet surface |
| Plum | `#5B415E` | brand, primary action |
| Memory Coral | `#E97A68` | 정서적 accent, 장식 |
| Golden Hour | `#E5A84B` | highlight, progress accent |
| Sage | `#537763` | 성공/프라이버시 신뢰 |
| Linen | `#E8E1DB` | divider/border |

### Semantic tokens

| Token | 값 | 사용 |
|---|---|---|
| `color.background.primary` | Cream | screen background |
| `color.background.surface` | Paper | card/sheet |
| `color.text.primary` | Ink | 제목/본문 |
| `color.text.secondary` | `#6F6774` | 보조 정보 |
| `color.action.primary` | Plum | primary button fill |
| `color.action.onPrimary` | White | primary button label |
| `color.action.secondary` | Plum | text/outline action |
| `color.accent.memory` | Memory Coral | 장식, 선택 강조 |
| `color.accent.warm` | Golden Hour | progress/illustration |
| `color.status.success` | Sage | 저장/프라이버시 상태 |
| `color.border.subtle` | Linen | divider |
| `color.overlay.scrim` | Ink 44% | modal/photo overlay |
| `color.status.error` | `#9B3D47` | 오류 텍스트/아이콘 |

### 검증한 주요 대비

| 조합 | 대비 | 사용 판정 |
|---|---:|---|
| Ink on Cream | 14.79:1 | 모든 텍스트 가능 |
| White on Plum | 8.89:1 | primary CTA 가능 |
| Ink on Memory Coral | 5.60:1 | 본문 가능 |
| White on Memory Coral | 2.82:1 | 작은 텍스트 금지 |
| Ink on Golden Hour | 7.54:1 | 텍스트 가능 |
| White on Sage | 5.02:1 | 일반 텍스트 가능 |
| Sage on Cream | 4.70:1 | 일반 텍스트 가능 |

Memory Coral 위에는 흰색 작은 글자를 올리지 않습니다. 색은 최소 기준을 만족해도 실제 Dynamic Type, Increase Contrast, 사진 배경 위에서 다시 검증합니다.

### 색 사용 비율 가이드

- 70% background/surface
- 20% 사진
- 7% Ink/Plum action과 typography
- 3% Coral/Gold/Sage accent

숫자는 pixel 규칙이 아니라 과한 accent를 막기 위한 방향입니다.

## 5. Typography

### 원칙

- 제품 글꼴은 **LINE Seed Sans KR** 한 family만 사용합니다.
- 제목·CTA는 `LINESeedSansKR-Bold`, 본문·보조 정보·navigation은 `LINESeedSansKR-Regular`를 사용합니다.
- 폰트 파일과 OFL 1.1 전문은 [`resources/fonts/line-seed-kr`](../resources/fonts/line-seed-kr)에 보관합니다.
- SwiftUI의 `Font.custom(_:size:relativeTo:)`를 사용해 custom font와 Dynamic Type을 함께 지원합니다.
- font binary를 정확히 적용할 수 없는 image-generation mockup은 방향 참고용이며 실제 앱과 제출 screenshot은 등록된 TTF로 렌더링합니다.
- 사진 위에 긴 텍스트를 배치하지 않습니다.
- 한글과 영어에 동일 family를 사용해 혼합 시 위화감을 줄입니다.
- serif wordmark, Apple system font, 다른 한글 sans를 같은 화면에 혼용하지 않습니다.
- 기본 큰 제목은 34–40pt 범위에서 시작하고 접근성 확대는 semantic scaling에 맡깁니다.

### Type roles

| Token | Base size / relative style | Font | 용도 |
|---|---|---|---|
| `type.display` | 38 / `.largeTitle` | Bold | Welcome 핵심 문장, 큰 완료 문장 |
| `type.title1` | 34 / `.title` | Bold | 화면의 정서적 제목 |
| `type.title2` | 28 / `.title2` | Bold | section/주간 제목 |
| `type.headline` | 18 / `.headline` | Bold | card/CTA label |
| `type.body` | 17 / `.body` | Regular | 설명 |
| `type.callout` | 15 / `.callout` | Regular | 보조 상태, 날짜 |
| `type.caption` | 13 / `.caption` | Regular | 법적/메타 정보 |

SwiftUI 등록 이름:

```swift
extension Font {
    static let weekkeepDisplay = Font.custom(
        "LINESeedSansKR-Bold",
        size: 38,
        relativeTo: .largeTitle
    )

    static let weekkeepBody = Font.custom(
        "LINESeedSansKR-Regular",
        size: 17,
        relativeTo: .body
    )
}
```

Info.plist의 `UIAppFonts`에 `LINESeedKR-Rg.ttf`, `LINESeedKR-Bd.ttf`를 등록하고 launch smoke test에서 실제 PostScript name을 확인합니다. `.fontWeight`로 synthetic weight를 만들지 않습니다.

### 줄과 폭

- 본문 최대 권장 폭: 38–44 한글자 정도
- display 문장: 2–3줄 이내
- CTA: 기본 1줄, 접근성 크기에서는 wrap 허용
- centered paragraph는 2줄 이하에만 사용; 긴 설명은 leading 정렬
- 숫자 `7`을 장식적으로 강조할 수 있지만 accessibility label에는 전체 문장을 제공합니다.

## 6. Spacing, Shape, Elevation

### 4pt spacing scale

| Token | 값 | 사용 |
|---|---:|---|
| `space.1` | 4 | icon 내부/미세 간격 |
| `space.2` | 8 | 밀접 요소 |
| `space.3` | 12 | card 내부 작은 그룹 |
| `space.4` | 16 | control/card 내부 또는 소형 화면 horizontal padding; 일반 custom root edge는 `WeekkeepScreenLayout` 사용 |
| `space.6` | 24 | section 내부 |
| `space.8` | 32 | section 사이 |
| `space.12` | 48 | hero/큰 분리 |
| `space.16` | 64 | extended scroll breathing; feature stack 압축 금지 |

### Weekly Review semantic spacing hierarchy

`SCR-WK-03` keeps the same production layout in normal use and deterministic
App Store fixture capture. The screenshot test may scroll to a second framing;
it must never use a launch argument or debug branch to compress the surface.

| 역할 | 기준 토큰 | 값 | 적용 위치 |
|---|---|---:|---|
| Screen edges | `WeekkeepScreenLayout` | 20pt / 16pt | regular width / compact width(≤375pt)의 horizontal content edge |
| Header cluster | `space.2` | 8pt | back/date/rail cluster internals |
| Header → editorial | `space.8` | 32pt | header cluster 아래 editorial group까지의 major boundary |
| Title/body editorial group | `space.3` | 12pt | title to explanatory body |
| Partial-result notice | `space.6` | 24pt | editorial group to partial-result notice |
| Editorial/body → media | `space.8` | 32pt | editorial group 또는 notice 아래 photo media까지의 major boundary |
| Media grid | `space.2` | 8pt | every photo gutter, including row gaps |
| Helper/replace state | `space.4` | 16pt | complete grid to helper or replacement action |
| Privacy note | `space.4` | 16pt | helper/replacement to inline local-only note |
| Primary action | `space.6` | 24pt | privacy note to save CTA |
| Scroll boundary | `space.4` / `space.6` | 16/24pt | top and bottom breathing room |
| Scroll runway | `space.16 + space.2` | 72pt | real bottom content runway so lower framing can settle without clipping editorial copy |

The implementation names these roles through `WeeklyReviewSpacing`; custom
screen roots share `WeekkeepScreenLayout` so the regular 6.1/6.9-inch target
uses a 20pt edge while the 375pt-and-smaller fallback remains 16pt. A 0–2pt
value may remain inside an icon or the independent stitch geometry, but is not
valid for a feature stack, photo grid, or screenshot-only layout override.
The root `ScrollView` keeps the platform safe-area positioning once; do not add
the same `GeometryProxy.safeAreaInsets` again as feature padding. Because the
hosted tab route can still underlap the status region at a lower scroll
position, `WeeklyReviewView` uses the runtime system boundary and the same
Cream surface as an invisible top occluder. `screenTop` remains the 16pt
content breathing room after the system boundary, and `scrollRunway` is real
content space rather than a visible bar or screenshot-only branch.

The local share preparation surface keeps native picker/control internals intact;
the format picker to generated preview/error content boundary uses
`WeeklyAlbumShareSpacing.rootSection` (`space.6`, 24pt).

### Radius

| Token | 값 | 사용 |
|---|---:|---|
| `radius.small` | 12 | thumbnail, chip |
| `radius.medium` | 16 | button, compact card |
| `radius.large` | 24 | hero card, sheet content |
| `radius.pill` | 999 | badge |

### Elevation

- card 기본은 shadow 없음 + surface contrast
- 떠 있는 CTA가 필요할 때만 `0 8 24 / Ink 10%`
- 사진 grid cell에는 shadow를 쓰지 않음
- V1 라이트 모드에서도 shadow보다 surface 대비와 여백으로 hierarchy를 만듦

## 7. Layout System

### Screen frame

- safe area 준수
- 기본 horizontal padding 20pt(소형 화면 16pt 허용)
- safe-area를 이미 준수하는 root scroll surface에 `GeometryProxy.safeAreaInsets`를 다시 padding으로 더하지 않음
- 저장 CTA와 privacy note는 normal scroll content 순서에 포함하며, overlay dock이나 별도 safe-area inset을 만들지 않음
- iPhone portrait가 기준이며 landscape에서 깨지지 않는 정도만 보장
- iPad에서 실행 가능하게 둘 경우 centered max width 560pt; V1 별도 iPad UX는 아님

### Weekly photo composition

The compact 7-photo composition is the shared production vocabulary for
Weekly Review, Ready/Plus explanatory previews, and local share artifacts.
It remains a wide hero followed by a 2-photo row and a 4-photo row. Onboarding
is intentionally a different album-page composition so the seven fixtures stay
legible in the narrower explanatory card.

#### Compact 7장 승인 기본안 — hero+2+4

```text
┌───────────────────────┐
│         Hero 1        │
│         16:10         │
├───────────┬───────────┤
│  Photo 2  │  Photo 3  │
│    1:1    │    1:1    │
├─────┬─────┼─────┬─────┤
│ P4  │ P5  │ P6  │ P7  │
│ 1:1 │ 1:1 │ 1:1 │ 1:1 │
└─────┴─────┴─────┴─────┘
```

검증 조건:

- 4-column 마지막 줄의 touch target이 44pt 미만이면 2-column adaptive grid로 변경
- 접근성 텍스트 크기가 grid 자체를 확대하지는 않지만 action은 별도 accessible custom action으로 제공
- hero crop이 사람 얼굴을 과도하게 자르는 사례가 많으면 Vision saliency crop 또는 uniform 2-column grid로 단순화

#### Onboarding keepsake — 1+3+3

```text
┌───────────────────────┐
│         Hero 1        │
│         wide          │
├──────┬──────┬─────────┤
│ P2   │ P3   │ P4      │
│ 1:1  │ 1:1  │ 1:1     │
├──────┼──────┼─────────┤
│ P5   │ P6   │ P7      │
│ 1:1  │ 1:1  │ 1:1     │
└──────┴──────┴─────────┘
```

- This rule applies only to `FixturePhotoStory(style: .onboarding)`: one
  wide hero followed by two clean rows of three equal thumbnails.
- Every horizontal and vertical photo gutter is at least `space.3` (12pt).
  The compact hero+2+4 composition keeps its existing `space.2` (8pt) token
  gap.
- All seven approved fixture photos remain inside one calm Paper/Cream card
  with the existing vertical exact-seven stitch binding. The binding has its
  own `space.3` separation from the photo mosaic and never touches a tile.
- Every tile uses the same `radius.small`, is explicitly clipped to its frame,
  and has no overlap, touching edge, shadow, gradient, placeholder bar, or
  stacked-card treatment. The restrained card border stays on the outer paper
  surface only.
- This onboarding variant is explanatory artwork, not a replacement for the
  Weekly Review's compact hero+2+4 layout or its interaction contract.

#### 1–6장

- 빈 자리를 가짜 frame이나 `사진을 더 추가하세요`로 채우지 않음
- 1장: 4:5 hero
- 2장: 2-column 1:1
- 3장: hero + 2-column
- 4장: 2×2
- 5–6장: 2-column adaptive grid

### Photo treatment

- 원본 색상에 필터를 적용하지 않음
- 기본 crop은 `.fill`, 확대 보기에서 전체 비율 확인 가능
- border 1pt subtle은 밝은 사진이 surface와 합쳐질 때만 사용
- 사진 위 text overlay는 viewer의 scrim 위 control 외에는 금지
- AI가 추론한 설명을 alt text로 만들지 않고 날짜/위치 순서 같은 확실한 정보만 사용
- 마케팅·fixture 사진도 같은 베이지 옷, 완벽한 미소, 반복 포즈로 통일하지 않음
- 서로 다른 날의 옷, 집의 생활감, 비대칭 crop, 움직임 blur, 낮과 저녁의 다른 조명을 포함해 실제 camera roll처럼 보이게 함
- 실제 사용자 사진은 명시적 동의 없이 demo, screenshot, Build in Public 자산으로 사용하지 않음

## 8. Component Library

### `CMP-01 PrimaryButton`

- 높이: 최소 52pt, touch target 최소 52pt
- radius: 16pt
- fill: `action.primary`
- label: `headline`, `action.onPrimary`
- full width 기본
- 상태: enabled / pressed / loading / disabled
- loading에서도 기존 label 의미를 유지하거나 `저장하는 중`으로 명시
- disabled 이유가 보이지 않으면 버튼을 비활성화하지 말고 상태 메시지 제공

### `CMP-02 SecondaryButton`

- text 또는 subtle outline
- Primary와 같은 화면에서 시각적 경쟁 금지
- destructive style은 V1 핵심 흐름에 없음

### `CMP-03 PrivacyBadge`

- 작은 lock SF Symbol과 짧은 사실 문구를 leading-aligned inline note로 표시
- full-width tinted rounded rectangle, card, badge-like container를 사용하지 않음
- 예: `이 iPhone 안에서만 살펴봐요`
- 버튼처럼 보이지 않으며 상세 링크가 필요하면 별도 text link 제공
- marketing claim이 아니라 실제 기술 경계와 일치해야 함

### `CMP-04 WeeklyPhotoGrid`

- 1–7장 adaptive layout
- 7장은 full-width 16:10 hero → 1:1 중간 2장 → 1:1 하단 4장 순서이며 row/column gap은 `space.2`(8pt)
- 하단 4장은 각 tile이 최소 44pt를 유지할 수 있을 때 4-column, 그렇지 않으면 2-column으로 전환
- 제안 photo마다 stable ID, position, `크게 보기`·`사진 교체` custom action
- 처음부터 7장을 선택하는 empty selection mode를 만들지 않음
- accept-as-is가 기본 상태이며, 사진마다 선택 checkbox를 반복해서 누르게 하지 않음
- skeleton은 실제 photo cell 수를 단정하지 않는 neutral block
- missing asset state를 별도 제공

### `CMP-05 PhotoTile`

- states: loading / available / unavailable / selectedCandidate
- unavailable: Linen surface + `photo.badge.exclamationmark` + 텍스트 label
- photo 위 permanent badge 최소화
- 첫 tap은 선택과 replace action reveal, 선택된 tile의 두 번째 tap은 viewer
- VoiceOver custom action은 순차 tap과 관계없이 viewer·replace를 직접 실행

### `CMP-06 WeekRow`

- 72–88pt 높이, cover 64pt
- 날짜 range가 primary, 사진 수는 secondary
- 전체 행 44pt 이상 tap target
- missing cover에도 layout 변화 없음

### `CMP-07 ProgressCard`

- 단계 title, optional determinate progress, privacy reassurance
- 가짜 퍼센트/시간 예측 금지
- 단계 변경 animation은 opacity 0.2s

### `CMP-08 EmptyState`

- icon/작은 abstract illustration
- 사실 기반 title
- 한 문단 설명
- 필요한 경우 primary CTA 하나
- 죄책감/실패 언어 금지

### `CMP-09 PermissionStateCard`

- 권한 상태를 full/limited/denied/restricted로 구분
- Limited는 warning이 아니라 정보 상태
- notDetermined는 권한 요청 action, denied는 Settings recovery action을 제공
- restricted는 정책 설명만 보여주고 앱이 직접 바꿀 수 없는 상태에 허위 Settings/manage action을 제공하지 않음

### `CMP-10 PlusCard`

- 구매 status와 value를 보여주며 price는 Store 제공 값 사용
- V1은 비소모성 평생 이용권 1개이며 US $19.99는 storefront 기준값일 뿐 UI 표시 문자열이 아님
- KR 약 ₩29,000 fixture와 관계없이 production은 RevenueCat/App Store 현지화 가격을 그대로 표시
- lifetime을 월 가격처럼 환산해 오해시키지 않음
- lifetime은 Plus 이용 권한의 상품 유형이며 기록의 영구 백업으로 표현하지 않음
- restore는 발견 가능한 text button

### `CMP-11 Toast/Notice`

- 성공/중립 feedback, 2줄 이내
- 핵심 오류나 되돌릴 수 없는 정보에는 toast 사용 금지
- VoiceOver announcement 제공

### `CMP-12 SevenStitchRail`

- Weekkeep의 `최대 7장` 제약을 나타내는 브랜드 컴포넌트
- 모든 크기와 상태에서 slot 수는 정확히 `7`
- 요일, 연속 사용일, 달성 streak를 뜻하지 않음
- 모든 slot은 index별 D-030 muted rainbow(`red → orange → yellow → green → blue → indigo → violet`)를 유지합니다. Welcome/Ready, 선택 tab, 저장 완료, 비활성 tab은 색을 단색으로 바꾸지 않고 semantic tone에 맞는 opacity를 적용합니다.
- 진행 상태는 `filledCount + remainingCount == 7`을 항상 만족하며 filled/unfilled는 opacity, selected는 4×14pt geometry, 일반 slot은 3×10pt geometry로 구분합니다.
- visible stitch는 어떤 상태에서도 opacity `0.58` 아래로 내려가지 않습니다. 이 floor는 muted/unfilled 슬롯이 iPhone과 1080p video scale에서 회색으로 뭉개지지 않도록 하며, 상태 의미는 opacity 차이와 geometry로 유지합니다.
- horizontal rail과 vertical album binding은 같은 normalized stitch geometry를 사용합니다. Bottom tab icon은 functional silhouette만 렌더링하며 exact-seven stitch signature를 포함하지 않습니다.
- rail은 일곱 개의 독립 stitch와 그 사이의 빈 공간만으로 구성하며 추가 선·막대·분할자를 두지 않습니다.
- 본 rail과 vertical binding은 SwiftUI code-rendered component입니다. TabView label은 `ThisWeekTabIcon`, `WeeksTabIcon`, `SettingsTabIcon` 세 deterministic original-rendering vector asset을 `.renderingMode(.original)`로 사용해 시스템 template tint를 차단합니다. 세 asset은 각각 calendar/week, stacked album/pages, adjustment sliders의 서로 다른 Plum silhouette만 가지며 bottom tab bar에는 decorative stitch를 렌더링하지 않습니다.
- rail 자체는 `accessibilityHidden(true)`; 실제 사진 수와 현재 위치는 별도 텍스트로 제공
- source geometry와 상태별 vector는 [`design/system/SEVEN-STITCH.md`](../design/system/SEVEN-STITCH.md)를 기준으로 함
- snapshot test에서 visible capsule count가 7인지 검증

### `CMP-13 SemanticTabIcon`

- `This Week`는 calendar/week, `Weeks`는 stacked album/pages, `Settings`는 adjustment sliders의 세 고유 silhouette을 사용합니다.
- Plum semantic glyph가 실제 tab-bar 크기에서 primary로 읽혀야 하며, bottom tab bar에는 secondary rainbow stitch signature를 그리지 않습니다.
- 각 asset은 고유 이름(`ThisWeekTabIcon`, `WeeksTabIcon`, `SettingsTabIcon`)과 `template-rendering-intent: original`을 사용합니다. system tint로 semantic glyph가 단색 collapse하지 않습니다.
- selected/unselected는 semantic glyph opacity로만 구분하며 localized text label과 `TAB-WEEK`, `TAB-ARCHIVE`, `TAB-SETTINGS` accessibility identifiers는 유지합니다.

### `CMP-14 FixturePhotoStory`

- onboarding·Ready·Plus의 설명용 photo-story는 승인된 seven fictional fixture PNG만 사용하고, 실제 사용자 Photos 자산이나 분석 결과를 암시하지 않습니다.
- 하나의 calm Paper/Cream surface 안에 non-overlapping photo mosaic과 exact-seven rail을 배치합니다. onboarding은 vertical binding과 `1+3+3` mosaic, Ready/Plus는 compact horizontal rail과 `hero+2+4` mosaic를 사용합니다.
- onboarding `1+3+3`은 `space.3` 이상의 수평·수직 gutter, 동일한 `radius.small`, 명시적 clipping을 사용합니다. compact `hero+2+4`는 기존 `space.2` gutter를 유지합니다.
- gradient, SF Symbol fake-photo art, generic icon illustration, stacked/overlapping cards, faux device chrome, 3D album cover, extra bezel은 금지합니다.
- fixture photo tile은 사진을 설명하는 보조 label만 제공하며 사람·가족의 신원이나 감정을 추측하지 않습니다. VoiceOver에는 공유 `accessibility.photoStory` 의미를 제공합니다.

## 9. 화면별 디자인 방향

### Welcome

- 실제 product outcome을 대표하는 일곱 개의 승인된 fictional fixture를 배치한 공유 `FixturePhotoStory`가 hero
- onboarding preview는 하나의 warm Paper/Cream surface 안에서 vertical exact-seven binding과 `1+3+3` photo geometry를 보여주며, Ready/Plus는 horizontal rail·compact `hero+2+4` geometry를 사용함
- onboarding 사진 사이 gutter는 수평·수직 모두 `space.3` 이상이며, 세 칸씩 맞춘 두 thumbnail row와 wide hero가 서로 닿거나 겹치지 않음
- seven fixture photo가 dominant content이며 faux-content capsule bar, placeholder bar, gradient/SF Symbol fake-photo art, overlapping translucent/card stack, device chrome을 사용하지 않음
- fixture는 정적 onboarding illustration이며 사용자 사진, Photos 자산, 분석 입력으로 취급하지 않음
- 배경은 Cream, preview 주변 여백 충분히
- 첫 viewport에 title, privacy badge, CTA가 모두 들어오되 작은 기기에서는 scroll 허용
- AI/기술 iconography보다 사진 결과 사용
- 부모의 상황을 먼저 말하는 headline `사진은 많은데, 정리할 시간은 없으니까.`를 기본안으로 사용
- 본문은 `지난 7일에서 최대 7장`이라고 정직하게 표현하며 항상 7장을 보장하지 않음

### This Week / Ready

- foreground 분석 전에는 `초안이 준비됐어요`라고 말하지 않음
- `지난주를 남겨볼까요?` → `7장 초안 만들기`가 기본 경로
- Ready explanatory surface는 `FixturePhotoStory`의 compact rail + flat hero+2+4 mosaic를 사용하며, 분석 결과나 사용자 사진 초안처럼 보이게 하지 않음
- 접근 가능한 사진 수는 local UI에 표시할 수 있지만 외부 분석에는 bucket만 전송

### Curation Progress

- 기다림을 과장된 spectacle로 만들지 않음
- 분석된 thumbnail이 짧게 등장할 수 있으나 session replay나 외부 compositing 없음
- cancellation이 항상 발견 가능
- iCloud 대기와 계산 진행을 카피로 구분

### Weekly Review

- 사진이 화면의 60% 이상 시각적 비중
- 제목과 CTA는 현재 진행 중인 주가 아니라 완료된 `지난주`를 가리킴
- 초안 그대로 저장하는 경로가 primary이며 저장 전 필수 선택 단계는 없음
- 첫 photo tap은 해당 tile을 Coral 선택 상태로 만들고 바로 아래 `이 사진 바꾸기`를 reveal
- 선택된 같은 photo를 두 번째 tap하면 그 index로 full-screen viewer를 열며, 다른 photo tap은 선택 대상만 변경
- photo tile별 `크게 보기`·`사진 교체`는 VoiceOver custom action으로 직접 접근 가능해야 함
- header cluster와 photo collage 사이에 두 번째 bar를 두지 않으며, 저장 CTA는 완성된 collage 뒤 helper/replacement action과 privacy note 다음의 normal scroll content에 둠
- 저장 CTA는 collage를 덮거나 시각적으로 분할하지 않으며, 7장 hero+2+4 전체가 한 흐름으로 읽혀야 함
- 간격은 `Weekly Review semantic spacing hierarchy`를 따르며, 상단 캡처는 header/title/body/hero story, 하단 캡처는 의도적으로 scroll한 replacement/privacy/save action을 보여 줌. 한 장에 모든 control을 넣기 위해 spacing을 줄이지 않음
- hosted ScrollView가 status region 아래로 움직여도 동일한 Cream occluder가 unsafe top을 보이지 않게 가리며, lower-action frame의 editorial title/copy는 안전 경계 아래에 온전히 보이거나 완전히 가려져야 함. `scrollRunway` 72pt는 이 상태를 위한 실제 bottom breathing이며 추가 toolbar/divider가 아님
- 반복 주는 grid 표시 후 한 번의 primary CTA로 완료 가능하며, 활성 조작 중앙값 60초 이하를 usability 기준으로 삼음
- 7장 미만일 때 부족함을 경고색으로 표현하지 않음

### Save Confirmation

- 성공은 짧은 haptic + 저장한 최대 7장이 60–80ms 간격으로 나타나는 약 1초 reveal로 표현
- reveal은 사진을 다시 고르게 하거나 다음 행동을 요구하지 않는 작은 보상이어야 함
- confetti, points, streak 없음
- primary CTA는 `이번 주를 공유하기`이며 저장된 결과를 local share preparation으로 연결합니다. `기록 보기`는 secondary, `완료`는 tertiary입니다.
- 알림 제안은 confirmation과 한 화면에서 동시에 경쟁시키지 않고 다음 sheet로 분리

### Local Share Artifact

- Story는 9:16 `1080×1920`, Post는 4:5 `1080×1350`의 exact pixel canvas입니다.
- visual hierarchy는 warm Cream/paper background → canonical Plum wordmark → local date range → real photo composition → exact seven muted stitch palette → restrained `Made with Weekkeep` signature 순서입니다.
- 7장은 editorial hero+2+4를 사용하고, 1–6장은 빈 placeholder 없이 실제 사진만 adaptive layout에 배치합니다.
- photo는 cover/crop만 조정하고 saturation filter, child/family label, filename, location, score, analytics, fake content를 넣지 않습니다.
- wordmark는 canonical `weekkeep` asset를 사용하며, in-app rail/index order는 `#E97A68`, `#E39455`, `#E5A84B`, `#66836E`, `#5F879B`, `#686286`, `#8A6386`을 그대로 씁니다. AppIcon 파일을 재사용하거나 변경하지 않습니다.
- signature는 visible attribution인 `Made with Weekkeep`만 사용합니다. V1 이미지에는 public install URL을 그리지 않습니다.
- preview와 native share action은 modal focus를 유지하고, loading/retry/error 상태와 VoiceOver label을 제공합니다. native share preview에는 localized generic title과 이미 만든 artifact thumbnail만 사용하며 public install URL은 넣지 않습니다. 시스템 share sheet는 사용자가 share CTA를 누른 뒤에만 엽니다.

### Weeks

- calendar app처럼 촘촘한 grid보다 앨범 목록의 호흡
- 기록이 12개 이상 쌓이기 전에는 과도한 year/month navigation 금지
- 커버가 없는 상태도 주차를 잃지 않음

### Paywall

- paywall은 별도 boolean modal이 아닌 item-driven full-screen app surface extension으로 표시하며 gray sheet chrome, nested rounded sheet, faux device frame을 만들지 않음
- hero는 Ready와 같은 `FixturePhotoStory` compact variant를 사용하고 gradient/SF Symbol fake-photo art, stacked card mockup, abstract album cover를 사용하지 않음
- 이미 만든 기록의 작은 thumbnail은 실제 Photos privacy 검토 후 local render만 사용
- `한 번 구매`, `평생 이용`을 명확히 구분
- restore 성공은 paywall 안에 성공 배너를 유지하고 purchase CTA를 Continue로 바꾸며, active entitlement 확인 전에는 닫지 않음
- Continue 확인이 inactive/unknown이면 차분한 pending 안내와 권한 확인 action을 유지하고 잠금을 낙관적으로 풀지 않음
- 개인정보 링크에서 현재 iPhone 로컬 저장과 앱 관리형 백업이 없다는 사실을 구매 전에 확인 가능
- `영구 보관`, `평생 보존`, `어느 기기에서나 복원` 표현 금지
- countdown, fake discount, ‘오늘만’ 금지

### Settings

- native Form/List 패턴 우선
- custom card로 모든 row를 재발명하지 않음
- 현재 권한/Plus 상태는 오른쪽 value로 명확히 표시
- 주간 알림 기본값은 문서 계약과 동일한 `월요일 오후 8:30`
- 저장 기록이 0개이면 Settings 알림 value row는 `첫 기록 저장 후`를 표시하고, `첫 주간 기록을 저장한 뒤 알림을 켤 수 있어요.`라는 static informational row를 둡니다. Button, chevron, tappable permission affordance를 표시하지 않습니다.
- 저장 기록이 1개 이상일 때만 `알림 켜기` 또는 `알림 설정 열기` action row를 렌더링합니다. VoiceOver에는 상태와 안내를 static text로, 실제 action은 실제 Button으로만 노출합니다.
- `데이터 저장` row에서 현재 iPhone 로컬 저장·별도 백업 없음·앱 삭제/기기 변경 시 유실 가능성을 한 화면 안에서 확인 가능

### Privacy

- 큰 방패 하나보다 `사진 앱 → 기기 안의 Weekkeep → 서버 전송 없음`의 실제 경계를 먼저 보여줌
- SevenStitchRail은 7개의 독립 stitch만으로 signature를 표현하며 privacy note와 결합하지 않음
- `기기 안에서 분석`, `추적하지 않음`, `내가 결정` 세 사실을 짧은 row로 제공
- `외부 전송 없음`과 `별도 백업 없음`을 혼동하지 않게 둘을 모두 설명

## 10. Motion

### 원칙

움직임은 상태 변화의 이해와 기억의 따뜻함을 돕되, 기다림을 더 길게 느끼게 하면 안 됩니다.

| Motion token | 값 | 사용 |
|---|---:|---|
| `motion.fast` | 0.16–0.20s | button, 작은 state |
| `motion.standard` | 0.28–0.35s | push-like content transition |
| `motion.reveal` | 0.40–0.55s | 저장 후 photo reveal |
| `motion.stagger` | 60–80ms | 최대 7장 등장 |

규칙:

- spring bounce는 작고 1회만
- 분석 spinner 외 반복 animation 최소화
- photo 교체는 crossfade; zoom/flip 금지
- 저장 성공에서는 최종 사진을 60–80ms 간격으로 순차 reveal해 약 1초 안에 한 주의 앨범이 완성됨
- Reduce Motion에서는 순차 이동 없이 짧은 fade 한 번으로 대체
- 자동 재생되는 영상이나 flashing 없음

## 11. Haptics

| 순간 | haptic |
|---|---|
| 사진 교체 | light selection |
| 저장 성공 | success notification |
| 오류 | warning/error는 중요한 경우만 1회 |
| 일반 navigation | 없음 |
| paywall 표시 | 없음 |

haptic은 시각/음성 feedback을 대체하지 않습니다.

## 12. Voice and Copy

### 목소리

- 짧고 구체적
- 다정하지만 과하게 감상적이지 않음
- 사용자를 평가하지 않음
- 기술적으로 정직함
- 명령보다 초대

### Do / Don’t

| 상황 | Do | Don’t |
|---|---|---|
| 가치 | `아이와 보낸 일주일, 사진 7장으로 남겨요.` | `AI가 최고의 아기 사진을 찾아드립니다.` |
| 진행 | `비슷한 사진을 정리하는 중이에요.` | `마법을 부리는 중...` |
| 검토 | `준비한 7장을 확인해 보세요.` | `사진 7장을 골라 주세요.` |
| 5장 | `지난주에는 5개의 순간을 찾았어요.` | `사진이 2장 부족해요.` |
| limited | `선택한 사진으로 기록을 만들어요.` | `전체 접근을 허용해야 더 좋아요.` |
| save | `지난주를 남겼어요.` | `7일 연속 성공!` |
| missed | `최근 한 주부터 다시 시작해요.` | `3주나 놓쳤어요.` |
| notification | `지난주를 1분 만에 남겨볼까요?` | `7장이 준비됐어요.` |
| purchase | `앞으로의 주들도 계속 남겨요.` | `추억을 잃기 전에 지금 구매하세요.` |
| error | `일부 사진을 불러오지 못했어요.` | `PHImageError -1001` |

### CTA 규칙

- 행동 + 결과: `지난 7일 남기기`, `7장 초안 보기`, `지난주 남기기`
- 모호한 `계속`, `확인`은 system flow 외 최소화
- 부정 CTA `아니요`보다 `지금은 괜찮아요`
- destructive action이 없으면 빨간 CTA를 사용하지 않음

### 영어 핵심 카피

| 한국어 | 영어 |
|---|---|
| 아이와 보낸 일주일, 사진 7장으로 남겨요. | Keep your week in seven photos. |
| 사진은 이 iPhone에서만 분석돼요. | Your photos are analyzed on this iPhone. |
| 지난주, 이 순간들을 남길까요? | Keep these moments from last week? |
| 지난주를 남겼어요. | Last week is saved. |
| 매주 월요일 저녁에 알려드릴까요? | Want a reminder every Monday evening? |
| 지난주를 1분 만에 남겨볼까요? | Take a minute to save last week. |
| Weekkeep은 별도 백업을 제공하지 않아 앱을 삭제하거나 기기를 바꾸면 기록이 사라질 수 있어요. | Weekkeep doesn't provide a separate backup, so records may be lost if you delete the app or change devices. |
| 원본 사진은 사진 앱에 남아 있어요. | Your original photos stay in Photos. |

영어는 직역보다 App Store 원어민 검수를 거칩니다. `keep`은 브랜드 문장에 남기되 행동·상태 카피에서는 자연스러운 `save`를 우선합니다.

## 13. Accessibility

### 필수

- Dynamic Type 모든 accessibility size
- VoiceOver logical order와 custom action
- 최소 44×44pt hit target
- 색상 하나만으로 상태 구분 금지
- Reduce Motion 대응
- Increase Contrast / Differentiate Without Color 확인
- decorative image는 VoiceOver에서 숨김
- 사진 설명은 확인 가능한 날짜/순서만 제공
- modal focus가 배경으로 빠지지 않음

### VoiceOver 예시

```text
“3월 8일 오후 2시 사진, 7장 중 3번째, 선택 안 됨. 두 번 탭하여 교체 대상으로 선택. 동작 사용 가능: 크게 보기, 사진 교체.”
```

선택된 photo의 기본 action은 viewer를 열고, 선택되지 않은 photo의 기본 action은 선택 상태를 만듭니다. `크게 보기`와 `사진 교체` custom action은 이 순서를 우회합니다. 사진 속 사람이나 감정을 추측해 accessibility label에 넣지 않습니다.

### 큰 글자 대응

- inline CTA가 content를 덮지 않고 마지막 photo와 privacy note 뒤에서 도달 가능함
- 2-column card가 한 column으로 바뀔 수 있음
- Settings trailing status가 아래 줄로 wrap 가능
- paywall legal links가 잘리거나 가로 scroll되지 않음

## 14. Localization

- source language English 또는 명확히 결정된 base locale로 String Catalog 사용
- 모든 사용자 문자열 String Catalog key 사용
- 날짜 범위는 `Date.FormatStyle` 사용
- 12/24시간 표기는 locale 따름
- 주 시작은 제품 규칙상 월요일이지만 날짜 문구는 locale로 표현
- 한국어 조사는 숫자/동적 값과 결합할 때 문장 전체를 localization
- 영어 30% expansion, 독일어 등 향후 40% expansion을 견딜 layout
- 사진 장수 pluralization은 String Catalog plural category 사용

## 15. Brand mark, Iconography와 App Icon 방향

### Brand mark hierarchy

- primary wordmark는 사용자가 제공한 canonical lowercase `weekkeep` asset이며 Plum `#5B415E`, flat fill을 유지합니다. 앱에서는 `design/brand/weekkeep-wordmark.png`를 image resource로 등록해 exact content를 렌더링하며 Text approximation을 사용하지 않습니다.
- onboarding upper-left와 앱 header·navigation처럼 작은 제품 surface에는 canonical wordmark-only를 사용하고 rainbow, 요일명, bracket, outline, shadow, tint를 붙이지 않습니다.
- 웹 hero·Shipaton end card·press kit 같은 외부 브랜드 surface에는 wordmark 아래에 **같은 크기와 간격의 horizontal seven-stitch**를 결합한 lockup을 사용할 수 있습니다.
- 외부 seven-stitch lockup도 app icon과 같은 muted red→orange→yellow→green→blue→indigo→violet 순서와 단색 규칙을 사용합니다. 최소 digital 폭은 120px이며 그보다 작으면 wordmark-only로 전환합니다.
- `MON`–`SUN` label과 좌우 bracket은 캠페인 illustration에는 사용할 수 있지만 primary logo 구성요소가 아니며, 작은 크기·다국어 surface에는 사용하지 않습니다.
- canonical asset과 출처는 [`design/brand/`](../design/brand/README.md)가 소유합니다.

### SF Symbols

- 기본 control icon은 SF Symbols 사용
- symbol만으로 의미가 불명확하면 text label 병행
- filled/outline은 selected/unselected 상태에 일관 사용
- sparkle symbol은 V1에서 사용하지 않음; top-level tabs는 `CMP-13 SemanticTabIcon`의 고유 semantic glyph만 사용하고 decorative seven-stitch는 표시하지 않음

### App icon creative brief

- 개념: Plum keepsake 위에 일주일의 일곱 순간을 꿰맨 **seven-stitch**
- 형태: 작은 크기에서도 식별되는 하나의 강한 silhouette와 정확히 7개의 둥근 stitch
- 배경/몸체: full-bleed Cream `#FBF7F2`, Plum `#5B415E`; 투명 여백이나 미리 둥글린 모서리를 넣지 않음
- stitch 순서: 왼쪽부터 빨강·주황·노랑·초록·파랑·남색·보라. 순서를 뒤집거나 섞지 않음
- stitch는 모두 같은 크기·간격·불투명도이며 gradient, glow, 그림자 없이 단색으로 표현
- 금지: 아기 얼굴, 젖병, 성별색, 숫자 7을 달력 badge처럼 직접 표기, 과도한 gradient/gloss
- 1024×1024 opaque sRGB master에서 만들고 알파 채널 없이 export; Apple의 시스템 mask가 모서리를 처리함

#### App icon stitch palette

| 순서 | 이름 | Hex | 기존 palette와의 관계 |
|---:|---|---|---|
| 1 | Memory Red | `#E97A68` | Memory Coral 그대로 사용 |
| 2 | Warm Orange | `#E39455` | Coral과 Golden Hour의 중간 온도 |
| 3 | Golden Yellow | `#E5A84B` | Golden Hour 그대로 사용 |
| 4 | Keepsake Green | `#66836E` | Sage를 아이콘 크기에 맞게 조금 밝힘 |
| 5 | Album Blue | `#5F879B` | Ink/Sage와 조화되는 저채도 blue |
| 6 | Evening Indigo | `#686286` | Plum과 blue 사이의 저채도 indigo |
| 7 | Memory Violet | `#8A6386` | Plum을 아이콘 크기에 맞게 밝힌 violet |

이 7색은 `D-030`이 소유하는 Weekkeep muted rainbow입니다. 앱 아이콘, 외부 lockup, 인앱 `CMP-12 SevenStitchRail`이 같은 index order를 공유하며, 인앱 rail의 진행·선택·완료·muted 의미는 색을 교체하지 않고 opacity와 geometry로 표현합니다. `CMP-13 SemanticTabIcon`은 bottom tab bar에서 Plum semantic glyph만 렌더링하고 decorative rainbow signature를 포함하지 않습니다. 앱 아이콘의 벡터 master와 production PNG는 `design/app-icon/`에서 소유하고 `Weekkeep/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`로 동기화합니다. 이번 visual revision에서는 이 AppIcon 파일을 변경하지 않습니다.

최종 아이콘은 실제 홈 화면 29/40/60pt에서 다음을 확인합니다: stitch 7개가 각각 분리되어 보임, rainbow 순서를 인식할 수 있음, 숫자 7이나 달력으로 오인되지 않음, Cream/Plum silhouette가 배경화면 색과 관계없이 유지됨.

## 16. App Store와 Shipaton Visuals

Screenshot의 순서·headline·locale·export 규격은 [App Store Metadata SSOT](10-APP-STORE-METADATA.md#5-screenshot-ssot)가 소유합니다. Shipaton 영상의 시간표와 narration은 [Shipaton Submission SSOT](11-SHIPATON-SUBMISSION.md#7-72-second-demo-master)가 소유합니다. 이 절은 그 자산의 시각 표현 규칙만 소유합니다.

### 제작 규칙

- App Store set은 현재 Apple 허용 규격을 사용하고, Shipaton proof는 정확히 1179×2556으로 별도 export
- Shipaton proof에 device frame 사용 금지
- captured app screen은 native full-screen surface를 그대로 보여주며 nested gray sheet chrome, bezel, device-like frame을 추가하지 않음
- App Store Plus 화면은 flat `FixturePhotoStory`와 canonical lowercase wordmark vocabulary를 유지하고 marketing compositor가 앱 안쪽 mockup을 다시 감싸지 않음
- website hero와 `og.png`도 같은 flat seven-photo story를 사용하며 3D album/device mockup과 capitalized wordmark를 금지
- 사용자 허가를 받은 사진 또는 라이선스/fixture 사진만 사용
- screenshot text는 영어 제출본 우선, 별도 한국어 App Store 세트
- 사진 식별자, debug overlay, 개인 notification을 화면 녹화에 노출하지 않음

## 17. Theme 구현 계약

Design System은 root에서 semantic theme를 주입합니다.

```swift
struct WeekkeepTheme: Sendable {
    let colors: WeekkeepColors
    let spacing: WeekkeepSpacing
    let radii: WeekkeepRadii
    let motion: WeekkeepMotion
}
```

규칙:

- feature View에서 raw hex 사용 금지
- `Color.purple`, `.orange` 같은 의미 없는 system color 직접 사용 금지
- typography는 extension으로 semantic role 제공
- custom typography는 `LINESeedSansKR-Regular/Bold`만 등록하고 semantic relative style로 scale
- high-contrast 변형은 component 내부 조건문이 아니라 token resolver에서 처리
- Preview는 light, ko/en, normal/accessibility text 조합 제공

## 18. Design QA Matrix

각 P0 화면을 아래 조합으로 확인합니다.

| 차원 | 값 |
|---|---|
| Appearance | Light |
| Text | Default, XXXL, Accessibility 5 |
| Language | Korean, English |
| Permission | Full, Limited, Denied |
| Data | 0, 1, 5, 7 photos, missing asset |
| Motion | Default, Reduce Motion |
| Review interaction | Unselected, selected, viewer, VoiceOver direct actions |
| Review framing | Clean top story; intentional lower-action state after scroll; no screenshot-only compression |
| Contrast | Default, Increase Contrast |
| Device | smallest supported width, 6.1-inch, largest iPhone |

## 19. Usability Validation

### 5명 prototype test

대상: 0–6세 자녀를 둔 iPhone 사용자 5명

과업:

1. 앱이 무엇을 하는지 첫 화면에서 설명해 보기
2. Photos limited 접근을 선택했다고 가정하고 첫 기록 만들기
3. 마음에 들지 않는 사진 한 장 교체하기
4. 저장 뒤 지난 기록 다시 찾기
5. 세 번째 기록을 만들고 가격/상품 형태 설명해 보기

관찰 지표:

- 도움 없이 첫 CTA 선택 여부
- permission 이해와 불안 표현
- 교체 action 발견 시간
- ‘7장 미만’ 결과를 오류로 해석하는지
- paywall이 구독인지 평생 이용권인지 정확히 이해하는지
- 평생 이용권을 데이터 영구 백업으로 오해하지 않는지
- 앱 삭제·기기 변경 시 Weekkeep 기록이 사라질 수 있음을 이해하는지
- ‘아이를 자동 식별한다’고 오해하는지

### 통과 기준

- 5명 중 4명 이상이 제품 가치를 15초 내 설명
- 5명 중 4명 이상이 교체를 10초 내 발견
- 5명 모두 사진이 외부 전송되지 않는다고 정확히 이해
- 5명 모두 상품을 평생 이용권으로 이해
- 5명 중 4명 이상이 Plus 복원과 주간 기록 복원을 구분
- 심각한 접근성/막다른 흐름 0건

## 20. Design Definition of Done

- [ ] 모든 화면이 semantic token만 사용
- [ ] Light/Increase Contrast 검증
- [ ] Dynamic Type와 VoiceOver 검증
- [ ] 0/1/5/7/missing photo state 디자인 존재
- [ ] full/limited/denied/restricted 상태가 시각·카피로 구분됨
- [ ] loading/partial/error가 서로 다른 패턴임
- [ ] primary action은 화면당 하나
- [ ] 사진 위 흰 텍스트 대비 문제 없음
- [ ] 한국어/영어 truncation 없음
- [ ] Weekly Review semantic spacing hierarchy와 top/lower screenshot framing 검증
- [ ] screenshot fixture launch path에 0–2pt feature stack/grid override 없음
- [ ] paywall에 현지화 가격, 복원, 약관, 닫기 존재
- [ ] Settings·paywall 개인정보 맥락에 로컬 보존 한계 ko/en 존재
- [ ] 평생 이용권을 데이터 영구 보존으로 오해시키는 문구 0
- [ ] guilt, streak, child identity 문구 없음
- [ ] stitch가 보이는 모든 상태에서 정확히 7개이며 index별 D-030 palette, state opacity/geometry test 통과
- [ ] 세 bottom-tab icon이 실제 tab-bar 크기에서 calendar/week·stacked album/pages·adjustment sliders로 즉시 구분되고, 각 original-rendered asset이 고유 이름·silhouette·decorative stitch 0개 계약을 통과
- [ ] onboarding wordmark가 canonical image resource이며 PNG가 design source와 byte-identical
- [ ] onboarding keepsake preview가 하나의 calm paper/cream card에서 승인된 seven fixture PNG를 모두 사용하고, `1+3+3`의 `space.3` 이상 gutter·non-overlap·small-radius clipping·vertical exact-seven binding을 유지하며 faux-content bars·overlapping card stack 없이 CTA가 Dynamic Type에서 도달 가능
- [ ] onboarding·Ready·Plus·website hero·`og.png`가 같은 flat `FixturePhotoStory` photo vocabulary를 사용하고 gradient/SF Symbol fake-photo art·abstract keepsake cover·device mockup이 없음
- [ ] Plus가 item-driven full-screen으로 열리고 gray sheet chrome·nested rounded sheet·bezel이 없음
- [ ] progress의 filled + remaining = 7
- [ ] 최종 App Icon이 1024×1024 opaque sRGB, pre-rounded 0이며 red→orange→yellow→green→blue→indigo→violet의 같은 크기 stitch 정확히 7개
- [ ] `scripts/validate-release-assets.sh` 통과와 29/40/60pt 육안 검증
- [ ] ready 화면이 foreground 분석 완료를 허위 주장하지 않음
- [ ] 월요일 20:30 알림이 primer와 Settings에서 일치
- [ ] 실제 app과 제출 screenshot이 bundled LINE Seed TTF로 렌더링
- [ ] 첫 tap 선택→교체 reveal, 선택 photo 두 번째 tap→viewer, VoiceOver direct action 검증
- [ ] save confirmation의 60–80ms 순차 reveal과 Reduce Motion 짧은 fade 검증
- [ ] App Store/Shipaton export 규격은 `docs/10`, demo 규격은 `docs/11` 기준으로 검증

## 21. 참고 원칙

- [Apple — Design Principles](https://developer.apple.com/design/human-interface-guidelines/design-principles)
- [Apple — Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility/)
- [Apple — Privacy](https://developer.apple.com/design/human-interface-guidelines/privacy/)
