# Weekkeep App Privacy Label SSOT

| 항목 | 값 |
|---|---|
| 기준일 | 2026-08-07 |
| 대상 | iOS 1.0.0 — current ASC build 6 is `VALID` and attached to version `ac4f183e-1019-4ffc-827f-f5514f0d349b`; current review is `WAITING_FOR_REVIEW`; historical build 3 evidence is preserved and its submission was replaced; build 4 is `VALID` but unattached |
| 공개 정책 URL | `https://weekkeep-app.kimsol1134.chatgpt.site/privacy` |
| Privacy Choices URL | `https://weekkeep-app.kimsol1134.chatgpt.site/privacy` |
| Tracking | No |
| 사진·영상 외부 수집 | No — photo selection and share rendering happen on the iPhone; photo details are not sent for analysis |

이 문서는 App Store Connect의 **App Privacy** 답변을 소유하는 단일 원본입니다. 앱 코드, `PrivacyInfo.xcprivacy`, SDK manifest, 공개 개인정보 처리방침, App Store 답변이 바뀔 때 이 문서를 함께 검토합니다.

## 1. V1 제출 구성

| 기능 | 제출 빌드 설정 | 네트워크 처리 |
|---|---|---|
| 사진 탐색·분석 | 활성 | Photos/Vision으로 iPhone에서 처리; 사진 픽셀·썸네일·파일명·위치·촬영 시각·Photos 식별자는 분석을 위해 분석 서비스나 다른 서비스로 보내지 않음 |
| 로컬 기록 | 활성 | SwiftData/App sandbox에만 저장; Weekkeep 서버·CloudKit 없음 |
| RevenueCat 구매 | 실제 public SDK key가 준비되면 활성 | 자동 생성 익명 App User ID와 구매·entitlement 정보 전송 |
| PostHog 분석 | **V1 제출은 비활성 (`WK_ANALYTICS_ENABLED = NO`)** | 전송 없음; adapter와 SDK는 deny-by-default 상태로 포함 |
| Crash/diagnostic 전송 | 비활성 | PostHog `errorTrackingConfig.autoCapture = false`; 앱 자체 crash reporter 없음 |
| 로컬 알림 | 선택 활성 | `UNUserNotificationCenter` 로컬 알림; 원격 푸시·OneSignal 없음 |

PostHog를 이후 활성화하려면 사용자 동의 UX, `TST-019`/`TST-022` payload audit, 공개 정책과 App Store label 갱신을 먼저 완료합니다.

## 2. App Store Connect 답변 — V1

첫 질문은 **“Yes, we collect data from this app”**로 답합니다. 사진이 아니라 구매 처리와 사용자가 직접 보낸 지원 요청 때문입니다.

| Data type | Collected | Purpose | Linked to identity | Tracking | 근거 |
|---|---|---|---|---|---|
| Identifiers → User ID | Yes | App Functionality | No | No | RevenueCat이 계정 없는 앱에 `$RCAnonymousID`를 생성해 entitlement를 식별 |
| Purchases → Purchase History | Yes | App Functionality | No | No | RevenueCat purchase/restore와 SDK privacy manifest |
| User Content → Customer Support | Yes, user initiated | App Functionality | Yes | No | 사용자가 mailto로 보낸 이메일 주소와 문의 내용; primary feature에는 사용하지 않음 |

다음 항목은 V1에서 **수집하지 않음**으로 답합니다.

- Photos or Videos: 사진 고르기와 공유 이미지 만들기는 iPhone에서 처리하며, 사진 정보는 분석을 위해 분석 서비스나 다른 서비스로 보내지 않음. 공유는 사용자가 직접 선택할 때만 시작
- Precise/Coarse Location: Photos 위치 metadata를 외부에 전송하지 않음
- Product Interaction / Other Usage Data: PostHog 비활성
- Crash Data / Performance Data / Other Diagnostic Data: 자동 crash capture 비활성, 자체 reporter 없음
- Device ID / Advertising Data: 광고 식별자 접근·광고·tracking 없음
- Name, phone, address, contacts, health, audio, browsing/search history: 요청·수집 없음

