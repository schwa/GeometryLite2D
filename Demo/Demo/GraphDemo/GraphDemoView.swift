import DemoKit
import Geometry
import GeometryCollections
import Interaction
import SwiftFormats
import SwiftUI
import Visualization

struct GraphDemoView: DemoView {
    static var metadata = DemoMetadata(
        type: Self.self,
        description: "Graph editor with segments, selection, and transforms",
        keywords: ["graph", "segment", "canvas", "selection"]
    )

    init() {}

    struct TypedLineSegment: Identifiable, Equatable {
        var id: String
        var type: String
        var segment: LineSegment
    }

    enum ColorMode: String, CaseIterable {
        case none = "None"
        case byID = "By ID"
        case byType = "By Type"
        case byLength = "By Length"
        case byDegree = "By Degree"
        case byComponent = "By Component"
    }

    enum Tool: String, CaseIterable {
        case select = "Select"
        case insertLine = "Insert Line"
    }

    struct SnapOptions: OptionSet {
        let rawValue: Int
        static let endpoints = SnapOptions(rawValue: 1 << 0)
        static let lines = SnapOptions(rawValue: 1 << 1)
        static let grid = SnapOptions(rawValue: 1 << 2)
    }

    @State private var currentTool: Tool = .select
    @State private var showInspector: Bool = true
    @State private var snapOptions: SnapOptions = [.endpoints, .grid]

    @State private var segments: [TypedLineSegment] = [
        TypedLineSegment(id: "1", type: "primary", segment: LineSegment(start: [100, 100], end: [300, 100])),
        TypedLineSegment(id: "2", type: "secondary", segment: LineSegment(start: [100, 150], end: [300, 200])),
        TypedLineSegment(id: "3", type: "primary", segment: LineSegment(start: [150, 50], end: [150, 100])) // T-junction with segment 1
    ]

    @State private var optionKeyDown = false
    @State private var shiftKeyDown = false
    @State private var colorMode: ColorMode = .byType
    @State private var selection: Set<String> = []
    @State private var shortIDs: [AnyHashable: Int] = [:]

    // Region of interest - the world coordinate space we're viewing
    @State private var regionOfInterest: CGRect = CGRect(x: 0, y: 0, width: 1000, height: 1000)

    // View transform state
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Angle = .zero

    // Gesture state
    @State private var lastScale: CGFloat = 1.0
    @State private var lastRotation: Angle = .zero
    @State private var viewSize: CGSize = CGSize(width: 600, height: 400)
    @State private var scrollPosition: ScrollPosition = .init(point: .zero)

    private let snapRadius: CGFloat = 10

    private func regenerateShortIDs() {
        var newShortIDs: [AnyHashable: Int] = [:]
        for (index, segment) in segments.enumerated() {
            newShortIDs[segment.id] = index + 1
        }
        shortIDs = newShortIDs
    }

    private func displayID(for id: String) -> String {
        if let shortID = shortIDs[id] {
            return "Edge-\(shortID)"
        }
        return id
    }

    private func color(for segment: TypedLineSegment) -> Color {
        switch colorMode {
        case .none:
            return .black
        case .byID:
            return Color(glasbeyIndex: abs(segment.id.hashValue))
        case .byType:
            return Color(glasbeyIndex: abs(segment.type.hashValue))
        case .byLength:
            return colorForLength(segment.segment)
        case .byDegree:
            return colorForDegree(segment.segment)
        case .byComponent:
            return colorForComponent(segment.segment)
        }
    }

    private let shortColor: Color = .blue
    private let longColor: Color = .red

    private func colorForLength(_ segment: LineSegment) -> Color {
        let lengths = segments.map { hypot($0.segment.end.x - $0.segment.start.x, $0.segment.end.y - $0.segment.start.y) }
        let minLength = lengths.min() ?? 0
        let maxLength = lengths.max() ?? 1
        let length = hypot(segment.end.x - segment.start.x, segment.end.y - segment.start.y)

        // Normalize to 0-1
        let range = maxLength - minLength
        let t = range > 0 ? (length - minLength) / range : 0

        return shortColor.mix(with: longColor, by: t)
    }

