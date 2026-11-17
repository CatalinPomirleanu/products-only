import ComposableArchitectureSupport
import DesignSystem
import SwiftUI

@Reducer
public nonisolated struct ProductsListReducer {

    @ObservableState
    public struct State: Equatable {
        public init() { }
    }

    public enum Action: Equatable, DelegateActionScope, ViewActionScope {

        public enum DelegateAction: Equatable {
            case productSelected(id: Int)
        }

        public enum ViewAction: Equatable {
            case productTapped(id: Int)
        }

        case delegate(DelegateAction)
        case view(ViewAction)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { _, action in
            switch action {
            case .delegate:
                return .none

            case .view(.productTapped(let id)):
                return .send(.delegate(.productSelected(id: id)))
            }
        }
    }
}

public struct ProductsListView: View {

    let store: StoreOf<ProductsListReducer>

    public init(store: StoreOf<ProductsListReducer>) {
        self.store = store
    }

    public var body: some View {
        PlaceholderView(title: "Products")
            .navigationTitle("Products")
    }
}

#Preview {
    NavigationStack {
        ProductsListView(
            store: Store(initialState: ProductsListReducer.State()) {
                ProductsListReducer()
            }
        )
    }
}
