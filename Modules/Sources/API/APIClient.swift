import Dependencies
import Foundation

public protocol APIClient: Sendable {
    var configuration: NetworkConfiguration { get }
    var decoder: any _NetworkDecoder { get }

    func fetch<Value: Sendable & Decodable>(request: some Request) async throws(APIError) -> (value: Value, response: HTTPURLResponse)
}

private enum APIClientKey: DependencyKey {
    static let liveValue: any APIClient = StandardAPIClient()
}

extension DependencyValues {
    public var apiClient: any APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}
