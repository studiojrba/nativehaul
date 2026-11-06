import Foundation

/// Recognises downloaded image bytes by their signature, so an HTML error page or placeholder is never cached.
enum ImageFormat: String, Sendable {
    case jpeg = "jpg"
    case png
    case webp
    case gif

    private static let jpegSignature = bytes(hex: "FFD8FF")
    private static let pngSignature = bytes(hex: "89504E47")
    private static let gifSignature = Array("GIF8".utf8)
    private static let riffSignature = Array("RIFF".utf8)
    private static let webpSignature = Array("WEBP".utf8)
    private static let webpMarkerOffset = 8

    /// File extension used in the artwork cache.
    var fileExtension: String {
        rawValue
    }

    /// The format of `data`, or `nil` when it is not a supported image.
    static func detect(_ data: Data) -> ImageFormat? {
        let bytes = [UInt8](data.prefix(webpMarkerOffset + webpSignature.count))
        if bytes.starts(with: jpegSignature) {
            return .jpeg
        }
        if bytes.starts(with: pngSignature) {
            return .png
        }
        if bytes.starts(with: gifSignature) {
            return .gif
        }
        if bytes.starts(with: riffSignature), bytes.dropFirst(webpMarkerOffset).starts(with: webpSignature) {
            return .webp
        }
        return nil
    }

    private static let hexRadix = 16
    private static let hexDigitsPerByte = 2

    private static func bytes(hex: String) -> [UInt8] {
        let digits = Array(hex)
        return stride(from: 0, to: digits.count, by: hexDigitsPerByte).compactMap { start in
            UInt8(String(digits[start ..< start + hexDigitsPerByte]), radix: hexRadix)
        }
    }
}
