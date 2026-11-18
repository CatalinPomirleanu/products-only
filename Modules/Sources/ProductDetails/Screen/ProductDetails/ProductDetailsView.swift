import ComposableArchitectureSupport
import DesignSystem
import Localisations
import StyleGuide
import SwiftUI
import Tracking

@Reducer
public nonisolated struct ProductDetailsReducer {

    @ObservableState
    public struct State: Equatable {
        @CasePathable
        public enum Content: Equatable, Sendable {
            case failed
            case loaded(ProductDetails)
            case loading
        }

        public let id: Int
        public let screen: Screen
        public var content: Content

        public init(id: Int, screen: Screen = .productDetails, content: Content = .loading) {
            self.id = id
            self.screen = screen
            self.content = content
        }
    }

    public enum Action: Equatable, InternalActionScope, ViewActionScope {

        public enum InternalAction: Equatable {
            case fetchFailure
            case fetchSuccess(ProductDetails)
        }

        public enum ViewAction: Equatable {
            case onAppear(isFirstTime: Bool)
            case retryButtonTapped
        }

        case _internal(InternalAction)
        case view(ViewAction)
    }

    private enum CancelID {
        case fetch
    }

    @Dependency(\.productDetailsRepository) private var productDetailsRepository
    @Dependency(\.trackErrorUseCase) private var trackErrorUseCase
    @Dependency(\.trackScreenUseCase) private var trackScreenUseCase

    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case ._internal(.fetchFailure):
                state.content = .failed
                return .none

            case ._internal(.fetchSuccess(let details)):
                state.content = .loaded(details)
                return .none

            case .view(.onAppear(let isFirstTime)):
                if isFirstTime {
                    trackScreenUseCase.execute(screen: state.screen)
                }
                guard state.content.is(\.loading) else { return .none }
                return fetch(id: state.id, screen: state.screen)

            case .view(.retryButtonTapped):
                guard state.content.is(\.failed) else { return .none }
                state.content = .loading
                return fetch(id: state.id, screen: state.screen)
            }
        }
    }

    private func fetch(id: Int, screen: Screen) -> EffectOf<Self> {
        .run { [productDetailsRepository, trackErrorUseCase] send in
            do {
                let request = ProductDetailsRequest(id: id)
                let details = try await productDetailsRepository.fetch(request: request)
                await send(._internal(.fetchSuccess(details)))
            } catch {
                guard !Task.isCancelled else { return }
                trackErrorUseCase.execute(error: "Product Details \(id) fetch failed", screen: screen)
                await send(._internal(.fetchFailure))
            }
        }.cancellable(id: CancelID.fetch, cancelInFlight: true)
    }
}

public struct ProductDetailsView: View {

    private let skeletonCount = 7
    private let store: StoreOf<ProductDetailsReducer>

