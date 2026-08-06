# 2026-08-05 Logo & Icon Imagegen Exploration

Mode: built-in `image_gen`, referenced-image refinement. 결과물은 방향 탐색용이며 production geometry와 색은 SVG/PNG master에서 결정합니다.

## Logo refinement

사용자 로고를 참조해 소문자 `weekkeep`, Plum `#5B415E`, Cream `#FBF7F2`, 같은 크기의 horizontal seven-stitch만 남기는 flat 3:1 lockup을 생성했습니다. `MON`–`SUN`, bracket, outline, shadow, gradient, texture, 추가 문구는 제거하도록 지시했습니다.

Output: `imagegen-refined-lockup-20260805.png`

## Icon refinement 1 — rejected

사용자 아이콘을 참조해 full-bleed Cream, Plum keepsake silhouette, exact-seven muted horizontal stitch, no pre-rounded tile/shadow/3D/detail로 정리하도록 지시했습니다.

Output: `../../app-icon/explorations/imagegen-keepsake-pocket-20260805.png`

판정: suitcase/briefcase로 읽혀 semantic mismatch로 폐기.

## Icon refinement 2 — rejected as production, retained as exploration

첫 결과와 사용자 원본을 참조해 handle이 없는 front-facing photo album, 왼쪽 spine, 큰 photo window, exact-seven muted stitch로 수정하도록 지시했습니다.

Output: `../../app-icon/explorations/imagegen-album-20260805.png`

판정: album 방향은 좋아졌지만 floppy-disk처럼 읽힐 여지가 있고 미세 gradient가 남아 production에는 부적합. 사용자 원안의 즉시 읽히는 photo/camera 의미를 채택하고 deterministic flat vector로 재제작했습니다.

# 2026-08-05 `eekkee` 구조 탐색 (2차)

Mode: Codex CLI 비대화형 `codex exec` + built-in `image_gen`.

`weekkeep`은 8글자가 `week`+`keep`으로 4+4 분할되고, 그 경계가 두 `k` 사이이며, 바깥 `w`·`p`를 떼면 `eekkee`가 같은 축의 회문입니다. 8글자 사이의 빈칸은 정확히 7개입니다. 이 구조를 시각화하는 워드마크 4안과 앱 아이콘 3안을 생성했습니다.

## Wordmark 탐색안

| 파일 | 개념 |
|---|---|
| `imagegen-seven-gaps-20260805.png` | 일곱 빈칸마다 스티치 하나. seven-stitch를 레일이 아니라 단어 구조 안에 배치 |
| `imagegen-fold-kk-20260805.png` | 두 번째 `k`만 좌우 반전. 두 k가 마주 보며 생긴 마름모 여백에 Golden Hour 마름모 |
| `imagegen-seam-kk-20260805.png` | 두 `k` 사이를 벌리고 Coral 세로 박음질 |
| `imagegen-core-tint-20260805.png` | 형태 변형 없이 `w`·`p`만 흐린 Plum `#B3A5AF`로 톤 다운 |

## App icon 탐색안

| 파일 | 개념 |
|---|---|
| `../../app-icon/explorations/imagegen-icon-kk-monogram-20260805.png` | 거울 대칭 `kk` 모노그램 + 중앙 Golden Hour 마름모 |
| `../../app-icon/explorations/imagegen-icon-kk-solid-20260805.png` | 같은 모노그램의 단색·연결 실루엣 |
| `../../app-icon/explorations/imagegen-icon-kk-inverse-20260805.png` | Plum 바탕에 Cream 모노그램 반전 |
| `../../app-icon/explorations/imagegen-icon-kk-size-qa-20260805.png` | 세 후보의 60/40/29pt 크기 검증 보드 |

## 후처리와 검증

생성 원본은 배경이 단색이 아니었습니다(예: 첫 시도 워드마크가 12,278색, 배경이 지정 Cream이 아닌 `#FCF9F4` 부근). Design Guide의 flat 단색·gradient 금지 조건을 맞추기 위해 지정 팔레트로 정규화했습니다.

- 워드마크 4안: 모두 지정 색만 남도록 정규화(3안은 3색, seven-gaps는 9색)
- 아이콘 3안: 스티치 밴드를 `red`·`blue` 위치로 특정한 뒤 밴드 안에서만 7색을 **좌→우 순서대로 위치 배정**했습니다. `#E39455`와 `#E5A84B`는 거리가 22밖에 안 되어 최근접 매핑으로는 서로 섞였고, `#686286`·`#8A6386`는 Plum↔Cream 안티에일리어싱 중간색과 겹쳐 글자 가장자리에 색 얼룩을 만들었습니다.
- `imagegen-icon-kk-monogram`은 원본에서 2번 스티치만 fill이 1035px로 나머지(~3900px)의 1/4이었습니다. 등크기·등불투명도 규칙(`D-030`) 위반이라 이웃 스티치 마스크로 복구했습니다.

검증 결과: 세 아이콘 모두 스티치 정확히 7개, 폭 편차 ±1px, 중심 간격 편차 ±1px, 좌→우 red→violet 순서 일치, 스티치별 픽셀 수 편차 4.6~6.8%.

## 판정

네 워드마크 안과 세 아이콘 안 모두 **방향 탐색용**입니다. production asset이 아닙니다.

- 서체가 `LINESeedSansKR-Bold`가 아니라 image_gen이 그린 유사 기하 산세리프입니다
- 정규화 후 안티에일리어싱이 없어 가장자리가 계단형입니다
- 스티치 좌표와 자간이 렌더마다 달라 재현되지 않습니다

방향을 채택하면 `D-030`·`D-031`을 먼저 개정하고, geometry와 색은 `design/brand/`·`design/app-icon/`의 deterministic SVG master에서 확정합니다.
