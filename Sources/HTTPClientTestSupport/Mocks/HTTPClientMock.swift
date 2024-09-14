import HTTPClient
import HTTPClientCore
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class HTTPClientMock: HTTPClientProtocol {
    public private(set) var didCallPerform: Bool = false
    public private(set) var performCallsCount = 0
    public private(set) var lastRequest: URLRequest?
    public private(set) var lastCompletion: ((Result<HTTPResponse, HTTPResponseError>) -> Void)?

    public init() { }

    @discardableResult
    public func run(_ request: URLRequest,
                    completion: @escaping (Result<HTTPResponse, HTTPResponseError>) -> Void) -> HTTPTask {
        didCallPerform = true
        performCallsCount += 1
        lastRequest = request
        lastCompletion = completion

        completion(stubbedResult ?? .failure(.unknown))

        return HTTPTaskFake()
    }

    // MARK: Stub

    private(set) var stubbedResult: Result<HTTPResponse, HTTPResponseError>?

    public func stubResult(with value: Result<HTTPResponse, HTTPResponseError>) {
        stubbedResult = value
    }
}
