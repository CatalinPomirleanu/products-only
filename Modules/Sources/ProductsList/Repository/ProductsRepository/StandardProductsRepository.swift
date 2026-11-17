import API
import Dependencies

nonisolated struct StandardProductsRepository: ProductsRepository {
    @Dependency(\.apiClient) private var apiClient

    func fetch(request: ProductsRequest) async throws -> ProductsPage {
        return try await apiClient.fetch(request: request).value
    }
}
