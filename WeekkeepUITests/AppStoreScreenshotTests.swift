import XCTest

/// Deliberately separate from the ordinary fixture UI suite. The capture
/// script opts in with WK_CAPTURE_APP_STORE_SCREENSHOTS=1 and runs this test
/// once per locale on the dedicated 6.9-inch simulator. The app uses bundled
/// SamplePhotoFixtures in this mode; these screenshots are deterministic UI
/// evidence and do not exercise PhotoKit.
@MainActor
final class AppStoreScreenshotTests: XCTestCase {
  private let minimumReviewGap: CGFloat = 8

  private let semanticScreens = [
    "01-welcome",
    "02-curation-progress",
    "03-review",
    "04-replace",
    "05-saved-weeks",
    "06-plus",
  ]

  func testCaptureBundledFixtureAppStoreScreenshots() throws {
    guard ProcessInfo.processInfo.environment["WK_CAPTURE_APP_STORE_SCREENSHOTS"] == "1" else {
      throw XCTSkip("App Store screenshot capture is opt-in.")
    }

    let locale = ProcessInfo.processInfo.environment["WK_APP_STORE_SCREENSHOT_LOCALE"] ?? "en-US"
    XCTAssertTrue(["en-US", "ko"].contains(locale), "Unsupported screenshot locale: \(locale)")

    let app = XCUIApplication()
    app.launchArguments = [
      "-ui-app-store-fixtures",
      "-AppleLanguages", locale == "ko" ? "(ko)" : "(en)",
      "-AppleLocale", locale == "ko" ? "ko_KR" : "en_US",
    ]
    app.launchEnvironment = [
      "WK_CAPTURE_APP_STORE_SCREENSHOTS": "1",
      "WK_APP_STORE_SCREENSHOT_LOCALE": locale,
    ]
    app.launch()

    let primary = app.buttons["SCR-ONB-01-Primary"]
    XCTAssertTrue(primary.waitForExistence(timeout: 10))
    capture(named: "\(locale)-\(semanticScreens[0])")

    primary.tap()
    let progressTitle = app.staticTexts["SCR-WK-02-CurationProgress"]
    XCTAssertTrue(progressTitle.waitForExistence(timeout: 10))
    XCTAssertFalse(app.alerts.firstMatch.exists)
    Thread.sleep(forTimeInterval: 0.25)
    capture(named: "\(locale)-\(semanticScreens[1])")

    let save = app.buttons["SCR-WK-03-Save"]
    XCTAssertTrue(save.waitForExistence(timeout: 25))
    waitForPhotoTiles(in: app, count: 7)
    let reviewTitle = app.staticTexts["SCR-WK-03-Title"]
    XCTAssertTrue(reviewTitle.waitForExistence(timeout: 5))
    XCTAssertTrue(reviewTitle.isHittable)
    // The top App Store story is intentionally a clean, photo-first frame.
    // Lower actions are captured separately after an explicit scroll;
    // production layout is never compressed for this attachment.
    frameReviewTopStoryForScreenshot(in: app)
    capture(named: "\(locale)-\(semanticScreens[2])")

    let scrollView = app.scrollViews.firstMatch
    XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
    let lowerPhoto = app.buttons["CMP-05-PhotoTile-6"]
    XCTAssertTrue(lowerPhoto.waitForExistence(timeout: 5))
    for _ in 0..<8 {
      if lowerPhoto.isHittable { break }
      scrollView.swipeUp()
      Thread.sleep(forTimeInterval: 0.25)
    }
    XCTAssertTrue(lowerPhoto.isHittable)
    lowerPhoto.tap()

    let replaceSelected = app.buttons["SCR-WK-03-ReplaceSelected"]
    XCTAssertTrue(replaceSelected.waitForExistence(timeout: 5))
    XCTAssertFalse((lowerPhoto.value as? String ?? "").isEmpty)
    for _ in 0..<8 {
      if lowerPhoto.isHittable && replaceSelected.isHittable { break }
      if !replaceSelected.isHittable {
        scrollView.swipeUp()
      } else if !lowerPhoto.isHittable {
        scrollView.swipeDown()
      }
      Thread.sleep(forTimeInterval: 0.25)
    }
    XCTAssertTrue(lowerPhoto.isHittable)
    XCTAssertTrue(replaceSelected.isHittable)
    XCTAssertFalse(app.staticTexts["SHEET-REP-01-Content"].exists)
    XCTAssertFalse(app.buttons["SHEET-REP-01-Cancel"].exists)
    Thread.sleep(forTimeInterval: 0.5)
    // This is the intentionally scrolled lower-action state: the selected
    // photo, replace action, privacy note, and save CTA remain breathable
    // and reachable without requiring the header to share the frame.
    frameReviewLowerActionsForScreenshot(in: app, requiresReplacementAction: true)
    capture(named: "\(locale)-\(semanticScreens[3])")

    // Reassert the safe lower-action framing before the QA-only duplicate
    // bottom attachment. The composed six-screen set uses 04-replace;
    // this attachment remains a validator input, not a submission image.
    frameReviewLowerActionsForScreenshot(in: app, requiresReplacementAction: true)
    scrollToSave(in: app, lastPhotoIndex: 6)
    capture(named: "\(locale)-03-review-bottom")
    save.tap()

    let savedTitle = app.staticTexts["SCR-WK-05-Title"]
    XCTAssertTrue(savedTitle.waitForExistence(timeout: 10))
    let viewRecord = app.buttons["SCR-WK-05-View"]
    XCTAssertTrue(viewRecord.waitForExistence(timeout: 5))
    viewRecord.tap()

    let archiveRow = app.descendants(matching: .any)
      .matching(identifier: "SCR-ARC-01-WeekRow")
      .firstMatch
    XCTAssertTrue(archiveRow.waitForExistence(timeout: 10))
    Thread.sleep(forTimeInterval: 0.75)
    capture(named: "\(locale)-\(semanticScreens[4])")

    let settingsTab = app.tabBars.buttons.element(boundBy: 2)
    XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
    settingsTab.tap()
    let openPlus = app.buttons["SHEET-PAY-01-Open"]
    XCTAssertTrue(openPlus.waitForExistence(timeout: 10))
    openPlus.tap()

    let paywallTitle = app.staticTexts["SHEET-PAY-01-Title"]
    XCTAssertTrue(paywallTitle.waitForExistence(timeout: 10))
    XCTAssertTrue(app.staticTexts["SHEET-PAY-01-Price"].waitForExistence(timeout: 10))
    Thread.sleep(forTimeInterval: 0.5)
    capture(named: "\(locale)-\(semanticScreens[5])")
  }

