# Weekkeep App Screens V1 — Image Generation Prompt Set

> **Legacy prompt archive — 재사용 금지.** 아래에는 현재 계약과 다른 font·tab icon·Sunday reminder copy가 포함돼 있습니다. 재생성은 [V2 Prompt Set](../app-screens-v2/PROMPTS.md)을 사용합니다.

## 생성 모드

- 도구: OpenAI built-in `image_gen`
- use case: `ui-mockup`
- 입력 레퍼런스: `00-style-reference.png`
- 레퍼런스 역할: style + fictional-family consistency reference only
- 출력: full portrait app screenshot, 853:1844, no device bezel
- Appearance: **Light mode only**

각 화면을 다시 만들 때 아래 `공통 프롬프트` 뒤에 해당 `화면 프롬프트`를 이어 붙입니다. 모든 텍스트는 후처리로 합성하지 않고 이미지 생성 단계에서 직접 렌더링합니다.

## 공통 프롬프트

```text
Use case: ui-mockup.

Image 1 is the visual style and fictional-family consistency reference only. Do not edit Image 1. Generate a brand-new LIGHT-MODE screen for the same iPhone app, Weekkeep. Weekkeep V1 has no dark mode.

Create a clean 853:1844 portrait app screenshot with no device bezel, hands, watermark, or presentation board. Match Image 1's mature Warm Private Family Album direction: warm cream paper background, generous 38–40 px side margins, deep near-black ink Korean typography, coral accent, sage privacy/status accent, dark plum primary action, white/paper surfaces, 20–26 px rounded corners, airy editorial spacing, premium native iOS polish, realistic to implement in SwiftUI. Preserve the same fictional Korean parents and one preschool-age child whenever family photos appear. Avoid baby-app motifs, cartoons, social features, streaks, confetti, surveillance graphics, face boxes, dark surfaces, and decorative clutter. One clear primary action per screen. All visible UI text must be generated directly, legible, natural Korean, and exactly as specified.
```

## 01 — Onboarding Welcome

```text
Create the first-run welcome screen with no tab bar. At the top, show a large rounded hero family photo and six smaller photos in a clean 3-column by 2-row grid. Do not place text over photos.

Render exact copy:
"아이와 보낸 일주일,\n사진 7장으로 남겨요."
"지난 7일의 사진을 기기에서 골라드려요."
Privacy badge with lock: "사진은 이 iPhone에서만 분석돼요"
Primary button: "지난 7일 남기기"
Text link: "사진 접근을 어떻게 사용하나요?"
```

## 02 — This Week / Ready

```text
Create the This Week ready tab-root screen. Top coral pill: "이번 주". Date: "8월 3일 – 9일". Large title: "이번 주가\n준비됐어요". Sage lock row: "이 iPhone에서만 분석". Show a large rounded album-preview card with a staggered stack of three warm family photos and the line "지난 7일의 순간을 함께 골라볼까요?". Primary button: "사진 고르기".

Bottom tab bar labels: "이번 주", "지난 주들", "설정". The first tab is selected in plum.
```

## 03 — Curation Progress

```text
Create an in-flow progress screen with no tab bar. Top back label: "이번 주". Large title: "이번 주를\n고르는 중이에요". In a white rounded progress card show seven candid thumbnails, some softly faded, with no biometric/scanning overlay. Current stage: "비슷한 사진을 정리하는 중". Thin determinate progress bar at about two-thirds. Count: "사진 28 / 42". Sage lock reassurance: "사진은 이 iPhone을 떠나지 않아요". Bottom outlined action: "취소". No time estimate or fake percentage.
```

## 04 — Weekly Review

`04-weekly-review.png`는 사용자가 선택한 기준 이미지를 그대로 보존한 화면입니다. 최초 탐색 프롬프트는 [`../concepts/PROMPTS.md`](../concepts/PROMPTS.md)의 **3. Warm Private Family Album**을 참조합니다.

## 05 — Photo Viewer

```text
Create a light-mode focused photo viewer. Cream background only. Top-left circular paper close button with X. Center "3 / 7". Show one large portrait candid family photo inside a softly rounded white album mat; the child paints while both parents lean in. No text over the photo. Below it show exactly seven rounded thumbnails; the third has a coral outline. Bottom outlined plum button: "이 사진 교체". No share, edit, like, comment, filter, metadata panel, or right-side menu.
```

## 06 — Save Confirmation

```text
Create a quiet save-confirmation screen. At top show a sage circular checkmark and "8월 3일 – 9일". Large title: "이번 주를 남겼어요.". Supporting copy: "평범한 순간들이 한 주의 기억이 되었어요.". Show exactly seven photos in a paper album: one hero, two medium, four small. Primary button: "기록 보기". Secondary text button: "완료". No notification request on this screen and no confetti, score, streak, trophy, or tab bar.
```

## 07 — Replace Photo Sheet

