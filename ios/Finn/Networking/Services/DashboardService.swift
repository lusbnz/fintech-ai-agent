import Foundation

final class DashboardService {
    static let shared = DashboardService()
    
    private init() {}

    func getDashboard(
        period: String,
    ) async throws -> DashboardData {
        let body: [String: Any] = [
            "period": period,
        ]
        
        let response: APIResponse<DashboardData> = try await APIClient.shared.request(
            .getDashboard(body: body),
            body: body,
            as: APIResponse<DashboardData>.self
        )
        return response.data
    }
}