  private func waitForPhotoTiles(in app: XCUIApplication, count: Int) {
    // The seven-photo hero+2+4 layout is taller than the 6.9-inch viewport.
    // The custom seven-photo layout is taller than the viewport, so visit
    // the lower row to prove all seven bundled-fixture tiles exist, then
    // restore the top framing for capture.
    let firstRowCount = min(3, count)
    for index in 0..<firstRowCount {
      XCTAssertTrue(app.buttons["CMP-05-PhotoTile-\(index)"].waitForExistence(timeout: 5))
    }

    guard count > firstRowCount else {
      Thread.sleep(forTimeInterval: 0.8)
      return
    }

    let scrollView = app.scrollViews.firstMatch
    XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
    for _ in 0..<5 {
      let lowerRowMaterialized = (firstRowCount..<count).allSatisfy {
        app.buttons["CMP-05-PhotoTile-\($0)"].exists
      }
      if lowerRowMaterialized { break }
      scrollView.swipeUp()
      Thread.sleep(forTimeInterval: 0.25)
    }
    for index in firstRowCount..<count {
      XCTAssertTrue(app.buttons["CMP-05-PhotoTile-\(index)"].waitForExistence(timeout: 5))
    }

    let header = app.buttons["SCR-WK-03-Header"]
    let title = app.staticTexts["SCR-WK-03-Title"]
    let firstPhoto = app.buttons["CMP-05-PhotoTile-0"]
    let safeTop = statusBarSafeTop(in: app)
    XCTAssertTrue(header.waitForExistence(timeout: 5))
    // The hero remains hittable even while the scroll view is partially
    // advanced. Restore a real top framing instead: the semantic header
    // must sit inside the scroll viewport and precede the review title.
    for _ in 0..<12 {
      let topFramingRestored =
        header.isHittable
        && title.isHittable
        && header.frame.minY >= safeTop
        && header.frame.maxY <= scrollView.frame.maxY
        && title.frame.minY >= header.frame.maxY
      if topFramingRestored { break }
      scrollView.swipeDown()
      Thread.sleep(forTimeInterval: 0.25)
    }
    XCTAssertTrue(header.isHittable)
    XCTAssertTrue(title.isHittable)
    // Keep the semantic header below the actual status-bar boundary and
    // above the title without coupling the capture test to one fixed point
    // value.
    XCTAssertGreaterThanOrEqual(header.frame.minY, safeTop)
    XCTAssertGreaterThanOrEqual(title.frame.minY, header.frame.maxY)
    XCTAssertTrue(firstPhoto.isHittable)
    // Fixture image requests are asynchronous. Let the bundled thumbnails
    // settle before exporting the attachment, without making the test
    // depend on a model-specific image request duration.
    Thread.sleep(forTimeInterval: 0.8)
  }

