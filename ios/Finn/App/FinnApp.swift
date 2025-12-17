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
    @StateObject private var settings = AppSettings.shared

    init() {
        let appState = AppState()
        _app = StateObject(wrappedValue: appState)
        _auth = StateObject(wrappedValue: AuthViewModel(app: appState))
        _budgetViewModel = StateObject(wrappedValue: BudgetViewModel(app: appState))
        _transactionViewModel = StateObject(wrappedValue: TransactionViewModel())
        _categoryViewModel = StateObject(wrappedValue: CategoryViewModel(app: appState))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(app)
                .environmentObject(auth)
                .environmentObject(budgetViewModel)
                .environmentObject(transactionViewModel)
                .environmentObject(categoryViewModel)
                .environmentObject(settings)
        }
    }
}
