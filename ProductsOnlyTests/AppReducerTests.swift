import ComposableArchitecture
import Foundation
import ProductDetails
import ProductsList
import Testing

@testable import ProductsOnly

@MainActor
struct AppReducerTests {

    private func makeStore(path: StackState<AppReducer.Path.State> = StackState()) -> TestStoreOf<AppReducer> {
        TestStore(initialState: AppReducer.State(path: path)) {
            AppReducer()
        }
    }

    @Test("""
    Given the products list
    When a product is tapped
    Then its details are pushed onto the stack
    """)
    func productTapped() async {
        let store = makeStore()

        await store.send(.productsList(.delegate(.productSelected(id: 7)))) {
            $0.path[id: 0] = .productDetails(ProductDetailsReducer.State(id: 7))
        }
    }

    @Test("""
    Given the products list
    When a product details deeplink is opened
    Then the stack shows the details of that product
    """)
    func productDetailsDeeplink() async throws {
        let store = makeStore()

        await store.send(.view(.onOpenURL(try #require(URL(string: "productsonly://products/42"))))) {
            $0.path[id: 0] = .productDetails(ProductDetailsReducer.State(id: 42))
        }
    }

    @Test("""
    Given product details on the stack
    When the products list deeplink is opened
    Then the stack is popped to the products list
    """)
    func productsListDeeplink() async throws {
        let store = makeStore(path: StackState([.productDetails(ProductDetailsReducer.State(id: 42))]))

        await store.send(.view(.onOpenURL(try #require(URL(string: "productsonly://products"))))) {
            $0.path = StackState()
        }
    }

    @Test("""
    Given product details on the stack
    When an unsupported URL is opened
    Then navigation does not change
    """)
    func unsupportedURL() async throws {
        let store = makeStore(path: StackState([.productDetails(ProductDetailsReducer.State(id: 42))]))

        await store.send(.view(.onOpenURL(try #require(URL(string: "productsonly://unknown")))))
    }
}