    public init(store: StoreOf<ProductDetailsReducer>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.s6) {
                makeContent()
            }
            .padding(.horizontal, Spacing.s4)
            .padding(.bottom, Spacing.s8)
            .frame(maxWidth: .infinity)
        }
        .background(Color.catalog.surface)
        .navigationTitle(store.content[case: \.loaded].map { CatalogFormat.category($0.category) } ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .ccp.onAppear { store.send(.onAppear(isFirstTime: $0)) }
    }

    @ViewBuilder
    private func makeContent() -> some View {
        switch store.content {
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

        case .loaded(let details):
            GalleryView(urls: details.images, title: details.title)
            makeSummary(details)
            makeAbout(details)
            makeDelivery(details)
            makeSpecifications(details)
            makeReviews(details)

        case .loading:
            VStack(spacing: Spacing.s3) {
                ForEach(0..<skeletonCount, id: \.self) { _ in
                    ProductCardView(content: .loading) { }
                }
            }
        }
    }

    private func makeSummary(_ details: ProductDetails) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            if let brand = details.brand, !brand.isEmpty {
                Text(brand)
                    .catalogText(.label)
                    .foregroundStyle(Color.catalog.inkMuted)
            }
            Text(details.title)
                .catalogText(.title)
                .foregroundStyle(Color.catalog.ink)
                .accessibilityAddTraits(.isHeader)
            RatingView(value: details.rating, count: details.reviews?.count)
            PriceView(price: details.price, discountPercentage: details.discountPercentage, size: .large)
            makeBadges(details)
        }
    }

    @ViewBuilder
    private func makeBadges(_ details: ProductDetails) -> some View {
        let minimumOrder = details.minimumOrderQuantity.flatMap { $0 > 1 ? $0 : nil }

        if details.availabilityStatus != nil || minimumOrder != nil {
            makeHorizontalScroll {
                if let status = details.availabilityStatus {
                    BadgeView(availabilityStatus: makeBadgeStatus(status, stock: details.stock))
                }
                if let minimumOrder {
                    BadgeView(text: L10n.Details.minOrder(minimumOrder))
                }
            }
        }
    }

    private func makeBadgeStatus(_ status: ProductDetails.AvailabilityStatus, stock: Int) -> BadgeAvailabilityStatus {
        switch status {
        case .inStock: .inStock
        case .lowStock: .lowStock(stock)
        case .outOfStock: .outOfStock
        case .unknown(let text): .general(text)
        }
    }

    @ViewBuilder
    private func makeDelivery(_ details: ProductDetails) -> some View {
        let items = [
            SpecListItem(label: L10n.Spec.shipping, value: details.shippingInformation, icon: .truck),
            SpecListItem(label: L10n.Spec.warranty, value: details.warrantyInformation, icon: .shield),
            SpecListItem(label: L10n.Spec.returns, value: details.returnPolicy, icon: .returns)
        ]
        let values = [details.shippingInformation, details.warrantyInformation, details.returnPolicy]

        if values.contains(where: { $0?.isEmpty == false }) {
            makeSection(title: L10n.Details.sectionDelivery) {
                makeBlock {
                    SpecListView(items: items)
                }
            }
        }
    }

    @ViewBuilder
    private func makeReviews(_ details: ProductDetails) -> some View {
        if let reviews = details.reviews, !reviews.isEmpty {
            makeSection(title: L10n.Details.sectionReviews(reviews.count)) {
                makeBlock {
                    VStack(spacing: 0) {
                        ForEach(reviews.enumerated(), id: \.offset) { position, review in
                            ReviewView(
                                reviewerName: review.reviewerName,
                                date: review.date,
                                rating: review.rating,
                                comment: review.comment,
                                showsSeparator: position > 0
                            )
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func makeAbout(_ details: ProductDetails) -> some View {
        if !details.description.isEmpty || !details.tags.isEmpty {
            makeSection(title: L10n.Details.sectionAbout) {
                if !details.description.isEmpty {
                    Text(details.description)
                        .catalogText(.body)
                        .foregroundStyle(Color.catalog.ink)
                }
                if !details.tags.isEmpty {
                    makeHorizontalScroll {
                        ForEach(Array(details.tags.enumerated()), id: \.offset) { _, tag in
                            TagView(text: tag)
                        }
                    }
                }
            }
        }
    }

    private func makeSpecifications(_ details: ProductDetails) -> some View {
        makeSection(title: L10n.Details.sectionSpecifications) {
            makeBlock {
                SpecListView(items: [
                    SpecListItem(label: L10n.Spec.brand, value: details.brand),
                    SpecListItem(label: L10n.Spec.category, value: CatalogFormat.category(details.category)),
                    SpecListItem(label: L10n.Spec.sku, value: details.sku, isMonospaced: true),
                    SpecListItem(label: L10n.Spec.barcode, value: details.meta?.barcode, isMonospaced: true),
                    SpecListItem(
                        label: L10n.Spec.weight,
                        value: details.weight?.formatted(.number.precision(.fractionLength(0...2)))
                    ),
                    SpecListItem(
                        label: L10n.Spec.size,
                        value: details.dimensions.map {
                            CatalogFormat.dimensions(width: $0.width, height: $0.height, depth: $0.depth)
                        }
                    ),
                    SpecListItem(label: L10n.Spec.minimumOrder, value: details.minimumOrderQuantity.map(L10n.Spec.units))
                ])
            }
        }
    }

    private func makeSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s3) {
            Text(title)
                .catalogText(.heading)
                .foregroundStyle(Color.catalog.ink)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func makeHorizontalScroll(@ViewBuilder content: () -> some View) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.s2) {
                content()
            }
        }
        .scrollIndicators(.hidden)
    }

    private func makeBlock(@ViewBuilder content: () -> some View) -> some View {
        let shape = RoundedRectangle(cornerRadius: Tokens.Radius.lg)

        return content()
            .padding(.horizontal, Spacing.s4)
            .background(Color.catalog.surfaceRaised, in: shape)
            .overlay {
                shape.strokeBorder(Color.catalog.line, lineWidth: 1)
            }
    }
}
