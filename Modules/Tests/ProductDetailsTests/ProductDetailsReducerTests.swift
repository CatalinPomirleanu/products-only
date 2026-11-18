import ComposableArchitecture
import Foundation
import Testing
import Tracking

@testable import ProductDetails

@MainActor
struct ProductDetailsReducerTests {

    private typealias State = ProductDetailsReducer.State
    private typealias Dependencies = (
        repository: ProductDetailsRepositoryMock,
        trackError: TrackErrorUseCaseMock,
        trackScreen: TrackScreenUseCaseMock
    )

    private let details = ProductDetails.mock(id: 7)
    private let fetchError = TrackErrorUseCaseMock.Call(error: "Product Details 7 fetch failed", screen: .productDetails)

    private func makeDependencies() -> Dependencies {
        (
            ProductDetailsRepositoryMock(),
            TrackErrorUseCaseMock(),
            TrackScreenUseCaseMock()
        )
    }

    private func makeStore(
        initialState: State = State(id: 7),
        deps: Dependencies
    ) -> TestStoreOf<ProductDetailsReducer> {
        TestStore(initialState: initialState) {
            ProductDetailsReducer()
        } withDependencies: {
            $0.productDetailsRepository = deps.repository
            $0.trackErrorUseCase = deps.trackError
            $0.trackScreenUseCase = deps.trackScreen
        }
    }

    @Test("""
    Given default state
    When it is created with a product id
    Then the content is loading and the screen is product details
    """)
    func initialState() {
        let sut = State(id: 7)

        #expect(sut.id == 7)
        #expect(sut.screen == .productDetails)
        #expect(sut.content == .loading)
    }

    @Test("""
    Given loading state
    When the screen appears for the first time
    Then the screen view is tracked and the product with the state's id is fetched and shown
    """)
    func onAppear() async {
        let deps = makeDependencies()
        deps.repository.setHandler { [details] _ in details }
        let store = makeStore(deps: deps)

        await store.send(.view(.onAppear(isFirstTime: true)))
        await store.receive(._internal(.fetchSuccess(details))) {
            $0.content = .loaded(details)
        }

        #expect(deps.repository.requests == [ProductDetailsRequest(id: 7)])
        #expect(deps.trackScreen.screens == [.productDetails])
        #expect(deps.trackError.calls.isEmpty)
    }

    @Test("""
    Given a repository that fails
    When the screen appears for the first time
    Then the error is tracked and the failed state is shown
    """)
    func onAppearFailure() async {
        let deps = makeDependencies()
        deps.repository.setHandler { _ in throw URLError(.notConnectedToInternet) }
        let store = makeStore(deps: deps)

        await store.send(.view(.onAppear(isFirstTime: true)))
        await store.receive(._internal(.fetchFailure)) {
            $0.content = .failed
        }

        #expect(deps.repository.requests.count == 1)
        #expect(deps.trackScreen.screens == [.productDetails])
        #expect(deps.trackError.calls == [fetchError])
    }

    @Test("""
    Given a missing product
    When the screen appears and the repository reports it was not found
    Then the missing product is shown and reappearing does not issue another request
    """)
    func productNotFound() async {
        let deps = makeDependencies()
        deps.repository.setHandler { _ in throw ProductDetailsRepositoryError.notFound }
        let store = makeStore(deps: deps)

        await store.send(.view(.onAppear(isFirstTime: true)))
        await store.receive(._internal(.productNotFound)) {
            $0.content = .notFound
        }
        await store.send(.view(.onAppear(isFirstTime: false)))

        #expect(deps.repository.requests == [ProductDetailsRequest(id: 7)])
    }

    @Test("""
    Given loaded state
    When the screen appears again
    Then the screen view is not tracked and nothing is fetched
    """)
    func onAppearWhenLoaded() async {
        let deps = makeDependencies()
        let store = makeStore(initialState: State(id: 7, content: .loaded(details)), deps: deps)

        await store.send(.view(.onAppear(isFirstTime: false)))

        #expect(deps.repository.requests.isEmpty)
        #expect(deps.trackScreen.screens.isEmpty)
    }

    @Test("""
    Given failed state
    When the screen appears again
    Then the screen view is not tracked and nothing is fetched
    """)
    func onAppearWhenFailed() async {
        let deps = makeDependencies()
        let store = makeStore(initialState: State(id: 7, content: .failed), deps: deps)

        await store.send(.view(.onAppear(isFirstTime: false)))

        #expect(deps.repository.requests.isEmpty)
        #expect(deps.trackScreen.screens.isEmpty)
    }

    @Test("""
    Given failed state
    When the retry button is tapped
    Then loading is shown, the product is fetched again and shown
    """)
    func retry() async {
        let deps = makeDependencies()
        deps.repository.setHandler { [details] _ in details }
        let store = makeStore(initialState: State(id: 7, content: .failed), deps: deps)

        await store.send(.view(.retryButtonTapped)) {
            $0.content = .loading
        }
        await store.receive(._internal(.fetchSuccess(details))) {
            $0.content = .loaded(details)
        }

        #expect(deps.repository.requests == [ProductDetailsRequest(id: 7)])
        #expect(deps.trackError.calls.isEmpty)
    }

    @Test("""
    Given failed state and a repository that still fails
    When the retry button is tapped
    Then loading is shown, the error is tracked and the failed state returns
    """)
    func retryFailure() async {
        let deps = makeDependencies()
        deps.repository.setHandler { _ in throw URLError(.notConnectedToInternet) }
        let store = makeStore(initialState: State(id: 7, content: .failed), deps: deps)

        await store.send(.view(.retryButtonTapped)) {
            $0.content = .loading
        }
        await store.receive(._internal(.fetchFailure)) {
            $0.content = .failed
        }

        #expect(deps.trackError.calls == [fetchError])
    }

    @Test(
        """
        Given a state that has not failed
        When the retry button is tapped
        Then nothing changes and nothing is fetched
        """,
        arguments: [State.Content.loading, .loaded(.mock(id: 7)), .notFound]
    )
    func retryWhenNotFailed(content: ProductDetailsReducer.State.Content) async {
        let deps = makeDependencies()
        let store = makeStore(initialState: State(id: 7, content: content), deps: deps)

        await store.send(.view(.retryButtonTapped))

        #expect(deps.repository.requests.isEmpty)
    }
}
