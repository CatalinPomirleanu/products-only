import Foundation

public protocol _NetworkDecoder: Sendable {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: _NetworkDecoder { }
