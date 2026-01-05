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
    @State private var showAddTransaction = false
    
    @State private var selectedTab: String = "Tất cả"
    @State private var chartRange: String = "Tuần"
    
    let chartRanges = ["Tuần", "Tháng"]
    private let tabs = ["Tất cả", "Thu vào", "Chi ra"]
    
    private var userCurrency: String {
        (app.profile?.currency ?? "VND").uppercased()
    }
    
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
    
    private var monthlyIncome: [DailyStat] {
        buildMonthlyStats(type: "income")
    }
    
    private var monthlyOutcome: [DailyStat] {
        buildMonthlyStats(type: "outcome")
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
        df.locale = Locale(identifier: "vi_VN")
        
        return days.map { day in
            let txs = grouped[day] ?? []
            let amount = txs.reduce(0) { $0 + $1.amount }
            return DailyStat(date: df.string(from: day), amount: amount)
        }
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
                VStack(spacing: 20) {
                    headerSection
                    summaryCard
                    quickStatsRow
                    chartSection
                    transactionSection
                }
                .padding(.bottom, 100)
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
        .fullScreenCover(isPresented: $showAddTransaction) {
            NavigationStack {
                CreateTransactionView(defaultBudgetId: budget.id)
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
            Text("Bạn có chắc là muốn xoá ngân sách?")
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
            }
            
            Spacer()
            
            Text("Chi tiết ngân sách")
                .font(.system(size: 17, weight: .semibold))
            
            Spacer()
            
            Menu {
                Button("Chỉnh sửa", systemImage: "pencil") { showEdit = true }
                Button("Xoá", systemImage: "trash", role: .destructive) { showDeleteConfirm = true }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var summaryCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text(budget.name)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text(formatCurrency(totalAmount))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(totalAmount >= 0 ? .primary : .red)
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 11))
                    Text("\(budgetTransactions.count) giao dịch")
                        .font(.system(size: 13))
                }
                .foregroundColor(.secondary)
            }
            
            if budget.limit > 0 {
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    budget.progress > 1 ? Color.red :
                                    (budget.progress > 0.8 ? Color.orange : Color.blue)
                                )
                                .frame(width: geo.size.width * CGFloat(min(budget.progress, 1.0)), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("Đã chi: \(formatCurrency(totalOutcome))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Giới hạn: \(formatCurrency(budget.limit + budget.amount))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if budget.recurring_active {
                HStack(spacing: 8) {
                    Image(systemName: "repeat")
                        .font(.system(size: 12))
                    Text("Nạp \(formatCurrency(budget.recurring_topup_amount)) / \(budget.recurring_interval_value) \(recurringUnitText)")
                        .font(.system(size: 13))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .padding(.horizontal, 16)
    }
    
    private var recurringUnitText: String {
        switch budget.recurring_interval_unit!.lowercased() {
        case "week": return "tuần"
        case "month": return "tháng"
        case "year": return "năm"
        default: return budget.recurring_interval_unit!
        }
    }

    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            // Income Card
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "arrow.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.green)
                        )
                    
                    Text("Thu vào")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Text(formatCurrency(totalIncome))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "arrow.up")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.red)
                        )
                    
                    Text("Chi ra")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Text(formatCurrency(totalOutcome))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.red)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        }
        .padding(.horizontal, 16)
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Thống kê")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(chartRanges, id: \.self) { range in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                chartRange = range
                            }
                        } label: {
                            Text(range)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(chartRange == range ? .white : .secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    chartRange == range ?
                                    Capsule().fill(Color.black) :
                                    Capsule().fill(Color.clear)
                                )
                        }
                    }
                }
                .padding(3)
                .background(Capsule().fill(Color(.systemGray6)))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Thu vào")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatCurrency(totalIncome))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                Chart {
                    ForEach(chartRange == "Tháng" ? monthlyIncome : weeklyIncome) { stat in
                        AreaMark(
                            x: .value("Ngày", stat.date),
                            y: .value("Thu", stat.amount)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.green.opacity(0.3), Color.green.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Ngày", stat.date),
                            y: .value("Thu", stat.amount)
                        )
                        .foregroundStyle(Color.green)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                }
                .frame(height: 120)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(.system(size: 9))
                            .foregroundStyle(Color.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("Chi ra")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatCurrency(totalOutcome))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.red)
                }
                
                Chart {
                    ForEach(chartRange == "Tháng" ? monthlyOutcome : weeklyOutcome) { stat in
                        AreaMark(
                            x: .value("Ngày", stat.date),
                            y: .value("Chi", stat.amount)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.red.opacity(0.3), Color.red.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Ngày", stat.date),
                            y: .value("Chi", stat.amount)
                        )
                        .foregroundStyle(Color.red)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                }
                .frame(height: 120)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(.system(size: 9))
                            .foregroundStyle(Color.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .padding(.horizontal, 16)
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
                attachments: (tx.image?.isEmpty == false) ? 1 : 0,
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
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: abs(value))) ?? "0"
        let sign = value < 0 ? "-" : (value > 0 ? "+" : "")
        return "\(sign)\(formatted) \(userCurrency)"
    }
}

struct TransactionRowDetail: View {
    let transaction: Transaction
    let userCurrency: String
    
    private var isIncome: Bool {
        transaction.type.lowercased() == "income"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isIncome ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: isIncome ? "arrow.down" : "arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isIncome ? .green : .red)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name ?? "Giao dịch")
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(transaction.formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if let category = transaction.category {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(category.name)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Text(isIncome
                 ? "+\(Int(transaction.amount).formattedWithSeparator) \(userCurrency)"
                 : "-\(Int(abs(transaction.amount)).formattedWithSeparator) \(userCurrency)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isIncome ? .green : .red)
        }
        .padding(.vertical, 10)
    }
}
