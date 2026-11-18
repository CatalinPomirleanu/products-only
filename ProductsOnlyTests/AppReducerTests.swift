import ComposableArchitecture
import Foundation
import ProductDetails
import ProductsList
import Testing
import Tracking

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
        let trackUserInteraction = TrackUserInteractionUseCaseMock()
        let store = makeStore()
        store.dependencies.trackUserInteractionUseCase = trackUserInteraction

        await store.send(.productsList(.delegate(.productSelected(id: 7)))) {
            $0.path[id: 0] = .productDetails(ProductDetailsReducer.State(id: 7))
        }
        await store.finish()

        #expect(trackUserInteraction.calls == [
            TrackUserInteractionUseCaseMock.Call(
                interaction: .gesture(trackingData: "Tap on Product: 7"),
                screen: .productsList
            )
        ])
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
    Given a missing product on the stack
    When Back to products is tapped
    Then the product list is shown
    """)
    func backToProducts() async throws {
        let details = ProductDetailsReducer.State(id: 42, content: .notFound)
        let path = StackState<AppReducer.Path.State>([.productDetails(details)])
        let store = makeStore(path: path)
        let id = try #require(path.ids.last)

        await store.send(.path(.element(id: id, action: .productDetails(.delegate(.backToProducts))))) {
            $0.path.removeAll()
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
