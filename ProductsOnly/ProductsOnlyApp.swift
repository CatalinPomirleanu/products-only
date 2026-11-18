import ComposableArchitectureSupport
import SwiftUI

@main
struct ProductsOnlyApp: App {

    var body: some Scene {
        WindowGroup {
            // Unit tests are hosted by the app: keep the real UI out of their way.
            if TestContext.current == nil {
                ProductsWindow()
            }
        }
    }
}

private struct ProductsWindow: View {
    @State private var store = Store(initialState: AppReducer.State()) {
        AppReducer()
    }

    var body: some View {
        AppView(store: store)
    }
}
