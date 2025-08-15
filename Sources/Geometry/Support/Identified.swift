import Foundation

public struct Identified<ID, Value>: Identifiable where ID: Hashable {
    public var id: ID
    public var value: Value

    public init(id: ID, value: Value) {
        self.id = id
        self.value = value
    }
}
