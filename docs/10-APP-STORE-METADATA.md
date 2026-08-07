# Weekkeep App Store Metadata SSOT

| 항목 | 값 |
|---|---|
| 기준일 | 2026-08-07 |
| 대상 버전 | iOS 1.0.0 — canonical ASC build 7 is the current attached review build; build 6 and its prior submission are historical/replaced, build 3 remains historical evidence, and build 4 is valid but unattached |
| Primary locale | English (U.S.) |
| 추가 locale | Korean |
| Bundle ID | `com.solkim.weekkeep` |
| SKU | `WEEKKEEP-IOS-2026` |
| 가격 | 앱 무료, Plus 비소모성 평생 이용권 US $19.99 |
| 상태 | ASC build 7 (`1c51b451-d37f-4704-89c9-e426b1ee5725`) is uploaded, `VALID`, and attached to version `ac4f183e-1019-4ffc-827f-f5514f0d349b`; current submission `6d2feeff-0f90-4b34-b0c8-b22a3b1928b7` is `WAITING_FOR_REVIEW` with exactly two `READY_FOR_REVIEW` items; previous submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00` is historical `COMPLETE` after replacement; build 6 is historical/replaced; build 3 submission `88c157ee-ce87-41c3-8a4a-71e614993a58` remains historical canceled/replaced; build 4 is `VALID` but unattached; IAP `weekkeep_plus_lifetime` remains `WAITING_FOR_REVIEW`; approval and public release remain pending |

이 문서는 App Store Connect에 입력하는 이름, 설명, 키워드, 카테고리, URL, 심사 메모, IAP metadata의 단일 원본입니다. 제품 범위와 가격은 [Decision Registry](00-INDEX.md#5-decision-registry--결정값과-상태의-ssot), 개인정보 답변은 [App Privacy Label](09-APP-PRIVACY-LABEL.md)이 소유합니다.

## 0. External build state

| 상태 | 값 | 의미 |
|---|---|---|
| Current submitted review build | `1.0.0 (7)` — ASC ID `1c51b451-d37f-4704-89c9-e426b1ee5725`, `VALID`, attached, uploaded `2026-08-07T08:28:29-07:00` | Current App Store Connect build for version `ac4f183e-1019-4ffc-827f-f5514f0d349b`; manual release; current submission is `6d2feeff-0f90-4b34-b0c8-b22a3b1928b7` |
| Historical TestFlight internal QA | `Weekkeep Internal QA` (`576fd29a-7a64-4521-9164-9697ec1c256f`) contains exactly historical build 6, `READY_FOR_BETA_TESTING`, and one invited verified account-holder tester (tester ID `bef018ab-9514-4388-804d-bcd363f601d4`, state `INVITED`) | Historical ready/invited distribution only; not installed, purchase-tested, or restore-tested |
| Historical/replaced build 6 | `1.0.0 (6)` — ASC ID `0ffa7586-619f-4df9-abc5-ae7ebbd068b1`, `VALID`, previously attached | Replaced by canonical build 7; previous submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00` is now `COMPLETE` historical |
| Historical build 3 | `1.0.0 (3)` — `VALID`, historical/non-target | Former submission `88c157ee-ce87-41c3-8a4a-71e614993a58` was canceled/replaced; its local evidence remains historical |
| Remote unattached valid build | `1.0.0 (4)` — ASC ID `6e92c470-c044-4512-9276-71491fe97685`, `VALID`, unattached | Historical/non-target external truth |
| Historical builds 1–2 and 5 | Historical/non-target | Preserved evidence; none is the current review target |

## 1. 앱 레코드와 분류

| 필드 | 입력값 | 근거/메모 |
|---|---|---|
| Platforms | iOS | iPhone only, iOS 18+ |
| Name (en-US) | `Weekkeep: Family Photo Album` | 28/30 characters |
| Name (ko) | `Weekkeep: 가족 사진 앨범` | 설치 후 표시 이름은 `Weekkeep` |
| Primary category | Photo & Video | binary의 `public.app-category.photo-video`와 일치 |
| Secondary category | Lifestyle | 부모의 주간 회고·가족 기록 맥락 |
| Made for Kids | No | 아이가 아니라 부모가 사용하는 앱 |
| Content rights | No third-party content catalog | 사용자가 접근을 허용한 자신의 Photos 자산만 표시 |
| Sign-in | Not required | 계정·백엔드 없음 |
| Copyright | `© 2026 Sol Kim` | 실제 App Store Connect 판매자명과 충돌하면 판매자명 기준으로 수정 |
| Availability | United States와 South Korea | ASC app availability configured with only USA/KOR available; public storefront check remains pending |
| Release method | Manual release | App Review 승인 뒤 공개일을 통제 |

