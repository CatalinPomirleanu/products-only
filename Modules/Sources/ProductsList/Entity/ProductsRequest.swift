import API
import Foundation

public enum ProductsRequest: Request, Equatable {
    case page(limit: Int, skip: Int)
    case search(query: String, limit: Int, skip: Int)

    public var path: String {
        switch self {
        case .page: "/products"
        case .search: "/products/search"
        }
    }

    public var queryItems: [URLQueryItem] {
        switch self {
        case .search(let query, let limit, let skip):
            [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "skip", value: String(skip))
            ]

        case .page(let limit, let skip):
            [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "skip", value: String(skip))
            ]
        }
    }
}
