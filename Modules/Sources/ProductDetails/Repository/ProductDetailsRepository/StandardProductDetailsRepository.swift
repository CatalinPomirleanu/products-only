import API
import Dependencies

nonisolated struct StandardProductDetailsRepository: ProductDetailsRepository {
    @Dependency(\.apiClient) private var apiClient

    func fetch(request: ProductDetailsRequest) async throws -> ProductDetails {
        try await apiClient.fetch(request: request).value
    }
}
