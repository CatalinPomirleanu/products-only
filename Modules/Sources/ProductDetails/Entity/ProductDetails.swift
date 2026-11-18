import Foundation

public nonisolated struct ProductDetails: Decodable, Equatable, Identifiable, Sendable {

    public enum AvailabilityStatus: Decodable, Equatable, Sendable {
        case inStock
        case lowStock
        case outOfStock
        case unknown(String)

        public init(rawValue: String) {
            switch rawValue {
            case "In Stock": self = .inStock
            case "Low Stock": self = .lowStock
            case "Out of Stock": self = .outOfStock
            default: self = .unknown(rawValue)
            }
        }

        public init(from decoder: any Decoder) throws {
            self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
        }
    }

    public struct Dimensions: Decodable, Equatable, Sendable {
        public let width: Double
        public let height: Double
        public let depth: Double

        public init(width: Double, height: Double, depth: Double) {
            self.width = width
            self.height = height
            self.depth = depth
        }
    }

    public struct Meta: Decodable, Equatable, Sendable {
        public let barcode: String?

        public init(barcode: String?) {
            self.barcode = barcode
        }
    }

    public struct Review: Decodable, Equatable, Sendable {
        private enum CodingKeys: String, CodingKey {
            case rating, comment, date, reviewerName
        }

        public let rating: Double
        public let comment: String?
        public let date: Date?
        public let reviewerName: String?

        public init(rating: Double, comment: String?, date: Date?, reviewerName: String?) {
            self.rating = rating
            self.comment = comment
            self.date = date
            self.reviewerName = reviewerName
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            rating = try container.decode(Double.self, forKey: .rating)
            comment = try container.decodeIfPresent(String.self, forKey: .comment)
            reviewerName = try container.decodeIfPresent(String.self, forKey: .reviewerName)
            date = try container.decodeIfPresent(String.self, forKey: .date).flatMap { string in
                (try? Date(string, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)))
                    ?? (try? Date(string, strategy: Date.ISO8601FormatStyle()))
            }
        }
    }

    public let id: Int
    public let title: String
    public let description: String
    public let category: String
    public let price: Double
    public let discountPercentage: Double
    public let rating: Double
    public let stock: Int
    public let tags: [String]
    public let brand: String?
    public let sku: String?
    public let weight: Double?
    public let dimensions: Dimensions?
    public let warrantyInformation: String?
    public let shippingInformation: String?
    public let availabilityStatus: AvailabilityStatus?
    public let reviews: [Review]?
    public let returnPolicy: String?
    public let minimumOrderQuantity: Int?
    public let meta: Meta?
    public let thumbnail: URL
    public let images: [URL]

    public init(
        id: Int,
        title: String,
        description: String,
        category: String,
        price: Double,
        discountPercentage: Double,
        rating: Double,
        stock: Int,
        tags: [String],
        brand: String?,
        sku: String? = nil,
        weight: Double? = nil,
        dimensions: Dimensions? = nil,
        warrantyInformation: String? = nil,
        shippingInformation: String? = nil,
        availabilityStatus: AvailabilityStatus? = nil,
        reviews: [Review]? = nil,
        returnPolicy: String? = nil,
        minimumOrderQuantity: Int? = nil,
        meta: Meta? = nil,
        thumbnail: URL,
        images: [URL]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.price = price
        self.discountPercentage = discountPercentage
        self.rating = rating
        self.stock = stock
        self.tags = tags
        self.brand = brand
        self.sku = sku
        self.weight = weight
        self.dimensions = dimensions
        self.warrantyInformation = warrantyInformation
        self.shippingInformation = shippingInformation
        self.availabilityStatus = availabilityStatus
        self.reviews = reviews
        self.returnPolicy = returnPolicy
        self.minimumOrderQuantity = minimumOrderQuantity
        self.meta = meta
        self.thumbnail = thumbnail
        self.images = images
    }
}

#if DEBUG

nonisolated extension ProductDetails {
    static func mock(id: Int) -> Self {
        ProductDetails(
            id: id,
            title: "Product \(id)",
            description: "Description \(id)",
            category: "beauty",
            price: 9.99,
            discountPercentage: 7.17,
            rating: 4.5,
            stock: 5,
            tags: ["beauty", "mascara"],
            brand: "Essence",
            sku: "SKU-\(id)",
            weight: 4,
            dimensions: Dimensions(width: 15.14, height: 13.08, depth: 22.99),
            warrantyInformation: "1 week warranty",
            shippingInformation: "Ships in 3-5 business days",
            availabilityStatus: .lowStock,
            reviews: [
                Review(
                    rating: 4,
                    comment: "Very satisfied!",
                    date: Date(timeIntervalSince1970: 1_746_006_062),
                    reviewerName: "Lucas Gordon"
                )
            ],
            returnPolicy: "No return policy",
            minimumOrderQuantity: 48,
            meta: Meta(barcode: "5784719087687"),
            thumbnail: URL(filePath: "/thumbnail-\(id).png"),
            images: [URL(filePath: "/image-\(id).png")]
        )
    }
}

#endif
