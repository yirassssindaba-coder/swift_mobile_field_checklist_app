import UIKit

enum ImageCompressor {
    static func compressToJpegData(_ image: UIImage,
                                  maxBytes: Int = 500 * 1024,
                                  maxDimension: CGFloat = 1600) -> Data? {

        let resized = resizeIfNeeded(image, maxDimension: maxDimension)

        var quality: CGFloat = 0.85
        guard var data = resized.jpegData(compressionQuality: quality) else { return nil }

        while data.count > maxBytes && quality > 0.25 {
            quality -= 0.10
            if let newData = resized.jpegData(compressionQuality: quality) {
                data = newData
            } else {
                break
            }
        }
        return data
    }

    private static func resizeIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return image }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let out = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return out ?? image
    }
}
