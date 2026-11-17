import Foundation

public struct StandardAPIClient: APIClient {

    public let configuration: NetworkConfiguration
    public let decoder: any _NetworkDecoder

    private let transport: @Sendable (URLRequest) async throws -> (Data, URLResponse)

    public init(
        configuration: NetworkConfiguration = .default,
        decoder: any _NetworkDecoder = JSONDecoder(),
        transport: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse) = {
            try await URLSession.shared.data(for: $0)
        }
    ) {
        self.configuration = configuration
        self.decoder = decoder
        self.transport = transport
    }

    public func fetch<Value: Sendable & Decodable>(
        request: some Request
    ) async throws(APIError) -> (value: Value, response: HTTPURLResponse) {
        let urlRequest = try request.urlRequest(timeoutInterval: configuration.timeoutInterval)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await transport(urlRequest)
        } catch {
            throw .transport(error as? URLError ?? URLError(.unknown))
        }

        guard let response = response as? HTTPURLResponse else {
            throw .invalidResponse
        }

        guard configuration.acceptableStatusCodes.contains(response.statusCode) else {
            throw .unacceptableStatusCode(response.statusCode)
        }

        do {
            return (try decoder.decode(Value.self, from: data), response)
        } catch {
            throw .decoding(String(describing: error))
        }
    }
}
