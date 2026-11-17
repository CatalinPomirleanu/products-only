import Foundation

public enum APIError: Error, Equatable {
    case decoding(String)
    case invalidResponse
    case invalidURL
    case transport(URLError)
    case unacceptableStatusCode(Int)
}
