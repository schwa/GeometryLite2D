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

extension LineSegment: VisualizationRepresentable {}

extension Polygon: VisualizationRepresentable {}

extension Circle: VisualizationRepresentable {
    public var boundingRect: CGRect {
        CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
    }
    
    public func visualize(in context: GraphicsContext, style: VisualizationStyle, transform: CGAffineTransform) {
        let path = Path(ellipseIn: boundingRect).applying(transform)
        if let fillShading = style.fill {
            context.fill(path, with: fillShading, style: style.fillStyle ?? .init())
        }

        if let strokeShading = style.stroke {
            context.stroke(path, with: strokeShading, style: style.strokeStyle ?? .init())
        }
    }
}

extension Ray: VisualizationRepresentable {
    public var boundingRect: CGRect {
        // For visualization, we'll show a ray segment extending a reasonable distance
        let endPoint = origin + direction.normalized * 100
        return CGRect.boundingRect(of: [origin, endPoint])
    }
    
    public func visualize(in context: GraphicsContext, style: VisualizationStyle, transform: CGAffineTransform) {
        // Visualize ray as a line segment with an arrow
        let endPoint = origin + direction.normalized * 100
        let segment = LineSegment(start: origin, end: endPoint)
        
        let path = Path(representable: segment).applying(transform)
        if let strokeShading = style.stroke {
            context.stroke(path, with: strokeShading, style: style.strokeStyle ?? .init())
        }
        
        // Add arrow head
        let arrowSize: CGFloat = 8
        let arrowAngle: CGFloat = .pi / 6
        
        let transformedEnd = endPoint.applying(transform)
        let transformedDirection = (endPoint - origin).applying(transform.withoutTranslation)
        let directionAngle = atan2(transformedDirection.y, transformedDirection.x)
        
        var arrowPath = Path()
        let arrowPoint1 = CGPoint(
            x: transformedEnd.x - arrowSize * cos(directionAngle - arrowAngle),
            y: transformedEnd.y - arrowSize * sin(directionAngle - arrowAngle)
        )
        let arrowPoint2 = CGPoint(
            x: transformedEnd.x - arrowSize * cos(directionAngle + arrowAngle),
            y: transformedEnd.y - arrowSize * sin(directionAngle + arrowAngle)
        )
        
        arrowPath.move(to: transformedEnd)
        arrowPath.addLine(to: arrowPoint1)
        arrowPath.move(to: transformedEnd)
        arrowPath.addLine(to: arrowPoint2)
        
        if let strokeShading = style.stroke {
            context.stroke(arrowPath, with: strokeShading, style: style.strokeStyle ?? .init())
        }
    }
}

extension Line: VisualizationRepresentable {
    public var boundingRect: CGRect {
        // For visualization, we'll show a line segment extending a reasonable distance in both directions
        let distance: CGFloat = 100
        let point1 = point - direction.normalized * distance
        let point2 = point + direction.normalized * distance
        return CGRect.boundingRect(of: [point1, point2])
    }
    
    public func visualize(in context: GraphicsContext, style: VisualizationStyle, transform: CGAffineTransform) {
        // Visualize line as a long segment
        let distance: CGFloat = 100
        let point1 = point - direction.normalized * distance
        let point2 = point + direction.normalized * distance
        let segment = LineSegment(start: point1, end: point2)
        
        let path = Path(representable: segment).applying(transform)
        if let strokeShading = style.stroke {
            context.stroke(path, with: strokeShading, style: style.strokeStyle ?? .init())
        }
    }
}

// MARK: - Helper Extensions

extension CGAffineTransform {
    var withoutTranslation: CGAffineTransform {
        CGAffineTransform(a: a, b: b, c: c, d: d, tx: 0, ty: 0)
    }
}

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

@MainActor
@discardableResult
public func visualize(_ elements: [any PathRepresentable], scaleToFit: Bool = false) -> CGImage {
    let paths = elements.map { element in
        Path(representable: element)
    }
    return Visualization.visualize(paths: paths, scaleToFit: scaleToFit)
}