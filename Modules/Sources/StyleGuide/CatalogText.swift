import SwiftUI

public enum CatalogText: CaseIterable, Sendable {
    case display, title, heading, body, bodyStrong, label, caption, captionStrong, code

    /// Point size at the default Dynamic Type setting.
    public var size: CGFloat {
        switch self {
        case .display: return 28
        case .title: return 22
        case .heading: return 17
        case .body: return 15
        case .bodyStrong: return 15
        case .label: return 13
        case .caption, .captionStrong: return 12
        case .code: return 13
        }
    }

    /// Line height from the design system, in points.
    public var lineHeight: CGFloat {
        switch self {
        case .display: return 34
        case .title: return 28
        case .heading: return 24
        case .body: return 22
        case .bodyStrong: return 22
        case .label: return 18
        case .caption, .captionStrong: return 16
        case .code: return 18
        }
    }

    /// Letter spacing in points (the tokens give it in em).
    public var tracking: CGFloat {
        switch self {
        case .display: return -0.56
        case .title: return -0.22
        case .heading: return 0
        case .body: return 0
        case .bodyStrong: return 0
        case .label: return 0
        case .caption, .captionStrong: return 0
        case .code: return 0
        }
    }

    /// The Dynamic Type style this one scales with.
    public var relativeTo: Font.TextStyle {
        switch self {
        case .display: return .title
        case .title: return .title2
        case .heading: return .headline
        case .body: return .subheadline
        case .bodyStrong: return .subheadline
        case .label: return .footnote
        case .caption, .captionStrong: return .caption
        case .code: return .footnote
        }
    }

    public var font: Font {
        switch self {
        case .display, .captionStrong: return .system(relativeTo, weight: .bold)
        case .title, .heading, .bodyStrong: return .system(relativeTo, weight: .semibold)
        case .body: return .system(relativeTo, weight: .regular)
        case .label, .caption: return .system(relativeTo, weight: .medium)
        case .code: return .system(relativeTo, design: .monospaced)
        }
    }
}

private struct CatalogTextModifier: ViewModifier {
    let style: CatalogText

    func body(content: Content) -> some View {
        // The line height is expressed as a multiple of the font's point size, so it equals
        // `style.lineHeight` at the default Dynamic Type setting and scales with the font.
        content
            .font(style.font)
            .tracking(style.tracking)
            .lineHeight(.multiple(factor: style.lineHeight / style.size))
    }
}

extension View {
    /// Applies a design-system text style: font, letter spacing and line height.
    public func catalogText(_ style: CatalogText) -> some View {
        modifier(CatalogTextModifier(style: style))
    }
}