지원 이메일이 Apple의 optional-disclosure 조건을 충족한다고 App Store Connect UI가 명확히 안내하는 경우 Customer Support를 optional로 제외할 수 있지만, 초기 제출은 보수적으로 공개합니다.

## 3. PostHog 활성화 시 추가 답변

다음 릴리스에서 사용자의 동의를 받은 뒤 PostHog를 활성화하면 아래 두 항목을 추가합니다.

| Data type | Purpose | Linked | Tracking | 허용 payload |
|---|---|---|---|---|
| Usage Data → Product Interaction | Analytics | No | No | 명시적 allowlist event, selected/replacement count, 권한·구매 결과 |
| Usage Data → Other Usage Data | Analytics | No | No | bucket 처리한 후보 수·활성 검토 시간, locale, app version |

금지 payload: 사진 픽셀, thumbnail, Photos ID, 파일명/path, capture time, 위치/좌표, week key, EXIF, caption, 자유 입력, 이메일·이름, 광고 ID. Person profile, identify, screen/element autocapture, session replay, surveys, feature flags, tracing, push capture, automatic crash capture는 계속 꺼둡니다.

## 4. Privacy manifest 해석

- 앱의 `PrivacyInfo.xcprivacy`는 앱 자체 수집 데이터가 없음을 선언하고 `UserDefaults` required-reason `CA92.1`만 포함합니다.
- RevenueCat SDK manifest는 `Purchase History / App Functionality / unlinked / not tracking`을 선언합니다.
- PostHog SDK manifest는 `Product Interaction`과 `Other Usage Data / Analytics / unlinked / not tracking`을 선언합니다.
- PostHog가 포함한 PHPLCrashReporter manifest는 `Crash Data`와 `Other Diagnostic Data`를 선언하지만 Weekkeep은 automatic error capture를 비활성화합니다. SDK manifest는 binary capability를, App Store label은 제출 버전의 실제 collection을 기록한다는 차이를 release note에 보존합니다.
- 앱 manifest에 SDK의 선언을 중복 복사하지 않습니다. Apple은 각 third-party SDK가 자신의 manifest를 제공하도록 안내합니다.

## 5. Historical remote build 3 및 ASC privacy evidence — 2026-08-06

- Distribution IPA: `release/local/asc-release-build3-20260806-onboarding-rerun1/exported/Weekkeep.ipa`
- Bundle/version/build: `com.solkim.weekkeep` / `1.0.0 (3)`; `get-task-allow=false`; `ITSAppUsesNonExemptEncryption=false`
- Release configuration: analytics `NO`, purchases `YES`, PostHog token empty, RevenueCat production public SDK key injected without recording its value
- IPA contains the app, RevenueCat, PostHog, and PHPLCrashReporter privacy manifests. The app declares no collected data or tracking; SDK declarations remain owned by each SDK.
- App Store Connect App Privacy was published on 2026-08-06 with the three entries above; the public API cannot independently expose the publish state, so the authenticated UI evidence remains the source for that status. The publication is retained for the current 1.0.0 app-version review; it does not claim App Review approval or public release.
- Public policy/support site: existing Sites project version 4 is public at `https://weekkeep-app.kimsol1134.chatgpt.site` as of deployment `2026-08-06T09:35:40.860943+00:00`; logged-out `/`, `/privacy`, `/support`, and `/terms` returned HTTP 200, with the intended public support contact present and no internal tester-domain address matches.

Build 2 (`release/local/asc-release-build2-20260806-rerun7/exported/Weekkeep.ipa`) is preserved as historical release evidence only; it was the prior review candidate and is no longer the attached version build.

## 5.1 Current build 6와 historical build 경계 — 2026-08-07

