// MARK: - Enum properties

extension Result {
    var value: Success? {
        guard case let .success(value) = self else { return nil }
        return value
    }

    var error: Failure? {
        guard case let .failure(value) = self else { return nil }
        return value
    }
}
