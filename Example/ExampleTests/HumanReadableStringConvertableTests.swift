//
//  HumanReadableStringConvertableTests.swift
//  ExampleTests
//
//  Created by Nick Kibysh on 02/05/2023.
//

import XCTest
@testable import Example

final class HumanReadableStringConvertableTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testData() {
        let d1 = Data(repeating: 0, count: 4)
        XCTAssertEqual(d1.humanReadableString, "4 bytes")
    }
}
