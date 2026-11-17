import Foundation

public nonisolated struct ProductsPage: Decodable, Equatable, Sendable {

    public let products: [Product]
    public let total: Int
    public let skip: Int
    public let limit: Int

    public init(products: [Product], total: Int, skip: Int, limit: Int) {
        self.products = products
        self.total = total
        self.skip = skip
        self.limit = limit
    }
}

#if DEBUG

extension ProductsPage {
    static func mock(ids: ClosedRange<Int>?, total: Int, skip: Int = 0) -> Self {
        let products = (ids.map(Array.init) ?? []).map(Product.mock)
        return ProductsPage(products: products, total: total, skip: skip, limit: products.count)
    }
}

#endif
