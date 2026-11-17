import Dependencies
import Foundation
import Testing

@testable import ProductsList

@MainActor
struct StandardFetchProductsUseCaseTests {

    private func makeDependencies() -> (repository: ProductsRepositoryMock, sut: StandardFetchProductsUseCase) {
        let repository = ProductsRepositoryMock()
        let sut = withDependencies {
            $0.productsRepository = repository
        } operation: {
            StandardFetchProductsUseCase()
        }
        return (repository, sut)
    }

    @Test("""
    Given a repository that answers with a page
    When executing in standard mode
    Then the page request is made with the offset and limit, and its page is returned
    """)
    func standard() async throws {
        let deps = makeDependencies()
        let page = ProductsPage.mock(ids: 21...40, total: 45, skip: 20)
        deps.repository.setHandler { _ in page }

        let result = try await deps.sut.execute(mode: .standard, offset: 20, limit: 20)

        #expect(result == page)
        #expect(deps.repository.requests == [.page(limit: 20, skip: 20)])
    }

    @Test("""
    Given a repository that answers with a page
    When executing in search mode
    Then the search request is made with the query, offset and limit, and its page is returned
    """)
    func search() async throws {
        let deps = makeDependencies()
        let page = ProductsPage.mock(ids: 1...2, total: 2)
        deps.repository.setHandler { _ in page }

        let result = try await deps.sut.execute(mode: .search("red"), offset: 0, limit: 10)

        #expect(result == page)
        #expect(deps.repository.requests == [.search(query: "red", limit: 10, skip: 0)])
    }

    @Test("""
    Given a repository that fails
    When executing
    Then its error is thrown unchanged
    """)
    func failure() async {
        let deps = makeDependencies()
        deps.repository.setHandler { _ in throw URLError(.notConnectedToInternet) }

        await #expect(throws: URLError(.notConnectedToInternet)) {
            try await deps.sut.execute(mode: .standard, offset: 0, limit: 20)
        }
    }
}
