import API
import Foundation

public struct ProductDetailsRequest: Request, Equatable {
    let id: Int

    public var path: String {
        "/products/\(id)"
    }
}
