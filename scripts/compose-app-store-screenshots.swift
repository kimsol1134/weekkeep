import AppKit
import CoreGraphics
import CoreText
import CryptoKit
import Foundation
import ImageIO
import UniformTypeIdentifiers

@main
struct ComposeAppStoreScreenshots {
    private static let width = 1320
    private static let height = 2868
    private static let rawWidth = 1050
    private static let cream = CGColor(red: 0xFB / 255.0, green: 0xF7 / 255.0, blue: 0xF2 / 255.0, alpha: 1)
    private static let plum = CGColor(red: 0x5B / 255.0, green: 0x41 / 255.0, blue: 0x5E / 255.0, alpha: 1)
    private static let linen = CGColor(red: 0xE8 / 255.0, green: 0xE1 / 255.0, blue: 0xDB / 255.0, alpha: 1)

    private static let headlines: [String: [String: String]] = [
        "en-US": [
            "01-welcome": "Your week, already waiting.",
            "02-curation-progress": "Private from the first tap.",
            "03-review": "Seven moments. Nothing to sort.",
            "04-replace": "Change one. Keep the feeling.",
            "05-saved-weeks": "A small album, every week.",
            "06-plus": "Two albums free. Then yours for life.",
        ],
        "ko": [
            "01-welcome": "사진은 많고, 시간은 없으니까.",
            "02-curation-progress": "첫 탭부터, 사진은 기기 안에서.",
            "03-review": "일주일에 7장만.",
            "04-replace": "마음에 안 드는 한 장만 바꾸세요.",
            "05-saved-weeks": "작은 한 주가 차곡차곡.",
            "06-plus": "두 번 무료, 그다음은 평생 이용권.",
        ],
    ]

    private static let slugs = [
        "01-welcome",
        "02-curation-progress",
        "03-review",
        "04-replace",
        "05-saved-weeks",
        "06-plus",
    ]

    static func main() throws {
        let arguments = try Arguments(ProcessInfo.processInfo.arguments)
        let fileManager = FileManager.default
        let outputRoot = arguments.outputRoot.standardizedFileURL
        let rawRoot = arguments.rawRoot.standardizedFileURL
        let fixtureRoot = arguments.fixtureRoot.standardizedFileURL
        let repoRoot = URL(fileURLWithPath: fileManager.currentDirectoryPath).standardizedFileURL

        if fileManager.fileExists(atPath: outputRoot.path) {
            let marker = outputRoot.appendingPathComponent(".weekkeep-managed")
            guard fileManager.fileExists(atPath: marker.path) else {
                throw Failure("Refusing to compose into an unmarked output directory: \(outputRoot.path)")
            }
        } else {
            try fileManager.createDirectory(at: outputRoot, withIntermediateDirectories: true)
        }
        try Data("Weekkeep App Store screenshot output\n".utf8)
            .write(to: outputRoot.appendingPathComponent(".weekkeep-managed"), options: .atomic)

        let fontURL = arguments.fontURL ?? repoRoot
            .appendingPathComponent("resources/fonts/line-seed-kr/LINESeedKR-Bd.ttf")
        let registered = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        if !registered && NSFont(name: "LINESeedSansKR-Bold", size: 20) == nil {
            // The font can already be registered when this tool is run twice
            // in one process; the name lookup below is the real smoke test.
            throw Failure("Could not register LINE Seed Sans KR Bold: \(fontURL.path)")
        }
        guard NSFont(name: "LINESeedSansKR-Bold", size: 20) != nil else {
            throw Failure("LINESeedSansKR-Bold is unavailable after registration")
        }

        let fixtureFiles = try fileManager.contentsOfDirectory(
            at: fixtureRoot,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        .filter { $0.pathExtension.lowercased() == "png" && $0.lastPathComponent.first?.isNumber == true }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
        guard fixtureFiles.count == 7 else {
            throw Failure("Expected seven approved fixture PNGs, found \(fixtureFiles.count)")
        }

        var localeRecords: [LocaleRecord] = []
        for locale in ["en-US", "ko"] {
            guard let localeHeadlines = headlines[locale] else { throw Failure("Missing headline contract for \(locale)") }
            let rawLocale = rawRoot.appendingPathComponent(locale)
            let finalLocale = outputRoot.appendingPathComponent(locale)
            try fileManager.createDirectory(at: finalLocale, withIntermediateDirectories: true)

            var screenshots: [ScreenshotRecord] = []
            for (offset, slug) in slugs.enumerated() {
                let rawURL = rawLocale.appendingPathComponent("\(slug).png")
                guard fileManager.fileExists(atPath: rawURL.path) else {
                    throw Failure("Missing raw capture: \(rawURL.path)")
                }
                guard let rawImage = loadImage(rawURL) else {
                    throw Failure("Could not decode raw capture: \(rawURL.path)")
                }
                guard rawImage.width == width, rawImage.height == height else {
                    throw Failure("Raw capture \(rawURL.lastPathComponent) is \(rawImage.width)x\(rawImage.height), expected \(width)x\(height)")
                }

                let headline = localeHeadlines[slug]!
                let finalURL = finalLocale.appendingPathComponent("\(slug).jpg")
                let composed = try compose(rawImage: rawImage.image, headline: headline)
                try writeJPEG(composed, to: finalURL)

                screenshots.append(ScreenshotRecord(
                    sequence: offset + 1,
                    semantic: semanticName(for: slug),
                    filename: "\(slug).jpg",
                    headline: headline,
                    source: relativePath(rawURL, from: repoRoot),
                    sourceSHA256: sha256(rawURL),
                    finalSHA256: sha256(finalURL)
                ))
            }
            localeRecords.append(LocaleRecord(locale: locale, screenshots: screenshots))
        }

        let fixtureRecords = fixtureFiles.map { file in
            FixtureRecord(filename: relativePath(file, from: repoRoot), sha256: sha256(file))
        }
        let manifest = ScreenshotManifest(
            schemaVersion: 1,
            set: "app-store-6.9",
            device: DeviceRecord(name: arguments.deviceName, udid: arguments.deviceID, os: "iOS 26.5"),
            output: OutputRecord(width: width, height: height, format: "jpeg", alpha: false),
            composition: CompositionRecord(
                background: "#FBF7F2",
                headlineColor: "#5B415E",
                borderColor: "#E8E1DB",
                headlineFont: "LINESeedSansKR-Bold",
                rawScreenshotWidth: rawWidth,
                rawScreenshotCornerRadius: 44,
                deviceFrame: false
            ),
            fixtureSources: fixtureRecords,
            locales: localeRecords
        )
        let manifestData = try JSONEncoder.pretty.encode(manifest)
        try manifestData.write(to: outputRoot.appendingPathComponent("manifest.json"), options: .atomic)
        try writeProvenance(
            manifest: manifest,
            candidateBuild: arguments.candidateBuild,
            candidateUploadState: arguments.candidateUploadState,
            to: outputRoot.appendingPathComponent("PROVENANCE.md")
        )
        try writeChecksums(manifest: manifest, to: outputRoot.appendingPathComponent("SHA256SUMS.txt"))

        print("COMPOSED: \(outputRoot.path)")
        print("HEADLINE FONT: LINESeedSansKR-Bold")
        print("OUTPUT: 2 locales × 6 opaque JPEGs at \(width)x\(height)")
    }

    private static func semanticName(for slug: String) -> String {
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

    private static func loadImage(_ url: URL) -> (image: CGImage, width: Int, height: Int)? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return nil }
        return (image, image.width, image.height)
    }

