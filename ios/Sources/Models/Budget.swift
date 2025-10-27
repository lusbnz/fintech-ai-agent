import Foundation

struct Budget: Codable, Identifiable {
    let id: String
    let name: String
    let user_id: String
    let amount: Double
    let start_date: Date   
    let remain: Double
    let limit: Double
    let period: String
    let created_at: String
    let updated_at: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, user_id, amount, start_date, remain, limit, period, created_at, updated_at
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

extension Budget {
    func formattedAmount(using currencyCode: String?) -> String {
        let code = (currencyCode ?? "USD").uppercased()
        
        return amount.formatted(
            .currency(code: code)
                .locale(Locale(identifier: code == "VND" ? "vi_VN" : "en_US"))
        )
    }
}
