import API
import Dependencies
import Testing

@testable import ProductDetails

@MainActor
struct StandardProductDetailsRepositoryTests {

    private func makeSUT(apiClient: APIClientMock) -> StandardProductDetailsRepository {
        withDependencies {
            $0.apiClient = apiClient
        } operation: {
            StandardProductDetailsRepository()
        }
    }

    @Test("""
    Given an api client that answers with product details
    When fetching a request
    Then the request is forwarded to the api client and its product details are returned
    """)
    func fetch() async throws {
        let details = ProductDetails.mock(id: 7)
        let apiClient = APIClientMock(result: .success(details))
        let sut = makeSUT(apiClient: apiClient)
        let request = ProductDetailsRequest(id: 7)

        let result = try await sut.fetch(request: request)

        #expect(result == details)
        #expect(apiClient.requests.count == 1)
        #expect(apiClient.requests.first as? ProductDetailsRequest == request)
    }

    @Test("""
    Given an api client that returns a 404
    When fetching a product
    Then the repository reports that the product was not found
    """)
    func productNotFound() async {
        let apiClient = APIClientMock(result: .failure(.unacceptableStatusCode(404)))
        let sut = makeSUT(apiClient: apiClient)

        await #expect(throws: ProductDetailsRepositoryError.notFound) {
            try await sut.fetch(request: ProductDetailsRequest(id: 7))
        }
    }

    @Test("""
    Given an api client that fails
    When fetching a request
    Then its error is thrown unchanged
    """)
    func fetchFailure() async {
        let apiClient = APIClientMock(result: .failure(.unacceptableStatusCode(500)))
        let sut = makeSUT(apiClient: apiClient)

        await #expect(throws: APIError.unacceptableStatusCode(500)) {
            try await sut.fetch(request: ProductDetailsRequest(id: 7))
        }
    }

    @Test("""
    Given a product id
    When a request is made for it
    Then its path points at that product
    """)
    func requestPath() {
        let sut = ProductDetailsRequest(id: 42)

        #expect(sut.path == "/products/42")
    }
}
