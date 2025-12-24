import CoreGraphics
import Geometry
import SwiftUI

// MARK: - Junction

public extension Junction {
    /// Returns thickened atoms for this junction
    /// - Parameters:
    ///   - width: Stroke width
    ///   - joinStyle: Join style for outer gaps (> 180°)
    ///   - capStyles: Cap style for each segment endpoint (must match vertices count)
    /// - Returns: Array of atoms (segments and knee caps)
    func thickened(
        width: CGFloat,
        joinStyle: JoinStyle = .miter,
        capStyles: [CapStyle]
    ) -> [ThickenPrimitive] {
        guard vertices.count >= 2 else {
            if let vertex = vertices.first {
                let seg = LineSegment(start: center, end: vertex)
                let capStyle = capStyles.first ?? .butt
                // For degree-1 vertex: cap at center (start), butt at midpoint (end)
                return thickenedSegment(seg, width: width, startCap: capStyle, endCap: .butt)
            }
            return []
        }

        if vertices.count == 2 {
            // For 2-way junction, use the first cap style (both endpoints typically same)
            let capStyle = capStyles.first ?? .butt
            return twoWayJunction(center: center, endpoints: vertices, width: width, joinStyle: joinStyle, capStyle: capStyle)
        }

        return nWayJunction(center: center, endpoints: vertices, width: width, joinStyle: joinStyle, capStyles: capStyles)
    }

    /// Convenience overload using same cap style for all endpoints
    func thickened(
        width: CGFloat,
        joinStyle: JoinStyle = .miter,
        capStyle: CapStyle = .butt
    ) -> [ThickenPrimitive] {
        thickened(
            width: width,
            joinStyle: joinStyle,
            capStyles: Array(repeating: capStyle, count: vertices.count)
        )
    }
}
