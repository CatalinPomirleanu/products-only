import Dependencies
import DependenciesMacros
import Foundation

public struct APIClient: Sendable {

    /// Performs the request and returns the body of a successful (2xx) response.
    public var data: @Sendable (_ request: URLRequest) async throws -> Data
}

extension APIClient {

    public func decoded<Value: Decodable>(
        _ type: Value.Type = Value.self,
        for request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> Value {
        try decoder.decode(Value.self, from: await data(request))
    }

    static func validate(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard 200..<300 ~= response.statusCode else {
            throw APIError.unacceptableStatusCode(response.statusCode)
        }
    }
}

extension APIClient: DependencyKey {

    public static let liveValue = APIClient { request in
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)
        return data
    }
}

extension DependencyValues {

    public var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
