import XCTest
@testable import HTTPClient
@testable import HTTPClientCore
import Logging

final class HTTPClientTests: XCTestCase {

    private var sessionMock = URLSessionMock()
    private var client: HTTPClient!

    override func setUp() {
        super.setUp()

        client = HTTPClient(session: sessionMock, responseHandler: HTTPResponseHandler(), middlewares: nil)
    }

    // MARK: - Success

    func testPerformWithSuccessAndEmptyDataBody() throws {
        sessionMock.stubDataTask(toCompleteWithData: Data(), response: Helpers.makeURLResponse(statusCode: 200), error: nil)

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()

        var resultBlock: Result<HTTPResponse, HTTPResponseError>?
        client.perform(request) { result in
            resultBlock = result
        }

        let httpResponse = try resultBlock?.get()
        XCTAssertNotNil(httpResponse, "It is not nil")
        XCTAssertEqual(httpResponse?.isSucceeded, true, "It is succeeded")
        XCTAssertEqual(httpResponse?.statusCode, 200, "It has the correct status code")
        XCTAssertNotNil(httpResponse?.successBody(), "It have a success body")
        XCTAssertNil(httpResponse?.failureBody(), "It does not have a failure body")
        XCTAssertTrue(sessionMock.didCallDataTask, "It calls `dataTask`")
        XCTAssertEqual(sessionMock.lastRequest, request, "It passes in the correct URLRequest")
        XCTAssertNotNil(sessionMock.lastCompletionHandler, "It received a completion handler")
    }

    func testPerformWithSuccessAndNonEmptyDataBody() throws {
        let expectedBodyMock = ResponseBodyMock(id: 10, description: "desc")
        let encodedBodyMock = try JSONEncoder().encode(expectedBodyMock)
        sessionMock.stubDataTask(toCompleteWithData: encodedBodyMock, response: Helpers.makeURLResponse(statusCode: 200), error: nil)

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()

        var resultBlock: Result<HTTPResponse, HTTPResponseError>?
        client.perform(request) { result in
            resultBlock = result
        }

        let httpResponse = try resultBlock?.get()
        XCTAssertNotNil(httpResponse, "It is not nil")
        XCTAssertEqual(httpResponse?.isSucceeded, true, "It is succeeded")
        XCTAssertEqual(httpResponse?.statusCode, 200, "It has the correct status code")
        XCTAssertNotNil(httpResponse?.successBody(), "It have a success body")
        XCTAssertNil(httpResponse?.failureBody(), "It does not have a failure body")

        let decoder = HTTPResponseDecoder(jsonDecoder: JSONDecoder())
        let decodedBody = try httpResponse?
            .successBody()
            .decoded(as: ResponseBodyMock.self, using: decoder)
        XCTAssertEqual(decodedBody, expectedBodyMock, "It decodes the body as expected")

        XCTAssertTrue(sessionMock.didCallDataTask, "It calls `dataTask`")
        XCTAssertEqual(sessionMock.lastRequest, request, "It passes in the correct URLRequest")
        XCTAssertNotNil(sessionMock.lastCompletionHandler, "It received a completion handler")
    }

    // MARK: - Failure

    func testPerformWithFailureAndEmptyDataBody() throws {
        let expectedURLResponse = Helpers.makeURLResponse(statusCode: 404)
        sessionMock.stubDataTask(toCompleteWithData: Data(), response: expectedURLResponse, error: nil)

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()

        var resultBlock: Result<HTTPResponse, HTTPResponseError>?
        client.perform(request) { result in
            resultBlock = result
        }

        let httpResponse = try resultBlock?.get()
        XCTAssertNotNil(httpResponse, "It is not nil")
        XCTAssertEqual(httpResponse?.isSucceeded, false, "It is not succeeded")
        XCTAssertEqual(httpResponse?.statusCode, 404, "It has the correct status code")
        XCTAssertNil(httpResponse?.successBody(), "It does not have a success body")
        XCTAssertNotNil(httpResponse?.failureBody(), "It does have a failure body")
        XCTAssert(httpResponse?.urlResponse == expectedURLResponse, "It has the correct url response")
        XCTAssertTrue(sessionMock.didCallDataTask, "It calls `dataTask`")
        XCTAssertEqual(sessionMock.lastRequest, request, "It passes in the correct URLRequest")
        XCTAssertNotNil(sessionMock.lastCompletionHandler, "It received a completion handler")
    }

