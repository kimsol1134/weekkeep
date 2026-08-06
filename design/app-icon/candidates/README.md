# App Icon Candidate — mirrored `kk` monogram

| 항목 | 값 |
|---|---|
| 상태 | **Candidate — 승인 전** |
| 현재 승인된 아이콘 | `../weekkeep-app-icon-master.svg` (Plum photo keepsake, `D-030`) |
| 관련 결정값 | `D-030` (아이콘 개념·stitch 규칙), `D-031` (브랜드 마크 계층) |

이 폴더의 자산은 **승인된 baseline이 아닙니다.** `design/README.md`의 current visual baseline과 `docs/05-DESIGN-GUIDE.md`의 App icon creative brief는 여전히 Plum photo keepsake를 가리킵니다. 승격 전에는 어떤 빌드나 제출물에도 사용하지 않습니다.

## 개념

`weekkeep`은 8글자가 `week`+`keep`으로 4+4 분할되고 그 경계가 두 `k` 사이입니다. 두 번째 `k`를 좌우로 뒤집으면 기둥은 바깥, 사선 팔은 안쪽에서 마주 보고, 그 사이에 남는 여백이 그 주의 한 장입니다. 가운데 Golden Hour 마름모가 그 한 장입니다.

승인된 seven-stitch는 **좌표까지 그대로 유지**했습니다. 바뀌는 것은 stitch 아래 실루엣뿐입니다.

## 파일

같은 디자인을 두 경로로 만들었습니다.

| 파일 | 경로 | 용도 |
|---|---|---|
| `weekkeep-app-icon-kk-candidate.svg` | 벡터 | 결정적 master 후보 |
| `weekkeep-app-icon-kk-candidate.png` | 벡터 | cairosvg 렌더, 1024 opaque sRGB |
| `weekkeep-app-icon-kk-imagegen-master.png` | image_gen | take3 기반 1024 opaque sRGB |
| `imagegen-take1.png` `imagegen-take2.png` `imagegen-take3.png` | image_gen | 1254 원본 3테이크 (medium / slim / bold) |
| `weekkeep-app-icon-kk-size-qa.png` | — | 두 경로와 현재 승인 아이콘의 60/40/29pt 비교 |

### image_gen 경로의 한계

`scripts/validate-release-assets.sh`는 PNG뿐 아니라 **SVG master의 구조**를 검사합니다 — `g#seven-stitches` 안의 rect 7개, 각각의 `fill`·`x`·`y`·`width`·`height`·`rx` 값. 래스터에는 그 구조가 없으므로 **image_gen 산출물만으로는 계약의 절반(PNG)만 충족합니다.** SVG master가 필요하면 벡터 경로를 씁니다.

세 테이크 모두 일곱 스티치의 픽셀 수가 소수점 없이 완전히 동일합니다(테이크별 4012 / 3488 / 4772, 편차 0.0%). 확산 모델 래스터에서는 나올 수 없는 값이라, Codex가 스티치 행을 코드로 다시 그렸을 가능성이 높습니다. 모노그램 형태는 생성 결과이고 스티치 행은 결정적으로 그려진 혼합 산출물로 취급합니다.

### 축소 규격

1254 → 1024 축소에는 반드시 **면적 평균(PIL `Image.BOX`)** 을 씁니다. LANCZOS와 BICUBIC은 평면 색 경계에서 오버슈트를 만들어 Cream보다 밝은 halo 5,200px와 Plum보다 어두운 ringing 2,100~2,700px가 생깁니다. BOX는 halo 0, ringing 0입니다.

## 기하

폰트 메트릭에 의존하지 않는 명시적 좌표입니다. 자소를 outline으로 변환한 것이 아니라 stroke 기반으로 작도했으므로 재현 가능합니다.

- stroke 88, round cap, Plum `#5B415E`
- 기둥 x=236 / x=788 (1024 기준 좌우 대칭), y 394→806
- knee y=600, 팔·다리 tip x=452 / x=572, y=424와 y=776
- 시각 경계 192–832 × 350–850, 중심 x=512
- 마름모: 116×116 rx14를 (512, 600) 기준 45° 회전, Golden Hour `#E5A84B`

## 검증

`scripts/validate-release-assets.sh`의 계약을 그대로 검사해 전부 통과했습니다.

- viewBox `0 0 1024 1024`, 첫 rect가 full-bleed Cream `#FBF7F2`, 미리 둥글린 모서리 없음
- `g#seven-stitches`에 rect 정확히 7개, 승인된 색·순서·x좌표·70×30·rx15 일치
- gradient/filter 0개
- PNG 1024×1024, alpha 없음, sRGB IEC61966-2.1

image_gen master(`weekkeep-app-icon-kk-imagegen-master.png`)도 독립 측정했습니다.

- 1024×1024, alpha 없음, sRGB IEC61966-2.1
- 스티치 정확히 7개, 폭 96–97px(편차 1px), 중심 간격 120.5–121.0px(편차 0.5px), 좌→우 red→violet 순서 일치, 스티치별 픽셀 편차 0.4%
- 색 30개(팔레트 9색 + 안티에일리어싱), halo·ringing 0px

## 승격하려면

1. `D-030`을 개정한다. "Plum keepsake 위 seven-stitch"에서 "거울 대칭 kk 모노그램 위 seven-stitch"로 개념이 바뀌므로 결정값 변경이다. 워드마크까지 함께 바꾸면 `D-031`도 개정한다.
2. `docs/05-DESIGN-GUIDE.md`의 App icon creative brief를 새 개념·기하로 갱신한다.
3. 이 폴더의 SVG/PNG를 `../weekkeep-app-icon-master.svg`, `../weekkeep-app-icon-master.png`로 옮기고 `Weekkeep/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`에 **byte-identical**로 복사한다.
4. `design/README.md`와 `../README.md`의 baseline 기술을 갱신한다.
5. `./scripts/validate-release-assets.sh`를 돌리고, 실제 iPhone 홈 화면에서 29/40/60pt를 확인한다.

## 열린 질문

국내 사용자는 `kk`를 ㅋㅋ로 먼저 읽습니다. 가족 사진 앱에는 선물일 수 있지만("이번 주의 웃음을 남긴다") 우연이 아니라 의도로 정하고 App Store 카피까지 맞춰야 합니다. 이 판단이 서지 않으면 승격하지 않습니다.
