import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var dashboardData: DashboardData?
    @Published var insightData: InsightData?
    @Published var homeInsightData: InsightData?
    @Published var isLoading = false
    @Published var isLoadingInsight = false
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
    
    func loadInsight(for period: String) async {
        isLoadingInsight = true
        errorMessage = nil
        
        do {
            let data = try await DashboardService.shared.getInsight(period: period.lowercased())
            insightData = data
        } catch {
            errorMessage = "Không thể tải dữ liệu: \(error.localizedDescription)"
            print("Dashboard error:", error)
        }
        
        isLoadingInsight = false
    }
    
    func loadInsightHome(for period: String) async {
        errorMessage = nil
        
        do {
            let data = try await DashboardService.shared.getInsight(period: "3_days")
            homeInsightData = data
        } catch {
            errorMessage = "Không thể tải dữ liệu: \(error.localizedDescription)"
            print("Dashboard error:", error)
        }
    }
}
