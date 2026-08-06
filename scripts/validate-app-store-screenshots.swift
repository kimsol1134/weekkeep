import CoreGraphics
import CryptoKit
import Foundation
import ImageIO
import UniformTypeIdentifiers

@main
struct ValidateAppStoreScreenshots {
  private static let width = 1320
  private static let height = 2868
  private static let deviceID = "9C794F17-634B-4B7A-86A9-AEE88EE575FF"
  private static let deviceName = "Weekkeep AppStore 6.9"
  private static let locales = ["en-US", "ko"]
  private static let slugs = [
    "01-welcome",
    "02-curation-progress",
    "03-review",
    "04-replace",
    "05-saved-weeks",
    "06-plus",
  ]
  private static let headlines: [String: [String]] = [
    "en-US": [
      "Your week, already waiting.",
      "Private from the first tap.",
      "Seven moments. Nothing to sort.",
      "Change one. Keep the feeling.",
      "A small album, every week.",
      "Two albums free. Then yours for life.",
    ],
    "ko": [
      "사진은 많고, 시간은 없으니까.",
      "첫 탭부터, 사진은 기기 안에서.",
      "일주일에 7장만.",
      "마음에 안 드는 한 장만 바꾸세요.",
      "작은 한 주가 차곡차곡.",
      "두 번 무료, 그다음은 평생 이용권.",
    ],
  ]

