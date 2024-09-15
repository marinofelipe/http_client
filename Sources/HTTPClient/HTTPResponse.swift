import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPClientCore

public struct HTTPResponse: Equatable {
    let body: Data?
    public let isSucceeded: Bool
    public let statusCode: Int
    public let urlResponse: URLResponse?

    public func successBody() -> Data? {
        guard isSucceeded else { return nil }
        return body
    }

    public func failureBody() -> Data? {
        return isSucceeded ? nil : body
    }
}

// MARK: - CustomDebugStringConvertible

extension HTTPResponse: CustomDebugStringConvertible {
    public var debugDescription: String {
        let prettyPrintedBody: String = successBody()?.prettyPrinted ?? failureBody()?.prettyPrinted ?? ""

        return """
        succeeded: \(isSucceeded)
        status code: \(statusCode)
        body: \(prettyPrintedBody)
        url response: \(String(describing: urlResponse.debugDescription))
        """
    }
}
