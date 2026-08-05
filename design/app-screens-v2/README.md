# Weekkeep App Screens V2

| 항목 | 결정 |
|---|---|
| 상태 | Approved |
| 역할 | Current visual baseline |
| 기준일 | 2026-08-05 |
| 디자인 SSOT | [`design/README.md`](../README.md) |
| 기준 IA | [`docs/03-IA.md`](../../docs/03-IA.md) |
| 디자인 리뷰 | [`docs/08-DESIGN-REVIEW-V2.md`](../../docs/08-DESIGN-REVIEW-V2.md) |
| 시각 방향 | Warm Private Family Album V2 |
| Appearance | **Light mode only** |
| 생성 방식 | OpenAI built-in `image_gen` + deterministic vector overlay |
| 기준 크기 | 853 × 1844 portrait |
| 제품 폰트 | LINE Seed Sans KR Regular/Bold |

## 결론

V2는 V1의 따뜻한 앨범 정서는 유지하면서, 부모의 실제 문제와 Weekkeep만의 상호작용을 더 선명하게 만들었습니다.

- 첫 문장은 `사진은 많은데, 정리할 시간은 없으니까.`로 시작합니다.
- 분석 전 화면은 초안이 이미 준비됐다고 주장하지 않습니다.
- 사용자는 빈 화면에서 고르지 않고 최대 7장의 초안을 검토합니다.
- 마음에 들지 않는 사진만 선택해 교체합니다.
- 사진은 광고 사진보다 실제 iPhone 카메라롤에 가까운 생활감을 가집니다.
- 저장 순간 grid가 한 장의 Week album으로 정리되는 방향을 사용합니다.
- 다크 모드는 V1 범위에 없습니다.

## 이 화면 세트의 권한

- 14개 PNG는 happy-path의 **시각 위계·사진 톤·layout 방향**을 소유합니다.
- 결정값과 승인 상태는 [Decision Registry](../../docs/00-INDEX.md), 화면 상태·navigation·gesture는 [IA](../../docs/03-IA.md), 동적 copy·token·접근성은 [Design Guide](../../docs/05-DESIGN-GUIDE.md)가 소유합니다.
- 이미지에 보이는 날짜, 사진 수, 가격, 문장은 생성 fixture입니다. 규범 문서와 다르면 규범 문서를 따릅니다.
- 생성 화면을 pixel-perfect로 복사하지 않고 SwiftUI semantic token과 실제 데이터로 재구성합니다.

## 7-stitch 불변 조건

화면에 보이는 stitch는 요일이나 streak가 아니라 `최대 7장의 사진`을 나타내는 브랜드 컴포넌트입니다.

- 최종 구현의 stitch 수는 언제나 정확히 **7개**입니다.
- 생성형 이미지가 최종 개수를 결정하지 않습니다.
- SwiftUI와 제출용 screenshot export에서 [`Seven-stitch Rail`](../system/SEVEN-STITCH.md)을 코드로 렌더링합니다.
- 진행 상태도 `완료 n개 + 남은 7-n개 = 7개`를 유지합니다.
- 1–6장 결과 화면에서는 stitch를 사진 슬롯으로 오해하지 않게 실제 사진 수를 텍스트로 별도 제공합니다.

## 화면 인벤토리

| 순서 | IA ID | 파일 | 핵심 상태 |
|---:|---|---|---|
| 00 | QA | `00-v2-contact-sheet.png` | 전체 화면 통일성 검토 |
| 01 | `SCR-ONB-01` | `01-onboarding-welcome.png` | 첫 가치·최대 7장·기기 내 처리 |
| 02 | `SCR-WK-01` | `02-this-week-ready.png` | 분석 전 ready; foreground 분석 시작 |
| 03 | `SCR-WK-02` | `03-curation-progress.png` | 4/7 진행 예시·취소·기기 내 처리 |
| 04 | `SCR-WK-03` | `04-weekly-review.png` | 7장 초안 검토·선택 사진 교체 |
| 05 | `SCR-WK-04` | `05-photo-viewer.png` | 1/7 확대·swipe·현재 사진 교체 |
| 06 | `SCR-WK-05` | `06-save-confirmation.png` | 한 주가 앨범이 된 완료 보상 |
| 07 | `SHEET-REP-01` | `07-replace-photo-sheet.png` | 현재 사진 맥락을 유지한 후보 선택 |
| 08 | `SHEET-NOT-01` | `08-notification-primer.png` | 첫 저장 뒤 월요일 20:30 알림 제안 |
| 09 | `SHEET-PAY-01` | `09-plus-paywall.png` | 두 주의 가치 회상·평생 이용권·현재 기기 열람 범위 |
| 10 | `SCR-ARC-01` | `10-weeks-archive.png` | 세 주의 읽기 전용 보관함 |
| 11 | `SCR-ARC-02` | `11-week-detail.png` | 정확히 7장의 읽기 전용 상세 |
| 12 | `SCR-SET-01` | `12-settings.png` | 사진·알림·Plus·로컬 저장·신뢰 상태 |
| 13 | `SCR-SET-02` | `13-privacy.png` | 기기 내 분석·서버 전송 없음·별도 백업 없음 |
| 14 | `SCR-SET-03` | `14-about-support.png` | 도움말·법적 링크·폰트 표기 |

