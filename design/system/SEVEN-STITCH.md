# Seven-stitch Rail

Weekkeep의 `7장`을 나타내는 단일 브랜드 컴포넌트입니다.

## 불변 조건

- stitch 개수는 모든 크기·상태에서 정확히 **7개**입니다.
- weekday, streak, 연속 사용 일수를 뜻하지 않습니다.
- horizontal rail을 회전해 vertical album binding으로 사용합니다.
- tab icon도 같은 geometry를 축소하여 사용합니다.
- raster/image generation이 stitch를 직접 그리지 않습니다.
- SwiftUI 구현과 최종 screenshot export에서 코드로 렌더링합니다.

## 상태

| 파일 | 상태 |
|---|---|
| `seven-stitch-rail-coral.svg` | Welcome/ready의 `최대 7장` brand accent; 초안 준비 완료를 뜻하지 않음 |
| `seven-stitch-rail-selected.svg` | 첫 사진 선택 예시; 선택 위치에 따라 Plum stitch 이동 |
| `seven-stitch-rail-progress-4.svg` | 7개 중 4개 진행 예시 |
| `seven-stitch-rail-plum.svg` | 선택된 tab icon |
| `seven-stitch-rail-sage.svg` | 저장 완료 |
| `seven-stitch-rail-muted.svg` | 비활성 tab icon |
| `seven-stitch-binding-coral.svg` | 같은 geometry를 세로축으로 배치한 album binding |

## SwiftUI geometry

```swift
let stitchCount = 7

HStack(spacing: 22) {
    ForEach(0..<stitchCount, id: \.self) { index in
        Capsule()
            .fill(color(for: index))
            .frame(width: index == selectedIndex ? 4 : 3,
                   height: index == selectedIndex ? 14 : 10)
    }
}
.background(alignment: .center) {
    Rectangle()
        .fill(Color.weekkeepLinen)
        .frame(height: 1)
}
```

접근성에서는 이미 `사진 7장`, `3번째 사진 선택됨`을 별도 텍스트로 제공하므로 rail 자체는 `accessibilityHidden(true)`로 처리합니다.
