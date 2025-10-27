import Foundation

struct Budget: Codable, Identifiable {
    let id: String
    let name: String
    let user_id: String
    let amount: Double
    let start_date: String
    let remain: Double
    let limit: Double
    let period: String
    let created_at: String
    let updated_at: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, user_id, amount, start_date, remain, limit, period, created_at, updated_at
 penn    }
    
    // Dùng để format ngày
    var startDate: Date {
        ISO8601DateFormatter().date(from: start_date) ?? Date()
    }
    
    var formattedAmount: String {
        amount.formatted(.currency(code: "USD")) // Sẽ xử lý theo currency sau
    }
}

struct BudgetListResponse: Codable {
    let data: BudgetData
    let message: String
}

struct BudgetData: Codable {
    let data: [Budget]
    let pagination: Pagination
}

struct Pagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let total_page: Int
}