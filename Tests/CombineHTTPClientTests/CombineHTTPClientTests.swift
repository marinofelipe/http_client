import XCTest
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Combine
import HTTPClientCore
import HTTPClientTestSupport
@testable import CombineHTTPClient

final class CombineHTTPClientTests: XCTestCase {
    private var sut: CombineHTTPClient!
    private var disposeBag: Set<AnyCancellable>! = .init()

    override func setUpWithError() throws {
        try super.setUpWithError()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let urlSession = URLSession(configuration: configuration)

        sut = CombineHTTPClient(session: urlSession)
    }

    override func tearDownWithError() throws {
        disposeBag.removeAll()
        disposeBag = nil
        sut = nil
        URLProtocolMock.cleanup()

        try super.tearDownWithError()
    }

    // MARK: - Success

    func testRunWithSuccessAndEmptyDataBody() throws {
        let runExpectation = expectation(description: "Client to run over mocked URLSession")

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()
        let url = try XCTUnwrap(request.url)

        URLProtocolMock.stubbedRequestHandler = { request in
          let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
          return (response, nil)
        }

        var receivedResponse: HTTPResponse<EmptyBody, EmptyBody>?
        let publisher: AnyPublisher<HTTPResponse<EmptyBody, EmptyBody>, HTTPResponseError> = sut.run(request, receiveOn: .main)
        publisher.sink(receiveCompletion: { completion in
            guard case .finished = completion else {
                XCTFail("Should not receive a error completion")
                return
            }
        }) { response in
            receivedResponse = response
            runExpectation.fulfill()
        }.store(in: &disposeBag)

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(receivedResponse, "It is not nil")
        XCTAssertEqual(receivedResponse?.isSuccess, true, "It is success")
        XCTAssertEqual(receivedResponse?.statusCode, 200, "It has the correct status code")
        XCTAssertEqual(receivedResponse?.value, .success(EmptyBody()), "It has the expected value")

        XCTAssertEqual(URLProtocolMock.startLoadingCallsCount, 1, "It calls `startLoading` once")
        XCTAssertEqual(URLProtocolMock.stopLoadingCallsCount, 1, "It calls `stopLoading` once")
    }

    func testRunWithSuccessAndNonEmptyDataBody() throws {
        let runExpectation = expectation(description: "Client to run over mocked URLSession")

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()
        let url = try XCTUnwrap(request.url)

        let fakeBody = FakeResponseBody(id: 10, description: "desc")
        let encodedFakeBody = try JSONEncoder().encode(fakeBody)

        URLProtocolMock.stubbedRequestHandler = { request in
          let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
          return (response, encodedFakeBody)
        }

        var receivedResponse: HTTPResponse<FakeResponseBody, EmptyBody>?
        let publisher: AnyPublisher<HTTPResponse<FakeResponseBody, EmptyBody>, HTTPResponseError> = sut.run(request, receiveOn: .main)
        publisher.sink(receiveCompletion: { completion in
            guard case .finished = completion else {
                XCTFail("Should not receive a error completion")
                return
            }
        }) { response in
            receivedResponse = response
            runExpectation.fulfill()
        }.store(in: &disposeBag)

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(receivedResponse, "It is not nil")
        XCTAssertEqual(receivedResponse?.isSuccess, true, "It is success")
        XCTAssertEqual(receivedResponse?.statusCode, 200, "It has the correct status code")
        XCTAssertEqual(receivedResponse?.value, .success(fakeBody), "It has the expected decoded value")

        XCTAssertEqual(URLProtocolMock.startLoadingCallsCount, 1, "It calls `startLoading` once")
        XCTAssertEqual(URLProtocolMock.stopLoadingCallsCount, 1, "It calls `stopLoading` once")
    }

    // MARK: - Failure

