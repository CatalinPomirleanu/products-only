---
paths:
  - "**/*Repository*.swift"
---
# Networking Patterns

## Repository Pattern

```swift
// Protocol
public protocol MyRepository {
    func fetchItems() async throws -> [Item]
}

// Implementation
public struct StandardMyRepository: MyRepository {
    @Dependency(\.apiClient) private var apiClient

    public func fetchItems() async throws -> [Item] {
        let result = await apiClient.fetch()
        return result
    }
}
```

## No Combine for New Code

Use async/await for all new networking.
