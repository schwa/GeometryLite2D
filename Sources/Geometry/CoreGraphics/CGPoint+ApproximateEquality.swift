import CoreGraphics
import Numerics

public extension CGPoint {
    func isApproximatelyEqual(to other: CGPoint, absoluteTolerance: CGFloat, relativeTolerance: CGFloat = 0) -> Bool {
        x.isApproximatelyEqual(to: other.x, absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance)
            && y.isApproximatelyEqual(to: other.y, absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance)
    }
}
