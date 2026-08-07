# Weekkeep Product Requirements Document

| 항목 | 값 |
|---|---|
| 버전 | 0.6-approved |
| 기준일 | 2026-08-07 |
| 상태 | Approved |
| 제품 책임 | Kim Sol + Codex |
| 대상 릴리스 | V1 / Shipaton 2026 public release |
| 플랫폼 | iPhone, iOS 18+ |

## 1. Executive Summary

부모의 사진첩에는 아이와 보낸 순간이 계속 쌓이지만, 사진을 고르고 글을 쓰고 앨범을 만드는 일은 또 하나의 숙제가 됩니다. Weekkeep은 그 숙제를 **이미 제안된 최대 7장을 확인하는 1분짜리 주간 의식**으로 바꿉니다.

앱은 사용자가 허용한 사진 중 해당 주의 사진을 기기에서 분석하여 최대 7장을 먼저 제안합니다. 사용자는 마음에 들지 않는 사진만 후보와 바꾸고 저장합니다. 결과는 날짜순 사진 보관함이 아니라, 한 주에 하나씩 쌓이는 가족의 기억입니다.

### 제품 문장

> 가장 최근에 완료된 한 주, 최대 7장으로 남겨요.

### 핵심 차별점

1. **주간 제약:** 무한한 사진 정리가 아니라 ‘완료된 한 주의 최대 7장’만 다룹니다.
2. **검토 중심:** 빈 화면에서 고르게 하지 않고, 첫 선택을 준비해 둡니다.
3. **프라이버시:** 사진 고르기와 공유 이미지 만들기는 기기에서 처리하고, 원본·썸네일·사진 정보는 분석을 위해 외부 서비스로 보내지 않습니다. 공유는 사용자가 직접 선택할 때만 시작합니다.
4. **반복 가능한 의식:** 월요일 리마인더와 쌓여 가는 주간 보관함이 기록 습관을 만듭니다.

## 2. 문제 정의

### 사용자가 겪는 문제

- 아이 사진을 많이 찍지만 ‘좋은 사진을 고르는 일’은 계속 미룹니다.
- 기존 사진 앱은 검색과 회상에는 강하지만, 가족의 일주일을 의도적으로 마감하는 흐름은 약합니다.
- 육아일기는 글쓰기 부담이 크고, 포토북은 제작 단위와 비용이 큽니다.
- 자동 생성 결과는 편하지만 통제감이 부족하거나, 프라이버시가 불분명하면 신뢰하기 어렵습니다.

### 해결할 핵심 긴장

| 긴장 | Weekkeep의 선택 |
|---|---|
| 자동화 vs 통제 | 7장을 먼저 제안하되 모든 사진을 교체 가능하게 함 |
| 기록 가치 vs 작업 부담 | 빈 화면에서 고르지 않고, 활성 조작 1분 내 검토·저장 |
| 사진 품질 vs 가족 의미 | 품질·중복·시간 다양성만 보조하고 ‘누가 중요한가’를 단정하지 않음 |
| 개인화 vs 프라이버시 | 얼굴 신원 학습 없이 기기 내 사진 특징만 사용 |
| 빠른 출시 vs 확장성 | 로컬 전용 V1, 서비스 경계는 향후 동기화를 막지 않게 설계 |

## 3. 목표와 비목표

### 목표

| ID | 목표 | 성공 기준 |
|---|---|---|
| `GOAL-01` | 첫 가치와 반복 가치를 빠르게 만든다 | 설치 후 첫 저장까지 중앙값 2분 이하, 반복 주 활성 검토 시간 중앙값 60초 이하 |
| `GOAL-02` | 주간 기록 완료를 반복 행동으로 만든다 | Retention Pilot·출시 cohort에서 W2 eligible completion 30% 방향 확인, W4 추세 측정; 출시 전 Usability Beta의 exit gate로 사용하지 않음 |
| `GOAL-03` | 자동 선택에 대한 신뢰와 통제감을 만든다 | 초기 7장 중 평균 5장 이상 유지 |
| `GOAL-04` | 가족 사진 제품에 필요한 프라이버시 신뢰를 만든다 | 사진 데이터 외부 전송 0건, 관련 P0/P1 결함 0건 |
| `GOAL-05` | 실제 결제가 가능한 공개 앱을 출시한다 | RevenueCat 구매/복원 포함 미국 App Store 공개 |
| `GOAL-06` | 저장 결과를 공유하고 싶은 제품 보상으로 만든다 | Weekkeep attribution이 포함된 Story/Post 제공, 측정 가능한 첫 두 cohort에서 Save Confirmation의 `share_completed / album_saved`를 Story/Post별 초기 가설로 검증; iOS share activity의 completed callback만 뜻하며 외부 게시·수신은 주장하지 않음 |

### V1 비목표

- 아이 또는 가족 구성원의 신원 식별
- 사진 삭제, 중복 정리, 저장 공간 확보
- 자동 캡션, 일기 작성, 성장 마일스톤 추론
- 가족 공동 편집 및 초대
- CloudKit/서버 동기화, 계정 생성
- 앱 삭제 후 복원, 새 기기 이전, 주간 기록 자동 백업
- 계정·사회적 피드·댓글·좋아요·가족 초대·클라우드 업로드·서버 렌더링
- Android, iPad 전용 레이아웃, 웹 앱
- Dark Mode 전용 UI·색상 token·QA
- 월간·연간 회고, 위젯, 포토북 주문
- 과거 사진 전체 백필 또는 무제한 앨범 재생성
- 원격 푸시 캠페인과 복잡한 CRM

