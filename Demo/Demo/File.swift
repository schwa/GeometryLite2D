import SwiftUI
import Geometry
import Visualization

extension Identified: @retroactive Equatable where Value: Equatable {
    public static func == (lhs: Identified, rhs: Identified) -> Bool {
        lhs.id == rhs.id && lhs.value == rhs.value
    }
}

extension Identified: @retroactive VisualizationRepresentable where Value: VisualizationRepresentable {
    public var boundingRect: CGRect {
        return value.boundingRect
    }

    public func visualize(in context: GraphicsContext, style: Visualization.VisualizationStyle, transform: CGAffineTransform) {
        value.visualize(in: context, style: style, transform: transform)
    }
}

enum Shape {
    case lineSegment(LineSegment)
    case circle(Circle_)
}

extension Shape: Equatable {
    static func == (lhs: Shape, rhs: Shape) -> Bool {
        switch (lhs, rhs) {
        case (.lineSegment(let lhs), .lineSegment(let rhs)):
            return lhs == rhs
        case (.circle(let lhs), .circle(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension Shape: VisualizationRepresentable {
    var boundingRect: CGRect {
        switch self {
        case .lineSegment(let segment):
            return segment.boundingRect
        case .circle(let circle):
            return circle.boundingRect
        }
    }

    func visualize(in context: GraphicsContext, style: Visualization.VisualizationStyle, transform: CGAffineTransform) {
        switch self {
        case .lineSegment(let segment):
            segment.visualize(in: context, style: style, transform: transform)
        case .circle(let circle):
            circle.visualize(in: context, style: style, transform: transform)
        }
    }
}
