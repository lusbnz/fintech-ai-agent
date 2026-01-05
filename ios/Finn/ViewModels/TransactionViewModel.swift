import Foundation
import Combine

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var transactions: [Transaction] = []
    @Published var reccurringTransactions: [TransactionReccurring] = []
    @Published var hasMorePages = true
    @Published var currentPage = 1
    @Published var hasMorePagesRecurring = true
    @Published var currentPageRecurring = 1
    
    @Published var showEdit = false
    @Published var showDeleteConfirm = false

    @Published var selectedBudgetId: String? = nil {
        didSet {
            resetAndReload()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let pageSize = 20
    
    private func sortByNewest(_ list: [Transaction]) -> [Transaction] {
        list.sorted { (lhs: Transaction, rhs: Transaction) in
            (lhs.createdAtDate ?? .distantPast) >
            (rhs.createdAtDate ?? .distantPast)
        }
    }
    
    init() {
        $selectedBudgetId
            .dropFirst()
            .sink { [weak self] _ in
                self?.resetAndReload()
            }
            .store(in: &cancellables)
    }
    
    func loadTransactions(page: Int = 1, append: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        let filter: TransactionFilter? = selectedBudgetId.map { TransactionFilter(budgetId: $0) }

        do {
            let response = try await TransactionService.shared.getTransactions(page: page, filter: filter)
            
            if Task.isCancelled { return }
            
            if append {
                transactions = sortByNewest(
                    transactions + response.data
                )
            } else {
                transactions = sortByNewest(response.data)
            }
            
            hasMorePages = response.pagination.page < response.pagination.total_page
            currentPage = response.pagination.page

        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Request was cancelled — ignore safely")
                return
            }

            if error is CancellationError {
                print("Task cancelled — ignore safely")
                return
            }

            self.error = "Failed to load: \(error.localizedDescription)"
        }
    }
    
    func loadReccurringTransactions(page: Int = 1, append: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await TransactionService.shared.getReccurringTransactions(page: page, filter: nil)
            
            if Task.isCancelled { return }
            
            if append {
                reccurringTransactions.append(contentsOf: response.data)
            } else {
                reccurringTransactions = response.data
            }
            
            hasMorePagesRecurring = response.pagination.page < response.pagination.total_page
            currentPageRecurring = response.pagination.page

        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Request was cancelled — ignore safely")
                return
            }

            if error is CancellationError {
                print("Task cancelled — ignore safely")
                return
            }

            self.error = "Failed to load: \(error.localizedDescription)"
        }
    }
    
    func refresh() async {
        await loadTransactions(page: 1, append: false)
        await loadReccurringTransactions(page: 1, append: false)
    }
    
    func loadMoreIfNeeded(currentTransaction: Transaction) async {
        guard hasMorePages,
              let lastTransaction = transactions.last,
              currentTransaction.id == lastTransaction.id else {
            return
        }
        
        await loadTransactions(page: currentPage + 1, append: true)
    }
    
    func loadMoreIfNeededReccurring(currentTransaction: TransactionReccurring) async {
        guard hasMorePages,
              let lastTransaction = reccurringTransactions.last,
              currentTransaction.id == lastTransaction.id else {
            return
        }
        
        await loadReccurringTransactions(page: currentPageRecurring + 1, append: true)
    }
    
    private func resetAndReload() {
        transactions = []
        hasMorePages = true
        currentPage = 1
        reccurringTransactions = []
        hasMorePagesRecurring = true
        currentPageRecurring = 1
        Task { await refresh() }
    }
    
    func createTransaction(
        name: String,
        amount: Double,
        category_id: String,
        note: String?,
        date: Date,
        type: String,
        budget_id: String?,
        image: String? = nil,
        is_recurring: Bool? = nil,
        recurring_start_date: String? = nil,
        recurring_interval_unit: String? = nil,
        recurring_interval_value: Int? = nil,
    ) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let isoDate = ISO8601DateFormatter().string(from: date)
        
        do {
            let newTx = try await TransactionService.shared.createTransaction(
                name: name,
                amount: amount,
                category_id: category_id,
                note: note,
                date: isoDate,
                type: type,
                budget_id: budget_id,
                image: image,
                is_recurring: is_recurring,
                recurring_start_date: recurring_start_date,
                recurring_interval_unit: recurring_interval_unit,
                recurring_interval_value: recurring_interval_value,
            )
            
            if selectedBudgetId == nil || newTx.budget_id == selectedBudgetId {
                transactions.insert(newTx, at: 0)
            }
            
            
            await loadTransactions()
            
            return true
        } catch {
            self.error = "Lỗi khi tạo giao dịch: \(error.localizedDescription)"
            return false
        }
    }
    
    func updateTransaction(
        id: String,
        name: String,
        amount: Double? = nil,
        category_id: String? = nil,
        note: String? = nil,
        date: Date? = nil,
        type: String? = nil,
        budget_id: String? = nil,
        image: String? = nil,
        is_recurring: Bool? = nil,
        recurring_start_date: String? = nil,
        recurring_interval_unit: String? = nil,
        recurring_interval_value: Int? = nil,
    ) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let isoDate = date.map { ISO8601DateFormatter().string(from: $0) }
        
        do {
            let updatedTx = try await TransactionService.shared.updateTransaction(
                id: id,
                name: name,
                amount: amount,
                category_id: category_id,
                note: note,
                date: isoDate,
                type: type,
                budget_id: budget_id,
                image: image,
                is_recurring: is_recurring,
                recurring_start_date: recurring_start_date,
                recurring_interval_unit: recurring_interval_unit,
                recurring_interval_value: recurring_interval_value,
            )
            
            if let index = transactions.firstIndex(where: { $0.id == id }) {
                transactions[index] = updatedTx
                
                if let budget_id = budget_id, selectedBudgetId != nil, budget_id != selectedBudgetId {
                    transactions.remove(at: index)
                }
                
                await loadTransactions()
            }
            
            return true
        } catch {
            self.error = "Cập nhật thất bại: \(error.localizedDescription)"
            return false
        }
    }
    
    func updateReccurringTransaction(
        id: String,
        name: String,
        amount: Double? = nil,
        category_id: String? = nil,
        note: String? = nil,
        date: Date? = nil,
        type: String? = nil,
        budget_id: String? = nil,
        image: String? = nil,
        interval_unit: String? = nil,
        interval_value: Int? = nil,
        next_run_at: String? = nil,
        last_run_at: String? = nil,
        active: Bool? = nil
    ) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let isoDate = date.map { ISO8601DateFormatter().string(from: $0) }
        
        do {
            let updatedTx = try await TransactionService.shared.updateReccurringTransaction(
                id: id,
                name: name,
                amount: amount,
                category_id: category_id,
                note: note,
                date: isoDate,
                type: type,
                budget_id: budget_id,
                image: image,
                active: active,
                interval_unit: interval_unit,
                interval_value: interval_value,
                next_run_at: next_run_at,
                last_run_at: last_run_at
            )
            
            if let index = reccurringTransactions.firstIndex(where: { $0.id == id }) {
                reccurringTransactions[index] = updatedTx
            }
            
            await loadReccurringTransactions()
            
            return true
        } catch {
            self.error = "Cập nhật thất bại: \(error.localizedDescription)"
            return false
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            try await TransactionService.shared.deleteTransaction(id: transaction.id)
            
            transactions.removeAll { $0.id == transaction.id }
            
            await loadTransactions()
            return true
        } catch {
            self.error = "Xoá thất bại: \(error.localizedDescription)"
            return false
        }
    }
    
    func deleteReccurringTransaction(_ transaction: TransactionReccurring) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            try await TransactionService.shared.deleteTransaction(id: transaction.id)
            
            transactions.removeAll { $0.id == transaction.id }
            
            await loadReccurringTransactions()
            return true
        } catch {
            self.error = "Xoá thất bại: \(error.localizedDescription)"
            return false
        }
    }
}

extension Transaction {
    var createdAtDate: Date? {
        ISO8601DateFormatter().date(from: date_time)
    }
}