출시 지역을 더 넓혀도 되지만, US와 KR에서 상품 가격·구매·복원·정책 URL을 실제 storefront로 확인하기 전에는 전 세계 공개로 전환하지 않습니다.

## 2. URL

| 필드 | URL |
|---|---|
| Marketing URL | Omit; the SSOT does not require the live root URL |
| Support URL | `https://weekkeep-app.kimsol1134.chatgpt.site/support` |
| Privacy Policy URL | `https://weekkeep-app.kimsol1134.chatgpt.site/privacy` |
| Privacy Choices URL | `https://weekkeep-app.kimsol1134.chatgpt.site/privacy` |
| Terms URL | Omit; ASC app-info schema has no terms URL field. Public `/terms` remains available from the app's supported policy links. |

실제 공개 URL은 Sites version 5로 `https://weekkeep-app.kimsol1134.chatgpt.site`에 배포되어 있으며 site tests는 8 passed, 0 failed입니다. 로그아웃 요청으로 `/privacy`, `/support`, `/terms`와 root가 HTTP 200인지 확인했습니다. App Store metadata의 Support, Privacy Policy, Privacy Choices URL은 이 public URL과 일치합니다. 앱이나 export artifact에 설치 URL을 하드코딩하지 않습니다.

## 3. English (U.S.) metadata

### Name

```text
Weekkeep: Family Photo Album
```

### Subtitle — 29/30 characters

```text
Up to seven moments each week
```

### Promotional text — 170 characters 이하

```text
Your camera roll is full. Weekkeep helps you keep up to seven moments from the past week on your iPhone, so one quiet minute becomes a family memory.
```

### Keywords — 100 bytes 이하

```text
family,memory,weekly,parents,baby,children,journal,private,organizer,keepsake,camera,diary
```

### Description

```text
Your camera roll is full of ordinary moments you meant to keep.

Weekkeep turns one week into a small family album of up to seven photos—without asking you to sort everything.

ONE QUIET MINUTE

On your first visit, start with your most recently completed local Monday–Sunday week. We check your most recent seven days only when that week has no photos Weekkeep can use. After that, a newly completed week waits for you each Monday. Weekkeep chooses up to seven moments on your iPhone. Keep the selection as it is, or change only the photos that do not feel right.

MADE FOR REAL FAMILY LIFE

• Up to seven moments, never a fake or empty slot
• A calm review instead of another daily habit
• Change only the photos that do not feel right
• A Weeks archive that keeps each album easy to revisit
• A shareable weekly album made on-device in Story 9:16 or Post 4:5 format
• An optional Monday evening reminder, scheduled locally
• English and Korean support

PRIVATE BY DESIGN

Photo selection and share rendering are processed on your iPhone. Weekkeep does not send photos, previews, filenames, capture times, locations, or other photo details to analytics services or other services for analysis. Sharing starts only when you explicitly choose it; Weekkeep then presents Apple’s system share sheet and does not choose or record the recipient. There is no Weekkeep account or Weekkeep cloud photo service.

Weekkeep stores album records locally and refers to the originals in Apple Photos. Deleting the app, changing devices, or deleting an original photo may make a record unavailable. Restoring a purchase restores Plus access, not locally stored albums.

TRY IT FIRST, KEEP IT FOR LIFE

Your first two weekly albums are included. Weekkeep Plus is a one-time lifetime purchase that unlocks future album creation. There is no subscription. Your local price is always shown before purchase.

A week worth keeping.
```

## 4. Korean metadata

### 이름

```text
Weekkeep: 가족 사진 앨범
```

### 부제

```text
최대 7장으로 남기는 일주일
```

### 프로모션 문구

```text
사진은 많고 정리할 시간은 없으니까. Weekkeep이 지난 일주일에서 다시 보고 싶은 순간을 최대 7장 골라요. 한 번 확인하고, 한 주를 남겨보세요.
```

### 키워드 — UTF-8 100 bytes 이하

```text
육아,추억,주간,부모,아기,아이,기록,일기,성장,가정
```

### 설명

