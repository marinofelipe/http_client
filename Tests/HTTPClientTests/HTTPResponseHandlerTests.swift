import XCTest
@testable import HTTPClient

final class HTTPResponseHandlerTests: XCTestCase {

    private var handler = HTTPResponseHandler()

    // MARK: - Tests - Error

    func testHandleWhenAllParamsNil() {
        let responseParams: HTTPResponseHandling.ResponseParams = (data: nil, response: nil, error: nil)

        XCTAssertThrowsError(try handler.handle(params: responseParams), "It throws an error") { error in
            XCTAssertEqual(error as? HTTPRequestError, .unknown, "The error thrown is a HTTPRequestError.unknown")
        }
    }

    func testHandleWithMappedNSURLErrorAndNoResponse() {
        let errorMock = HTTPRequestError.unknown
        let responseParamsMock: HTTPResponseHandling.ResponseParams = (data: dataMock, response: nil, error: errorMock)

        XCTAssertThrowsError(try handler.handle(params: responseParamsMock), "It throws an error") { error in
            XCTAssertEqual(error as? HTTPRequestError, .unknown, "The error thrown is a HTTPRequestError.unknown")
        }
    }

    func testHandleWithUnmappedNSURLErrorAndNoResponse() {
        let error = NSError(domain: NSURLErrorDomain,
                            code: URLError.secureConnectionFailed.rawValue,
                            userInfo: nil)
        let responseParamsMock: HTTPResponseHandling.ResponseParams = (data: dataMock, response: nil, error: error)

        XCTAssertThrowsError(try handler.handle(params: responseParamsMock), "It throws an error") { error in
            let httpRequestError = error as? HTTPRequestError

            guard case let .underlying(urlError) = httpRequestError else {
                XCTFail("Received an unexpected HTTPRequestError")
                return
            }

            XCTAssertEqual(urlError as NSError, NSError(domain: NSURLErrorDomain,
                                                        code: URLError.secureConnectionFailed.rawValue,
                                                        userInfo: nil),
                           "The error thrown is a NSURLErrorSecureConnectionFailed")
        }
    }

    func testHandleWithErrorAndResponse() {
        let error = NSError(domain: NSURLErrorDomain,
                            code: URLError.secureConnectionFailed.rawValue,
                            userInfo: nil)
        let responseParamsMock: HTTPResponseHandling.ResponseParams = (data: dataMock, response: Helpers.makeURLResponse(statusCode: 500), error: error)

        XCTAssertThrowsError(try handler.handle(params: responseParamsMock), "It throws an error") { error in
            let httpRequestError = error as? HTTPRequestError

            guard case let .underlying(urlError) = httpRequestError else {
                XCTFail("Received an unexpected HTTPRequestError")
                return
            }

            XCTAssertEqual(urlError as NSError, NSError(domain: NSURLErrorDomain,
                                                        code: URLError.secureConnectionFailed.rawValue,
                                                        userInfo: nil),
                           "The error thrown is a NSURLErrorSecureConnectionFailed")
        }
    }

    // MARK: - Tests - Response

    func testHandleWithInvalidStatusCodeAndData() throws {
        let responseParamsMock: HTTPResponseHandling.ResponseParams = (data: dataMock, response: Helpers.makeURLResponse(statusCode: 400), error: nil)
        let returnTuple = try handler.handle(params: responseParamsMock)

        XCTAssertEqual(returnTuple.isSucceeded, false, "It returns as not succeeded")
        XCTAssertEqual(returnTuple.statusCode, 400, "It returns the correct status code")
    }

    func testHandleWithInvalidStatusCodeAndNoResponseData() throws {
        let responseParamsMock: HTTPResponseHandling.ResponseParams = (data: nil, response: Helpers.makeURLResponse(statusCode: 400), error: nil)
        let returnTuple = try handler.handle(params: responseParamsMock)

        XCTAssertEqual(returnTuple.isSucceeded, false, "It returns as not succeeded")
        XCTAssertEqual(returnTuple.statusCode, 400, "It returns the correct status code")
    }

    func testHandleWithValidStatusCodeAndNoResponseData() throws {
        let responseParamsMock: HTTPResponseHandling.ResponseParams = (data: nil, response: Helpers.makeURLResponse(statusCode: 200), error: nil)

        let returnTuple = try handler.handle(params: responseParamsMock)

        XCTAssertEqual(returnTuple.isSucceeded, true, "It returns as not succeeded")
        XCTAssertEqual(returnTuple.statusCode, 200, "It returns the correct status code")
    }

    func testHandleWithValidStatusCodeAndResponseData() throws {
        let responseParamsMock: HTTPResponseHandling.ResponseParams = (data: dataMock, response: Helpers.makeURLResponse(statusCode: 200), error: nil)

        let returnTuple = try handler.handle(params: responseParamsMock)

        XCTAssertEqual(returnTuple.isSucceeded, true, "It returns as not succeeded")
        XCTAssertEqual(returnTuple.statusCode, 200, "It returns the correct status code")
    }
}

// MARK: - Helpers

extension HTTPResponseHandlerTests {
    var dataMock: Data { "some data".data(using: .utf8)! }
}