```text
Show the Weekly Review recognizable behind a warm translucent scrim. Present a native full-height white bottom sheet with rounded top corners and grabber. Title: "어떤 순간으로 바꿀까요?". Supporting copy: "사진을 탭하면 바로 바뀌어요". Upper-right action: "취소". Show six equal candidate photos in a 2-column grid with exact captions:
"8월 4일 오후 3:12"
"8월 5일 오전 9:20"
"8월 6일 오후 6:40"
"8월 7일 오전 10:05"
"8월 8일 오후 2:18"
"8월 9일 오전 11:32"
The first candidate has a coral outline and checkmark. No confirm CTA, search, filters, or library picker.
```

## 08 — Notification Primer

```text
Show the save-confirmation screen softly blurred and lightly dimmed behind a white native bottom sheet. Use a refined sage bell icon with a tiny coral dot. Title: "매주 일요일에\n알려드릴까요?". Body: "한 주의 순간을 놓치지 않도록\n저녁 8시 30분에 알려드릴게요.". Small schedule card: "매주 일요일" and "오후 8:30". Primary button: "알림 받기". Secondary text button: "지금은 괜찮아요". Do not show the iOS system permission alert.
```

## 09 — Plus Paywall

```text
Create a light full-height paywall that feels like an app surface, not an ad. Top-left X and centered "Weekkeep Plus". Show two compact overlapping album cards with captions "7월 20일 – 26일" and "7월 27일 – 8월 2일". Headline: "앞으로의 주들도\n계속 남겨요.". Supporting line: "지난 기록은 계속 볼 수 있어요.". Benefit rows:
"매주 새로운 주간 기록"
"사진은 계속 기기에서 분석"
"한 번 구매로 평생 이용"
Product card: "평생 이용권" and "₩29,000".
Primary button: "Weekkeep Plus 시작하기".
Links: "구매 복원", "이용 약관", "개인정보 처리방침".
No countdown, fake discount, crossed-out price, urgency, or social proof.
```

## 10 — Weeks Archive

```text
Create the archive tab root. Large title: "지난 주들". Section label: "2026". Show three spacious rounded week cards, each with a four-photo collage, chevron, exact date, and "사진 7장":
"8월 3일 – 9일"
"7월 27일 – 8월 2일"
"7월 20일 – 26일"
Bottom tabs: "이번 주", "지난 주들", "설정". Select the second tab in plum. No calendar grid, edit, share, or delete menu.
```

## 11 — Week Detail

```text
Create a read-only saved-week detail with no tab bar. Back label: "지난 주들". Center title: "7월 27일 – 8월 2일". Coral pill: "지난 주". Large title: "우리 가족의 지난 주". Secondary line: "사진 7장". Show exactly seven photos: one 16:10 hero family meal, two medium photos, four small photos. Bottom sage lock reassurance: "사진은 이 iPhone에만 있어요". No editing, replace, save, share, delete, or overflow menu.
```

## 12 — Settings

```text
Create a native light iOS grouped Settings screen. Large title: "설정".

Section "사진": "사진 접근" / "전체 접근"; "사진 접근 관리".
Section "알림": "주간 알림" / "일요일 오후 8:30"; "알림 설정 열기".
Section "Weekkeep Plus": "이용 상태" / "무료 이용 중"; "Weekkeep Plus 알아보기"; "구매 복원".
Section "개인정보": "사진과 개인정보" / "기기 내 처리".
Section "도움말": "도움말 및 문의".
Footer: "Weekkeep 1.0 (1)".
Bottom tabs: "이번 주", "지난 주들", "설정". Select Settings in plum. No account, profile, cloud sync, AI settings, or fake permission switches.
```

## 13 — Privacy

```text
Create a privacy detail. Back label: "설정". Large title: "사진과 개인정보". Sage shield-lock icon. Headline: "사진은 이 iPhone을\n떠나지 않아요". Supporting copy: "Weekkeep은 사진을 기기 안에서만 분석해요.".

Card 1: "기기 안에서 분석" / "사진과 썸네일을 서버로 보내지 않아요."
Card 2: "추적하지 않음" / "사진 이름, 위치, 촬영 시각을 분석 도구에 보내지 않아요."
Card 3: "내가 결정" / "사진 접근은 언제든 설정에서 바꿀 수 있어요."
Bottom outlined button: "사진 접근 설정 열기".
No surveillance imagery, face scanning, cloud illustration, or legal wall of text.
```

## 14 — About & Support

```text
Create an About & Support detail. Back label: "설정". Title: "도움말 및 문의". Brand block: "Weekkeep" and seven tiny coral rounded marks in one horizontal row. Tagline: "아이와 보낸 일주일, 사진 7장으로 남겨요.".

Grouped list rows: "도움말", "문의하기", "이용 약관", "개인정보 처리방침", "오픈소스 라이선스".
Version: "Weekkeep 1.0 (1)".
Copyright line: "Made with care in Seoul".
Bottom text link: "앱 평가하기".
```

## 제외한 시안

사진 확대 화면의 초기 다크 배경 탐색본은 사용자 결정에 따라 폐기했습니다. V1 세트와 재생성 프롬프트에는 라이트 모드 버전만 포함합니다.
