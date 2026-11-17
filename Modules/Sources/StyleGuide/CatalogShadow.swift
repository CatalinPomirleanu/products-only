import SwiftUI

extension View {
    public func catalogFloatShadow() -> some View {
        shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 6)
    }
}
