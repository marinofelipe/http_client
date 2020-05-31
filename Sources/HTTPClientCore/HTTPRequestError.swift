import Foundation

/// Possible errors for an HTTP response.
public enum HTTPResponseError: Error, CustomDebugStringConvertible {
    case invalidResponse(_ urlResponse: URLResponse)
    case underlying(_ error: URLError)
    case decoding(_ error: DecodingError)
    case unknown

    public var debugDescription: String {
        switch self {
        case let .invalidResponse(urlResponse):
            return "Received response is not a HTTPURLResponse. Response: \(urlResponse)"
        case let .underlying(urlError):
            return "Underlying URL error: \(urlError)"
        case let .decoding(error):
            return "Decoding failed with error: \(error)"
        case .unknown:
            return "Failed by unknown reasons"
        }
    }
}

// MARK: - Equatable

extension HTTPResponseError: Equatable {
    public static func == (lhs: HTTPResponseError, rhs: HTTPResponseError) -> Bool {
        switch lhs {
        case let invalidResponse(lhsURLResponse):
            switch rhs {
            case let invalidResponse(rhsURLResponse):
                return lhsURLResponse === rhsURLResponse
            default: return false
            }
        case let .underlying(lhsURLError):
            switch rhs {
            case let .underlying(rhsURLError):
                return lhsURLError == rhsURLError
            default: return false
            }
        case let .decoding(lhsError):
            switch rhs {
            case let .decoding(rhsError):
                return lhsError.failureReason == rhsError.failureReason
            default: return false
            }
        case .unknown:
            switch rhs {
            case .unknown:
                return true
            default: return false
            }
        }
    }
}
