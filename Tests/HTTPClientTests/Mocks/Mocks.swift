import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import HTTPClient

// MARK: - Decodable error mock

struct DecodableErrorMock: Codable, Equatable, Error, LocalizedError {
    let description: String
    let id: Int
}

// MARK: - URL session mock

class URLSessionMock: URLSessionProtocol {
    private(set) var delegateQueue: OperationQueue = .main
    private(set) var didCallDataTask = false
    private(set) var lastRequest: URLRequest?
    private(set) var lastCompletionHandler: ((Data?, URLResponse?, Error?) -> Void)?

    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        didCallDataTask = true
        lastRequest = request
        lastCompletionHandler = completionHandler

        completionHandler(self.stubbedCompletionData,
                          self.stubbedCompletionResponse,
                          self.stubbedCompletionError)

        return stubbedDataTask
    }

    // MARK: - Stubs

    private var stubbedCompletionData: Data?
    private var stubbedCompletionResponse: URLResponse?
    private var stubbedCompletionError: Error?
    private var stubbedDataTask: URLSessionDataTask = URLSessionDataTaskPartialMock()

    func stubDataTask(toCompleteWithData data: Data?, response: URLResponse?, error: Error?) {
        stubbedCompletionData = data
        stubbedCompletionResponse = response
        stubbedCompletionError = error
    }

    func stubDataTask(toReturn dataTask: URLSessionDataTask) {
        self.stubbedDataTask = dataTask
    }
}

// MARK: - URL session data task partial mock

final class URLSessionDataTaskPartialMock: URLSessionDataTask {
    override func resume() {}
    override func suspend() {}
    override func cancel() {}
}
