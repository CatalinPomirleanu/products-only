import Core
import SwiftUI

public struct AppearExecutionViewModifier: ViewModifier {
    @State private var appeared = false
    private let action: (Bool) -> Void

    public init(_ action: @escaping (Bool) -> Void) {
        self.action = action
    }

    public func body(content: Content) -> some View {
        content.onAppear {
            guard appeared == false else { return action(false) }
            appeared = true
            action(true)
        }
    }
}

@MainActor
extension Core.Namespace where T: View {
    public func onAppear(_ action: @escaping (Bool) -> Void) -> some View {
        base.modifier(AppearExecutionViewModifier(action))
    }
}
