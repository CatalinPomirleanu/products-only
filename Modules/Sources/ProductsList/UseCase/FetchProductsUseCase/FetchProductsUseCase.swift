import Dependencies

public enum FetchProductsMode: Equatable {
    case standard
    case search(String)
}

public protocol FetchProductsUseCase: Sendable {
    func execute(mode: FetchProductsMode, offset: Int, limit: Int) async throws -> ProductsPage
}

private nonisolated enum ProductsRepositoryDependencyKey: DependencyKey {
    static let liveValue: FetchProductsUseCase = StandardFetchProductsUseCase()
}

nonisolated extension DependencyValues {
    public var fetchProductsUseCase: FetchProductsUseCase {
        get { self[ProductsRepositoryDependencyKey.self] }
        set { self[ProductsRepositoryDependencyKey.self] = newValue }
    }
}

#if DEBUG

import Synchronization

public nonisolated final class FetchProductsUseCaseMock: FetchProductsUseCase {

    public typealias Call = (mode: FetchProductsMode, offset: Int, limit: Int)
    public typealias Handler = @Sendable (FetchProductsMode, Int, Int) async throws -> ProductsPage

    public enum MockError: Error {
        case handlerNotSet
    }

    private struct State {
        var calls: [Call] = []
        var handler: Handler = { _, _, _ in throw MockError.handlerNotSet }
    }

    private let state = Mutex(State())

    public var calls: [Call] {
        state.withLock { $0.calls }
    }

    public init() { }

    public func setHandler(_ handler: @escaping Handler) {
        state.withLock { $0.handler = handler }
    }

    public func execute(mode: FetchProductsMode, offset: Int, limit: Int) async throws -> ProductsPage {
        let handler = state.withLock { state in
            state.calls.append((mode, offset, limit))
            return state.handler
        }
        return try await handler(mode, offset, limit)
    }
}

#endif
