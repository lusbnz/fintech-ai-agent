import SwiftUI
import Charts

struct DailyStat: Identifiable {
    let id = UUID()
    let date: String
    let amount: Double
}

struct BudgetDetailView: View {
    let budget: Budget
    @EnvironmentObject var app: AppState
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showEdit = false
    @State private var showDeleteConfirm = false
    
    @State private var selectedTab: String = "Tất cả"
    @State private var selectedDate: String? = nil
    
    @State private var chartRange: String = "Tuần"
    let chartRanges = ["Tuần", "Tháng"]
    
    private var userCurrency: String {
        app.profile?.currency ?? "VNĐ"
    }
    
    private let tabs = ["Tất cả", "Thu vào", "Chi ra"]
    
    private var budgetTransactions: [Transaction] {
        transactionViewModel.transactions.filter { $0.budget_id == budget.id }
    }
    
    private var filteredTransactions: [Transaction] {
        switch selectedTab {
        case "Thu vào": return budgetTransactions.filter { $0.type == "income" }
        case "Chi ra": return budgetTransactions.filter { $0.type == "outcome" }
        default: return budgetTransactions
        }
    }
    
    private var totalIncome: Double {
        budgetTransactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalOutcome: Double {
        budgetTransactions.filter { $0.type == "outcome" }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalAmount: Double {
        totalIncome - totalOutcome
    }
    
    private var weeklyIncome: [DailyStat] {
        buildWeeklyStats(type: "income")
    }
    
    private var weeklyOutcome: [DailyStat] {
        buildWeeklyStats(type: "outcome")
    }
    
    private func buildWeeklyStats(type: String) -> [DailyStat] {
        let calendar = Calendar.current
        let today = Date()
        guard let week = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: week.start) }
        
        let grouped = Dictionary(grouping: budgetTransactions.filter { $0.type == type }) {
            calendar.startOfDay(for: $0.displayDate ?? Date())
        }
        
        let df = DateFormatter()
        df.dateFormat = "E"
        
        return days.map { day in
            let txs = grouped[day] ?? []
            let amount = txs.reduce(0) { $0 + $1.amount }
            return DailyStat(date: df.string(from: day), amount: amount)
        }
    }
    
    private var monthlyIncome: [DailyStat] {
        buildMonthlyStats(type: "income")
    }
    
    private var monthlyOutcome: [DailyStat] {
        buildMonthlyStats(type: "outcome")
    }
    
    private func buildMonthlyStats(type: String) -> [DailyStat] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let month = calendar.dateInterval(of: .month, for: today) else { return [] }
        let totalDays = calendar.range(of: .day, in: .month, for: today) ?? 1..<30
        
        let grouped = Dictionary(grouping: budgetTransactions.filter { $0.type == type }) {
            calendar.startOfDay(for: $0.displayDate ?? Date())
        }
        
        let df = DateFormatter()
        df.dateFormat = "d"
        
