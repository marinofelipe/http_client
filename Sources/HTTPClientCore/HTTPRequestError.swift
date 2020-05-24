import Foundation

/// Possible errors for an HTTP response.
public enum HTTPResponseError: Error, Equatable, CustomDebugStringConvertible {
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
