public nonisolated protocol ViewActionScope {
    associatedtype ViewAction
    static func view(_ action: ViewAction) -> Self
}

public nonisolated protocol InternalActionScope {
    associatedtype InternalAction
    static func _internal(_ action: InternalAction) -> Self
}

public nonisolated protocol DelegateActionScope {
    associatedtype DelegateAction
    static func delegate(_ action: DelegateAction) -> Self
}

extension Store where Action: ViewActionScope {
    public func send(_ action: Action.ViewAction) {
        send(.view(action))
    }
}

public typealias ScopedAction = DelegateActionScope & InternalActionScope & ViewActionScope
