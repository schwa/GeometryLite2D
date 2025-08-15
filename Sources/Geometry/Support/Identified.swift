import Foundation

public struct Identified<ID, Value>: Identifiable where ID: Hashable {
    public let id: ID
    public let value: Value

    public init(id: ID, value: Value) {
        self.id = id
        self.value = value
    }
}
