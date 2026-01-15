import Foundation

struct DashboardOverviewResponse: Codable {
    let status: Int
    let data: DashboardData
    let message: String
}

struct DashboardData: Codable {
    let summary: DashboardSummary
    let chartData: [ChartDataPoint]
    let budgets: [DashboardBudget]
    let categories: [DashboardCategory]
    
    enum CodingKeys: String, CodingKey {
        case summary
        case chartData = "chart_data"
        case budgets
        case categories
    }
}

struct DashboardSummary: Codable {
    let currentBalance: Double
    let totalIncome: Double
    let totalExpenses: Double
    let balance: Double
    let transactionCount: Int
    let avgPerDay: Double
    let budgetUsagePercent: Double
    let period: String
    
    enum CodingKeys: String, CodingKey {
        case currentBalance = "current_balance"
        case totalIncome = "total_income"
        case totalExpenses = "total_expenses"
        case balance
        case transactionCount = "transaction_count"
        case avgPerDay = "avg_per_day"
        case budgetUsagePercent = "budget_usage_percent"
        case period
    }
}

struct ChartDataPoint: Codable, Identifiable {
    let id = UUID()
    let date: String
    let label: String
    let income: Double
    let outcome: Double
}

struct DashboardBudget: Codable, Identifiable {
    let id: String
    let name: String
    let amount: Double
    let limit: Double
    let usagePercent: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case amount
        case limit
        case usagePercent = "usage_percent"
    }
    
    var percent: Double {
            guard limit > 0 else { return 0 }
            return amount / limit
        }
        
        var spent: Double {
            return abs(amount)
        }
        
        var isOverBudget: Bool {
            return percent > 1
        }
}

struct DashboardCategory: Codable, Identifiable {
    let id: String
    let name: String
    let income: Double
    let outcome: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case income
        case outcome
    }
    
    var total: Double {
        return outcome - income
    }
}

struct InsightResponse: Codable {
    let status: Int
    let data: InsightData
    let message: String
}

struct InsightData: Codable {
    let insight: String
}