  private func capture(named name: String) {
    let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }

  private func statusBarSafeTop(in app: XCUIApplication) -> CGFloat {
    // On iOS 26 the app's accessibility tree does not expose its system
    // status bar, even though it is visible in the screenshot. Query the
    // owning SpringBoard tree so the boundary remains a runtime frame rather
    // than a simulator-specific constant.
    let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let statusBar = springBoard.statusBars.firstMatch
    XCTAssertTrue(statusBar.waitForExistence(timeout: 5))
    XCTAssertGreaterThan(statusBar.frame.height, 0)
    return statusBar.frame.maxY + minimumReviewGap
  }

  private func editorialBoundaryIsWholeOrOccluded(
    in app: XCUIApplication,
    scrollView: XCUIElement,
    safeTop: CGFloat
  ) -> Bool {
    let title = app.staticTexts["SCR-WK-03-Title"]
    let body = app.staticTexts["SCR-WK-03-Body"]
    XCTAssertTrue(title.waitForExistence(timeout: 5))
    XCTAssertTrue(body.waitForExistence(timeout: 5))
    XCTAssertGreaterThan(title.frame.height, 0)
    XCTAssertGreaterThan(body.frame.height, 0)

    let editorialIsFullyOccluded =
      title.frame.maxY <= safeTop
      && body.frame.maxY <= safeTop
    let editorialIsFullyVisible =
      title.frame.minY >= safeTop
      && body.frame.minY >= title.frame.maxY
      && body.frame.maxY <= scrollView.frame.maxY

    return editorialIsFullyOccluded || editorialIsFullyVisible
  }

