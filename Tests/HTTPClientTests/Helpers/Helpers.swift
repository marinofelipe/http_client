import Foundation

enum Helpers {
    static func makeURLResponse(statusCode: Int) -> URLResponse {
        HTTPURLResponse(url: URL(string: "https://example.com/some-path")!,
                        statusCode: statusCode,
                        httpVersion: "HTTP/1.1",
                        headerFields: [:])!
    }
}
