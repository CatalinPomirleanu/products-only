import Localisations
import StyleGuide
import SwiftUI

public struct PriceView: View {

    public enum Size: CaseIterable, Sendable {
        case medium
        case large
    }

    private let size: Size
    private let now: String
    private let was: String?
    private let discount: String?

    public init(price: Double, discountPercentage: Double = 0, size: Size = .medium, currencyCode: String = "USD") {
        self.size = size
        if CatalogFormat.hasDiscount(discountPercentage) {
            let paid = CatalogFormat.discounted(price: price, discountPercentage: discountPercentage)
            now = CatalogFormat.price(paid, currencyCode: currencyCode)
            was = CatalogFormat.price(price, currencyCode: currencyCode)
            discount = CatalogFormat.percent(discountPercentage)
        } else {
            now = CatalogFormat.price(price, currencyCode: currencyCode)
            was = nil
            discount = nil
        }
    }

    public var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.s2) {
                nowText
                reduction
            }
            VStack(alignment: .leading, spacing: 2) {
                nowText
                reduction
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var nowText: some View {
        Text(now)
            .catalogText(size == .large ? .display : .bodyStrong)
            .monospacedDigit()
            .foregroundStyle(Color.catalog.ink)
            .lineLimit(1)
    }

    @ViewBuilder private var reduction: some View {
        if let was, let discount {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.s2) {
                Text(was)
                    .catalogText(size == .large ? .label : .caption)
                    .monospacedDigit()
                    .strikethrough()
                    .foregroundStyle(Color.catalog.inkMuted)
                    .lineLimit(1)
                Text(discount)
                    .catalogText(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.catalog.onSticker)
                    .lineLimit(1)
                    .padding(.horizontal, Spacing.s2)
                    .frame(minHeight: size == .large ? 24 : 20)
                    .background(Color.catalog.sticker, in: Capsule())
            }
        }
    }

    private var accessibilityLabel: String {
        guard let was, let discount else { return now }
        return L10n.A11y.priceDiscounted(price: now, listPrice: was, discount: discount)
    }
}

#if DEBUG

#Preview {
    VStack(alignment: .leading, spacing: Spacing.s3) {
        PriceView(price: 9.99, discountPercentage: 7.17)
        PriceView(price: 9.99)
        PriceView(price: 9.99, discountPercentage: 0.4)
        PriceView(price: 1899.99, discountPercentage: 18.5, size: .large)
        PriceView(price: 1899.99, size: .large)
        PriceView(price: 1899.99, discountPercentage: 18.5, size: .large)
            .frame(width: 220, alignment: .leading)
    }
    .padding(Spacing.s4)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.catalog.surface)
}

#endif
