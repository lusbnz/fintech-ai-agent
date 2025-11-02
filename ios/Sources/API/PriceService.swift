import Foundation

final class PriceService {
    static let shared = PriceService()
    private init() {}

    func fetchPrices(version: String = "vi") async throws -> PriceData {
        let response: PriceResponse = try await APIClient.shared.request(
            .getPrices(version: version),
            as: PriceResponse.self
        )
        return response.data
    }
}
