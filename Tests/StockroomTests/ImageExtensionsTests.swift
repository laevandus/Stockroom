//
//  ImageExtensionsTests.swift
//  
//
//  Created by Toomas Vahter on 19.08.2022.
//

@testable import Stockroom
import ImageIO
import XCTest

final class ImageExtensionsTests: XCTestCase {
#if canImport(UIKit)
    func testImagePropertyOrientation() throws {
        XCTAssertEqual(CGImagePropertyOrientation(.up), CGImagePropertyOrientation.up)
    }
#endif
}