## 4. 대상 사용자

### Primary Persona — 기록하고 싶지만 시간이 없는 부모

- 0–6세 아이를 둔 iPhone 사용자
- 주당 30장 이상의 가족 사진을 찍음
- 육아일기나 앨범 앱을 시작했지만 꾸준히 쓰지 못한 경험이 있음
- 사진을 외부 AI 서버에 올리는 데 민감할 수 있음
- 완벽한 기록보다 ‘놓치지 않고 조금씩 남기는 것’을 원함

### Job To Be Done

> 한 주가 끝날 때, 사진첩을 오래 뒤지거나 글을 쓰지 않고도 이번 주 아이와 보낸 순간을 작게 마감하고 싶다. 그래야 시간이 지나도 우리 가족의 평범한 주들을 다시 볼 수 있다.

### 사용 맥락

- 기본 리마인더 순간: 월요일 20:30, 아이가 잠든 뒤
- 실제 완료 가능 시간: 다음 일요일까지 사용자가 여유 있는 어느 때나
- 기기: 한 손에 든 iPhone
- 가용 시간: 분석 대기를 제외한 활성 조작 1분 내외
- 정서: 피곤하지만 지난주를 부담 없이 남기고 싶음

## 5. 제품 원칙

1. **기억이 AI보다 먼저다.** UI는 모델 성능이 아니라 가족의 결과를 말합니다.
2. **빈 화면보다 초안을 준다.** 사용자는 만드는 사람이 아니라 확인하는 사람으로 시작합니다.
3. **보상 후 요청한다.** 알림 권한은 첫 기록 저장 후에만 요청합니다.
4. **한 화면에 한 결정만 둔다.** 허용, 기다림, 검토, 저장을 한꺼번에 요구하지 않습니다.
5. **불확실성을 숨기지 않는다.** 사진이 부족하거나 접근이 제한되면 실제 상태를 말합니다.
6. **죄책감을 만들지 않는다.** 놓친 주, 적은 사진, 구매하지 않은 사용자를 꾸짖지 않습니다.
7. **부모가 마지막 편집자다.** 제안 결과는 언제나 사용자가 바꿀 수 있습니다.
8. **매일 열게 만들지 않는다.** DAU, streak, 일일 prompt보다 한 주를 완성하고 장기 보관함이 쌓이는 가치를 우선합니다.
9. **보존 범위를 과장하지 않는다.** V1은 앱 관리형 백업·기기 간 복원을 제공하거나 보장하지 않으며, Plus 평생 이용권을 데이터의 영구 보존으로 표현하지 않습니다.

## 6. V1 경험 범위

### 핵심 루프

1. 첫 실행에서는 가장 최근에 완전히 끝난 로컬 월–일 주를 우선 대상으로 엽니다. 그 주의 적격 사진이 0장일 때만 최근 rolling 7일을 fallback으로 확인하고, 두 범위가 모두 비면 empty state를 유지합니다. 이후에는 월–일이 끝난 다음 월요일부터 가장 최근 완료 주를 대상으로 엽니다.
2. 사용자가 허용한 Photos 자산을 가져옵니다.
3. 기기 내에서 품질, 중복, 시간 분포를 분석합니다.
4. 최대 14장 중 최대 7장을 초안으로 먼저 보여줍니다.
5. 사용자는 초안을 그대로 승인하거나 마음에 들지 않는 사진만 보통 0–2장 교체합니다.
6. 저장하면 `Weeks` 보관함에 주차별로 쌓입니다.
7. 저장 직후 실제 사진으로 만든 Weekkeep Story/Post 이미지를 기기에서 준비하고, 사용자가 원할 때 native share sheet로 공유합니다.
8. 다음 월요일 20:30에 로컬 알림으로 다시 돌아오며, 다음 일요일까지 완료할 수 있습니다.

### 첫 경험과 반복 경험

| 경험 | 날짜 범위 | 목적 |
|---|---|---|
| Welcome Week | 가장 최근 완료된 로컬 월–일 주; 적격 사진이 0장일 때만 rolling 7일 fallback | 설치 직후 즉시 가치 제공 |
| Regular Week | 로컬 시간대 월 00:00–일 23:59, 다음 월–일 7일간 완료 가능 | 반복 가능한 주간 기록 |

완료 주 Welcome을 저장하면 그 앨범의 `weekEnd`(현재 월요일)를 `regularCycleStartsAt`으로 둡니다. rolling fallback Welcome과 기존에 저장된 legacy rolling Welcome은 저장 시점 다음 월요일 규칙을 유지합니다. 이미 저장된 `regularCycleStartsAt`은 다시 계산하거나 덮어쓰지 않습니다. 모든 경우 선택된 정확한 `WeekRange`를 권한 재개·CTA·foreground curation까지 고정하고, 첫 Regular Week는 그 cycle에서 시작하는 **새로운 전체 캘린더 주**가 끝난 다음 월요일에 열립니다. Welcome Week와 거의 같은 사진으로 즉시 두 번째 기록을 만들지 않고 과거 주를 대량 백필하지 않습니다.

