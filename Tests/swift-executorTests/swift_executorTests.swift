import XCTest
@testable import swift_executor

class swift_executorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(swift_executor().text, "Hello, World!")
    }


    static var allTests : [(String, (swift_executorTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
