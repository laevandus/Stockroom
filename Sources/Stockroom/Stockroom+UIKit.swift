//
//  Stockroom+UIKit.swift
//  
//
//  Created by Toomas Vahter on 05.01.2023.
//

#if canImport(UIKit)
import os
import UIKit

extension Stockroom {
    func loadCGImage(for identifier: String, targetPixelSize: CGSize) async -> CGImage? {
        await load(for: identifier, dataTransformer: { data in
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                Logger.stockroom.debug("Failed to create an image source")
                return nil
            }
            guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                Logger.stockroom.debug("Failed to create an image using a source")
                return nil
            }
            if targetPixelSize.width > 0, targetPixelSize.height > 0 {
                guard let scaled = ImageScaler.scaleToFill(image, in: targetPixelSize) else {
                    Logger.stockroom.debug("Failed to scale an image to w:\(targetPixelSize.width) h:\(targetPixelSize.height)")
                    return nil
                }
                return scaled
            }
            else {
                return image
            }
        })
    }
    
    private static func createData(from cgImage: CGImage, orientation: CGImagePropertyOrientation) -> Data? {
        guard let upOrientedImage = cgImage.rotatedToUpOrientation(from: orientation) else { return nil }
        guard let mutableData = CFDataCreateMutable(nil, 0) else { return nil }
        guard let destination = CGImageDestinationCreateWithData(mutableData, "public.jpeg" as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, upOrientedImage, nil)
        return CGImageDestinationFinalize(destination) ? mutableData as Data : nil
    }
    
    // MARK: -
    
    /// Loads image asynchonously on disk.
    /// - Parameters:
    ///   - identifier: The identifier of the image.
    ///   - targetPixelSize: The target size of the image.
    public func loadImage(for identifier: String, targetPixelSize: CGSize = .zero) async -> UIImage? {
        guard let cgImage = await loadCGImage(for: identifier, targetPixelSize: targetPixelSize) else { return nil }
        return UIImage(cgImage: cgImage, scale: 1, orientation: .up)
    }
    
    /// Store data asynchronously on disk.
    /// - Parameters:
    ///   - image: UIImage to store.
    ///   - identifier: The identifier of the image.
    /// - Returns: An identifier used for storing the data.
    public func storeImage(_ image: UIImage, for identifier: String = UUID().uuidString) async throws -> String {
        try await store({
            guard let cgImage = image.cgImage else { return nil }
            return Self.createData(from: cgImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
        }, for: identifier)
    }
}
#endif
