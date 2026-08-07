# Weekkeep App Screens V2 — Image Generation Prompt Set

> **재생성 기록입니다.** 제품·동작의 SSOT가 아니며 현재 권한 구조는 [Design SSOT](../README.md)를 따릅니다.

## 생성 계약

- 도구: OpenAI built-in `image_gen`
- use case: `ui-mockup`
- 출력: 853 × 1844 portrait, edge-to-edge, no device frame
- appearance: Light only
- typography direction: LINE Seed Sans KR Regular/Bold
- photo direction: ordinary Korean family iPhone camera roll; mixed clothes, clutter, imperfect crop, uneven light, occasional motion blur
- visible text: image generation 단계에서 직접 생성
- final stitch: image generation에 맡기지 않고 [`design/system`](../system/SEVEN-STITCH.md)의 vector를 overlay

## 공통 프롬프트

```text
Create one polished full-height iPhone screenshot for Weekkeep, a private weekly family-photo curation app. Use light mode only and an edge-to-edge 853 × 1844 portrait canvas with no device frame, hands, watermark, or presentation board.

Use a LINE Seed Sans KR-like friendly rounded Korean sans for all visible text. Never use serif or handwriting. Use warm off-white paper, near-black ink, solid plum primary action, memory coral accents, sage privacy/success, and linen borders. Keep compact native iOS hierarchy, generous whitespace, minimal shadows, one primary action, and realistic SwiftUI geometry. Avoid glassmorphism, decorative gradients, AI sparkle icons, confetti, streaks, guilt language, biometric graphics, and stock-photo perfection.

Do not generate final stitches, dashed rails, perforations, dotted progress, or repeated short-line motifs. Leave specified stitch areas empty. The exact seven-stitch vector is rendered afterward. Keep all Korean copy fully legible and correctly spelled.
```

## 01 — Onboarding Welcome

```text
Headline: "사진은 많은데,\n정리할 시간은 없으니까."
Body: "최근 완료된 월요일부터 일요일까지의 한 주로 시작해 최대 7장의 순간을 골라드려요.\n그 주에 적격 사진이 없으면 최근 7일을 대신 확인해요."
Privacy: "사진 고르기는 이 iPhone 안에서 이뤄져요"
Primary: "첫 주 추억 고르기"
Secondary: "사진 접근을 어떻게 쓰나요?"
Show seven candid photo regions in a paper album. No tab bar. Reserve exact seven-stitch rail and binding positions.
```

## 02 — This Week / Ready

```text
This is before the app looks through the photos. Never claim the album is ready yet.
Wordmark: "weekkeep"
Date: "8월 3일 – 9일"
Headline: "지난주의 순간을 남겨볼까요?"
Body: "지난주 사진에서 다시 보고 싶은 순간을 최대 7장 골라드려요."
Show the approved flat compact hero+2+4 photo story as an explanatory surface, with no overlapping card stack or claim that analysis has already finished.
Label: "지난주 사진 42장"
Privacy: "사진 고르기는 이 iPhone 안에서 이뤄져요"
Primary: "지난주 추억 고르기"
Tabs: "이번 주", "지난 기록", "설정"; first selected. Leave top rail and first-tab icon blank for exact vectors.
```

## 03 — Curation Progress

```text
Back: "이번 주"
Headline: "소중한 순간을 고르고 있어요"
Body: "지난주의 사진에서 다시 보고 싶은 순간을 찾고 있어요."
Stage: "비슷한 사진을 정리하는 중"
Count: "사진 28 / 42"
Privacy: "사진 고르기는 이 iPhone에서 처리해요"
Secondary: "취소"
Reserve a seven-position progress rail; deterministic overlay shows four coral and three muted. Reserve seven-position vertical album binding.
```

## 04 — Weekly Review

```text
Back: "이번 주"
Date: "8월 3일 – 9일"
Headline: "지난주, 이 순간들을 남길까요?"
Body: "이번 주에 남길 순간 n장을 골라봤어요. 마음에 들지 않는 사진만 바꿔보세요."
Show the actual 1–7 candid photo regions. One selected photo has label "바꿀 사진으로 골랐어요".
Helper: "바꾸고 싶은 사진을 눌러주세요."
Secondary: "이 사진 바꾸기"
Privacy: "사진 고르기는 이 iPhone 안에서 이뤄져요"
Primary: "사진 n장 남기기"
Interaction intent: first tap selects one photo and reveals the replace action; tapping that selected photo again opens the full-screen viewer. Do not imply that the first tap immediately opens the viewer.
```

## 05 — Photo Viewer

```text
Light viewer with close button and position "1 / 7". Show one large candid photo and exactly seven thumbnails; first selected. Helper: "좌우로 넘겨보세요". Primary outlined action: "이 사진 바꾸기". No share, edit, like, comment, filter, or metadata menu.
```

## 06 — Save Confirmation

```text
Date: "8월 3일 – 9일"
Headline: "지난주가\n작은 앨범이 됐어요"
Metadata: "사진 7장 · 이 iPhone에 저장됨"
Supporting copy: "평범한 한 주도,\n나중에 다시 꺼내 볼 수 있는 기록이 됐어요."
Show the actual saved photos in one album sheet.
Primary: "이 앨범 공유하기" (opens local Story/Post preparation)
Secondary: "기록 보기"
Tertiary: "완료"
Reserve exact seven-stitch completion rail in sage. No confetti or notification primer in this screen.
```

## 07 — Replace Photo Sheet

```text
Blur the review screen behind a native light bottom sheet.
Title: "어떤 사진으로 바꿀까요?"
Context label: "지금 사진"
Alternative label: "다른 사진"
Show the current photo plus available alternatives with readable local date/time captions. The selected alternative uses a coral outline/check. Action: "취소". No library search, filter, or confirm button.
```

