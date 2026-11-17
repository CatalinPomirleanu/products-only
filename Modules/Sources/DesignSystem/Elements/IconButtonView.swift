import StyleGuide
import SwiftUI

public struct IconButtonView: View {
    private let icon: CatalogIcon
    private let accessibilityLabel: String
    private let tone: IconButtonStyle.Tone
    private let isEnabled: Bool
    private let onAction: () -> Void

    public init(
        icon: CatalogIcon,
        accessibilityLabel: String,
        tone: IconButtonStyle.Tone = .standard,
        isEnabled: Bool = true,
        onAction: @escaping () -> Void
    ) {
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.tone = tone
        self.isEnabled = isEnabled
        self.onAction = onAction
    }

    public var body: some View {
        Button {
            onAction()
        } label: {
            icon.view
        }
        .buttonStyle(IconButtonStyle(tone: tone))
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
    }
}

#if DEBUG

#Preview("Light") {
    HStack(spacing: Spacing.s3) {
        IconButtonView(icon: .arrowLeft, accessibilityLabel: "Back") { }
        IconButtonView(icon: .close, accessibilityLabel: "Clear search", tone: .muted) { }
        IconButtonView(icon: .arrowLeft, accessibilityLabel: "Back", isEnabled: false) { }
    }
    .padding(Spacing.s4)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.catalog.surface)
}

#endif
