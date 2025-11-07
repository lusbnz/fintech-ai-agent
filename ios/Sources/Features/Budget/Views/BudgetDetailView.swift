import SwiftUI
import Charts

struct DailyStat: Identifiable {
    let id = UUID()
    let date: String
    let amount: Double
}

struct BudgetDetailView: View {
    let budget: Budget
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var budgetVM = BudgetViewModel()
    
    @State private var showEdit = false
    @State private var showDeleteConfirm = false
    
    @State private var selectedTab: String = "All"
    @State private var selectedDate: String? = nil
    
    private var userCurrency: String {
        authViewModel.userProfile?.currency ?? "VNĐ"
    }
    
    private let tabs = ["All", "Income", "Outcome"]
    
    // MARK: - Filtered transactions
    private var budgetTransactions: [Transaction] {
        transactionVM.transactions.filter { $0.budget_id == budget.id }
    }
    
    private var filteredTransactions: [Transaction] {
        switch selectedTab {
        case "Income": return budgetTransactions.filter { $0.type == "income" }
        case "Outcome": return budgetTransactions.filter { $0.type == "outcome" }
        default: return budgetTransactions
        }
    }
    
    private var totalAmount: Double {
        let income = budgetTransactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
        let outcome = budgetTransactions.filter { $0.type == "outcome" }.reduce(0) { $0 + $1.amount }
        return income - outcome
    }
    
    // MARK: - Weekly stats
    private var weeklyStats: [DailyStat] {
        let calendar = Calendar.current
        let today = Date()
        guard let week = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: week.start) }
        let grouped = Dictionary(grouping: filteredTransactions) { tx in
            calendar.startOfDay(for: tx.displayDate ?? Date())
        }
        let df = DateFormatter()
        df.dateFormat = "E"
        
        return days.map { day in
            let txs = grouped[day] ?? []
            let income = txs.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
            let outcome = txs.filter { $0.type == "outcome" }.reduce(0) { $0 + $1.amount }
            return DailyStat(date: df.string(from: day), amount: income - outcome)
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "F04A25"), Color.white],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    header
                    summaryCard
                    tabFilter
                    chartSection
                    transactionSection
                }
                .padding(.vertical)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if transactionVM.transactions.isEmpty {
                Task { await transactionVM.refresh() }
            }
        }
        .fullScreenCover(isPresented: $showEdit) {
            NavigationStack {
                CreateBudgetView(budget: budget) { dismiss() }
            }
        }
        .alert("Delete Budget", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    let success = await budgetVM.deleteBudget(budget)
                    if success { dismiss() }
                }
            }
        } message: {
            Text("Are you sure you want to delete “\(budget.name)”?")
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            }
            Spacer()
            Menu {
                Button("Edit", systemImage: "pencil") { showEdit = true }
                Button("Delete", systemImage: "trash", role: .destructive) { showDeleteConfirm = true }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Summary
    private var summaryCard: some View {
        VStack(spacing: 10) {
            Text(budget.name)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.black)
            
            Text("\(budgetTransactions.count) transactions")
                .font(.system(size: 13))
                .foregroundColor(.gray)
            
            Text(totalAmount >= 0 ?
                 "+\(Int(abs(totalAmount)).formattedWithSeparator) \(userCurrency)" :
                 "-\(Int(abs(totalAmount)).formattedWithSeparator) \(userCurrency)")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(
                    totalAmount >= 0
                    ? LinearGradient(colors: [.green], startPoint: .top, endPoint: .bottom)
                    : LinearGradient(colors: [.red], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        .padding(.horizontal)
    }
    
    // MARK: - Tabs
    private var tabFilter: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { selectedTab = tab }
                } label: {
                    Text(tab)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? .black : .white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedTab == tab ? .white : .gray.opacity(0.15))
                        )
                        .shadow(color: selectedTab == tab ? .black.opacity(0.08) : .clear, radius: 3, y: 2)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Chart
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This Week Overview")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            let maxY = (weeklyStats.map { abs($0.amount) }.max() ?? 1000)
            
            Chart {
                ForEach(weeklyStats) { stat in
                    BarMark(
                        x: .value("Date", stat.date),
                        y: .value("Amount", stat.amount)
                    )
                    .foregroundStyle(
                        stat.amount >= 0
                        ? LinearGradient(colors: [.green.opacity(0.7), .green],
                                         startPoint: .bottom, endPoint: .top)
                        : LinearGradient(colors: [.red.opacity(0.7), .red],
                                         startPoint: .bottom, endPoint: .top)
                    )
                    .cornerRadius(6)
                    .annotation(position: .top) {
                        if abs(stat.amount) > 0 {
                            Text("\(Int(stat.amount).formattedWithSeparator)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(height: 180)
            .chartYScale(domain: [-maxY, maxY])
            .padding(.top, 8)
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 5, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Transactions
    private var transactionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transactions")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)
            
            if filteredTransactions.isEmpty {
                Text("No transactions available")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                ForEach(filteredTransactions) { tx in
                    NavigationLink(destination: TransactionDetailView(transaction: tx)) {
                        TransactionItem(
                            title: tx.name,
                            remain: tx.type == "outcome"
                                ? "-\(Int(tx.amount).formattedWithSeparator) \(userCurrency)"
                                : "+\(Int(tx.amount).formattedWithSeparator) \(userCurrency)",
                            time: tx.formattedDate,
                            place: tx.location?.name ?? "Unknown",
                            attachments: tx.image != nil ? 1 : 0,
                            categoryColor: tx.type == "income" ? .green : .red,
                            categoryIcon: tx.type == "income" ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
                        )
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.bottom, 40)
    }
}
