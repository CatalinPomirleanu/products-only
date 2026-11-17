import SwiftUI

public struct StandardButtonStyle: ButtonStyle {
    public enum Variant: CaseIterable, Sendable {
        case primary
        case secondary
        case quiet
    }

    @Environment(\.isEnabled) private var isEnabled
    
    let variant: Variant

    public init(variant: Variant) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: Tokens.Radius.md)

        configuration.label
            .foregroundStyle(variant == .primary ? Color.catalog.onAction : Color.catalog.ink)
            .padding(.horizontal, Spacing.s4)
            .frame(minHeight: Tokens.Size.controlHeight)
            .background(background(isPressed: configuration.isPressed), in: shape)
            .overlay {
                if variant == .secondary {
                    shape.strokeBorder(Color.catalog.lineStrong, lineWidth: 1)
                }
            }
            .opacity(opacity(isPressed: configuration.isPressed))
            .contentShape(shape)
    }

    private func background(isPressed: Bool) -> Color {
        switch variant {
        case .primary: Color.catalog.action
        case .secondary: isPressed ? Color.catalog.line : Color.catalog.surfaceRaised
        case .quiet: isPressed ? Color.catalog.line : Color.clear
        }
    }

    private func opacity(isPressed: Bool) -> Double {
        guard isEnabled else { return 0.45 }
        return variant == .primary && isPressed ? 0.76 : 1
    }
}
