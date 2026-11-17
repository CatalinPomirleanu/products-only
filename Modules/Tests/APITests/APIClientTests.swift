import Dependencies
import Foundation
import Testing

@testable import API

struct APIClientTests {

    private let request = URLRequest(url: URL(filePath: "/"))

    @Test("""
    Given an overridden data endpoint
    When decoding a request
    Then the JSON body is decoded
    """)
    func decoded() async throws {
        let sut = withDependencies {
            $0.apiClient.data = { _ in Data(#"{"value":1}"#.utf8) }
        } operation: {
            @Dependency(\.apiClient) var apiClient
            return apiClient
        }

        let result: [String: Int] = try await sut.decoded(for: request)

        #expect(result == ["value": 1])
    }

    @Test("""
    Given HTTP responses
    When validating them
    Then only 2xx status codes are accepted
    """, arguments: [(200, true), (299, true), (199, false), (300, false), (404, false), (500, false)])
    func validate(statusCode: Int, isAccepted: Bool) throws {
        let response = try #require(
            HTTPURLResponse(url: URL(filePath: "/"), statusCode: statusCode, httpVersion: nil, headerFields: nil)
        )

        if isAccepted {
            try APIClient.validate(response)
        } else {
            #expect(throws: APIError.unacceptableStatusCode(statusCode)) {
                try APIClient.validate(response)
            }
        }
    }

    @Test("""
    Given a non-HTTP response
    When validating it
    Then it is rejected as invalid
    """)
    func validateNonHTTPResponse() {
        #expect(throws: APIError.invalidResponse) {
            try APIClient.validate(URLResponse())
        }
    }
}
