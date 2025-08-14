// import CoreGraphics
// import os
//
//// TODO: This is now basically useless. Get rid of.
// public struct Mesh {
//    public var segments: [LineSegment]
//    public var components: [[LineSegment]]
//    public var logger: Logger? = Logger()
//
//    public init(segments: [LineSegment]) {
//        logger?.info("#segments: \(segments.count)")
//
//        self.segments = segments
//
//        let graph = Graph<CGPoint, Int> { graph in
//            for (index, segment) in segments.enumerated() {
//                graph.addEdge(from: segment.start, to: segment.end, value: index)
//            }
//        }
//
//        logger?.info("#graph.vertices.count: \(graph.vertices.count)")
//        logger?.info("#graph.edges.count: \(graph.edges.count)")
//
//
//        let components = graph.connectedComponents().map { Array($0.1) }
//
//
//
//        let count = components.reduce(0) { $0 + $1.count }
//        logger?.info("#segments (after making graph): \(count)")
//    }
// }
