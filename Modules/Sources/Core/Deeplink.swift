import Foundation

public enum Deeplink: Equatable, Sendable {
    case productDetails(id: Int)
    case productsList

    public static let scheme = "productsonly"

    public init?(url: URL) {
        guard url.scheme?.lowercased() == Self.scheme, url.host()?.lowercased() == "products" else {
            return nil
        }
        let components = url.pathComponents.filter { $0 != "/" }
        if components.isEmpty {
            self = .productsList
        } else if components.count == 1, let id = Int(components[0]), id > 0 {
            self = .productDetails(id: id)
        } else {
            return nil
        }
    }
}
