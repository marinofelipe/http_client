import Foundation
import HTTPClientCore

// MARK: - Abstraction

public protocol HTTPClientProtocol {
    @discardableResult
    func perform(_ request: URLRequest,
                 completion: @escaping (Result<HTTPResponse, HTTPResponseError>) -> Void) -> HTTPTask
}

// MARK: - Concrete

/// An HTTP client that runs `URLRequests`.
/// *Note*: The queue where to run the completions `e.g. .main`, **must** be defined through `URLSession.delegateQueue`.
/// Docs: https://developer.apple.com/documentation/foundation/urlsession/1411571-delegatequeue
public final class HTTPClient: HTTPClientProtocol {
    private let session: URLSessionProtocol
    private let responseHandler: HTTPResponseHandling
    private let middlewares: [HTTPClientMiddleware]?

    public init(session: URLSessionProtocol,
                responseHandler: HTTPResponseHandling,
                middlewares: [HTTPClientMiddleware]?) {
        self.session = session
        self.responseHandler = responseHandler
        self.middlewares = middlewares
    }

    /// Performs the `request` with generic `ResponseBody` for handler and completion.
    ///
    /// *Note*: For empty body responses, or requests that only the result as success matters, **make sure** you use
    /// `EmptyBody` decodable type.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to be run.
    ///   - completion: The closure to be called when the request is complete.
    /// - Returns: A running HTTPTask.
    @discardableResult
    public func perform(_ request: URLRequest,
                        completion: @escaping (Result<HTTPResponse, HTTPResponseError>) -> Void) -> HTTPTask {

        middlewares?.forEach { $0.respond(to: request) }

        let task = session.dataTask(with: request) { [weak self] data, urlResponse, error in
            guard let self = self else { return }
            let result: Result<HTTPResponse, HTTPResponseError>
            do {
                let responseStatus = try self.responseHandler.handle(params: (data, response: urlResponse, error))
                let response = HTTPResponse(body: data,
                                            isSucceeded: responseStatus.isSucceeded,
                                            statusCode: responseStatus.statusCode,
                                            urlResponse: urlResponse)
                result = .success(response)
            } catch {
                if let httpResponseError = error as? HTTPResponseError {
                    result = .failure(httpResponseError)
                } else {
                    result = .failure(.unknown)
                }
            }
            // Performed on URLSessionProtocol.delegateQueue
            completion(result)
            self.middlewares?.forEach { $0.respond(to: result) }
        }
        task.resume()

        return task
    }
}