  static func main() throws {
    let arguments = try Arguments(ProcessInfo.processInfo.arguments)
    let outputRoot = arguments.outputRoot.standardizedFileURL
    let repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .standardizedFileURL
    let manifestURL = outputRoot.appendingPathComponent("manifest.json")
    let manifest = try decodeManifest(manifestURL)

    guard manifest.schemaVersion == 1,
      manifest.set == "app-store-6.9",
      manifest.device.udid == deviceID,
      manifest.device.name == deviceName,
      manifest.device.os == "iOS 26.5",
      manifest.output.width == width,
      manifest.output.height == height,
      manifest.output.format == "jpeg",
      manifest.output.alpha == false,
      manifest.composition.background == "#FBF7F2",
      manifest.composition.headlineColor == "#5B415E",
      manifest.composition.borderColor == "#E8E1DB",
      manifest.composition.headlineFont == "LINESeedSansKR-Bold",
      manifest.composition.rawScreenshotWidth == 1050,
      manifest.composition.rawScreenshotCornerRadius == 44,
      manifest.composition.deviceFrame == false
    else {
      throw Failure("Manifest does not match the approved App Store composition contract")
    }

    try validateFixtureSources(
      manifest.fixtureSources, fixtureRoot: arguments.fixtureRoot, repoRoot: repoRoot)
    try validateReviewLayoutSource(repoRoot: repoRoot)
    try validateLocales(
      manifest.locales,
      outputRoot: outputRoot,
      rawRoot: arguments.rawRoot,
      repoRoot: repoRoot
    )

    let localeDirectories = try FileManager.default.contentsOfDirectory(
      at: outputRoot,
      includingPropertiesForKeys: [.isDirectoryKey],
      options: [.skipsHiddenFiles]
    ).filter { url in
      (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }.map(\.lastPathComponent).sorted()
    guard localeDirectories == locales.sorted() else {
      throw Failure("Expected exactly locale directories \(locales), found \(localeDirectories)")
    }

    print(
      "PASS: manifest, review spacing contract, exact locale/file sequence, fixture hashes, JPEG/no-alpha, and 1320x2868 dimensions"
    )
  }

  private static func decodeManifest(_ url: URL) throws -> Manifest {
    guard let data = try? Data(contentsOf: url) else {
      throw Failure("Missing manifest: \(url.path)")
    }
    do { return try JSONDecoder().decode(Manifest.self, from: data) } catch {
      throw Failure("Could not decode manifest: \(error)")
    }
  }

  private static func validateFixtureSources(
    _ sources: [FixtureRecord],
    fixtureRoot: URL,
    repoRoot: URL
  ) throws {
    let files = try FileManager.default.contentsOfDirectory(
      at: fixtureRoot,
      includingPropertiesForKeys: nil,
      options: [.skipsHiddenFiles]
    ).filter {
      $0.pathExtension.lowercased() == "png" && $0.lastPathComponent.first?.isNumber == true
    }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
    guard files.count == 7, sources.count == 7 else {
      throw Failure("Fixture source contract must contain exactly seven files")
    }
    for (file, source) in zip(files, sources) {
      let expectedPath = relativePath(file, from: repoRoot)
      guard source.filename == expectedPath,
        source.sha256 == sha256(file),
        source.sha256.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil
      else {
        throw Failure("Fixture source/hash mismatch: \(source.filename)")
      }
    }
  }

  private static func validateReviewLayoutSource(repoRoot: URL) throws {
    let sourceURL =
      repoRoot
      .appendingPathComponent("Weekkeep/Features/WeeklyCuration/ReviewViews.swift")
    guard let source = try? String(contentsOf: sourceURL, encoding: .utf8) else {
      throw Failure("Missing Weekly Review source: \(sourceURL.path)")
    }

    let forbiddenScreenshotOverrides = [
      "-ui-app-store-fixtures",
      "reviewLayoutSpacing",
      "reviewTopPadding",
      "WeekkeepSpacing.one / 2",
      "geometry.safeAreaInsets",
    ]
    for marker in forbiddenScreenshotOverrides where source.contains(marker) {
      throw Failure("Weekly Review contains a screenshot-only layout override: \(marker)")
    }

    let requiredSemanticSpacing = [
      "enum WeeklyReviewSpacing",
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
    ]
    for marker in requiredSemanticSpacing where !source.contains(marker) {
      throw Failure("Weekly Review is missing semantic spacing contract: \(marker)")
    }
  }

  private static func validateLocales(
    _ records: [LocaleRecord],
    outputRoot: URL,
    rawRoot: URL?,
    repoRoot: URL
  ) throws {
    guard records.map(\.locale).sorted() == locales.sorted() else {
      throw Failure("Manifest locale set must be exactly en-US and ko")
    }
    if let rawRoot {
      for locale in locales {
        let topURL = rawRoot.appendingPathComponent(locale).appendingPathComponent("03-review.png")
        let bottomURL = rawRoot.appendingPathComponent(locale).appendingPathComponent(
          "03-review-bottom.png")
        guard FileManager.default.fileExists(atPath: bottomURL.path) else {
          throw Failure("Missing raw lower-action review capture: \(bottomURL.path)")
        }
        try validateImage(bottomURL, expectedType: .png, expectedAlpha: false)
        guard sha256(topURL) != sha256(bottomURL) else {
          throw Failure("Review top and lower-action captures alias each other: \(locale)")
        }
      }
    }
    for locale in locales {
      guard let record = records.first(where: { $0.locale == locale }),
        let expectedHeadlines = headlines[locale],
        record.screenshots.count == 6
      else { throw Failure("Manifest is missing six screenshots for \(locale)") }

      let localeRoot = outputRoot.appendingPathComponent(locale)
      let imageFiles = try FileManager.default.contentsOfDirectory(
        at: localeRoot,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
      ).filter { ["jpg", "jpeg", "png"].contains($0.pathExtension.lowercased()) }
      guard imageFiles.count == 6 else {
        throw Failure("\(locale) must contain exactly six image files; found \(imageFiles.count)")
      }

      for index in 0..<6 {
        let screenshot = record.screenshots[index]
        let slug = slugs[index]
        let expectedSource =
          rawRoot.map {
            relativePath(
              $0.appendingPathComponent(locale).appendingPathComponent("\(slug).png"),
              from: repoRoot
            )
          } ?? screenshot.source
        guard screenshot.sequence == index + 1,
          screenshot.semantic == semantic(for: slug),
          screenshot.filename == "\(slug).jpg",
          screenshot.headline == expectedHeadlines[index],
          screenshot.source == expectedSource,
          screenshot.sourceSHA256.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil,
          screenshot.finalSHA256.range(of: "^[0-9a-f]{64}$", options: .regularExpression) != nil
        else { throw Failure("Headline/sequence/source contract mismatch for \(locale)/\(slug)") }

        let finalURL = localeRoot.appendingPathComponent(screenshot.filename)
        guard FileManager.default.fileExists(atPath: finalURL.path) else {
          throw Failure("Missing final screenshot: \(finalURL.path)")
        }
        try validateImage(finalURL, expectedType: .jpeg, expectedAlpha: false)
        guard sha256(finalURL) == screenshot.finalSHA256 else {
          throw Failure("Final screenshot hash mismatch: \(finalURL.path)")
        }

        if let rawRoot {
          let rawURL = rawRoot.appendingPathComponent(locale).appendingPathComponent("\(slug).png")
          guard FileManager.default.fileExists(atPath: rawURL.path) else {
            throw Failure("Missing raw source for \(locale)/\(slug): \(rawURL.path)")
          }
          try validateImage(rawURL, expectedType: .png, expectedAlpha: false)
          guard imageSize(rawURL) == CGSize(width: width, height: height),
            sha256(rawURL) == screenshot.sourceSHA256
          else { throw Failure("Raw source hash/dimension mismatch: \(rawURL.path)") }
        }
      }
    }
  }

  private static func validateImage(_ url: URL, expectedType: UTType, expectedAlpha: Bool) throws {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let type = CGImageSourceGetType(source),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else { throw Failure("Could not decode image: \(url.path)") }
    guard type == expectedType.identifier as CFString else {
      throw Failure("\(url.lastPathComponent) is not \(expectedType.identifier)")
    }
    guard image.width == width, image.height == height else {
      throw Failure(
        "\(url.lastPathComponent) is \(image.width)x\(image.height), expected \(width)x\(height)")
    }
    let hasAlpha: Bool
    switch image.alphaInfo {
    case .none, .noneSkipFirst, .noneSkipLast:
      hasAlpha = false
    default:
      hasAlpha = true
    }
    guard hasAlpha == expectedAlpha else {
      throw Failure("\(url.lastPathComponent) alpha mismatch")
    }
  }

  private static func imageSize(_ url: URL) -> CGSize {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else { return .zero }
    return CGSize(width: image.width, height: image.height)
  }

  private static func semantic(for slug: String) -> String {
    switch slug {
    case "01-welcome": "welcome"
    case "02-curation-progress": "curation_progress"
    case "03-review": "review"
    case "04-replace": "replace"
    case "05-saved-weeks": "saved_weeks"
    case "06-plus": "plus"
    default: slug
    }
  }

  private static func sha256(_ url: URL) -> String {
    let data = (try? Data(contentsOf: url)) ?? Data()
    return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
  }

  private static func relativePath(_ url: URL, from root: URL) -> String {
    let prefix = root.path.hasSuffix("/") ? root.path : root.path + "/"
    return url.standardizedFileURL.path.replacingOccurrences(of: prefix, with: "")
  }

  private struct Arguments {
    let outputRoot: URL
    let rawRoot: URL?
    let fixtureRoot: URL

    init(_ arguments: [String]) throws {
      var values: [String: String] = [:]
      var index = 1
      while index < arguments.count {
        guard index + 1 < arguments.count else {
          throw Failure("Missing value for \(arguments[index])")
        }
        values[arguments[index]] = arguments[index + 1]
        index += 2
      }
      guard let output = values["--output-root"],
        let fixture = values["--fixture-root"]
      else { throw Failure("Usage: --output-root PATH [--raw-root PATH] --fixture-root PATH") }
      outputRoot = URL(fileURLWithPath: output, isDirectory: true)
      rawRoot = values["--raw-root"].map { URL(fileURLWithPath: $0, isDirectory: true) }
      fixtureRoot = URL(fileURLWithPath: fixture, isDirectory: true)
    }
  }

  private struct Manifest: Codable {
    let schemaVersion: Int
    let set: String
    let device: DeviceRecord
    let output: OutputRecord
    let composition: CompositionRecord
    let fixtureSources: [FixtureRecord]
    let locales: [LocaleRecord]

    enum CodingKeys: String, CodingKey {
      case schemaVersion = "schema_version"
      case set, device, output, composition
      case fixtureSources = "fixture_sources"
      case locales
    }
  }

  private struct DeviceRecord: Codable {
    let name: String
    let udid: String
    let os: String
  }
  private struct OutputRecord: Codable {
    let width: Int
    let height: Int
    let format: String
    let alpha: Bool
  }
  private struct CompositionRecord: Codable {
    let background: String
    let headlineColor: String
    let borderColor: String
    let headlineFont: String
    let rawScreenshotWidth: Int
    let rawScreenshotCornerRadius: Int
    let deviceFrame: Bool

    enum CodingKeys: String, CodingKey {
      case background
      case headlineColor = "headline_color"
      case borderColor = "border_color"
      case headlineFont = "headline_font"
      case rawScreenshotWidth = "raw_screenshot_width"
      case rawScreenshotCornerRadius = "raw_screenshot_corner_radius"
      case deviceFrame = "device_frame"
    }
  }
  private struct FixtureRecord: Codable {
    let filename: String
    let sha256: String
  }
  private struct LocaleRecord: Codable {
    let locale: String
    let screenshots: [ScreenshotRecord]
  }
  private struct ScreenshotRecord: Codable {
    let sequence: Int
    let semantic: String
    let filename: String
    let headline: String
    let source: String
    let sourceSHA256: String
    let finalSHA256: String

    enum CodingKeys: String, CodingKey {
      case sequence, semantic, filename, headline, source
      case sourceSHA256 = "source_sha256"
      case finalSHA256 = "final_sha256"
    }
  }

  private struct Failure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
  }
}
