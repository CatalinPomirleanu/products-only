import Localisations
import StyleGuide
import SwiftUI

public struct RatingView: View {

    public enum Size: CaseIterable, Sendable {
        case small
        case medium

        var starSize: CGFloat {
            switch self {
            case .small: 14
            case .medium: 18
            }
        }
    }

    @ScaledMetric private var starSize: CGFloat

    private static let starCount = 5
    private let value: Double
    private let count: Int?
    private let showsValue: Bool

    public init(value: Double, count: Int? = nil, size: Size = .medium, showsValue: Bool = true) {
        self.value = min(max(value, 0), Double(Self.starCount))
        self.count = count
        self.showsValue = showsValue
        _starSize = ScaledMetric(wrappedValue: size.starSize, relativeTo: .footnote)
    }

    public var body: some View {
        HStack(spacing: Spacing.s1) {
            stars
            if showsValue {
                Text(CatalogFormat.rating(value))
                    .catalogText(.label)
                    .monospacedDigit()
            }
            if let count {
                Text(verbatim: "(\(count))")
                    .catalogText(.label)
                    .foregroundStyle(Color.catalog.inkMuted)
            }
        }
        .foregroundStyle(Color.catalog.ink)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var stars: some View {
        starRow
            .foregroundStyle(Color.catalog.lineStrong)
            .overlay {
                starRow
                    .foregroundStyle(Color.catalog.ink)
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: starSize * CGFloat(value))
                    }
            }
    }

    private var starRow: some View {
        HStack(spacing: 0) {
            ForEach(0..<Self.starCount, id: \.self) { _ in
                CatalogIcon.star.view(size: starSize)
            }
        }
    }

    private var accessibilityLabel: String {
        let rating = CatalogFormat.rating(value)
        guard let count else { return L10n.A11y.rating(rating) }
        return L10n.A11y.ratingWithReviews(rating, reviews: count)
    }
}

#if DEBUG

#Preview {
    VStack(alignment: .leading, spacing: Spacing.s3) {
        RatingView(value: 4.94, count: 3)
        RatingView(value: 3.5)
        RatingView(value: 0)
        RatingView(value: 5, count: 1)
        RatingView(value: 4.94, size: .small)
        RatingView(value: 2, size: .small, showsValue: false)
    }
    .padding(Spacing.s4)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.catalog.surface)
}

#endif
