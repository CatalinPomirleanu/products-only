import StyleGuide
import SwiftUI

public struct TagView: View {

    private let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .catalogText(.label)
            .lineLimit(1)
            .foregroundStyle(Color.catalog.ink)
            .padding(.horizontal, Spacing.s3)
            .frame(minHeight: 28)
            .background(Color.catalog.surfaceSunken, in: Capsule())
            .overlay {
                Capsule().strokeBorder(Color.catalog.line, lineWidth: 1)
            }
    }
}

#if DEBUG

#Preview {
    HStack(spacing: Spacing.s2) {
        TagView(text: "beauty")
        TagView(text: "mascara")
    }
    .padding(Spacing.s4)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.catalog.surface)
}

#endif