`00-v1-style-reference.png`는 V1과의 시각적 비교를 위한 보존 파일이며 V2의 source of truth가 아닙니다.

## 폰트 적용

제품 파일은 [`resources/fonts/line-seed-kr`](../../resources/fonts/line-seed-kr)에 보관합니다.

| 역할 | 파일 | PostScript name |
|---|---|---|
| Body, caption, navigation | `LINESeedKR-Rg.ttf` | `LINESeedSansKR-Regular` |
| Display, title, CTA | `LINESeedKR-Bd.ttf` | `LINESeedSansKR-Bold` |

`image_gen` 결과는 LINE Seed의 인상과 폭을 지시한 high-fidelity 방향 이미지입니다. 생성 모델은 로컬 TTF를 정확히 식자한다고 보장하지 않으므로, 앱 구현과 실제 제출 screenshot은 위 폰트 파일을 등록한 SwiftUI 화면에서 캡처해야 합니다.

## 구현 시 해석 규칙

- 이 이미지는 hierarchy·copy·photo direction·interaction intent의 기준이며 고정 pixel spec은 아닙니다.
- Primary button은 mockup의 미세한 톤 변화와 관계없이 production에서 **solid Plum**으로 구현합니다.
- Paywall의 `₩29,000`은 초기 KR 예상 fixture이며 실제 화면은 RevenueCat/App Store가 반환한 현지화 가격만 표시합니다.
- `평생 이용권`은 Plus 기능의 상품 유형이며 기록의 영구 백업을 뜻하지 않습니다. paywall 개인정보 링크와 Settings에서 로컬 보존 한계를 확인할 수 있어야 합니다.
- `사진 42장`은 ready fixture입니다. 실제 값은 접근 가능한 해당 기간 descriptor count를 사용하고 외부 analytics에는 bucket만 보냅니다.
- archive는 기록이 12개 이상 쌓이기 전 year/month filter를 표시하지 않습니다.
- week detail은 읽기 전용이며 V1에 공유·내보내기·편집·삭제가 없습니다.
- 실제 제출 사진은 사용 동의 또는 적절한 라이선스를 확인한 fixture로 교체합니다.
- 권한·사진 0/1–6/누락·오류·Dynamic Type 상태는 이 happy-path 세트와 별도로 구현합니다.
- Weekly Review의 첫 photo tap은 대상을 선택하고 `이 사진 바꾸기`를 노출합니다. 선택된 사진의 두 번째 tap은 viewer를 열며, VoiceOver custom action은 `크게 보기`와 `사진 교체`를 직접 제공합니다.
- grid→album 전환은 matched geometry를 사용하고 Reduce Motion에서는 0.2초 fade로 대체합니다.

### 생성 fixture 예외

`13-privacy.png`의 `기록은 복원되지 않아요`는 생성 당시의 과도하게 단정적인 fixture입니다. Production copy는 `FR-022`의 계약에 따라 `Weekkeep은 별도 백업을 제공하지 않아 앱을 삭제하거나 기기를 바꾸면 기록이 사라질 수 있어요. 원본 사진은 사진 앱에 남아 있어요.`를 사용합니다.

재생성 규칙과 화면별 copy는 [`PROMPTS.md`](PROMPTS.md)에 기록합니다.
