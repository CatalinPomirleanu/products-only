import ComposableArchitecture
import Foundation
import Testing

@testable import ProductDetails

@MainActor
struct ProductDetailsReducerTests {

    private typealias State = ProductDetailsReducer.State

    private let details = ProductDetails.mock(id: 7)

    private func makeRepository() -> ProductDetailsRepositoryMock {
        ProductDetailsRepositoryMock()
    }

    private func makeStore(
        initialState: State = State(id: 7),
        repository: ProductDetailsRepositoryMock
    ) -> TestStoreOf<ProductDetailsReducer> {
        TestStore(initialState: initialState) {
            ProductDetailsReducer()
        } withDependencies: {
            $0.productDetailsRepository = repository
        }
    }

    @Test("""
    Given default state
    When it is created with a product id
    Then the content is loading
    """)
    func initialState() {
        let sut = State(id: 7)

        #expect(sut.id == 7)
        #expect(sut.content == .loading)
    }

    @Test("""
    Given loading state
    When the screen appears
    Then the product with the state's id is fetched and shown
    """)
    func onAppear() async {
        let repository = makeRepository()
        repository.setHandler { [details] _ in details }
        let store = makeStore(repository: repository)

        await store.send(.view(.onAppear))
        await store.receive(._internal(.fetchSuccess(details))) {
            $0.content = .loaded(details)
        }

        #expect(repository.requests == [ProductDetailsRequest(id: 7)])
    }

    @Test("""
    Given a repository that fails
    When the screen appears
    Then the failed state is shown
    """)
    func onAppearFailure() async {
        let repository = makeRepository()
        repository.setHandler { _ in throw URLError(.notConnectedToInternet) }
        let store = makeStore(repository: repository)

        await store.send(.view(.onAppear))
        await store.receive(._internal(.fetchFailure)) {
            $0.content = .failed
        }

        #expect(repository.requests.count == 1)
    }

    @Test("""
    Given loaded state
    When the screen appears again
    Then nothing is fetched
    """)
    func onAppearWhenLoaded() async {
        let repository = makeRepository()
        let store = makeStore(initialState: State(id: 7, content: .loaded(details)), repository: repository)

        await store.send(.view(.onAppear))

        #expect(repository.requests.isEmpty)
    }

    @Test("""
    Given failed state
    When the screen appears again
    Then nothing is fetched
    """)
    func onAppearWhenFailed() async {
        let repository = makeRepository()
        let store = makeStore(initialState: State(id: 7, content: .failed), repository: repository)

        await store.send(.view(.onAppear))

        #expect(repository.requests.isEmpty)
    }

    @Test("""
    Given failed state
    When the retry button is tapped
    Then loading is shown, the product is fetched again and shown
    """)
    func retry() async {
        let repository = makeRepository()
        repository.setHandler { [details] _ in details }
        let store = makeStore(initialState: State(id: 7, content: .failed), repository: repository)

        await store.send(.view(.retryButtonTapped)) {
            $0.content = .loading
        }
        await store.receive(._internal(.fetchSuccess(details))) {
            $0.content = .loaded(details)
        }

        #expect(repository.requests == [ProductDetailsRequest(id: 7)])
    }

    @Test("""
    Given failed state and a repository that still fails
    When the retry button is tapped
    Then loading is shown and the failed state returns
    """)
    func retryFailure() async {
        let repository = makeRepository()
        repository.setHandler { _ in throw URLError(.notConnectedToInternet) }
        let store = makeStore(initialState: State(id: 7, content: .failed), repository: repository)

        await store.send(.view(.retryButtonTapped)) {
            $0.content = .loading
        }
        await store.receive(._internal(.fetchFailure)) {
            $0.content = .failed
        }
    }

    @Test(
        """
        Given a state that has not failed
        When the retry button is tapped
        Then nothing changes and nothing is fetched
        """,
        arguments: [State.Content.loading, .loaded(.mock(id: 7))]
    )
    func retryWhenNotFailed(content: ProductDetailsReducer.State.Content) async {
        let repository = makeRepository()
        let store = makeStore(initialState: State(id: 7, content: content), repository: repository)

        await store.send(.view(.retryButtonTapped))

        #expect(repository.requests.isEmpty)
    }
}
