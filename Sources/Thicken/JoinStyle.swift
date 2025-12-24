import CoreGraphics

/// How to connect two line segments at a shared vertex
public enum JoinStyle: Hashable, Sendable {
    /// Extend edges until they meet. Limit is miterLength/lineWidth threshold.
    case miter(limit: CGFloat = 10)
    /// Circular arc connecting the edges
    case round
    /// Straight line connecting the edges (cut corner)
    case bevel
}

extension JoinStyle {
    /// Default miter join with standard limit (matches Core Graphics default of 10)
    public static let miter = JoinStyle.miter(limit: 10)
}
