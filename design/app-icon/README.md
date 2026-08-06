# Weekkeep App Icon Handoff

색상값, rainbow 순서, 형태·금지 규칙의 SSOT는 [Design Guide — App icon creative brief](../../docs/05-DESIGN-GUIDE.md#app-icon-creative-brief)와 Decision `D-030`입니다. 이 폴더는 사용자 원본을 보존하고 승인된 평면 master와 검증 절차를 소유합니다.

## Canonical files

- 벡터 master: `weekkeep-app-icon-master.svg`
- opaque PNG master: `weekkeep-app-icon-master.png`
- Xcode asset: `../../Weekkeep/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`
- 크기 QA board: `weekkeep-app-icon-qa.png`
- Apple mask proof: `previews/simulator-home-weekkeep-crop-20260805.png`

## 전달 규격

- 형식: PNG
- 크기: 1024×1024 px
- color space: sRGB
- alpha: 없음
- 모서리: 미리 둥글리지 않음
- 최종 경로: `Weekkeep/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`

`Contents.json`은 universal iOS 1024 master를 이미 가리키므로 수정하지 않습니다. 최종 PNG만 같은 이름으로 교체합니다.

## 검증

```bash
cd /Users/solkim/Dev/weekkeep
./scripts/validate-release-assets.sh
```

자동 검증과 Simulator home-screen mask 확인은 통과했습니다. 최종 제출 전 실제 iPhone 홈 화면에서 29pt, 40pt, 60pt를 다시 확인합니다. 일곱 stitch가 분리되어 보이는지, 순서가 뒤집히지 않았는지, 같은 크기·간격인지, 숫자 7이나 달력 badge로 오인되지 않는지 확인합니다.

`explorations/user-icon-20260805.jpeg`는 사용자 제작 원본이며 수정하지 않습니다. 부드러운 재질감과 사진 의미는 방향으로 채택했지만, 미리 둥근 tile·shadow·3D·불균일 stitch를 제거한 production master는 별도로 관리합니다. 다른 `explorations/` 파일도 최종 아이콘 기준이 아닙니다.
