import Foundation

/// A very basic representation of a user interaction
public enum UserInteraction: Equatable, Sendable {
    case gesture(trackingData: String)
}
