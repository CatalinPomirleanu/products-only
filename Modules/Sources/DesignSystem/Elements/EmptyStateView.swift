import StyleGuide
import SwiftUI

public struct EmptyStateView: View {
    public enum Tone: CaseIterable, Sendable {
        case neutral
        case danger
    }

    public struct ActionButton: Equatable, Sendable {
        let title: String
        let icon: CatalogIcon?
        let variant: StandardButtonStyle.Variant

        public init(title: String, icon: CatalogIcon? = nil, variant: StandardButtonStyle.Variant = .primary) {
            self.title = title
            self.icon = icon
            self.variant = variant
        }
    }

    private static let discSize = Tokens.Size.controlHeight + Spacing.s3

    private let icon: CatalogIcon?
    private let title: String
    private let message: String?
    private let tone: Tone
    private let actionButton: ActionButton?
    private let onAction: () -> Void

    public init(
        icon: CatalogIcon? = nil,
        title: String,
        message: String? = nil,
        tone: Tone = .neutral,
        actionButton: ActionButton? = nil,
        onAction: @escaping () -> Void = { }
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.tone = tone
        self.actionButton = actionButton
        self.onAction = onAction
    }

    public var body: some View {
        VStack(spacing: Spacing.s2) {
            if let icon {
                icon.view(size: 24)
                    .foregroundStyle(tone == .danger ? Color.catalog.danger : Color.catalog.ink)
                    .frame(width: Self.discSize, height: Self.discSize)
                    .background(tone == .danger ? Color.catalog.dangerSoft : Color.catalog.surfaceSunken, in: Circle())
                    .padding(.bottom, Spacing.s2)
                    .accessibilityHidden(true)
            }
            VStack(spacing: Spacing.s2) {
                Text(title)
                    .catalogText(.heading)
                    .foregroundStyle(Color.catalog.ink)
                    .accessibilityAddTraits(.isHeader)
                if let message {
                    Text(message)
                        .catalogText(.body)
                        .foregroundStyle(Color.catalog.inkMuted)
                        .frame(maxWidth: 280)
                }
            }
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .combine)
            if let actionButton {
                ButtonView(title: actionButton.title, icon: actionButton.icon, variant: actionButton.variant) {
                    onAction()
                }
                .padding(.top, Spacing.s3)
            }
        }
        .padding(.vertical, Spacing.s8)
        .padding(.horizontal, Spacing.s6)
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            EmptyStateView(
                icon: .search,
                title: "No products match “mascra”",
                message: "Check the spelling or try a shorter search.",
                actionButton: EmptyStateView.ActionButton(title: "Clear search", variant: .secondary)
            ) { }
            EmptyStateView(
                icon: .alert,
                title: "Couldn’t load products",
                message: "Check your connection and try again.",
                tone: .danger,
                actionButton: EmptyStateView.ActionButton(title: "Try again", icon: .refresh)
            ) { }
            EmptyStateView(title: "Nothing here yet")
        }
    }
    .background(Color.catalog.surface)
}

#endif