0.5 문서의 ‘Welcome은 기본 rolling 7일’ 문구와 그에 따른 일반 CTA는 `D-036`에 의해 `Deprecated`입니다. rolling 7일은 completed week에 적격 사진이 0장일 때의 truthful fallback 및 기존 저장 데이터 호환 경로로만 남습니다.

### 기능 범위

| 영역 | V1 포함 | 이후 |
|---|---|---|
| 사진 접근 | 전체/제한/거부 상태 지원 | 가족 공유 보관함 최적화 |
| 분석 | 미학 품질, 얼굴 품질 보조, 중복, 시간 다양성 | 사용자별 선호 학습 |
| 선택 | 초기 최대 7장 + 교체 후보 최대 7장 | 수동 전체 사진 탐색 |
| 기록 | 현재 앱 설치의 로컬 저장, 주별 목록/상세, 보존 한계 안내 | 백업, 기기 이전, 캡션 |
| 공유 보상 | 저장된 실제 사진의 on-device Story 9:16/Post 4:5 렌더링과 native share sheet | social feed, comments, likes, account, cloud upload |
| 재방문 | 월요일 20:30 로컬 알림, 7일 완료 창 | OneSignal 기반 캠페인 |
| 결제 | RevenueCat 평생 이용권/복원 | 구독 실험 |
| 측정 | 익명 행동 이벤트 | 세분화된 리텐션 메시지 |

## 7. 기능 요구사항

### 온보딩과 권한

#### `FR-001` 가치 중심 첫 화면

- 최초 실행 시 3페이지 튜토리얼 대신 한 화면에서 핵심 결과를 보여줍니다.
- 필수 문구: ‘첫 주 추억 고르기/Choose your first week’, 가장 최근 완료된 월–일 주에서 시작한다는 설명, ‘최대 7장’, ‘사진 고르기는 이 iPhone 안에서 이뤄짐’.
- completed week에 사진이 없을 때만 보이는 fallback copy는 최근 7일을 확인한다는 사실을 명시합니다. Regular CTA는 `지난주 추억 고르기` / `Choose moments from last week`입니다.

수용 기준:

- 사용자는 시스템 권한 팝업 전에 사진 접근 이유와 결과를 이해할 수 있습니다.
- 이 화면에서는 알림·결제·계정 정보를 요구하지 않습니다.

#### `FR-002` 맥락형 사진 권한 요청

- 사용자가 `첫 주 추억 고르기`를 탭한 직후 Photos 읽기 권한을 요청합니다.
- 목적 문자열은 가장 최근 완료된 월–일 주에서 시작하고 사진이 없을 때만 최근 7일을 확인한다는 이유와 사진 고르기가 iPhone에서 처리된다는 사실을 구체적으로 설명합니다.

#### `FR-003` 모든 Photos 권한 상태 처리

- `.authorized`: 접근 가능한 전체 라이브러리 사용
- `.limited`: 선택된 사진만으로 동작하고 제한 상태 배지와 관리 진입점 표시
- `.denied`: 설정 이동 방법과 재시도 제공
- `.restricted`: 기기·보호자·조직 정책 설명만 제공하며 Settings/manage CTA를 제공하지 않음
- `.notDetermined`: 사전 설명 후 시스템 요청

수용 기준:

- 제한 접근에서도 강제로 전체 접근을 요구하지 않습니다.
- 거부 상태를 빈 보관함이나 분석 실패로 위장하지 않습니다.

### 날짜와 후보 수집

#### `FR-004` 일관된 주차 계산

- 캘린더는 ISO-style Monday start를 사용하되 사용자 현재 시간대를 적용합니다.
- `weekKey`는 `YYYY-Www` 형태의 로컬 주차 식별자로 저장합니다.
- Welcome Week 이후에는 `weekStart >= regularCycleStartsAt`인 완료 주만 Regular target이 될 수 있습니다. completed week Welcome의 cycle은 `album.weekEnd`, rolling/legacy Welcome은 저장 시점 다음 월요일이며 기존 persisted cycle은 보존합니다.
- Regular Week의 사진 범위는 월요일 00:00부터 일요일 23:59까지이며, 그 다음 월요일 00:00에 eligible이 됩니다.
- 해당 기록은 다음 일요일 23:59까지 현재 대상으로 유지됩니다. 이 기간 안에서는 알림 시각과 무관하게 언제든 시작할 수 있습니다.
- 완료 창 안에서 분석을 시작했다면 자정을 지나도 그 foreground 흐름이 저장·취소될 때까지 같은 `weekKey`를 유지합니다.
- 완료 창을 놓치고 새 주가 끝나면 가장 최근 완료 주 하나로 대상을 교체합니다. 밀린 주 목록, 연속 백필, streak 손실은 만들지 않습니다.
- DST 및 시간대 변경에도 같은 실제 주가 중복 저장되지 않아야 합니다.

#### `FR-005` 해당 범위 사진만 수집

- 이미지 자산만 포함합니다. 동영상, 스크린샷, 숨김 항목은 V1 후보에서 제외합니다.
- Welcome은 우선 최근 완료된 한 주만 조회합니다. 그 범위의 적격 사진이 0장일 때만 최근 rolling 7일을 조회하며, 두 범위 모두 요청 범위 밖 사진으로 부족분을 채우지 않습니다.
- Regular Week도 다른 주의 사진으로 부족분을 채우지 않습니다.
- 접근 가능한 descriptor는 최대 500개까지 metadata scan할 수 있습니다.
- deterministic metadata prefilter가 local calendar day와 4시간 time bucket coverage를 먼저 확보한 뒤 최대 21개(7일×3개)만 Vision에 전달합니다. favorite와 resolution은 coverage 이후 tie-breaker입니다.

