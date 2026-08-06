import XCTest

/// Opt-in footage path for the Remotion Shipaton video. It launches the
/// deterministic `-ui-fixtures` environment backed by bundled
/// `SamplePhotoFixtures`; this footage is UI evidence and does not exercise
/// PhotoKit. The test is skipped in ordinary UI runs so normal regression
/// tests do not launch the app or wait on footage pacing.
@MainActor
final class RemotionFootageCaptureTests: XCTestCase {
    func testCaptureRemotionFootage() throws {
        guard ProcessInfo.processInfo.environment["WK_CAPTURE_REMOTION_FOOTAGE"] == "1" else {
            throw XCTSkip("Remotion footage capture is opt-in.")
        }

        let app = launchFixture()

        let primary = app.buttons["SCR-ONB-01-Primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 5))
        hold(0.75)
        primary.tap()

        let progressTitle = app.staticTexts["SCR-WK-02-CurationProgress"]
        XCTAssertTrue(progressTitle.waitForExistence(timeout: 5))
        // The DEBUG-only fixture pacing keeps this actual foreground screen
        // visible for about 1.5 seconds; this small hold lets it read clearly.
        hold(0.35)

        let reviewTitle = app.staticTexts["SCR-WK-03-Title"]
        let save = app.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 12))
        XCTAssertTrue(reviewTitle.waitForExistence(timeout: 5))
        hold(0.75)

        let firstPhoto = app.buttons["CMP-05-PhotoTile-0"]
        XCTAssertTrue(firstPhoto.waitForExistence(timeout: 5))
        XCTAssertTrue(firstPhoto.isHittable)
        firstPhoto.tap()

        let replaceSelected = app.buttons["SCR-WK-03-ReplaceSelected"]
        XCTAssertTrue(replaceSelected.waitForExistence(timeout: 3))
        hold(0.35)
        replaceSelected.tap()

        let sameDayHeading = app.staticTexts["SHEET-REP-01-SameDay"]
        XCTAssertTrue(sameDayHeading.waitForExistence(timeout: 5))
        let sameDayCandidate = app.buttons["SHEET-REP-01-Candidate-0"]
        XCTAssertTrue(sameDayCandidate.waitForExistence(timeout: 5))
        XCTAssertTrue(sameDayCandidate.isHittable)
        hold(0.45)
        sameDayCandidate.tap()

        XCTAssertTrue(waitUntilGone(sameDayHeading, timeout: 5))
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        hold(0.55)
        scrollToSave(in: app, lastPhotoIndex: 6)
        save.tap()

        let savedTitle = app.staticTexts["SCR-WK-05-Title"]
        XCTAssertTrue(savedTitle.waitForExistence(timeout: 8))
        hold(0.85)

        let sharePreviewButton = app.buttons["SCR-WK-05-Share"]
        XCTAssertTrue(sharePreviewButton.waitForExistence(timeout: 5))
        sharePreviewButton.tap()

        let shareTitle = app.staticTexts["SHEET-SHARE-01-Title"]
        XCTAssertTrue(shareTitle.waitForExistence(timeout: 5))
        let preview = app.descendants(matching: .any)
            .matching(identifier: "SHEET-SHARE-01-Preview")
            .firstMatch
        XCTAssertTrue(preview.waitForExistence(timeout: 15))
        let nativeShareButton = app.buttons["SHEET-SHARE-01-Share"]
        XCTAssertTrue(nativeShareButton.waitForExistence(timeout: 5))
        // The English submission edit stops on the real share artifact. The
        // system activity controller follows the Simulator's Korean OS locale
        // and is already covered by separate native-share QA evidence.
        hold(1.25)

        let closeSharePreview = app.buttons["SHEET-SHARE-01-Close"]
        XCTAssertTrue(waitUntilHittable(closeSharePreview, timeout: 8))
        closeSharePreview.tap()
        XCTAssertTrue(savedTitle.waitForExistence(timeout: 6))

        let viewRecord = app.buttons["SCR-WK-05-View"]
        XCTAssertTrue(waitUntilHittable(viewRecord, timeout: 6))
        hold(0.45)
        viewRecord.tap()

        let archiveRow = app.descendants(matching: .any)
            .matching(identifier: "SCR-ARC-01-WeekRow")
            .firstMatch
        XCTAssertTrue(archiveRow.waitForExistence(timeout: 10))
        hold(0.9)
        archiveRow.tap()

        let archiveShare = app.buttons["SCR-ARC-02-Share"]
        XCTAssertTrue(archiveShare.waitForExistence(timeout: 8))
        hold(0.9)

        let settingsTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        let openPlus = app.buttons["SHEET-PAY-01-Open"]
        XCTAssertTrue(openPlus.waitForExistence(timeout: 8))
        hold(0.9)
        openPlus.tap()

        let paywallTitle = app.staticTexts["SHEET-PAY-01-Title"]
        let paywallPrice = app.staticTexts["SHEET-PAY-01-Price"]
        XCTAssertTrue(paywallTitle.waitForExistence(timeout: 8))
        XCTAssertTrue(paywallPrice.waitForExistence(timeout: 8))
        hold(1.2)
    }

    private func launchFixture() -> XCUIApplication {
        let app = XCUIApplication()
        // Keep the footage source deterministic and independent of simulator
        // Photos ingestion; live PhotoKit behavior is validated separately.
        app.launchArguments = [
            "-ui-fixtures",
            "-ui-fixtures-skip-notification",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
        ]
        app.launchEnvironment = [
            "WK_UI_TEST_FIXTURES": "1",
            "WK_CAPTURE_REMOTION_FOOTAGE": "1",
        ]
        app.launch()
        return app
    }

    private func hold(_ duration: TimeInterval) {
        Thread.sleep(forTimeInterval: duration)
    }

    private func waitUntilGone(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if !element.exists { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return !element.exists
    }

    private func waitUntilHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if element.exists && element.isHittable { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return element.exists && element.isHittable
    }

    private func scrollToSave(in app: XCUIApplication, lastPhotoIndex: Int) {
        let scrollView = app.scrollViews.firstMatch
        let lastPhoto = app.buttons["CMP-05-PhotoTile-\(lastPhotoIndex)"]
        let save = app.buttons["SCR-WK-03-Save"]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        XCTAssertTrue(lastPhoto.waitForExistence(timeout: 5))

        for _ in 0..<12 {
            if save.isHittable && lastPhoto.isHittable { break }
            scrollView.swipeUp()
            hold(0.15)
        }

        XCTAssertTrue(lastPhoto.isHittable)
        XCTAssertTrue(save.isHittable)
        XCTAssertGreaterThan(save.frame.minY, lastPhoto.frame.maxY)
    }

}