  private func frameReviewTopStoryForScreenshot(in app: XCUIApplication) {
    // Use the runtime status-bar frame so this guard catches content that is
    // technically hittable but visibly drawn beneath system indicators.
    let maximumHeaderTopInset: CGFloat = 96
    let scrollView = app.scrollViews.firstMatch
    let header = app.buttons["SCR-WK-03-Header"]
    let title = app.staticTexts["SCR-WK-03-Title"]
    let body = app.staticTexts["SCR-WK-03-Body"]
    let hero = app.buttons["CMP-05-PhotoTile-0"]
    let safeTop = statusBarSafeTop(in: app)

    XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
    XCTAssertTrue(header.waitForExistence(timeout: 5))
    XCTAssertTrue(title.waitForExistence(timeout: 5))
    XCTAssertTrue(body.waitForExistence(timeout: 5))
    XCTAssertTrue(hero.waitForExistence(timeout: 5))

    for _ in 0..<12 {
      let topStoryIsSafe =
        header.isHittable
        && title.isHittable
        && hero.isHittable
        && header.frame.minY >= safeTop
        && header.frame.minY <= safeTop + maximumHeaderTopInset
        && header.frame.maxY <= scrollView.frame.maxY
        && title.frame.minY >= header.frame.maxY
        && body.frame.minY >= title.frame.maxY + minimumReviewGap
        && hero.frame.minY >= body.frame.maxY + minimumReviewGap
        && hero.frame.maxY <= scrollView.frame.maxY
      if topStoryIsSafe {
        break
      }
      scrollView.swipeDown()
      Thread.sleep(forTimeInterval: 0.2)
    }

    XCTAssertGreaterThanOrEqual(header.frame.minY, safeTop)
    XCTAssertLessThanOrEqual(header.frame.minY, safeTop + maximumHeaderTopInset)
    XCTAssertLessThanOrEqual(header.frame.maxY, scrollView.frame.maxY)
    XCTAssertGreaterThanOrEqual(title.frame.minY, header.frame.maxY)
    XCTAssertGreaterThanOrEqual(body.frame.minY, title.frame.maxY + minimumReviewGap)
    XCTAssertTrue(hero.isHittable)
    XCTAssertGreaterThanOrEqual(hero.frame.minY, body.frame.maxY + minimumReviewGap)
    XCTAssertLessThanOrEqual(hero.frame.maxY, scrollView.frame.maxY)
  }

