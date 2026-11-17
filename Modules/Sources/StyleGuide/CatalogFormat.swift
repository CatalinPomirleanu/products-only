import Foundation

public enum CatalogFormat {
    /// `price` is the list price; the price paid is the list price less the discount, rounded to cents.
    public static func discounted(price: Double, discountPercentage: Double) -> Double {
        (price * (100 - discountPercentage)).rounded() / 100
    }

    /// 9.27 -> "$9.27". The API carries no currency; USD is the default.
    public static func price(_ value: Double, currencyCode: String = "USD") -> String {
        value.formatted(.currency(code: currencyCode))
    }

    /// The sticker appears only when the discount rounds to 1% or more.
    public static func hasDiscount(_ discountPercentage: Double) -> Bool {
        discountPercentage.rounded() >= 1
    }

    /// 7.17 -> "−7%" (a true minus sign, whole percent).
    public static func percent(_ discountPercentage: Double) -> String {
        "\u{2212}\(Int(discountPercentage.rounded()))%"
    }

    /// 4.94 -> "4.9"
    public static func rating(_ value: Double) -> String {
        String(format: "%.1f", (value * 10).rounded() / 10)
    }

    /// "home-decoration" -> "Home decoration"
    public static func category(_ slug: String) -> String {
        let words = slug.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
        return words.prefix(1).uppercased() + words.dropFirst()
    }

    /// W × H × D, no unit: the API gives none.
    public static func dimensions(width: Double, height: Double, depth: Double) -> String {
        [width, height, depth].map { $0.formatted(.number.precision(.fractionLength(0...2))) }.joined(separator: " \u{00D7} ")
    }

    /// "Low Stock" + 5 -> "Low stock · 5 left"; other statuses are re-cased to sentence case.
    public static func stockLabel(status: String, stock: Int?) -> String {
        let lower = status.lowercased()
        let label = lower.prefix(1).uppercased() + lower.dropFirst()
        if lower == "low stock", let stock, stock > 0 { return "\(label) \u{00B7} \(stock) left" }
        return label
    }
}
