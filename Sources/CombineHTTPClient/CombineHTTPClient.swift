import Combine
import HTTPClientCore
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct EmptyBody: Decodable, Equatable { }

/// An HTTP client built on top of Combine and its Foundation conveniences.
public struct CombineHTTPClient {
    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    /// Performs the `request` with generic `S` and `F` for success and failure response bodies respectively.
    ///
    /// *Note*: For empty body responses, or requests that only the result as success matters,
    /// **make sure** you use `EmptyBody` decodable type.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` to be run.
    ///   - validStatusCode: Set of status codes considered successful. `Defaults` to `200..<300`.
    ///   - successDecoder: A decoder for success bodies.
    ///   - failureDecoder: A decoder for failure bodies.
    ///   - completionQueue: The queue in which the returned publisher will emit values on.
    /// - Returns: A publisher that emits `HTTPResponse`s or `HTTPRequestError`s.
    @discardableResult
    public func run<S: Decodable, F: Decodable>(_ request: URLRequest,
                                                validStatusCode: Set<Int> = .defaultSuccessfulStatusCodes,
                                                successDecoder: JSONDecoder = .init(),
                                                failureDecoder: JSONDecoder = .init(),
                                                receiveOn completionQueue: DispatchQueue) -> AnyPublisher<HTTPResponse<S, F>, HTTPResponseError> {
        session.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> HTTPResponse<S, F> in
                guard let httpResponse = response as? HTTPURLResponse else { throw HTTPResponseError.invalidResponse(response) }
                return try HTTPResponse<S, F>(body: data,
                                              decoder: successDecoder,
                                              validStatusCode: validStatusCode,
                                              statusCode: httpResponse.statusCode,
                                              urlResponse: httpResponse)
            }
        .mapError { error -> HTTPResponseError in
            if let urlError = error as? URLError {
                return .underlying(urlError)
            } else if let decodingError = error as? DecodingError {
                return .decoding(decodingError)
            }
            return .unknown
        }
        .receive(on: completionQueue)
        .eraseToAnyPublisher()
    }
}