    private func colorForDegree(_ segment: LineSegment) -> Color {
        // Color by max degree of the two endpoints
        let g = graph
        let startDegree = g.neighbors(of: segment.start).count
        let endDegree = g.neighbors(of: segment.end).count
        let maxDegree = max(startDegree, endDegree)
        return Color(glasbeyIndex: maxDegree)
    }

    private func colorForComponent(_ segment: LineSegment) -> Color {
        // Color by connected component
        let g = graph
        let components = g.connectedComponentsOfEdges()
        for (index, componentEdges) in components.enumerated() {
            for edge in componentEdges {
                if (edge.from == segment.start && edge.to == segment.end) ||
                   (edge.from == segment.end && edge.to == segment.start) {
                    return Color(glasbeyIndex: index)
                }
            }
        }
        return .black
    }

    private var segmentsAsCSV: String {
        var csv = "id,type,start_x,start_y,end_x,end_y\n"
        for segment in segments {
            csv += "\(segment.id),\(segment.type),\(segment.segment.start.x),\(segment.segment.start.y),\(segment.segment.end.x),\(segment.segment.end.y)\n"
        }
        return csv
    }

    private func parseCSV(_ csv: String) -> [TypedLineSegment]? {
        let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count >= 2 else { return nil }

        let headerLine = lines[0].lowercased()
        let headers = headerLine.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        // Find column indices - support various naming conventions
        let idIndex = headers.firstIndex(of: "id")
        let typeIndex = headers.firstIndex(of: "type")

        // Look for coordinate columns with various names
        func findColumn(_ names: [String]) -> Int? {
            headers.firstIndex { names.contains($0) }
        }

        // Try specific names first, then fallback to x0/y0/x1/y1 pattern
        let startXIndex = findColumn(["start_x", "start x", "startx", "sx", "ax", "x0"])
            ?? (findColumn(["x1"]) != nil && findColumn(["x2"]) != nil ? findColumn(["x1"]) : nil)
        let startYIndex = findColumn(["start_y", "start y", "starty", "sy", "ay", "y0"])
            ?? (findColumn(["y1"]) != nil && findColumn(["y2"]) != nil ? findColumn(["y1"]) : nil)
        let endXIndex = findColumn(["end_x", "end x", "endx", "ex", "bx"])
            ?? findColumn(["x2"])
            ?? (startXIndex != findColumn(["x1"]) ? findColumn(["x1"]) : nil)
        let endYIndex = findColumn(["end_y", "end y", "endy", "ey", "by"])
            ?? findColumn(["y2"])
            ?? (startYIndex != findColumn(["y1"]) ? findColumn(["y1"]) : nil)

        // Must have coordinates
        guard let sxIdx = startXIndex, let syIdx = startYIndex,
              let exIdx = endXIndex, let eyIdx = endYIndex else {
            return nil
        }

        var result: [TypedLineSegment] = []

        for (index, line) in lines.dropFirst().enumerated() {
            let values = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

            guard values.count > max(sxIdx, syIdx, exIdx, eyIdx),
                  let startX = Double(values[sxIdx]),
                  let startY = Double(values[syIdx]),
                  let endX = Double(values[exIdx]),
                  let endY = Double(values[eyIdx]) else {
                continue
            }

            let id = idIndex.flatMap { $0 < values.count ? values[$0] : nil } ?? "\(index + 1)"
            let type = typeIndex.flatMap { $0 < values.count ? values[$0] : nil } ?? "primary"

            let segment = TypedLineSegment(
                id: id,
                type: type,
                segment: LineSegment(
                    start: CGPoint(x: startX, y: startY),
                    end: CGPoint(x: endX, y: endY)
                )
            )
            result.append(segment)
        }

        return result.isEmpty ? nil : result
    }

    private var snapOptionsDescription: String {
        var parts: [String] = []
        if snapOptions.contains(.endpoints) { parts.append("Endpoints") }
        if snapOptions.contains(.lines) { parts.append("Lines") }
        if snapOptions.contains(.grid) { parts.append("Grid") }
        return parts.joined(separator: ", ")
    }

    private var allEndpoints: [CGPoint] {
        segments.flatMap { [$0.segment.start, $0.segment.end] }
    }

    private var allLineSegments: [LineSegment] {
        segments.map(\.segment)
    }

