import XCTest
@testable import HTTPClientCore

final class DataExtensionTests: XCTestCase {

    func testPrettyPrinted() {
        let data = "{\"foo\": \"bar\"}".data(using: .utf8)
        let prettyPrinted = data?.prettyPrinted
        XCTAssertEqual(prettyPrinted, "{\n  \"foo\" : \"bar\"\n}")
    }
}
