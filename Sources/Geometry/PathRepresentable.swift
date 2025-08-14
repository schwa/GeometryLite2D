import SwiftUI

public protocol PathRepresentable {
    func makePath() -> Path
}

public extension Path {
    init(representable: some PathRepresentable) {
        self = representable.makePath()
    }
}

// MARK: - CGRect Conformance

extension CGRect: PathRepresentable {
    public func makePath() -> Path {
        Path(self)
    }
}

// MARK: - LineSegment Conformance

extension LineSegment: PathRepresentable {
    public func makePath() -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
}

// MARK: - Polygon Conformance

extension Polygon: PathRepresentable {
    public func makePath() -> Path {
        var path = Path()
        guard let first = vertices.first else { return path }
        
        path.move(to: first)
        for vertex in vertices.dropFirst() {
            path.addLine(to: vertex)
        }
        path.closeSubpath()
        return path
    }
}