### 기기 내 분석과 제안

#### `FR-006` 기기 내 분석

- 분석은 Apple Photos/Vision 기반으로 기기에서 수행합니다.
- 원본, 썸네일, 임베딩, Photos local identifier와 같은 사진 정보는 분석을 위해 서버나 분석 SDK에 전송하지 않습니다.
- iCloud 원본 다운로드가 필요한 경우 진행 상태와 네트워크 대기를 표시합니다.
- analysis image는 약 416px의 fast PhotoKit representation을 사용하며 display/share image 품질 경로와 분리합니다.
- per-asset 약 1.5초 timeout과 약 12초 global foreground budget을 적용합니다. 일부 사진을 처리하지 못해도 실제 성공 사진만으로 partial result를 만들고, fake photo나 백그라운드 완료 주장은 하지 않습니다.

#### `FR-007` 최대 7장 초기 선택

- 품질, 근접 중복, 촬영 시간 분포를 조합해 초기 선택을 만듭니다.
- 아이 신원이나 가족 관계를 추론하지 않습니다.
- 후보가 14장 이상이면 초기 선택 7장과 교체 후보 7장을 제공합니다.
- 후보가 7–13장이면 초기 선택 최대 7장, 나머지를 교체 후보로 제공합니다.

#### `FR-008` 7장 미만의 정직한 결과

- 유효한 사진이 1–6장이면 실제 개수만 표시합니다.
- ‘7장을 채우기 위해’ 다른 날짜 사진을 섞지 않습니다.
- 사진이 0장이면 날짜 범위와 권한 상태에 맞는 빈 상태를 표시합니다.

### 검토와 저장

#### `FR-009` 한 화면 검토

- 선택된 사진, 날짜 범위, 사진 수, `교체`와 `저장` 행동을 한 화면에서 제공합니다.
- primary path는 준비된 초안을 그대로 저장하는 것이며 교체는 선택 행동입니다. 처음부터 7장을 직접 고르게 하지 않습니다.
- 반복 주의 활성 검토 시간 목표는 중앙값 60초 이하입니다. foreground 분석 대기와 앱이 background에 있던 시간은 이 지표에서 제외합니다.
- 선택 순서는 기본적으로 촬영 시간순입니다.
- 사진을 처음 탭하면 교체 대상을 선택하고 `이 사진 바꾸기`를 노출합니다. 같은 선택 사진을 다시 탭하면 전체 화면 viewer를 엽니다.
- 선택 상태는 저장을 위한 필수 단계가 아니며, 사용자는 아무 사진도 선택하지 않고 초안을 그대로 저장할 수 있습니다.
- VoiceOver 등 보조 기술에서는 순차 탭을 강요하지 않고 각 photo에 `크게 보기`와 `사진 교체` custom action을 직접 제공합니다.

#### `FR-010` 개별 교체

- 선택된 사진의 `이 사진 바꾸기` 또는 해당 photo의 접근성 `사진 교체` action을 실행하면 아직 선택되지 않은 후보가 표시됩니다.
- 새 후보를 고르면 검토 중 해당 위치만 crossfade로 바뀌며 나머지 사진의 표시 위치와 선택은 유지됩니다.
- 저장할 때 최종 사진 set을 촬영 시간순으로 정규화하며 cover의 visual hero 배치는 별도 metadata로 유지합니다.
- 취소하면 원래 선택을 유지합니다.
- 이미 선택된 사진을 중복으로 고를 수 없습니다.
- replacement sheet의 첫 상태는 display timezone 기준으로 선택 사진과 같은 calendar day의 미사용 후보만 보여줍니다.
- same-day 후보가 없으면 따뜻한 empty explanation과 '다른 날 사진 보기' opt-in을 제공합니다. same-day 후보가 있어도 다른 날 보기 disclosure는 명시적 secondary action으로만 제공합니다.
- opt-in 뒤의 후보는 날짜별 heading/group으로 구분하고 다른 날짜를 조용히 섞지 않습니다.
- 분석 결과가 허용하면 selected calendar day마다 미사용 강한 alternative를 bounded shortlist에 먼저 보존합니다.

#### `FR-011` 초안 취소와 재시도

- 분석 중 취소할 수 있고, 취소된 초안은 저장 기록으로 계산하지 않습니다.
- 실패 후 재시도는 동일 날짜 범위를 유지합니다.
- V1에는 무제한 ‘다시 추천’ 버튼을 제공하지 않습니다.

#### `FR-012` 주차별 멱등 저장

- 같은 `weekKey`를 다시 저장하면 새 앨범을 삽입하지 않고 기존 기록을 갱신합니다.
- 저장 성공 뒤에만 무료 사용 횟수를 증가시킵니다.
- 저장 도중 앱이 종료되어도 중복·부분 기록을 남기지 않습니다.

#### `FR-023` 저장 결과를 로컬 공유 이미지로 보상

