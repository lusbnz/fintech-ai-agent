import Foundation

final class BudgetService {
    static let shared = BudgetService()
    private init() {}
    
    func getBudgets(page: Int = 1) async throws -> BudgetListResponse {
        let response: BudgetListResponse = try await APIClient.shared.request(
            .budgetList(page: page),
            as: BudgetListResponse.self
        )
        return response
    }
    
    func createBudget(name: String, amount: Double, start_date: String, period: String) async throws -> Budget {
        let body: [String: Any] = [
            "name": name,
            "amount": amount,
            "start_date": start_date,
            "period": period
        ]
        
        let response: APIResponse<Budget> = try await APIClient.shared.request(
            .budgetCreate,
            body: body,
            as: APIResponse<Budget>.self
        )
        return response.data
    }
    
    func updateBudget(id: String, name: String? = nil, amount: Double? = nil, start_date: String? = nil, period: String? = nil) async throws -> Budget {
        var body: [String: Any] = [:]
        if let name = name { body["name"] = name }
        if let amount = amount { body["amount"] = amount }
        if let start_date = start_date { body["start_date"] = start_date }
        if let period = period { body["period"] = period }
        
        let response: APIResponse<Budget> = try await APIClient.shared.request(
            .budgetUpdate(id: id),
            body: body,
            as: APIResponse<Budget>.self
        )
        return response.data
    }
    
    func deleteBudget(id: String) async throws {
        _ = try await APIClient.shared.request(
            .budgetDelete(id: id),
            as: APIResponse<EmptyResponse>.self
        )
    }
}

struct EmptyResponse: Codable {}
