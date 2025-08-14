import CoreGraphics
import Foundation

public extension CGPoint {
    enum Comparator {
        case xThenY
        case yThenX
        case relativeAngleFrom(CGPoint)
        case distanceFrom(CGPoint)
    }

    func compare(to other: CGPoint, using comparator: Comparator) -> ComparisonResult {
        switch comparator {
        case .xThenY:
            if self.x != other.x {
                return self.x < other.x ? .orderedAscending : .orderedDescending
            } else if self.y != other.y {
                return self.y < other.y ? .orderedAscending : .orderedDescending
            } else {
                return .orderedSame
            }
        case .yThenX:
            if self.y != other.y {
                return self.y < other.y ? .orderedAscending : .orderedDescending
            } else if self.x != other.x {
                return self.x < other.x ? .orderedAscending : .orderedDescending
            } else {
                return .orderedSame
            }
        case .relativeAngleFrom(let center):
            let angle1 = atan2(self.y - center.y, self.x - center.x)
            let angle2 = atan2(other.y - center.y, other.x - center.x)
            if angle1 != angle2 {
                return angle1 < angle2 ? .orderedAscending : .orderedDescending
            } else {
                return .orderedSame
            }
        case .distanceFrom(let origin):
            let dist1 = self.distance(to: origin)
            let dist2 = other.distance(to: origin)
            if dist1 != dist2 {
                return dist1 < dist2 ? .orderedAscending : .orderedDescending
            } else {
                return .orderedSame
            }
        }
    }

}


