import XCTest
@testable import HTTPClient

final class HTTPRequestBuilderTests: XCTestCase {

    // MARK: - Tests - Init

    func testInit() {
        let builder = HTTPRequestBuilder(scheme: .http, host: "host", headers: ["key": "value"])

        XCTAssertEqual(builder.scheme, .http, "It has the correct scheme")
        XCTAssertEqual(builder.host, "host", "It has the correct host")
        XCTAssertEqual(builder.headers, ["key": "value"], "It has the correct headers")
    }

    // MARK: - Tests - Valid

    func testBuildingValidRequest() {
        let builder = HTTPRequestBuilder(scheme: .http, host: "www.apple.com", headers: ["key": "value"])

        let request = try! builder
            .path("/path")
            .cachePolicy(.returnCacheDataDontLoad)
            .method(.post)
            .queryItems([URLQueryItem(name: "name", value: "value")])
            .additionalHeaders(["other": "2"])
            .timeoutInterval(5)
            .build()

        XCTAssertNotNil(request, "It is not nil")
        XCTAssertNotNil(request.url, "It is not nil")
        XCTAssertEqual(request.url?.absoluteString, "http://www.apple.com/path?name=value", "It has the correct url string")
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 2, "It has the expected headers count")
        XCTAssertEqual(request.allHTTPHeaderFields?["key"], "value", "It has the expected value for key")
        XCTAssertEqual(request.allHTTPHeaderFields?["other"], "2", "It has the expected value for key")
        XCTAssertEqual(request.cachePolicy, .returnCacheDataDontLoad, "It has the expected cache policy")
        XCTAssertNil(request.httpBody, "It has no request body")
        XCTAssertEqual(request.httpMethod, "POST", "It has the correct http method")
        XCTAssertEqual(request.timeoutInterval, 5, "It has the correct timeout interval")
    }

    func testBuildingValidRequestWithBody() {
        let builder = HTTPRequestBuilder(scheme: .http, host: "www.apple.com", headers: ["key": "value"])

        let request = try! builder
            .path("/path")
            .body(ResponseBodyMock(id: 10, description: "Desc"))
            .build()

        XCTAssertNotNil(request, "It is not nil")
        XCTAssertNotNil(request.url, "It is not nil")
        XCTAssertEqual(request.url?.absoluteString, "http://www.apple.com/path", "It has the correct url string")
        XCTAssertNotNil(request.httpBody, "It has a request body")

        let decodedBody = try! JSONDecoder().decode(ResponseBodyMock.self, from: request.httpBody!)
        XCTAssertEqual(decodedBody, ResponseBodyMock(id: 10, description: "Desc"), "The request body has the correct properties when decoded")
    }

    // MARK: - Tests - Invalid

    func testBuildingRequestWithInvalidPath() {
        let builder = HTTPRequestBuilder(scheme: .http, host: "www.apple.com", headers: ["key": "value"])

        let builderExpectation = expectation(description: "Builder should throw an error")

        do {
            _ = try builder
                .path("path")
                .build()
        } catch {
            XCTAssertNotNil(error, "It has returned an error")

            let builderError = error as? HTTPRequestBuilderError
            XCTAssertEqual(builderError, .invalidURLComponents, "It has returned the expected error")
            XCTAssertEqual(builderError?.debugDescription,
                           "Invalid URL components when building request. Double-check if host, path (begins with /), and other parameters are valid.",
                           "It has the correct debug description")

            builderExpectation.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // MARK: - Tests - State

    func testIfCleaningDoNotKeepRequestRelatedState() {
        let builder = HTTPRequestBuilder(scheme: .http, host: "www.apple.com", headers: ["key": "value"])

        _ = try! builder
            .path("/path")
            .cachePolicy(.reloadIgnoringLocalAndRemoteCacheData)
            .method(.post)
            .queryItems([URLQueryItem(name: "name", value: "value")])
            .additionalHeaders(["other": "2"])
            .timeoutInterval(5)
            .body(ResponseBodyMock(id: 10, description: "Desc"))
            .build()

        let secondRequest = try! builder
            .clean()
            .path("/other")
            .cachePolicy(.returnCacheDataElseLoad)
            .method(.patch)
            .build()

        XCTAssertNotNil(secondRequest, "It is not nil")
        XCTAssertNotNil(secondRequest.url, "It is not nil")
        XCTAssertEqual(secondRequest.url?.absoluteString, "http://www.apple.com/other", "It has the correct url string")
        XCTAssertEqual(secondRequest.allHTTPHeaderFields?.count, 1, "It has the expected headers count")
        XCTAssertEqual(secondRequest.allHTTPHeaderFields?["key"], "value", "It has the expected value for key")
        XCTAssertEqual(secondRequest.cachePolicy, .returnCacheDataElseLoad, "It has the expected cache policy")
        XCTAssertNil(secondRequest.httpBody, "It has no request body")
        XCTAssertEqual(secondRequest.httpMethod, "PATCH", "It has the correct http method")
        XCTAssertEqual(secondRequest.timeoutInterval, 10, "It has the correct timeout interval")
    }

    // MARK: - Tests - Schemes

    func testIfBuildsWithCorrectScheme() {
        // http scheme
        var builder = HTTPRequestBuilder(scheme: .http, host: "www.apple.com")

        var request = try! builder
            .path("/path")
            .build()

        XCTAssertEqual(request.url?.absoluteString, "http://www.apple.com/path", "It has the correct url string")

        // https scheme
        builder = HTTPRequestBuilder(scheme: .https, host: "www.apple.com")

        request = try! builder
            .path("/path")
            .build()

        XCTAssertEqual(request.url?.absoluteString, "https://www.apple.com/path", "It has the correct url string")
    }

    // MARK: - Tests - Request methods

    func testIfBuildsWithCorrectRequestMethod() {
        // get
        let builder = HTTPRequestBuilder(scheme: .http, host: "www.apple.com")

        var request = try! builder
            .path("/path")
            .method(.get)
            .build()

        XCTAssertEqual(request.httpMethod, "GET", "It has the correct http method")

        // delete
        request = try! builder
            .path("/path")
            .method(.delete)
            .build()

        XCTAssertEqual(request.httpMethod, "DELETE", "It has the correct http method")

        // patch
        request = try! builder
            .path("/path")
            .method(.patch)
            .build()

        XCTAssertEqual(request.httpMethod, "PATCH", "It has the correct http method")

        // POST
        request = try! builder
            .path("/path")
            .method(.post)
            .build()

        XCTAssertEqual(request.httpMethod, "POST", "It has the correct http method")

        // PUT
        request = try! builder
            .path("/path")
            .method(.put)
            .build()

        XCTAssertEqual(request.httpMethod, "PUT", "It has the correct http method")
    }
}
