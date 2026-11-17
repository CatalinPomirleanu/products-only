---
paths:
  - "**/*View.swift"
  - "**/*Reducer*.swift"
---

# TCA Patterns

## Full ScopedAction Template

```swift
@Reducer
public struct MyReducer {

    @ObservableState
    public struct State: Equatable { }

    public enum Action: Equatable, ScopedAction {

        public enum DelegateAction: Equatable {
            case dismiss
        }

        public enum InternalAction: Equatable {
            case fetchSuccess([Item])
            case fetchFailure
        }

        public enum ViewAction: Equatable {
            case onAppear
            case retryButtonTapped
        }

        case delegate(DelegateAction)
        case _internal(InternalAction)
        case view(ViewAction)
    }

    @Dependency(\.myRepository) private var myRepository

    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none

            case ._internal(.fetchFailure):
                return .none

            case ._internal(.fetchSuccess(let items)):
                return .none

            case .view(.onAppear):
                return fetch()

            case .view(.retryButtonTapped):
                return fetch()
            }
        }
    }
    
    private func fetch() -> EffectOf<Self> {
        .run { send in
            await send(._internal(.fetchSuccess([])))
        }
    }
}
```

## Action Rules

- **ViewAction**: Sent from views ONLY. Never `.send(.view(...))` from reducer — use InternalAction instead.
- **InternalAction**: Sent from reducer ONLY. For async results, shared logic consolidation.
- **DelegateAction**: For parent/child communication. ALWAYS `return .none` in child reducer.
- Views can send `.view(...)`, `.delegate(...)`, or `._internal(...)` — convenience accessors omit `.view(...)`.
- Use `ScopedAction` when all 3 scopes are needed, or the individual scope protocols otherwise.

## Pattern Matching (Required)

Top-level, alphabetical, no nested switches, no `default` clause — use a scope-level catch-all instead:

```swift
switch action {
case .delegate:
    return .none

case ._internal(.fetchFailure):
    return .none

case ._internal(.fetchSuccess):
    return .none

case ._internal: // scope-level catch-all
    return .none

case .view(.onAppear):
    return .none
}
```

## ViewStateReducer

For loading/success/error screens:

```swift
@Reducer
public struct MyScreenReducer {

    public typealias ViewStateReducer = SuccessViewStateReducerOf<MySuccessReducer>

    @ObservableState
    public struct State: Equatable {
        var viewState: ViewStateReducer.State = .loading(ScreenLoadingReducer.State())
    }

    public enum Action: Equatable {
        case viewState(ViewStateReducer.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.viewState, action: \.viewState) { ViewStateReducer() }
    }
}
```

## CancelID Pattern

```swift
private enum CancelID {
    case fetch
    case debounce
}

return .run { send in
    let result = await myRepository.fetch()
    await send(._internal(.fetchResult(result)))
}
.cancellable(id: CancelID.fetch, cancelInFlight: true)
```

## @CasePathable

Required on nested enums when using key-path syntax for `Scope`:

```swift
@CasePathable
public enum SectionState: Equatable {
    case header(HeaderReducer.State)
    case content(ContentReducer.State)
}
```

## Reducer Anatomy (Order)

1. Nested reducers (paths, destinations)
2. `@ObservableState struct State: Equatable` — presentation props first, then remaining, alphabetical
3. `enum Action: Equatable` — cases alphabetical
4. Dependencies (`@Dependency`), alphabetical
5. Mappers
6. Mutators
7. State Makers
8. `init()`
9. `var body: some ReducerOf<Self>` — actions handled alphabetically

## View Anatomy (Order)

1. `let store: StoreOf<MyReducer>` (or `@Bindable var store`)
2. `init(store:)`
3. `var body: some View`
4. Factory methods (`@ViewBuilder private func make...`)

## StateMaker Pattern

Factory for complex child state. NOT a dependency — instantiated directly in the reducer:

```swift
let stateMaker = StateMaker<Params, ChildReducer.State> { params in
    // build child state from params
}

state.child = stateMaker.make(params)
```

## Mutator Pattern

For shared state mutations across parent/child reducers. NOT dependencies — instantiated directly:

```swift
// State-only mutation
extension Mutator<ChildReducer> {
    static let increment = Self { state in
        state.count += 1
    }
}

let incrementMutator: Mutator<ChildReducer> = .increment
incrementMutator.mutate(&state.child)

// Mutation with side effects
extension EffectfulMutator<ChildReducer> {
    static let reload = Self { state in
        state.isLoading = true
        return .run { send in /* async work */ }
    }
}

let reloadMutator: EffectfulMutator<ChildReducer> = .reload
return reloadMutator.mutate(&state.child)
```

## State Injection

Prefer injecting data via `initialState` over fetching in `.onAppear`. This simplifies snapshot testing.

## Misc

- Omit `var body` entirely if the reducer has no actions to handle (no `EmptyReducer` boilerplate).
- Use functions with `inout State` for synchronous shared logic; use InternalAction for async/throwing.
