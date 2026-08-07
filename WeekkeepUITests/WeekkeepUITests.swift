import XCTest
import UIKit

// WeekkeepSpacing.six (24pt) is the normal-flow gap between the CTA and
// ReadyPhotoStack. The UI-test target intentionally keeps this contract local
// because the app target is not imported into XCTest.
private let thisWeekCTAPhotoStoryGap: CGFloat = 24

private enum PhysicalShareQAContract {
    static let captureEnvironment = "WK_CAPTURE_PHYSICAL_SHARE_QA"
    static let localeEnvironment = "WK_PHYSICAL_SHARE_QA_LOCALE"
    static let defaultLocale = "ko"
}

@MainActor
final class WeekkeepUITests: XCTestCase {
    func testWelcomeScreenExposesProductOutcome() {
        let app = launchFixture()

        XCTAssertTrue(app.buttons["SCR-ONB-01-Primary"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["CMP-03-PrivacyBadge"].exists)
    }

    func testReviewTapContractIsAccessibleInFixtureFlow() {
        let app = launchFixture(language: "en")
        let primary = app.buttons["SCR-ONB-01-Primary"]
        guard primary.waitForExistence(timeout: 5) else {
            XCTFail("The onboarding primary action did not appear.")
            return
        }
        primary.tap()
        let review = app.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(review.waitForExistence(timeout: 10))

        let firstPhoto = app.buttons["CMP-05-PhotoTile-0"]
        XCTAssertTrue(firstPhoto.exists)
        firstPhoto.tap()
        XCTAssertTrue(app.buttons["SCR-WK-03-ReplaceSelected"].waitForExistence(timeout: 3))
        XCTAssertEqual(firstPhoto.value as? String, "Ready to change")

        scrollToSave(in: app, lastPhotoIndex: 6, assertWideHero: true)
        review.tap()
        XCTAssertTrue(app.staticTexts["SCR-WK-05-Title"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["SCR-WK-03-Title"].exists)
    }

    func testSaveRewardAppearsBeforeNotificationPrimer() {
        let app = launchFixture(skipNotificationPrimer: false)
        let primary = app.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        primary.tap()

        let save = app.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 10))
        scrollToSave(in: app, lastPhotoIndex: 6, assertWideHero: true)
        save.tap()

        XCTAssertTrue(app.staticTexts["SCR-WK-05-Title"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["SHEET-NOT-01-Title"].exists)

        let done = app.buttons["SCR-WK-05-Done"]
        XCTAssertTrue(done.waitForExistence(timeout: 3))
        scrollToVisible(done, in: app)
        done.tap()
        XCTAssertTrue(app.staticTexts["SHEET-NOT-01-Title"].waitForExistence(timeout: 5))
    }

    func testSaveConfirmationMakesLocalShareThePrimaryReward() {
        let app = launchFixture()
        let primary = app.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        primary.tap()

        let save = app.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 10))
        scrollToSave(in: app, lastPhotoIndex: 6, assertWideHero: true)
        save.tap()

