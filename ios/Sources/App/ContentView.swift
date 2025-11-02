import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var budgetViewModel = BudgetViewModel()
    @StateObject private var transactionViewModel = TransactionViewModel()

    var body: some View {
        if authViewModel.isLoggedIn, authViewModel.userProfile != nil {
            WrapperView()
                .environmentObject(authViewModel)
                .environmentObject(budgetViewModel)
                .environmentObject(transactionViewModel)
        } else if !authViewModel.isLoading {
            IntroView()
                .environmentObject(authViewModel)
        }
    }
}
