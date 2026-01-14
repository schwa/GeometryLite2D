import Geometry
import SwiftUI

// MARK: - InsertLineModifier

struct InsertLineModifier: ViewModifier {
    let transform: CGAffineTransform
    let snapTargets: [CGPoint]
    let snap: ((CGPoint, [CGPoint]) -> CGPoint)?
    let onInsert: (LineSegment) -> Void

    @State private var lineStart: CGPoint?
    @State private var lineEnd: CGPoint?

    private func snappedWorldPoint(_ screenPoint: CGPoint) -> CGPoint {
        var worldPoint = screenPoint.applying(transform.inverted())
        if let snap {
            worldPoint = snap(worldPoint, snapTargets)
        }
        return worldPoint
    }

    private func worldToScreen(_ worldPoint: CGPoint) -> CGPoint {
        worldPoint.applying(transform)
    }

    private var currentLine: LineSegment? {
        guard let start = lineStart, let end = lineEnd else { return nil }
        let worldStart = snappedWorldPoint(start)
        let worldEnd = snappedWorldPoint(end)
        return LineSegment(start: worldStart, end: worldEnd)
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                Canvas { context, _ in
                    if let start = lineStart, let end = lineEnd {
                        // Draw in screen space but use snapped positions
                        let snappedStart = worldToScreen(snappedWorldPoint(start))
                        let snappedEnd = worldToScreen(snappedWorldPoint(end))

                        var path = Path()
                        path.move(to: snappedStart)
                        path.addLine(to: snappedEnd)
                        context.stroke(path, with: .color(.accentColor), style: StrokeStyle(lineWidth: 2, dash: [5, 3]))

                        // Draw endpoints
                        context.fill(
                            Path(ellipseIn: CGRect(x: snappedStart.x - 4, y: snappedStart.y - 4, width: 8, height: 8)),
                            with: .color(.accentColor)
                        )
                        context.fill(
                            Path(ellipseIn: CGRect(x: snappedEnd.x - 4, y: snappedEnd.y - 4, width: 8, height: 8)),
                            with: .color(.accentColor)
                        )
                    }
                }
                .allowsHitTesting(false)
            }
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        if lineStart == nil {
                            lineStart = value.startLocation
                        }
                        lineEnd = value.location
                    }
                    .onEnded { _ in
                        if let line = currentLine, line.length > 1 {
                            onInsert(line)
                        }
                        lineStart = nil
                        lineEnd = nil
                    }
            )
    }
}

// MARK: - View Extension

extension View {
    func insertLineTool(
        transform: CGAffineTransform,
        snapTargets: [CGPoint],
        snap: ((CGPoint, [CGPoint]) -> CGPoint)?,
        onInsert: @escaping (LineSegment) -> Void
    ) -> some View {
        modifier(InsertLineModifier(
            transform: transform,
            snapTargets: snapTargets,
            snap: snap,
            onInsert: onInsert
        ))
    }
}
