import Localisations
import StyleGuide
import SwiftUI

public enum BadgeAvailabilityStatus: Equatable {
    case general(String)
    case inStock
    case lowStock(Int)
    case outOfStock
}

public struct BadgeView: View {
    public enum Tone: CaseIterable, Sendable {
        case neutral
        case positive
        case caution
        case danger
    }

    private let text: String
    private let tone: Tone
    private let showsDot: Bool

    public init(text: String, tone: Tone = .neutral, showsDot: Bool = false) {
        self.text = text
        self.tone = tone
        self.showsDot = showsDot
    }

    public init(availabilityStatus: BadgeAvailabilityStatus) {
        switch availabilityStatus {
        case .general(let text):
            self.init(text: text, tone: .neutral, showsDot: true)

        case .inStock:
            self.init(text: L10n.Stock.inStock, tone: .positive, showsDot: true)

        case .lowStock(let stock):
            let text = if stock > 0 { L10n.Stock.lowStockCount(stock) } else { L10n.Stock.lowStock }
            self.init(text: text, tone: .caution, showsDot: true)

        case .outOfStock:
            self.init(text: L10n.Stock.outOfStock, tone: .danger, showsDot: true)
        }
    }

    public var body: some View {
        HStack(spacing: Spacing.s1) {
            if showsDot {
                Circle()
                    .frame(width: 6, height: 6)
                    .accessibilityHidden(true)
            }
            Text(text)
                .catalogText(.label)
                .lineLimit(1)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, Spacing.s2)
        .padding(.vertical, 2)
        .background(background, in: RoundedRectangle(cornerRadius: Tokens.Radius.sm))
    }

    private var foreground: Color {
        switch tone {
        case .neutral: Color.catalog.ink
        case .positive: Color.catalog.positive
        case .caution: Color.catalog.caution
        case .danger: Color.catalog.danger
        }
    }

    private var background: Color {
        switch tone {
        case .neutral: Color.catalog.surfaceSunken
        case .positive: Color.catalog.positiveSoft
        case .caution: Color.catalog.cautionSoft
        case .danger: Color.catalog.dangerSoft
        }
    }
}

#if DEBUG

#Preview {
    VStack(alignment: .leading, spacing: Spacing.s3) {
        BadgeView(text: "Min. order 24")
        BadgeView(text: "Positive", tone: .positive)
        BadgeView(text: "Caution", tone: .caution)
        BadgeView(text: "Danger", tone: .danger)
        BadgeView(availabilityStatus: .inStock)
        BadgeView(availabilityStatus: .lowStock(5))
        BadgeView(availabilityStatus: .lowStock(0))
        BadgeView(availabilityStatus: .outOfStock)
    }
    .padding(Spacing.s4)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.catalog.surface)
}

#endif
