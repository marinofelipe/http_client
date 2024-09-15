import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - Decoded

extension Optional where Wrapped == Data {

    enum Error: Swift.Error {
        case nilWrappedValue
    }

    public func decoded<T: Decodable>(as: T.Type,
                                      using decoder: HTTPResponseDecoding) throws -> T {
        guard case let data? = self else { throw Error.nilWrappedValue }
        return try decoder.decode(data)
    }
}
