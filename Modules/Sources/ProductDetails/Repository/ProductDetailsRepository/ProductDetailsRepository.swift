import Foundation
import Dependencies

public protocol ProductDetailsRepository: Sendable {
    func fetch(request: ProductDetailsRequest) async throws -> ProductDetails
}

private nonisolated enum ProductDetailsRepositoryDependencyKey: DependencyKey {
    static let liveValue: ProductDetailsRepository = StandardProductDetailsRepository()
}

nonisolated extension DependencyValues {
    public var productDetailsRepository: ProductDetailsRepository {
        get { self[ProductDetailsRepositoryDependencyKey.self] }
        set { self[ProductDetailsRepositoryDependencyKey.self] = newValue }
    }
}

#if DEBUG

import Synchronization

public nonisolated final class ProductDetailsRepositoryMock: ProductDetailsRepository {

    public typealias Handler = @Sendable (ProductDetailsRequest) async throws -> ProductDetails

    public enum MockError: Error {
        case handlerNotSet
    }

    private struct State {
        var handler: Handler = { _ in throw MockError.handlerNotSet }
        var requests: [ProductDetailsRequest] = []
    }

    private let state = Mutex(State())

    public var requests: [ProductDetailsRequest] {
        state.withLock { $0.requests }
    }

    public init() { }

    public func setHandler(_ handler: @escaping Handler) {
        state.withLock { $0.handler = handler }
    }

    public func fetch(request: ProductDetailsRequest) async throws -> ProductDetails {
        let handler = state.withLock { state in
            state.requests.append(request)
            return state.handler
        }
        return try await handler(request)
    }
}

#endif