- 저장 성공 뒤 Save Confirmation의 primary action은 local share preparation입니다. 기존 archive detail에서도 같은 action을 다시 시작할 수 있습니다.
- Story format은 정확히 1080×1920 (9:16), Post format은 정확히 1080×1350 (4:5)입니다.
- renderer는 saved album의 실제 PhotoKit display images를 사용하고 warm paper background, canonical wordmark, exact seven muted stitch palette, date range, seven-photo hero+2+4 또는 실제 장수 adaptive layout, 'Made with Weekkeep' signature를 포함합니다.
- child/family name, filename, location, photo identifier, score, analytics data, fake content와 hard-coded public install URL은 넣지 않습니다. 저장 목록에서 `createdAt` 오름차순, `weekStart` 오름차순, UUID 문자열 순으로 계산한 누적 1-based ordinal이 있으면 generic `Our family · week N` / `우리 가족의 N번째 주`를 header의 날짜 행에 함께 표시하고, lookup 실패·앨범 부재 시 생략합니다. footer에는 `How was your family's week?` / `너희 가족의 이번 주는 어땠어?`를 7-stitch 위에 절제해 표시합니다. V1 이미지에는 공개 설치 URL도 그리지 않습니다. 현재 제출된 ASC build 7은 `https://apps.apple.com/app/id6798449478`와 `A week with our family 🌈\nMade with Weekkeep.\nHow was your family's week?` / `우리 가족의 일주일 🌈\nWeekkeep으로 남겼어요.\n너희 가족의 이번 주는 어땠어?` invitation을 이미지와 분리된 native share items로만 전달합니다. image-only destination에는 local artifact가 남고, link-capable destination은 iOS 지원 범위에 따라 text와 URL을 받을 수 있습니다. 이 share contract는 historical build 6에는 포함되지 않았고, 공개 릴리스 전 URL이 live라고 주장하지 않습니다.
- renderer는 temporary local file을 만든 뒤 사용자가 명시적으로 누른 native share sheet에 전달합니다. 업로드, 계정, backend, CloudKit, server rendering, in-app social feed/comments/likes는 없습니다.
- 준비 UI는 loading, retry/error, Story/Post format selection, preview, VoiceOver label, local-only privacy copy를 제공합니다. external destination/recipient는 analytics에 기록하지 않습니다.

### 보관함과 회복

#### `FR-013` Weeks 보관함

- 저장한 기록을 최신 주부터 목록으로 표시합니다.
- 목록에는 날짜 범위, 커버 사진, 사진 수를 표시합니다.
- 상세 화면은 선택 사진을 촬영 시간순으로 보여줍니다.

#### `FR-014` 원본 사진 변경 처리

- 사용자가 Photos에서 원본을 삭제하거나 접근 범위에서 제거하면 앱은 종료되지 않아야 합니다.
- 누락된 자리는 명확한 placeholder로 표시하며 다른 사진으로 위장하지 않습니다.
- V1은 원본 사진을 앱 컨테이너에 복제 저장하지 않습니다.

#### `FR-022` 로컬 보존 범위의 정직한 안내

- 주차, 선택 순서, Photos 자산 참조는 현재 iPhone의 현재 Weekkeep 앱 설치에만 저장합니다.
- 앱 삭제·재설치 또는 새 기기 변경 뒤의 저장 기록 복원을 제공하거나 보장하지 않습니다. 원본 사진이 Photos/iCloud Photos에 남아 있어도 Weekkeep의 선택 1–7장과 순서는 자동 재구성하지 않습니다.
- `구매 복원`은 RevenueCat Plus entitlement만 복원하며 Weekkeep 기록을 복원하지 않습니다.
- Archive와 구매/복원 맥락에서 다음 의미를 한국어·영어로 명확히 전달합니다: `사진 고르기와 공유 이미지 만들기는 이 iPhone에서 처리해요. 사진 정보는 분석을 위해 외부 서비스로 보내지 않아요. 공유는 직접 선택할 때만 시작돼요. 주간 기록은 이 iPhone에 저장돼요. Weekkeep은 별도 백업을 제공하지 않아 앱을 삭제하거나 기기를 바꾸면 기록이 사라질 수 있어요.`
- `영구 보관`, `평생 보존`, `어느 기기에서나 복원`처럼 V1이 보장하지 않는 표현을 사용하지 않습니다.

### 알림

#### `FR-015` 가치 경험 후 로컬 알림

- 첫 기록 저장 성공 후에만 알림 사전 설명을 보여줍니다.
- 기본 제안 시각은 매주 월요일 20:30 로컬 시간입니다.
- Welcome Week와 겹치지 않는 Regular target이 아직 없다면 그 월요일 알림은 예약하지 않습니다.
- primer는 `월요일 20:30` 규칙을 유지하면서 정확한 다음 가능일을 함께 보여줍니다. 알림은 `월요일 저녁, 여유가 될 때 다시 볼 수 있도록 알려드릴게요.`처럼 foreground 분석을 완료했다고 주장하지 않습니다.
- 분석은 foreground에서 시작하므로 `7장이 준비됐어요`처럼 백그라운드 작업 완료를 주장하지 않습니다.
- 허용 시 로컬 알림을 예약하고, 거부해도 핵심 기능은 유지합니다.
- 해당 주 기록이 이미 저장되었으면 가능한 범위에서 중복 리마인더를 취소하고, 동일 target에 중복 예약하지 않습니다. primer를 한 번 거절하거나 처리한 뒤 반복 권한 prompt/notification spam을 만들지 않습니다.
- 알림 탭은 가장 최근 완료된 월–일 주간 기록으로 이동하며, 이 대상은 다음 일요일까지 완료할 수 있습니다.

