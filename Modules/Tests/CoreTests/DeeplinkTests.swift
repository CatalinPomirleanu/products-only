import Foundation
import Testing

import Core

struct DeeplinkTests {

    @Test("""
    Given a supported URL
    When parsing it
    Then the matching deeplink is returned
    """, arguments: [
        ("productsonly://products", Deeplink.productsList),
        ("productsonly://products/", Deeplink.productsList),
        ("PRODUCTSONLY://products", Deeplink.productsList),
        ("productsonly://PrOdUcTs/42", Deeplink.productDetails(id: 42)),
        ("productsonly://products/42", Deeplink.productDetails(id: 42)),
        ("productsonly://products/42?source=push", Deeplink.productDetails(id: 42))
    ])
    func supported(url: String, expected: Deeplink) throws {
        let sut = Deeplink(url: try #require(URL(string: url)))

        #expect(sut == expected)
    }

    @Test("""
    Given an unsupported URL
    When parsing it
    Then no deeplink is returned
    """, arguments: [
        "https://products/42",
        "productsonly://",
        "productsonly://unknown",
        "productsonly://products/0",
        "productsonly://products/-1",
        "productsonly://products/abc",
        "productsonly://products/42/reviews"
    ])
    func unsupported(url: String) throws {
        let sut = Deeplink(url: try #require(URL(string: url)))

        #expect(sut == nil)
    }
}
