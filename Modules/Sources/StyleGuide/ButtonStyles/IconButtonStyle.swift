import SwiftUI

public struct IconButtonStyle: ButtonStyle {
    public enum Tone: CaseIterable, Sendable {
        case muted
        case standard
    }

    @Environment(\.isEnabled) private var isEnabled

    private let tone: Tone

    public init(tone: Tone) {
        self.tone = tone
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(tone == .muted ? Color.catalog.inkMuted : Color.catalog.ink)
            .frame(width: Tokens.Size.controlHeight, height: Tokens.Size.controlHeight)
            .background(configuration.isPressed ? Color.catalog.line : Color.clear, in: Circle())
            .opacity(isEnabled ? 1 : 0.45)
            .contentShape(Circle())
    }
}
