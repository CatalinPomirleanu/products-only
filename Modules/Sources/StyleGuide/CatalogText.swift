import SwiftUI

/// The eight text styles. Use `.catalogText(.body)` rather than setting fonts by hand.
public enum CatalogText: CaseIterable, Sendable {
    case display, title, heading, body, bodyStrong, label, caption, code

    /// Point size at the default Dynamic Type setting.
    public var size: CGFloat {
        switch self {
        case .display: return 28
        case .title: return 22
        case .heading: return 17
        case .body: return 15
        case .bodyStrong: return 15
        case .label: return 13
        case .caption: return 12
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
        case .caption: return 16
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
        case .caption: return 0
        case .code: return 0
        }
    }

    /// PostScript name of the Work Sans face, or nil for the system monospaced font.
    public var fontName: String? {
        switch self {
        case .display: return "WorkSans-Bold"
        case .title: return "WorkSans-SemiBold"
        case .heading: return "WorkSans-SemiBold"
        case .body: return "WorkSans-Regular"
        case .bodyStrong: return "WorkSans-SemiBold"
        case .label: return "WorkSans-Medium"
        case .caption: return "WorkSans-Medium"
        case .code: return nil
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
        case .caption: return .caption
        case .code: return .footnote
        }
    }

    /// Falls back to the system font if Work Sans is not registered in the app.
    public var font: Font {
        guard let fontName else { return .system(relativeTo, design: .monospaced) }
        return .custom(fontName, size: size, relativeTo: relativeTo)
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
