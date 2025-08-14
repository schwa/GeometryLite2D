import Foundation
import os
import SwiftUI

public final class GeometryLog: Sendable {

    public static let shared = GeometryLog()

    public struct Event: Sendable {
        public var timestamp: Date
        public var description: String
        public var tags: Set<String> = []
        public var color: Color?
        public var geometries: [LoggableGeometry]
    }

    private let events: OSAllocatedUnfairLock<[Event]> = .init(initialState: [])
    private let callbacks: OSAllocatedUnfairLock<[@Sendable () -> Void]> = .init(initialState: [])

    public func log(description: String = "", tags: Set<String> = [], color: Color? = nil, geometries: [LoggableGeometry]) {
        events.withLock { events in
            defer {
                post()
            }
            let event = Event(timestamp: Date(), description: description, tags: tags, color: color, geometries: geometries)
            events.append(event)
        }
    }

    public func fetchAndClear() -> [Event] {
        events.withLock { events in
            let currentEvents = events
            events.removeAll()
            return currentEvents
        }
    }

    public func registerCallback(_ callback: @Sendable @escaping () -> Void) {
        callbacks.withLock { callbacks in
            callbacks.append(callback)
        }
    }

    func post() {
        callbacks.withLock { callbacks in
            callbacks.forEach { $0() }
        }
    }

}

public enum LoggableGeometry: Sendable {
    case point(CGPoint)
    case rect(CGRect)
    case segment(LineSegment)
    case line(Line)
    case ray(Ray)
}
