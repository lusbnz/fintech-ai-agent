import SwiftUI

struct TransactionReccurringView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showCreateNew = false
    @State private var selectedBudget: String = "Tất cả"
    
    private var userCurrency: String {
        app.profile?.currency ?? "VNĐ"
    }
    
    private var budgetTags: [String] {
        ["Tất cả"] + app.budgets.map { $0.name }
    }
    
    private var selectedBudgetId: String? {
        guard selectedBudget != "All" else { return nil }
        return app.budgets.first { $0.name == selectedBudget }?.id
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "CFDBF8"), .white], startPoint: .top, endPoint: .bottom)
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                siteHeaderView
                transactionListView
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadInitialData()
        }
        .fullScreenCover(isPresented: $showCreateNew) {
            NavigationStack {
                CreateTransactionView()
            }
        }
    }
    
    private var siteHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }

                Spacer()
                Text("Giao dịch lặp lại")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Spacer().frame(width: 16)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Button {
                showCreateNew = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.5),
                                style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(height: 44)

                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                        Text("Tạo mới")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
    }
    
    private var transactionListView: some View {
        Group {
            if transactionViewModel.isLoading && transactionViewModel.reccurringTransactions.isEmpty {
                skeletonLoadingView
            } else if let error = transactionViewModel.error {
                errorView(for: error)
            } else if transactionViewModel.reccurringTransactions.isEmpty {
                emptyStateView
            } else {
                realTransactionList
            }
        }
    }
    
    @ViewBuilder
    private func errorView(for error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text(error)
                .font(.system(size: 14))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Thử lại") {
                Task { await transactionViewModel.refresh() }
            }
            .font(.system(size: 14, weight: .semibold))
            .padding(.horizontal, 32)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Không có giao dịch nào")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    @ViewBuilder
    private var skeletonLoadingView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<3) { _ in
                    SkeletonItem()
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .disabled(true)
    }
    
    private var realTransactionList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(transactionViewModel.reccurringTransactions, id: \.id) { tx in
                    RecurringTransactionRow(
                        tx: tx,
                        userCurrency: userCurrency
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .refreshable {
            transactionViewModel.error = nil
            transactionViewModel.hasMorePagesRecurring = true
            transactionViewModel.currentPageRecurring = 1
            transactionViewModel.isLoading = false
            await transactionViewModel.refresh()
        }
    }
    
    struct RecurringTransactionRow: View {
        let tx: TransactionReccurring
        let userCurrency: String

        private var remainText: String {
            if tx.type == "outcome" {
                return "-\(Int(abs(tx.amount))) \(userCurrency)"
            } else {
                return "+\(Int(tx.amount)) \(userCurrency)"
            }
        }

        private var categoryColor: Color {
            tx.type == "income" ? .green : .red
        }

        var body: some View {
            NavigationLink {
                CreateReccurringTransactionView(transaction: tx)
            } label: {
                TransactionReccurringItem(
                    title: tx.name,
                    remain: remainText,
                    time: tx.created_at,
                    attachments: tx.image != nil ? 1 : 0,
//                    category: tx.category != nil ? tx.category : nil,
                    categoryColor: categoryColor,
                    categoryIcon: "repeat.circle.fill",
                    lastRun: tx.last_run_at
                )
            }
            .buttonStyle(.plain)
        }
    }

    
    private func sortDates(_ a: String, _ b: String) -> Bool {
        if a == "Hôm nay" { return true }
        if b == "Hôm nay" { return false }
        if a == "Hôm qua" { return true }
        if b == "Hôm qua" { return false }
        return a > b
    }
    
    private func loadInitialData() {
        Task { await transactionViewModel.refresh() }
    }
}
