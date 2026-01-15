import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isAppReady = false
    @Published var isLoadingInitialData = false
    @Published var initialLoadError: String?
    
    @Published var profile: User? = nil
    @Published var budgets: [Budget] = []
    @Published var transactions: [Transaction] = []
    @Published var reccurringTransactions: [TransactionReccurring] = []
    @Published var categories: [Category] = []
    @Published var noti: [Noti] = []
    @Published var chats: [Chat] = []
    @Published var homeInsight: InsightData? = nil
    
    let settings = AppSettings.shared

    func preloadInitialData() async {
        guard !isAppReady else { return }

        isLoadingInitialData = true
        initialLoadError = nil

        defer {
            isLoadingInitialData = false
        }

        do {
            async let userResponse = AuthService.shared.getProfile()
            async let budgetResponse = BudgetService.shared.getBudgets(page: 1)
            async let transactionResponse = TransactionService.shared.getTransactions(page: 1)
            async let reccurringTransactionResponse = TransactionService.shared.getReccurringTransactions(page: 1)
            async let categoryResponse = CategoryService.shared.getCategories(page: 1)
            async let chatResponse = ChatService.shared.getChats(page: 1)
            async let homeInsightResponse = DashboardService.shared.getInsight(period: "3_days")

            let userResult = try await userResponse
            let budgetResult = try await budgetResponse
            let transactionResult = try await transactionResponse
            let reccurringTransactionResult = try await reccurringTransactionResponse
            let categoryResult = try await categoryResponse
            let chatResult = try await chatResponse
            let homeInsightResult = try await homeInsightResponse

            self.profile = userResult.self
            self.budgets = budgetResult.data.data
            self.transactions = transactionResult.data
            self.reccurringTransactions = reccurringTransactionResult.data
            self.categories = categoryResult.data
            self.chats = chatResult.data
            self.homeInsight = homeInsightResult
            
            if budgetResult.data.data.count == 0 {
                settings.isSettedFirstBudeget = false
            }

            isAppReady = true

        } catch {
            isAppReady = true
            initialLoadError = "Tải dữ liệu ban đầu thất bại."
        }
    }
}
