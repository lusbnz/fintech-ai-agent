import SwiftUI
import FirebaseCore
import Foundation
import Combine
import FirebaseMessaging

@main
struct FinnApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var app = AppState()
    @StateObject var auth: AuthViewModel
    @StateObject var budgetViewModel: BudgetViewModel
    @StateObject var transactionViewModel: TransactionViewModel
    @StateObject var categoryViewModel: CategoryViewModel
    @StateObject var chatViewModel: ChatViewModel
    @StateObject var dashboardViewModel: DashboardViewModel
    @StateObject private var settings = AppSettings.shared

    init() {
        let appState = AppState()
        _app = StateObject(wrappedValue: appState)
        _auth = StateObject(wrappedValue: AuthViewModel(app: appState))
        _budgetViewModel = StateObject(wrappedValue: BudgetViewModel(app: appState))
        _transactionViewModel = StateObject(wrappedValue: TransactionViewModel())
        _categoryViewModel = StateObject(wrappedValue: CategoryViewModel(app: appState))
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(app: appState))
        _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
                .environmentObject(auth)
                .environmentObject(budgetViewModel)
                .environmentObject(transactionViewModel)
                .environmentObject(categoryViewModel)
                .environmentObject(chatViewModel)
                .environmentObject(dashboardViewModel)
                .environmentObject(settings)
        }
    }
}