    private static func compose(rawImage: CGImage, headline: String) throws -> CGImage {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw Failure("Could not create composition context")
        }

        context.setFillColor(cream)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        let headlineFont = CTFontCreateWithName("LINESeedSansKR-Bold" as CFString, 66, nil)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 8
        let attributed = NSAttributedString(
            string: headline,
            attributes: [
                .font: headlineFont,
                .foregroundColor: NSColor(cgColor: plum) ?? NSColor.black,
                .paragraphStyle: paragraph,
                .kern: 0.1,
            ]
        )
        let framesetter = CTFramesetterCreateWithAttributedString(attributed as CFAttributedString)
        let constraint = CGSize(width: rawWidth, height: 360)
        var headlineSize = CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRange(location: 0, length: attributed.length),
            nil,
            constraint,
            nil
        )
        headlineSize.width = CGFloat(rawWidth)
        headlineSize.height = ceil(headlineSize.height)
        let topMargin: CGFloat = 112
        let rawTop: CGFloat = topMargin + headlineSize.height + 58
        let rawHeight = CGFloat(rawWidth) * CGFloat(height) / CGFloat(width)
        let rawRect = CGRect(
            x: CGFloat((width - rawWidth) / 2),
            y: CGFloat(height) - rawTop - rawHeight,
            width: CGFloat(rawWidth),
            height: rawHeight
        )
        guard rawRect.minY > 80 else {
            throw Failure("Headline and raw screenshot do not fit within safe margins")
        }

        let headlineRect = CGRect(
            x: rawRect.minX,
            y: CGFloat(height) - topMargin - headlineSize.height,
            width: CGFloat(rawWidth),
            height: headlineSize.height + 8
        )
        let textPath = CGPath(rect: headlineRect, transform: nil)
        let textFrame = CTFramesetterCreateFrame(
            framesetter,
            CFRange(location: 0, length: attributed.length),
            textPath,
            nil
        )
        context.saveGState()
        context.textPosition = CGPoint(x: 0, y: 0)
        CTFrameDraw(textFrame, context)
        context.restoreGState()

        let clipPath = CGPath(
            roundedRect: rawRect,
            cornerWidth: 44,
            cornerHeight: 44,
            transform: nil
        )
        context.saveGState()
        context.addPath(clipPath)
        context.clip()
        context.interpolationQuality = .high
        context.draw(rawImage, in: rawRect)
        context.restoreGState()

        context.addPath(clipPath)
        context.setStrokeColor(linen)
        context.setLineWidth(2)
        context.strokePath()
        return context.makeImage()!
    }

    private static func writeJPEG(_ image: CGImage, to url: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else { throw Failure("Could not create JPEG destination: \(url.path)") }
        let properties: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: 0.93,
            kCGImagePropertyJFIFIsProgressive: false,
        ]
        CGImageDestinationAddImage(destination, image, properties as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            throw Failure("Could not finalize JPEG: \(url.path)")
        }
    }

    private static func sha256(_ url: URL) -> String {
        let data = (try? Data(contentsOf: url)) ?? Data()
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private static func relativePath(_ url: URL, from root: URL) -> String {
        let rootPath = root.path.hasSuffix("/") ? root.path : root.path + "/"
        return url.standardizedFileURL.path.replacingOccurrences(of: rootPath, with: "")
    }

    private static func writeProvenance(
        manifest: ScreenshotManifest,
        candidateBuild: String?,
        candidateUploadState: String?,
        to url: URL
    ) throws {
        var lines = [
            "# App Store 6.9-inch screenshot provenance",
            "",
            "This directory contains the six-screen App Store composition for each approved locale.",
            "The raw app captures are recorded in the manifest's locale-specific source paths and are ignored by git.",
            "",
            "- Device: \(manifest.device.name) (`\(manifest.device.udid)`), \(manifest.device.os)",
            "- Output: two locales × six opaque JPEGs, exactly `1320×2868`",
            "- Composition: Cream `#FBF7F2`, Plum `#5B415E`, Linen `#E8E1DB`, no device frame",
            "- Headline font: bundled `LINESeedSansKR-Bold`",
            "- Capture mode: DEBUG bundled-fixture XCTest UI evidence via `-ui-app-store-fixtures`; it does not exercise PhotoKit.",
            "- Fixture policy: the seven fictional, non-identifiable images below are the bundled `SamplePhotoFixtures`; they are not customer photos.",
            "- Real PhotoKit behavior is validated separately through the live adapter/device QA path.",
            "- Review framing: `03-review` is the clean top story; `04-replace` is an intentional lower-action state after scrolling. Neither capture changes production spacing.",
            "- `03-review-bottom` is a raw QA-only attachment used to prove the lower action order and is not part of the six composed submission images.",
            "",
            "## Approved fixture sources",
            "",
        ]
        if let candidateBuild {
            lines.insert(
                "- Release candidate: App Store build `\(candidateBuild)`; this composition is local evidence only.",
                at: 7
            )
        }
        if let candidateUploadState {
            lines.insert("- Candidate upload state: `\(candidateUploadState)`.", at: 8)
        }
        for fixture in manifest.fixtureSources {
            lines.append("- `\(fixture.filename)` — SHA-256 `\(fixture.sha256)`")
        }
        lines.append("")
        lines.append("## Final screenshot hashes")
        lines.append("")
        for locale in manifest.locales {
            lines.append("### \(locale.locale)")
            lines.append("")
            for screenshot in locale.screenshots {
                lines.append("- `\(screenshot.filename)` — \(screenshot.headline) — SHA-256 `\(screenshot.finalSHA256)`")
            }
            lines.append("")
        }
        try lines.joined(separator: "\n").appending("\n").write(to: url, atomically: true, encoding: .utf8)
    }

    private static func writeChecksums(manifest: ScreenshotManifest, to url: URL) throws {
        var lines: [String] = []
        for locale in manifest.locales {
            for screenshot in locale.screenshots {
                lines.append("\(screenshot.finalSHA256)  \(locale.locale)/\(screenshot.filename)")
            }
        }
        try lines.joined(separator: "\n").appending("\n").write(to: url, atomically: true, encoding: .utf8)
    }

    private struct Arguments {
        let rawRoot: URL
        let outputRoot: URL
        let fixtureRoot: URL
        let deviceID: String
        let deviceName: String
        let fontURL: URL?
        let candidateBuild: String?
        let candidateUploadState: String?

        init(_ arguments: [String]) throws {
            var values: [String: String] = [:]
            var index = 1
            while index < arguments.count {
                let key = arguments[index]
                guard index + 1 < arguments.count else { throw Failure("Missing value for \(key)") }
                values[key] = arguments[index + 1]
                index += 2
            }
            func required(_ key: String) throws -> String {
                guard let value = values[key], !value.isEmpty else { throw Failure("Missing required argument \(key)") }
                return value
            }
            rawRoot = URL(fileURLWithPath: try required("--raw-root"), isDirectory: true)
            outputRoot = URL(fileURLWithPath: try required("--output-root"), isDirectory: true)
            fixtureRoot = URL(fileURLWithPath: try required("--fixture-root"), isDirectory: true)
            deviceID = try required("--device-id")
            deviceName = try required("--device-name")
            fontURL = values["--font"].map { URL(fileURLWithPath: $0) }
            candidateBuild = values["--candidate-build"]
            candidateUploadState = values["--candidate-upload-state"]
        }
    }

    private struct ScreenshotManifest: Codable {
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

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