  private func frameReviewLowerActionsForScreenshot(
    in app: XCUIApplication,
    requiresReplacementAction: Bool
  ) {
    let scrollView = app.scrollViews.firstMatch
    let lastPhoto = app.buttons["CMP-05-PhotoTile-6"]
    let privacy = app.staticTexts["CMP-03-PrivacyBadge"]
    let save = app.buttons["SCR-WK-03-Save"]
    let replacement = app.buttons["SCR-WK-03-ReplaceSelected"]
    let safeTop = statusBarSafeTop(in: app)

    XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
    XCTAssertTrue(lastPhoto.waitForExistence(timeout: 5))
    XCTAssertTrue(privacy.waitForExistence(timeout: 5))
    XCTAssertTrue(save.waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["SCR-WK-03-Title"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["SCR-WK-03-Body"].waitForExistence(timeout: 5))
    if requiresReplacementAction {
      XCTAssertTrue(replacement.waitForExistence(timeout: 5))
    }

    for _ in 0..<12 {
      let replacementIsSafe =
        !requiresReplacementAction
        || (replacement.isHittable && replacement.frame.maxY <= scrollView.frame.maxY)
      let lowerActionsAreSafe =
        lastPhoto.isHittable
        && privacy.isHittable
        && save.isHittable
        && lastPhoto.frame.minY >= safeTop
        && lastPhoto.frame.maxY <= scrollView.frame.maxY
        && (!requiresReplacementAction || lastPhoto.frame.maxY + minimumReviewGap <= replacement.frame.minY)
        && (!requiresReplacementAction || replacement.frame.maxY + minimumReviewGap <= privacy.frame.minY)
        && privacy.frame.maxY + minimumReviewGap <= save.frame.minY
        && save.frame.maxY <= scrollView.frame.maxY
        && editorialBoundaryIsWholeOrOccluded(in: app, scrollView: scrollView, safeTop: safeTop)
        && replacementIsSafe
      if lowerActionsAreSafe { break }
      scrollView.swipeUp()
      Thread.sleep(forTimeInterval: 0.2)
    }

    XCTAssertTrue(lastPhoto.isHittable)
    XCTAssertTrue(privacy.isHittable)
    XCTAssertTrue(save.isHittable)
    XCTAssertTrue(
      editorialBoundaryIsWholeOrOccluded(in: app, scrollView: scrollView, safeTop: safeTop),
      "Weekly Review editorial content must be fully visible below the status bar or fully scrolled above it."
    )
    XCTAssertGreaterThanOrEqual(lastPhoto.frame.minY, safeTop)
    XCTAssertLessThanOrEqual(lastPhoto.frame.maxY, scrollView.frame.maxY)
    if requiresReplacementAction {
      XCTAssertTrue(replacement.isHittable)
      XCTAssertGreaterThanOrEqual(
        replacement.frame.minY, lastPhoto.frame.maxY + minimumReviewGap)
      XCTAssertLessThanOrEqual(replacement.frame.maxY, privacy.frame.minY)
    }
    XCTAssertGreaterThanOrEqual(
      privacy.frame.minY,
      (requiresReplacementAction ? replacement.frame.maxY : lastPhoto.frame.maxY) + minimumReviewGap
    )
    XCTAssertGreaterThanOrEqual(save.frame.minY, privacy.frame.maxY + minimumReviewGap)
    XCTAssertLessThanOrEqual(save.frame.maxY, scrollView.frame.maxY)
  }

  private func scrollToSave(in app: XCUIApplication, lastPhotoIndex: Int) {
    let scrollView = app.scrollViews.firstMatch
    let lastPhoto = app.buttons["CMP-05-PhotoTile-\(lastPhotoIndex)"]
    let replacement = app.buttons["SCR-WK-03-ReplaceSelected"]
    let privacy = app.staticTexts["CMP-03-PrivacyBadge"]
    let save = app.buttons["SCR-WK-03-Save"]
    let safeTop = statusBarSafeTop(in: app)
    XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
    XCTAssertTrue(lastPhoto.waitForExistence(timeout: 5))
    XCTAssertTrue(replacement.waitForExistence(timeout: 5))
    XCTAssertTrue(privacy.waitForExistence(timeout: 5))

    for _ in 0..<12 {
      let completeBottomState =
        lastPhoto.isHittable && replacement.isHittable && privacy.isHittable && save.isHittable
        && lastPhoto.frame.minY >= safeTop
        && lastPhoto.frame.maxY <= scrollView.frame.maxY
        && lastPhoto.frame.maxY + minimumReviewGap <= replacement.frame.minY
        && replacement.frame.maxY + minimumReviewGap <= privacy.frame.minY
        && privacy.frame.maxY + minimumReviewGap <= save.frame.minY
        && save.frame.maxY <= scrollView.frame.maxY
        && editorialBoundaryIsWholeOrOccluded(in: app, scrollView: scrollView, safeTop: safeTop)
      if completeBottomState { break }
      scrollView.swipeUp()
      Thread.sleep(forTimeInterval: 0.2)
    }

    XCTAssertTrue(lastPhoto.isHittable)
    XCTAssertTrue(replacement.isHittable)
    XCTAssertTrue(privacy.isHittable)
    XCTAssertTrue(save.isHittable)
    XCTAssertTrue(
      editorialBoundaryIsWholeOrOccluded(in: app, scrollView: scrollView, safeTop: safeTop),
      "QA review-bottom must not contain a partially clipped editorial section."
    )
    XCTAssertGreaterThanOrEqual(lastPhoto.frame.minY, safeTop)
    XCTAssertLessThanOrEqual(lastPhoto.frame.maxY, scrollView.frame.maxY)
    XCTAssertGreaterThanOrEqual(
      replacement.frame.minY, lastPhoto.frame.maxY + minimumReviewGap)
    XCTAssertGreaterThanOrEqual(
      privacy.frame.minY, replacement.frame.maxY + minimumReviewGap)
    XCTAssertGreaterThanOrEqual(save.frame.minY, privacy.frame.maxY + minimumReviewGap)
    XCTAssertLessThanOrEqual(save.frame.maxY, scrollView.frame.maxY)
  }
}
