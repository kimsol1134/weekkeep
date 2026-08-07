import Foundation
import XCTest

@testable import Weekkeep

final class VisualSystemContractTests: XCTestCase {
  private let expectedPalette = [
    "#E97A68", "#E39455", "#E5A84B", "#66836E", "#5F879B", "#686286", "#8A6386",
  ]

  func testSevenStitchPaletteHasExactCountAndCanonicalOrder() {
    XCTAssertEqual(SevenStitchRail.stitchCount, 7)
    XCTAssertEqual(SevenStitchRail.stitchPaletteHex, expectedPalette)
    XCTAssertEqual(Set(SevenStitchRail.stitchPaletteHex).count, 7)
  }

  func testRailStatesKeepPaletteIndexAndUseOpacityAndGeometrySemantics() {
    let progress = SevenStitchRail.slotStates(filledCount: 4, tone: .progress, selectedIndex: 2)

    XCTAssertEqual(progress.count, 7)
    XCTAssertEqual(progress.map(\.paletteHex), expectedPalette)
    XCTAssertEqual(progress.filter(\.isFilled).count, 4)
    XCTAssertEqual(progress.filter(\.isSelected).count, 1)
    XCTAssertTrue(progress[2].isFilled)
    XCTAssertTrue(progress[2].isSelected)
    XCTAssertEqual(progress[2].width, 4)
    XCTAssertEqual(progress[2].height, 14)
    XCTAssertEqual(progress[1].width, 3)
    XCTAssertEqual(progress[1].height, 10)
    XCTAssertGreaterThan(progress[0].opacity, progress[4].opacity)

    let muted = SevenStitchRail.slotStates(filledCount: 7, tone: .muted, selectedIndex: nil)
    XCTAssertEqual(muted.map(\.paletteHex), expectedPalette)
    XCTAssertLessThan(muted[0].opacity, progress[0].opacity)
    XCTAssertGreaterThan(progress[4].opacity, muted[0].opacity)

    let selectedRemaining = SevenStitchRail.slotStates(
      filledCount: 2, tone: .progress, selectedIndex: 5)
    XCTAssertFalse(selectedRemaining[5].isFilled)
    XCTAssertTrue(selectedRemaining[5].isSelected)
    XCTAssertEqual(selectedRemaining[5].opacity, progress[4].opacity)
    XCTAssertEqual(selectedRemaining[5].height, 14)
  }

  func testEveryRailToneKeepsEveryVisibleSlotAboveTheRainbowVisibilityFloor() {
    for tone in SevenStitchRailTone.allCases {
      for filledCount in [0, 1, 4, 7] {
        let slots = SevenStitchRail.slotStates(
          filledCount: filledCount,
          tone: tone,
          selectedIndex: 3
        )

        XCTAssertEqual(slots.count, SevenStitchRail.stitchCount)
        XCTAssertEqual(slots.map(\.paletteHex), expectedPalette)
        XCTAssertTrue(
          slots.allSatisfy { $0.opacity >= SevenStitchRail.minimumVisibleOpacity },
          "\(tone) at \(filledCount) filled slots fell below the visibility floor"
        )
      }
    }
  }

  func testBottomTabBarIconsHaveUniqueSemanticSilhouettesWithoutDecorativeStitches() throws {
    XCTAssertEqual(
      WeekkeepTabIcon.assetNames,
      ["ThisWeekTabIcon", "WeeksTabIcon", "SettingsTabIcon"]
    )
    XCTAssertEqual(Set(WeekkeepTabIcon.assetNames).count, 3)
    XCTAssertEqual(
      WeekkeepTabIcon.silhouetteIDs,
      ["calendar", "album-stack", "sliders"]
    )
    XCTAssertEqual(Set(WeekkeepTabIcon.silhouetteIDs).count, 3)
    XCTAssertTrue(WeekkeepTabIcon.usesOriginalRendering)
    XCTAssertGreaterThan(WeekkeepTabIcon.inactiveOpacity, 0)

    let tabIconSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/DesignSystem/Components/WeekkeepTabIcon.swift"),
      encoding: .utf8
    )
    XCTAssertFalse(tabIconSource.contains("SevenStitchRail"))
    XCTAssertFalse(tabIconSource.contains("seven-stitches"))

