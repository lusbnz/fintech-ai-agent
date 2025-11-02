import Foundation

struct TransactionListResponse: Codable {
    let data: [Transaction]
    let pagination: Pagination
}

struct Transaction: Codable, Identifiable {
    let id: String
    let name: String
    let budget_id: String
    let type: String            // "outcome" / "income"
    let description: String?
    let user_id: String
    let category: String
    let amount: Double
    let date_time: String
    let image: String?
    let location: Location?
    let created_at: String
    let updated_at: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, budget_id, type, description, user_id, category, amount
        case date_time, image, location, created_at, updated_at
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
