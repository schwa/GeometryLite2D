import Foundation

public struct Identified<ID, Value>: Identifiable where ID: Hashable {
    public var id: ID
    public var value: Value

    public init(id: ID, value: Value) {
        self.id = id
        self.value = value
    }
}

extension Identified: Sendable where ID: Sendable, Value: Sendable {
}

extension Identified: Equatable where ID: Equatable, Value: Equatable {
}

extension Identified: Hashable where ID: Hashable, Value: Hashable {
}

extension Identified: Codable where ID: Codable, Value: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case value
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(ID.self, forKey: .id)
        let value = try container.decode(Value.self, forKey: .value)
        self.init(id: id, value: value)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(value, forKey: .value)
    }
}
