# Repository Instructions

This file provides guidance to AI coding agents working in this repository.

`AGENTS.md` is the single source of repository instructions for Claude Code, Codex, and other compatible
agents. Edit this file directly. `CLAUDE.md` only imports this file (`@AGENTS.md`) so every Claude Code
version loads it; do not add content there.

Shared path-scoped rules live in `.agents/rules/` and are linked into `.claude/rules/`. Before editing
or reviewing matching files, read and follow the corresponding rule, even if your tool does not load it
automatically:

- `**/*View.swift` and `**/*Reducer*.swift`: `.agents/rules/tca.md`
- `**/*View.swift`: `.agents/rules/swiftui.md`
- `**/*Tests.swift` and `**/*Test.swift`: `.agents/rules/testing.md`
- `**/*Repository*.swift`: `.agents/rules/networking.md`

## Shared Skills
Reusable Agent Skills live in `.agents/skills/` and are linked into `.claude/skills/`. Codex discovers
the shared directory natively; Claude Code discovers the links.

## Quick Reference

### Architecture Rules
- SwiftUI is required for all new code
- **No singletons** - Use dependency injection via `@Dependency`
- **No empty/passthrough UseCases** - Use repositories directly if UseCase adds no value
- **Use async/await over Combine**

### Technology Stack
- **UI Framework**: SwiftUI
- **Architecture Pattern**: TCA
- **State Management**: TCA Reducers with `@Dependency` injection
- **Concurrency**: async/await
- **Networking**: REST
- **UI Components**: DesignSystem shared component library
- **Package Management**: Swift Package Manager

### Architecture Layers
```
┌─────────────────────────────────────────┐
│ Presentation (SwiftUI + TCA)            │
│ - SwiftUI Views (required)              │
│ - TCA Reducers (required for new code)  │      
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ Domain (Optional)                       │
│ - UseCases (only if adding value)       │
│ - Skip if UseCase is just passthrough   │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ Data                                    │
│ - Repository Protocol                   │
│ - Repository Implementation             │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ Network                                 │
│ - APIClient (REST)                      │
└─────────────────────────────────────────┘
```

### SwiftUI Best Practices
- **Prefer concrete types over AnyView** - Type erasure breaks animations
- **Keep view hierarchies flat** - Sibling views over deep nesting
- **Use @ViewBuilder** - For flexible, composable components
- **Minimize observed state** - Pass data, not entire stores
- **Use LazyVStack/LazyHStack** - For long scrollable lists
- **Profile on device** - 60fps target (120fps on iPad Pro)
- **Avoid complex computed properties in body** - Precompute or pass as parameters

### Swift Code Style

- **Never use `.init`** - Always use the full type name instead of `.init`
  ```swift
  // Good
  let alert = Alert(source: { $0 }, assertion: .contains("text"))
  let elements = LoginElements(\.emailTextField)

  // Bad
  let alert: Alert<Button> = .init(source: { $0 }, assertion: .contains("text"))
  let elements: LoginElements = .init(\.emailTextField)
  ```

- **Omit redundant type annotations** - When the type is obvious from the right-hand side
  ```swift
  // Good
  let foo = MyType()
  let bar = SomeClass(value: 42)

  // Bad
  let foo: MyType = MyType()
  let bar: SomeClass = SomeClass(value: 42)
  ```

### File Structure

Reducer and View live in the same file, named `*View.swift`, in this order:

1. Imports
2. Supporting types
3. Reducer
4. View
5. Preview

### DesignSystem Component Guidelines
- **Pure SwiftUI only**
- **Prefer TCA over @State** - For components with complex state mutations
- **Only truly shared components** - Feature-specific views belong in feature modules
