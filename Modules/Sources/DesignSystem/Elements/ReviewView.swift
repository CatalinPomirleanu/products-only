import Localisations
import StyleGuide
import SwiftUI

public struct ReviewView: View {

    private let reviewerName: String
    private let date: String?
    private let rating: Double
    private let comment: String?
    private let showsSeparator: Bool

    public init(
        reviewerName: String?,
        date: Date? = nil,
        rating: Double,
        comment: String? = nil,
        showsSeparator: Bool = false
    ) {
        var dateStyle = Date.FormatStyle.dateTime
        dateStyle.timeZone = .gmt

        self.reviewerName = if let reviewerName, !reviewerName.isEmpty { reviewerName } else { L10n.Review.anonymous }
        self.date = date?.formatted(dateStyle.day().month(.abbreviated).year())
        self.rating = rating
        self.comment = if let comment, !comment.isEmpty { comment } else { nil }
        self.showsSeparator = showsSeparator
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s1) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.s3) {
                Text(reviewerName)
                    .catalogText(.bodyStrong)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let date {
                    Text(date)
                        .catalogText(.caption)
                        .foregroundStyle(Color.catalog.inkMuted)
                        .lineLimit(1)
                }
            }
            RatingView(value: rating, size: .small, showsValue: false)
            if let comment {
                Text(comment)
                    .catalogText(.body)
                    .padding(.top, Spacing.s1)
            }
        }
        .foregroundStyle(Color.catalog.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.s3)
        .overlay(alignment: .top) {
            if showsSeparator {
                Color.catalog.line
                    .frame(height: 1)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        ReviewView(reviewerName: "John Doe", date: Date(), rating: 2, comment: "Very unhappy with my purchase!")
        ReviewView(
            reviewerName: "Scarlett Wright",
            date: Date(),
            rating: 5,
            comment: "Very satisfied! It arrived early, the packaging was intact and it does what it says.",
            showsSeparator: true
        )
        ReviewView(reviewerName: nil, rating: 3.5, showsSeparator: true)
    }
    .padding(.horizontal, Spacing.s4)
    .background(Color.catalog.surfaceRaised, in: RoundedRectangle(cornerRadius: Tokens.Radius.lg))
    .padding(Spacing.s4)
    .background(Color.catalog.surface)
}

#endif
