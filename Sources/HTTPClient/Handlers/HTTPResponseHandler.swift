import Foundation

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
                throw HTTPRequestError.underlying(urlError)
            }

            // TODO: could also return response for logger to perform side effect

            throw HTTPRequestError.unknown
        }

        guard let response = params.response as? HTTPURLResponse else {
            if let response = params.response {
                throw HTTPRequestError.invalidResponse(response)
            } else {
                throw HTTPRequestError.unknown
            }
        }

        guard successfulStatusCodes.contains(response.statusCode) else {
            return (isSucceeded: false, statusCode: response.statusCode)
        }

        return (isSucceeded: true, statusCode: response.statusCode)
    }
}

// MARK: - Default successful status codes

public extension Set where Element == Int {
    static var defaultSuccessfulStatusCodes: Set<Int> = Set(200..<300)
}
