import Localisations
import StyleGuide
import SwiftUI

public struct ImageWellView: View {

    private let image: Image?
    private let inset: CGFloat
    private let placeholderSize: CGFloat
    private let title: String?

    public init(image: Image?, inset: CGFloat = 0, placeholderSize: CGFloat = 24, title: String? = nil) {
        self.image = image
        self.inset = inset
        self.placeholderSize = placeholderSize
        self.title = title
    }

    public var body: some View {
        ZStack {
            Color.catalog.surfaceSunken
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .padding(inset)
            } else {
                CatalogIcon.image.view(size: placeholderSize)
                    .foregroundStyle(Color.catalog.inkMuted)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? "")
        .accessibilityAddTraits(.isImage)
        .accessibilityHidden(accessibilityLabel == nil)
    }

    private var accessibilityLabel: String? {
        guard let title else { return nil }
        return image == nil ? L10n.A11y.imageMissing(title: title) : title
    }
}

#if DEBUG

#Preview {
    HStack(alignment: .top, spacing: Spacing.s3) {
        ImageWellView(image: Image(systemName: "shippingbox.fill"), inset: Spacing.s1)
            .frame(width: Tokens.Size.thumbSize, height: Tokens.Size.thumbSize)
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
        ImageWellView(image: nil)
            .frame(width: Tokens.Size.thumbSize, height: Tokens.Size.thumbSize)
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
        ImageWellView(image: nil, inset: Spacing.s4, placeholderSize: 32, title: "Essence Mascara")
            .frame(width: 160, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
    }
    .padding(Spacing.s4)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.catalog.surface)
}

#endif
