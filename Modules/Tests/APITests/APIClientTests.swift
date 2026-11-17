import Dependencies
import Foundation
import Testing

@testable import API

struct APIClientTests {

    private struct TestRequest: Request {
        var baseUrl = "https://example.com"
        var path = "/items"
    }

    private func makeSUT(
        configuration: NetworkConfiguration = .default,
        statusCode: Int = 200,
        body: String = #"{"value":1}"#
    ) -> StandardAPIClient {
        StandardAPIClient(configuration: configuration) { request in
            let url = try #require(request.url)
            let response = try #require(
                HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
            )
            return (Data(body.utf8), response)
        }
    }

    @Test("""
    Given a request with a method, headers and a base URL with a path prefix
    When building its URL request
    Then they are applied together with the timeout interval
    """)
    func urlRequestFields() throws {
        struct DeleteRequest: Request {
            let baseUrl = "https://example.com/v1/"
            let path = "items/7"
            let method = HTTPMethod.delete
            let headers = ["Accept": "application/json"]
        }

        let sut = try DeleteRequest().urlRequest(timeoutInterval: 5)

        #expect(sut.url?.absoluteString == "https://example.com/v1/items/7")
        #expect(sut.httpMethod == "DELETE")
        #expect(sut.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(sut.timeoutInterval == 5)
    }

    @Test("""
    Given a base URL without a scheme and host
    When fetching
    Then the invalid URL error is thrown
    """, arguments: ["", "dummyjson.com", "https://"])
    func invalidURL(baseUrl: String) async {
        let sut = makeSUT()

        await #expect(throws: APIError.invalidURL) {
            let _: (value: [String: Int], response: HTTPURLResponse) = try await sut.fetch(
                request: TestRequest(baseUrl: baseUrl)
            )
        }
    }

    // MARK: - Fetch

    @Test("""
    Given an overridden api client dependency
    When fetching a request
    Then the JSON body is decoded and the HTTP response is returned
    """)
    func fetch() async throws {
        let stub = makeSUT()
        let sut = withDependencies {
            $0.apiClient = stub
        } operation: {
            @Dependency(\.apiClient) var apiClient
            return apiClient
        }

        let result: (value: [String: Int], response: HTTPURLResponse) = try await sut.fetch(request: TestRequest())

        #expect(result.value == ["value": 1])
        #expect(result.response.statusCode == 200)
        #expect(result.response.url?.absoluteString == "https://example.com/items")
    }

    @Test("""
    Given the configured timeout interval
    When fetching
    Then it is applied to the URL request
    """)
    func timeoutInterval() async throws {
        let sut = StandardAPIClient(configuration: NetworkConfiguration(timeoutInterval: 3)) { request in
            #expect(request.timeoutInterval == 3)
            throw URLError(.timedOut)
        }

        await #expect(throws: APIError.transport(URLError(.timedOut))) {
            let _: (value: [String: Int], response: HTTPURLResponse) = try await sut.fetch(request: TestRequest())
        }
    }

    @Test("""
    Given HTTP responses
    When fetching with the default configuration
    Then only 2xx status codes are accepted
    """, arguments: [(200, true), (299, true), (199, false), (300, false), (404, false), (500, false)])
    func statusCode(statusCode: Int, isAccepted: Bool) async throws {
        let sut = makeSUT(statusCode: statusCode)

        if isAccepted {
            let value: [String: Int] = try await sut.fetch(request: TestRequest()).value
            #expect(value == ["value": 1])
        } else {
            await #expect(throws: APIError.unacceptableStatusCode(statusCode)) {
                let _: [String: Int] = try await sut.fetch(request: TestRequest()).value
            }
        }
    }

    @Test("""
    Given a configuration accepting 304
    When the server answers 200 or 304
    Then only the configured status code is accepted
    """)
    func customAcceptableStatusCodes() async throws {
        let configuration = NetworkConfiguration(acceptableStatusCodes: 304..<305)

        let value: [String: Int] = try await makeSUT(configuration: configuration, statusCode: 304)
            .fetch(request: TestRequest()).value
        #expect(value == ["value": 1])

        await #expect(throws: APIError.unacceptableStatusCode(200)) {
            let _: [String: Int] = try await makeSUT(configuration: configuration, statusCode: 200)
                .fetch(request: TestRequest()).value
        }
    }

    @Test("""
    Given a non-HTTP response
    When fetching
    Then it is rejected as invalid
    """)
    func nonHTTPResponse() async {
        let sut = StandardAPIClient { _ in (Data(), URLResponse()) }

        await #expect(throws: APIError.invalidResponse) {
            let _: [String: Int] = try await sut.fetch(request: TestRequest()).value
        }
    }

    @Test("""
    Given a body that does not match the expected type
    When fetching
    Then the failure is mapped to a decoding error
    """)
    func decodingFailure() async {
        let sut = makeSUT(body: #"{"value":"not a number"}"#)

        do {
            let _: [String: Int] = try await sut.fetch(request: TestRequest()).value
            Issue.record("Expected a decoding error")
        } catch {
            guard case .decoding(let description) = error else {
                Issue.record("Expected a decoding error, got \(error)")
                return
            }
            #expect(description.contains("typeMismatch"))
        }
    }
}
