import Foundation

// MARK: Pretty printed

public extension Data {
    var prettyPrinted: String? {
        guard
            let bodyJSON = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
            let prettyPrintedBodyData = try? JSONSerialization.data(withJSONObject: bodyJSON, options: .prettyPrinted)
            else {
                return String(decoding: self, as: UTF8.self)
        }

        return String(decoding: prettyPrintedBodyData, as: UTF8.self)
    }
}
