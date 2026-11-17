---
name: new-tca
description: Create a SwiftUI and TCA view file at a repository path. Use when scaffolding a new TCA screen, view, or reducer/view pair.
---

# New TCA File

- Create a new Swift file for a TCA view at the path supplied by the user; if no path was supplied, ask for it
- File should be named with last path component
  - if the filename doesn't include the `.swift` extension; add it
  - if the filename (without extension) doesn't end with `View`; add it
  - if the filename ends with `Reducer`; replace `Reducer` with `View`
- The prefix used in the template should be the name of the file but without "View.swift"
- Content of file should be this template:
    ```swift
import ComposableArchitectureSupport
    import SwiftUI

    @Reducer
    public struct <#name#>Reducer {

        @ObservableState
        public struct State: Equatable { }

        public enum Action: Equatable, DelegateActionScope, ViewActionScope {

            public enum DelegateAction: Equatable { }

            public enum ViewAction: Equatable { }

            case delegate(DelegateAction)
            case view(ViewAction)
        }

        public init() { }

        public var body: some ReducerOf<Self> {
            Reduce<State, Action> { state, action in
                switch action {
                case .delegate:
                    return .none

                case .view:
                    return .none
                }
            }
        }
    }

    public struct <#name#>View: View {

        let store: StoreOf<<#name#>Reducer>

        public init(store: StoreOf<<#name#>Reducer>) {
            self.store = store
        }

        public var body: some View {
            Text("Hello, World!")
        }
    }

    ```
- replace all instances of `<#name#>` in the template with the prefix value
