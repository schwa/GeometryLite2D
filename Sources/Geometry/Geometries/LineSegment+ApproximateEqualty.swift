import Numerics
import CoreGraphics

public extension LineSegment {
    func isApproximatelyEqual(to other: LineSegment, absoluteTolerance: CGFloat, relativeTolerance: CGFloat = 0) -> Bool {
        start.x.isApproximatelyEqual(to: other.start.x, absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance)
        && start.y.isApproximatelyEqual(to: other.start.y, absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance)
        && end.x.isApproximatelyEqual(to: other.end.x, absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance)
        && end.y.isApproximatelyEqual(to: other.end.y, absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance)
    }
}
