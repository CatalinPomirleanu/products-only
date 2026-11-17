import ComposableArchitectureSupport
import SwiftUI

@main
struct ProductsOnlyApp: App {

    private static let store = Store(initialState: AppReducer.State()) {
        AppReducer()
    }

    var body: some Scene {
        WindowGroup {
            // Unit tests are hosted by the app: keep the real UI out of their way.
            if TestContext.current == nil {
                AppView(store: Self.store)
            }
        }
    }
}
