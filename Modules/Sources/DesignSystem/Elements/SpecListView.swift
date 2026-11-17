import StyleGuide
import SwiftUI

public struct SpecListItem: Equatable, Sendable {
    let label: String
    let value: String?
    let icon: CatalogIcon?
    let isMonospaced: Bool

    public init(label: String, value: String?, icon: CatalogIcon? = nil, isMonospaced: Bool = false) {
        self.label = label
        self.value = value
        self.icon = icon
        self.isMonospaced = isMonospaced
    }
}

public struct SpecListView: View {
    private struct Row: Identifiable {
        let id: Int
        let label: String
        let value: String
        let icon: CatalogIcon?
        let isMonospaced: Bool
    }

    private let rows: [Row]

    public init(items: [SpecListItem]) {
        rows = items
            .compactMap { item -> SpecListItem? in
                guard let value = item.value, !value.isEmpty else { return nil }
                return item
            }
            .enumerated()
            .map { index, item in
                Row(id: index, label: item.label, value: item.value ?? "", icon: item.icon, isMonospaced: item.isMonospaced)
            }
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                if row.id > 0 {
                    Color.catalog.line
                        .frame(height: 1)
                }
                makeRow(row)
            }
        }
    }

    private func makeRow(_ row: Row) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.s3) {
            if let icon = row.icon {
                icon.view
                    .foregroundStyle(Color.catalog.inkMuted)
                    .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
                    .accessibilityHidden(true)
            }
            Text(row.label)
                .catalogText(.label)
                .foregroundStyle(Color.catalog.inkMuted)
                .layoutPriority(1)
            Text(row.value)
                .catalogText(row.isMonospaced ? .code : .body)
                .foregroundStyle(Color.catalog.ink)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, Spacing.s3)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG

#Preview("Light") {
    VStack(spacing: Spacing.s4) {
        SpecListView(items: [
            SpecListItem(label: "Shipping", value: "Ships in 1 month", icon: .truck),
            SpecListItem(label: "Warranty", value: "1 month warranty", icon: .shield),
            SpecListItem(label: "Returns", value: "30 days return policy", icon: .returns)
        ])
        .padding(.horizontal, Spacing.s4)
        .background(Color.catalog.surfaceRaised, in: RoundedRectangle(cornerRadius: Tokens.Radius.lg))

        SpecListView(items: [
            SpecListItem(label: "Brand", value: "Essence"),
            SpecListItem(label: "Category", value: nil),
            SpecListItem(label: "SKU", value: "RCH45Q1A", isMonospaced: true),
            SpecListItem(label: "Barcode", value: "9164035109868", isMonospaced: true),
            SpecListItem(label: "Weight", value: ""),
            SpecListItem(label: "Size (W × H × D)", value: "23.17 × 14.43 × 28.01"),
            SpecListItem(
                label: "Notes",
                value: "A long value that wraps onto a second line and stays right-aligned."
            )
        ])
        .padding(.horizontal, Spacing.s4)
        .background(Color.catalog.surfaceRaised, in: RoundedRectangle(cornerRadius: Tokens.Radius.lg))
    }
    .padding(Spacing.s4)
    .background(Color.catalog.surface)
}

#endif
