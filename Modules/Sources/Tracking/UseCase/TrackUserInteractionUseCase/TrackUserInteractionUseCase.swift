import Dependencies

public protocol TrackUserInteractionUseCase: Sendable {
    func execute(interaction: UserInteraction, screen: Screen)
}

private nonisolated enum TrackUserInteractionUseCaseDependencyKey: DependencyKey {
    static let liveValue: TrackUserInteractionUseCase = StandardTrackUserInteractionUseCase()
}

nonisolated extension DependencyValues {
    public var trackUserInteractionUseCase: TrackUserInteractionUseCase {
        get { self[TrackUserInteractionUseCaseDependencyKey.self] }
        set { self[TrackUserInteractionUseCaseDependencyKey.self] = newValue }
    }
}

#if DEBUG

import Synchronization

public final class TrackUserInteractionUseCaseMock: TrackUserInteractionUseCase {

    public struct Call: Equatable, Sendable {
        public let interaction: UserInteraction
        public let screen: Screen

        public init(interaction: UserInteraction, screen: Screen) {
            self.interaction = interaction
            self.screen = screen
        }
    }

    private let state = Mutex<[Call]>([])

    public var calls: [Call] {
        state.withLock { $0 }
    }

    public init() { }

    public func execute(interaction: UserInteraction, screen: Screen) {
        state.withLock { $0.append(Call(interaction: interaction, screen: screen)) }
    }
}

#endif
