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

    @State private var snappingEnabled = false
    @State private var shiftKeyDown = false
    @State private var selection: Set<String> = []
    @State private var selectionBeforeMarquee: Set<String> = []
    @State private var marqueeStart: CGPoint?
    @State private var marqueeEnd: CGPoint?

    private let snapRadius: CGFloat = 10

    private var segmentsAsCSV: String {
        var csv = "id,type,start_x,start_y,end_x,end_y\n"
        for segment in segments {
            csv += "\(segment.id),\(segment.type),\(segment.segment.start.x),\(segment.segment.start.y),\(segment.segment.end.x),\(segment.segment.end.y)\n"
        }
        return csv
    }

    private var snapClosure: ((CGPoint, [CGPoint]) -> CGPoint)? {
        guard snappingEnabled else { return nil }
        return { point, targets in
            var closest: CGPoint = point
            var closestDistance: CGFloat = self.snapRadius
            for target in targets {
                let distance = hypot(target.x - point.x, target.y - point.y)
                if distance < closestDistance {
                    closest = target
                    closestDistance = distance
                }
            }
            return closest
        }
    }

    private func updateSelectionFromMarquee() {
        guard let rect = marqueeRect else { return }
        var newSelection = selectionBeforeMarquee
        for segment in segments {
            // Select if either endpoint is in the marquee, or if the segment intersects the marquee
            if rect.contains(segment.segment.start) || rect.contains(segment.segment.end) || segmentIntersectsRect(segment.segment, rect) {
                newSelection.insert(segment.id)
            }
        }
        selection = newSelection
    }

    private func segmentIntersectsRect(_ segment: LineSegment, _ rect: CGRect) -> Bool {
        // Check if segment intersects any edge of the rect
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)

        let edges = [
            LineSegment(start: topLeft, end: topRight),
            LineSegment(start: topRight, end: bottomRight),
            LineSegment(start: bottomRight, end: bottomLeft),
            LineSegment(start: bottomLeft, end: topLeft)
        ]

        for edge in edges {
            if segmentsIntersect(segment, edge) {
                return true
            }
        }
        return false
    }

    private func segmentsIntersect(_ a: LineSegment, _ b: LineSegment) -> Bool {
        func cross(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
            (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
        }

        let d1 = cross(b.start, b.end, a.start)
        let d2 = cross(b.start, b.end, a.end)
        let d3 = cross(a.start, a.end, b.start)
        let d4 = cross(a.start, a.end, b.end)

        if ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
           ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0)) {
            return true
        }
        return false
    }

    private let hitTolerance: CGFloat = 5

    private func segmentAt(_ point: CGPoint) -> TypedLineSegment? {
        for segment in segments {
            if point.distance(to: segment.segment) <= hitTolerance {
                return segment
            }
        }
        return nil
    }

    private var marqueeRect: CGRect? {
        guard let start = marqueeStart, let end = marqueeEnd else { return nil }
        return CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
    }

    var body: some View {
        ZStack {
            Canvas { context, _ in
                for segment in segments {
                    let isSelected = selection.contains(segment.id)
                    let baseColor: Color = segment.type == "primary" ? .blue : .orange
                    let color: Color = isSelected ? .accentColor : baseColor
                    let lineWidth: CGFloat = isSelected ? 3 : 2

                    var path = Path()
                    path.move(to: segment.segment.start)
                    path.addLine(to: segment.segment.end)
                    context.stroke(path, with: .color(color), lineWidth: lineWidth)

                    // Draw endpoints
                    let endpointSize: CGFloat = isSelected ? 10 : 8
                    context.fill(
                        Path(ellipseIn: CGRect(center: segment.segment.start, size: [endpointSize, endpointSize])),
                        with: .color(color)
                    )
                    context.fill(
                        Path(ellipseIn: CGRect(center: segment.segment.end, size: [endpointSize, endpointSize])),
                        with: .color(color)
                    )
                }

                // Draw selection marquee
                if let rect = marqueeRect {
                    context.stroke(Path(rect), with: .color(.accentColor), lineWidth: 1)
                    context.fill(Path(rect), with: .color(.accentColor.opacity(0.1)))
                }
            }
            .allowsHitTesting(false)

            // Marquee selection layer
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            if marqueeStart == nil {
                                marqueeStart = value.startLocation
                                selectionBeforeMarquee = shiftKeyDown ? selection : []
                            }
                            marqueeEnd = value.location
                            updateSelectionFromMarquee()
                        }
                        .onEnded { _ in
                            marqueeStart = nil
                            marqueeEnd = nil
                        }
                )
                .onTapGesture { location in
                    if let tappedSegment = segmentAt(location) {
                        if shiftKeyDown {
                            if selection.contains(tappedSegment.id) {
                                selection.remove(tappedSegment.id)
                            } else {
                                selection.insert(tappedSegment.id)
                            }
                        } else {
                            selection = [tappedSegment.id]
                        }
                    } else {
                        selection.removeAll()
                    }
                }

            InteractiveCanvas(elements: $segments, id: \.id, snap: snapClosure)

            VStack {
                Spacer()
                Text("Snapping (⌥): \(snappingEnabled ? "On" : "Off")")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
                    .padding(.bottom, 8)
            }
        }
        .background(.white)
        .focusable()
        .copyable([segmentsAsCSV])
        .onModifierKeysChanged { _, new in
            snappingEnabled = new.contains(.option)
            shiftKeyDown = new.contains(.shift)
        }
        .inspector(isPresented: .constant(true)) {
            List(segments, selection: $selection) { segment in
                VStack(alignment: .leading) {
                    Text(segment.id)
                        .font(.headline)
                    Text("Type: \(segment.type)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Start: (\(segment.segment.start.x, specifier: "%.1f"), \(segment.segment.start.y, specifier: "%.1f"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("End: (\(segment.segment.end.x, specifier: "%.1f"), \(segment.segment.end.y, specifier: "%.1f"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
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
