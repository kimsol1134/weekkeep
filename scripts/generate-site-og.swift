import AppKit
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

@main
struct GenerateSiteOG {
    private static let width = 1200
    private static let height = 630
    private static let cream = CGColor(red: 0xFB / 255.0, green: 0xF7 / 255.0, blue: 0xF2 / 255.0, alpha: 1)
    private static let paper = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    private static let ink = CGColor(red: 0x25 / 255.0, green: 0x21 / 255.0, blue: 0x2B / 255.0, alpha: 1)
    private static let plum = CGColor(red: 0x5B / 255.0, green: 0x41 / 255.0, blue: 0x5E / 255.0, alpha: 1)
    private static let linen = CGColor(red: 0xE8 / 255.0, green: 0xE1 / 255.0, blue: 0xDB / 255.0, alpha: 1)
    private static let stitchColors: [CGColor] = [
        CGColor(red: 0xE9 / 255.0, green: 0x7A / 255.0, blue: 0x68 / 255.0, alpha: 1),
        CGColor(red: 0xE3 / 255.0, green: 0x94 / 255.0, blue: 0x55 / 255.0, alpha: 1),
        CGColor(red: 0xE5 / 255.0, green: 0xA8 / 255.0, blue: 0x4B / 255.0, alpha: 1),
        CGColor(red: 0x66 / 255.0, green: 0x83 / 255.0, blue: 0x6E / 255.0, alpha: 1),
        CGColor(red: 0x5F / 255.0, green: 0x87 / 255.0, blue: 0x9B / 255.0, alpha: 1),
        CGColor(red: 0x68 / 255.0, green: 0x62 / 255.0, blue: 0x86 / 255.0, alpha: 1),
        CGColor(red: 0x8A / 255.0, green: 0x63 / 255.0, blue: 0x86 / 255.0, alpha: 1),
    ]

    static func main() throws {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).standardizedFileURL
        let publicRoot = root.appendingPathComponent("site/public")
        let fixtureRoot = publicRoot.appendingPathComponent("fixtures/app-store-family-moments")
        let outputURL = publicRoot.appendingPathComponent("og.png")
        let wordmarkURL = publicRoot.appendingPathComponent("brand/weekkeep-wordmark.png")

