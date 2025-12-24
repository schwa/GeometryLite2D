import DemoKit
import Geometry
import GeometryCollections
import Interaction
import Thicken
import SwiftUI

struct ThickenDemoView: DemoView {
    static var metadata = DemoMetadata(
        type: Self.self,
        description: "Line thickening with configurable join and cap styles",
        keywords: ["thicken", "stroke", "polyline", "junction", "graph"]
    )

    init() {}

    @State private var lineWidth: CGFloat = 30
    @State private var miterLimit: CGFloat = 10

    @State private var points: [CGPoint] = Scene.rightAngle.points
    @State private var currentScene: Scene = .rightAngle

    @State private var joinStyleChoice: JoinStyleChoice = .miter
    @State private var capStyle: CapStyle = .round
    @State private var renderAsTriangles: Bool = false
    @State private var pixelsPerSegment: CGFloat = 4
    @State private var closePath: Bool = false

    // Graph state - vertices that can be dragged
    @State private var graphVertices: [CGPoint] = Scene.twoSquares.graphVertices

    enum Scene: String, CaseIterable {
        case rightAngle = "Right Angle (3)"
        case acute = "Acute (3)"
        case obtuse = "Obtuse (3)"
        case zigzag = "Zigzag (4)"
        case uTurn = "U-Turn (3)"
        case twoWayJunction = "2-Way Junction"
        case tJunction = "T-Junction"
        case cross = "Cross (4-way)"
        case twoSquares = "Two Squares (Graph)"
        case twoSquaresWithTail = "Two Squares + Tail"

        var points: [CGPoint] {
            switch self {
            case .rightAngle:
                return [[100, 100], [250, 100], [250, 280]]

            case .acute:
                return [[100, 150], [250, 150], [150, 250]]

            case .obtuse:
                return [[100, 150], [250, 150], [350, 200]]

            case .zigzag:
                return [[50, 150], [200, 150], [200, 300], [350, 300]]

            case .uTurn:
                return [[100, 150], [300, 150], [100, 180]]

            case .twoWayJunction:
                // 2-way junction: center + 2 endpoints
                return [[200, 200], [100, 120], [320, 280]]

            case .tJunction:
                // T-junction: center + 3 endpoints
                return [[200, 200], [100, 200], [300, 200], [200, 320]]

            case .cross:
                // Cross: center + 4 endpoints
                return [[200, 200], [100, 200], [300, 200], [200, 100], [200, 300]]

            case .twoSquares, .twoSquaresWithTail:
                // Graph vertices (not used as polyline)
                return []
            }
        }

        var isJunction: Bool {
            switch self {
            case .twoWayJunction, .tJunction, .cross: return true
            default: return false
            }
        }

        var isGraph: Bool {
            switch self {
            case .twoSquares, .twoSquaresWithTail: return true
            default: return false
            }
        }

        /// Vertices for graph scenes (indexed for dragging)
        var graphVertices: [CGPoint] {
            switch self {
            case .twoSquares:
                // 0: p00, 1: p10, 2: p20, 3: p01, 4: p11, 5: p21
                return [
                    [100, 100], // 0: top-left
                    [200, 100], // 1: top-middle (shared)
                    [300, 100], // 2: top-right
                    [100, 200], // 3: bottom-left
                    [200, 200], // 4: bottom-middle (shared)
                    [300, 200]  // 5: bottom-right
                ]

            case .twoSquaresWithTail:
                // Same as twoSquares plus a tail vertex
                return [
                    [100, 100], // 0: top-left
                    [200, 100], // 1: top-middle (shared)
                    [300, 100], // 2: top-right
                    [100, 200], // 3: bottom-left
                    [200, 200], // 4: bottom-middle (shared)
                    [300, 200], // 5: bottom-right
                    [50, 150]   // 6: tail endpoint (off bottom-left)
                ]

            default:
                return []
            }
        }

        /// Edge indices for graph scenes (pairs of vertex indices)
        var graphEdgeIndices: [(Int, Int)] {
            switch self {
            case .twoSquares:
                return [
                    (0, 1), // top-left to top-middle
                    (1, 4), // top-middle to bottom-middle (shared edge)
                    (4, 3), // bottom-middle to bottom-left
                    (3, 0), // bottom-left to top-left
                    (1, 2), // top-middle to top-right
                    (2, 5), // top-right to bottom-right
                    (5, 4)  // bottom-right to bottom-middle
                ]

            case .twoSquaresWithTail:
                return [
                    (0, 1), // top-left to top-middle
                    (1, 4), // top-middle to bottom-middle (shared edge)
                    (4, 3), // bottom-middle to bottom-left
                    (3, 0), // bottom-left to top-left
                    (1, 2), // top-middle to top-right
                    (2, 5), // top-right to bottom-right
                    (5, 4), // bottom-right to bottom-middle
                    (3, 6)  // tail: bottom-left to tail endpoint
                ]

            default:
                return []
            }
        }

        /// Build graph from vertices array and edge indices
        static func buildGraph(vertices: [CGPoint], edgeIndices: [(Int, Int)]) -> UndirectedGraph<CGPoint> {
            var g = UndirectedGraph<CGPoint>()
            for (i, j) in edgeIndices {
                guard i < vertices.count, j < vertices.count else { continue }
                g.add(edge: .init(from: vertices[i], to: vertices[j]))
            }
            return g
        }
    }

