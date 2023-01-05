//
//  ImageExtensionsTests.swift
//  
//
//  Created by Toomas Vahter on 19.08.2022.
//

import ImageIO
import XCTest

final class ImageExtensionsTests: XCTestCase {
    func testImagePropertyOrientation() throws {
        XCTAssertEqual(CGImagePropertyOrientation(.up), CGImagePropertyOrientation.up)
    }
}
