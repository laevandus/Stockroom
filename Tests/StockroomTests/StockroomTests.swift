//
//  StockroomTests.swift
//  
//
//  Created by Toomas Vahter on 05.01.2023.
//

@testable import Stockroom
import XCTest

final class StockroomTests: XCTestCase {
    private var stockroom: Stockroom!
    
    override func setUpWithError() throws {
        stockroom = try Stockroom(name: #fileID)
    }

    override func tearDownWithError() throws {
        stockroom = nil
    }

    func testStoreAndLoadData() async throws {
        let input = try XCTUnwrap("Data".data(using: .utf8))
        let identifier = try await stockroom.storeData(input, for: "abc")
        XCTAssertEqual(identifier, "abc")
        
        let result = await stockroom.loadData(for: identifier)
        XCTAssertEqual(result, input)
    }
}
