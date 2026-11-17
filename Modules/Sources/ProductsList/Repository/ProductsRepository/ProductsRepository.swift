import Dependencies

public protocol ProductsRepository: Sendable {
    func fetch(request: ProductsRequest) async throws -> ProductsPage
}

private nonisolated enum ProductsRepositoryDependencyKey: DependencyKey {
    static let liveValue: ProductsRepository = StandardProductsRepository()
}

nonisolated extension DependencyValues {
    public var productsRepository: ProductsRepository {
        get { self[ProductsRepositoryDependencyKey.self] }
        set { self[ProductsRepositoryDependencyKey.self] = newValue }
    }
}

#if DEBUG

import Synchronization

public nonisolated final class ProductsRepositoryMock: ProductsRepository {

    public typealias Handler = @Sendable (ProductsRequest) async throws -> ProductsPage

    public enum MockError: Error {
        case handlerNotSet
    }

    private struct State {
        var handler: Handler = { _ in throw MockError.handlerNotSet }
        var requests: [ProductsRequest] = []
    }

    private let state = Mutex(State())

    public var requests: [ProductsRequest] {
        state.withLock { $0.requests }
    }

    public init() { }

    public func setHandler(_ handler: @escaping Handler) {
        state.withLock { $0.handler = handler }
    }

    public func fetch(request: ProductsRequest) async throws -> ProductsPage {
        let handler = state.withLock { state in
            state.requests.append(request)
            return state.handler
        }
        return try await handler(request)
    }
}

#endif