```text
사진은 많은데 정리할 시간은 없으니까.

Weekkeep은 평범한 일주일을 최대 7장의 작은 가족 앨범으로 남겨요. 카메라 롤 전체를 정리하라고 하지 않아요.

한 번의 조용한 확인

처음에는 가장 최근 완료된 월요일부터 일요일까지의 한 주에서 다시 보고 싶은 순간을 골라요. 그 주에 Weekkeep이 남길 수 있는 사진이 없을 때만 최근 7일을 정직하게 확인해요. 그다음부터는 새로 끝난 한 주가 월요일마다 기다려요. Weekkeep이 이 iPhone에서 최대 7장의 순간을 골라주면 그대로 남기거나 마음에 들지 않는 사진만 바꾸면 돼요.

실제 가족 생활을 위한 방식

• 최대 7장, 사진이 부족하면 빈자리를 억지로 채우지 않음
• 매일 접속이나 연속 기록을 요구하지 않는 주간 경험
• 마음에 들지 않는 사진만 간단히 바꾸기
• 지난 기록을 한곳에서 다시 보기
• 저장한 사진으로 만드는 Story 9:16 또는 Post 4:5 공유 이미지
• 월요일 저녁에 기기에서 보내는 선택형 알림
• 한국어와 영어 지원

사진 고르기와 공유 이미지 만들기는 iPhone에서

사진 고르기와 공유 이미지 만들기는 이 iPhone에서 처리해요. 사진·미리보기·파일 이름·위치·촬영 시각 같은 사진 정보는 분석을 위해 분석 서비스나 다른 서비스로 보내지 않아요. 공유는 직접 선택할 때만 시작되고, 그때 Apple 시스템 공유 시트를 열어요. Weekkeep은 수신자나 목적지를 선택하거나 기록하지 않아요. Weekkeep 계정이나 Weekkeep 사진 클라우드도 없어요.

주간 기록은 이 iPhone에 저장되고 사진 앱의 원본을 참조합니다. 앱을 삭제하거나 기기를 바꾸거나 원본 사진을 지우면 기록을 볼 수 없게 될 수 있습니다. 구매 복원은 Plus 이용 권한만 복원하며 로컬 기록은 복원하지 않습니다.

먼저 두 번 써보고, 한 번의 구매로 계속

첫 두 개의 주간 기록은 무료입니다. Weekkeep Plus는 이후의 기록 생성을 여는 비소모성 평생 이용권이며 구독이 아닙니다. 구매 전에는 App Store가 제공하는 현지 가격을 표시합니다.

남겨둘 만한 일주일.
```

## 5. Screenshot SSOT

App Store와 Shipaton 증거를 분리합니다.

| 세트 | 규격 | 용도 |
|---|---|---|
| App Store en-US | Apple이 현재 허용하는 6.9-inch portrait 규격 중 하나, alpha 없음 | 영어 제품 페이지 6장 |
| App Store ko | 같은 규격·같은 화면 순서, 한국어 copy | 한국 제품 페이지 6장 |
| Shipaton proof | 정확히 `1179×2556`, alpha 없음, device frame 없음 | Devpost 필수 screenshot 최소 1장 |

### 6장 narrative

| 순서 | 화면 | en-US headline | ko headline | 증명할 것 |
|---:|---|---|---|---|
| 1 | Welcome | `Your week, already waiting.` | `사진은 많고, 시간은 없으니까.` | 부모 문제와 1분 가치 |
| 2 | Curation progress | `Private from the first tap.` | `첫 탭부터, 사진 고르기는 iPhone에서 처리해요.` | foreground on-device 처리 |
| 3 | Seven-photo review | `Seven moments. Nothing to sort.` | `일주일에 7장만.` | hero+2+4, exact-seven signature |
| 4 | Replace | `Change one. Keep the feeling.` | `마음에 안 드는 한 장만 바꾸세요.` | 선택→교체 interaction |
| 5 | Saved/Weeks | `A small album, every week.` | `작은 한 주가 차곡차곡.` | 저장 보상·보관함과 detail local share entry |
| 6 | Plus | `Two albums free. Then yours for life.` | `두 번 무료, 그다음은 평생 이용권.` | 투명한 one-time price와 restore |

제출용 사진은 사용 허가를 받은 fixture만 사용합니다. 사람 얼굴을 합성하거나 실제 사용자 사진을 무단으로 쓰지 않습니다. Shipaton proof는 마케팅 headline을 얹지 않은 실제 앱 원본 캡처를 별도로 냅니다.

App Store 6.9-inch screenshot evidence is captured from the DEBUG
`-ui-app-store-fixtures` launch path using the bundled `SamplePhotoFixtures`.
This is deterministic bundled-fixture UI evidence, not a PhotoKit ingestion
test; live PhotoKit behavior is validated separately through the live adapter
and device QA path.

