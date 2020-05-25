public struct FakeResponseBody: Codable, Equatable {
    public let id: Int
    public let description: String

    public init(id: Int, description: String) {
        self.id = id
        self.description = description
    }
}
