import ComposableArchitecture
import Foundation
import Testing
import Tracking

@testable import ProductsList

@MainActor
struct ProductsListReducerTests {

    private typealias State = ProductsListReducer.State
    private typealias Dependencies = (
        clock: TestClock<Duration>,
        trackError: TrackErrorUseCaseMock,
        trackScreen: TrackScreenUseCaseMock,
        trackUserInteraction: TrackUserInteractionUseCaseMock,
        useCase: FetchProductsUseCaseMock
    )

    private let fetchError = TrackErrorUseCaseMock.Call(error: "Products list fetch failed", screen: .productsList)

    private let firstPage = ProductsPage.mock(ids: 1...20, total: 45)
    private let secondPage = ProductsPage.mock(ids: 21...40, total: 45, skip: 20)
    private let searchPage = ProductsPage.mock(ids: 101...102, total: 2)

    private func makeDependencies() -> Dependencies {
        (
            TestClock(),
            TrackErrorUseCaseMock(),
            TrackScreenUseCaseMock(),
            TrackUserInteractionUseCaseMock(),
            FetchProductsUseCaseMock()
        )
    }

    private func makeStore(initialState: State = State(), deps: Dependencies) -> TestStoreOf<ProductsListReducer> {
        TestStore(initialState: initialState) {
            ProductsListReducer()
        } withDependencies: {
            $0.continuousClock = deps.clock
            $0.fetchProductsUseCase = deps.useCase
            $0.trackErrorUseCase = deps.trackError
            $0.trackScreenUseCase = deps.trackScreen
            $0.trackUserInteractionUseCase = deps.trackUserInteraction
        }
    }

    /// A state showing `page` as the results of `query`.
    private func makeState(
        page: ProductsPage,
        query: String = "",
        nextPage: State.NextPageStatus = .idle
    ) -> State {
        var state = State()
        state.content = .loaded(State.Results(page: page))
        state.nextPage = nextPage
        state.query = query
        state.appliedQuery = query
        return state
    }

    /// `firstPage` with `secondPage` appended, as the reducer leaves it.
    private func makeBothPagesContent() -> State.Content {
        var results = State.Results(page: firstPage)
        results.products.append(contentsOf: secondPage.products)
        results.nextOffset = 40
        return .loaded(results)
    }

    // MARK: - First page

    @Test("""
    Given default state
    When the screen appears for the first time
    Then the screen view is tracked and the first standard page is fetched and shown
    """)
    func onAppear() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { [firstPage] _, _, _ in firstPage }
        let store = makeStore(deps: deps)

        await store.send(.view(.onAppear(isFirstTime: true)))
        await store.receive(._internal(.firstPageLoaded(firstPage, query: ""))) {
            $0.content = .loaded(State.Results(page: firstPage))
        }