### 결제

#### `FR-016` 무료 한도와 Plus 게이트

- 이 요구사항의 값과 승인 상태는 `D-008`을 따릅니다.
- 무료 사용자는 Welcome Week를 포함해 최초 2개의 저장 기록을 만들 수 있습니다.
- 사진 1장 이상인 세 번째 미저장 target의 `만들기` 진입 시 Plus paywall을 표시합니다.
- 사진이 0장이거나 이미 저장된 target을 여는 행동에는 paywall을 표시하지 않습니다.
- 기존 무료 기록 열람은 구매 여부와 관계없이 계속 가능합니다.

#### `FR-017` RevenueCat 구매와 복원

- 상품 유형·기준 가격의 값과 승인 상태는 `D-023`을 따릅니다.
- V1 상품은 비소모성 평생 이용권 1개입니다.
- RevenueCat entitlement ID: `plus`
- App Store product ID: `weekkeep_plus_lifetime`
- App Store Connect의 US 기준 가격은 $19.99이며 다른 storefront는 Apple 자동 등가 가격을 사용합니다.
- 앱에는 App Store/RevenueCat이 반환한 현지화 가격만 표시합니다. KR 약 ₩29,000은 초기 예상·테스트 fixture이며 production 값으로 하드코딩하지 않습니다.
- 구매 취소, 대기, 실패, 성공을 구분합니다.
- Settings와 paywall에 `구매 복원`을 제공합니다.

### 설정, 카피, 측정

#### `FR-018` Settings

- Photos 접근 상태 및 시스템 설정 진입
- 알림 상태 및 시스템 설정 진입
- Plus 상태, 구매, 구매 복원
- Help & Support 진입과 지원, 약관, 개인정보 처리방침, 버전 정보
- root Settings에는 데이터 저장·프라이버시 요약을 중복 표시하지 않으며, 보존 한계 고지는 Archive와 Paywall의 해당 맥락에 둠
- 계정/로그아웃 메뉴는 V1에 표시하지 않음

#### `FR-019` 프라이버시 보존 분석 이벤트

- 허용된 이벤트와 속성만 allowlist 방식으로 전송합니다.
- 사진 원본/썸네일/파일명/local identifier/촬영 위치/정확한 촬영 시각을 전송하지 않습니다.
- 화면 녹화와 session replay는 비활성화합니다.
- eligible weekly return과 이후 저장을 구분하기 위해 `EVT-eligible_week_opened`를 추가합니다. typed `entry_point=direct|notification`만 허용하고, direct/notification을 안정적으로 알 수 없는 경로는 추정하지 않습니다. weekKey, 날짜, 사진·식별자, recipient/destination, free-form value는 보내지 않습니다.

#### `FR-020` 한국어와 영어

- 앱과 App Store 자산은 한국어·영어를 지원합니다.
- 날짜는 시스템 locale을 따릅니다.
- ‘best’, ‘child detected’ 같은 과장·신원 추론 문구를 쓰지 않습니다.

#### `FR-021` 오류 회복

- 네트워크, iCloud 다운로드, 분석, 저장, 결제 오류를 구분합니다.
- 사용자가 실행할 수 있는 다음 행동이 있을 때만 CTA를 제공합니다.
- 기술 오류 문자열이나 사진 식별자를 사용자 화면에 노출하지 않습니다.

## 8. 비기능 요구사항

| ID | 요구사항 | 목표/수용 기준 |
|---|---|---|
| `NFR-001` | Privacy | 사진 관련 데이터 외부 전송 0, session replay off |
| `NFR-002` | Performance | design target: descriptor metadata scan ≤500개, Vision candidate ≤21개(7일×3개), analysis thumbnail 384–448px(현재 416px), per-asset timeout 약 1.5초, global foreground budget 약 12초. 실기기 측정 전이므로 verified metric/SLA가 아님 |
| `NFR-003` | Accessibility | LINE Seed semantic scaling, Dynamic Type, VoiceOver direct custom action, Reduce Motion, 색만으로 상태 전달 금지, 44pt 최소 터치 영역 |
| `NFR-004` | Offline core | 로컬 사진이 내려받아져 있다면 분석·검토·저장은 오프라인 가능 |
| `NFR-005` | Reliability | 동일 주차 중복 0, 저장 원자성, crash-free sessions ≥99.5% 목표 |
| `NFR-006` | Concurrency | Swift 6 strict concurrency 경고 0, UI 상태는 MainActor에서 변경 |
| `NFR-007` | Battery/thermal | 분석 동시 작업 수 제한, 384–448px fast analysis 입력, display/share path와 분리, 원본 전체 해상도 분석 금지 |
| `NFR-008` | Maintainability | 외부 SDK를 protocol adapter 뒤에 격리, 핵심 큐레이션은 순수 Swift 테스트 가능 |
| `NFR-009` | App size | 불필요한 ML 모델·중복 SDK 없이 다운로드 크기 관리 |
| `NFR-010` | Localization | 사용자 노출 문자열 하드코딩 금지, 한국어/영어 길이 검증 |

성능 숫자는 베타 기기 측정 전까지 SLA가 아니라 **검증 가설**입니다.

