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
