// MARK: - Enum properties

extension Result {
    var success: Success? {
        guard case let .success(value) = self else { return nil }
        return value
    }

    var failure: Failure? {
        guard case let .failure(value) = self else { return nil }
        return value
    }
}
