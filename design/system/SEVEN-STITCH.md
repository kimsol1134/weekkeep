# Seven-stitch Rail

Weekkeep의 `7장`을 나타내는 단일 브랜드 컴포넌트입니다.

## 불변 조건

- stitch 개수는 모든 크기·상태에서 정확히 **7개**입니다.
- weekday, streak, 연속 사용 일수를 뜻하지 않습니다.
- horizontal rail을 회전해 vertical album binding으로 사용합니다.
- tab icon은 rail geometry를 primary silhouette로 축소하지 않고, 각 기능의 semantic glyph만 bottom tab bar에 사용합니다. bottom tab bar에는 decorative seven-color signature를 렌더링하지 않습니다.
- 본 rail과 vertical binding은 SwiftUI에서 코드로 렌더링합니다. TabView label은 `ThisWeekTabIcon`, `WeeksTabIcon`, `SettingsTabIcon`의 deterministic original-rendering vector asset을 사용해 시스템 template tint를 피합니다. 세 asset은 기능별 semantic silhouette 계약만 공유합니다.
- 모든 visible stitch는 opacity `0.58` 이상이어야 합니다. 이 값보다 낮은 opacity는 iPhone 및 1080p video scale에서 canonical 색을 회색처럼 보이게 하므로 허용하지 않습니다.
- rail은 일곱 개의 독립 stitch로만 구성합니다. 추가 선·막대·분할자를 두지 않습니다.

## 상태

모든 상태가 같은 index별 muted rainbow를 공유합니다. 상태 차이는 색 교체가 아니라 filled/unfilled와 semantic tone의 opacity, selected slot의 geometry, vertical/horizontal orientation으로 표현합니다.

| 상태 | filled | remaining/muted | selected geometry |
|---|---|---|---|
| Welcome/ready | 7색 각 index의 full semantic opacity | 같은 7색의 `≥0.58` opacity | 일반 geometry |
| progress | 앞의 `filledCount`만 full opacity | 나머지 slot `≥0.58` opacity | 일반 geometry |
| selected | 선택 index는 기존 색을 유지하고 강조 opacity | — | 4×14pt, 나머지 3×10pt |
| saved/muted rail | 7색 각 index를 tone별 낮은/중간 opacity로 유지하되 `≥0.58` | 같은 7색의 `≥0.58` opacity | 일반 geometry |
| bottom tab icon | 고유한 Plum semantic glyph만 렌더링 | decorative stitch 없음 | tab kind별 고유 silhouette |
| vertical binding | index order를 위→아래로 유지 | orientation만 변경 | selected geometry 유지 |

Canonical palette order: `#E97A68`, `#E39455`, `#E5A84B`, `#66836E`, `#5F879B`, `#686286`, `#8A6386` (`D-030`).

## SwiftUI geometry

```swift
let stitchCount = 7

HStack(spacing: 22) {
    ForEach(0..<stitchCount, id: \.self) { index in
        Capsule()
            .fill(mutedRainbow[index].opacity(opacity(for: index)))
            .frame(width: index == selectedIndex ? 4 : 3,
                   height: index == selectedIndex ? 14 : 10)
    }
}
```

접근성에서는 이미 `사진 7장`, `3번째 사진 선택됨`을 별도 텍스트로 제공하므로 rail 자체는 `accessibilityHidden(true)`로 처리합니다.