## 08 — Notification Primer

```text
Blur the save-confirmation screen behind a light bottom sheet.
Headline: "지난주를 남길 때 알려드릴까요?"
Body: "월요일 저녁, 여유가 될 때 다시 볼 수 있도록 알려드릴게요."
Schedule: "매주 월요일" / "오후 8:30"
Primary: "알림 받을게요"
Secondary: "지금은 괜찮아요"
Never mention Sunday as the reminder day and never claim the album already exists.
```

## 09 — Plus Paywall

```text
Brand: "weekkeep plus"
Value proof: two previously saved week cards.
Overline: "두 주를 남겼어요"
Headline: "매주 작은 앨범을\n계속 남겨요"
Body: "이미 저장한 기록은 Plus 없이도\n이 iPhone에서 계속 볼 수 있어요."
Benefits: up to seven moments to keep each week, photo selection and share rendering happen on your iPhone, and one-time lifetime access.
Product: "평생 이용권" / initial KR expected fixture "₩29,000"; production uses the RevenueCat/App Store localized price
Primary: "평생 이용 시작하기"
Links: "구매 복원", "이용 약관", "개인정보 처리방침"
No urgency, discount, subscription framing, or blocked archive.
```

## 10 — Weeks Archive

```text
Wordmark: "weekkeep"
Title: "지난 기록"
Body: "남긴 주간 기록을 한곳에서 다시 볼 수 있어요."
Show three vertically stacked album cards, each labeled with the actual photo count:
"8월 3일 – 9일", "7월 27일 – 8월 2일", "7월 20일 – 26일".
Do not show a year/month filter for only three records.
Tabs: "이번 주", "지난 기록", "설정"; middle selected. Leave first-tab icon blank for the exact muted vector.
```

## 11 — Week Detail

```text
Back: "지난 기록"
Overline: "우리 가족의 한 주"
Title: "7월 27일 – 8월 2일"
Metadata: "사진 7장 · 이 iPhone에 저장됨"
Show exactly seven photo regions: one hero plus six supporting.
Helper: "사진을 눌러 크게 보세요."
Show a restrained top-trailing local share action. No overflow, edit, delete, or bottom tab bar; social feed and cloud upload are out of scope.
```

## 12 — Settings

```text
Wordmark: "weekkeep"
Title: "설정"
Helper: "기억하고 싶은 한 주를 가볍게 남겨요."
Sections and rows:
"사진" — "사진 접근" / "전체 접근", "사진 접근 관리"
"알림" — "주간 알림" / "월요일 오후 8:30", "알림 설정 열기"
"Weekkeep Plus" — "이용 상태" / "무료 이용 중", "Weekkeep Plus 알아보기", "구매 복원"
"저장과 도움" — "데이터 저장" / "이 iPhone만", "사진과 개인정보" / "사진 고르기는 이 iPhone에서", "도움말 및 문의"
Footer: "Weekkeep 1.0 (1)"
Tabs: "이번 주", "지난 기록", "설정"; third selected. Leave first icon blank for vector.
```

## 13 — Privacy

```text
Back: "설정"
Overline: "사진과 개인정보"
Headline: "사진 고르기는 이 iPhone 안에서 이뤄져요"
Body: "사진 고르기와 공유 이미지 만들기는 이 iPhone에서 처리해요. 사진 정보는 사용 통계나 다른 서비스의 분석을 위해 보내지 않아요. 공유는 직접 선택할 때만 시작돼요."
Diagram labels: "사진 앱" → "기기 안의 Weekkeep" and blocked "서버 전송 없음". Use one solid arrow only; no dotted connector.
Facts:
"사진 고르기는 이 iPhone 안에서 이뤄져요" / "Weekkeep을 사용하는 동안 사진 고르기와 공유 이미지 만들기는 이 iPhone에서 처리해요."
"사진 정보는 분석에 보내지 않아요" / "사진 이름·위치·촬영 시각·미리보기 같은 정보는 분석 서비스나 다른 서비스의 분석을 위해 보내지 않아요. 공유는 직접 선택할 때만 시작돼요."
"내가 결정" / "사진 접근은 언제든 설정에서 바꿀 수 있어요."
Storage card:
"기록은 이 iPhone에만 저장돼요"
"Weekkeep은 별도 백업을 제공하지 않아 앱을 삭제하거나 기기를 바꾸면 기록이 사라질 수 있어요. 원본 사진은 사진 앱에 남아 있어요."
Action: "사진 접근 설정 열기"
```

## 14 — About & Support

```text
Back: "설정"
Title: "도움말 및 문의"
Brand: lowercase "weekkeep" in bold rounded sans; leave rail space blank.
Tagline: "사진은 많고 시간은 없으니까,\n한 주의 순간만 가볍게 남겨요."
Body: "평범한 한 주도 다시 꺼내 볼 앨범이 될 수 있어요."
Rows: "도움말", "문의하기", "이용 약관", "개인정보 처리방침", "오픈소스 라이선스"
Font row: "사용한 글꼴" / "LINE Seed Sans KR"
Footer: "Weekkeep 1.0 (1)", "Made with care in Seoul", "앱 평가하기"
Overlay exact seven-stitch coral rail below the wordmark.
```

## 최종 QA

- 모든 화면 853 × 1844
- dark surface 0
- stitch가 나타나는 모든 위치의 count = 7
- progress rail total = 7
- photo detail total = 7
- 알림 = 월요일 20:30
- Ready 화면은 사진을 살펴보기 전이며, 결과가 이미 마련됐다고 주장하지 않음
- archive 3개 상태에는 year filter 없음
- detail에는 local share action이 있고 social feed/edit/delete는 없음
- 실제 앱/제출 screenshot은 등록된 LINE Seed TTF로 렌더링