    enum JoinStyleChoice: String, CaseIterable {
        case miter, bevel, round
    }

    var joinStyle: JoinStyle {
        switch joinStyleChoice {
        case .miter: return .miter(limit: miterLimit)
        case .bevel: return .bevel
        case .round: return .round
        }
    }

    var isJunction: Bool {
        currentScene.isJunction && points.count >= 2
    }

    var junctionCenter: CGPoint? {
        guard isJunction else { return nil }
        return points[0]
    }

    var junctionEndpoints: [CGPoint] {
        guard isJunction else { return [] }
        return Array(points.dropFirst())
    }

    var body: some View {
        VStack {
            // Controls
            VStack(spacing: 8) {
                HStack {
                    Picker("Scene", selection: $currentScene) {
                        ForEach(Scene.allCases, id: \.self) { scene in
                            Text(scene.rawValue).tag(scene)
                        }
                    }
                    .frame(width: 150)
                    .onChange(of: currentScene) { _, newScene in
                        points = newScene.points
                        if newScene.isGraph {
                            graphVertices = newScene.graphVertices
                        }
                    }

                    Picker("Join", selection: $joinStyleChoice) {
                        ForEach(JoinStyleChoice.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)

                    Picker("Cap", selection: $capStyle) {
                        Text("butt").tag(CapStyle.butt)
                        Text("square").tag(CapStyle.square)
                        Text("round").tag(CapStyle.round)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)

                    Toggle("Triangles", isOn: $renderAsTriangles)
                    Toggle("Closed", isOn: $closePath)
                }

                HStack {
                    Text("Width: \(lineWidth, specifier: "%.0f")")
                        .frame(width: 80, alignment: .leading)
                    Slider(value: $lineWidth, in: 5...200)
                        .frame(width: 150)

                    Text("Miter limit: \(miterLimit, specifier: "%.1f")")
                        .frame(width: 120, alignment: .leading)
                    Slider(value: $miterLimit, in: 0.5...50)
                        .frame(width: 150)

                    Text("Pixels/seg: \(pixelsPerSegment, specifier: "%.0f")")
                        .frame(width: 100, alignment: .leading)
                    Slider(value: $pixelsPerSegment, in: 1...50)
                        .frame(width: 150)
                }
            }
            .padding()

            ZStack {
                Canvas { context, _ in
                    let colors: [Color] = [.blue, .green, .orange, .purple, .red, .cyan]

                    if currentScene.isGraph {
                        // Build graph from current vertices state
                        let graph = Scene.buildGraph(vertices: graphVertices, edgeIndices: currentScene.graphEdgeIndices)

                        // Thicken the graph
                        let atoms = thickenGraph(
                            graph,
                            width: lineWidth,
                            joinStyle: joinStyle,
                            capStyle: capStyle
                        )

                        let paths = renderAsTriangles ? atoms.toTriangles(pixelsPerSegment: pixelsPerSegment) : atoms.map { $0.toPath() }

                        // Draw all paths
                        for (i, path) in paths.enumerated() {
                            let color = colors[i % colors.count]
                            context.fill(path, with: .color(color.opacity(0.4)))
                            context.stroke(path, with: .color(.black), lineWidth: 1)
                        }

                        // Draw graph edges as red reference lines
                        var linePath = Path()
                        for edge in graph.edges {
                            linePath.move(to: edge.from)
                            linePath.addLine(to: edge.to)
                        }
                        context.stroke(linePath, with: .color(.red), lineWidth: 1)
                    } else {
                        // Get atoms from junction or polyline
                        let atoms: [Atom]
                        if let center = junctionCenter {
                            atoms = thickenJunction(
                                center: center,
                                endpoints: junctionEndpoints,
                                width: lineWidth,
                                joinStyle: joinStyle,
                                capStyle: capStyle
                            )
                        } else {
                            atoms = thickenPolyline(
                                points: points,
                                width: lineWidth,
                                joinStyle: joinStyle,
                                capStyle: capStyle,
                                closed: closePath
                            )
                        }

                        let paths = renderAsTriangles ? atoms.toTriangles(pixelsPerSegment: pixelsPerSegment) : atoms.map { $0.toPath() }

                        // Draw all paths
                        for (i, path) in paths.enumerated() {
                            let color = colors[i % colors.count]
                            context.fill(path, with: .color(color.opacity(0.4)))
                            context.stroke(path, with: .color(.black), lineWidth: 1)
                        }

                        // Draw original polyline/junction (1px reference)
                        var linePath = Path()
                        if let center = junctionCenter {
                            for endpoint in junctionEndpoints {
                                linePath.move(to: center)
                                linePath.addLine(to: endpoint)
                            }
                        } else if let first = points.first {
                            linePath.move(to: first)
                            for point in points.dropFirst() {
                                linePath.addLine(to: point)
                            }
                        }
                        context.stroke(linePath, with: .color(.red), lineWidth: 1)
                    }
                }

                // Draggable handles
                if currentScene.isGraph {
                    ForEach(graphVertices.indices, id: \.self) { index in
                        DragHandle(position: $graphVertices[index])
                    }
                } else {
                    ForEach(points.indices, id: \.self) { index in
                        DragHandle(position: $points[index])
                    }
                }
            }
        }
        .background(.white)
    }
}

#Preview {
    ContentView()
        .frame(width: 500, height: 450)
}
