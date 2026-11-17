import ComposableArchitectureSupport
import Core
import ProductDetails
import ProductsList
import SwiftUI

@Reducer
nonisolated struct AppReducer {

    @Reducer
    enum Path {
        case productDetails(ProductDetailsReducer)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var productsList = ProductsListReducer.State()
    }

    enum Action: Equatable, ViewActionScope {

        enum ViewAction: Equatable {
            case onOpenURL(URL)
        }

        case path(StackActionOf<Path>)
        case productsList(ProductsListReducer.Action)
        case view(ViewAction)
    }

    /// The navigation stack a deeplink resolves to. It replaces the current stack.
    private func path(for deeplink: Deeplink) -> StackState<Path.State> {
        switch deeplink {
        case .productDetails(let id):
            StackState([.productDetails(ProductDetailsReducer.State(id: id))])

        case .productsList:
            StackState()
        }
    }

    var body: some ReducerOf<Self> {
        Scope(\.productsList, action: \.productsList) {
            ProductsListReducer()
        }
        Reduce<State, Action> { state, action in
            switch action {
            case .path:
                return .none

            case .productsList(.delegate(.productSelected(let id))):
                state.path.append(.productDetails(ProductDetailsReducer.State(id: id)))
                return .none

            case .productsList:
                return .none

            case .view(.onOpenURL(let url)):
                guard let deeplink = Deeplink(url: url) else {
                    return .none
                }
                state.path = path(for: deeplink)
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension AppReducer.Path.State: Equatable { }
extension AppReducer.Path.Action: Equatable { }

struct AppView: View {

    @Bindable var store: StoreOf<AppReducer>

    var body: some View {
        NavigationStack(path: $store.scope(\.path, action: \.path)) {
            ProductsListView(store: store.scope(\.productsList, action: \.productsList))
        } destination: { store in
            switch store.case {
            case .productDetails(let store):
                ProductDetailsView(store: store)
            }
        }
        .onOpenURL { url in
            store.send(.onOpenURL(url))
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppReducer.State()) {
            AppReducer()
        }
    )
}
