import XCTest

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
        XCTAssertEqual(firstPhoto.value as? String, "Selected for replacement")

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
            XCTAssertTrue(app.otherElements["SHEET-REP-01-Content"].exists)
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

    func testThisWeekInitialFrameKeepsLowerContentOutsideFloatingTabBar() {
        let app = launchFixture(screen: "ready")
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        for identifier in [
            "SCR-WK-01-PhotoCount",
            "CMP-03-PrivacyBadge",
            "SCR-WK-01-Start",
        ] {
            let element = app.descendants(matching: .any)[identifier]
            XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing \(identifier)")
            let message = identifier
                + " overlaps the floating tab bar before scrolling"
                + " elementFrame=" + String(describing: element.frame)
                + " tabBarFrame=" + String(describing: tabBar.frame)
                + " hittable=" + String(element.isHittable)
            XCTAssertFalse(
                element.frame.intersects(tabBar.frame) && element.isHittable,
                message
            )
        }
    }

    func testThisWeekFinalActionCanSettleAboveFloatingTabBar() {
        let app = launchFixture(screen: "ready")
        let start = app.buttons["SCR-WK-01-Start"]
        XCTAssertTrue(start.waitForExistence(timeout: 8))

        let scrollView = app.scrollViews.firstMatch
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        for _ in 0..<12 {
            if start.isHittable && start.frame.maxY <= tabBar.frame.minY {
                break
            }
            scrollView.swipeUp()
            Thread.sleep(forTimeInterval: 0.15)
        }

        XCTAssertTrue(start.isHittable)
        XCTAssertLessThanOrEqual(start.frame.maxY, tabBar.frame.minY)
    }

    func testSettingsFinalSectionCanSettleAboveFloatingTabBar() {
        let app = launchFixture(screen: "ready")
        let settingsTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let dataSection = app.descendants(matching: .any)["SCR-SET-01-DataSection"]
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(dataSection.waitForExistence(timeout: 5))
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        XCTAssertFalse(
            dataSection.isHittable && dataSection.frame.intersects(tabBar.frame),
            "The Settings data section must not be tappable under the floating tab bar. "
                + "elementFrame=" + String(describing: dataSection.frame)
                + " tabBarFrame=" + String(describing: tabBar.frame)
        )

        for _ in 0..<12 {
            if dataSection.isHittable && dataSection.frame.maxY <= tabBar.frame.minY {
                break
            }
            app.swipeUp()
            Thread.sleep(forTimeInterval: 0.15)
        }

        XCTAssertTrue(dataSection.isHittable)
        XCTAssertLessThanOrEqual(dataSection.frame.maxY, tabBar.frame.minY)
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
        XCTAssertTrue(empty.staticTexts["SCR-SET-01-NotificationGate"].waitForExistence(timeout: 5))
        XCTAssertFalse(empty.buttons["SCR-SET-01-NotificationAction"].exists)
        captureScreenshot(named: "\(locale)-settings-zero-saved")
        empty.terminate()

        let saved = launchFixture(language: language, screen: "ready")
        let savedSettingsTab = saved.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(savedSettingsTab.waitForExistence(timeout: 5))
        savedSettingsTab.tap()
        XCTAssertTrue(saved.buttons["SCR-SET-01-NotificationAction"].waitForExistence(timeout: 5))
        XCTAssertFalse(saved.staticTexts["SCR-SET-01-NotificationGate"].exists)
        captureScreenshot(named: "\(locale)-settings-saved")
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
        screen: String? = nil
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
        }
        if let language {
            app.launchArguments.append(contentsOf: [
                "-AppleLanguages", "(\(language))",
                "-AppleLocale", language == "en" ? "en_US" : "ko_KR",
            ])
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

    private func captureScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
