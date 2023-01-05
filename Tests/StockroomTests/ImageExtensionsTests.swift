//
//  ImageExtensionsTests.swift
//  
//
//  Created by Toomas Vahter on 19.08.2022.
//

import ImageIO
@testable import Stockroom
import XCTest

final class ImageExtensionsTests: XCTestCase {
#if canImport(UIKit)
    func testImagePropertyOrientation() throws {
        XCTAssertEqual(CGImagePropertyOrientation(.up), CGImagePropertyOrientation.up)
    }
#endif
}
