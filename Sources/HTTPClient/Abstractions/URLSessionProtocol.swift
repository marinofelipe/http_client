import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol URLSessionProtocol {
    var delegateQueue: OperationQueue { get }

    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}
