import ComposableArchitectureSupport
import DesignSystem
import SwiftUI

@Reducer
public nonisolated struct ProductDetailsReducer {

    @ObservableState
    public struct State: Equatable {
        public let id: Int

        public init(id: Int) {
            self.id = id
        }
    }

    public enum Action: Equatable { }

    public init() { }
}

public struct ProductDetailsView: View {

    let store: StoreOf<ProductDetailsReducer>

    public init(store: StoreOf<ProductDetailsReducer>) {
        self.store = store
    }

    public var body: some View {
        Text("Product \(store.id)")
            .navigationTitle("Product")
    }
}

#Preview {
    NavigationStack {
        ProductDetailsView(
            store: Store(initialState: ProductDetailsReducer.State(id: 1)) {
                ProductDetailsReducer()
            }
        )
    }
}
