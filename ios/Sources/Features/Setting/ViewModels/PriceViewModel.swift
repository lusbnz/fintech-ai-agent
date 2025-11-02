import Foundation
import Combine

@MainActor
final class PriceViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var priceData: PriceData?

    func fetchPrices(version: String = "vi") async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await PriceService.shared.getPrices(version: version)
            priceData = response.data
        } catch {
            self.error = "Failed to fetch prices: \(error.localizedDescription)"
        }
    }
}
