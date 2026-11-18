import Dependencies

public protocol TrackScreenUseCase: Sendable {
    func execute(screen: Screen)
}

private nonisolated enum TrackScreenUseCaseDependencyKey: DependencyKey {
    static let liveValue: TrackScreenUseCase = StandardTrackScreenUseCase()
}

nonisolated extension DependencyValues {
    public var trackScreenUseCase: TrackScreenUseCase {
        get { self[TrackScreenUseCaseDependencyKey.self] }
        set { self[TrackScreenUseCaseDependencyKey.self] = newValue }
    }
}

#if DEBUG

import Synchronization

public final class TrackScreenUseCaseMock: TrackScreenUseCase {

    private let state = Mutex<[Screen]>([])

    public var screens: [Screen] {
        state.withLock { $0 }
    }

    public init() { }

    public func execute(screen: Screen) {
        state.withLock { $0.append(screen) }
    }
}

#endif
