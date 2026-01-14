import DemoKit
import Geometry
import Interaction
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
        var segment: LineSegment
    }

    @State private var segments: [TypedLineSegment] = [
        TypedLineSegment(id: "1", type: "primary", segment: LineSegment(start: [100, 100], end: [300, 100])),
        TypedLineSegment(id: "2", type: "secondary", segment: LineSegment(start: [100, 150], end: [300, 200])),
        TypedLineSegment(id: "3", type: "primary", segment: LineSegment(start: [150, 50], end: [150, 250]))
    ]

    var body: some View {
        ZStack {
            Canvas { context, _ in
                for segment in segments {
                    let color: Color = segment.type == "primary" ? .blue : .orange
                    var path = Path()
                    path.move(to: segment.segment.start)
                    path.addLine(to: segment.segment.end)
                    context.stroke(path, with: .color(color), lineWidth: 2)

                    // Draw endpoints
                    context.fill(
                        Path(ellipseIn: CGRect(center: segment.segment.start, size: [8, 8])),
                        with: .color(color)
                    )
                    context.fill(
                        Path(ellipseIn: CGRect(center: segment.segment.end, size: [8, 8])),
                        with: .color(color)
                    )
                }
            }
            .allowsHitTesting(false)

            InteractiveCanvas(elements: $segments, id: \.id)
        }
        .background(.white)
    }
}

// MARK: - InteractiveRepresentable

extension LineSegmentsDemoView.TypedLineSegment: InteractiveRepresentable {
    typealias HandleID = LineSegment.HandleID

    func makeHandles() -> [InteractiveHandle<HandleID>] {
        segment.makeHandles()
    }

    mutating func handleDidChange(id: HandleID, handles: inout [HandleID: InteractiveHandle<HandleID>]) {
        segment.handleDidChange(id: id, handles: &handles)
    }
}
