import Localisations
import StyleGuide
import SwiftUI

public struct ProductCardView: View {
    public struct Product: Equatable, Sendable {
        let kicker: String
        let title: String
        let rating: Double?
        let price: Double
        let discountPercentage: Double
        let availabilityStatus: BadgeAvailabilityStatus?
        let currencyCode: String

        public init(
            kicker: String,
            title: String,
            rating: Double? = nil,
            price: Double,
            discountPercentage: Double = 0,
            availabilityStatus: BadgeAvailabilityStatus? = nil,
            currencyCode: String = "USD"
        ) {
            self.kicker = kicker
            self.title = title
            self.rating = rating
            self.price = price
            self.discountPercentage = discountPercentage
            self.availabilityStatus = availabilityStatus
            self.currencyCode = currencyCode
        }
    }

    public enum Content: Equatable, Sendable {
        case loading
        case product(Product)
    }

    private let content: Content
    private let thumbnail: Image?
    private let onAction: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPulsing = false

    public init(content: Content, thumbnail: Image? = nil, onAction: @escaping () -> Void) {
        self.content = content
        self.thumbnail = thumbnail
        self.onAction = onAction
    }

    public var body: some View {
        switch content {
        case .loading:
            skeleton

        case .product(let product):
            Button {
                onAction()
            } label: {
                makeCard(product)
            }
            .buttonStyle(ProductCardViewStyle())
        }
    }

    // MARK: - Loaded

    private func makeCard(_ product: Product) -> some View {
        HStack(alignment: .top, spacing: Spacing.s3) {
            ImageWellView(image: thumbnail, inset: Spacing.s1)
                .frame(width: Tokens.Size.thumbSize, height: Tokens.Size.thumbSize)
                .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
            VStack(alignment: .leading, spacing: Spacing.s1) {
                Text(product.kicker)
                    .catalogText(.label)
                    .foregroundStyle(Color.catalog.inkMuted)
                    .lineLimit(1)
                Text(product.title)
                    .catalogText(.bodyStrong)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                if let rating = product.rating {
                    RatingView(value: rating, size: .small)
                }
                Spacer(minLength: 0)
                makeFoot(product)
                    .padding(.top, 2)
            }
            .foregroundStyle(Color.catalog.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func makeFoot(_ product: Product) -> some View {
        let price = PriceView(
            price: product.price,
            discountPercentage: product.discountPercentage,
            currencyCode: product.currencyCode
        )

        return ViewThatFits(in: .horizontal) {
            HStack(spacing: Spacing.s2) {
                price
                Spacer(minLength: 0)
                makeBadge(product)
            }
            VStack(alignment: .leading, spacing: Spacing.s1) {
                price
                makeBadge(product)
            }
        }
    }

    @ViewBuilder
    private func makeBadge(_ product: Product) -> some View {
        if let status = product.availabilityStatus {
            BadgeView(availabilityStatus: status)
        }
    }

    private var skeleton: some View {
        HStack(alignment: .top, spacing: Spacing.s3) {
            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                .frame(width: Tokens.Size.thumbSize, height: Tokens.Size.thumbSize)
            GeometryReader { proxy in
                VStack(alignment: .leading, spacing: Spacing.s2) {
                    makeBar(width: proxy.size.width * 0.32, height: 12)
                    makeBar(width: proxy.size.width * 0.86, height: 16)
                    makeBar(width: proxy.size.width * 0.44, height: 12)
                    makeBar(width: proxy.size.width * 0.28, height: 16)
                        .padding(.top, 6)
                }
                .padding(.top, Spacing.s1)
            }
            .frame(height: Tokens.Size.thumbSize)
        }
        .foregroundStyle(Color.catalog.surfaceSunken)
        .modifier(ProductCardViewChrome(isPressed: false))
        .opacity(isPulsing ? 0.55 : 1)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isPulsing)
        .onAppear { isPulsing = !reduceMotion }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.List.loading)
    }

    private func makeBar(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: Tokens.Radius.sm)
            .frame(width: width, height: height)
    }
}

private struct ProductCardViewStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(ProductCardViewChrome(isPressed: configuration.isPressed))
    }
}

private struct ProductCardViewChrome: ViewModifier {

    let isPressed: Bool

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: Tokens.Radius.lg)

        content
            .padding(Spacing.s3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isPressed ? Color.catalog.surfaceSunken : Color.catalog.surfaceRaised, in: shape)
            .overlay {
                shape.strokeBorder(Color.catalog.line, lineWidth: 1)
            }
            .contentShape(shape)
    }
}

#if DEBUG

#Preview {
    ScrollView {
        VStack(spacing: Spacing.s3) {
            ProductCardView(
                content: .product(
                    ProductCardView.Product(
                        kicker: "Essence",
                        title: "Essence Mascara Lash Princess",
                        rating: 4.94,
                        price: 9.99,
                        discountPercentage: 7.17,
                        availabilityStatus: .lowStock(5)
                    )
                ),
                thumbnail: Image(systemName: "shippingbox.fill")
            ) { }
            ProductCardView(
                content: .product(
                    ProductCardView.Product(
                        kicker: "Home decoration",
                        title: "A product with a very long title that has to clamp at two lines in the card",
                        rating: 3.2,
                        price: 1899.99,
                        discountPercentage: 18.5,
                        availabilityStatus: .outOfStock
                    )
                )
            ) { }
            ProductCardView(
                content: .product(
                    ProductCardView.Product(
                        kicker: "Groceries",
                        title: "Apple",
                        price: 1.99,
                        availabilityStatus: .inStock
                    )
                )
            ) { }
            ProductCardView(content: .loading) { }
        }
        .padding(Spacing.s4)
    }
    .background(Color.catalog.surface)
}

#endif
