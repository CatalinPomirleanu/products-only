import Foundation

public nonisolated struct Product: Decodable, Equatable, Identifiable, Sendable {

    public enum AvailabilityStatus: String, Decodable, Equatable, Sendable {
        case inStock = "In Stock"
        case lowStock = "Low Stock"
        case outOfStock = "Out of Stock"
        case unknown

        public init(from decoder: any Decoder) throws {
            let rawValue = try decoder.singleValueContainer().decode(String.self)
            self = AvailabilityStatus(rawValue: rawValue) ?? .unknown
        }
    }

    public let id: Int
    public let title: String
    public let category: String
    public let price: Double
    public let discountPercentage: Double
    public let rating: Double
    public let stock: Int
    public let availabilityStatus: AvailabilityStatus?
    public let brand: String?
    public let thumbnail: URL

    public init(
        id: Int,
        title: String,
        category: String,
        price: Double,
        discountPercentage: Double,
        rating: Double,
        stock: Int,
        availabilityStatus: AvailabilityStatus?,
        brand: String?,
        thumbnail: URL
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.price = price
        self.discountPercentage = discountPercentage
        self.rating = rating
        self.stock = stock
        self.availabilityStatus = availabilityStatus
        self.brand = brand
        self.thumbnail = thumbnail
    }
}

#if DEBUG

extension Product {
    static func mock(id: Int) -> Self {
        Product(
            id: id,
            title: "Product \(id)",
            category: "beauty",
            price: 9.99,
            discountPercentage: 7.17,
            rating: 4.5,
            stock: 5,
            availabilityStatus: .inStock,
            brand: "Essence",
            thumbnail: URL(filePath: "/thumbnail-\(id).png")
        )
    }
}

#endif