        XCTAssertTrue(app.staticTexts["SCR-WK-05-Title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["SCR-WK-05-Share"].exists)
        XCTAssertTrue(app.buttons["SCR-WK-05-View"].exists)
        XCTAssertTrue(app.buttons["SCR-WK-05-Done"].exists)

        app.buttons["SCR-WK-05-Share"].tap()
        XCTAssertTrue(app.staticTexts["SHEET-SHARE-01-Title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["SHEET-SHARE-01-FormatPicker"].exists)
        XCTAssertTrue(
            app.otherElements["SHEET-SHARE-01-Loading"].waitForExistence(timeout: 2)
                || app.images["SHEET-SHARE-01-Preview"].waitForExistence(timeout: 10)
        )
    }

    /// Fixture-only physical-iPhone QA: bundled sample pixels only, no private
    /// Photos, no destination selection, and no send. This deliberately stops
    /// after Apple presents the native sharing UI and terminates the app.
    func testPhysicalShareSheetQAIsOptInFixtureOnlyNoPrivatePixelsNoSend() throws {
        guard ProcessInfo.processInfo.environment[PhysicalShareQAContract.captureEnvironment] == "1" else {
            throw XCTSkip("Physical native share-sheet QA is opt-in.")
        }

        let rawLocale = ProcessInfo.processInfo.environment[PhysicalShareQAContract.localeEnvironment]
            ?? PhysicalShareQAContract.defaultLocale
        let language: String
        switch rawLocale.lowercased() {
        case "ko", "ko-kr", "ko_kr":
            language = "ko"
        case "en", "en-us", "en_us":
            language = "en"
        default:
            XCTFail("Unsupported physical share QA locale: \(rawLocale). Use ko or en.")
            return
        }

        // This launch is intentionally limited to the existing DEBUG fixture
        // path. It never requests or reads PhotoKit/private photos.
        let app = launchFixture(language: language, screen: "ready")
        defer {
            // Termination dismisses the native sheet without selecting a
            // destination or sending content.
            app.terminate()
        }

        let readyCTA = app.buttons["SCR-WK-01-Start"]
        guard readyCTA.waitForExistence(timeout: 8) else {
            XCTFail("The fixture ready state did not expose the start action.")
            return
        }
        readyCTA.tap()

        let curationProgress = app.staticTexts["SCR-WK-02-CurationProgress"]
        XCTAssertTrue(curationProgress.waitForExistence(timeout: 8))

        let save = app.buttons["SCR-WK-03-Save"]
        guard save.waitForExistence(timeout: 15) else {
            XCTFail("The fixture curation flow did not reach Weekly Review.")
            return
        }
        XCTAssertTrue(app.staticTexts["SCR-WK-03-Title"].exists)
        scrollToSave(in: app, lastPhotoIndex: 6)
        guard save.isHittable else {
            XCTFail("The fixture save action was not hittable after review settled.")
            return
        }
        save.tap()

        XCTAssertTrue(app.staticTexts["SCR-WK-05-Title"].waitForExistence(timeout: 8))
        let openLocalShare = app.buttons["SCR-WK-05-Share"]
        guard openLocalShare.waitForExistence(timeout: 5) else {
            XCTFail("Save Confirmation did not expose local share preparation.")
            return
        }
        openLocalShare.tap()

        XCTAssertTrue(app.staticTexts["SHEET-SHARE-01-Title"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["SHEET-SHARE-01-FormatPicker"].waitForExistence(timeout: 5))
        let preview = app.descendants(matching: .any)["SHEET-SHARE-01-Preview"]
        XCTAssertTrue(preview.waitForExistence(timeout: 20))

        let shareButton = app.buttons["SHEET-SHARE-01-Share"]
        guard shareButton.waitForExistence(timeout: 5), shareButton.isHittable else {
            XCTFail("The prepared Story/Post preview did not expose a hittable native-share action.")
            return
        }

        // Kept attachment immediately before the one and only share-sheet tap.
        let appSheetCountBeforeNativeShare = app.sheets.count
        captureScreenshot(named: "physical-share-qa-before-native-share-sheet")
        shareButton.tap()

        // Use only stable accessibility roles/containers from the app and
        // Apple system surfaces. Destination labels are deliberately ignored:
        // they vary by device, locale, and installed apps, and are not delivery
        // evidence.
        XCTAssertTrue(
            waitForNativeShareAccessibilityPresentation(
                in: app,
                existingAppSheetCount: appSheetCountBeforeNativeShare,
                timeout: 15
            ),
            "Apple native sharing UI was not visibly presented in an accessibility sheet/container."
        )
        // Kept attachment immediately after the native sheet becomes visible.
        captureScreenshot(named: "physical-share-qa-after-native-share-sheet")
    }

    func testReplacementStartsWithSameDayAndDisclosesOtherDays() {
        let app = launchFixture()
        let primary = app.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        primary.tap()

        let save = app.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 10))
        let firstPhoto = app.buttons["CMP-05-PhotoTile-0"]
        XCTAssertTrue(firstPhoto.exists)
        firstPhoto.tap()
        app.buttons["SCR-WK-03-ReplaceSelected"].tap()

        XCTAssertTrue(app.staticTexts["SHEET-REP-01-SameDay"].waitForExistence(timeout: 5))
        let seeOtherDays = app.buttons["SHEET-REP-01-SeeOtherDays"]
        if seeOtherDays.waitForExistence(timeout: 2) {
            XCTAssertFalse(app.staticTexts["SHEET-REP-01-OtherDays"].exists)
            seeOtherDays.tap()
            XCTAssertTrue(app.staticTexts["SHEET-REP-01-OtherDays"].waitForExistence(timeout: 3))
        } else {
            XCTAssertTrue(
                app.staticTexts["SHEET-REP-01-None"].waitForExistence(timeout: 3)
            )
        }
    }

    func testFixtureWindowUsesFullScreenPortraitIPhoneBoundsAndUniqueWeeklyIdentifiers() {
        let app = launchFixture()
        let primary = app.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))

        let window = app.windows.firstMatch
        XCTAssertTrue(window.exists)
        XCTAssertEqual(window.frame.minX, 0, accuracy: 1)
        XCTAssertEqual(window.frame.minY, 0, accuracy: 1)
        XCTAssertGreaterThanOrEqual(window.frame.width, 390)
        XCTAssertGreaterThanOrEqual(window.frame.height, 844)
        XCTAssertLessThan(window.frame.width, window.frame.height)
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "TAB-WEEK").count, 0)
    }

    func testThisWeekInitialFrameShowsNormalFlowCTAAboveNativeTabBar() {
        for language in ["en", "ko"] {
            for screen in ["welcome-pending", "ready", "ready-limited"] {
                let app = launchFixture(language: language, screen: screen)
                let start = app.buttons["SCR-WK-01-Start"]
                let photoStory = app.descendants(matching: .any)["SCR-WK-01-PhotoStory"]
                let photoStoryTop = app.descendants(matching: .any)["SCR-WK-01-PhotoStory-Top"]
                let tabBar = app.tabBars.firstMatch
                let window = app.windows.firstMatch
                let expectedTitle: String
                if language == "ko" {
                    expectedTitle = screen == "welcome-pending" ? "첫 주 추억 고르기" : "지난주 추억 고르기"
                } else {
                    expectedTitle = screen == "welcome-pending"
                        ? "Choose your first week"
                        : "Choose moments from last week"
                }

                XCTAssertTrue(start.waitForExistence(timeout: 8), "Missing start CTA for \(language)/\(screen)")
                XCTAssertEqual(
                    app.buttons.matching(identifier: "SCR-WK-01-Start").count,
                    1,
                    "This Week must expose exactly one start CTA for \(language)/\(screen)"
                )
                XCTAssertTrue(photoStory.waitForExistence(timeout: 5), "Missing photo story for \(language)/\(screen)")
                XCTAssertTrue(photoStoryTop.waitForExistence(timeout: 5), "Missing photo story top for \(language)/\(screen)")
                XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Missing tab bar for \(language)/\(screen)")
                XCTAssertTrue(window.waitForExistence(timeout: 5), "Missing app window for \(language)/\(screen)")
                Thread.sleep(forTimeInterval: 0.5)
                XCTAssertEqual(start.label, expectedTitle)
                XCTAssertEqual(
                    tabBar.buttons.count,
                    3,
                    "The native tab bar must keep three items for \(language)/\(screen)"
                )

                // This is intentionally the launch frame: no swipe or scroll-to-
                // element helper is allowed before these assertions.
                XCTAssertTrue(start.isHittable, "Start CTA is not hittable before scrolling for \(language)/\(screen)")
                XCTAssertGreaterThanOrEqual(
                    start.frame.minY,
                    window.frame.minY,
                    "Start CTA begins outside the app window for \(language)/\(screen)"
                )
                XCTAssertLessThanOrEqual(
                    start.frame.maxY,
                    window.frame.maxY,
                    "Start CTA extends outside the app window for \(language)/\(screen)"
                )
                XCTAssertLessThanOrEqual(
                    start.frame.maxY + thisWeekCTAPhotoStoryGap,
                    photoStoryTop.frame.minY,
                    "Normal-flow CTA/photo story gap is below the spacing token for \(language)/\(screen): "
                        + "ctaFrame=" + String(describing: start.frame)
                        + " photoStoryTopFrame=" + String(describing: photoStoryTop.frame)
                )
                XCTAssertFalse(
                    start.frame.intersects(tabBar.frame),
                    "Start CTA intersects the native tab bar for \(language)/\(screen): "
                        + "ctaFrame=" + String(describing: start.frame)
                        + " tabBarFrame=" + String(describing: tabBar.frame)
                )
                XCTAssertLessThanOrEqual(
                    start.frame.maxY,
                    tabBar.frame.minY,
                    "Start CTA must sit above the native tab bar for \(language)/\(screen): "
                        + "ctaFrame=" + String(describing: start.frame)
                        + " tabBarFrame=" + String(describing: tabBar.frame)
                )
                XCTAssertGreaterThanOrEqual(start.frame.height, 44)

                // Accessibility frames alone cannot detect a non-interactive view
                // painted over the native controls. Sample the actual launch
                // pixels so a full-width Cream occluder fails this test.
                guard let sampler = FixtureScreenshotSampler(screenshot: XCUIScreen.main.screenshot()) else {
                    XCTFail("Unable to inspect the launch screenshot for \(language)/\(screen)")
                    app.terminate()
                    continue
                }
                let plum = { (red: UInt8, green: UInt8, blue: UInt8) in
                    abs(Int(red) - 0x5B) <= 42
                        && abs(Int(green) - 0x41) <= 42
                        && abs(Int(blue) - 0x5E) <= 42
                }
                XCTAssertGreaterThan(
                    sampler.coverage(of: start.frame, in: window.frame, matching: plum),
                    0.35,
                    "The CTA accessibility frame exists but is not visibly Plum in the launch pixels for \(language)/\(screen)"
                )

                for (index, tabButton) in tabBar.buttons.allElementsBoundByIndex.enumerated() {
                    XCTAssertFalse(tabButton.label.isEmpty, "Native tab \(index) has no visible label for \(language)/\(screen)")
                    XCTAssertGreaterThan(
                        sampler.coverage(of: tabButton.frame, in: window.frame, matching: plum),
                        0.005,
                        "Native tab \(index) has an accessibility frame but no visible icon/label pixels for \(language)/\(screen)"
                    )
                }
                app.terminate()
            }
        }
    }

    func testThisWeekReadyLimitedContentCanSettleFullyAboveNativeTabBar() {
        let app = launchFixture(screen: "ready-limited")
        let scrollView = app.scrollViews.firstMatch
        let tabBar = app.tabBars.firstMatch
        // The explanatory story is intentionally taller than a compact device.
        // Check its visual bounds independently instead of requiring the whole
        // mosaic to fit in one viewport.
        let content = [
            ("photo story top", app.descendants(matching: .any)["SCR-WK-01-PhotoStory-Top"]),
            ("photo story bottom", app.descendants(matching: .any)["SCR-WK-01-PhotoStory-Bottom"]),
            ("photo count", app.descendants(matching: .any)["SCR-WK-01-PhotoCount"]),
            ("limited notice", app.descendants(matching: .any)["SCR-WK-01-LimitedAccess"]),
            ("privacy badge", app.descendants(matching: .any)["CMP-03-PrivacyBadge"]),
        ]

        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        for (name, element) in content {
            XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing \(name)")
        }
        Thread.sleep(forTimeInterval: 0.5)

        for (name, element) in content {
            for _ in 0..<18 {
                let fullyVisibleAboveTabBar = element.frame.minY >= scrollView.frame.minY
                    && element.frame.maxY <= tabBar.frame.minY
                if fullyVisibleAboveTabBar { break }
                nudgeScroll(
                    scrollView,
                    upward: element.frame.minY >= scrollView.frame.minY
                )
            }

            XCTAssertGreaterThanOrEqual(
                element.frame.minY,
                scrollView.frame.minY,
                "\(name) starts above the visible scroll viewport: "
                    + "elementFrame=" + String(describing: element.frame)
                    + " scrollFrame=" + String(describing: scrollView.frame)
                    + " tabBarFrame=" + String(describing: tabBar.frame)
            )
            XCTAssertLessThanOrEqual(
                element.frame.maxY,
                tabBar.frame.minY,
                "\(name) remains under the native tab bar after settling: "
                    + "elementFrame=" + String(describing: element.frame)
                    + " tabBarFrame=" + String(describing: tabBar.frame)
            )
        }
    }

    func testSettingsSupportSectionCanSettleAboveFloatingTabBar() {
        let app = launchFixture(screen: "ready")
        let settingsTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let supportSection = app.descendants(matching: .any)["SCR-SET-01-SupportSection"]
        let tabBar = app.tabBars.firstMatch
        // Compact List layouts may virtualize lower section headers until the
        // first scroll. Materialize the target before asserting its final
        // relationship to the native tab bar.
        for _ in 0..<4 where !supportSection.exists {
            app.swipeUp()
            Thread.sleep(forTimeInterval: 0.15)
        }
        XCTAssertTrue(supportSection.waitForExistence(timeout: 5))
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        XCTAssertFalse(
            supportSection.isHittable && supportSection.frame.intersects(tabBar.frame),
            "The Settings support section must not be tappable under the floating tab bar. "
                + "elementFrame=" + String(describing: supportSection.frame)
                + " tabBarFrame=" + String(describing: tabBar.frame)
        )

        for _ in 0..<12 {
            if supportSection.isHittable && supportSection.frame.maxY <= tabBar.frame.minY {
                break
            }
            app.swipeUp()
            Thread.sleep(forTimeInterval: 0.15)
        }

        XCTAssertTrue(supportSection.isHittable)
        XCTAssertLessThanOrEqual(supportSection.frame.maxY, tabBar.frame.minY)
    }

    func testSavedFixtureReachesShellWithThreeDistinctLocalizedTabs() {
        let app = launchFixture()
        let primary = app.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        primary.tap()

        let save = app.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 10))
        scrollToSave(in: app, lastPhotoIndex: 6, assertWideHero: true)
        save.tap()

        let done = app.buttons["SCR-WK-05-Done"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        scrollToVisible(done, in: app)
        done.tap()

        let tabIdentifiers = ["TAB-WEEK", "TAB-ARCHIVE", "TAB-SETTINGS"]
        for identifier in tabIdentifiers {
            XCTAssertEqual(
                app.descendants(matching: .any).matching(identifier: identifier).count,
                1,
                "Missing localized tab identifier \(identifier)"
            )
        }
    }

    func testCaptureDeterministicFixtureMilestonesWhenRequested() {
        guard ProcessInfo.processInfo.environment["WK_CAPTURE_SCREENSHOTS"] == "1" else { return }

        let app = launchFixture()
        let primary = app.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        captureScreenshot(named: "01-welcome")

        primary.tap()
        let save = app.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 10))
        let hero = app.buttons["CMP-05-PhotoTile-0"]
        XCTAssertTrue(hero.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(hero.frame.width, hero.frame.height * 1.4)
        captureScreenshot(named: "02-review")

        let firstPhoto = app.buttons["CMP-05-PhotoTile-0"]
        XCTAssertTrue(firstPhoto.exists)
        firstPhoto.tap()
        XCTAssertTrue(app.buttons["SCR-WK-03-ReplaceSelected"].waitForExistence(timeout: 3))
        captureScreenshot(named: "03-review-selected")

        scrollToSave(in: app, lastPhotoIndex: 6)
        save.tap()
        XCTAssertTrue(app.staticTexts["SCR-WK-05-Title"].waitForExistence(timeout: 5))
        captureScreenshot(named: "04-save-confirmation")
    }

    /// Build-7 Shipaton evidence uses the real in-app share preview as its
    /// fourth frame. This remains opt-in and fixture-only: it never opens the
    /// Apple share sheet and never exercises PhotoKit or private pixels.
    func testCaptureBuild7ShipatonSubmissionScreenshotsWhenRequested() throws {
        let captureEnvironment = ProcessInfo.processInfo.environment
        let captureRequested = captureEnvironment["WK_CAPTURE_BUILD7_SHIPATON_SCREENSHOTS"] == "1"
            || captureEnvironment["TEST_RUNNER_WK_CAPTURE_BUILD7_SHIPATON_SCREENSHOTS"] == "1"
        guard captureRequested else {
            throw XCTSkip("Build-7 Shipaton screenshot capture is opt-in.")
        }

        let rawLocale = captureEnvironment["WK_BUILD7_SHIPATON_LOCALE"]
            ?? captureEnvironment["TEST_RUNNER_WK_BUILD7_SHIPATON_LOCALE"]
            ?? "en"
        let language: String
        switch rawLocale.lowercased() {
        case "en", "en-us", "en_us":
            language = "en"
        case "ko", "ko-kr", "ko_kr":
            language = "ko"
        default:
            XCTFail("Unsupported build-7 screenshot locale: \(rawLocale). Use en or ko.")
            return
        }

        // `launchFixture` explicitly sets the sentinel screen so this
        // narrative cannot inherit an ambient WK_UI_FIXTURE_SCREEN value.
        let app = launchFixture(language: language, screen: "onboarding")
        let welcomePrimary = app.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(welcomePrimary.waitForExistence(timeout: 8))
        XCTAssertFalse(app.buttons["SCR-WK-01-Start"].exists)
        captureScreenshot(named: "01-welcome", from: app)
        waitForBuild7SimulatorCapture(named: "01-welcome")

        welcomePrimary.tap()
        // The build-7 narrative intentionally captures the settled Weekly
        // Review surface. The fixture's foreground progress phase is
        // cancellable and time-bounded, so it is covered by the legacy
        // milestone contract rather than used as a prerequisite here.
        let save = app.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 15))
        XCTAssertTrue(app.staticTexts["SCR-WK-03-Title"].waitForExistence(timeout: 5))
        let hero = app.buttons["CMP-05-PhotoTile-0"]
        XCTAssertTrue(hero.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(hero.frame.width, hero.frame.height * 1.4)
        XCTAssertFalse(app.otherElements["SHEET-SHARE-01-Loading"].exists)
        captureScreenshot(named: "02-review", from: app)
        waitForBuild7SimulatorCapture(named: "02-review")

        scrollToSave(in: app, lastPhotoIndex: 6)
        XCTAssertTrue(save.isHittable)
        save.tap()

        let savedTitle = app.staticTexts["SCR-WK-05-Title"]
        XCTAssertTrue(savedTitle.waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["SCR-WK-05-Share"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["CMP-05-PhotoTile-6"].waitForExistence(timeout: 5))
        scrollToTop(in: app)
        captureScreenshot(named: "03-save-confirmation", from: app)
        waitForBuild7SimulatorCapture(named: "03-save-confirmation")

        app.buttons["SCR-WK-05-Share"].tap()
        XCTAssertTrue(app.staticTexts["SHEET-SHARE-01-Title"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["SHEET-SHARE-01-FormatPicker"].waitForExistence(timeout: 5))
        let preview = app.descendants(matching: .any)["SHEET-SHARE-01-Preview"]
        XCTAssertTrue(preview.waitForExistence(timeout: 20))
        XCTAssertFalse(app.otherElements["SHEET-SHARE-01-Loading"].exists)

        // Keep the generated Story preview and its action in the visible
        // frame, but do not tap the native-share action.
        let shareScroll = app.scrollViews.firstMatch
        XCTAssertTrue(shareScroll.waitForExistence(timeout: 5))
        for _ in 0..<4 {
            let shareButton = app.buttons["SHEET-SHARE-01-Share"]
            if preview.isHittable && shareButton.isHittable {
                break
            }
            shareScroll.swipeUp()
            Thread.sleep(forTimeInterval: 0.15)
        }
        XCTAssertTrue(preview.isHittable)
        XCTAssertTrue(app.buttons["SHEET-SHARE-01-Share"].isHittable)
        captureScreenshot(named: "04-share-preview", from: app)
        waitForBuild7SimulatorCapture(named: "04-share-preview")
    }

    func testCapturePhotoStoryVisualQAWhenRequested() {
        guard ProcessInfo.processInfo.environment["WK_CAPTURE_VISUAL_QA"] == "1" else { return }

        let onboarding = launchFixture()
        let primary = onboarding.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        captureScreenshot(named: "rerun8-onboarding-top")

        let onboardingScroll = onboarding.scrollViews.firstMatch
        XCTAssertTrue(onboardingScroll.waitForExistence(timeout: 5))
        for _ in 0..<10 {
            if primary.isHittable { break }
            onboardingScroll.swipeUp()
            Thread.sleep(forTimeInterval: 0.1)
        }
        XCTAssertTrue(primary.isHittable)
        captureScreenshot(named: "rerun8-onboarding-bottom")
        captureScreenshot(named: "rerun8-onboarding-bottom-raw-proof")
        onboarding.terminate()

        let ready = launchFixture(screen: "ready")
        let readyCTA = ready.buttons["SCR-WK-01-Start"]
        XCTAssertTrue(readyCTA.waitForExistence(timeout: 8))
        captureScreenshot(named: "rerun8-ready")

        let settingsTab = ready.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        let openPlus = ready.buttons["SHEET-PAY-01-Open"]
        XCTAssertTrue(openPlus.waitForExistence(timeout: 5))
        openPlus.tap()
        XCTAssertTrue(ready.staticTexts["SHEET-PAY-01-Title"].waitForExistence(timeout: 8))
        XCTAssertTrue(ready.descendants(matching: .any)["SHEET-PAY-01-Price"].waitForExistence(timeout: 8))
        captureScreenshot(named: "rerun8-plus-full-screen")
    }

    func testCaptureBuild6NotificationSettingsWhenRequested() {
        guard ProcessInfo.processInfo.environment["WK_CAPTURE_BUILD6_NOTIFICATION_SETTINGS"] == "1" else { return }

        let locale = ProcessInfo.processInfo.environment["WK_BUILD6_NOTIFICATION_SETTINGS_LOCALE"] ?? "en-US"
        XCTAssertTrue(["en-US", "ko"].contains(locale), "Unsupported build 6 evidence locale: \(locale)")
        let language = locale == "ko" ? "ko" : "en"

        let empty = launchFixture(language: language, screen: "ready-empty")
        let emptySettingsTab = empty.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(emptySettingsTab.waitForExistence(timeout: 5))
        emptySettingsTab.tap()
        XCTAssertTrue(empty.descendants(matching: .any)["SCR-SET-01-NotificationStatus"].waitForExistence(timeout: 5))
        XCTAssertTrue(empty.staticTexts["SCR-SET-01-NotificationGate"].waitForExistence(timeout: 5))
        XCTAssertFalse(empty.buttons["SCR-SET-01-NotificationAction"].exists)
        XCTAssertFalse(empty.buttons["SCR-SET-01-NotificationStatus"].exists)
        captureScreenshot(named: "\(locale)-settings-zero-saved")
        empty.terminate()

        let saved = launchFixture(language: language, screen: "ready")
        let savedSettingsTab = saved.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(savedSettingsTab.waitForExistence(timeout: 5))
        savedSettingsTab.tap()
        XCTAssertTrue(saved.buttons["SCR-SET-01-NotificationStatus"].waitForExistence(timeout: 5))
        XCTAssertFalse(saved.buttons["SCR-SET-01-NotificationAction"].exists)
        XCTAssertFalse(saved.staticTexts["SCR-SET-01-NotificationGate"].exists)
        captureScreenshot(named: "\(locale)-settings-saved")
    }

    func testCaptureKoreanCopySurfaceScreenshotsWhenRequested() {
        guard ProcessInfo.processInfo.environment["WK_CAPTURE_KOREAN_COPY_SURFACES"] == "1" else { return }

        let welcome = launchFixture(language: "ko")
        XCTAssertTrue(welcome.buttons["SCR-ONB-01-Primary"].waitForExistence(timeout: 5))
        captureScreenshot(named: "ko-01-welcome")
        welcome.terminate()

        let weekly = launchFixture(language: "ko", screen: "ready", paceCuration: true)
        let start = weekly.buttons["SCR-WK-01-Start"]
        XCTAssertTrue(start.waitForExistence(timeout: 8))
        captureScreenshot(named: "ko-02-ready")

        start.tap()
        XCTAssertTrue(weekly.staticTexts["SCR-WK-02-CurationProgress"].waitForExistence(timeout: 10))
        captureScreenshot(named: "ko-03-progress")

        let save = weekly.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 15))
        XCTAssertTrue(weekly.staticTexts["SCR-WK-03-Title"].waitForExistence(timeout: 5))
        captureScreenshot(named: "ko-04-review")

        scrollToSave(in: weekly, lastPhotoIndex: 6)
        save.tap()
        XCTAssertTrue(weekly.staticTexts["SCR-WK-05-Title"].waitForExistence(timeout: 8))
        captureScreenshot(named: "ko-05-save")

        let share = weekly.buttons["SCR-WK-05-Share"]
        XCTAssertTrue(share.waitForExistence(timeout: 5))
        share.tap()
        XCTAssertTrue(weekly.staticTexts["SHEET-SHARE-01-Title"].waitForExistence(timeout: 5))
        let sharePreview = weekly.descendants(matching: .any)["SHEET-SHARE-01-Preview"]
        XCTAssertTrue(sharePreview.waitForExistence(timeout: 15))
        captureScreenshot(named: "ko-06-share")
        weekly.terminate()

        let settings = launchFixture(language: "ko", screen: "ready")
        let settingsTab = settings.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        XCTAssertTrue(settings.descendants(matching: .any)["SCR-SET-01-SupportSection"].waitForExistence(timeout: 8))
        captureScreenshot(named: "ko-07-settings")
    }

    func testUnderSevenFixtureShowsOnlyTheRealPhotoCount() {
        for photoCount in [1, 6] {
            let app = launchFixture(photoCount: photoCount)
            let primary = app.buttons["SCR-ONB-01-Primary"]
            XCTAssertTrue(primary.waitForExistence(timeout: 5))
            primary.tap()

            let save = app.buttons["SCR-WK-03-Save"]
            XCTAssertTrue(save.waitForExistence(timeout: 10))
            XCTAssertTrue(app.buttons["CMP-05-PhotoTile-0"].exists)
            XCTAssertTrue(app.buttons["CMP-05-PhotoTile-\(photoCount - 1)"].exists)
            XCTAssertFalse(app.buttons["CMP-05-PhotoTile-\(photoCount)"].exists)

            scrollToSave(in: app, lastPhotoIndex: photoCount - 1)
            save.tap()
            XCTAssertTrue(app.staticTexts["SCR-WK-05-Title"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.buttons["CMP-05-PhotoTile-0"].waitForExistence(timeout: 3))
            XCTAssertTrue(app.buttons["CMP-05-PhotoTile-\(photoCount - 1)"].exists)
            XCTAssertFalse(app.buttons["CMP-05-PhotoTile-\(photoCount)"].exists)
            app.terminate()
        }
    }

    func testZeroPhotoFixtureShowsHonestEmptyState() {
        let app = launchFixture(photoCount: 0)
        let primary = app.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        primary.tap()

        XCTAssertTrue(app.staticTexts["SCR-WK-01-NoPhotosTitle"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["SCR-WK-03-Save"].exists)
    }

    func testEnglishPhotoAccessibilityReadsIndexBeforeTotal() {
        let app = launchFixture(language: "en")
        let primary = app.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        primary.tap()

        let firstPhoto = app.buttons["CMP-05-PhotoTile-0"]
        XCTAssertTrue(firstPhoto.waitForExistence(timeout: 10))
        XCTAssertEqual(firstPhoto.label, "Photo 1 of 7")
    }

    private func launchFixture(
        skipNotificationPrimer: Bool = true,
        photoCount: Int? = nil,
        language: String? = nil,
        screen: String? = nil,
        paceCuration: Bool = false
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-fixtures"]
        if skipNotificationPrimer {
            app.launchArguments.append("-ui-fixtures-skip-notification")
        }
        app.launchEnvironment = ["WK_UI_TEST_FIXTURES": "1"]
        if let photoCount {
            app.launchEnvironment["WK_UI_FIXTURE_PHOTO_COUNT"] = String(photoCount)
        }
        if let screen {
            app.launchEnvironment["WK_UI_FIXTURE_SCREEN"] = screen
        } else {
            // Never inherit a screen selector from the xcodebuild shell or a
            // previous fixture capture. The unconfigured fixture launch is
            // always the real onboarding surface.
            app.launchEnvironment["WK_UI_FIXTURE_SCREEN"] = "onboarding"
        }
        if let language {
            app.launchArguments.append(contentsOf: [
                "-AppleLanguages", "(\(language))",
                "-AppleLocale", language == "en" ? "en_US" : "ko_KR",
            ])
        }
        if paceCuration {
            app.launchEnvironment["WK_CAPTURE_REMOTION_FOOTAGE"] = "1"
        }
        app.launch()
        return app
    }

    private func scrollToSave(in app: XCUIApplication, lastPhotoIndex: Int, assertWideHero: Bool = false) {
        let hero = app.buttons["CMP-05-PhotoTile-0"]
        XCTAssertTrue(hero.waitForExistence(timeout: 5))
        if assertWideHero {
            XCTAssertGreaterThan(hero.frame.width, hero.frame.height * 1.4)
        }

        let scrollView = app.scrollViews.firstMatch
        let lastPhoto = app.buttons["CMP-05-PhotoTile-\(lastPhotoIndex)"]
        let privacy = app.staticTexts["CMP-03-PrivacyBadge"]
        let save = app.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        XCTAssertTrue(lastPhoto.waitForExistence(timeout: 5))
        XCTAssertTrue(privacy.waitForExistence(timeout: 5))

        for _ in 0..<12 {
            let completeBottomState = lastPhoto.isHittable && privacy.isHittable && save.isHittable
                && lastPhoto.frame.maxY <= scrollView.frame.maxY
                && privacy.frame.minY >= lastPhoto.frame.maxY
                && save.frame.minY >= privacy.frame.maxY
                && save.frame.maxY <= scrollView.frame.maxY
            if completeBottomState { break }
            scrollView.swipeUp()
            Thread.sleep(forTimeInterval: 0.15)
        }

        XCTAssertTrue(lastPhoto.isHittable)
        XCTAssertTrue(privacy.isHittable)
        XCTAssertTrue(save.isHittable)
        XCTAssertLessThanOrEqual(lastPhoto.frame.maxY, scrollView.frame.maxY)
        XCTAssertGreaterThanOrEqual(privacy.frame.minY, lastPhoto.frame.maxY)
        XCTAssertGreaterThanOrEqual(save.frame.minY, privacy.frame.maxY)
        XCTAssertLessThanOrEqual(save.frame.maxY, scrollView.frame.maxY)
        XCTAssertGreaterThan(save.frame.minY, lastPhoto.frame.maxY)
    }

    private func scrollToVisible(_ element: XCUIElement, in app: XCUIApplication) {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 3))
        for _ in 0..<8 {
            if element.isHittable { break }
            scrollView.swipeUp()
            Thread.sleep(forTimeInterval: 0.15)
        }
        XCTAssertTrue(element.isHittable)
    }

    private func waitForNativeShareAccessibilityPresentation(
        in app: XCUIApplication,
        existingAppSheetCount: Int,
        timeout: TimeInterval
    ) -> Bool {
        let activityApplication = XCUIApplication(bundleIdentifier: "com.apple.UIKit.activity")
        let springBoard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let candidates = [
            app.sheets.element(boundBy: existingAppSheetCount),
            app.descendants(matching: .any)
                .matching(identifier: "UIActivityContentView")
                .firstMatch,
            activityApplication.sheets.firstMatch,
            springBoard.sheets.firstMatch,
        ]
        let deadline = Date().addingTimeInterval(timeout)

        repeat {
            if candidates.contains(where: { $0.exists && $0.frame.width > 0 && $0.frame.height > 0 }) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        } while Date() < deadline

        return candidates.contains(where: { $0.exists && $0.frame.width > 0 && $0.frame.height > 0 })
    }

    private func nudgeScroll(_ scrollView: XCUIElement, upward: Bool) {
        let startY: CGFloat = upward ? 0.72 : 0.28
        let endY: CGFloat = upward ? 0.62 : 0.38
        let start = scrollView.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: startY)
        )
        let end = scrollView.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: endY)
        )
        start.press(forDuration: 0.05, thenDragTo: end)
        Thread.sleep(forTimeInterval: 0.15)
    }

    private func scrollToTop(in app: XCUIApplication) {
        let scrollView = app.scrollViews.firstMatch
        guard scrollView.waitForExistence(timeout: 5) else { return }
        for _ in 0..<3 {
            scrollView.swipeDown()
            Thread.sleep(forTimeInterval: 0.15)
        }
    }

    private func captureScreenshot(named name: String, from app: XCUIApplication? = nil) {
        let screenshot = app?.screenshot() ?? XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func waitForBuild7SimulatorCapture(named name: String) {
        let environment = ProcessInfo.processInfo.environment
        guard let markerDirectory = environment["WK_BUILD7_SIM_CAPTURE_MARKER_DIR"]
            ?? environment["TEST_RUNNER_WK_BUILD7_SIM_CAPTURE_MARKER_DIR"] else {
            return
        }

        let directory = URL(fileURLWithPath: markerDirectory, isDirectory: true)
        let ready = directory.appendingPathComponent("\(name).ready")
        let complete = directory.appendingPathComponent("\(name).done")
        do {
            try Data(name.utf8).write(to: ready, options: .atomic)
        } catch {
            XCTFail("Unable to publish build-7 simulator capture marker for \(name): \(error)")
            return
        }

        let deadline = Date().addingTimeInterval(30)
        while !FileManager.default.fileExists(atPath: complete.path), Date() < deadline {
            Thread.sleep(forTimeInterval: 0.05)
        }
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: complete.path),
            "The capture script did not acknowledge the exact simulator frame for \(name)."
        )
    }
}