    let appShellSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent("Weekkeep/App/RootView.swift"),
      encoding: .utf8
    )
    XCTAssertTrue(appShellSource.contains("WeekkeepTabIcon"))
    XCTAssertFalse(appShellSource.contains("SevenStitchRail"))

    for kind in WeekkeepTabIconKind.allCases {
      let svgURL =
        repositoryRoot
        .appendingPathComponent("Weekkeep/Resources/Assets.xcassets")
        .appendingPathComponent("\(kind.assetName).imageset")
        .appendingPathComponent("\(kind.assetName).svg")
      let contentsURL = svgURL.deletingLastPathComponent().appendingPathComponent("Contents.json")
      guard let svg = try? String(contentsOf: svgURL, encoding: .utf8),
        let contents = try? String(contentsOf: contentsURL, encoding: .utf8)
      else {
        XCTFail("Missing tab icon asset for \(kind.rawValue)")
        continue
      }

      XCTAssertEqual(svg.components(separatedBy: "<rect").count - 1, semanticRectCount(for: kind))
      XCTAssertTrue(svg.contains("id=\"semantic-\(kind.silhouetteID)\""))
      XCTAssertTrue(svg.contains("#5B415E"))
      XCTAssertTrue(contents.contains("\"template-rendering-intent\" : \"original\""))
      XCTAssertFalse(
        svg.contains("seven-stitches"), "Bottom tab icons must not render decorative stitches")
      for color in expectedPalette {
        XCTAssertFalse(
          svg.contains(color), "Bottom tab icon contains decorative stitch color \(color)")
      }
    }
  }

  func testOnboardingPreviewUsesAllSevenFixturesWithoutLegacyBarsOrStack() {
    XCTAssertEqual(SamplePhotoFixtures.assetNames.count, SevenStitchRail.stitchCount)
    XCTAssertEqual(OnboardingKeepsakePreviewContract.fixtureIndices, Array(0..<7))

    guard
      let source = try? String(
        contentsOf: repositoryRoot.appendingPathComponent(
          "Weekkeep/Features/Onboarding/OnboardingView.swift"),
        encoding: .utf8
      )
    else {
      XCTFail("Unable to read onboarding source contract")
      return
    }

    XCTAssertTrue(source.contains("FixturePhotoStory(style: .onboarding)"))
    XCTAssertTrue(
      source.contains("static let fixtureIndices = Array(0..<SamplePhotoFixtures.assetNames.count)")
    )
    XCTAssertFalse(source.contains("KeepsakePageHeader"))
    XCTAssertFalse(source.contains("Capsule()"))
    XCTAssertFalse(source.contains("rotationEffect"))
    XCTAssertFalse(source.contains("SamplePhotoArt"))
  }

  func testPhotoStorySurfacesShareFixtureVocabularyAndPaywallPresentation() throws {
    let photoStorySource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/DesignSystem/Components/PhotoStoryMosaic.swift"),
      encoding: .utf8
    )
    XCTAssertTrue(photoStorySource.contains("SamplePhotoFixtures.assetName(for: index)"))
    XCTAssertTrue(photoStorySource.contains("WeeklyPhotoGridLayout.sevenPhotoGeometry"))
    XCTAssertTrue(photoStorySource.contains("case onboarding"))
    XCTAssertTrue(photoStorySource.contains("case compact"))
    XCTAssertTrue(photoStorySource.contains("FixturePhotoStoryGeometry"))
    XCTAssertTrue(photoStorySource.contains("FixturePhotoMosaic(style: style)"))
    XCTAssertTrue(
      photoStorySource.contains("VStack(spacing: FixturePhotoStoryGeometry.onboardingGutter)"))
    XCTAssertTrue(photoStorySource.contains("ViewThatFits(in: .horizontal)"))
    XCTAssertFalse(photoStorySource.contains("struct FixturePhotoMosaicLayout"))
    XCTAssertTrue(photoStorySource.contains(".clipped()"))
    XCTAssertTrue(photoStorySource.contains("WeekkeepRadii.small"))
    XCTAssertFalse(photoStorySource.contains("LinearGradient"))
    XCTAssertFalse(photoStorySource.contains("Image(systemName:"))

    let readySource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/WeeklyCuration/WeeklyViews.swift"),
      encoding: .utf8
    )
    XCTAssertTrue(readySource.contains("FixturePhotoStory(style: .compact)"))
    XCTAssertFalse(readySource.contains("SamplePhotoArt"))
    XCTAssertTrue(readySource.contains(".fullScreenCover(item: paywallBinding)"))
    XCTAssertFalse(
      readySource.contains(
        "PlusPaywallView(model: model)\n                    .presentationDetents"))

    let paywallSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/Paywall/PlusPaywallView.swift"),
      encoding: .utf8
    )
    XCTAssertTrue(paywallSource.contains("FixturePhotoStory(style: .compact)"))
    XCTAssertFalse(paywallSource.contains("SamplePhotoArt"))

    let settingsSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/Settings/SettingsViews.swift"),
      encoding: .utf8
    )
    XCTAssertTrue(settingsSource.contains(".fullScreenCover(item: purchaseBinding)"))
    XCTAssertFalse(settingsSource.contains(".sheet(isPresented: purchaseSheetBinding)"))

    let productionSwift =
      try FileManager.default
      .subpaths(atPath: repositoryRoot.appendingPathComponent("Weekkeep").path)?
      .filter { $0.hasSuffix(".swift") }
      .map { repositoryRoot.appendingPathComponent("Weekkeep").appendingPathComponent($0) }
      .map { try String(contentsOf: $0, encoding: .utf8) }
      .joined(separator: "\n") ?? ""
    XCTAssertFalse(productionSwift.contains("SamplePhotoArt"))
  }

  func testRailClampsFilledCountWithoutChangingSevenSlotInvariant() {
    let full = SevenStitchRail.slotStates(filledCount: 99, tone: .coral, selectedIndex: 8)
    let empty = SevenStitchRail.slotStates(filledCount: -1, tone: .coral, selectedIndex: -1)

    XCTAssertEqual(full.count, 7)
    XCTAssertTrue(full.allSatisfy(\.isFilled))
    XCTAssertNil(full.first(where: \.isSelected))
    XCTAssertEqual(empty.count, 7)
    XCTAssertTrue(empty.allSatisfy { !$0.isFilled })
    XCTAssertNil(empty.first(where: \.isSelected))
  }

  func testOnboardingFixtureManifestHasSevenStableAssetNames() {
    XCTAssertEqual(SamplePhotoFixtures.assetNames.count, 7)
    XCTAssertEqual(
      SamplePhotoFixtures.assetNames,
      (1...7).map { String(format: "OnboardingMoment%02d", $0) }
    )
    XCTAssertEqual(
      (0..<7).map { SamplePhotoFixtures.assetName(for: $0) },
      SamplePhotoFixtures.assetNames
    )
  }

  func testOnboardingPhotoStoryUsesOnePlusThreePlusThreeWithMinimumGutters() {
    let geometry = FixturePhotoStoryGeometry.onboardingGeometry(
      availableWidth: 314,
      spacing: WeekkeepSpacing.one
    )
    let minimumGutter = WeekkeepSpacing.three

    XCTAssertEqual(SamplePhotoFixtures.assetNames.count, SevenStitchRail.stitchCount)
    XCTAssertEqual(OnboardingKeepsakePreviewContract.fixtureIndices.count, 7)
    XCTAssertEqual(geometry.allFrames.count, SevenStitchRail.stitchCount)
    XCTAssertEqual(geometry.middle.count, 3)
    XCTAssertEqual(geometry.bottom.count, 3)
    XCTAssertEqual(FixturePhotoStoryGeometry.onboardingGutter, minimumGutter)
    XCTAssertEqual(geometry.hero.width / geometry.hero.height, 1.6, accuracy: 0.001)

    for (index, frame) in geometry.allFrames.enumerated() {
      for otherFrame in geometry.allFrames.dropFirst(index + 1) {
        XCTAssertFalse(frame.intersects(otherFrame), "Onboarding photo frames must not overlap")
      }
    }

    assertPositiveAdjacentGaps(
      geometry.allFrames,
      minimumGap: minimumGutter,
      messagePrefix: "Onboarding"
    )

    for row in [geometry.middle, geometry.bottom] {
      XCTAssertTrue(
        row.dropFirst().allSatisfy { frame in
          abs(frame.width - row[0].width) < 0.001 && abs(frame.height - row[0].height) < 0.001
        })

      for (left, right) in zip(row, row.dropFirst()) {
        XCTAssertGreaterThanOrEqual(
          right.minX - left.maxX,
          minimumGutter,
          "Onboarding thumbnails need a horizontal gutter"
        )
      }
    }

    XCTAssertGreaterThanOrEqual(
      geometry.middle[0].minY - geometry.hero.maxY,
      minimumGutter,
      "Onboarding hero and first thumbnail row need a vertical gutter"
    )
    XCTAssertGreaterThanOrEqual(
      geometry.bottom[0].minY - geometry.middle[0].maxY,
      minimumGutter,
      "Onboarding thumbnail rows need a vertical gutter"
    )
  }

  func testCompactPhotoStoryRetainsHeroTwoPlusFourGeometry() {
    let geometry = FixturePhotoStoryGeometry.geometry(for: .compact, availableWidth: 358)

    XCTAssertEqual(geometry.middle.count, 2)
    XCTAssertEqual(geometry.bottom.count, 4)
    XCTAssertEqual(FixturePhotoStoryGeometry.compactGutter, WeekkeepSpacing.two)
    XCTAssertEqual(geometry.hero.width / geometry.hero.height, 1.6, accuracy: 0.001)
    XCTAssertEqual(
      geometry.middle[0].minY,
      geometry.hero.maxY + FixturePhotoStoryGeometry.compactGutter,
      accuracy: 0.001
    )
    XCTAssertEqual(
      geometry.bottom[0].minY,
      geometry.middle[0].maxY + FixturePhotoStoryGeometry.compactGutter,
      accuracy: 0.001
    )

    for width in [CGFloat(358), CGFloat(190)] {
      let compactGeometry = FixturePhotoStoryGeometry.geometry(
        for: .compact,
        availableWidth: width
      )
      assertPositiveAdjacentGaps(
        compactGeometry.allFrames,
        minimumGap: FixturePhotoStoryGeometry.compactGutter,
        messagePrefix: "Compact width \(width)"
      )
    }
  }

  func testSevenPhotoGridFallsBackBeforeTouchTargetsShrinkBelow44Points() {
    XCTAssertEqual(WeeklyPhotoGridLayout.minimumWidth(for: 4, spacing: 8), 200)
    XCTAssertEqual(
      WeeklyPhotoGridLayout.preferredSevenPhotoColumnCount(availableWidth: 200, spacing: 8),
      4
    )
    XCTAssertEqual(
      WeeklyPhotoGridLayout.preferredSevenPhotoColumnCount(availableWidth: 199, spacing: 8),
      2
    )
  }

  func testSevenPhotoGridUsesWideHeroAndNonOverlappingRows() {
    let geometry = WeeklyPhotoGridLayout.sevenPhotoGeometry(availableWidth: 358)

    XCTAssertEqual(WeeklyPhotoGridLayout.gridSpacing, WeekkeepSpacing.two)
    XCTAssertEqual(geometry.middle.count, 2)
    XCTAssertEqual(geometry.bottom.count, 4)
    XCTAssertEqual(geometry.hero.width / geometry.hero.height, 1.6, accuracy: 0.001)
    XCTAssertGreaterThan(geometry.hero.width, geometry.hero.height)
    XCTAssertTrue(geometry.bottom.allSatisfy { $0.width >= WeeklyPhotoGridLayout.minimumTileWidth })

    for (index, frame) in geometry.allFrames.enumerated() {
      for otherFrame in geometry.allFrames.dropFirst(index + 1) {
        XCTAssertFalse(frame.intersects(otherFrame), "Photo frames must not overlap")
      }
    }

    XCTAssertEqual(
      geometry.middle[0].minY, geometry.hero.maxY + WeeklyPhotoGridLayout.gridSpacing,
      accuracy: 0.001)
    XCTAssertEqual(
      geometry.bottom[0].minY, geometry.middle[0].maxY + WeeklyPhotoGridLayout.gridSpacing,
      accuracy: 0.001)
  }

  func testWeeklyReviewUsesInlineSaveOrderAndIndependentStitches() throws {
    let reviewSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/WeeklyCuration/ReviewViews.swift"),
      encoding: .utf8
    )
    let gridRange = try XCTUnwrap(reviewSource.range(of: "WeeklyPhotoGrid("))
    let privacyRange = try XCTUnwrap(
      reviewSource.range(of: "PrivacyBadge(title: \"week.privacy\")"))
    let saveRange = try XCTUnwrap(reviewSource.range(of: "SCR-WK-03-Save"))

    XCTAssertLessThan(gridRange.lowerBound, privacyRange.lowerBound)
    XCTAssertLessThan(privacyRange.lowerBound, saveRange.lowerBound)
    XCTAssertTrue(reviewSource.contains("WeeklyReviewHeaderCluster"))
    XCTAssertFalse(reviewSource.contains("ScreenHeader("))
    XCTAssertFalse(reviewSource.contains(".safeAreaInset(edge: .bottom)"))

    let railSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/DesignSystem/Components/SevenStitchRail.swift"),
      encoding: .utf8
    )
    XCTAssertFalse(railSource.contains(".background("))

    let controlsSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/DesignSystem/Components/WeekkeepControls.swift"),
      encoding: .utf8
    )
    let privacyStart = try XCTUnwrap(controlsSource.range(of: "struct PrivacyBadge"))
    let privacyEnd = try XCTUnwrap(controlsSource.range(of: "struct WeekkeepWordmark"))
    let privacySource = String(controlsSource[privacyStart.lowerBound..<privacyEnd.lowerBound])
    XCTAssertFalse(privacySource.contains(".background("))
    XCTAssertTrue(privacySource.contains("lock.fill"))

    let photoSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/DesignSystem/Components/PhotoComponents.swift"),
      encoding: .utf8
    )
    XCTAssertTrue(photoSource.contains("heroAspectRatio: CGFloat = 16 / 10"))
    XCTAssertTrue(photoSource.contains("PhotoTileAspectLayout"))
    XCTAssertTrue(photoSource.contains("frame(width: proxy.size.width, height: proxy.size.height)"))
  }

  func testCustomScreenRootsUseResponsiveHorizontalEdgeContract() throws {
    XCTAssertEqual(WeekkeepScreenLayout.defaultHorizontalPadding, 20)
    XCTAssertEqual(WeekkeepScreenLayout.smallScreenHorizontalPadding, 16)
    XCTAssertEqual(WeekkeepScreenLayout.smallScreenWidth, 375)

    XCTAssertEqual(WeekkeepScreenLayout.horizontalPadding(for: 440), 20)
    XCTAssertEqual(WeekkeepScreenLayout.horizontalPadding(for: 376), 20)
    XCTAssertEqual(WeekkeepScreenLayout.horizontalPadding(for: 375), 16)
    XCTAssertEqual(WeekkeepScreenLayout.horizontalPadding(for: 320), 16)
    XCTAssertEqual(WeekkeepScreenLayout.contentWidth(for: 440), 400)
    XCTAssertEqual(WeekkeepScreenLayout.contentWidth(for: 320), 288)

    for path in [
      "Weekkeep/Features/Onboarding/OnboardingView.swift",
      "Weekkeep/Features/WeeklyCuration/WeeklyViews.swift",
      "Weekkeep/Features/WeeklyCuration/ReviewViews.swift",
      "Weekkeep/Features/Archive/ArchiveViews.swift",
      "Weekkeep/Features/Paywall/PlusPaywallView.swift",
      "Weekkeep/Features/Sharing/WeeklyAlbumShare.swift",
    ] {
      let source = try String(
        contentsOf: repositoryRoot.appendingPathComponent(path),
        encoding: .utf8
      )
      XCTAssertTrue(
        source.contains("WeekkeepScreenLayout.horizontalPadding(for:"),
        "Missing responsive root-edge contract in \(path)"
      )
    }

    let settingsSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/Settings/SettingsViews.swift"),
      encoding: .utf8
    )
    XCTAssertTrue(settingsSource.contains("List {"))
    XCTAssertTrue(settingsSource.contains(".listStyle(.insetGrouped)"))

    XCTAssertEqual(WeeklyAlbumShareSpacing.rootSection, WeekkeepSpacing.six)
    let shareSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/Sharing/WeeklyAlbumShare.swift"),
      encoding: .utf8
    )
    XCTAssertTrue(shareSource.contains("WeeklyAlbumShareSpacing.rootSection"))
  }

  func testWeeklyReviewSpacingHierarchyDoesNotCompressScreenshotFixtures() throws {
    let reviewSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/WeeklyCuration/ReviewViews.swift"),
      encoding: .utf8
    )

    XCTAssertFalse(reviewSource.contains("-ui-app-store-fixtures"))
    XCTAssertFalse(reviewSource.contains("reviewLayoutSpacing"))
    XCTAssertFalse(reviewSource.contains("reviewTopPadding"))
    XCTAssertFalse(reviewSource.contains("WeekkeepSpacing.one / 2"))

    XCTAssertEqual(WeeklyReviewSpacing.screenEdge, 20)
    XCTAssertEqual(WeeklyReviewSpacing.smallScreenEdge, 16)
    XCTAssertEqual(WeeklyReviewSpacing.screenEdge(for: 440), 20)
    XCTAssertEqual(WeeklyReviewSpacing.screenEdge(for: 320), 16)
    XCTAssertEqual(WeeklyReviewSpacing.screenTop, WeekkeepSpacing.four)
    XCTAssertEqual(WeeklyReviewSpacing.headerCluster, WeekkeepSpacing.two)
    XCTAssertEqual(WeeklyReviewSpacing.headerToEditorial, WeekkeepSpacing.eight)
    XCTAssertEqual(WeeklyReviewSpacing.titleBodyEditorial, WeekkeepSpacing.three)
    XCTAssertEqual(WeeklyReviewSpacing.partialNotice, WeekkeepSpacing.six)
    XCTAssertEqual(WeeklyReviewSpacing.editorialToMedia, WeekkeepSpacing.eight)
    XCTAssertEqual(WeeklyReviewSpacing.mediaGrid, WeekkeepSpacing.two)
    XCTAssertEqual(WeeklyReviewSpacing.helperReplace, WeekkeepSpacing.four)
    XCTAssertEqual(WeeklyReviewSpacing.privacy, WeekkeepSpacing.four)
    XCTAssertEqual(WeeklyReviewSpacing.primaryAction, WeekkeepSpacing.six)
    XCTAssertEqual(WeeklyReviewSpacing.screenBottom, WeekkeepSpacing.six)
    XCTAssertEqual(WeeklyReviewSpacing.scrollRunway, WeekkeepSpacing.sixteen + WeekkeepSpacing.two)
    XCTAssertGreaterThan(WeeklyReviewSpacing.headerToEditorial, WeeklyReviewSpacing.titleBodyEditorial)
    XCTAssertGreaterThan(WeeklyReviewSpacing.editorialToMedia, WeeklyReviewSpacing.titleBodyEditorial)
    XCTAssertGreaterThan(WeeklyReviewSpacing.helperReplace, WeeklyReviewSpacing.mediaGrid)
    XCTAssertGreaterThan(WeeklyReviewSpacing.primaryAction, WeeklyReviewSpacing.privacy)
    XCTAssertGreaterThanOrEqual(WeeklyReviewSpacing.mediaGrid, WeekkeepSpacing.two)
    XCTAssertTrue(reviewSource.contains("proxy.safeAreaInsets.top"))
    XCTAssertTrue(reviewSource.contains("weekkeepTopSystemOcclusion"))
    XCTAssertTrue(reviewSource.contains("WeeklyReviewSpacing.scrollRunway"))
    XCTAssertFalse(reviewSource.contains("WeekkeepSystemSafeArea.top"))

    let rootSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent("Weekkeep/App/RootView.swift"),
      encoding: .utf8
    )
    XCTAssertTrue(rootSource.contains("WeekkeepSystemSafeArea.top(for: proxy.size") || rootSource.contains("WeekkeepSystemSafeArea.top(\n"))
    XCTAssertTrue(rootSource.contains("geometrySafeAreaTop: proxy.safeAreaInsets.top"))

    for marker in [
      "WeeklyReviewSpacing.screenEdge",
      "WeeklyReviewSpacing.screenTop",
      "WeeklyReviewSpacing.headerCluster",
      "WeeklyReviewSpacing.headerToEditorial",
      "WeeklyReviewSpacing.titleBodyEditorial",
      "WeeklyReviewSpacing.partialNotice",
      "WeeklyReviewSpacing.editorialToMedia",
      "WeeklyReviewSpacing.mediaGrid",
      "WeeklyReviewSpacing.helperReplace",
      "WeeklyReviewSpacing.privacy",
      "WeeklyReviewSpacing.primaryAction",
      "WeeklyReviewSpacing.screenBottom",
      "WeeklyReviewSpacing.scrollRunway",
    ] {
      XCTAssertTrue(
        reviewSource.contains(marker), "Missing Weekly Review spacing marker: \(marker)")
    }
  }

  func testTopOcclusionIsSharedByOnboardingAndWeeklyReviewWithoutTouchOrAccessibilityCapture() throws {
    let onboardingSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/Onboarding/OnboardingView.swift"),
      encoding: .utf8
    )
    let reviewSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/WeeklyCuration/ReviewViews.swift"),
      encoding: .utf8
    )
    let themeSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/DesignSystem/Theme/WeekkeepTheme.swift"),
      encoding: .utf8
    )

    XCTAssertTrue(
      onboardingSource.contains(
        ".weekkeepTopSystemOcclusion(localSafeAreaTop: proxy.safeAreaInsets.top)"
      )
    )
    XCTAssertTrue(
      reviewSource.contains(
        ".weekkeepTopSystemOcclusion(localSafeAreaTop: proxy.safeAreaInsets.top)"
      )
    )
    XCTAssertTrue(themeSource.contains("WeekkeepTopSystemOcclusion.height"))
    XCTAssertTrue(themeSource.contains(".allowsHitTesting(false)"))
    XCTAssertTrue(themeSource.contains(".accessibilityHidden(true)"))
    XCTAssertTrue(themeSource.contains("WeekkeepColors.primaryBackground"))
  }

  func testThisWeekUsesSemanticTabHostScrollClearance() throws {
    XCTAssertEqual(
      WeekkeepTabHostSpacing.bottomScrollClearance,
      WeekkeepSpacing.sixteen + WeekkeepSpacing.two
    )
    XCTAssertGreaterThan(WeekkeepTabHostSpacing.bottomScrollClearance, WeekkeepSpacing.six)

    let weeklySource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/WeeklyCuration/WeeklyViews.swift"),
      encoding: .utf8
    )
    let normalizedWeeklySource = weeklySource.replacingOccurrences(
      of: "\\s+",
      with: " ",
      options: .regularExpression
    )
    let internalClearance =
      ".padding(.bottom, WeekkeepSpacing.six + WeekkeepTabHostSpacing.bottomScrollClearance)"
    XCTAssertEqual(
      normalizedWeeklySource.components(separatedBy: internalClearance).count - 1,
      1,
      "This Week must keep tab-bar clearance inside the ScrollView content"
    )
    let internalClearanceRange = try XCTUnwrap(normalizedWeeklySource.range(of: internalClearance))
    let scrollIndicatorsRange = try XCTUnwrap(
      normalizedWeeklySource.range(of: ".scrollIndicators(.hidden)")
    )
    XCTAssertLessThan(
      internalClearanceRange.lowerBound,
      scrollIndicatorsRange.lowerBound,
      "Content runway must be applied before the ScrollView modifier boundary"
    )
    XCTAssertFalse(
      normalizedWeeklySource.contains(
        ".scrollIndicators(.hidden) .padding(.bottom, WeekkeepTabHostSpacing.bottomScrollClearance)"
      ),
      "This Week must not shrink the ScrollView viewport with outer bottom clearance"
    )
    XCTAssertFalse(weeklySource.contains(".safeAreaInset(edge: .bottom"))
    XCTAssertFalse(weeklySource.contains("ThisWeekBottomInset"))
    XCTAssertFalse(weeklySource.contains("ThisWeekPinnedStartFooter"))
    XCTAssertFalse(weeklySource.contains("showsPinnedStartAction"))
    XCTAssertFalse(weeklySource.contains("bottomTabBarBreathingRoom"))
    XCTAssertTrue(weeklySource.contains("SCR-WK-01-Start"))
    XCTAssertTrue(weeklySource.contains("action: model.startCuration"))
    XCTAssertTrue(weeklySource.contains("WeekkeepPrimaryButton("))
    let readyBodyRange = try XCTUnwrap(weeklySource.range(of: "Text(isWelcome ? \"week.welcomeBody\""))
    let readyCTARange = try XCTUnwrap(weeklySource.range(of: "WeekkeepPrimaryButton("))
    let readyPhotoStoryRange = try XCTUnwrap(weeklySource.range(of: "ReadyPhotoStack()"))
    XCTAssertLessThan(readyBodyRange.lowerBound, readyCTARange.lowerBound)
    XCTAssertLessThan(readyCTARange.lowerBound, readyPhotoStoryRange.lowerBound)
    XCTAssertFalse(weeklySource.contains("bottomTabBarOcclusion"))
    XCTAssertFalse(weeklySource.contains("ZStack(alignment: .bottom)"))
    XCTAssertFalse(weeklySource.contains(".ignoresSafeArea(edges: .bottom)"))

    let settingsSource = try String(
      contentsOf: repositoryRoot.appendingPathComponent(
        "Weekkeep/Features/Settings/SettingsViews.swift"),
      encoding: .utf8
    )
    XCTAssertFalse(settingsSource.contains("bottomTabBarOcclusion"))
    XCTAssertFalse(settingsSource.contains(".ignoresSafeArea(edges: .bottom)"))
  }

  private var repositoryRoot: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
  }

  private func assertPositiveAdjacentGaps(
    _ frames: [CGRect],
    minimumGap: CGFloat,
    messagePrefix: String
  ) {
    let tolerance: CGFloat = 0.001

    for (index, frame) in frames.enumerated() {
      for (otherIndex, otherFrame) in frames.enumerated() where otherIndex > index {
        XCTAssertFalse(
          frame.intersects(otherFrame),
          "\(messagePrefix) photo frames must not overlap: \(index) and \(otherIndex)"
        )

        if abs(frame.minY - otherFrame.minY) <= tolerance {
          let gap =
            frame.minX < otherFrame.minX
            ? otherFrame.minX - frame.maxX
            : frame.minX - otherFrame.maxX
          XCTAssertGreaterThan(gap, 0, "\(messagePrefix) horizontal gap must be positive")
          XCTAssertGreaterThanOrEqual(
            gap, minimumGap, "\(messagePrefix) horizontal gutter is too small")
        }

        if abs(frame.minX - otherFrame.minX) <= tolerance {
          let gap =
            frame.minY < otherFrame.minY
            ? otherFrame.minY - frame.maxY
            : frame.minY - otherFrame.maxY
          XCTAssertGreaterThan(gap, 0, "\(messagePrefix) vertical gap must be positive")
          XCTAssertGreaterThanOrEqual(
            gap, minimumGap, "\(messagePrefix) vertical gutter is too small")
        }
      }
    }
  }

  private func semanticRectCount(for kind: WeekkeepTabIconKind) -> Int {
    switch kind {
    case .week: 1
    case .archive: 4
    case .settings: 3
    }
  }
}
