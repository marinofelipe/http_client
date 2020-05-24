import XCTest
@testable import HTTPClient

final class HTTPResponseDecoderTests: XCTestCase {

    func testInit() {
        let decoder = JSONDecoder()
        let responseDecoder = HTTPResponseDecoder(jsonDecoder: decoder)

        XCTAssert(responseDecoder.jsonDecoder === decoder, "It has the correct json decoder")
    }

    func testDecodingWithFailure() {
        let decoder = JSONDecoder()
        let responseDecoder = HTTPResponseDecoder(jsonDecoder: decoder)

        XCTAssertThrowsError(decoded = try responseDecoder.decode(Data()),
                             "It throws a decoding error") { error in
            let decodingError = error as? DecodingError
            XCTAssertNotNil(decodingError, "It throws a decoding error")
        }
    }

    func testDecodingWithSuccess() throws {
        let decoder = JSONDecoder()
        let responseDecoder = HTTPResponseDecoder(jsonDecoder: decoder)

        let responseBodyMock = ResponseBodyMock(id: 10, description: "Desc")
        let encodedResponseBodyMock = try JSONEncoder().encode(responseBodyMock)

        let decodedResponseBody: ResponseBodyMock = try responseDecoder.decode(encodedResponseBodyMock)

        XCTAssertEqual(decodedResponseBody, ResponseBodyMock(id: 10, description: "Desc"), "It decodes with as expected")
    }
}
