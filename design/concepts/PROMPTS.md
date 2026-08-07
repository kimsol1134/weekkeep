# Weekkeep Design Exploration — Image Generation Prompts

> **Deprecated prompt archive.** 현재 화면을 재생성하거나 구현할 때 사용하지 않습니다. [Design SSOT](../README.md)를 따릅니다.

모든 이미지는 OpenAI built-in `image_gen`을 사용해 새로 생성했습니다. 외부 앱 screenshot은 입력 이미지로 사용하지 않았고, 공개 제품 조사는 방향 분석에만 사용했습니다.

## 1. Quiet Editorial Album

```text
Use case: ui-mockup
Asset type: high-fidelity iPhone app screen concept for Weekkeep, a private weekly family memory app
Primary request: Design Direction 1, “Quiet Editorial Album.” Create a shippable weekly review screen that feels like a premium Scandinavian photo book: calm, restrained, warm, photo-first, mature rather than baby-cute.
Scene/backdrop: full portrait mobile UI canvas only, edge-to-edge app screenshot, no iPhone hardware frame
Subject: a weekly review screen with exactly seven candid photographs of the same fictional Korean family with a young child, arranged as one generous hero image plus a refined asymmetrical editorial mosaic. The photos should feel natural, ordinary and warm: park walk, breakfast, drawing, bedtime book, small laugh, playground, holding hands.
Style/medium: realistic polished iOS product UI, not concept art; editorial whitespace; subtle paper-album feeling; precise practical hierarchy
Composition/framing: cream background #FBF7F2, ink text #25212B, plum primary action #5B415E, restrained coral accent #E97A68, 20pt-like margins, subtle 16–24pt corner radii, minimal shadow. Large photo area and a full-width bottom action.
Text (verbatim, render each exactly once unless noted): "이번 주"; "8월 3일 – 9일"; "이번 주, 이 순간들을 남길까요?"; "사진 고르기는 이 iPhone에서 이뤄져요"; "교체"; "7장의 사진"; "이번 주 남기기"
Typography: exceptionally legible Korean typography, contemporary Apple-system-like sans serif, with an optional restrained editorial serif only for the date; clear Dynamic-Type-friendly sizing
Constraints: exactly seven photos; one obvious replace control connected to one photo; one primary button; no captions, no social feed, no likes, no comments, no streak, no AI sparkle, no child name, no logos, no trademarks, no watermark, no extra text, no phone bezel or device mockup. The UI must look feasible to implement in SwiftUI and suitable for a real App Store screenshot.
Avoid: pastel overload, cartoon baby motifs, scrapbook stickers, glossy 3D, dense controls, white text on coral.
```

## 2. Seven-Day Rhythm

```text
Use case: ui-mockup
Asset type: high-fidelity iPhone app screen concept for Weekkeep, a private weekly family memory app
Primary request: Design Direction 2, “Seven-Day Rhythm.” Create a shippable weekly review screen whose signature is a calm Monday-to-Sunday rhythm, inspired by the clarity of a calendar and a one-moment-per-day journal, while remaining warm and photo-first.
Scene/backdrop: full portrait mobile UI canvas only, edge-to-edge app screenshot, no iPhone hardware frame
Subject: exactly seven candid photographs of the same fictional Korean family with a young child, one visual moment for each day. Arrange them in an elegant weekly composition: a slim seven-day ribbon at the top with labels "월", "화", "수", "목", "금", "토", "일", then a modular editorial grid where each photo has a tiny day marker. Make Sunday subtly highlighted as the weekly ritual, not as a warning. Include a single replace action for the currently focused photo.
Style/medium: realistic polished iOS product UI, not concept art; structured and rhythmic but not like a productivity calendar
Composition/framing: warm cream background #FBF7F2, ink #25212B, sage #537763, plum #5B415E, golden accent #E5A84B used sparingly. Clear 4pt-grid spacing, soft 16pt photo corners, no heavy shadows, full-width bottom action.
Text (verbatim): "이번 주"; "8월 3일 – 9일"; "이번 주의 일곱 순간"; "월"; "화"; "수"; "목"; "금"; "토"; "일"; "사진 고르기는 이 iPhone에서 이뤄져요"; "교체"; "이번 주 남기기"
Typography: highly legible Korean system-like sans serif; compact weekday labels; strong accessible hierarchy
Constraints: exactly seven photos and seven weekday labels; photos should show plausible distinct ordinary moments across one week; one obvious replace control; one primary button; no social feed, no captions, no likes, no comments, no streak counter, no AI sparkle, no child name, no logos, no trademarks, no watermark, no extra text, no phone bezel. Feasible SwiftUI layout.
Avoid: corporate calendar dashboard, productivity charts, gamification, pastel baby motifs, dense metadata, glossy 3D.
```

## 3. Warm Private Family Album

