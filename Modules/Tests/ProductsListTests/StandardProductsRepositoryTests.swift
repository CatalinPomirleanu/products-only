import API
import Dependencies
import Testing

@testable import ProductsList

@MainActor
struct StandardProductsRepositoryTests {

    private func makeSUT(apiClient: APIClientMock) -> StandardProductsRepository {
        withDependencies {
            $0.apiClient = apiClient
        } operation: {
            StandardProductsRepository()
        }
    }

    @Test("""
    Given an api client that answers with a page
    When fetching a request
    Then the request is forwarded to the api client and its page is returned
    """)
    func fetch() async throws {
        let page = ProductsPage.mock(ids: 1...3, total: 3)
        let apiClient = APIClientMock(result: .success(page))
        let sut = makeSUT(apiClient: apiClient)
        let request = ProductsRequest.search(query: "red", limit: 20, skip: 40)

        let result = try await sut.fetch(request: request)

        #expect(result == page)
        #expect(apiClient.requests.count == 1)
        #expect(apiClient.requests.first as? ProductsRequest == request)
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
            try await sut.fetch(request: .page(limit: 20, skip: 0))
        }
    }
}