    private static func nearestPointOnSegment(point: CGPoint, segment: LineSegment) -> CGPoint {
        let dx = segment.end.x - segment.start.x
        let dy = segment.end.y - segment.start.y
        let lengthSquared = dx * dx + dy * dy

        if lengthSquared == 0 {
            return segment.start
        }

        let dotProduct = (point.x - segment.start.x) * dx + (point.y - segment.start.y) * dy
        let t = max(0, min(1, dotProduct / lengthSquared))
        return CGPoint(x: segment.start.x + t * dx, y: segment.start.y + t * dy)
    }

    private let gridSize: CGFloat = 10

    private var snapClosure: ((CGPoint, [CGPoint]) -> CGPoint)? {
        // Option key suppresses snapping
        guard !optionKeyDown, !snapOptions.isEmpty else { return nil }
        // Capture current values
        let options = snapOptions
        let radius = snapRadius
        let grid = gridSize
        let lineSegments = allLineSegments
        return { point, endpointTargets in
            // Priority order: endpoints > lines > grid
            // If we find a snap target at a higher priority level, use it

            // 1. Snap to endpoints (highest priority)
            if options.contains(.endpoints) {
                var closestEndpoint: CGPoint?
                var closestDistance: CGFloat = radius
                for target in endpointTargets {
                    let distance = hypot(target.x - point.x, target.y - point.y)
                    if distance < closestDistance {
                        closestEndpoint = target
                        closestDistance = distance
                    }
                }
                if let endpoint = closestEndpoint {
                    return endpoint
                }
            }

            // 2. Snap to lines (medium priority)
            if options.contains(.lines) {
                var closestLinePoint: CGPoint?
                var closestDistance: CGFloat = radius
                for segment in lineSegments {
                    let nearestPoint = Self.nearestPointOnSegment(point: point, segment: segment)
                    let distance = hypot(nearestPoint.x - point.x, nearestPoint.y - point.y)
                    if distance < closestDistance {
                        closestLinePoint = nearestPoint
                        closestDistance = distance
                    }
                }
                if let linePoint = closestLinePoint {
                    return linePoint
                }
            }

            // 3. Snap to grid (lowest priority)
            if options.contains(.grid) {
                let gridPoint = CGPoint(
                    x: (point.x / grid).rounded() * grid,
                    y: (point.y / grid).rounded() * grid
                )
                let distance = hypot(gridPoint.x - point.x, gridPoint.y - point.y)
                if distance < radius {
                    return gridPoint
                }
            }

            return point
        }
    }

    @ViewBuilder
    private var colorKeyView: some View {
        switch colorMode {
        case .none:
            EmptyView()
        case .byID:
            colorKeyList(title: "By ID", items: segments.map { (displayID(for: $0.id), Color(glasbeyIndex: abs($0.id.hashValue))) })
        case .byType:
            let types = Set(segments.map(\.type)).sorted()
            colorKeyList(title: "By Type", items: types.map { ($0, Color(glasbeyIndex: abs($0.hashValue))) })
        case .byLength:
            colorKeyList(title: "By Length", items: [("Short", shortColor), ("Long", longColor)])
        case .byDegree:
            let degrees = Set(segments.flatMap { seg in
                [graph.neighbors(of: seg.segment.start).count, graph.neighbors(of: seg.segment.end).count]
            }).sorted()
            colorKeyList(title: "By Degree", items: degrees.map { ("\($0)", Color(glasbeyIndex: $0)) })
        case .byComponent:
            let componentCount = graph.connectedComponentsOfEdges().count
            colorKeyList(title: "By Component", items: (0..<componentCount).map { ("Component \($0 + 1)", Color(glasbeyIndex: $0)) })
        }
    }

    @ViewBuilder
    private func colorKeyList(title: String, items: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).fontWeight(.medium)
            if items.count <= 10 {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    colorKeyRow(label: item.0, color: item.1)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                            colorKeyRow(label: item.0, color: item.1)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
    }

