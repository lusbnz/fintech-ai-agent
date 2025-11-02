import Foundation
import Combine

@MainActor
final class BudgetViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var showEdit = false
    @Published var showDeleteConfirm = false
    @Published var budgets: [Budget] = []
    
    private let periodMap: [String: String] = [
        "Single": "single",
        "1 Week": "1_week",
        "1 Month": "1_month",
        "1 Year": "1_year"
    ]

    func loadBudgets() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await BudgetService.shared.getBudgets(page: 1)
            budgets = response.data.data
            print("Budget list: \(budgets)")
        } catch {
            self.error = "Failed to load budgets: \(error.localizedDescription)"
        }
    }
    
    func createBudget(
        name: String,
        amount: Double,
        start_date: Date,
        period: String
    ) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let dateStr = formatter.string(from: start_date)
        let periodKey = periodMap[period] ?? "1_month"
        
        do {
            let budget = try await BudgetService.shared.createBudget(
                name: name,
                amount: amount,
                start_date: dateStr,
                period: periodKey
            )
            print("Budget created: \(budget.name)")
            return true
        } catch {
            self.error = "Failed to create budget: \(error.localizedDescription)"
            print("Create error: \(error)")
            return false
        }
    }
    
    func updateBudget(
        id: String,
        name: String,
        amount: Double,
        start_date: Date,
        period: String
    ) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let dateStr = formatter.string(from: start_date)
        
        let periodKey = periodMap[period] ?? "1_month"
        
        do {
            let updated = try await BudgetService.shared.updateBudget(
                id: id,
                name: name,
                amount: amount,
                start_date: dateStr,
                period: periodKey
            )
            print("Budget updated: \(updated.name)")
            return true
        } catch {
            self.error = "Update failed: \(error.localizedDescription)"
            return false
        }
    }
    
    func deleteBudget(_ budget: Budget) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            try await BudgetService.shared.deleteBudget(id: budget.id)
            return true
        } catch {
            self.error = "Delete failed: \(error.localizedDescription)"
            return false
        }
    }
}
