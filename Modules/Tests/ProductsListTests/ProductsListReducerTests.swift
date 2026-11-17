import ComposableArchitecture
import Testing

import ProductsList

@MainActor
struct ProductsListReducerTests {

    @Test("""
    Given default state
    When a product is tapped
    Then the selection is delegated to the parent
    """)
    func productTapped() async {
        let store = TestStore(initialState: ProductsListReducer.State()) {
            ProductsListReducer()
        }

        await store.send(.view(.productTapped(id: 7)))
        await store.receive(.delegate(.productSelected(id: 7)))
    }
}
