@testable import HTTPClient
import Foundation

public extension HTTPResponse {
    static func makeSuccessFake(with data: Data) -> HTTPResponse {
        HTTPResponse(body: data,
                     isSucceeded: true,
                     statusCode: 200,
                     urlResponse: nil)
    }

    static func makeFailureFake(with data: Data) -> HTTPResponse {
        HTTPResponse(body: data,
                     isSucceeded: false,
                     statusCode: 500,
                     urlResponse: nil)
    }
}
