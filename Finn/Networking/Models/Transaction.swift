import Foundation

struct TransactionListResponse: Codable {
    let data: [Transaction]
    let pagination: Pagination
}

struct TransactionReccurringListResponse: Codable {
    let data: [TransactionReccurring]
    let pagination: Pagination
}

struct Transaction: Codable, Identifiable {
    let id: String
    let name: String
    let budget_id: String
    let type: String
    let description: String?
    let user_id: String
    let category: Category?
    let category_id: String?
    let amount: Double
    let date_time: String
    let image: String?
    let created_at: String
    let updated_at: String
    
    let interval_unit: String?
    let interval_value: Int?
    let next_run_at: String?
    let last_run_at: String?
    let active: Bool?
    
    let is_recurring: Bool?
    let recurring_start_date: String?
    let recurring_interval_unit: String?
    let recurring_interval_value: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, budget_id, type, description, user_id, category, category_id, amount
        case date_time, image, created_at, updated_at, is_recurring, recurring_start_date, recurring_interval_unit, recurring_interval_value, interval_unit, interval_value, next_run_at, last_run_at,active
    }
}

struct TransactionFilter {
    let budgetId: String?
    
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]
        if let budgetId = budgetId { json["budget_id"] = budgetId }
        return json
    }
}


struct TransactionReccurring: Codable, Identifiable {
    let id: String
    let name: String
    let budget_id: String
    let type: String
    let description: String?
    let user_id: String
    let category_id: String?
    let amount: Double
    let image: String?
    let created_at: String
    let updated_at: String
    
    let active: Bool?
    let interval_unit: String?
    let interval_value: Int?
    let next_run_at: String?
    let last_run_at: String?
    
    let is_recurring: Bool?
    let recurring_start_date: String?
    let recurring_interval_unit: String?
    let recurring_interval_value: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, budget_id, type, description, user_id, category_id, amount
        case image, created_at, updated_at, interval_unit, interval_value, next_run_at, last_run_at, active, is_recurring, recurring_start_date, recurring_interval_unit, recurring_interval_value
    }
}
