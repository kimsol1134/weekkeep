# Weekkeep Brand Marks

브랜드 결정값의 SSOT는 [Design Guide](../../docs/05-DESIGN-GUIDE.md)와 Decision Registry의 `D-030`, `D-031`입니다. 이 폴더는 배포 가능한 로고 파일과 출처만 소유합니다.

## 자산 계층

| 자산 | 용도 | 사용 금지 |
|---|---|---|
| `weekkeep-wordmark.svg` + `weekkeep-wordmark.png` | onboarding upper-left와 앱 header·작은 제품 UI의 canonical wordmark source; iOS는 PNG image set으로 bundle | Text 재식자, rainbow 추가, outline, shadow, tint |
| `weekkeep-lockup-seven-stitch.svg` | 웹 hero, Shipaton end card, press kit 같은 외부 브랜드 surface | 앱 navigation/header, 120px 미만 폭 |
| `../app-icon/weekkeep-app-icon-master.svg` | App Icon의 벡터 master | 앱 안 기능 icon, 미리 둥근 모서리 |

SVG와 PNG는 canonical content를 보존합니다. iOS production resource는 PNG 배포본을 `WeekkeepWordmark.imageset`으로 byte-preserving 등록하며, 이 revision은 AppIcon source/master와 무관합니다.

## 원본과 탐색안

- `source/user-logo-20260805.png`: 사용자 제작 원본. 수정하지 않습니다.
- `explorations/imagegen-refined-lockup-20260805.png`: 구조 탐색용이며 미세 gradient 때문에 production asset이 아닙니다.
- `explorations/PROMPTS.md`: image generation 입력, 채택·폐기 판단 기록.
- app icon 사용자 원본과 image generation 탐색안은 `../app-icon/explorations/`에 보존합니다.

## Clear space와 최소 크기

- wordmark clear space: 소문자 `w` 높이의 0.5배 이상
- seven-stitch lockup 최소 폭: digital 120px
- 그보다 작으면 `weekkeep-wordmark.svg`만 사용
- app icon은 Apple system mask에 맡기며 master에 corner radius나 shadow를 넣지 않음
