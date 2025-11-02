import Foundation
import Combine

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    @Published var transactions: [Transaction] = []
    @Published var hasMorePages = true
    @Published var currentPage = 1
    
    // Lọc theo budget (nếu có)
    @Published var selectedBudgetId: String? = nil {
        didSet {
            resetAndReload()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let pageSize = 20 // Có thể điều chỉnh
    
    init() {
        // Tự động reload khi selectedBudgetId thay đổi
        $selectedBudgetId
            .dropFirst()
            .sink { [weak self] _ in
                self?.resetAndReload()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Transactions
    func loadTransactions(page: Int = 1, append: Bool = false) async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let filter: TransactionFilter? = selectedBudgetId.map { TransactionFilter(budgetId: $0) }
        
        do {
            let response = try await TransactionService.shared.getTransactions(
                page: page,
                filter: filter
            )
            
            let newTransactions = response.data
            
            if append {
                transactions.append(contentsOf: newTransactions)
            } else {
                transactions = newTransactions
            }
            
            hasMorePages = newTransactions.count == pageSize
            currentPage = page
            
        } catch {
            self.error = "Failed to load transactions: \(error.localizedDescription)"
            print("Transaction load error: \(error)")
        }
    }
    
    // MARK: - Pull to Refresh / Initial Load
    func refresh() async {
        await loadTransactions(page: 1, append: false)
    }
    
    // MARK: - Load More (Infinite Scroll)
    func loadMoreIfNeeded(currentTransaction: Transaction) async {
        guard hasMorePages,
              let lastTransaction = transactions.last,
              currentTransaction.id == lastTransaction.id else {
            return
        }
        
        await loadTransactions(page: currentPage + 1, append: true)
    }
    
    // MARK: - Reset & Reload
    private func resetAndReload() {
        transactions = []
        hasMorePages = true
        currentPage = 1
        Task { await refresh() }
    }
    
    // MARK: - Create Transaction
    func createTransaction(
        amount: Double,
        category: String,
        note: String?,
        date: Date,
        type: String,
        budget_id: String?,
        image_url: String? = nil
    ) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let isoDate = ISO8601DateFormatter().string(from: date)
        
        do {
            let newTx = try await TransactionService.shared.createTransaction(
                amount: amount,
                category: category,
                note: note,
                date: isoDate,
                type: type,
                budget_id: budget_id,
                image_url: image_url
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
    
    // MARK: - Update Transaction
    func updateTransaction(
        id: String,
        amount: Double? = nil,
        category: String? = nil,
        note: String? = nil,
        date: Date? = nil,
        type: String? = nil,
        budget_id: String? = nil,
        image_url: String? = nil
    ) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let isoDate = date.map { ISO8601DateFormatter().string(from: $0) }
        
        do {
            let updatedTx = try await TransactionService.shared.updateTransaction(
                id: id,
                amount: amount,
                category: category,
                note: note,
                date: isoDate,
                type: type,
                budget_id: budget_id,
                image_url: image_url
            )
            
            // Cập nhật trong danh sách
            if let index = transactions.firstIndex(where: { $0.id == id }) {
                transactions[index] = updatedTx
                
                // Nếu đổi budget → có thể cần loại bỏ nếu không còn phù hợp
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
    
    // MARK: - Delete Transaction
    func deleteTransaction(_ transaction: Transaction) async -> Bool {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            try await TransactionService.shared.deleteTransaction(id: transaction.id)
            
            // Xóa khỏi danh sách
            transactions.removeAll { $0.id == transaction.id }
            return true
        } catch {
            self.error = "Delete failed: \(error.localizedDescription)"
            return false
        }
    }
}