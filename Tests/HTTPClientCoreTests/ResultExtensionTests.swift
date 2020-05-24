import XCTest
import HTTPClientTestSupport
@testable import HTTPClientCore

final class ResultExtensionTests: XCTestCase {

    func testSuccessProperty() {
        let result: Result<Void, Never> = .success(())
        XCTAssertNotNil(result.value, "It has returns a success value")
    }

    func testFailureProperty() {
        let result: Result<Void, FakeError> = .failure(FakeError())
        XCTAssertNotNil(result.error, "It has returns a failure value")
    }
}
