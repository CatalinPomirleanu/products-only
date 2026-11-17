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

#if DEBUG

import Synchronization

public final class APIClientMock: APIClient {

    private struct State {
        var requests: [any Request] = []
        var result: Result<any Sendable, APIError>
    }

    public let configuration = NetworkConfiguration.default
    public let decoder: any _NetworkDecoder = JSONDecoder()

    private let state: Mutex<State>

    public var requests: [any Request] {
        state.withLock { $0.requests }
    }

    public init(result: Result<any Sendable, APIError> = .failure(.invalidResponse)) {
        self.state = Mutex(State(result: result))
    }

    public func setResult(_ result: Result<any Sendable, APIError>) {
        state.withLock { $0.result = result }
    }

    public func fetch<Value: Sendable & Decodable>(
        request: some Request
    ) async throws(APIError) -> (value: Value, response: HTTPURLResponse) {
        let result = state.withLock { state in
            state.requests.append(request)
            return state.result
        }

        guard let value = try result.get() as? Value else {
            throw .decoding("APIClientMock was given a value that is not \(Value.self)")
        }
        return (value, HTTPURLResponse())
    }
}

#endif
