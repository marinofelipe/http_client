import Logging
import struct Foundation.URLRequest
import HTTPClientCore

public final class LoggerMiddleware: HTTPClientMiddleware {

    private let logger = Logger(label: "com.HTTPClient.HTTPClientMiddleware.logger")

    public init() {}

    public func respond(to request: URLRequest) {
        let prettyPrintedBody = request.httpBody?.prettyPrinted ?? "nil"

        logger.error("""

        ***   HTTP Request --->>>>   ***
        method: \(String(describing: request.httpMethod));
        url: \(String(describing: request.url?.absoluteString));
        headers: \(String(describing: request.allHTTPHeaderFields));
        body: \(prettyPrintedBody);

        """)
    }

    public func respond(to responseResult: Result<HTTPResponse, Error>) {
        let printStatement: String
        do {
            let response = try responseResult.get()
            printStatement = response.debugDescription
        } catch {
            printStatement = error.localizedDescription
        }

        logger.error("""

        ***   <<<--- HTTP Response   ***
        \(printStatement)

        """)
    }
}
