import Foundation

/// A mock that can be used to run stubbed URLSession tasks.
public final class URLProtocolMock: URLProtocol {
    public static var startLoadingCallsCount: Int = 0
    public static var stopLoadingCallsCount: Int = 0

    // MARK: - Stub

    public static var stubbedError: Error?
    public static var stubbedRequestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    public static func cleanup() {
        stubbedError = nil
        stubbedRequestHandler = nil
        startLoadingCallsCount = 0
        stopLoadingCallsCount = 0
    }

    // MARK: - URLProtocol

    public override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    public override func startLoading() {
        Self.startLoadingCallsCount += 1

        do {
            if let stubbedError = Self.stubbedError {
                throw stubbedError
            }

            guard let requestHandler = URLProtocolMock.stubbedRequestHandler else {
                fatalError("Request handler must be stubbed")
            }

            let (response, data) = try requestHandler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    public override func stopLoading() {
        Self.stopLoadingCallsCount += 1
    }
}