        return totalDays.compactMap { day -> DailyStat? in
            guard let date = calendar.date(bySetting: .day, value: day, of: month.start) else { return nil }
            let amount = (grouped[date] ?? []).reduce(0) { $0 + $1.amount }
            return DailyStat(date: df.string(from: date), amount: amount)
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F04A25"),
                    Color(hex: "FFFFFF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.5)
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    header
                    summaryCard
                    chartSection
//                    if budget.recurring_active {
//                        reccurringSection
//                    }
                    transactionSection
                }
                .padding(.vertical)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if transactionViewModel.transactions.isEmpty {
                Task { await transactionViewModel.refresh() }
            }
        }
        .fullScreenCover(isPresented: $showEdit) {
            NavigationStack {
                CreateBudgetView(budget: budget) { dismiss() }
            }
        }
        .alert("Xoá ngân sách", isPresented: $showDeleteConfirm) {
            Button("Huỷ", role: .cancel) {}
            Button("Xoá", role: .destructive) {
                Task {
                    let success = await budgetViewModel.deleteBudget(budget)
                    if success { dismiss() }
                }
            }
        } message: {
            Text("Bạn có chắc là muốn xoá ngân sách “\(budget.name)”?")
        }
    }
    
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            Spacer()
            Menu {
                Button("Chỉnh sửa", systemImage: "pencil") { showEdit = true }
                Button("Xoá", systemImage: "trash", role: .destructive) { showDeleteConfirm = true }
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

    private var summaryCard: some View {
        VStack(spacing: 10) {
            Text(budget.name)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.black)
            
            Text("\(budgetTransactions.count) giao dịch")
                .font(.system(size: 13))
                .foregroundColor(.gray)
            
            Text(totalAmount >= 0 ?
                 "+\(Int(abs(totalAmount)).formattedWithSeparator) \(userCurrency)" :
                 "-\(Int(abs(totalAmount)).formattedWithSeparator) \(userCurrency)"
            )
            .font(.system(size: 30, weight: .bold))
            .foregroundColor(totalAmount >= 0 ? .green : .red)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        .padding(.horizontal)
    }

    // ----------------------------------------------------------------------
    // MARK: - Chart: 2 line charts (Income & Outcome)
    // ----------------------------------------------------------------------

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            
            HStack {
                Text("Thống kê")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Spacer()
                
                Picker("", selection: $chartRange) {
                    ForEach(chartRanges, id: \.self) { range in
                        Text(range)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
            }

            VStack(alignment: .leading) {
                Text("Nạp vào")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.green)
                
                Chart {
                    ForEach(chartRange == "Tháng" ? monthlyIncome : weeklyIncome) { stat in
                        LineMark(
                            x: .value("Ngày", stat.date),
                            y: .value("Thu", stat.amount)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.green)
                        
                        PointMark(
                            x: .value("Ngày", stat.date),
                            y: .value("Thu", stat.amount)
                        )
                        .foregroundStyle(.green)
                    }
                }
                .frame(height: 160)
            }

            VStack(alignment: .leading) {
                Text("Chi ra")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.red)
                
                Chart {
                    ForEach(chartRange == "Tháng" ? monthlyOutcome : weeklyOutcome) { stat in
                        LineMark(
                            x: .value("Ngày", stat.date),
                            y: .value("Chi", stat.amount)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.red)
                        
                        PointMark(
                            x: .value("Ngày", stat.date),
                            y: .value("Chi", stat.amount)
                        )
                        .foregroundStyle(.red)
                    }
                }
                .frame(height: 160)
            }

        }
        .padding()
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 5, y: 2)
        .padding(.horizontal)
    }
    
    private var transactionHeader: some View {
        Text("Giao dịch")
            .font(.system(size: 18, weight: .bold))
            .padding(.horizontal)
    }
    
    private var transactionList: some View {
        Group {
            if filteredTransactions.isEmpty {
                emptyStateView
            } else {
                transactionItemsList
            }
        }
    }

    private var emptyStateView: some View {
        Text("Chưa có giao dịch nào")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
    }

    private var transactionItemsList: some View {
        ForEach(filteredTransactions) { tx in
            transactionRow(for: tx)
        }
    }

    private func transactionRow(for tx: Transaction) -> some View {
        NavigationLink(destination: CreateTransactionView(transaction: tx)) {
            TransactionItem(
                title: tx.name,
                remain: tx.type == "outcome"
                    ? "-\(Int(tx.amount).formattedWithSeparator) \(userCurrency)"
                    : "+\(Int(tx.amount).formattedWithSeparator) \(userCurrency)",
                time: tx.formattedDate,
                attachments: tx.image != nil ? 1 : 0,
                category: tx.category != nil ? tx.category : nil,
                categoryColor: tx.type == "income" ? .green : .red,
                categoryIcon: tx.type == "income" ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
            )
            .padding(.horizontal)
        }
    }

    private var transactionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            transactionHeader
            transactionList
        }
        .padding(.bottom, 40)
    }
    
    private var reccurringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nạp tiền định kì")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)
            Text("\(budget.recurring_topup_amount) \(userCurrency) / \(budget.recurring_interval_value) \(budget.recurring_interval_unit)")
                .font(.system(size: 16))
                .padding(.horizontal)
        }
        .padding(.bottom, 40)
    }
}
