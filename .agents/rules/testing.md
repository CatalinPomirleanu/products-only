---
paths:
  - "**/*Tests.swift"
  - "**/*Test.swift"
---

# Testing Patterns

## Naming Convention: Given/When/Then

```swift
// Swift Testing style (preferred)
@Test("""
Given default state
When onAppear action is sent
Then data is fetched
""")
func onAppear() { }
```

Use `sut` for the system under test.

## Factory Pattern (Required — No setUp/tearDown)

```swift
private func makeDependencies() -> (
    repository: RepositoryMock,
    useCase: UseCaseMock
) {
    (
        RepositoryMock(),
        UseCaseMock()
    )
}

@Test("""
Given successful repo
When button tapped
Then state is updated
""")
@MainActor
func onButtonTap() async {
    var deps = makeDependencies()
    deps.useCase.mocks.execute.output = [1, 2, 3]

    let store = TestStore(
        initialState: MyReducer.State.mock(),
        reducer: { MyReducer() },
        withDependencies: {
            $0.repository = deps.repository
            $0.useCase = deps.useCase
        }
    )

    await store.send(.view(.buttonTapped))
    // assert state changes
    // assert dependencies calls
}
```

## TestStore Setup

- Use `var deps` (not `let`) to allow mutating injected dependencies per test
- Only set dependencies actually needed for the test
- Use `@Mocked` macro on protocols for automatic mock generation
- For nil values: `deps.useCase.mocks.execute.output = .some(nil)`

## AAA Convention

Arrange (setup) → Act (action) → Assert (expectations). Use comments for long tests.
