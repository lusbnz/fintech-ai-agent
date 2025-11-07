import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    
    @State private var showCreateNew = false
    @State private var selectedType = "All"
    
    let types = ["All", "Income", "Outgoing"]
    
    private var userCurrency: String {
        authViewModel.userProfile?.currency ?? "VNĐ"
    }
    
    // MARK: - Filter & Sort
    private var latestTransactions: [Transaction] {
        var filtered = transactionVM.transactions
        switch selectedType {
        case "Income":
            filtered = filtered.filter { $0.type.lowercased() == "income" }
        case "Outgoing":
            filtered = filtered.filter { $0.type.lowercased() == "outcome" || $0.type.lowercased() == "expense" }
        default: break
        }
        return filtered.sorted { $0.date_time > $1.date_time }.prefix(5).map { $0 }
    }
    
    // MARK: - UI
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "DDE9FF"), Color.white],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    summaryBudgetCard
                    if !budgetViewModel.budgets.isEmpty {
                        BudgetDonutChart(budgets: budgetViewModel.budgets)
                            .padding(.horizontal)
                    }
                    budgetList
                    transactionSection
                }
                .padding(.bottom, 60)
                .padding(.top, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Home")
        .task {
            await budgetViewModel.loadBudgets()
            await transactionVM.refresh()
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, \(authViewModel.userProfile?.display_name ?? "Guest") 👋")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.black)
                Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            NavigationLink {
                SettingView(authViewModel: authViewModel)
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Summary Card (main budget)
    private var summaryBudgetCard: some View {
        Group {
            if budgetViewModel.isLoading {
                ProgressView("Loading budgets...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let budget = budgetViewModel.budgets.first {
                VStack(alignment: .leading, spacing: 12) {
                    Text(budget.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    Text("\(Int(budget.remain).formattedWithSeparator) VNĐ")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    Text("Left to spend of \(Int(budget.limit).formattedWithSeparator) VNĐ limit")
                        .font(.system(size: 14)) .foregroundColor(.black)
                    HStack {
                            Text("\(Int(budget.days_remaining)) days to go")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(Int(-budget.diff_avg).formattedWithSeparator) saved")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                        }
                    GeometryReader {
                        geometry in ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            Capsule()
                                .fill(Color.blue)
                                .frame( width: geometry.size.width * CGFloat(budget.progress), height: 6 )
                        }
                    }
                    .frame(height: 6)
                    HStack(spacing: 8) {
                                    VStack(alignment: .leading) { Text("\(Int(budget.total_income).formattedWithSeparator) VNĐ")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Incoming")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(16)
                                    VStack(alignment: .leading) {
                                        Text("\(Int(budget.total_outcome).formattedWithSeparator) VNĐ")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Outgoing") .font(.system(size: 10))
                                    .foregroundColor(.gray) }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                        .padding(.vertical, 12) .background(Color.gray.opacity(0.2))
                                    .cornerRadius(16) } }
                .padding()
                .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)
            }
        }
    }

    // MARK: - Budget list
    private var budgetList: some View {
        Group {
            if !budgetViewModel.budgets.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Header
                    HStack {
                        Text("Your Budgets")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                        NavigationLink(
                            destination: BudgetView()
                                .environmentObject(authViewModel)
                                .environmentObject(transactionVM)
                        ) {
                            Text("See all")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray) // 👉 đổi từ xanh sang xám trung tính
                        }
                    }
                    .padding(.horizontal)
                    
                    // List
                    VStack(spacing: 14) {
                        ForEach(budgetViewModel.budgets.prefix(3)) { budget in
                            let color: Color = budget.progress < 0.7 ? .mint :
                                               (budget.progress < 0.9 ? .orange : .red)
                            
                            NavigationLink(
                                destination: BudgetDetailView(budget: budget)
                                    .environmentObject(authViewModel)
                                    .environmentObject(transactionVM)
                            ) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(budget.name)
                                            .font(.system(size: 15, weight: .semibold))
                                        Spacer()
                                        Text("\(Int(budget.progress * 100))%")
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                    }
                                    BudgetProgressBar(progress: CGFloat(budget.progress), color: color)
                                        .frame(height: 8)
                                    
                                    HStack {
                                        Text("Remain: \(Int(budget.remain).formattedWithSeparator) \(userCurrency)")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("Limit: \(Int(budget.limit).formattedWithSeparator) \(userCurrency)")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    
    // MARK: - Transaction Section
    private var transactionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Latest Transactions")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal)
            
            FlexibleView(data: types) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { selectedType = type }
                } label: {
                    Text(type)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedType == type ? .black : .gray)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedType == type ? .white : .gray.opacity(0.15))
                        )
                        .shadow(color: selectedType == type ? .black.opacity(0.08) : .clear, radius: 3, y: 1)
                }
            }
            .padding(.horizontal)
            
            if latestTransactions.isEmpty {
                Text("No transactions yet")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(latestTransactions) { tx in
                        NavigationLink(destination: TransactionDetailView(transaction: tx)) {
                            TransactionItem(
                                title: tx.name,
                                remain: tx.type == "outcome"
                                    ? "-\(Int(abs(tx.amount)).formattedWithSeparator) \(userCurrency)"
                                    : "+\(Int(tx.amount).formattedWithSeparator) \(userCurrency)",
                                time: tx.formattedDate,
                                place: tx.location?.name ?? "Unknown",
                                attachments: tx.image != nil ? 1 : 0,
                                categoryColor: tx.type == "income" ? .green : .red,
                                categoryIcon: tx.type == "income" ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper Components
    private func statBox(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Progress Ring (for budget summary)
struct ProgressRingView: View {
    var progress: Double
    var lineWidth: CGFloat = 10
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [.blue, .green, .mint]),
                                    center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
            Text("\(Int(progress * 100))%")
                .font(.system(size: 14, weight: .semibold))
        }
    }
}


struct BudgetDonutChart: View {
    var budgets: [Budget]
    
    var totalRemain: Double {
        budgets.map { $0.remain }.reduce(0, +)
    }

    private let colors: [Color] = [
        .blue.opacity(0.8),
        .green.opacity(0.8),
        .orange.opacity(0.8),
        .purple.opacity(0.8),
        .pink.opacity(0.8),
        .teal.opacity(0.8),
        .mint.opacity(0.8)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Budget Distribution")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            // Chart
            HStack(alignment: .center) {
                ZStack {
                    Chart {
                        ForEach(Array(budgets.enumerated()), id: \.element.id) { index, budget in
                            SectorMark(
                                angle: .value("Remain", budget.remain),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.5
                            )
                            .foregroundStyle(colors[index % colors.count])
                        }
                    }
                    .chartLegend(.hidden)
                    .frame(width: 140, height: 140)
                    
                    VStack(spacing: 2) {
                        Text("\(Int(totalRemain).formattedWithSeparator)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                        Text("Total Remain")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(budgets.enumerated().prefix(3)), id: \.element.id) { index, budget in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(colors[index % colors.count])
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(budget.name)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.black)
                                Text("\(Int(budget.remain).formattedWithSeparator) VNĐ")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    if budgets.count > 3 {
                        Text("+\(budgets.count - 3) more...")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                }
                
                Spacer()

            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}


struct BudgetProgressBar: View {
    var progress: CGFloat
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                Capsule()
                    .fill(color)
                    .frame(width: geometry.size.width * min(progress, 1.0), height: 8)
            }
        }
        .frame(height: 8)
    }
}

extension Numeric {
    var formattedWithSeparator: String {
        Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
}
