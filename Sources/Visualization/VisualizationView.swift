import SwiftUI

public struct VisualizationView: View {
    let elements: [([any VisualizationRepresentable], VisualizationStyle)]
    let scaleToFit: Bool

    public init(elements: [([any VisualizationRepresentable], VisualizationStyle)], scaleToFit: Bool = false) {
        self.elements = elements
        self.scaleToFit = scaleToFit
    }

    public var body: some View {
        let info = layoutInfo

        Canvas { context, size in
            drawAxes(context: context, size: size, info: info)
            drawOriginLabel(context: context, info: info)
            for (representables, style) in elements {
                for representable in representables {
                    representable.visualize(in: context, style: style, transform: info.transform)
                }
            }
        } symbols: {
            // Origin label symbol
            Text("(0, 0)")
                .font(.footnote)
                .foregroundColor(.black)
                .tag("origin")
        }
        .frame(width: info.canvasSize.width, height: info.canvasSize.height)
        .padding()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .padding()
    }

    private var layoutInfo: (bounds: CGRect, canvasSize: CGSize, transform: CGAffineTransform, originOffset: CGPoint) {
        // Collect all bounding rects from elements
        var allBounds: [CGRect] = []
        for (representables, _) in elements {
            for representable in representables {
                allBounds.append(representable.boundingRect)
            }
        }

        guard !allBounds.isEmpty else {
            return (CGRect(x: 0, y: 0, width: 100, height: 100), CGSize(width: 200, height: 200), .identity, .zero)
        }

        var unionBounds = allBounds[0]
        for bounds in allBounds.dropFirst() {
            unionBounds = unionBounds.union(bounds)
        }
        unionBounds = unionBounds.union(CGRect(x: 0, y: 0, width: 0.1, height: 0.1))

        let margin: CGFloat = 20
        let targetSize: CGFloat = 200

        if scaleToFit {
            // Scale content to fit within target size
            let contentWidth = unionBounds.width
            let contentHeight = unionBounds.height

            // Calculate scale to fit within target size (minus margins)
            let availableSize = targetSize - (margin * 2)
            let scaleX = contentWidth > 0 ? availableSize / contentWidth : 1
            let scaleY = contentHeight > 0 ? availableSize / contentHeight : 1
            let scale = min(scaleX, scaleY) // Take the smaller scale to fit both dimensions

            // Apply scale and center
            let scaledWidth = contentWidth * scale
            let scaledHeight = contentHeight * scale
            let xOffset = (targetSize - scaledWidth) / 2
            let yOffset = (targetSize - scaledHeight) / 2

            let transform = CGAffineTransform(translationX: -unionBounds.minX, y: -unionBounds.minY)
                .scaledBy(x: scale, y: scale)
                .translatedBy(x: xOffset / scale, y: yOffset / scale)

            return (unionBounds, CGSize(width: targetSize, height: targetSize), transform, .zero)
        }
        let canvasSize = CGSize(width: max(targetSize, unionBounds.width + margin * 2),
                                height: max(targetSize, unionBounds.height + margin * 2))
        let transform = CGAffineTransform(translationX: margin - unionBounds.minX, y: margin - unionBounds.minY)
        return (unionBounds, canvasSize, transform, .zero)
    }

    private func drawAxes(context: GraphicsContext, size: CGSize, info: (bounds: CGRect, canvasSize: CGSize, transform: CGAffineTransform, originOffset: CGPoint)) {
        // Calculate where the actual 0 axes appear in canvas coordinates
        let originInCanvas = CGPoint.zero.applying(info.transform)

        // Draw X-axis (horizontal line through y=0)
        var xAxisPath = Path()
        xAxisPath.move(to: CGPoint(x: 0, y: originInCanvas.y))
        xAxisPath.addLine(to: CGPoint(x: size.width, y: originInCanvas.y))
        context.stroke(xAxisPath, with: .color(.gray.opacity(0.3)), lineWidth: 0.5)

        // Draw Y-axis (vertical line through x=0)
        var yAxisPath = Path()
        yAxisPath.move(to: CGPoint(x: originInCanvas.x, y: 0))
        yAxisPath.addLine(to: CGPoint(x: originInCanvas.x, y: size.height))
        context.stroke(yAxisPath, with: .color(.gray.opacity(0.3)), lineWidth: 0.5)
    }

    private func drawOriginLabel(context: GraphicsContext, info: (bounds: CGRect, canvasSize: CGSize, transform: CGAffineTransform, originOffset: CGPoint)) {
        let origin = CGPoint.zero.applying(info.transform)
        if let originLabel = context.resolveSymbol(id: "origin") {
            let labelOffset = CGPoint(x: 15, y: -15)
            context.draw(originLabel, at: CGPoint(x: origin.x + labelOffset.x, y: origin.y + labelOffset.y))
        }
    }
}

public extension VisualizationView {
    init(paths: [Path], scaleToFit: Bool = false) {
        let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink]
        var elements: [([any VisualizationRepresentable], VisualizationStyle)] = []

        for (index, path) in paths.enumerated() {
            let color = colors[index % colors.count]
            let style = VisualizationStyle(
                stroke: .color(color),
                strokeStyle: StrokeStyle(lineWidth: 2)
            )
            elements.append(([path], style))
        }

        self.init(elements: elements, scaleToFit: scaleToFit)
    }
}

@MainActor
@discardableResult
public func visualize(_ elements: [([any VisualizationRepresentable], VisualizationStyle)], scaleToFit: Bool = false) -> CGImage {
    let view = VisualizationView(elements: elements, scaleToFit: scaleToFit)
    let renderer = ImageRenderer(content: view)
    #if os(macOS)
    renderer.scale = NSScreen.main?.backingScaleFactor ?? 1.0
    #endif
    return renderer.cgImage!
}

@MainActor
@discardableResult
public func visualize(paths: [Path], scaleToFit: Bool = false) -> CGImage {
    let view = VisualizationView(paths: paths, scaleToFit: scaleToFit)
    let renderer = ImageRenderer(content: view)
    #if os(macOS)
    renderer.scale = NSScreen.main?.backingScaleFactor ?? 1.0
    #endif
    return renderer.cgImage!
}

// MARK: - Core Types Extensions

extension CGPoint: VisualizationRepresentable {
    public var boundingRect: CGRect {
        CGRect(center: self, size: CGSize(width: 4, height: 4))
    }

    public func visualize(in context: GraphicsContext, style: VisualizationStyle, transform: CGAffineTransform) {
        let point = self.applying(transform)

        let path = Path { path in
            // draw a small circle around the point
            path.addEllipse(in: CGRect(center: point, size: CGSize(width: 4, height: 4)))
        }
        if let stroke = style.stroke {
            context.fill(path, with: stroke)
        }
    }
}

extension CGRect {
    public init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2), size: size)
    }
}
