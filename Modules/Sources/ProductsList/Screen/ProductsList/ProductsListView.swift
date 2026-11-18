import ComposableArchitectureSupport
import DesignSystem
import Localisations
import StyleGuide
import SwiftUI
import Tracking

@Reducer
public nonisolated struct ProductsListReducer {

    @ObservableState
    public struct State: Equatable {
        struct Results: Equatable, Sendable {
            public var products: IdentifiedArrayOf<Product>
            public var total: Int
            public var nextOffset: Int?
            public var limit: Int

            init(page: ProductsPage) {
                products = IdentifiedArray(page.products, uniquingIDsWith: { first, _ in first })
                total = page.total
                nextOffset = Self.nextOffset(after: page)
                limit = page.limit
            }

            static func nextOffset(after page: ProductsPage) -> Int? {
                let nextOffset = page.skip + page.products.count
                return !page.products.isEmpty && nextOffset < page.total ? nextOffset : nil
            }
        }

        @CasePathable
        enum Content: Equatable, Sendable {
            case failed
            case loaded(Results)
            case loading
        }

        enum NextPageStatus: Equatable, Sendable {
            case failed
            case idle
            case loading
        }

        var content: Content = .loading
        var nextPage: NextPageStatus = .idle
        var query = ""
        var appliedQuery = ""
        let screen: Screen

        public init(screen: Screen = .productsList) {
            self.screen = screen
        }
    }

    public enum Action: Equatable, ScopedAction {

        public enum DelegateAction: Equatable {
            case productSelected(id: Int)
        }

        public enum InternalAction: Equatable {
            case firstPageFailed(query: String)
            case firstPageLoaded(ProductsPage, query: String)
            case nextPageFailed(query: String)
            case nextPageLoaded(ProductsPage, query: String)
            case searchDebounceElapsed
        }

        public enum ViewAction: Equatable {
            case clearSearchButtonTapped
            case nextPageRetryButtonTapped
            case onAppear(isFirstTime: Bool)
            case onDisappear
            case productAppeared(id: Int)
            case retryButtonTapped
            case searchSubmitted
            case searchTextChanged(String)
        }

        case delegate(DelegateAction)
        case _internal(InternalAction)
        case view(ViewAction)
    }

    private enum CancelID {
        case debounce
        case fetch
    }

    static let paginationThreshold = 5
    static let searchDebounce: Duration = .milliseconds(300)

    @Dependency(\.continuousClock) private var clock
    @Dependency(\.fetchProductsUseCase) private var fetchProductsUseCase
    @Dependency(\.trackErrorUseCase) private var trackErrorUseCase
    @Dependency(\.trackUserInteractionUseCase) private var trackUserInteractionUseCase
    @Dependency(\.trackScreenUseCase) private var trackScreenUseCase

    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate(.productSelected(let id)):
                return .run { [screen = state.screen, trackUserInteractionUseCase] _ in
                    trackUserInteractionUseCase.execute(interaction: .gesture(trackingData: "Tap on Product: \(id)"), screen: screen)
                }

            case .delegate:
                return .none

            case ._internal(.firstPageFailed(let query)):
                guard query == state.appliedQuery else { return .none }

                state.content = .failed
                state.nextPage = .idle

                return .none

            case ._internal(.firstPageLoaded(let page, let query)):
                guard query == state.appliedQuery else { return .none }

                state.content = .loaded(State.Results(page: page))
                state.nextPage = .idle

                return .none

            case ._internal(.nextPageFailed(let query)):
                guard query == state.appliedQuery, state.nextPage == .loading else { return .none }
                state.nextPage = .failed
                return .none

            case ._internal(.nextPageLoaded(let page, let query)):
                guard query == state.appliedQuery, state.nextPage == .loading else { return .none }
                guard case .loaded(var results) = state.content else { return .none }
                for product in page.products {
                    results.products.updateOrAppend(product)
                }
                results.total = page.total
                results.nextOffset = State.Results.nextOffset(after: page)
                results.limit = page.limit
                state.content = .loaded(results)
                state.nextPage = .idle
                return .none

            case ._internal(.searchDebounceElapsed):
                return commitQuery(&state)

            case .view(.clearSearchButtonTapped):
                state.query = ""
                return commitQuery(&state)

            case .view(.nextPageRetryButtonTapped):
                guard state.nextPage == .failed else {
                    return .none
                }
                return loadNextPage(&state)

            case .view(.onAppear(let isFirstTime)):
                if isFirstTime {
                    trackScreenUseCase.execute(screen: state.screen)
                }

                if normalized(state.query) != state.appliedQuery {
                    return commitQuery(&state)
                }

                if state.content == .loading {
                    return fetch(query: state.appliedQuery, screen: state.screen)
                }

                if state.nextPage == .loading, let results = state.content[case: \.loaded], let offset = results.nextOffset {
                    return fetch(query: state.appliedQuery, screen: state.screen, offset: offset, limit: results.limit)
                }

                return .none

            case .view(.onDisappear):
                return .merge(.cancel(id: CancelID.debounce), .cancel(id: CancelID.fetch))

            case .view(.productAppeared(let id)):
                guard
                    state.nextPage == .idle,
                    let results = state.content[case: \.loaded],
                    let index = results.products.index(id: id),
                    index >= results.products.count - Self.paginationThreshold
                else {
                    return .none
                }
                return loadNextPage(&state)

            case .view(.retryButtonTapped):
                guard state.content == .failed else { return .none }
                state.content = .loading
                return fetch(query: state.appliedQuery, screen: state.screen)

            case .view(.searchSubmitted):
                return commitQuery(&state)

            case .view(.searchTextChanged(let text)):
                guard text != state.query else { return .none }

                state.query = text

                guard normalized(text) != state.appliedQuery else { return .cancel(id: CancelID.debounce) }

                return .run { [clock] send in
                    try await clock.sleep(for: Self.searchDebounce)
                    await send(._internal(.searchDebounceElapsed))
                }.cancellable(id: CancelID.debounce, cancelInFlight: true)
            }
        }
    }

    private func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func commitQuery(_ state: inout State) -> EffectOf<Self> {
        let query = normalized(state.query)

        guard query != state.appliedQuery else { return .cancel(id: CancelID.debounce) }

        state.appliedQuery = query
        state.content = .loading
        state.nextPage = .idle

        return .merge(.cancel(id: CancelID.debounce), fetch(query: query, screen: state.screen))
    }

    private func loadNextPage(_ state: inout State) -> EffectOf<Self> {
        guard
            state.nextPage != .loading,
            case .loaded(let results) = state.content,
            let offset = results.nextOffset
        else {
            return .none
        }

        state.nextPage = .loading
        return fetch(query: state.appliedQuery, screen: state.screen, offset: offset, limit: results.limit)
    }

    private func fetch(query: String, screen: Screen, offset: Int = 0, limit: Int = 20) -> EffectOf<Self> {
        .run { [fetchProductsUseCase, trackErrorUseCase] send in
            do {
                let fetchMode: FetchProductsMode = query.isEmpty ? .standard : .search(query)
                let page = try await fetchProductsUseCase.execute(mode: fetchMode, offset: offset, limit: limit)
                await send(._internal(offset == 0 ? .firstPageLoaded(page, query: query) : .nextPageLoaded(page, query: query)))
            } catch {
                guard !Task.isCancelled else { return }
                trackErrorUseCase.execute(error: "Products list fetch failed", screen: screen)
                await send(._internal(offset == 0 ? .firstPageFailed(query: query) : .nextPageFailed(query: query)))
            }
        }.cancellable(id: CancelID.fetch, cancelInFlight: true)
    }
}

