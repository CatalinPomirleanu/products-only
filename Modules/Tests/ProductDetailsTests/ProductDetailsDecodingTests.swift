import Foundation
import Testing

@testable import ProductDetails

@MainActor
struct ProductDetailsDecodingTests {

    /// The fields the model requires, as a JSON fragment without the surrounding braces.
    private let requiredFields = """
    "id": 1,
    "title": "Essence Mascara Lash Princess",
    "description": "A popular mascara.",
    "category": "beauty",
    "price": 9.99,
    "discountPercentage": 10.48,
    "rating": 2.56,
    "stock": 99,
    "tags": ["beauty", "mascara"],
    "thumbnail": "https://cdn.dummyjson.com/thumbnail.webp",
    "images": ["https://cdn.dummyjson.com/1.webp"]
    """

    private func decode<Value: Decodable>(_ type: Value.Type = Value.self, from json: String) throws -> Value {
        try JSONDecoder().decode(Value.self, from: Data(json.utf8))
    }

    private func makeDate(_ iso8601: String) throws -> Date {
        try Date(iso8601, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))
    }

    @Test("""
    Given a full product response
    When it is decoded
    Then every field the screen shows is mapped
    """)
    func fullResponse() throws {
        let json = """
        {
            \(requiredFields),
            "brand": "Essence",
            "sku": "BEA-ESS-ESS-001",
            "weight": 4,
            "dimensions": { "width": 15.14, "height": 13.08, "depth": 22.99 },
            "warrantyInformation": "1 week warranty",
            "shippingInformation": "Ships in 3-5 business days",
            "availabilityStatus": "In Stock",
            "reviews": [
                {
                    "rating": 3,
                    "comment": "Would not recommend!",
                    "date": "2025-04-30T09:41:02.053Z",
                    "reviewerName": "Eleanor Collins",
                    "reviewerEmail": "eleanor.collins@x.dummyjson.com"
                }
            ],
            "returnPolicy": "No return policy",
            "minimumOrderQuantity": 48,
            "meta": {
                "createdAt": "2025-10-09T14:47:01.588Z",
                "updatedAt": "2026-05-23T11:27:41.868Z",
                "barcode": "5784719087687",
                "qrCode": "https://cdn.dummyjson.com/public/qr-code.png"
            }
        }
        """

        let sut: ProductDetails = try decode(from: json)

        let expected = ProductDetails(
            id: 1,
            title: "Essence Mascara Lash Princess",
            description: "A popular mascara.",
            category: "beauty",
            price: 9.99,
            discountPercentage: 10.48,
            rating: 2.56,
            stock: 99,
            tags: ["beauty", "mascara"],
            brand: "Essence",
            sku: "BEA-ESS-ESS-001",
            weight: 4,
            dimensions: ProductDetails.Dimensions(width: 15.14, height: 13.08, depth: 22.99),
            warrantyInformation: "1 week warranty",
            shippingInformation: "Ships in 3-5 business days",
            availabilityStatus: .inStock,
            reviews: [
                ProductDetails.Review(
                    rating: 3,
                    comment: "Would not recommend!",
                    date: try makeDate("2025-04-30T09:41:02.053Z"),
                    reviewerName: "Eleanor Collins"
                )
            ],
            returnPolicy: "No return policy",
            minimumOrderQuantity: 48,
            meta: ProductDetails.Meta(barcode: "5784719087687"),
            thumbnail: try #require(URL(string: "https://cdn.dummyjson.com/thumbnail.webp")),
            images: [try #require(URL(string: "https://cdn.dummyjson.com/1.webp"))]
        )
        #expect(sut == expected)
    }

    @Test("""
    Given a response with only the required fields
    When it is decoded
    Then decoding succeeds and every optional field is nil
    """)
    func requiredFieldsOnly() throws {
        let sut: ProductDetails = try decode(from: "{ \(requiredFields) }")

        #expect(sut.id == 1)
        #expect(sut.brand == nil)
        #expect(sut.sku == nil)
        #expect(sut.weight == nil)
        #expect(sut.dimensions == nil)
        #expect(sut.warrantyInformation == nil)
        #expect(sut.shippingInformation == nil)
        #expect(sut.availabilityStatus == nil)
        #expect(sut.reviews == nil)
        #expect(sut.returnPolicy == nil)
        #expect(sut.minimumOrderQuantity == nil)
        #expect(sut.meta == nil)
    }

    @Test("""
    Given a response without a required field
    When it is decoded
    Then decoding fails
    """)
    func missingRequiredField() {
        #expect(throws: DecodingError.self) {
            let _: ProductDetails = try decode(from: #"{ "id": 1 }"#)
        }
    }

    @Test(
        """
        Given an availability status string
        When it is decoded
        Then known statuses map to their case and any other is kept as sent
        """,
        arguments: [
            ("In Stock", ProductDetails.AvailabilityStatus.inStock),
            ("Low Stock", .lowStock),
            ("Out of Stock", .outOfStock),
            ("Pre-order", .unknown("Pre-order")),
            ("in stock", .unknown("in stock"))
        ]
    )
    func availabilityStatus(rawValue: String, expected: ProductDetails.AvailabilityStatus) throws {
        let sut: [ProductDetails.AvailabilityStatus] = try decode(from: #"["\#(rawValue)"]"#)

        #expect(sut == [expected])
    }

    @Test(
        """
        Given a review with an ISO 8601 date
        When it is decoded
        Then the date is parsed with or without fractional seconds
        """,
        arguments: ["2025-04-30T09:41:02.053Z", "2025-04-30T09:41:02Z"]
    )
    func reviewDate(date: String) throws {
        let sut: ProductDetails.Review = try decode(from: #"{ "rating": 5, "date": "\#(date)" }"#)

        let expected = try makeDate("2025-04-30T09:41:02.000Z")
        let parsed = try #require(sut.date)
        #expect(abs(parsed.timeIntervalSince(expected)) < 1)
    }

    @Test("""
    Given a review with a date that is not ISO 8601
    When it is decoded
    Then the review is kept without a date
    """)
    func reviewInvalidDate() throws {
        let sut: ProductDetails.Review = try decode(from: #"{ "rating": 5, "comment": "Great", "date": "yesterday" }"#)

        #expect(sut == ProductDetails.Review(rating: 5, comment: "Great", date: nil, reviewerName: nil))
    }

    @Test("""
    Given a review with only a rating
    When it is decoded
    Then the comment, date and reviewer name are nil
    """)
    func reviewRatingOnly() throws {
        let sut: ProductDetails.Review = try decode(from: #"{ "rating": 3.5 }"#)

        #expect(sut == ProductDetails.Review(rating: 3.5, comment: nil, date: nil, reviewerName: nil))
    }
}