        #expect(deps.useCase.calls.count == 1)
        #expect(deps.useCase.calls.first?.mode == .standard)
        #expect(deps.useCase.calls.first?.offset == 0)
        #expect(deps.useCase.calls.first?.limit == 20)
        #expect(deps.trackScreen.screens == [.productsList])
        #expect(deps.trackError.calls.isEmpty)
    }

    @Test("""
    Given a loaded list
    When the screen appears again
    Then the screen view is not tracked and nothing is fetched
    """)
    func onAppearAgain() async {
        let deps = makeDependencies()
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.onAppear(isFirstTime: false)))

        #expect(deps.trackScreen.screens.isEmpty)
        #expect(deps.useCase.calls.isEmpty)
    }

    @Test("""
    Given a first page request that fails
    When the retry button is tapped
    Then the error is tracked once and the first page is fetched again and shown
    """)
    func firstPageFailureAndRetry() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { _, _, _ in throw URLError(.notConnectedToInternet) }
        let store = makeStore(deps: deps)

        await store.send(.view(.onAppear(isFirstTime: true)))
        await store.receive(._internal(.firstPageFailed(query: ""))) {
            $0.content = .failed
        }
        #expect(deps.trackError.calls == [fetchError])

        deps.useCase.setHandler { [firstPage] _, _, _ in firstPage }
        await store.send(.view(.retryButtonTapped)) {
            $0.content = .loading
        }
        await store.receive(._internal(.firstPageLoaded(firstPage, query: ""))) {
            $0.content = .loaded(State.Results(page: firstPage))
        }

        #expect(deps.useCase.calls.count == 2)
        #expect(deps.trackError.calls == [fetchError])
    }

    @Test("""
    Given a loaded list
    When the retry button action is sent
    Then nothing is fetched
    """)
    func retryWhenNotFailed() async {
        let deps = makeDependencies()
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.retryButtonTapped))

        #expect(deps.useCase.calls.isEmpty)
    }

    @Test("""
    Given pages from the backend
    When building results from them
    Then the next offset is set only while more products remain
    """)
    func resultsNextOffset() {
        #expect(State.Results(page: firstPage).nextOffset == 20)
        #expect(State.Results(page: secondPage).nextOffset == 40)
        #expect(State.Results(page: ProductsPage.mock(ids: 41...45, total: 45, skip: 40)).nextOffset == nil)
        #expect(State.Results(page: ProductsPage.mock(ids: nil, total: 45, skip: 20)).nextOffset == nil)
    }

    // MARK: - Pagination

    @Test("""
    Given a loaded list with more pages
    When one of the last products appears
    Then the next page is fetched from the next offset and appended
    """)
    func nextPage() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { [secondPage] _, _, _ in secondPage }
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.productAppeared(id: 16))) {
            $0.nextPage = .loading
        }
        await store.receive(._internal(.nextPageLoaded(secondPage, query: ""))) {
            $0.content = makeBothPagesContent()
            $0.nextPage = .idle
        }

        #expect(deps.useCase.calls.count == 1)
        #expect(deps.useCase.calls.first?.mode == .standard)
        #expect(deps.useCase.calls.first?.offset == 20)
        #expect(deps.useCase.calls.first?.limit == 20)
    }

    @Test("""
    Given a loaded list with more pages
    When a product far from the end appears
    Then nothing is fetched
    """)
    func productFarFromEndAppeared() async {
        let deps = makeDependencies()
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.productAppeared(id: 15)))

        #expect(deps.useCase.calls.isEmpty)
    }

    @Test("""
    Given a next page request in flight
    When another of the last products appears
    Then the page is not requested twice
    """)
    func nextPageNotRequestedTwice() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { _, _, _ in try await Task.never() }
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.productAppeared(id: 19))) {
            $0.nextPage = .loading
        }
        await store.send(.view(.productAppeared(id: 20)))

        #expect(deps.useCase.calls.count == 1)

        await store.send(.view(.onDisappear))
    }

    @Test("""
    Given a loaded list with no more pages
    When the last product appears
    Then nothing is fetched
    """)
    func noMorePages() async {
        let deps = makeDependencies()
        let lastPage = ProductsPage.mock(ids: 41...45, total: 45, skip: 40)
        let store = makeStore(initialState: makeState(page: lastPage), deps: deps)

        await store.send(.view(.productAppeared(id: 45)))

        #expect(deps.useCase.calls.isEmpty)
    }

    @Test("""
    Given a next page request that fails
    When the last product appears again and then the retry button is tapped
    Then the loaded products are kept, the error is tracked, only the retry fetches, and the page is appended
    """)
    func nextPageFailureAndRetry() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { _, _, _ in throw URLError(.notConnectedToInternet) }
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.productAppeared(id: 20))) {
            $0.nextPage = .loading
        }
        await store.receive(._internal(.nextPageFailed(query: ""))) {
            $0.nextPage = .failed
        }

        await store.send(.view(.productAppeared(id: 20)))
        #expect(deps.useCase.calls.count == 1)
        #expect(deps.trackError.calls == [fetchError])

        deps.useCase.setHandler { [secondPage] _, _, _ in secondPage }
        await store.send(.view(.nextPageRetryButtonTapped)) {
            $0.nextPage = .loading
        }
        await store.receive(._internal(.nextPageLoaded(secondPage, query: ""))) {
            $0.content = makeBothPagesContent()
            $0.nextPage = .idle
        }

        #expect(deps.useCase.calls.count == 2)
        #expect(deps.useCase.calls.last?.offset == 20)
        #expect(deps.trackError.calls == [fetchError])
    }

    // MARK: - Search

    @Test("""
    Given a loaded standard list
    When the search text changes
    Then the trimmed query is fetched from the first page only after the debounce interval
    """)
    func searchIsDebounced() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { [searchPage] _, _, _ in searchPage }
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.searchTextChanged("  red "))) {
            $0.query = "  red "
        }
        await deps.clock.advance(by: ProductsListReducer.searchDebounce - .milliseconds(1))
        #expect(deps.useCase.calls.isEmpty)

        await deps.clock.advance(by: .milliseconds(1))
        await store.receive(._internal(.searchDebounceElapsed)) {
            $0.appliedQuery = "red"
            $0.content = .loading
        }
        await store.receive(._internal(.firstPageLoaded(searchPage, query: "red"))) {
            $0.content = .loaded(State.Results(page: searchPage))
        }

        #expect(deps.useCase.calls.count == 1)
        #expect(deps.useCase.calls.first?.mode == .search("red"))
        #expect(deps.useCase.calls.first?.offset == 0)
    }

    @Test("""
    Given a loaded standard list
    When the search text changes several times within the debounce interval
    Then only the last query is fetched
    """)
    func searchFetchesOnlyTheLastQuery() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { [searchPage] _, _, _ in searchPage }
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.searchTextChanged("r"))) {
            $0.query = "r"
        }
        await deps.clock.advance(by: .milliseconds(200))
        await store.send(.view(.searchTextChanged("re"))) {
            $0.query = "re"
        }
        await deps.clock.advance(by: .milliseconds(200))
        await store.send(.view(.searchTextChanged("red"))) {
            $0.query = "red"
        }
        await deps.clock.advance(by: ProductsListReducer.searchDebounce)

        await store.receive(._internal(.searchDebounceElapsed)) {
            $0.appliedQuery = "red"
            $0.content = .loading
        }
        await store.receive(._internal(.firstPageLoaded(searchPage, query: "red"))) {
            $0.content = .loaded(State.Results(page: searchPage))
        }

        #expect(deps.useCase.calls.count == 1)
        #expect(deps.useCase.calls.first?.mode == .search("red"))
    }

    @Test("""
    Given search results on screen
    When the text changes but the normalized query does not
    Then nothing is fetched
    """)
    func unchangedNormalizedQuery() async {
        let deps = makeDependencies()
        let store = makeStore(initialState: makeState(page: searchPage, query: "red"), deps: deps)

        await store.send(.view(.searchTextChanged("red "))) {
            $0.query = "red "
        }
        await deps.clock.advance(by: ProductsListReducer.searchDebounce)
        await store.send(.view(.searchSubmitted))

        #expect(deps.useCase.calls.isEmpty)
    }

    @Test("""
    Given a changed search text waiting for the debounce
    When the text returns to the applied query
    Then the pending search is dropped
    """)
    func revertedQuery() async {
        let deps = makeDependencies()
        let store = makeStore(initialState: makeState(page: searchPage, query: "red"), deps: deps)

        await store.send(.view(.searchTextChanged("reds"))) {
            $0.query = "reds"
        }
        await store.send(.view(.searchTextChanged("red"))) {
            $0.query = "red"
        }
        await deps.clock.advance(by: ProductsListReducer.searchDebounce)

        #expect(deps.useCase.calls.isEmpty)
    }

    @Test("""
    Given a changed search text waiting for the debounce
    When the search is submitted
    Then it is fetched at once and not again when the debounce interval passes
    """)
    func searchSubmitted() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { [searchPage] _, _, _ in searchPage }
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.searchTextChanged("red"))) {
            $0.query = "red"
        }
        await store.send(.view(.searchSubmitted)) {
            $0.appliedQuery = "red"
            $0.content = .loading
        }
        await store.receive(._internal(.firstPageLoaded(searchPage, query: "red"))) {
            $0.content = .loaded(State.Results(page: searchPage))
        }
        await deps.clock.advance(by: ProductsListReducer.searchDebounce)

        #expect(deps.useCase.calls.count == 1)
    }

    @Test("""
    Given a search without results
    When the clear search button is tapped
    Then the standard list is fetched at once from the first page
    """)
    func clearSearch() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { [firstPage] _, _, _ in firstPage }
        let store = makeStore(
            initialState: makeState(page: ProductsPage.mock(ids: nil, total: 0), query: "mascra"),
            deps: deps
        )

        await store.send(.view(.clearSearchButtonTapped)) {
            $0.query = ""
            $0.appliedQuery = ""
            $0.content = .loading
        }
        await store.receive(._internal(.firstPageLoaded(firstPage, query: ""))) {
            $0.content = .loaded(State.Results(page: firstPage))
        }

        #expect(deps.useCase.calls.count == 1)
        #expect(deps.useCase.calls.first?.mode == .standard)
        #expect(deps.useCase.calls.first?.offset == 0)
    }

    @Test("""
    Given a loaded standard list
    When a search fails on its first page
    Then the error is tracked and replaces the list
    """)
    func searchFailure() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { _, _, _ in throw URLError(.notConnectedToInternet) }
        var initialState = makeState(page: firstPage)
        initialState.query = "red"
        let store = makeStore(initialState: initialState, deps: deps)

        await store.send(.view(.searchSubmitted)) {
            $0.appliedQuery = "red"
            $0.content = .loading
        }
        await store.receive(._internal(.firstPageFailed(query: "red"))) {
            $0.content = .failed
        }

        #expect(deps.trackError.calls == [fetchError])
    }

    // MARK: - Cancellation

    @Test("""
    Given a next page request in flight
    When the query changes
    Then the request is cancelled without a tracked error and the search results replace the list
    """)
    func queryChangeCancelsNextPage() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { [searchPage] _, offset, _ in
            if offset > 0 {
                try await Task.never()
            }
            return searchPage
        }
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.productAppeared(id: 20))) {
            $0.nextPage = .loading
        }
        await store.send(.view(.searchTextChanged("red"))) {
            $0.query = "red"
        }
        await store.send(.view(.searchSubmitted)) {
            $0.appliedQuery = "red"
            $0.content = .loading
            $0.nextPage = .idle
        }
        await store.receive(._internal(.firstPageLoaded(searchPage, query: "red"))) {
            $0.content = .loaded(State.Results(page: searchPage))
        }

        #expect(deps.useCase.calls.count == 2)
        #expect(deps.trackError.calls.isEmpty)
    }

    @Test("""
    Given a first page request in flight for a query
    When the query changes
    Then the request is cancelled and only the newer query's results are shown
    """)
    func queryChangeCancelsFirstPage() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { [searchPage] mode, _, _ in
            if case .search("a") = mode {
                try await Task.never()
            }
            return searchPage
        }
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.searchTextChanged("a"))) {
            $0.query = "a"
        }
        await store.send(.view(.searchSubmitted)) {
            $0.appliedQuery = "a"
            $0.content = .loading
        }
        await store.send(.view(.searchTextChanged("b"))) {
            $0.query = "b"
        }
        await store.send(.view(.searchSubmitted)) {
            $0.appliedQuery = "b"
        }
        await store.receive(._internal(.firstPageLoaded(searchPage, query: "b"))) {
            $0.content = .loaded(State.Results(page: searchPage))
        }
    }

    @Test("""
    Given results on screen for a query
    When responses for another query arrive
    Then they are ignored
    """)
    func staleResponses() async {
        let deps = makeDependencies()
        let store = makeStore(initialState: makeState(page: firstPage, nextPage: .loading), deps: deps)

        await store.send(._internal(.firstPageLoaded(searchPage, query: "old")))
        await store.send(._internal(.firstPageFailed(query: "old")))
        await store.send(._internal(.nextPageLoaded(searchPage, query: "old")))
        await store.send(._internal(.nextPageFailed(query: "old")))
    }

    @Test("""
    Given a first page request in flight
    When the screen disappears and appears again
    Then the request is cancelled without a tracked error and issued again, and the screen view is tracked once
    """)
    func disappearCancelsAndAppearRestarts() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { _, _, _ in try await Task.never() }
        let store = makeStore(deps: deps)

        await store.send(.view(.onAppear(isFirstTime: true)))
        await store.send(.view(.onDisappear))

        deps.useCase.setHandler { [firstPage] _, _, _ in firstPage }
        await store.send(.view(.onAppear(isFirstTime: false)))
        await store.receive(._internal(.firstPageLoaded(firstPage, query: ""))) {
            $0.content = .loaded(State.Results(page: firstPage))
        }

        #expect(deps.useCase.calls.count == 2)
        #expect(deps.trackScreen.screens == [.productsList])
        #expect(deps.trackError.calls.isEmpty)
    }

    @Test("""
    Given a next page request cancelled by the screen disappearing
    When the screen appears again
    Then the next page is requested again
    """)
    func appearRestartsNextPage() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { [secondPage] _, _, _ in secondPage }
        let store = makeStore(initialState: makeState(page: firstPage, nextPage: .loading), deps: deps)

        await store.send(.view(.onAppear(isFirstTime: false)))
        await store.receive(._internal(.nextPageLoaded(secondPage, query: ""))) {
            $0.content = makeBothPagesContent()
            $0.nextPage = .idle
        }

        #expect(deps.useCase.calls.first?.offset == 20)
    }

    @Test("""
    Given a changed search text waiting for the debounce
    When the screen disappears and appears again
    Then the debounce is cancelled and the search is fetched on appearing
    """)
    func disappearCancelsDebounce() async {
        let deps = makeDependencies()
        deps.useCase.setHandler { [searchPage] _, _, _ in searchPage }
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.view(.searchTextChanged("red"))) {
            $0.query = "red"
        }
        await store.send(.view(.onDisappear))
        await deps.clock.advance(by: ProductsListReducer.searchDebounce)
        #expect(deps.useCase.calls.isEmpty)

        await store.send(.view(.onAppear(isFirstTime: false))) {
            $0.appliedQuery = "red"
            $0.content = .loading
        }
        await store.receive(._internal(.firstPageLoaded(searchPage, query: "red"))) {
            $0.content = .loaded(State.Results(page: searchPage))
        }
    }

    // MARK: - Tracking

    @Test("""
    Given a loaded list
    When a product is selected
    Then the tap is tracked for the products list screen
    """)
    func productSelected() async {
        let deps = makeDependencies()
        let store = makeStore(initialState: makeState(page: firstPage), deps: deps)

        await store.send(.delegate(.productSelected(id: 7)))
        await store.finish()

        #expect(deps.trackUserInteraction.calls == [
            TrackUserInteractionUseCaseMock.Call(
                interaction: .gesture(trackingData: "Tap on Product: 7"),
                screen: .productsList
            )
        ])
    }
}
