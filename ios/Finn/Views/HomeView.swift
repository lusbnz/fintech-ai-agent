import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    
    @State private var showNotification = false
    @State private var showCreateNew = false
    @State private var selectedType = "Tất cả"
    
    let types = ["Tất cả", "Nạp vào", "Chi ra"]
    
    private var userCurrency: String {
        (app.profile?.currency ?? "VND").uppercased()
    }
    
    private var latestTransactions: [Transaction] {
        var filtered = transactionViewModel.transactions
        switch selectedType {
        case "Nạp vào":
            filtered = filtered.filter { $0.type.lowercased() == "income" }
        case "Chi ra":
            filtered = filtered.filter { $0.type.lowercased() == "outcome" || $0.type.lowercased() == "expense" }
        default: break
        }
        return filtered.sorted { $0.date_time > $1.date_time }.prefix(5).map { $0 }
    }
    
    private var aiInsightText: String {
        return """
        Tuần này bạn chi 1.2 triệu cho cafe, tăng 40% so với tuần trước. Có vẻ họp nhiều nhỉ?
        """
    }

    
    var body: some View {
            ZStack {
                LinearGradient(colors: [Color(hex: "DDE9FF"), Color.white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        header
                        summaryBudgetCard
                    
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.leading)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Insight")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.purple)
                                
                                Text(aiInsightText)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical)
                            
                            Spacer()
                            
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                        )
                        .padding(.horizontal)
                        
                        if !app.budgets.isEmpty {
                            BudgetDonutChart(budgets: app.budgets, userCurrency: userCurrency)
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
            .navigationTitle("Trang chủ")
            .task {
                await transactionViewModel.loadTransactions(page: 1)
            }
    }
    
    private var header: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Xin chào, \(app.profile?.display_name ?? "Khách")")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                    Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
//                NavigationLink {
//                    BankNotificationsView()
//                } label: {
//                    Image(systemName: "icloud.fill")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.black)
//                        .padding(10)
//                        .background(Color.white)
//                        .clipShape(Circle())
//                        .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
//                }
                
                NavigationLink {
                    NotificationView()
                } label: {
                    Image(systemName: "bell.fill")
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
    
    private var summaryBudgetCard: some View {
        Group {
            if let budget = app.budgets.first {
                VStack(alignment: .leading, spacing: 12) {
                    Text(budget.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    Text("\(Int(budget.amount).formattedWithSeparator) \(userCurrency)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    Text("Còn \(Int(budget.limit).formattedWithSeparator) \(userCurrency) tới ngưỡng giới hạn")
                        .font(.system(size: 14)) .foregroundColor(.black)
                    HStack {
                        if let daysRemaining = budget.days_remaining, daysRemaining > 0 {
                            Text("\(Int(daysRemaining)) ngày còn lại")
                                .font(.system(size: 12))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        
                        let savedAmount = -(budget.diff_avg ?? 0)
                        let savedText: String = {
                            if savedAmount > 0 {
                                return "Tiết kiệm được: \(Int(savedAmount).formattedWithSeparator) \(userCurrency)"
                            } else if savedAmount < 0 {
                                return "Chi vượt: \(Int(-savedAmount).formattedWithSeparator) \(userCurrency)"
                            } else {
                                return "Tiết kiệm được: 0 \(userCurrency)"
                            }
                        }()
                        
                        Text(savedText)
                            .font(.system(size: 12))
                            .foregroundColor(savedAmount >= 0 ? .green : .red)
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
                                    VStack(alignment: .leading) { Text("\(Int(budget.total_income).formattedWithSeparator) \(userCurrency)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Nạp vào")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(16)
                                    VStack(alignment: .leading) {
                                        Text("\(Int(budget.total_outcome).formattedWithSeparator) \(userCurrency)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                    Text("Chi ra") .font(.system(size: 10))
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

    private var budgetList: some View {
        Group {
            if !app.budgets.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    
                    HStack {
                        Text("Ngân sách")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                        NavigationLink(
                            destination: BudgetView()
                        ) {
                            Text("Xem tất cả")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 14) {
                        ForEach(app.budgets.reversed().prefix(3)) { budget in
                            NavigationLink(
                                destination: BudgetDetailView(budget: budget)
                            ) {
                                BudgetItem(budget: budget)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

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
    
    private var transactionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Giao dịch mới nhất")
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
                Text("Không có giao dịch nào")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(latestTransactions) { tx in
                        NavigationLink(destination: CreateTransactionView(transaction: tx)) {
                            TransactionItem(
                                title: tx.name,
                                remain: tx.type == "outcome"
                                    ? "-\(Int(abs(tx.amount)).formattedWithSeparator) \(userCurrency)"
                                    : "+\(Int(tx.amount).formattedWithSeparator) \(userCurrency)",
                                time: tx.formattedDate,
                                attachments: (tx.image?.isEmpty == false) ? 1 : 0,
                                category: tx.category != nil ? tx.category : nil,
                                categoryColor: tx.type == "income" ? .green : .red,
                                categoryIcon: tx.type == "income" ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
    }
}

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
    var userCurrency: String
    
    var totalRemain: Double {
        budgets.map { $0.amount }.reduce(0, +)
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
    
    private var chartData: [BudgetSlice] {
        budgets.enumerated().map { index, budget in
            BudgetSlice(
                id: budget.id,
                name: budget.name,
                value: budget.amount,
                color: colors[index % colors.count]
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Phân phối ngân sách")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack(alignment: .center) {
                ZStack {
                    Chart(chartData) { item in
                        SectorMark(
                            angle: .value("Còn lại", item.value),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.color)
                    }
                    .chartLegend(.hidden)
                    .frame(width: 140, height: 140)
                    
                    VStack(spacing: 2) {
                        Text("\(Int(totalRemain).formattedWithSeparator)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(chartData.prefix(3)) { item in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 8, height: 8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 11, weight: .medium))
                                Text("\(Int(item.value).formattedWithSeparator) \(userCurrency)")
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
