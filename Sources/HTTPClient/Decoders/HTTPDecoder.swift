import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - Abstraction

public protocol HTTPResponseDecoding {
    func decode<ResponseBody: Decodable>(_ data: Data) throws -> ResponseBody
}

// MARK: - Concrete

/// An object that decodes `Data` into a `ResponseBody`.
public struct HTTPResponseDecoder: HTTPResponseDecoding {
    let jsonDecoder: JSONDecoder

    public init(jsonDecoder: JSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }

    /// Decodes `data` into a `ResponseBody`. Generic over the `ResponseBody`
    ///
    /// - Parameter data: The data to decode.
    /// - Returns: `ResponseBody` decoded from `data`.
    /// - Throws: An error if `data` cannot be decoded to a `ResponseBody`.
    public func decode<ResponseBody: Decodable>(_ data: Data) throws -> ResponseBody {
        try jsonDecoder.decode(ResponseBody.self, from: data)
    }
}
