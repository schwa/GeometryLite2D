import SwiftUI

public protocol PathRepresentable {
    func makePath() -> Path
}

public extension Path {
    init(representable: some PathRepresentable) {
        self = representable.makePath()
    }
}