    private func colorKeyRow(label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
        }
    }

    private let hitToleranceScreen: CGFloat = 10

    private func segmentAt(_ point: CGPoint) -> TypedLineSegment? {
        let hitToleranceWorld = hitToleranceScreen / scale
        for segment in segments {
            if point.distance(to: segment.segment) <= hitToleranceWorld {
                return segment
            }
        }
        return nil
    }

    private func segmentBoundingRect(_ segment: TypedLineSegment) -> CGRect {
        let minX = min(segment.segment.start.x, segment.segment.end.x)
        let minY = min(segment.segment.start.y, segment.segment.end.y)
        let maxX = max(segment.segment.start.x, segment.segment.end.x)
        let maxY = max(segment.segment.start.y, segment.segment.end.y)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    private var graph: UndirectedGraph<CGPoint> {
        var g = UndirectedGraph<CGPoint>()
        for segment in segments {
            g.add(edge: .init(from: segment.segment.start, to: segment.segment.end))
        }
        return g
    }

    private var segmentsBoundingBox: CGRect? {
        guard !segments.isEmpty else { return nil }
        var minX = CGFloat.infinity
        var minY = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var maxY = -CGFloat.infinity
        for segment in segments {
            minX = min(minX, segment.segment.start.x, segment.segment.end.x)
            minY = min(minY, segment.segment.start.y, segment.segment.end.y)
            maxX = max(maxX, segment.segment.start.x, segment.segment.end.x)
            maxY = max(maxY, segment.segment.start.y, segment.segment.end.y)
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    private func splitSegments(options: SplitOptions) {
        let lineSegments = segments.map(\.segment)

        // Use a tolerance based on bounding box
        let tolerance: CGFloat
        if let bbox = segmentsBoundingBox {
            let diagonal = hypot(bbox.width, bbox.height)
            tolerance = max(diagonal * 0.001, 0.01)
        } else {
            tolerance = 0.1
        }

        let result = resolveTJunctions(segments: lineSegments, options: options, absoluteTolerance: tolerance)

        // Build new segments list, preserving type from original
        var newSegments: [TypedLineSegment] = []
        for segment in segments {
            if let splitSegments = result[segment.segment] {
                for (index, splitSegment) in splitSegments.enumerated() {
                    let id = splitSegments.count > 1 ? "\(segment.id)#\(index)" : segment.id
                    newSegments.append(TypedLineSegment(id: id, type: segment.type, segment: splitSegment))
                }
            }
        }

        segments = newSegments
        selection.removeAll()
    }

    private func quantizeSegments() {
        // Collect all endpoints
        let allPoints = segments.flatMap { [$0.segment.start, $0.segment.end] }

        // Quantize with a tolerance (e.g., 1% of bounding box diagonal)
        let tolerance: CGFloat
        if let bbox = segmentsBoundingBox {
            let diagonal = hypot(bbox.width, bbox.height)
            tolerance = max(diagonal * 0.01, 0.1)
        } else {
            tolerance = 1.0
        }

        let (mapping, _) = quantize(points: allPoints, tolerance: tolerance)

        // Apply the mapping to all segments
        segments = segments.map { segment in
            var newSegment = segment
            if let newStart = mapping[segment.segment.start] {
                newSegment.segment.start = newStart
            }
            if let newEnd = mapping[segment.segment.end] {
                newSegment.segment.end = newEnd
            }
            return newSegment
        }
    }

    private func zoomToFit(viewSize: CGSize) {
        guard let bbox = segmentsBoundingBox else { return }

        // Handle zero-size cases (single point or all points on a line)
        let width = max(bbox.width, 1)
        let height = max(bbox.height, 1)
        let adjustedBBox = CGRect(x: bbox.minX, y: bbox.minY, width: width, height: height)

        // Add 10% padding
        let paddedBBox = adjustedBBox.insetBy(dx: -width * 0.1, dy: -height * 0.1)

        // Calculate scale to fit the padded bbox in the view
        let scaleX = viewSize.width / paddedBBox.width
        let scaleY = viewSize.height / paddedBBox.height
        let newScale = min(scaleX, scaleY)

        // Reset rotation
        rotation = .zero
        lastRotation = .zero

        // Set scale
        scale = newScale
        lastScale = newScale

        // Scroll to center the bbox in the view
        // Convert bbox origin from world to screen coordinates
        let screenX = (paddedBBox.minX - regionOfInterest.minX) * newScale
        let screenY = (paddedBBox.minY - regionOfInterest.minY) * newScale
        scrollPosition = ScrollPosition(point: CGPoint(x: screenX, y: screenY))
    }

    private var canvasTransform: CGAffineTransform {
        // Transform from world coordinates to view coordinates
        // 1. Translate so ROI origin is at (0,0)
        // 2. Scale
        // 3. Rotate
        CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .rotated(by: rotation.radians)
            .translatedBy(x: -regionOfInterest.origin.x, y: -regionOfInterest.origin.y)
    }

    private var contentSize: CGSize {
        CGSize(
            width: regionOfInterest.width * scale,
            height: regionOfInterest.height * scale
        )
    }

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack {
                // Grid
                Canvas { context, _ in
                    context.concatenate(canvasTransform)

                    let minorGrid: CGFloat = 10
                    let majorGrid: CGFloat = 100
                    let roi = regionOfInterest

                    let startX = floor(roi.minX / minorGrid) * minorGrid
                    let endX = ceil(roi.maxX / minorGrid) * minorGrid
                    let startY = floor(roi.minY / minorGrid) * minorGrid
                    let endY = ceil(roi.maxY / minorGrid) * minorGrid

                    let lineWidth: CGFloat = 1 / scale

                    // Draw vertical lines
                    var x = startX
                    while x <= endX {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: roi.minY))
                        path.addLine(to: CGPoint(x: x, y: roi.maxY))

                        let color: Color
                        let intX = Int(x)
                        if intX == 0 {
                            color = .red.opacity(0.5)
                        } else if intX % Int(majorGrid) == 0 {
                            color = .gray.opacity(0.3)
                        } else {
                            color = .gray.opacity(0.1)
                        }
                        context.stroke(path, with: .color(color), lineWidth: lineWidth)
                        x += minorGrid
                    }

                    // Draw horizontal lines
                    var y = startY
                    while y <= endY {
                        var path = Path()
                        path.move(to: CGPoint(x: roi.minX, y: y))
                        path.addLine(to: CGPoint(x: roi.maxX, y: y))

                        let color: Color
                        let intY = Int(y)
                        if intY == 0 {
                            color = .green.opacity(0.5)
                        } else if intY % Int(majorGrid) == 0 {
                            color = .gray.opacity(0.3)
                        } else {
                            color = .gray.opacity(0.1)
                        }
                        context.stroke(path, with: .color(color), lineWidth: lineWidth)
                        y += minorGrid
                    }
                }
                .allowsHitTesting(false)

                // Segments
                Canvas { context, _ in
                    context.concatenate(canvasTransform)

                    for segment in segments {
                        let isSelected = selection.contains(segment.id)
                        let segmentColor = color(for: segment)
                        let lineWidth: CGFloat = 2 / scale

                        var path = Path()
                        path.move(to: segment.segment.start)
                        path.addLine(to: segment.segment.end)

                        // Draw selection highlight behind the segment
                        if isSelected {
                            context.stroke(path, with: .color(.accentColor), style: StrokeStyle(lineWidth: 8 / scale, lineCap: .round))
                        }

                        context.stroke(path, with: .color(segmentColor), lineWidth: lineWidth)

                        // Draw endpoints
                        let endpointSize: CGFloat = 8 / scale
                        context.fill(
                            Path(ellipseIn: CGRect(center: segment.segment.start, size: [endpointSize, endpointSize])),
                            with: .color(segmentColor)
                        )
                        context.fill(
                            Path(ellipseIn: CGRect(center: segment.segment.end, size: [endpointSize, endpointSize])),
                            with: .color(segmentColor)
                        )
                    }


                }
                .allowsHitTesting(false)

                InteractiveCanvas(elements: $segments, id: \.id, snap: snapClosure, transform: canvasTransform)
            }
            .frame(width: contentSize.width, height: contentSize.height)
            .contentShape(Rectangle())
            .modifier(ToolModifier(
                tool: currentTool,
                selection: $selection,
                segments: segments,
                segmentBoundingRect: segmentBoundingRect,
                segmentAt: segmentAt,
                transform: canvasTransform,
                shiftKeyDown: shiftKeyDown,
                snapTargets: allEndpoints,
                snap: snapClosure,
                onInsertLine: { line in
                    let newID = UUID().uuidString
                    segments.append(TypedLineSegment(id: newID, type: "primary", segment: line))
                }
            ))
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        scale = lastScale * value.magnification
                    }
                    .onEnded { _ in
                        lastScale = scale
                    }
            )
            .gesture(
                RotateGesture()
                    .onChanged { value in
                        rotation = lastRotation + value.rotation
                    }
                    .onEnded { _ in
                        lastRotation = rotation
                    }
            )
        }
        .scrollPosition($scrollPosition)
        .background(.white)
        .overlay(alignment: .bottom) {
            HStack(spacing: 12) {
                if !snapOptions.isEmpty {
                    Text("Snap: \(snapOptionsDescription)\(optionKeyDown ? " (⌥ suppressed)" : "")")
                }
                if scale != 1.0 {
                    Text("Zoom: \(scale * 100, specifier: "%.0f")%")
                }
                if rotation != .zero {
                    Text("Rotation: \(rotation.degrees, specifier: "%.1f")°")
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
            .padding(.bottom, 8)
        }
        .overlay(alignment: .bottomTrailing) {
            colorKeyView
                .padding(8)
        }
        .focusable()
        .copyable([segmentsAsCSV])
        .pasteDestination(for: String.self) { strings in
            guard let csv = strings.first else { return }
            if let parsed = parseCSV(csv) {
                segments = parsed
                selection.removeAll()
            }
        }
        .dropDestination(for: URL.self) { urls, _ in
            guard let url = urls.first,
                  url.pathExtension.lowercased() == "csv",
                  let csv = try? String(contentsOf: url, encoding: .utf8),
                  let parsed = parseCSV(csv) else {
                return false
            }
            segments = parsed
            selection.removeAll()
            return true
        }
        .onModifierKeysChanged { _, new in
            optionKeyDown = new.contains(.option)
            shiftKeyDown = new.contains(.shift)
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newSize in
            viewSize = newSize
        }
        .toolbar {
            ToolbarItem {
                Picker("Tool", selection: $currentTool) {
                    ForEach(Tool.allCases, id: \.self) { tool in
                        Text(tool.rawValue).tag(tool)
                    }
                }
                .pickerStyle(.segmented)
            }
            ToolbarItem {
                Picker("Color", selection: $colorMode) {
                    ForEach(ColorMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
            }
            ToolbarItem {
                Menu {
                    Button("Quantize") {
                        quantizeSegments()
                    }
                    Button("Split T-Junctions") {
                        splitSegments(options: .tJunctions)
                    }
                    Button("Split Crossings") {
                        splitSegments(options: .crossings)
                    }
                    Button("Split All") {
                        splitSegments(options: .all)
                    }
                } label: {
                    Label("Transform", systemImage: "wand.and.stars")
                }
            }
            ToolbarItem {
                Menu {
                    Toggle("Endpoints", isOn: Binding(
                        get: { snapOptions.contains(.endpoints) },
                        set: { if $0 { snapOptions.insert(.endpoints) } else { snapOptions.remove(.endpoints) } }
                    ))
                    Toggle("Lines", isOn: Binding(
                        get: { snapOptions.contains(.lines) },
                        set: { if $0 { snapOptions.insert(.lines) } else { snapOptions.remove(.lines) } }
                    ))
                    Toggle("Grid", isOn: Binding(
                        get: { snapOptions.contains(.grid) },
                        set: { if $0 { snapOptions.insert(.grid) } else { snapOptions.remove(.grid) } }
                    ))
                } label: {
                    Label("Snap", systemImage: "magnet")
                }
            }
            ToolbarItem {
                Button {
                    zoomToFit(viewSize: viewSize)
                } label: {
                    Label("Zoom to Fit", systemImage: "arrow.up.left.and.arrow.down.right")
                }
            }
            ToolbarItem {
                Button {
                    regionOfInterest = CGRect(x: 0, y: 0, width: 1000, height: 1000)
                    scale = 1.0
                    lastScale = 1.0
                    rotation = .zero
                    lastRotation = .zero
                    scrollPosition = ScrollPosition(point: .zero)
                } label: {
                    Label("Reset View", systemImage: "arrow.counterclockwise")
                }
            }
            ToolbarItem {
                Button {
                    showInspector.toggle()
                } label: {
                    Label("Inspector", systemImage: "sidebar.trailing")
                }
            }
        }
        .inspector(isPresented: $showInspector) {
            InspectorView(segments: $segments, selection: $selection, contentBoundingBox: segmentsBoundingBox, regionOfInterest: regionOfInterest, graph: graph, shortIDs: shortIDs)
        }
        .onAppear {
            regenerateShortIDs()
        }
        .onChange(of: segments) {
            regenerateShortIDs()
        }
    }
}

// MARK: - ToolModifier

private struct ToolModifier: ViewModifier {
    let tool: GraphDemoView.Tool
    @Binding var selection: Set<String>
    let segments: [GraphDemoView.TypedLineSegment]
    let segmentBoundingRect: (GraphDemoView.TypedLineSegment) -> CGRect
    let segmentAt: (CGPoint) -> GraphDemoView.TypedLineSegment?
    let transform: CGAffineTransform
    let shiftKeyDown: Bool
    let snapTargets: [CGPoint]
    let snap: ((CGPoint, [CGPoint]) -> CGPoint)?
    let onInsertLine: (LineSegment) -> Void

    func body(content: Content) -> some View {
        switch tool {
        case .select:
            content.selectable(
                selection: $selection,
                items: segments,
                itemRect: segmentBoundingRect,
                hitTest: segmentAt,
                transform: transform,
                shiftKeyDown: shiftKeyDown
            )
        case .insertLine:
            content.insertLineTool(
                transform: transform,
                snapTargets: snapTargets,
                snap: snap,
                onInsert: onInsertLine
            )
        }
    }
}

// MARK: - InteractiveRepresentable

extension GraphDemoView.TypedLineSegment: InteractiveRepresentable {
    typealias HandleID = LineSegment.HandleID

    func makeHandles() -> [InteractiveHandle<HandleID>] {
        segment.makeHandles()
    }

    mutating func handleDidChange(id: HandleID, handles: inout [HandleID: InteractiveHandle<HandleID>]) {
        segment.handleDidChange(id: id, handles: &handles)
    }
}

// MARK: - InspectorView

private struct InspectorView: View {
    @Binding var segments: [GraphDemoView.TypedLineSegment]
    @Binding var selection: Set<String>
    var contentBoundingBox: CGRect?
    var regionOfInterest: CGRect
    var graph: UndirectedGraph<CGPoint>
    var shortIDs: [AnyHashable: Int]

    private func displayID(for id: String) -> String {
        if let shortID = shortIDs[id] {
            return "Edge-\(shortID)"
        }
        return id
    }

    var body: some View {
        TabView {
            Tab("Segments", systemImage: "line.diagonal") {
                segmentsList
            }
            Tab("Canvas", systemImage: "rectangle.dashed") {
                canvasInfoForm
            }
            Tab("Graph", systemImage: "point.3.connected.trianglepath.dotted") {
                graphInfoForm
            }
        }
    }

    private var segmentsList: some View {
        List(segments, selection: $selection) { segment in
            let length = hypot(segment.segment.end.x - segment.segment.start.x, segment.segment.end.y - segment.segment.start.y)
            VStack(alignment: .leading) {
                Text(displayID(for: segment.id))
                Text("Type: \(segment.type)")
                    .foregroundStyle(.secondary)
                Text("Start: \(segment.segment.start.formatted())")
                    .foregroundStyle(.secondary)
                Text("End: \(segment.segment.end.formatted())")
                    .foregroundStyle(.secondary)
                Text("Length: \(length, specifier: "%.2f")")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var canvasInfoForm: some View {
        Form {
            Section("Region of Interest") {
                Text(regionOfInterest.formatted())
            }
            Section("Content Bounding Box") {
                if let bbox = contentBoundingBox {
                    Text(bbox.formatted())
                } else {
                    Text("No content")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var graphInfoForm: some View {
        Form {
            Section("Summary") {
                LabeledContent("Vertices", value: "\(graph.vertices.count)")
                LabeledContent("Edges", value: "\(graph.edges.count)")
            }
            Section("Vertices") {
                ForEach(Array(graph.vertices), id: \.self) { vertex in
                    HStack {
                        Text(vertex.formatted())
                        Spacer()
                        Text("\(graph.neighbors(of: vertex).count) neighbors")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
