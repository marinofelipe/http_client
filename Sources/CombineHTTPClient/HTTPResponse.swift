import Foundation

/// Data for a HTTP responses that might contain `both success and failure Decodable bodies`.
/// - note: Failure bodies are useful for when mapping specific error codes, messages or more complex error payloads returned by the API.
/// e.g. A POST request sent to submit a form, where one of the fields have invalid content. The API returns a body containing the
/// user facing localized message and the invalid field to make the life easier for the FE clients.
public struct HTTPResponse<S: Decodable & Equatable, F: Decodable & Equatable>: Equatable {
    public enum Value: Equatable {
        case success(S)
        case failure(F)
    }

    public let value: Value
    public let statusCode: Int
    public let urlResponse: URLResponse

    public var isSuccess: Bool {
        guard case .success = value else { return false }
        return true
    }

    init(body: Data, decoder: JSONDecoder, validStatusCode: Set<Int>, statusCode: Int, urlResponse: URLResponse) throws {
        if validStatusCode.contains(statusCode) {
            if S.self is EmptyBody.Type {
                value = .success((EmptyBody() as! S))
            } else {
                let decodedValue = try decoder.decode(S.self, from: body)
                value = .success(decodedValue)
            }
        } else {
            if F.self is EmptyBody.Type {
                value = .failure((EmptyBody() as! F))
            } else {
                let decodedValue = try decoder.decode(F.self, from: body)
                value = .failure(decodedValue)
            }
        }

        self.statusCode = statusCode
        self.urlResponse = urlResponse
    }
}

extension HTTPResponse: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        succeeded: \(isSuccess)
        status code: \(statusCode)
        decoded value: \(value)
        url response: \(String(describing: urlResponse.debugDescription))
        """
    }
}
