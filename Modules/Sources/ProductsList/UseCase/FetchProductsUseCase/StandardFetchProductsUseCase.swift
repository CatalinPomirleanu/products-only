import Dependencies

nonisolated struct StandardFetchProductsUseCase: FetchProductsUseCase {
    @Dependency(\.productsRepository) private var productsRepository

    func execute(mode: FetchProductsMode, offset: Int, limit: Int) async throws -> ProductsPage {
        let request: ProductsRequest = switch mode {
        case .standard: .page(limit: limit, skip: offset)
        case .search(let query): .search(query: query, limit: limit, skip: offset)
        }

        return try await productsRepository.fetch(request: request)
    }
}