- Remote build 4 (`6e92c470-c044-4512-9276-71491fe97685`) is `VALID` and unattached; it remains historical/non-target.
- ASC build 6 (`0ffa7586-619f-4df9-abc5-ae7ebbd068b1`) is `1.0.0 (6)`, processed `VALID`, uploaded at `2026-08-06T15:31:16-07:00`, and attached to version `ac4f183e-1019-4ffc-827f-f5514f0d349b`. The current submission `a9b0a18f-6cf6-4af4-8e6f-c77009831e00` is `WAITING_FOR_REVIEW` with the app-version and IAP-version items both `READY_FOR_REVIEW`.
- Signed build-6 IPA local verification is recorded without a tracked evidence file: 23,338,085 bytes, SHA256 `feccbf6e94b4b848d119eb242994f9626106595b79d6e8acc0d8d8e2dc55f06a`, bundle `com.solkim.weekkeep`, version `1.0.0`, build `6`, purchases `YES`, analytics `NO`, PrivacyInfo present, Apple Distribution `sol kim`, team `D48DDX5D5W`.
- `release/privacy-manifest.json` scopes the published App Privacy facts to the current `1.0.0` app version; the historical build-3 IPA remains evidence only. Build 6's local IPA verification confirms `PrivacyInfo` is present but does not claim a separate build-6 privacy publication event. No App Review approval or public App Store release is made.
- The build-6 Settings visual-QA evidence remains separately recorded at `release/local/visual-qa/20260807-build6-notification-settings-rerun1/final/`; it is not an App Store screenshot replacement. Builds 1–5 remain historical/non-target. The physical iPhone fixture-only UI runner started after the lock wait but failed initialization with LocalAuthentication Code `-4` (authentication canceled); its process was safely terminated, and the result bundle is invalid/incomplete because `Info.plist` is missing and is not evidence. Physical UI attachments, purchase/restore verification, target-device footage, actual-library performance, and icon QA remain pending; no credentials were requested or handled and Photos/notification permissions and private pixels were not changed.
- The historical local build-5 candidate remains recorded as `not_submitted_for_build5` for exact build-state traceability.

## 6. 제출 전 검증 체크리스트

- [x] 공개 정책/지원 URL을 로그아웃 상태에서 열 수 있음 — existing public Sites deployment verified on 2026-08-06; App Store metadata support/privacy URLs match
- [ ] Release `Info.plist`의 `WK_ANALYTICS_ENABLED = NO`
- [ ] Release `Info.plist`의 RevenueCat public SDK key가 비어 있지 않고 secret 저장소에서 주입됨
- [ ] Proxyman/Charles에서 clean install → curation → save 중 photo 관련 외부 request 0
- [ ] purchase/restore 요청에 익명 App User ID와 구매 정보 외 custom attribute 0
- [ ] App Store label Product Page Preview와 이 표가 일치
- [ ] 앱 Settings와 paywall에서 정책·약관·지원 링크가 열림
- [ ] SDK version 변경 시 built app의 모든 `PrivacyInfo.xcprivacy` 재검사

## 7. 공식 근거

- [Apple — App privacy details](https://developer.apple.com/app-store/app-privacy-details/): on-device-only 데이터는 수집으로 보지 않으며 third-party partner의 collection도 공개해야 함
- [Apple — Describing data use in privacy manifests](https://developer.apple.com/documentation/bundleresources/describing-data-use-in-privacy-manifests): app manifest에 third-party SDK manifest를 중복 선언할 필요가 없음
- [Apple — App Review Guidelines 5.1.1](https://developer.apple.com/app-store/review/guidelines/): 앱 안과 App Store metadata에 개인정보 처리방침을 제공하고 retention/deletion을 설명해야 함
- [RevenueCat — SDK Quickstart](https://www.revenuecat.com/docs/getting-started/quickstart): App User ID를 생략하면 anonymous ID를 만들고 purchase 정보를 RevenueCat에 전송
