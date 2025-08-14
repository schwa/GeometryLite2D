#if !canImport(CoreGraphics)
public struct Angle {
    public var radians: Double

    public var degrees: Double {
        radians * 180.0 / .pi
    }

    public init(radians: Double) {
        self.radians = radians
    }

    init(degrees: Double) {
        self.radians = degrees * .pi / 180.0
    }

    static func radians(_ radians: Double) -> Self {
        Self(radians: radians)
    }

    static func degrees(_ degrees: Double) -> Self {
        Self(degrees: degrees)
    }
}

extension Angle: Equatable {
}

extension Angle: Sendable {
}
#endif
