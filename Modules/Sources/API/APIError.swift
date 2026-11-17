public enum APIError: Error, Equatable {
    case invalidResponse
    case unacceptableStatusCode(Int)
}
