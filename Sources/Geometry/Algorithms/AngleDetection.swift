import CoreGraphics
import SwiftUI

/**
 Calculates the optimal rotation angle to align a set of line segments.

 This function analyzes the angles of the provided line segments, builds a histogram
 to determine the dominant direction, and refines the result by averaging angles
 near the dominant direction. The result is the angle that best aligns the segments.

 - Parameter segments: An array of `LineSegment` objects to analyze.
 - Returns: An `Angle` representing the optimal rotation to align the segments.
 If the input array is empty, the function returns `.zero`.
 */
public func findRotationToAlign(segments: [LineSegment]) -> Angle {
    guard !segments.isEmpty else { return .zero }

    let binSize = Angle.degrees(5.0)
    let halfWindow = Angle.degrees(15.0)
    let totalRangeDegrees = 180.0
    let binCount = Int(totalRangeDegrees / binSize.degrees)

    // Build histogram
    var histogram = [Double](repeating: 0.0, count: binCount)

    for segment in segments {
        let angle = segment.angle.normalized180()
        let weight = segment.length
        let index = Int((angle.degrees / binSize.degrees).rounded()) % binCount
        histogram[index] += weight
    }

    // Find dominant bin
    guard let (dominantIndex, _) = histogram.enumerated().max(by: { $0.element < $1.element }) else {
        return .zero
    }

    let dominantBinCenter = Angle.degrees(Double(dominantIndex) * binSize.degrees)

    // Refine: average all angles near the dominant bin
    var totalAngle = Angle.zero
    var totalWeight = 0.0

    for segment in segments {
        let angle = segment.angle.normalized180()
        let deviation = (angle - dominantBinCenter).wrappedToMinus90to90()

        if abs(deviation.degrees) <= halfWindow.degrees {
            let weight = segment.length
            totalAngle += angle * weight
            totalWeight += weight
        }
    }

    guard totalWeight > 0 else { return .zero }

    return totalAngle / totalWeight
}
