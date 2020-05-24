import HTTPClient
import Foundation

public final class HTTPClientMock: HTTPClientProtocol {
    public private(set) var didCallPerform: Bool = false
    public private(set) var performCallsCount = 0
    public private(set) var lastRequest: URLRequest?
    public private(set) var lastCompletion: ((Result<HTTPResponse, Error>) -> Void)?

    public init() { }

    @discardableResult
    public func perform(_ request: URLRequest,
                 completion: @escaping (Result<HTTPResponse, Error>) -> Void) -> HTTPTask {
        didCallPerform = true
        performCallsCount += 1
        lastRequest = request
        lastCompletion = completion

        completion(stubbedResult ?? .failure(FakeError()))

        return HTTPTaskFake()
    }

    // MARK: Stub

    private(set) var stubbedResult: Result<HTTPResponse, Error>?

    public func stubResult(with value: Result<HTTPResponse, Error>) {
        stubbedResult = value
    }
}
