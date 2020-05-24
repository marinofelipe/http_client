import Foundation

/// The HTTP request methods that can be performed in network requests.
public enum HTTPRequestMethod: String {
    case get = "GET"
    case delete = "DELETE"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

/// Possible schemes for an HTTP(S) request.
public enum HTTPRequestScheme: String {
    case http
    case https
}

/// Possible errors for an HTTP request.
public enum HTTPRequestError: Error, Equatable, CustomDebugStringConvertible {
    case invalidResponse(_ urlResponse: URLResponse)
    case underlying(_ error: URLError)
    case unknown

    public var debugDescription: String {
        switch self {
        case let .invalidResponse(urlResponse):
            return "Received response is not a HTTPURLResponse. Response: \(urlResponse)"
        case let .underlying(urlError):
            return "Underlying URL error: \(urlError)"
        case .unknown:
            return "Failed by unknown reasons"
        }
    }
}
