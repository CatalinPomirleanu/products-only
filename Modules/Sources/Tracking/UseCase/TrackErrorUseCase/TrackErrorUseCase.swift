import Dependencies

public protocol TrackErrorUseCase: Sendable {
    func execute(error: String, screen: Screen)
}

private nonisolated enum TrackErrorUseCaseDependencyKey: DependencyKey {
    static let liveValue: TrackErrorUseCase = StandardTrackErrorUseCase()
}

nonisolated extension DependencyValues {
    public var trackErrorUseCase: TrackErrorUseCase {
        get { self[TrackErrorUseCaseDependencyKey.self] }
        set { self[TrackErrorUseCaseDependencyKey.self] = newValue }
    }
}

#if DEBUG

import Synchronization

public final class TrackErrorUseCaseMock: TrackErrorUseCase {

    public struct Call: Equatable, Sendable {
        public let error: String
        public let screen: Screen

        public init(error: String, screen: Screen) {
            self.error = error
            self.screen = screen
        }
    }

    private let state = Mutex<[Call]>([])

    public var calls: [Call] {
        state.withLock { $0 }
    }

    public init() { }

    public func execute(error: String, screen: Screen) {
        state.withLock { $0.append(Call(error: error, screen: screen)) }
    }
}

#endif
