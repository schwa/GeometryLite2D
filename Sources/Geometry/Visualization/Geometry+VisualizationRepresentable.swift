import SwiftUI
import Visualization

// MARK: - PathRepresentable Extension

extension VisualizationRepresentable where Self: PathRepresentable {
    public var boundingRect: CGRect {
        Path(representable: self).boundingRect
    }

    public func visualize(in context: GraphicsContext, style: VisualizationStyle, transform: CGAffineTransform) {
        let path = Path(representable: self).applying(transform)
        if let fillShading = style.fill {
            context.fill(path, with: fillShading, style: style.fillStyle ?? .init())
        }

        if let strokeShading = style.stroke {
            context.stroke(path, with: strokeShading, style: style.strokeStyle ?? .init())
        }
    }
}

// MARK: - Geometry Type Conformances

extension LineSegment: VisualizationRepresentable {
}

extension Polygon: VisualizationRepresentable {
}

extension Circle: VisualizationRepresentable {
}

extension Line: VisualizationRepresentable {
}

// MARK: - Helper Extensions

extension CGRect {
    static func boundingRect(of points: [CGPoint]) -> CGRect {
        guard !points.isEmpty else { return .zero }
        
        let xs = points.map { $0.x }
        let ys = points.map { $0.y }
        
        let minX = xs.min()!
        let maxX = xs.max()!
        let minY = ys.min()!
        let maxY = ys.max()!
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

// MARK: - Convenience Visualization Functions

// TODO: DEPRECATE
@MainActor
@discardableResult
public func visualize(_ elements: [any PathRepresentable], scaleToFit: Bool = false) -> CGImage {
    let paths = elements.map { element in
        Path(representable: element)
    }
    return Visualization.visualize(paths: paths, scaleToFit: scaleToFit)
}
