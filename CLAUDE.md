# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

```bash
# Build the package
swift build

# Build the Demo app
cd Demo && swift build

# Run all tests
swift test

# Run a specific test
swift test --filter TestName

# Clean build artifacts
swift package clean

# Update dependencies
swift package update
```

## Architecture Overview

This is a Swift package providing 2D geometry primitives and algorithms. The package is structured as three libraries:

- **Geometry**: Core 2D shapes (Polygon, LineSegment, Circle, Ray, Line) built on CoreGraphics types with algorithms for intersection detection, containment tests, convex hull computation, and T-junction resolution
- **Visualization**: Protocols and extensions for rendering geometry using SwiftUI's Canvas API
- **Interaction**: Protocols for making geometry interactively editable with drag handles

### Demo App Architecture

The Demo app showcases an interactive geometry editing system:

- **InteractiveRepresentable Protocol**: Shapes implement this to provide drag handles with type-safe handle IDs
- **InteractiveCanvas**: Generic SwiftUI view that manages handle state and drag interactions
- **Shape Enum**: Heterogeneous collection of shapes using type erasure with AnyHashable for handle IDs
- **Handle System**: Each shape defines its own HandleID enum for compile-time safety, avoiding string-based handle identification

Key insight: The handle system allows shapes to maintain interaction state (like Circle's edge point) that isn't part of the core geometry model. When handles are dragged, shapes can update other handles in response (e.g., moving the circle center also moves the edge handle).

## Key Design Patterns

### Type Organization
- Primary types defined in dedicated files (e.g., `Polygon.swift`, `LineSegment.swift`)
- Operations split into extension files by concern (e.g., `Geometry+Intersection.swift`, `Geometry+Contains.swift`)
- Graph types follow protocol-oriented design with `GraphProtocol` and `EdgeProtocol`

### Testing Approach
- Uses Swift Testing framework (not XCTest)
- Test assertions use `#expect` macro
- Test files mirror source file structure (e.g., `Polygon.swift` → `PolygonTests.swift`)

### Interactive Geometry Pattern
- Shapes provide handles via `makeHandles()` returning array of `InteractiveHandle<HandleID>`
- Handle changes trigger `handleDidChange(id:handles:)` where shapes can update themselves and other handles
- Type erasure at Shape enum level using `delegateHandleChange` helper to minimize boilerplate

## Dependencies

- **swift-collections**: Provides OrderedSet and other advanced collection types used in graph implementations
- **swift-numerics**: Mathematical utilities for numerical computations
