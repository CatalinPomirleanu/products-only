---
paths:
  - "**/*View.swift"
---

# SwiftUI Patterns

## View Composition

- **Concrete types over AnyView** — type erasure breaks view identity and animations
- **@ViewBuilder** for flexible, composable components
- **Flat view hierarchies** — sibling views over deep nesting
- **LazyVStack/LazyHStack** for long scrollable lists
- **@State only for simple local UI state** — use TCA for complex mutations

## Layout

- Use `.fixedSize()` for known dimensions
- Minimize environment value changes — apply at highest common ancestor

## Performance

- Minimize observed state — pass data as values, not entire stores
- Avoid complex computed properties in `body` — precompute in state
- Profile on device with Instruments (60fps iPhone / 120fps iPad Pro)
