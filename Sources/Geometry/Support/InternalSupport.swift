import CoreGraphics
import SwiftUI

extension Collection {
    func withNeighborElements() -> [(Element, Element)] {
        guard !isEmpty else { return [] }

        let elements = Array(self)
        let count = elements.count
        return (0..<count).map { i in
            let current = elements[i]
            let next = elements[(i + 1) % count]
            return (current, next)
        }
    }

    func with2NeighborElements() -> [(Element, Element, Element)] {
        guard !isEmpty else { return [] }

        let elements = Array(self)
        let count = elements.count
        return (0..<count).map { i in
            let previous = elements[(i - 1 + count) % count]
            let current = elements[i]
            let next = elements[(i + 1) % count]
            return (previous, current, next)
        }
    }
}

extension Collection where Element: Hashable {
    func uniqued() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}

internal extension Angle {
    func normalized180() -> Angle {
        var deg = self.degrees.truncatingRemainder(dividingBy: 180)
        if deg < 0 { deg += 180 }
        return .degrees(deg)
    }

    func wrappedToMinus90to90() -> Angle {
        var deg = self.degrees.truncatingRemainder(dividingBy: 180)
        if deg > 90 { deg -= 180 }
        if deg < -90 { deg += 180 }
        return .degrees(deg)
    }
}

internal extension Collection {
    func uncons() -> (Element, SubSequence)? {
        guard let firstElement = first else { return nil }
        return (firstElement, dropFirst())
    }
}
