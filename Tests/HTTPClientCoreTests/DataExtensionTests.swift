import XCTest
import HTTPClientTestSupport
@testable import HTTPClientCore

final class SetExtensionTests: XCTestCase {

    func testDefaultSuccessfulStatusCode() {
        XCTAssertEqual(Set.defaultSuccessfulStatusCodes, Set(200..<300))
    }
}