Weekly Review capture framing is intentionally split: `03-review` is the clean
top story (header, editorial copy, and photo story), while `04-replace` shows
the lower replacement/privacy/save actions after an explicit scroll. The raw
`03-review-bottom` attachment is QA evidence only and is not an additional
submission image. No `-ui-app-store-fixtures` branch may reduce production
spacing to fit the six-screen composition.

The six-screen sets must capture the app surface itself: Plus is an item-driven
native full-screen route with no gray sheet chrome, nested rounded sheet, bezel,
or device frame. The explanatory Welcome, Ready, and Plus visuals use the same
flat `FixturePhotoStory` vocabulary and approved fictional fixture PNGs. The
historical build-2 rerun8 evidence is in
`release/local/visual-qa/20260806-app-store-build2-photo-first-rerun8/final/`,
and the canonical release tree is `release/screenshots/app-store-6.9/`. The
six build-3 JPEGs per locale passed the semantic/dimension/alpha validator,
replaced the previous en-US and ko `APP_IPHONE_67` resources in ASC, and every
remote asset was re-read as `COMPLETE` at `1320×2868`; no device frame is
present. This is historical remote build-3 evidence. The historical local
build-5 candidate remains the latest six-screen local App Store set at
`release/local/visual-qa/20260807-build5-app-store-candidate-rerun8/final/`
and is not relabeled as build 6. The active local build-6 candidate's new
Settings notification surface is recorded separately at
`release/local/visual-qa/20260807-build6-notification-settings-rerun1/final/`.
It contains two opaque PNG states per locale (zero saved albums and saved-user
action), direct XCTest attachment manifests, and no App Store screenshot
replacement evidence. Build 6 is uploaded, processed `VALID`, and attached to
the current app version. Build 3 was regenerated locally at
`release/local/visual-qa/20260806-app-store-build3-onboarding-rerun1/final/`
with the corrected onboarding 1+3+3 collage and mirrored into the canonical
local tree; that build-3 record remains historical evidence for the former
review submission, which was canceled/replaced by build 6. The prior build-2
submission was canceled and remains historical.
The attachment extractor requires `startswith($prefix + "_0_")` and exactly one
match, so `03-review` cannot alias `03-review-bottom`. ASC build 6 is the
current uploaded/attached review binary; its Settings visual-QA captures do not
replace the historical six-screen App Store screenshot set.

## 6. In-App Purchase metadata

| 필드 | 값 |
|---|---|
| Type | Non-Consumable |
| Reference Name | `Weekkeep Plus Lifetime` |
| Product ID | `weekkeep_plus_lifetime` |
| RevenueCat entitlement | `plus` |
| RevenueCat offering | `default` |
| US price | `$19.99` price point |
| Availability | USA and KOR; ASC availability verified |

### IAP localization

| Locale | Display Name | Description |
|---|---|---|
| en-US | `Weekkeep Plus Lifetime` | `Keep up to seven moments every week.` |
| ko | `Weekkeep Plus 평생 이용권` | `앞으로의 매주 소중한 순간을 최대 7장씩 남겨요.` |

IAP Review Screenshot은 Settings → Weekkeep Plus에서 열린 실제 paywall을 사용하고, 현지화된 가격·`Restore purchase`·Terms·Privacy·닫기 버튼이 한 화면에 보이게 합니다.

The current product-level review screenshot is ASC resource
`e181d5af-7959-4e7d-9372-416516bb6c87`, sourced from the approved English
Plus screen (`06-plus.jpg`), and was re-read as `COMPLETE`, opaque JPEG,
`1320×2868`.

## 7. App Review notes — English

```text
Weekkeep does not require an account.

Core review path:
1. Launch the app and tap “Choose your first week.” Weekkeep starts with the most recently completed local Monday–Sunday week; we check the most recent 7 days only when that week has no photos Weekkeep can use.
2. Grant Full or Limited Photos access. The permission prompt appears only after this action.
3. Weekkeep checks the photos it can use on the iPhone and chooses up to seven moments.
4. Tap a photo once to select it, then tap “Change this photo” to choose an alternative. Same-day alternatives appear first; other dates require an explicit disclosure. Tap the selected photo again to open the viewer.
5. Save the photos. On Save Confirmation, choose Story (1080×1920) or Post (1080×1350), review the local preview, and tap Share to open the native iOS share sheet. Do not send it anywhere during review.
6. Open the saved album again from the Saved weeks tab; the same local share entry point is available in Week Detail.

In-App Purchase:
Open Settings → Weekkeep Plus → Learn about Weekkeep Plus. The paywall is available immediately; reviewers do not need to wait for a third weekly album. The product is the non-consumable `weekkeep_plus_lifetime`, mapped by RevenueCat to the `plus` entitlement in the `default` offering. Purchase restoration is available from both the paywall and Settings.

The first two saved albums are free. Plus unlocks future album creation; existing albums always remain viewable. No subscription is offered.

Privacy and storage:
Photo selection and share rendering are processed on the iPhone. Photos, previews, filenames, capture times, locations, and other photo details are not sent to RevenueCat, analytics services, or other services for analysis. Sharing starts only after an explicit user action and the image is handed to the native iOS share sheet; the app does not choose or record a recipient. Album records are stored locally on the iPhone; restoring Plus does not restore album data.

No special hardware, login, or reviewer account is required. Please use a device with several recent photos or grant Limited Access to a small test set.
```

