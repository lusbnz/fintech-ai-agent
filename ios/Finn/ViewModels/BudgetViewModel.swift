import Foundation
import Combine

@MainActor
final class BudgetViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?

    let app: AppState

    init(app: AppState) {
        self.app = app
    }

    func loadBudgets() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await BudgetService.shared.getBudgets(page: 1)
            app.budgets = response.data.data
        } catch {
            self.error = "Lỗi khi tải ngân sách: \(error.localizedDescription)"
        }
    }
    

    func createBudget(
        name: String,
        amount: Double,
        start_date: Date,
        recurring_topup_amount: Double,
        recurring_interval_unit: String,
        recurring_interval_value: Int,
        recurring_active: Bool
    ) async -> Bool {

        isLoading = true
        error = nil
        defer { isLoading = false }

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"

        do {
            let _ = try await BudgetService.shared.createBudget(
                name: name,
                amount: amount,
                start_date: formatter.string(from: start_date),
                recurring_topup_amount: recurring_topup_amount,
                recurring_interval_unit: recurring_interval_unit,
                recurring_interval_value: recurring_interval_value,
                recurring_active: recurring_active
            )

            await loadBudgets()

            return true
        } catch {
            self.error = "Lỗi tạo ngân sách: \(error.localizedDescription)"
            return false
        }
    }

    func updateBudget(
        id: String,
        name: String,
        amount: Double,
        start_date: Date,
        recurring_topup_amount: Double,
        recurring_interval_unit: String,
        recurring_interval_value: Int,
        recurring_active: Bool,
    ) async -> Bool {

        isLoading = true
        error = nil
        defer { isLoading = false }

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"

        do {
            let _ = try await BudgetService.shared.updateBudget(
                id: id,
                name: name,
                amount: amount,
                start_date: formatter.string(from: start_date),
                recurring_topup_amount: recurring_topup_amount,
                recurring_interval_unit: recurring_interval_unit,
                recurring_interval_value: recurring_interval_value,
                recurring_active: recurring_active
            )

            await loadBudgets()

            return true
        } catch {
            self.error = "Cập nhật thất bại: \(error.localizedDescription)"
            return false
        }
    }

    func deleteBudget(_ budget: Budget) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            try await BudgetService.shared.deleteBudget(id: budget.id)

            await loadBudgets()

            return true
        } catch {
            self.error = "Xoá thất bại: \(error.localizedDescription)"
            return false
        }
    }
}
