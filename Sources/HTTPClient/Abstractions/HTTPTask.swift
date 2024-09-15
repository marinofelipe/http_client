import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// An abstract interface to network tasks.
public protocol HTTPTask {
    /// Resumes the task, if it is suspended.
    func resume()
    /// Temporarily suspends a task.
    func suspend()
    /// Cancels the task.
    func cancel()
}

extension URLSessionTask: HTTPTask {}
