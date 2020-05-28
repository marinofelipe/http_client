/*
 Builder Pattern - `Creational Pattern` that focus on constructing complex objects step by step.
 It encapsulates the object creation and exposes a simple API for the user, without exposing implementation details or introducing mutability.

 More on wikipedia: https://en.wikipedia.org/wiki/Builder_pattern
 */

import Foundation

// MARK: - Error

public enum HTTPRequestBuilderError: Error, CustomDebugStringConvertible {
    case invalidURLComponents

    public var debugDescription: String {
        "Invalid URL components when building request. Double-check if host, path (begins with /), and other parameters are valid."
    }
}

// MARK: - Builder

public final class HTTPRequestBuilder {

    // MARK: Builder properties

    let scheme: HTTPRequestScheme
    let host: String
    let headers: [String: String]

    // MARK: Request properties

    private var method: HTTPRequestMethod = .get
    private var timeoutInterval: TimeInterval = 10
    private var body: Data?
    private var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    private var allHeaders = [String: String]()
    private var urlComponents = URLComponents()

    // MARK: Init

    public init(scheme: HTTPRequestScheme, host: String, headers: [String: String] = [:]) {
        self.scheme = scheme
        self.host = host
        self.headers = headers
        self.allHeaders = headers
        self.urlComponents.host = host
        self.urlComponents.scheme = scheme.rawValue
    }

    // MARK: API

    @discardableResult
    public func path(_ path: String) -> HTTPRequestBuilder {
        urlComponents.path = path
        return self
    }

    @discardableResult
    public func method(_ method: HTTPRequestMethod) -> HTTPRequestBuilder {
        self.method = method
        return self
    }

    @discardableResult
    public func additionalHeaders(_ additionalHeaders: [String: String]) -> HTTPRequestBuilder {
        self.allHeaders = allHeaders.merging(additionalHeaders) { headers, _ -> String in
            headers
        }
        return self
    }

    @discardableResult
    public func timeoutInterval(_ timeoutInterval: TimeInterval) -> HTTPRequestBuilder {
        self.timeoutInterval = timeoutInterval
        return self
    }

    @discardableResult
    public func body<T>(_ encodableBody: T, encoder: JSONEncoder = .init()) throws -> HTTPRequestBuilder where T: Encodable {
        self.body = try encoder.encode(encodableBody)
        return self
    }

    /// Set the cache policy for the request.
    ///
    /// *Note*: Be **aware** that reloadIgnoringLocalAndRemoteCacheData and .reloadRevalidatingCacheData are not implemented by Apple,
    /// and using them lead to unexpected set cachePolicy.
    ///
    /// - Parameter cachePolicy: The cache policy for the request. Defaults to `.useProtocolCachePolicy`
    @discardableResult
    public func cachePolicy(_ cachePolicy: URLRequest.CachePolicy) -> HTTPRequestBuilder {
        self.cachePolicy = cachePolicy
        return self
    }

    @discardableResult
    public func queryItems(_ queryItems: [URLQueryItem]) -> HTTPRequestBuilder {
        urlComponents.queryItems = queryItems
        return self
    }

    public func build() throws -> URLRequest {
        try makeUrlRequest()
    }

    // MARK: Private

    /// The `URLRequest` to be built.
    private func makeUrlRequest() throws  -> URLRequest {
        guard let url = urlComponents.url else {
            throw HTTPRequestBuilderError.invalidURLComponents
        }

        var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        urlRequest.httpMethod = method.rawValue
        for (key, value) in allHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        urlRequest.httpBody = body

        return urlRequest
    }

    /// Cleanup all states, reseting the builder to its initial constructed state.
    ///
    /// *Note*: You can use this method to reuse the builder for more than on requests.
    @discardableResult
    func clean() -> HTTPRequestBuilder {
        method = .get
        timeoutInterval = 10
        body = nil
        cachePolicy = .useProtocolCachePolicy

        // Reset all headers to default headers
        allHeaders = headers

        urlComponents = URLComponents()
        urlComponents.host = host
        urlComponents.scheme = scheme.rawValue

        return self
    }
}
