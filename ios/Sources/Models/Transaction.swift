//
//  TransactionListResponse.swift
//  faa-ios
//
//  Created by Đinh Quốc Việt on 27/10/25.
//


struct TransactionListResponse: Codable {
    let data: [Transaction]
    let pagination: Pagination
}

struct Transaction: Codable, Identifiable {
    let id: String
    let amount: Double
    let category: String
    let note: String?
    let date: String
    let type: String // "income" | "expense"
    let budget_id: String?
    let image_url: String?
    let created_at: String
    let updated_at: String
    
    enum CodingKeys: String, CodingKey {
        case id, amount, category, note, date, type
        case budget_id, image_url, created_at, updated_at
    }
}

struct TransactionFilter {
    let category: String?
    let type: String? // "income", "expense"
    let dateFrom: Date?
    let dateTo: Date?
    let budgetId: String?
    
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]
        if let category = category { json["category"] = category }
        if let type = type { json["type"] = type }
        if let dateFrom = dateFrom {
            json["date_from"] = ISO8601DateFormatter().string(from: dateFrom)
        }
        if let dateTo = dateTo {
            json["date_to"] = ISO8601DateFormatter().string(from: dateTo)
        }
        if let budgetId = budgetId { json["budget_id"] = budgetId }
        return json
    }
}