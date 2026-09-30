import CoreGraphics
import XCTest

@testable import Weekkeep

final class SystemSafeAreaResolverTests: XCTestCase {
  func testTopOcclusionUsesTheLargestAvailableSystemBoundary() {
    XCTAssertEqual(
      WeekkeepTopSystemOcclusion.height(windowSafeAreaTop: 62, localSafeAreaTop: 59),
      62,
      accuracy: 0.001
    )
    XCTAssertEqual(
      WeekkeepTopSystemOcclusion.height(windowSafeAreaTop: 0, localSafeAreaTop: 47),
      47,
      accuracy: 0.001
    )
    XCTAssertEqual(
      WeekkeepTopSystemOcclusion.height(windowSafeAreaTop: -1, localSafeAreaTop: -2),
      0,
      accuracy: 0.001
    )
  }

  func testRequiredRuntimeAndNormalizedPortraitFallbackCases() {
    let cases: [(String, CGFloat, CGFloat, CGSize, CGFloat)] = [
      ("runtime status 54 and inset 59", 54, 59, CGSize(width: 440, height: 956), 62),
      ("runtime status 20 and inset 20", 20, 20, CGSize(width: 440, height: 956), 28),
      ("runtime status 47 and inset 47", 47, 47, CGSize(width: 393, height: 852), 55),
      ("zero runtime 375x667", 0, 0, CGSize(width: 375, height: 667), 28),
      ("zero runtime 375x812", 0, 0, CGSize(width: 375, height: 812), 55),
      ("zero runtime 390x844", 0, 0, CGSize(width: 390, height: 844), 55),
      ("zero runtime 414x896", 0, 0, CGSize(width: 414, height: 896), 55),
      ("zero runtime 428x926", 0, 0, CGSize(width: 428, height: 926), 55),
      ("zero runtime 393x852", 0, 0, CGSize(width: 393, height: 852), 62),
      ("zero runtime 430x932", 0, 0, CGSize(width: 430, height: 932), 62),
      ("zero runtime 440x956", 0, 0, CGSize(width: 440, height: 956), 62),
    ]

    for (name, statusBarHeight, windowSafeAreaTop, screenSize, expected) in cases {
      XCTAssertEqual(
        WeekkeepSystemSafeAreaResolver.resolve(
          statusBarHeight: statusBarHeight,
          windowSafeAreaTop: windowSafeAreaTop,
          portraitScreenSize: screenSize
        ),
        expected,
        accuracy: 0.001,
        name
      )
    }
  }

  func testRuntimeValuesDoNotReceiveGeometryFallback() {
    XCTAssertEqual(
      WeekkeepSystemSafeAreaResolver.resolve(
        statusBarHeight: 0,
        windowSafeAreaTop: 20,
        portraitScreenSize: CGSize(width: 440, height: 956)
      ),
      20,
      accuracy: 0.001
    )
    XCTAssertEqual(
      WeekkeepSystemSafeAreaResolver.resolve(
        statusBarHeight: 20,
        windowSafeAreaTop: 0,
        portraitScreenSize: CGSize(width: 440, height: 956)
      ),
      28,
      accuracy: 0.001
    )
    XCTAssertEqual(
      WeekkeepSystemSafeAreaResolver.resolve(
        statusBarHeight: 20,
        windowSafeAreaTop: 20,
        portraitScreenSize: CGSize(width: 440, height: 956)
      ),
      28,
      accuracy: 0.001
    )
    XCTAssertEqual(
      WeekkeepSystemSafeAreaResolver.resolve(
        statusBarHeight: 47,
        windowSafeAreaTop: 47,
        portraitScreenSize: CGSize(width: 393, height: 852)
      ),
      55,
      accuracy: 0.001
    )
  }
}
