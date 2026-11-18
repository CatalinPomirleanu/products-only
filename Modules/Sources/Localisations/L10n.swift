import Foundation

/// Typed access to every string in `Localizable.xcstrings`, which ships in this module's bundle.
/// Usage: `Text(L10n.List.title)` or `L10n.List.countProducts(12)`.
/// Nested enums follow the first segment of the catalog key; the doc comment on each member is its English value.
public enum L10n {

    // MARK: - List screen

    public enum List {
        /// Products
        public static var title: String { String(localized: "list.title", bundle: .module) }

        /// %lld product / %lld products
        public static func countProducts(_ count: Int) -> String {
            String(localized: "list.count.products \(count)", bundle: .module)
        }

        /// %lld result(s) for “%@”
        public static func countResults(_ count: Int, query: String) -> String {
            String(localized: "list.count.results \(count) \(query)", bundle: .module)
        }

        /// No products match “%@”
        public static func emptyTitle(query: String) -> String {
            String(localized: "list.empty.title \(query)", bundle: .module)
        }

        /// Check the spelling or try a shorter search.
        public static var emptyBody: String { String(localized: "list.empty.body", bundle: .module) }

        /// Couldn’t load products
        public static var errorTitle: String { String(localized: "list.error.title", bundle: .module) }

        /// Check your connection and try again.
        public static var errorBody: String { String(localized: "list.error.body", bundle: .module) }

        /// Try again
        public static var errorRetry: String { String(localized: "list.error.retry", bundle: .module) }

        /// Loading products
        public static var loading: String { String(localized: "list.loading", bundle: .module) }
    }

    public enum Search {
        /// Search products
        public static var placeholder: String { String(localized: "search.placeholder", bundle: .module) }

        /// Clear search
        public static var clear: String { String(localized: "search.clear", bundle: .module) }
    }

    // MARK: - Details screen

    public enum Details {
        /// Back
        public static var back: String { String(localized: "details.back", bundle: .module) }

        /// Back to products
        public static var backToProducts: String { String(localized: "details.backToProducts", bundle: .module) }

        /// Product not found
        public static var notFoundTitle: String { String(localized: "details.notFound.title", bundle: .module) }

        /// About this product
        public static var sectionAbout: String { String(localized: "details.section.about", bundle: .module) }

        /// Delivery and returns
        public static var sectionDelivery: String { String(localized: "details.section.delivery", bundle: .module) }

        /// Specifications
        public static var sectionSpecifications: String {
            String(localized: "details.section.specifications", bundle: .module)
        }

        /// Reviews (%lld)
        public static func sectionReviews(_ count: Int) -> String {
            String(localized: "details.section.reviews \(count)", bundle: .module)
        }

        /// Min. order %lld
        public static func minOrder(_ quantity: Int) -> String {
            String(localized: "details.minOrder \(quantity)", bundle: .module)
        }
    }

    public enum Spec {
        /// Shipping
        public static var shipping: String { String(localized: "spec.shipping", bundle: .module) }

        /// Warranty
        public static var warranty: String { String(localized: "spec.warranty", bundle: .module) }

        /// Returns
        public static var returns: String { String(localized: "spec.returns", bundle: .module) }

        /// Brand
        public static var brand: String { String(localized: "spec.brand", bundle: .module) }

        /// Category
        public static var category: String { String(localized: "spec.category", bundle: .module) }

        /// SKU
        public static var sku: String { String(localized: "spec.sku", bundle: .module) }

        /// Barcode
        public static var barcode: String { String(localized: "spec.barcode", bundle: .module) }

        /// Weight
        public static var weight: String { String(localized: "spec.weight", bundle: .module) }

        /// Size (W × H × D)
        public static var size: String { String(localized: "spec.size", bundle: .module) }

        /// Minimum order
        public static var minimumOrder: String { String(localized: "spec.minimumOrder", bundle: .module) }

        /// %lld unit / %lld units
        public static func units(_ quantity: Int) -> String {
            String(localized: "spec.units \(quantity)", bundle: .module)
        }
    }

    public enum Review {
        /// Anonymous
        public static var anonymous: String { String(localized: "review.anonymous", bundle: .module) }
    }

    public enum Stock {
        /// In stock
        public static var inStock: String { String(localized: "stock.inStock", bundle: .module) }

        /// Low stock
        public static var lowStock: String { String(localized: "stock.lowStock", bundle: .module) }

        /// Low stock · %lld left
        public static func lowStockCount(_ count: Int) -> String {
            String(localized: "stock.lowStockCount \(count)", bundle: .module)
        }

        /// Out of stock
        public static var outOfStock: String { String(localized: "stock.outOfStock", bundle: .module) }
    }

    // MARK: - Accessibility

    public enum A11y {
        /// Rated %@ out of 5
        public static func rating(_ rating: String) -> String {
            String(localized: "a11y.rating \(rating)", bundle: .module)
        }

        /// Rated %@ out of 5, %lld review(s)
        public static func ratingWithReviews(_ rating: String, reviews: Int) -> String {
            String(localized: "a11y.ratingWithReviews \(rating) \(reviews)", bundle: .module)
        }

        /// Now %@, was %@, discount %@
        public static func priceDiscounted(price: String, listPrice: String, discount: String) -> String {
            String(localized: "a11y.price.discounted \(price) \(listPrice) \(discount)", bundle: .module)
        }

        /// %@ images
        public static func gallery(title: String) -> String {
            String(localized: "a11y.gallery \(title)", bundle: .module)
        }

        /// %@, image %lld of %lld
        public static func galleryImage(title: String, position: Int, total: Int) -> String {
            String(localized: "a11y.gallery.image \(title) \(position) \(total)", bundle: .module)
        }

        /// Show image %lld
        public static func galleryShow(position: Int) -> String {
            String(localized: "a11y.gallery.show \(position)", bundle: .module)
        }

        /// %@, no image
        public static func imageMissing(title: String) -> String {
            String(localized: "a11y.image.missing \(title)", bundle: .module)
        }
    }
}
