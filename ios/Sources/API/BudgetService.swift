import Foundation

final class BudgetService {
    static let shared = BudgetService()
    private init() {}
    
    // MARK: - List
    func getBudgets(page: Int = 1) async throws -> BudgetListResponse {
        let response: BudgetListResponse = try await APIClient.shared.request(
            .budgetList(page: page),
            as: BudgetListResponse.self
        )
        return response
    }
    
    // MARK: - Create
    func createBudget(name: String, amount: Double, startDate: String) async throws -> Budget {
        let body: [String: Any] = [
            "name": name,
            "amount": amount,
            "start_date": startDate
        ]
        
        let response: APIResponse<Budget> = try await APIClient.shared.request(
            .budgetCreate,
            body: body,
            as: APIResponse<Budget>.self
        )
        return response.data
    }
    
    // MARK: - Update
    func updateBudget(id: String, name: String? = nil, amount: Double? = nil) async throws -> Budget {
        var body: [String: Any] = [:]
        if let name = name { body["name"] = name }
        if let amount = amount { body["amount"] = amount }
        
        let response: APIResponse<Budget> = try await APIClient.shared.request(
            .budgetUpdate(id: id),
            body: body,
            as: APIResponse<Budget>.self
        )
        return response.data
    }
    
    // MARK: - Delete
    func deleteBudget(id: String) async throws {
        _ = try await APIClient.shared.request(
            .budgetDelete(id: id),
            as: APIResponse<EmptyResponse>.self
        )
    }
}

// Dùng cho response không có data
struct EmptyResponse: Codable {}