@MainActor
private struct FixtureScreenshotSampler {
    private let bytes: [UInt8]
    private let width: Int
    private let height: Int
    private let bytesPerRow: Int

    init?(screenshot: XCUIScreenshot) {
        guard let source = screenshot.image.cgImage else { return nil }

        let width = source.width
        let height = source.height
        let bytesPerRow = width * 4
        var buffer = [UInt8](repeating: 0, count: height * bytesPerRow)

        guard let context = CGContext(
            data: &buffer,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.interpolationQuality = .none
        context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))

        self.bytes = buffer
        self.width = width
        self.height = height
        self.bytesPerRow = bytesPerRow
    }

    func coverage(
        of frame: CGRect,
        in windowFrame: CGRect,
        matching predicate: (UInt8, UInt8, UInt8) -> Bool
    ) -> Double {
        guard windowFrame.width > 0, windowFrame.height > 0 else { return 0 }

        let scaleX = CGFloat(width) / windowFrame.width
        let scaleY = CGFloat(height) / windowFrame.height
        let minX = max(0, min(width, Int(floor((frame.minX - windowFrame.minX) * scaleX))))
        let maxX = max(0, min(width, Int(ceil((frame.maxX - windowFrame.minX) * scaleX))))
        let minY = max(0, min(height, Int(floor((frame.minY - windowFrame.minY) * scaleY))))
        let maxY = max(0, min(height, Int(ceil((frame.maxY - windowFrame.minY) * scaleY))))

        guard maxX > minX, maxY > minY else { return 0 }

        var matchingPixels = 0
        var totalPixels = 0
        for screenY in minY..<maxY {
            // The normalized screenshot buffer and XCTest frames both use a
            // top-origin coordinate system after CGContext draws the source.
            let bitmapY = screenY
            for x in minX..<maxX {
                let offset = bitmapY * bytesPerRow + x * 4
                if predicate(bytes[offset], bytes[offset + 1], bytes[offset + 2]) {
                    matchingPixels += 1
                }
                totalPixels += 1
            }
        }

        return totalPixels > 0 ? Double(matchingPixels) / Double(totalPixels) : 0
    }
}
