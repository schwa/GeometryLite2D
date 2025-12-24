/// How to terminate the end of an open path
public enum CapStyle: Hashable, Sendable, CaseIterable {
    /// Flat cap, no extension beyond endpoint
    case butt
    /// Semicircular cap extending half-width beyond endpoint
    case round
    /// Square cap extending half-width beyond endpoint
    case square
}
