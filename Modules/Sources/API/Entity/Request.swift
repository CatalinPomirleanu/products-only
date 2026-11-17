import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public protocol Request: Sendable {

    var baseUrl: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
}

extension Request {

    public var baseUrl: String { "https://dummyjson.com" }
    public var method: HTTPMethod { .get }
    public var headers: [String: String] { [:] }
    public var queryItems: [URLQueryItem] { [] }
}

extension Request {

    func urlRequest(timeoutInterval: TimeInterval) throws(APIError) -> URLRequest {
        guard var components = URLComponents(string: baseUrl) else {
            throw .invalidURL
        }

        let basePath = components.path.hasSuffix("/") ? String(components.path.dropLast()) : components.path
        components.path = basePath + (path.isEmpty || path.hasPrefix("/") ? path : "/" + path)

        if !queryItems.isEmpty {
            components.queryItems = queryItems
            components.percentEncodedQuery = components.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B")
        }

        guard components.scheme != nil, components.host?.isEmpty == false, let url = components.url else {
            throw .invalidURL
        }

        var urlRequest = URLRequest(url: url, timeoutInterval: timeoutInterval)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
}