    func testPerformWithFailureAndNonEmptyDataBody() throws {
        let expectedErrorBodyMock = DecodableErrorMock(description: "desc", id: 8)
        let encodedErrorBodyMock = try JSONEncoder().encode(expectedErrorBodyMock)
        sessionMock.stubDataTask(toCompleteWithData: encodedErrorBodyMock, response: Helpers.makeURLResponse(statusCode: 500), error: nil)

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()

        var resultBlock: Result<HTTPResponse, HTTPResponseError>?
        client.perform(request) { result in
            resultBlock = result
        }

        let httpResponse = try resultBlock?.get()
        XCTAssertNotNil(httpResponse, "It is not nil")
        XCTAssertEqual(httpResponse?.isSucceeded, false, "It is not succeeded")
        XCTAssertEqual(httpResponse?.statusCode, 500, "It has the correct status code")
        XCTAssertNil(httpResponse?.successBody(), "It does not have a success body")
        XCTAssertNotNil(httpResponse?.failureBody(), "It does have a failure body")

        let decoder = HTTPResponseDecoder(jsonDecoder: JSONDecoder())
        let decodedErrorBody = try httpResponse?
            .failureBody()
            .decoded(as: DecodableErrorMock.self, using: decoder)
        XCTAssertEqual(decodedErrorBody, expectedErrorBodyMock, "It decodes the body as expected")

        XCTAssertTrue(sessionMock.didCallDataTask, "It calls `dataTask`")
        XCTAssertEqual(sessionMock.lastRequest, request, "It passes in the correct URLRequest")
        XCTAssertNotNil(sessionMock.lastCompletionHandler, "It received a completion handler")
    }

    // MARK: - Error

    func testPerformWithError() throws {
        let error = NSError(domain: NSURLErrorDomain,
                            code: URLError.secureConnectionFailed.rawValue,
                            userInfo: nil)
        sessionMock.stubDataTask(toCompleteWithData: nil, response: Helpers.makeURLResponse(statusCode: 400), error: error)

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()

        var resultBlock: Result<HTTPResponse, HTTPResponseError>?
        client.perform(request) { result in
            resultBlock = result
        }

        XCTAssertThrowsError(try resultBlock?.get(), "It throws error") { error in
            let httpResponseError = error as? HTTPResponseError
            guard case let .underlying(urlError) = httpResponseError else {
                XCTFail("Received an unexpected HTTPRequestError")
                return
            }

            XCTAssertEqual(urlError as NSError, NSError(domain: NSURLErrorDomain,
                                                        code: URLError.secureConnectionFailed.rawValue,
                                                        userInfo: nil),
                           "The error thrown is a NSURLErrorSecureConnectionFailed")
        }

        XCTAssertTrue(sessionMock.didCallDataTask, "It calls `dataTask`")
        XCTAssertEqual(sessionMock.lastRequest, request, "It passes in the correct URLRequest")
        XCTAssertNotNil(sessionMock.lastCompletionHandler, "It received a completion handler")
    }

    func testWithMiddleware() throws {
        let middlewareMock = MiddlewareMock()
        client = HTTPClient(session: sessionMock, responseHandler: HTTPResponseHandler(), middlewares: [middlewareMock])

        sessionMock.stubDataTask(toCompleteWithData: nil, response: Helpers.makeURLResponse(statusCode: 200), error: nil)

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()

        var resultBlock: Result<HTTPResponse, HTTPResponseError>?
        client.perform(request) { result in
            resultBlock = result
        }

        XCTAssertTrue(middlewareMock.didCallRespondToRequest, "It called didCallRespondToRequest")
        XCTAssertTrue(middlewareMock.didCallRespondToResult, "It called didCallRespondToResult")
        XCTAssertEqual(middlewareMock.lastRequest, request, "It has received the correct request")
        XCTAssertEqual(try middlewareMock.lastResult?.get(), try resultBlock?.get(), "It has received the correct result")
    }
}

// MARK: - Middleware mock

final class MiddlewareMock: HTTPClientMiddleware {
    private(set) var didCallRespondToRequest: Bool = false
    private(set) var didCallRespondToResult: Bool = false
    private(set) var lastRequest: URLRequest?
    private(set) var lastResult: Result<HTTPResponse, HTTPResponseError>?

    func respond(to request: URLRequest) {
        didCallRespondToRequest = true
        lastRequest = request
    }

    func respond(to responseResult: Result<HTTPResponse, HTTPResponseError>) {
        didCallRespondToResult = true
        lastResult = responseResult
    }
}