    func testRunWithFailureAndEmptyDataBody() throws {
        let runExpectation = expectation(description: "Client to run over mocked URLSession")

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()
        let url = try XCTUnwrap(request.url)

        URLProtocolMock.stubbedRequestHandler = { request in
          let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil))
          return (response, Data())
        }

        var receivedResponse: HTTPResponse<FakeResponseBody, EmptyBody>?
        let publisher: AnyPublisher<HTTPResponse<FakeResponseBody, EmptyBody>, HTTPResponseError> = sut.run(request, receiveOn: .main)
        publisher.sink(receiveCompletion: { completion in
            guard case .finished = completion else {
                XCTFail("Should not receive a error completion")
                return
            }
        }) { response in
            receivedResponse = response
            runExpectation.fulfill()
        }.store(in: &disposeBag)

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(receivedResponse, "It is not nil")
        XCTAssertEqual(receivedResponse?.isSuccess, false, "It is success")
        XCTAssertEqual(receivedResponse?.statusCode, 404, "It has the correct status code")
        XCTAssertEqual(receivedResponse?.value, .failure(EmptyBody()), "It has the expected value")

        XCTAssertEqual(URLProtocolMock.startLoadingCallsCount, 1, "It calls `startLoading` once")
        XCTAssertEqual(URLProtocolMock.stopLoadingCallsCount, 1, "It calls `stopLoading` once")
    }

    func testRunWithFailureAndNonEmptyDataBody() throws {
        let runExpectation = expectation(description: "Client to run over mocked URLSession")

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()
        let url = try XCTUnwrap(request.url)

        let fakeBody = FakeResponseBody(id: 10, description: "desc")
        let encodedFakeBody = try JSONEncoder().encode(fakeBody)

        URLProtocolMock.stubbedRequestHandler = { request in
          let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil))
          return (response, encodedFakeBody)
        }

        var receivedResponse: HTTPResponse<EmptyBody, FakeResponseBody>?
        let publisher: AnyPublisher<HTTPResponse<EmptyBody, FakeResponseBody>, HTTPResponseError> = sut.run(request, receiveOn: .main)
        publisher.sink(receiveCompletion: { completion in
            guard case .finished = completion else {
                XCTFail("Should not receive a error completion")
                return
            }
        }) { response in
            receivedResponse = response
            runExpectation.fulfill()
        }.store(in: &disposeBag)

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(receivedResponse, "It is not nil")
        XCTAssertEqual(receivedResponse?.isSuccess, false, "It is success")
        XCTAssertEqual(receivedResponse?.statusCode, 500, "It has the correct status code")
        XCTAssertEqual(receivedResponse?.value, .failure(fakeBody), "It has the expected value")

        XCTAssertEqual(URLProtocolMock.startLoadingCallsCount, 1, "It calls `startLoading` once")
        XCTAssertEqual(URLProtocolMock.stopLoadingCallsCount, 1, "It calls `stopLoading` once")
    }

    // MARK: - Error

    func testRunWithError() throws {
        let runExpectation = expectation(description: "Client to run over mocked URLSession")

        URLProtocolMock.stubbedError = FakeError()

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()
        var receivedError: HTTPResponseError?
        let publisher: AnyPublisher<HTTPResponse<EmptyBody, FakeResponseBody>, HTTPResponseError> = sut.run(request, receiveOn: .main)

        publisher.sink(receiveCompletion: { completion in
            guard case let .failure(error) = completion else {
                XCTFail("Should receive a error completion")
                return
            }
            receivedError = error
            runExpectation.fulfill()
        }) { response in
            XCTFail("Should not receive a valid response")
        }.store(in: &disposeBag)

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(receivedError, "It is not nil")

        guard case .underlying = receivedError else {
            XCTFail("Should have received an HTTPResponseError.underlying()")
            return
        }

        XCTAssertEqual(URLProtocolMock.startLoadingCallsCount, 1, "It calls `startLoading` once")
        XCTAssertEqual(URLProtocolMock.stopLoadingCallsCount, 1, "It calls `stopLoading` once")
    }

    func testRunWithFailureByDecodingError() throws {
        let runExpectation = expectation(description: "Client to run over mocked URLSession")

        let fakeBody = FakeResponseBody(id: 10, description: "desc")
        let encodedFakeBody = try JSONEncoder().encode(fakeBody)

        let request = try HTTPRequestBuilder(scheme: .https, host: "www.apple.com").build()
        let url = try XCTUnwrap(request.url)

        URLProtocolMock.stubbedRequestHandler = { request in
            let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil))
            return (response, encodedFakeBody)
        }

        var receivedError: HTTPResponseError?
        let publisher: AnyPublisher<HTTPResponse<EmptyBody, Int>, HTTPResponseError> = sut.run(request, receiveOn: .main)

        publisher.sink(receiveCompletion: { completion in
            guard case let .failure(error) = completion else {
                XCTFail("Should receive a error completion")
                return
            }
            receivedError = error
            runExpectation.fulfill()
        }) { response in
            XCTFail("Should not receive a valid response")
        }.store(in: &disposeBag)

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertNotNil(receivedError, "It is not nil")

        guard case .decoding = receivedError else {
            XCTFail("Should have received an HTTPResponseError.underlying()")
            return
        }

        XCTAssertEqual(URLProtocolMock.startLoadingCallsCount, 1, "It calls `startLoading` once")
        XCTAssertEqual(URLProtocolMock.stopLoadingCallsCount, 1, "It calls `stopLoading` once")
    }

    // MARK: - Middleware

    func testWithMiddleware() throws {
        // TODO: Tbi. after middleware support is added
    }
}
