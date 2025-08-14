# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

```bash
# Build the package
swift build

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

This is a Swift package providing 2D geometry primitives and algorithms. The package is structured as:

- **Core Geometry Types**: Basic 2D shapes (Polygon, LineSegment, Circle, Ray, Line) built on CoreGraphics types (CGPoint, CGVector)
- **Graph Structures**: Generic graph implementations (DirectedGraph, UndirectedGraph) using Swift Collections
- **Geometry Operations**: Algorithms for intersection detection, containment tests, convex hull computation, and T-junction resolution
- **Extensions**: CoreGraphics extensions for vector math and geometric operations

## Key Design Patterns

### Type Organization
- Primary types defined in dedicated files (e.g., `Polygon.swift`, `LineSegment.swift`)
- Operations split into extension files by concern (e.g., `Geometry+Intersection.swift`, `Geometry+Contains.swift`)
- Graph types follow protocol-oriented design with `GraphProtocol` and `EdgeProtocol`

### Testing Approach
- Uses Swift Testing framework (not XCTest)
- Test assertions use `#expect` macro
- Test files mirror source file structure (e.g., `Polygon.swift` → `PolygonTests.swift`)

### Common Patterns
- Extensive use of computed properties for derived geometric values
- Protocol conformances (Equatable, Hashable, Sendable) for all primary types

## Dependencies

- **swift-collections**: Provides OrderedSet and other advanced collection types used in graph implementations
- **swift-numerics**: Mathematical utilities for numerical computations
