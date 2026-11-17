import SwiftUI

public struct PlaceholderView: View {

    private let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        ContentUnavailableView(title, systemImage: "hammer")
    }
}

#Preview {
    PlaceholderView(title: "Placeholder")
}
