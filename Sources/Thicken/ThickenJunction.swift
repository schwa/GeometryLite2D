import CoreGraphics
import Geometry
import SwiftUI

// MARK: - Junction

/// Process an N-way junction and return thickened atoms
/// - Parameters:
///   - center: The junction point
///   - endpoints: The far endpoints of each segment (not the center)
///   - width: Stroke width
///   - joinStyle: Join style for outer gaps (> 180°)
///   - capStyles: Cap style for each segment endpoint (must match endpoints count)
/// - Returns: Array of atoms (segments and knee caps)
public func thickenJunction(
    center: CGPoint,
    endpoints: [CGPoint],
    width: CGFloat,
    joinStyle: JoinStyle = .miter,
    capStyles: [CapStyle]
) -> [Atom] {
    guard endpoints.count >= 2 else {
        if let endpoint = endpoints.first {
            let seg = LineSegment(start: center, end: endpoint)
            let capStyle = capStyles.first ?? .butt
            // For degree-1 vertex: cap at center (start), butt at midpoint (end)
            return thickenedSegment(seg, width: width, startCap: capStyle, endCap: .butt)
        }
        return []
    }

    if endpoints.count == 2 {
        // For 2-way junction, use the first cap style (both endpoints typically same)
        let capStyle = capStyles.first ?? .butt
        return twoWayJunction(center: center, endpoints: endpoints, width: width, joinStyle: joinStyle, capStyle: capStyle)
    }

    return nWayJunction(center: center, endpoints: endpoints, width: width, joinStyle: joinStyle, capStyles: capStyles)
}

/// Convenience overload using same cap style for all endpoints
public func thickenJunction(
    center: CGPoint,
    endpoints: [CGPoint],
    width: CGFloat,
    joinStyle: JoinStyle = .miter,
    capStyle: CapStyle = .butt
) -> [Atom] {
    thickenJunction(
        center: center,
        endpoints: endpoints,
        width: width,
        joinStyle: joinStyle,
        capStyles: Array(repeating: capStyle, count: endpoints.count)
    )
}