        let fontURL = root.appendingPathComponent("resources/fonts/line-seed-kr/LINESeedKR-Bd.ttf")
        _ = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)

        let fixtureNames = [
            "01-ginkgo-leaf.png", "02-pancake-morning.png", "03-rainy-puddle.png",
            "04-bedtime-story.png", "05-park-bubbles.png", "06-acorn-home.png",
            "07-balcony-herbs.png",
        ]
        let fixtures = try fixtureNames.map { name -> CGImage in
            let url = fixtureRoot.appendingPathComponent(name)
            guard let image = loadImage(url) else { throw Failure("Could not decode fixture: (url.path)") }
            return image
        }
        guard let wordmark = loadImage(wordmarkURL) else {
            throw Failure("Could not decode canonical wordmark: (wordmarkURL.path)")
        }

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else { throw Failure("Could not create OG context") }

        context.setFillColor(cream)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        drawImage(wordmark, inTopRect: CGRect(x: 82, y: 118, width: 310, height: 80), context: context)
        drawText(
            "A week worth keeping.",
            inTopRect: CGRect(x: 82, y: 244, width: 520, height: 64),
            fontSize: 38,
            color: plum,
            context: context
        )
        drawText(
            "Seven everyday moments, kept privately on your iPhone.",
            inTopRect: CGRect(x: 84, y: 338, width: 420, height: 82),
            fontSize: 21,
            color: ink,
            context: context
        )
        drawText(
            "PRIVATE WEEKLY PHOTO RITUAL",
            inTopRect: CGRect(x: 84, y: 476, width: 360, height: 24),
            fontSize: 12,
            color: plum,
            context: context
        )

        let card = CGRect(x: 620, y: 62, width: 520, height: 506)
        drawRoundedRect(card, radius: 28, fill: paper, stroke: linen, context: context)
        drawText(
            "SEVEN MOMENTS",
            inTopRect: CGRect(x: 646, y: 86, width: 180, height: 20),
            fontSize: 12,
            color: plum,
            context: context
        )
        drawStitches(x: 982, y: 84, width: 10, height: 28, gap: 7, context: context)

        let mosaicX: CGFloat = 646
        let mosaicWidth: CGFloat = 468
        let heroHeight: CGFloat = 188
        drawImage(
            fixtures[0],
            inTopRect: CGRect(x: mosaicX, y: 132, width: mosaicWidth, height: heroHeight),
            radius: 12,
            context: context
        )

        let middleY: CGFloat = 328
        let middleGap: CGFloat = 8
        let middleWidth = (mosaicWidth - middleGap) / 2
        for index in 0..<2 {
            drawImage(
                fixtures[index + 1],
                inTopRect: CGRect(
                    x: mosaicX + CGFloat(index) * (middleWidth + middleGap),
                    y: middleY,
                    width: middleWidth,
                    height: 112
                ),
                radius: 12,
                context: context
            )
        }

        let bottomY: CGFloat = 448
        let bottomGap: CGFloat = 8
        let bottomWidth = (mosaicWidth - (bottomGap * 3)) / 4
        for index in 0..<4 {
            drawImage(
                fixtures[index + 3],
                inTopRect: CGRect(
                    x: mosaicX + CGFloat(index) * (bottomWidth + bottomGap),
                    y: bottomY,
                    width: bottomWidth,
                    height: 72
                ),
                radius: 10,
                context: context
            )
        }

        guard let image = context.makeImage(),
              let destination = CGImageDestinationCreateWithURL(
                outputURL as CFURL,
                UTType.png.identifier as CFString,
                1,
                nil
              ) else { throw Failure("Could not create OG PNG destination") }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw Failure("Could not write \(outputURL.path)")
        }
        print("GENERATED: \(outputURL.path) \(width)x\(height), opaque PNG")
    }

    private static func loadImage(_ url: URL) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    private static func topRect(_ rect: CGRect) -> CGRect {
        CGRect(x: rect.minX, y: CGFloat(height) - rect.maxY, width: rect.width, height: rect.height)
    }

    private static func drawRoundedRect(
        _ rect: CGRect,
        radius: CGFloat,
        fill: CGColor,
        stroke: CGColor,
        context: CGContext
    ) {
        let path = CGPath(roundedRect: topRect(rect), cornerWidth: radius, cornerHeight: radius, transform: nil)
        context.addPath(path)
        context.setFillColor(fill)
        context.fillPath()
        context.addPath(path)
        context.setStrokeColor(stroke)
        context.setLineWidth(2)
        context.strokePath()
    }

    private static func drawImage(
        _ image: CGImage,
        inTopRect rect: CGRect,
        radius: CGFloat = 0,
        context: CGContext
    ) {
        let target = topRect(rect)
        context.saveGState()
        if radius > 0 {
            context.addPath(CGPath(roundedRect: target, cornerWidth: radius, cornerHeight: radius, transform: nil))
            context.clip()
        }
        let scale = max(target.width / CGFloat(image.width), target.height / CGFloat(image.height))
        let drawSize = CGSize(width: CGFloat(image.width) * scale, height: CGFloat(image.height) * scale)
        let drawRect = CGRect(
            x: target.midX - drawSize.width / 2,
            y: target.midY - drawSize.height / 2,
            width: drawSize.width,
            height: drawSize.height
        )
        context.interpolationQuality = .high
        context.draw(image, in: drawRect)
        context.restoreGState()
    }

    private static func drawStitches(
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        gap: CGFloat,
        context: CGContext
    ) {
        for (index, color) in stitchColors.enumerated() {
            let rect = topRect(CGRect(
                x: x + CGFloat(index) * (width + gap),
                y: y,
                width: width,
                height: height
            ))
            context.addPath(CGPath(roundedRect: rect, cornerWidth: width / 2, cornerHeight: width / 2, transform: nil))
            context.setFillColor(color)
            context.fillPath()
        }
    }

    private static func drawText(
        _ string: String,
        inTopRect rect: CGRect,
        fontSize: CGFloat,
        color: CGColor,
        context: CGContext
    ) {
        let font = CTFontCreateWithName("LINESeedSansKR-Bold" as CFString, fontSize, nil)
        let attributed = NSAttributedString(
            string: string,
            attributes: [
                .font: font,
                .foregroundColor: NSColor(cgColor: color) ?? NSColor.black,
                .kern: 0.1,
            ]
        )
        let framesetter = CTFramesetterCreateWithAttributedString(attributed as CFAttributedString)
        let path = CGPath(rect: topRect(rect), transform: nil)
        let frame = CTFramesetterCreateFrame(
            framesetter,
            CFRange(location: 0, length: attributed.length),
            path,
            nil
        )
        CTFrameDraw(frame, context)
    }

    private struct Failure: Error, CustomStringConvertible {
        let description: String

        init(_ description: String) { self.description = description }
    }
}