```text
Use case: ui-mockup
Asset type: high-fidelity iPhone app screen concept for Weekkeep, a private weekly family memory app
Primary request: Design Direction 3, “Warm Private Family Album.” Create a shippable weekly review screen with the immediate clarity and friendliness of a family album that parents and grandparents could understand at a glance, but keep it mature, uncluttered, and premium.
Scene/backdrop: full portrait mobile UI canvas only, edge-to-edge app screenshot, no iPhone hardware frame
Subject: exactly seven candid photographs of the same fictional Korean family with a young child. Use a large welcoming cover photo, a simple rounded collage of six smaller moments, a highly visible privacy reassurance, an easy replace control, and one large save action.
Style/medium: realistic polished iOS product UI, not concept art; friendly native controls; generous readable type; soft rounded cards; approachable without feeling childish
Composition/framing: warm white background, paper cards, coral #E97A68 and sage #537763 accents, deep ink #25212B text, plum #5B415E button, spacious 20pt-like margins, 20pt card radius, soft surface separation rather than strong shadows
Text (verbatim, render each exactly once): "이번 주"; "8월 3일 – 9일"; "우리 가족의 이번 주"; "사진 고르기는 이 iPhone에서 이뤄져요"; "사진 7장"; "교체"; "이번 주 남기기"
Typography: large, highly legible Korean system-like sans serif, comfortable for tired parents and older family members
Constraints: exactly seven photos; one obvious replace control; one primary button; clear touch targets; no upload icon, no sharing invitation, no child age, no captions, no likes, no comments, no feed, no streak, no AI sparkle, no cartoon, no logos, no trademarks, no watermark, no extra text, no phone bezel. Feasible SwiftUI layout and accessible visual hierarchy.
Avoid: pink baby-app clichés, gender coding, overly cute blobs, cluttered family social network UI, tiny labels, glossy 3D.
```

## 4. Private Journal Cards

```text
Use case: ui-mockup
Asset type: high-fidelity iPhone app screen concept for Weekkeep, a private weekly family memory app
Primary request: Design Direction 4, “Private Journal Cards.” Create a shippable weekly review screen with calm native iOS journal-card architecture: one focused weekly suggestion card, strong privacy reassurance, clear system-like navigation, and almost no decoration.
Scene/backdrop: full portrait mobile UI canvas only, edge-to-edge app screenshot, no iPhone hardware frame
Subject: exactly seven candid photographs of the same fictional Korean family with a young child, arranged inside one elevated weekly memory card as a clean modular collage. Include a small date header, a privacy status card, one focused replace action, and one large save action. The page should feel like a trusted private journal rather than a family social feed.
Style/medium: realistic polished native iOS product UI, not concept art; soft material surfaces, precise spacing, clear system controls, subtle depth and translucency that remains feasible on iOS 18
Composition/framing: very light warm-gray background, white and pale plum cards, ink #25212B, plum #5B415E primary action, sage #537763 privacy status, restrained coral selection indicator. Rounded 20–24pt cards, crisp accessible typography, compact navigation bar.
Text (verbatim, render each exactly once): "Weekkeep"; "이번 주"; "8월 3일 – 9일"; "일곱 개의 순간이 준비됐어요"; "사진 고르기는 이 iPhone에서 처리해요"; "교체"; "이번 주 남기기"
Typography: exceptionally legible Korean Apple-system-like sans serif, native navigation proportions, accessible hierarchy
Constraints: exactly seven photos; the collage lives inside one coherent weekly card; one replace control; one primary button; no writing prompt, no text-entry field, no maps, no health data, no streak, no social feed, no comments, no likes, no AI sparkle, no child name, no logos besides the plain text Weekkeep, no trademarks, no watermark, no extra text, no phone bezel. Must look straightforward to implement in SwiftUI.
Avoid: copying Apple Journal screen exactly, purple gradient overload, floating plus button, glass that hurts contrast, dense metadata, baby motifs.
```

## 5. Weekly Contact Sheet

```text
Use case: ui-mockup
Asset type: high-fidelity iPhone app screen concept for Weekkeep, a private weekly family memory app
Primary request: Design Direction 5, “Weekly Contact Sheet.” Create a shippable weekly review screen that treats the seven selected photos like a refined analog contact sheet: tactile, memorable, slightly cinematic, and private, without becoming nostalgic costume design or a social app.
Scene/backdrop: full portrait mobile UI canvas only, edge-to-edge app screenshot, no iPhone hardware frame
Subject: exactly seven candid photographs of the same fictional Korean family with a young child. Present them as seven carefully aligned photographic frames with thin warm-paper borders and tiny frame numbers 01 through 07, including one larger featured frame and six supporting frames. Include one focused replace action and one strong save action.
Style/medium: realistic polished iOS product UI, not concept art; modern editorial photography contact sheet; mature analog warmth; highly usable
Composition/framing: deep ink/charcoal background #17151B, warm paper #F7F1EB, muted plum #5B415E, burnt coral #E97A68 and gold #E5A84B accents, crisp high-contrast labels, restrained 12pt photo corners, subtle film grain only in the background—not over the family photos
Text (verbatim, render each exactly once): "이번 주"; "8월 3일 – 9일"; "일주일을 한 장에"; "01"; "02"; "03"; "04"; "05"; "06"; "07"; "사진 고르기는 이 iPhone에서 이뤄져요"; "교체"; "이번 주 남기기"
Typography: highly legible Korean modern grotesk/system sans serif; small monospaced frame numbers; accessible contrast
Constraints: exactly seven photos and frame numbers 01–07; one replace control; one primary button; family photos retain natural color; no social feed, no likes, no comments, no postcard or sharing controls, no streak, no AI sparkle, no child name, no logos, no trademarks, no watermark, no extra text, no phone bezel. Feasible SwiftUI layout.
Avoid: fake film sprocket holes, sepia filter, grunge, hipster camera UI, neon, tiny unreadable text, heavy texture, glossy 3D.
```
