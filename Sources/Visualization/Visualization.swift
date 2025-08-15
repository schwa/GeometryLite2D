import SwiftUI

public protocol VisualizationRepresentable {
    var boundingRect: CGRect { get }
    func visualize(in context: GraphicsContext, style: VisualizationStyle, transform: CGAffineTransform)
}

public struct VisualizationStyle {
    public var stroke: GraphicsContext.Shading?
    public var strokeStyle: StrokeStyle?
    public var fill: GraphicsContext.Shading?
    public var fillStyle: FillStyle?

    public init(stroke: GraphicsContext.Shading? = nil, strokeStyle: StrokeStyle? = nil, fill: GraphicsContext.Shading? = nil, fillStyle: FillStyle? = nil) {
        self.stroke = stroke
        self.strokeStyle = strokeStyle
        self.fill = fill
        self.fillStyle = fillStyle
    }
}

public extension VisualizationStyle {
    init() {
        self.stroke = .color(.black)
        self.strokeStyle = .init(lineWidth: 1)
        self.fill = .color(.clear)
        self.fillStyle = nil
    }

    init(stroke: GraphicsContext.Shading? = nil, lineWidth: Double, fill: GraphicsContext.Shading? = nil, fillStyle: FillStyle? = nil) {
        self.stroke = stroke
        self.strokeStyle = .init(lineWidth: lineWidth)
        self.fill = fill
        self.fillStyle = fillStyle
    }
}

extension Path: VisualizationRepresentable {
    public func visualize(in context: GraphicsContext, style: VisualizationStyle, transform: CGAffineTransform) {
        let path = self.applying(transform)

        // Fill first (so stroke appears on top)
        if let fillShading = style.fill {
            context.fill(path, with: fillShading, style: style.fillStyle ?? .init())
        }

        // Then stroke
        if let strokeShading = style.stroke {
            context.stroke(path, with: strokeShading, style: style.strokeStyle ?? .init())
        }
    }
}
