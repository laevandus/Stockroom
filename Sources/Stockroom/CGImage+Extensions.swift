//
//  CGImage+Extensions.swift
//  
//
//  Created by Toomas Vahter on 03.07.2022.
//

import CoreGraphics
import ImageIO

extension CGImage {
    func rotatedToUpOrientation(from orientation: CGImagePropertyOrientation) -> CGImage? {
        guard orientation != .up else { return self }
        let pixelSize = CGSize(width: width, height: height)
        let rotationTransform: CGAffineTransform = {
            switch orientation {
            case .up, .upMirrored:
                return CGAffineTransform()
            case .down, .downMirrored:
                return CGAffineTransform(translationX: pixelSize.width, y: pixelSize.height).rotated(by: CGFloat.pi)
            case .left, .leftMirrored:
                return CGAffineTransform(translationX: pixelSize.height, y: 0).rotated(by: CGFloat.pi / 2.0)
            case .right, .rightMirrored:
                return CGAffineTransform(translationX: 0, y: pixelSize.width).rotated(by: -CGFloat.pi / 2.0)
            }
        }()
        let transform: CGAffineTransform
        switch orientation {
        case .upMirrored, .downMirrored:
            transform = rotationTransform.translatedBy(x: pixelSize.height, y: 0).scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = rotationTransform.translatedBy(x: pixelSize.width, y: 0).scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            transform = rotationTransform
        }
        
        let upOrientedContextSize: CGSize = {
            switch orientation {
            case .up, .upMirrored, .down, .downMirrored:
                return CGSize(width: width, height: height)
            case .left, .leftMirrored, .right, .rightMirrored:
                return CGSize(width: height, height: width)
            }
        }()
        guard let context = CGContext.context(forDrawing: self, size: upOrientedContextSize) else { return nil }
        context.concatenate(transform)
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }
}

extension CGContext {
    class func context(forDrawing cgImage: CGImage, size: CGSize) -> CGContext? {
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: cgImage.bytesPerRow,
                                space: cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: cgImage.bitmapInfo.rawValue)
        context?.interpolationQuality = .high
        return context
    }
}
