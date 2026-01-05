import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var dashboardData: DashboardData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadData(for period: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await DashboardService.shared.getDashboard(period: period.lowercased())
            dashboardData = data
        } catch {
            errorMessage = "Không thể tải dữ liệu: \(error.localizedDescription)"
            print("Dashboard error:", error)
        }
        
        isLoading = false
    }
}
