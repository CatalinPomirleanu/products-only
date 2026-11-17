import StyleGuide
import SwiftUI

public struct ButtonView: View {
    private let title: String
    private let icon: CatalogIcon?
    private let variant: StandardButtonStyle.Variant
    private let isEnabled: Bool
    private let onAction: () -> Void

    public init(
        title: String,
        icon: CatalogIcon? = nil,
        variant: StandardButtonStyle.Variant = .primary,
        isEnabled: Bool = true,
        onAction: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.isEnabled = isEnabled
        self.onAction = onAction
    }

    public var body: some View {
        Button {
            onAction()
        } label: {
            HStack(spacing: Spacing.s2) {
                icon?.view
                Text(title)
                    .catalogText(.bodyStrong)
                    .lineLimit(1)
            }
        }
        .buttonStyle(StandardButtonStyle(variant: variant))
        .disabled(!isEnabled)
    }
}

#if DEBUG

#Preview {
    VStack(alignment: .leading, spacing: Spacing.s3) {
        ButtonView(title: "Try again", icon: .refresh) { }
        ButtonView(title: "Clear search", variant: .secondary) { }
        ButtonView(title: "Show all reviews", variant: .quiet) { }
        ButtonView(title: "Try again", isEnabled: false) { }
        ButtonView(title: "Clear search", variant: .secondary, isEnabled: false) { }
        ButtonView(title: "Show all reviews", icon: .chevronRight, variant: .quiet, isEnabled: false) { }
    }
    .padding(Spacing.s4)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.catalog.surface)
}

#endif
