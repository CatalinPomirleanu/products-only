import Localisations
import StyleGuide
import SwiftUI

public struct SearchFieldView: View {

    public enum Action: Equatable, Sendable {
        case textChanged(String)
        case submitted(String)
    }

    private let text: String
    private let placeholder: String
    private let onAction: (Action) -> Void

    @FocusState private var isFocused: Bool

    public init(text: String, placeholder: String = L10n.Search.placeholder, onAction: @escaping (Action) -> Void) {
        self.text = text
        self.placeholder = placeholder
        self.onAction = onAction
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: Tokens.Radius.md)

        HStack(spacing: 0) {
            CatalogIcon.search.view
                .foregroundStyle(Color.catalog.inkMuted)
                .padding(.trailing, Spacing.s2)
                .accessibilityHidden(true)
            field
            if !text.isEmpty {
                IconButtonView(icon: .close, accessibilityLabel: L10n.Search.clear, tone: .muted) {
                    onAction(.textChanged(""))
                    isFocused = true
                }
            }
        }
        .padding(.leading, Spacing.s3)
        .padding(.trailing, text.isEmpty ? Spacing.s2 : 0)
        .frame(minHeight: Tokens.Size.controlHeight)
        .background(Color.catalog.surfaceRaised, in: shape)
        .overlay {
            shape.strokeBorder(
                isFocused ? Color.catalog.ink : Color.catalog.lineStrong,
                lineWidth: isFocused ? 2 : 1
            )
        }
        .contentShape(shape)
        .onTapGesture { isFocused = true }
    }

    private var field: some View {
        TextField(
            placeholder,
            text: Binding(get: { text }, set: { onAction(.textChanged($0)) }),
            prompt: Text(placeholder).foregroundStyle(Color.catalog.inkMuted)
        )
        .catalogText(.body)
        .foregroundStyle(Color.catalog.ink)
        .tint(Color.catalog.ink)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .submitLabel(.search)
        .focused($isFocused)
        .onSubmit {
            onAction(.submitted(text))
            isFocused = false
        }
        .accessibilityAddTraits(.isSearchField)
    }
}

#if DEBUG

private struct SearchFieldViewPreview: View {
    @State private var text = "red"
    @State private var lastAction = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s3) {
            SearchFieldView(text: "") { _ in }
            SearchFieldView(text: "mascara") { _ in }
            SearchFieldView(text: text) { action in
                lastAction = String(describing: action)
                if case .textChanged(let value) = action { text = value }
            }
            Text(verbatim: "Last action: \(lastAction)")
                .catalogText(.caption)
                .foregroundStyle(Color.catalog.inkMuted)
        }
        .padding(Spacing.s4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.catalog.surface)
    }
}

#Preview {
    SearchFieldViewPreview()
}

#endif