## 8. Submission toggles and compliance

- Age Rating questionnaire: 답변을 실제 기능에 맞춰 모두 완료하며 social, messaging, web access, UGC, gambling, medical 기능은 없음.
- Advertising Identifier: 사용하지 않음.
- Tracking permission: 요청하지 않음.
- Export compliance: 자체 암호화나 비표준 암호화를 사용하지 않음; `ITSAppUsesNonExemptEncryption = NO`가 archive에 있어야 함.
- App Privacy: [09-APP-PRIVACY-LABEL.md](09-APP-PRIVACY-LABEL.md)를 그대로 입력.
- App Accessibility: ASC has an iPhone VoiceOver-only declaration in `DRAFT`; Apple will not publish an iPhone declaration until the app is available on the App Store. No dark-interface, captions, audio-description, voice-control, or other unsupported capability is declared.
- Review contact: Supplied only through the authenticated App Store Connect review-contact workflow; reviewer contact values are intentionally not stored in public source.
- App Review attachment: IAP paywall screenshot과 필요 시 30초 이내 핵심 flow 영상.

## 9. 입력 전 자동/수동 검증

- [ ] 앱 레코드 이름이 각 locale에서 30 characters 이하
- [ ] subtitle 30 characters 이하
- [ ] promotional text 170 characters 이하
- [ ] description 4,000 characters 이하
- [ ] keyword가 locale별 UTF-8 100 bytes 이하이고 경쟁사·상표명 없음
- [ ] IAP display name 30 characters 이하, description 45 characters 이하
- [ ] 앱 icon 1024×1024 opaque, 미리 둥근 모서리 없음, exact-seven rainbow (`D-030`)
- [x] Historical build-3 App Store en-US/ko screenshot sets: exactly six each, opaque JPEG, `1320×2868`, `APP_IPHONE_67`, remote state `COMPLETE`; retained as historical evidence after build-6 replacement
- [x] Historical local build-5 App Store candidate screenshots: exactly six each, opaque JPEG, current raw-source provenance/checksums, and local validator pass; not uploaded or relabeled
- [x] Historical build-6 Settings notification visual QA: four bilingual opaque `1320×2868` PNGs, direct XCTest manifests, matching checksums, and local validator pass; separate from App Store screenshot evidence
- [x] Current review build: build 7 upload, canonical IPA inspection, ASC `VALID` processing, version attachment, and submission `6d2feeff-0f90-4b34-b0c8-b22a3b1928b7` `WAITING_FOR_REVIEW`
- [x] Current review submission has exactly two `READY_FOR_REVIEW` items: app version `ac4f183e-1019-4ffc-827f-f5514f0d349b` and IAP version `cedd0fe9-5b2a-478e-a58f-9ae2269ecd7f`
- [x] 모든 screenshot alpha 없음; Shipaton proof는 `1179×2556`와 no-device-frame 확인
- [x] Support/Privacy URL responds publicly; ASC en-US/ko app-info localizations use `/support` and `/privacy` consistently
- [ ] US storefront에서 앱과 IAP 다운로드/구매 가능 — public release remains pending
- [ ] Review Notes의 버튼명과 Release localization이 글자 단위로 일치
- [x] App Review contact and IAP review screenshot re-read in ASC
- [x] App Privacy data-usage answers published in ASC for the current `1.0.0` app version; build 7 `PrivacyInfo` presence is local binary evidence, not a separate build-7 publication event

## 10. 공식 기준

- [Apple App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/)
- [Apple Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information)
- [Apple Creating Your Product Page](https://developer.apple.com/app-store/product-page/)
- [Apple Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
- [Apple In-App Purchase information](https://developer.apple.com/help/app-store-connect/reference/in-app-purchases-and-subscriptions/in-app-purchase-information)
