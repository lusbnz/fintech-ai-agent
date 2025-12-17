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
    
    func createBudget(name: String, amount: Double, start_date: String, recurring_topup_amount: Double, recurring_interval_unit: String, recurring_interval_value: Int, recurring_active: Bool) async throws -> Budget {
        let body: [String: Any] = [
            "name": name,
            "amount": amount,
            "start_date": start_date,
            "recurring_topup_amount": recurring_topup_amount,
            "recurring_interval_unit": recurring_interval_unit,
            "recurring_interval_value": recurring_interval_value,
            "recurring_active": recurring_active,
        ]
        
        let response: APIResponse<Budget> = try await APIClient.shared.request(
            .budgetCreate,
            body: body,
            as: APIResponse<Budget>.self
        )
        return response.data
    }
    
    func updateBudget(id: String, name: String? = nil, amount: Double? = nil, start_date: String? = nil, recurring_topup_amount: Double? = nil, recurring_interval_unit: String? = nil, recurring_interval_value: Int? = nil, recurring_active: Bool? = nil) async throws -> Budget {
        var body: [String: Any] = [:]
        if let name = name { body["name"] = name }
        if let amount = amount { body["amount"] = amount }
        if let start_date = start_date { body["start_date"] = start_date }
        if let recurring_topup_amount = recurring_topup_amount { body["recurring_topup_amount"] = recurring_topup_amount }
        if let recurring_interval_unit = recurring_interval_unit { body["recurring_interval_unit"] = recurring_interval_unit }
        if let recurring_interval_value = recurring_interval_value { body["recurring_interval_value"] = recurring_interval_value }
        if let recurring_active = recurring_active { body["recurring_active"] = recurring_active }
        
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
