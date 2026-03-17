import DemoKit
import Geometry
import Interaction
import SwiftUI
import Voronoi

struct VoronoiDemoView: DemoView {
    static var metadata = DemoMetadata(
        type: Self.self,
        description: "Voronoi diagrams and Delaunay triangulation",
        keywords: ["voronoi", "delaunay", "triangulation", "diagram"]
    )

    init() {}

    struct Options {
        var drawConvexHull: Bool = false
        var drawTriangulation: Bool = true
        var drawCircumcircles: Bool = false
        var drawVoronoi: Bool = true
        var drawVoronoiCells: Bool = true
    }

    @State var points: [CGPoint] = [
        CGPoint(x: 0.51, y: 0.5),
        CGPoint(x: 0.8, y: 0.6),
        CGPoint(x: 0.8, y: 0.4),
        CGPoint(x: 0.2, y: 0.4),
        CGPoint(x: 0.2, y: 0.6),
        CGPoint(x: 0.62, y: 0.86),
        CGPoint(x: 0.80, y: 0.65),
        CGPoint(x: 0.85, y: 0.45),
        CGPoint(x: 0.68, y: 0.28),
        CGPoint(x: 0.50, y: 0.20),
        CGPoint(x: 0.30, y: 0.30),
        CGPoint(x: 0.22, y: 0.50),
        CGPoint(x: 0.32, y: 0.68),
        CGPoint(x: 0.48, y: 0.74),
        CGPoint(x: 0.66, y: 0.68)
    ]

    @State var triangles: [Triangle] = []
    @State var convexHullPoints: [CGPoint] = []
    @State var voronoiEdges: [VoronoiEdge] = []
    @State var size: CGSize = .zero
    @State var zoom: CGFloat = 1.0
    @State var gestureZoom: CGFloat = 1.0
    @State var options: Options = Options()

    var body: some View {
        let scale = min(size.width, size.height) * zoom * gestureZoom
        VStack {
            HStack {
                Button("Random Points") {
                    generateRandomPoints()
                }
                Button("Clear") {
                    points.removeAll()
                }
                Spacer()
            }
            .padding(.horizontal)

            ZStack {
                Canvas { context, size in
                    render(context: context, size: size, scale: scale)
                }

                ForEach(Array(points.enumerated()), id: \.0) { index, point in
                    Circle().frame(width: 10, height: 10)
                        .foregroundColor(.black)
                        .position(x: point.x * scale, y: point.y * scale)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    points[index] = CGPoint(
                                        x: value.location.x / scale,
                                        y: value.location.y / scale
                                    )
                                }
                        )
                        .contextMenu {
                            Button("Delete") {
                                points.remove(at: index)
                            }
                        }
                }
            }
            .onChange(of: points, initial: true) {
                triangles = delaunayTriangulation(points)
                convexHullPoints = Geometry.convexHull(points)
                voronoiEdges = computeVoronoiEdges(from: triangles)
            }
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        gestureZoom = max(value.magnification, 0.01)
                    }
                    .onEnded { _ in
                        zoom = gestureZoom
                        gestureZoom = 1.0
                    }
            )
            .onGeometryChange(for: CGSize.self, of: \.size) { size = $0 }
            .contentShape(Rectangle())
            .onTapGesture { location in
                let newPoint = CGPoint(
                    x: location.x / scale,
                    y: location.y / scale
                )
                points.append(newPoint)
            }
            .overlay(alignment: .bottomTrailing) {
                optionsPanel()
            }
        }
        .background(.white)
    }

    @ViewBuilder
    func optionsPanel() -> some View {
        Form {
            Toggle("Convex Hull", isOn: $options.drawConvexHull)
            Toggle("Triangulation", isOn: $options.drawTriangulation)
            Toggle("Circumcircles", isOn: $options.drawCircumcircles)
            Toggle("Voronoi Edges", isOn: $options.drawVoronoi)
            Toggle("Voronoi Cells", isOn: $options.drawVoronoiCells)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .padding()
        .frame(width: 200)
    }

    func generateRandomPoints() {
        let count = Int.random(in: 10...20)
        let newPoints = (0..<count).map { _ in
            CGPoint(
                x: CGFloat.random(in: 0.1...0.9),
                y: CGFloat.random(in: 0.1...0.9)
            )
        }
        points.append(contentsOf: newPoints)
    }

    func render(context: GraphicsContext, size: CGSize, scale: CGFloat) {
        let transform = CGAffineTransform(scaleX: scale, y: scale)

        // Draw Voronoi cells (colored regions)
        if options.drawVoronoiCells {
            let polygons = computeInteriorVoronoiCells(points: points, edges: voronoiEdges, triangles: triangles)
            for (point, polygon) in polygons {
                guard let polygon else { continue }
                let path = polygon.makePath().applying(transform)
                context.fill(path, with: .color(Color(forHashable: point).opacity(0.2)))
            }
        }

        // Draw convex hull
        if options.drawConvexHull {
            var hullPath = Path()
            hullPath.addLines(convexHullPoints)
            hullPath.closeSubpath()
            context.stroke(hullPath.applying(transform), with: .color(.red), lineWidth: 2)
        }

        // Draw triangulation
        for triangle in triangles {
            if options.drawTriangulation {
                context.stroke(
                    Path(triangle).applying(transform),
                    with: .color(.cyan),
                    lineWidth: 1
                )
            }

            if options.drawCircumcircles {
                if let circle = triangle.circumcircle {
                    let circleRect = CGRect(
                        x: circle.center.x - circle.radius,
                        y: circle.center.y - circle.radius,
                        width: circle.radius * 2,
                        height: circle.radius * 2
                    )
                    context.stroke(
                        Path(ellipseIn: circleRect).applying(transform),
                        with: .color(.green),
                        lineWidth: 0.5
                    )
                }
            }
        }

        // Draw Voronoi edges
        if options.drawVoronoi {
            for edge in voronoiEdges {
                context.stroke(
                    Path(edge, maxRayLength: 1000).applying(transform),
                    with: .color(.blue),
                    lineWidth: 1.0
                )
            }
        }
    }
}

// Helper to generate consistent colors from hashable values
extension Color {
    init(forHashable hashable: some Hashable) {
        var hash = Hasher()
        hashable.hash(into: &hash)
        let value = hash.finalize()
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    VoronoiDemoView()
        .frame(width: 800, height: 600)
}
