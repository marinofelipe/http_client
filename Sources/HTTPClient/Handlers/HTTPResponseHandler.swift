import Foundation
import HTTPClientCore

// MARK: - Abstraction

public protocol HTTPResponseHandling {
    typealias ResponseParams = (data: Data?, response: URLResponse?, error: Error?)

    func handle(params: ResponseParams) throws -> (isSucceeded: Bool, statusCode: Int)
}

// MARK: - Concrete

/// Handler for HTTP requests responses. It returns a tuple: `Bool` indicating success and the `statusCode`.
public struct HTTPResponseHandler: HTTPResponseHandling {
    let successfulStatusCodes: Set<Int>

    public init(successfulStatusCodes: Set<Int> = .defaultSuccessfulStatusCodes) {
        self.successfulStatusCodes = successfulStatusCodes
    }

    public func handle(params: ResponseParams) throws -> (isSucceeded: Bool, statusCode: Int) {
        guard params.error == nil else {
            if let urlError = params.error as? URLError {
                throw HTTPResponseError.underlying(urlError)
            }

            // TODO: could also return response for logger to perform side effect

            throw HTTPResponseError.unknown
        }

        guard let response = params.response as? HTTPURLResponse else {
            if let response = params.response {
                throw HTTPResponseError.invalidResponse(response)
            } else {
                throw HTTPResponseError.unknown
            }
        }

        return (isSucceeded: successfulStatusCodes.contains(response.statusCode), statusCode: response.statusCode)
    }
}