## 9. 수익화 계약과 검증 가설

### Offering

아래 표는 `D-008`, `D-023`의 `Approved` 출시 기본값을 제품 맥락에서 보여주는 파생 뷰이며 승인 상태는 Decision Registry만 따릅니다.

| 항목 | V1 출시 계약 |
|---|---|
| 무료 가치 | Welcome 포함 저장 기록 2개, 현재 앱 설치에 남아 있는 기존 기록은 Plus 없이 열람 |
| 유료 가치 | 이후 모든 주간 기록 생성 |
| 상품 | 비소모성 평생 이용권 1개 |
| 가격 | US 기준 $19.99, 다른 storefront는 Apple 자동 등가 가격; production UI는 현지화 Store 가격만 표시 |
| 구독 | V1 제외 |

이 출시 계약을 승인한 것과 시장 적합성 검증은 별개입니다. `H-003`은 자연 발생 세 번째 기록의 paywall cohort로, `H-004`는 paywall→purchase 전환과 인터뷰로 검증합니다.

### 구독 전환 조건

구독은 W4 주간 기록 완료율이 35% 이상이고, 사용자 인터뷰에서 지속적 서비스 가치가 확인되기 전에는 추가하지 않습니다. 가격과 무료 한도 변경은 실험 결과를 근거로 Decision Registry를 다시 승인한 뒤 적용합니다.

## 10. 측정 계획

### North Star

`Regular Weekly Memory Completed` = `EVT-album_saved(album_kind: regular)`의 주간 고유 익명 사용자 수입니다. Welcome 저장은 반복 완료에 합산하지 않고 activation으로 분리합니다.

### 퍼널

| 단계 | 이벤트 | 핵심 속성 |
|---|---|---|
| 온보딩 시작 | `EVT-onboarding_started` | locale, app_version |
| Photos 결과 | `EVT-photo_permission_resolved` | status(full/limited/denied) |
| 분석 시작 | `EVT-curation_started` | album_kind, candidate_count_bucket |
| eligible 주간 진입 | `EVT-eligible_week_opened` | entry_point(direct/notification) |
| 분석 완료 | `EVT-curation_completed` | duration_bucket, selected_count |
| 사진 교체 | `EVT-photo_replaced` | replacement_index, no photo ID |
| 기록 저장 | `EVT-album_saved` | album_kind, regular_sequence_bucket(`w1`/`w2`/`w3_plus`), selected_count, replacement_count, active_review_duration_bucket |
| 공유창 열기 | `EVT-share_sheet_opened` | format(story/post), entry_point(save_confirmation/archive_detail); destination/recipient 없음 |
| 공유 완료 | `EVT-share_completed` | `completed == true`인 native activity completion callback을 presentation당 최대 1회 기록; format(story/post), entry_point(save_confirmation/archive_detail)만 허용하고 activity type/returned items/error/destination/recipient/message는 제외 |
| 알림 선택 | `EVT-notification_permission_resolved` | status |
| paywall 표시 | `EVT-paywall_viewed` | free_album_count |
| 구매 결과 | `EVT-purchase_resolved` | result, product_type, localized_price_bucket optional |
| 복원 결과 | `EVT-restore_resolved` | result |

### 초기 목표

| 지표 | 목표 |
|---|---|
| 사진 권한 허용률(full+limited) | ≥70% |
| 설치 → 첫 저장 activation | ≥60% |
| 첫 저장 time-to-value 중앙값 | ≤2분 |
| 반복 주 활성 검토 시간 중앙값 | ≤60초 |
| 초기 선택 유지 | selected_count=7인 기록의 평균 ≥5/7; 전체는 `kept/selected` 비율 별도 보고 |
| 저장 → 공유 완료 | Save Confirmation의 `share_completed / album_saved` ≥25% 초기 가설; Story/Post format mix 함께 확인 |
| W2 eligible-week completion | ≥30% 방향 확인; Retention Pilot·출시 cohort 지표이며 출시 전 Usability Beta gate 아님 |
| W4 eligible-week completion | 방향성과 이탈 이유 측정 |
| 월요일 알림 → 해당 주 저장 | cohort별 측정, 베타 후 목표 설정 |
| paywall → purchase | 4–5% 가설 |

작은 베타 표본에서는 숫자를 성공 선언보다 문제 탐지에 사용합니다.

공유 지표는 `share_sheet_opened`라는 **의도**와, iOS가 `completed == true`로 알려 준 native activity **완료**를 구분합니다. 후자는 외부 앱에서 실제 게시됐는지, 누구에게 보냈는지, 어느 채널을 선택했는지를 뜻하지 않으며 그 정보는 수집하거나 추정하지 않습니다. `entry_point=save_confirmation`만 저장 직후 전환 가설에 사용하고 Archive 재공유는 별도로 봅니다. V1 Release의 analytics가 no-op인 동안에는 이 수치를 주장하지 않으며, privacy audit를 통과해 측정을 켠 첫 cohort부터 baseline을 만듭니다.

W1/W2는 설치 후 단순 1·2주차가 아니라 Welcome 이후 첫 번째/두 번째 Regular Week입니다. Retention Pilot에서는 Welcome을 정해진 기한까지 저장한 참여자 roster를 denominator로 고정하고, 해당 완료 창이 닫힐 때까지 저장하지 않은 참여자도 미완료에 포함합니다. 앱을 다시 연 사람만 denominator로 잡지 않습니다.

