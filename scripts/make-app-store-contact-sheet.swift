import AppKit
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

@main
struct MakeAppStoreContactSheet {
    private static let slugs = [
        "01-welcome",
        "02-curation-progress",
        "03-review",
        "04-replace",
        "05-saved-weeks",
        "06-plus",
    ]
    private static let locales = ["en-US", "ko"]
    private static let cellWidth = 210
    private static let cellHeight = 456
    private static let gap = 14
    private static let margin = 42

    static func main() throws {
        let outputRoot = try Arguments(ProcessInfo.processInfo.arguments).outputRoot
        var images: [String: [CGImage]] = [:]
        for locale in locales {
            images[locale] = try slugs.map { slug in
                let url = outputRoot.appendingPathComponent(locale).appendingPathComponent("\(slug).jpg")
                guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                      let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
                else { throw Failure("Could not load contact-sheet source: \(url.path)") }
                return image
            }
        }

        let width = margin * 2 + (cellWidth * slugs.count) + (gap * (slugs.count - 1))
        let rowHeight = 34 + cellHeight + 38
        let height = margin + (rowHeight * locales.count) + margin
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { throw Failure("Could not create contact-sheet context") }

        let background = CGColor(red: 0xFB / 255.0, green: 0xF7 / 255.0, blue: 0xF2 / 255.0, alpha: 1)
        let ink = CGColor(red: 0x5B / 255.0, green: 0x41 / 255.0, blue: 0x5E / 255.0, alpha: 1)
        context.setFillColor(background)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        for (row, locale) in locales.enumerated() {
            let rowTop = margin + (row * rowHeight)
            drawLabel(locale, in: context, x: CGFloat(margin), y: CGFloat(height - rowTop - 24), color: ink)
            for (column, image) in images[locale]!.enumerated() {
                let x = margin + (column * (cellWidth + gap))
                let y = height - rowTop - 34 - cellHeight
                let rect = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
                let clip = CGPath(roundedRect: rect, cornerWidth: 16, cornerHeight: 16, transform: nil)
                context.saveGState()
                context.addPath(clip)
                context.clip()
                context.interpolationQuality = .high
                context.draw(image, in: rect)
                context.restoreGState()
                drawLabel(String(column + 1), in: context, x: CGFloat(x + 4), y: CGFloat(y - 25), color: ink)
            }
        }

        let outputURL = outputRoot.appendingPathComponent("contact-sheet.jpg")
        guard let outputImage = context.makeImage(),
              let destination = CGImageDestinationCreateWithURL(
                outputURL as CFURL,
                UTType.jpeg.identifier as CFString,
                1,
                nil
              ) else { throw Failure("Could not create contact sheet") }
        CGImageDestinationAddImage(destination, outputImage, [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw Failure("Could not finalize contact sheet") }
        print("CONTACT SHEET: \(outputURL.path) \(width)x\(height)")
    }

    private static func drawLabel(_ text: String, in context: CGContext, x: CGFloat, y: CGFloat, color: CGColor) {
        let font = NSFont(name: "Helvetica-Bold", size: text.count > 2 ? 18 : 16) ?? NSFont.systemFont(ofSize: 16, weight: .bold)
        let attributed = NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: NSColor(cgColor: color) ?? NSColor.black,
        ])
        let line = CTLineCreateWithAttributedString(attributed as CFAttributedString)
        context.saveGState()
        context.textPosition = CGPoint(x: x, y: y)
        CTLineDraw(line, context)
        context.restoreGState()
    }

    private struct Arguments {
        let outputRoot: URL

        init(_ arguments: [String]) throws {
            guard let index = arguments.firstIndex(of: "--output-root"), index + 1 < arguments.count else {
                throw Failure("Usage: --output-root PATH")
            }
            outputRoot = URL(fileURLWithPath: arguments[index + 1], isDirectory: true)
        }
    }

    private struct Failure: Error, CustomStringConvertible {
        let description: String
        init(_ description: String) { self.description = description }
    }
}
