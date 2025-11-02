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
    
    @State private var selectedTab: String = "All"
    @State private var selectedDate: String? = nil
    
    private var userCurrency: String {
        authViewModel.userProfile?.currency ?? "VNĐ"
    }
    
    private let tabs = ["All", "Income", "Outcome"]
    
    // MARK: - Filtered transactions for this budget
    private var budgetTransactions: [Transaction] {
        transactionVM.transactions.filter { $0.budget_id == budget.id }
    }
    
    private var filteredTransactions: [Transaction] {
        switch selectedTab {
        case "Income":
            return budgetTransactions.filter { $0.type == "income" }
        case "Outcome":
            return budgetTransactions.filter { $0.type == "outcome" }
        default:
            return budgetTransactions
        }
    }
    
    private var totalAmount: Double {
        let income = budgetTransactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
        let outcome = budgetTransactions.filter { $0.type == "outcome" }.reduce(0) { $0 + $1.amount }
        return income - outcome
    }
    
    // MARK: - Weekly chart data
    private var weeklyStats: [DailyStat] {
        let calendar = Calendar.current
        let today = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        
        // Lấy danh sách 7 ngày trong tuần hiện tại
        let daysInWeek: [Date] = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekInterval.start)
        }
        
        // Gom nhóm transaction theo ngày (startOfDay)
        let grouped = Dictionary(grouping: filteredTransactions) { tx -> Date in
            calendar.startOfDay(for: tx.displayDate ?? Date())
        }
        
        // Map ra đủ 7 ngày — nếu ngày nào không có data thì amount = 0
        return daysInWeek.map { day in
            let txs = grouped[day] ?? []
            let income = txs.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
            let outcome = txs.filter { $0.type == "outcome" }.reduce(0) { $0 + $1.amount }
            let net = income - outcome
            
            let df = DateFormatter()
            df.dateFormat = "E" // "Mon", "Tue", ...
            
            return DailyStat(date: df.string(from: day), amount: net)
        }
    }
    
    // MARK: - UI
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "F04A25"), .white],
                           startPoint: .top,
                           endPoint: .bottom)
                .opacity(0.5)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    titleSection
                    tabFilter
                    chartSection
                    transactionList
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if transactionVM.transactions.isEmpty {
                Task { await transactionVM.refresh() }
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2, y: 1)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Title section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(budget.name)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.black)
            Text("\(budgetTransactions.count) items")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            let formatted = "\(Int(abs(totalAmount)).formattedWithSeparator) \(userCurrency)"
            Text(totalAmount >= 0 ? "+\(formatted)" : "-\(formatted)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(totalAmount >= 0 ? .green : .red)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Tabs
    private var tabFilter: some View {
        HStack {
            FlexibleView(data: tabs) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? .black : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedTab == tab ? .white : .gray.opacity(0.2))
                        )
                        .shadow(color: selectedTab == tab ? .white.opacity(0.3) : .clear, radius: 3)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Chart
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This Week")
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
                                         startPoint: .bottom,
                                         endPoint: .top)
                        : LinearGradient(colors: [.red.opacity(0.7), .red],
                                         startPoint: .bottom,
                                         endPoint: .top)
                    )
                    .cornerRadius(6)
                }
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let amount = value.as(Double.self) {
                        AxisValueLabel("\(Int(amount).formattedWithSeparator)")
                    }
                }
            }
            .chartYScale(domain: [-maxY, maxY])
        }
        .padding(.horizontal)
    }
    
    // MARK: - Transaction list
    private var transactionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            if filteredTransactions.isEmpty {
                Text("No more transactions")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(filteredTransactions) { tx in
                    NavigationLink(destination: TransactionDetailView(transaction: tx)) {
                        TransactionItem(
                            title: tx.name,
                            remain: tx.type == "outcome"
                                ? "-\(Int(tx.amount).formattedWithSeparator) \(userCurrency)"
                                : "+\(Int(tx.amount).formattedWithSeparator) \(userCurrency)",
                            time: tx.formattedDate,
                            place: (tx.location?.name.isEmpty == false ? tx.location!.name : "Unknown"),
                            attachments: tx.image != nil ? 1 : 0,
                            categoryColor: tx.type == "income" ? .green : .red,
                            categoryIcon: tx.type == "income" ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
