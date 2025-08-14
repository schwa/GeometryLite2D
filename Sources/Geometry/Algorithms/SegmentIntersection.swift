import CoreGraphics
import Foundation
import Numerics


// MARK: - Geometry Helpers

// TODO: Move
public func angle(from p: CGPoint, to q: CGPoint) -> CGFloat {
    atan2(q.y - p.y, q.x - p.x)
}

