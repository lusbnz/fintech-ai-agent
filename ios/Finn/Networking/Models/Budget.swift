import Foundation
import SwiftUI

struct Budget: Codable, Identifiable {
    let id: String
    let name: String
    let user_id: String
    let amount: Double
    let start_date: Date
    let limit: Double
    let created_at: String
    let updated_at: String
    let days_remaining: Double?
    let days_passed: Double
    let actual_avg: Double
    let expected_avg: Double
    let diff_avg: Double
    let progress: Double
    let total_income: Double
    let total_outcome: Double
    
    let recurring_topup_amount: Double
    let recurring_interval_unit: String
    let recurring_interval_value: Int
    let recurring_active: Bool
    let recurring_next_run_at: Date?
    let recurring_last_run_at: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, user_id, amount, start_date, limit, created_at, updated_at, days_remaining, days_passed, actual_avg, expected_avg, diff_avg, progress, total_income, total_outcome, recurring_topup_amount, recurring_interval_unit, recurring_interval_value, recurring_active, recurring_next_run_at, recurring_last_run_at
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

struct BudgetSlice: Identifiable {
    let id: String
    let name: String
    let value: Double
    let color: Color
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
