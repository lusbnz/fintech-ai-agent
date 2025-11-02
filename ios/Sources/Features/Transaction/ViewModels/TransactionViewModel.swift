import Foundation
import Combine

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var transactions: [Transaction] = []
    @Published var hasMorePages = true
    @Published var currentPage = 1
    
    @Published var showEdit = false
    @Published var showDeleteConfirm = false
    
    @Published var selectedBudgetId: String? = nil {
        didSet {
            resetAndReload()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let pageSize = 20
    
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
                transactions.append(contentsOf: response.data)
            } else {
                transactions = response.data
            }
            
            hasMorePages = response.pagination.page < response.pagination.total_page
            currentPage = response.pagination.page

        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("⚠️ Request was cancelled — ignore safely")
                return
            }

            if error is CancellationError {
                print("⚠️ Task cancelled — ignore safely")
                return
            }

            self.error = "Failed to load: \(error.localizedDescription)"
        }
    }
    
    func refresh() async {
        await loadTransactions(page: 1, append: false)
    }
    
    func loadMoreIfNeeded(currentTransaction: Transaction) async {
        guard hasMorePages,
              let lastTransaction = transactions.last,
              currentTransaction.id == lastTransaction.id else {
            return
        }
        
        await loadTransactions(page: currentPage + 1, append: true)
    }
    
    private func resetAndReload() {
        transactions = []
        hasMorePages = true
        currentPage = 1
        Task { await refresh() }
    }
    
    func createTransaction(
        name: String,
        amount: Double,
        category: String,
        note: String?,
        date: Date,
        type: String,
        budget_id: String?,
        image: String? = nil
    ) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let isoDate = ISO8601DateFormatter().string(from: date)
        
        do {
            let newTx = try await TransactionService.shared.createTransaction(
                name: name,
                amount: amount,
                category: category,
                note: note,
                date: isoDate,
                type: type,
                budget_id: budget_id,
                image: image
            )
            
            // Thêm vào đầu danh sách nếu cùng budget (hoặc All)
            if selectedBudgetId == nil || newTx.budget_id == selectedBudgetId {
                transactions.insert(newTx, at: 0)
            }
            
            return true
        } catch {
            self.error = "Failed to create transaction: \(error.localizedDescription)"
            return false
        }
    }
    
    func updateTransaction(
        id: String,
        name: String,
        amount: Double? = nil,
        category: String? = nil,
        note: String? = nil,
        date: Date? = nil,
        type: String? = nil,
        budget_id: String? = nil,
        image: String? = nil
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
                category: category,
                note: note,
                date: isoDate,
                type: type,
                budget_id: budget_id,
                image: image
            )
            
            if let index = transactions.firstIndex(where: { $0.id == id }) {
                transactions[index] = updatedTx
                
                if let budget_id = budget_id, selectedBudgetId != nil, budget_id != selectedBudgetId {
                    transactions.remove(at: index)
                }
            }
            
            return true
        } catch {
            self.error = "Update failed: \(error.localizedDescription)"
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
            return true
        } catch {
            self.error = "Delete failed: \(error.localizedDescription)"
            return false
        }
    }
}
