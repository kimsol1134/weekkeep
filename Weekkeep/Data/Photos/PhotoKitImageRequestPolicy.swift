import UIKit

/// Pure PhotoKit callback policy for analysis and display delivery.
///
/// iCloud-optimized libraries usually deliver a local degraded frame first,
/// then a sharper frame after download. Display UI must show the first frame
/// immediately and keep that request alive while the photo is on screen.
enum PhotoKitImageRequestPolicy: Sendable {
    /// Share preparation can wait for a sharper frame, but it must still
    /// finish with the best received image rather than hanging the sheet.
    static let shareFallbackTimeoutNanoseconds: UInt64 = 30_000_000_000

    enum DeliveryMode: Equatable, Sendable {
        case fastFormat
        case opportunisticHighQuality
    }

    enum Decision: Equatable, Sendable {
        case ignore
        case usePartial
        case complete(cancelOutstanding: Bool)
        case fail
    }

    static func decision(
        hasImage: Bool,
        degraded: Bool,
        deliveryMode: DeliveryMode
    ) -> Decision {
        switch deliveryMode {
        case .fastFormat:
            return hasImage ? .complete(cancelOutstanding: true) : .fail
        case .opportunisticHighQuality:
            if hasImage {
                return degraded ? .usePartial : .complete(cancelOutstanding: false)
            }
            return degraded ? .ignore : .fail
        }
    }
}

enum PhotoDisplayTarget {
    static let hero = CGSize(width: 1_600, height: 1_000)
    static let reviewTile = CGSize(width: 900, height: 900)
    static let viewer = CGSize(width: 1_600, height: 1_600)
    static let strip = CGSize(width: 240, height: 240)
    static let cover = CGSize(width: 900, height: 900)
}

struct PhotoDisplayFrame: @unchecked Sendable {
    let image: UIImage

    var pixelWidth: Int { Int(image.size.width * image.scale) }
    var pixelHeight: Int { Int(image.size.height * image.scale) }
    var pixelCount: Int { pixelWidth * pixelHeight }
    var minPixelDimension: Int { min(pixelWidth, pixelHeight) }

    func meets(_ targetSize: CGSize) -> Bool {
        let needed = Int(min(targetSize.width, targetSize.height) * 0.8)
        return minPixelDimension >= needed
    }
}

enum PhotoKitJPEGEncoder: Sendable {
    static func data(from image: UIImage, quality: CGFloat = 0.85) -> Data? {
        if let data = image.jpegData(compressionQuality: quality), !data.isEmpty {
            return data
        }

        let size = image.size
        guard size.width > 0, size.height > 0 else { return nil }

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        format.preferredRange = .standard
        let flattened = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return flattened.jpegData(compressionQuality: quality)
    }
}
