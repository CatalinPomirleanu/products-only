import API
import Dependencies

nonisolated struct StandardProductDetailsRepository: ProductDetailsRepository {
    @Dependency(\.apiClient) private var apiClient

    func fetch(request: ProductDetailsRequest) async throws -> ProductDetails {
        do {
            return try await apiClient.fetch(request: request).value
        } catch APIError.unacceptableStatusCode(404) {
            throw ProductDetailsRepositoryError.notFound
        }
    }
}