public struct ProductsListView: View {

    private static let skeletonCount = 5

    private let store: StoreOf<ProductsListReducer>

    public init(store: StoreOf<ProductsListReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            makeSearchField()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.s3) {
                    makeContent()
                }
                .padding(.horizontal, Spacing.s4)
                .padding(.bottom, Spacing.s8)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .background(Color.catalog.surface)
        .navigationTitle(L10n.List.title)
        .ccp.onAppear { store.send(.onAppear(isFirstTime: $0)) }
        .onDisappear { store.send(.onDisappear) }
    }

    private func makeSearchField() -> some View {
        SearchFieldView(text: store.query) { action in
            switch action {
            case .submitted:
                store.send(.searchSubmitted)

            case .textChanged(let text):
                store.send(.searchTextChanged(text))
            }
        }
        .padding(.horizontal, Spacing.s4)
        .padding(.vertical, Spacing.s2)
        .frame(maxWidth: .infinity)
        .background(Color.catalog.surface)
    }

    @ViewBuilder
    private func makeContent() -> some View {
        switch store.content {
        case .loaded(let results) where results.products.isEmpty && !store.appliedQuery.isEmpty:
            EmptyStateView(
                icon: .search,
                title: L10n.List.emptyTitle(query: store.appliedQuery),
                message: L10n.List.emptyBody,
                actionButton: EmptyStateView.ActionButton(title: L10n.Search.clear, variant: .secondary)
            ) {
                store.send(.clearSearchButtonTapped)
            }

        case .failed:
            EmptyStateView(
                icon: .alert,
                title: L10n.List.errorTitle,
                message: L10n.List.errorBody,
                tone: .danger,
                actionButton: EmptyStateView.ActionButton(title: L10n.List.errorRetry, icon: .refresh)
            ) {
                store.send(.retryButtonTapped)
            }

        case .loaded(let results):
            Text(store.appliedQuery.isEmpty
                ? L10n.List.countProducts(results.total)
                : L10n.List.countResults(results.total, query: store.appliedQuery))
                .catalogText(.caption)
                .foregroundStyle(Color.catalog.inkMuted)
            ForEach(results.products) { product in
                makeCard(product)
            }
            makeNextPageFooter()

        case .loading:
            ForEach(0..<Self.skeletonCount, id: \.self) { _ in
                ProductCardView(content: .loading) { }
            }
        }
    }

    private func makeCard(_ product: Product) -> _ProductCardView {
        _ProductCardView(product: product) { id in
            store.send(.delegate(.productSelected(id: id)))
        } onAppear: { id in
            store.send(.productAppeared(id: id))
        }
    }

    @ViewBuilder
    private func makeNextPageFooter() -> some View {
        switch store.nextPage {
        case .failed:
            HStack(spacing: Spacing.s3) {
                Text(L10n.List.errorTitle)
                    .catalogText(.body)
                    .foregroundStyle(Color.catalog.inkMuted)
                Spacer(minLength: 0)
                ButtonView(title: L10n.List.errorRetry, icon: .refresh) {
                    store.send(.nextPageRetryButtonTapped)
                }
            }

        case .idle:
            EmptyView()

        case .loading:
            ProductCardView(content: .loading) { }
        }
    }
}

private struct _ProductCardView: View {
    let product: Product
    let onSelection: (Int) -> Void
    let onAppear: (Int) -> Void

    var body: some View {
        AsyncImage(url: product.thumbnail) { phase in
            ProductCardView(content: .product(makeCardProduct(product)), thumbnail: phase.image) {
                onSelection(product.id)
            }
        }
        .onAppear { onAppear(product.id) }
    }

    private func makeCardProduct(_ product: Product) -> ProductCardView.Product {
        let availabilityStatus: BadgeAvailabilityStatus? = switch product.availabilityStatus {
        case .lowStock: .lowStock(product.stock)
        case .outOfStock: .outOfStock
        case .inStock, .unknown, nil: nil
        }

        return ProductCardView.Product(
            kicker: product.brand ?? CatalogFormat.category(product.category),
            title: product.title,
            rating: product.rating,
            price: product.price,
            discountPercentage: product.discountPercentage,
            availabilityStatus: availabilityStatus
        )
    }
}
