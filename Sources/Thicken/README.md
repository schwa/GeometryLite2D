# Thicken

⚠️ **Experimental** - This code is under active development and the API may change significantly.

Line thickening algorithms for converting line segments, polylines, junctions, and graphs into filled polygons.

## Overview

This module provides stroke-to-fill conversion, similar to what graphics systems do internally when stroking paths with a given line width. The output is a set of geometric primitives (`Atom`) that can be rendered as filled shapes.

## Features

- **Polyline thickening** - Convert a series of connected points into a thick stroke
- **Junction handling** - N-way junctions where multiple line segments meet at a point
- **Graph thickening** - Thicken all edges of an undirected graph with proper junction handling
- **Join styles** - Miter (with configurable limit), bevel, and round joins
- **Cap styles** - Butt, square, and round end caps
- **Triangle output** - Optional conversion to triangles for GPU rendering

## Usage

```swift
import Geometry
import Thicken

// Thicken a polyline
let polyline = Polyline(vertices: [
    CGPoint(x: 0, y: 0),
    CGPoint(x: 100, y: 0),
    CGPoint(x: 100, y: 100)
])
let atoms = polyline.thickened(
    width: 20,
    joinStyle: .miter(limit: 10),
    capStyle: .round
)

// Thicken a junction
let junction = Junction(center: CGPoint(x: 100, y: 100), vertices: [
    CGPoint(x: 0, y: 100),
    CGPoint(x: 200, y: 100),
    CGPoint(x: 100, y: 200)
])
let junctionAtoms = junction.thickened(width: 20, joinStyle: .bevel)

// Thicken a graph
let graph: UndirectedGraph<CGPoint> = ...
let graphAtoms = graph.thickened(width: 20, capStyle: .round)

// Convert to SwiftUI paths for rendering
for atom in atoms {
    let path = atom.toPath()
    // fill path...
}
```

## Known Limitations

- Self-intersecting polylines may produce visual artifacts
- Very acute angles with miter joins fall back to bevel
- Graph thickening splits edges at midpoints (may not be ideal for all use cases)
