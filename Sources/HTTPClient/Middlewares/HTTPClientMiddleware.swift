import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPClientCore

public protocol HTTPClientMiddleware {
    func respond(to request: URLRequest)
    func respond(to responseResult: Result<HTTPResponse, HTTPResponseError>)
}