DAU는 V1 핵심 지표가 아닙니다. Weekkeep의 건강성은 매일 여는 횟수가 아니라 `eligible → saved` 주간 완료율, W2/W4 반복 완료, 같은 iPhone에서 6개월 뒤 다시 보고 싶은 보관함이 쌓이는지로 판단합니다. 기기 변경까지 포함한 장기 보존 가치는 V1 지표나 마케팅 약속에 포함하지 않습니다.

## 11. Shipaton 2026 출시 제약

| ID | 요구사항 | Weekkeep 대응 |
|---|---|---|
| `BR-001` | 행사 기간 중 첫 공개 릴리스 | 기존 Peeka가 아닌 신규 Weekkeep bundle로 출시 |
| `BR-002` | RevenueCat SDK를 통한 실제 구매 | `FR-017`, 샌드박스·TestFlight·프로덕션 구매 검증 |
| `BR-003` | 미국에서 이용 가능 | US storefront 공개 및 영어 metadata |
| `BR-004` | 2분 미만 공개 데모 영상 | Welcome Week → 교체 → 저장 → paywall 중심 |
| `BR-005` | 1024px 아이콘, 1179×2556 screenshot, 기기 프레임 금지 | Design QA 체크리스트에 포함 |
| `BR-006` | 심사용 무료 접근 수단 | 무료 2개 기록 또는 심사 promo code 안내 |
| `BR-007` | 영어 제출 | 제품 설명·데모 자막·스토어 카피 영어 준비 |
| `BR-008` | 제출 마감 | 2026-10-01 15:45 KST 이전 제출 완료, 내부 마감은 72시간 전 |

Shipaton 카테고리 우선순위, demo/submission evidence, Build in Public 전략은 [Shipaton Submission SSOT](11-SHIPATON-SUBMISSION.md)가 단일 소유합니다. 이 PRD는 위 `BR-001`–`BR-008` 요구사항을 유지하고, 제출 선택은 해당 문서를 참조합니다.

## 12. 의존성과 리스크

| 리스크 | 가능성/영향 | 완화 |
|---|---|---|
| Photos 권한 거부 | 높음/높음 | 가치 사전 설명, limited 지원, 개인정보 카피 |
| iCloud 사진 다운로드 지연 | 중간/높음 | 진행 상태, 취소/재시도, 분석 상한 |
| 자동 선택이 가족 의미를 놓침 | 높음/높음 | 교체를 핵심 흐름으로, 과장 표현 금지, acceptance 측정 |
| 주 1회 행동도 또 하나의 숙제가 됨 | 높음/높음 | 초안 그대로 저장을 primary로, 활성 검토 60초 이하, 월–일 7일 완료 창, 작은 사진 reveal |
| 일주일을 놓친 뒤 복귀하지 않음 | 중간/높음 | streak·밀린 목록 없이 최신 완료 주 하나부터 재시작 |
| 사진이 7장 미만 | 중간/낮음 | 실제 개수 유지, 다른 주 사진으로 채우지 않음 |
| RevenueCat/App Store 설정 지연 | 중간/높음 | 개발 초기에 test product와 entitlement 검증 |
| 1인 개발 범위 팽창 | 높음/높음 | 비목표 고정, 신규 요구는 문서 승인 후 추가 |
| 앱 삭제·새 기기에서 Weekkeep 기록 유실 | 중간/높음 | `D-022`와 `FR-022`의 Archive·Paywall/구매 맥락 안내, 영구 보존 표현 금지, 원본은 Photos에 유지; 백업/sync는 별도 V2 결정 |
| 기존 코드 재사용이 부채를 유입 | 중간/높음 | 알고리즘 단위 재작성/테스트, 프로젝트 복사 금지 |

## 13. 출시 승인 조건

- [ ] `FR-001`–`FR-023`의 P0 경로 구현 및 수용 테스트 통과
- [ ] 모든 권한 상태와 사진 0/1/6/7/14/21/35/100/500장 fixture 검증; 100 eligible input에서 Vision work ≤21을 증명
- [ ] Story/Post local renderer의 dimension·metadata·privacy·partial-photo contract와 save/detail share-first UI 검증
- [ ] 사진 데이터가 네트워크 요청 payload에 없음을 네트워크 검사로 확인
- [ ] RevenueCat 구매, 취소, 실패, 대기, 복원 실기기 검증
- [ ] VoiceOver, 가장 큰 접근성 텍스트, Reduce Motion 점검
- [ ] 한국어/영어 UI 및 App Store metadata 검수
- [ ] Archive와 구매/복원 맥락에서 로컬 보존 한계를 한국어·영어로 확인하고 영구 보존 오인 문구가 없음
- [ ] 크래시/데이터 손상 P0·P1 미해결 0건
- [ ] Shipaton 제출 자산과 공개 URL 검증

## 14. 근거 자료

- [Shipaton 공식 사이트](https://www.shipaton.com/)
- [Shipaton 공식 규칙](https://revenuecat-shipaton-2026.devpost.com/rules)
- [Shipaton FAQ](https://www.shipaton.com/faq)
- [Apple — Privacy, Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/privacy/)
- [Apple — Accessibility, Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility/)
- [RevenueCat SDK Quickstart](https://www.revenuecat.com/docs/getting-started/quickstart)
