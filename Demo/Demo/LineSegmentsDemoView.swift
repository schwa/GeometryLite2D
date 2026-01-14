import DemoKit
import Geometry
import SwiftUI
import Visualization

struct LineSegmentsDemoView: DemoView {
    static var metadata = DemoMetadata(
        type: Self.self,
        description: "Canvas with typed line segments",
        keywords: ["line", "segment", "canvas"]
    )

    init() {}

    struct TypedLineSegment: Identifiable, Equatable {
        var id: String
        var type: String
        var start: CGPoint
        var end: CGPoint
    }

    @State private var segments: [TypedLineSegment] = [
        TypedLineSegment(id: "1", type: "primary", start: [100, 100], end: [300, 100]),
        TypedLineSegment(id: "2", type: "secondary", start: [100, 150], end: [300, 200]),
        TypedLineSegment(id: "3", type: "primary", start: [150, 50], end: [150, 250])
    ]

    var body: some View {
        Canvas { context, _ in
            for segment in segments {
                let color: Color = segment.type == "primary" ? .blue : .orange
                var path = Path()
                path.move(to: segment.start)
                path.addLine(to: segment.end)
                context.stroke(path, with: .color(color), lineWidth: 2)

                // Draw endpoints
                context.fill(
                    Path(ellipseIn: CGRect(center: segment.start, size: [8, 8])),
                    with: .color(color)
                )
                context.fill(
                    Path(ellipseIn: CGRect(center: segment.end, size: [8, 8])),
                    with: .color(color)
                )
            }
        }
        .background(.white)
    }
}
