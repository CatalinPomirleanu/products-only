import Foundation

public struct NetworkConfiguration: Equatable, Sendable {

    public static let `default` = NetworkConfiguration()

    public var acceptableStatusCodes: Range<Int>
    public var timeoutInterval: TimeInterval

    public init(acceptableStatusCodes: Range<Int> = 200..<300, timeoutInterval: TimeInterval = 60) {
        self.acceptableStatusCodes = acceptableStatusCodes
        self.timeoutInterval = timeoutInterval
    }
}
