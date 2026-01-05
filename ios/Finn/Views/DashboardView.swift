import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    
    @State private var selectedTab = 0
    @State private var selectedPeriod = 0
    @State private var showAllCategories = false
    
    private let periods = ["Tuần", "Tháng"]
    
    private var totalChi: Double {
        dashboardViewModel.dashboardData?.summary.totalExpenses ?? 0
    }

    private var totalThu: Double {
        dashboardViewModel.dashboardData?.summary.totalIncome ?? 0
    }

    private var balance: Double {
        dashboardViewModel.dashboardData?.summary.balance ?? 0
    }
    
    private var aiInsightText: String {
        guard let data = dashboardViewModel.dashboardData else {
            return "Đang tải dữ liệu..."
        }
        
        let expenseBudgets = data.budgets.filter { $0.amount < 0 }
        guard let topCategory = expenseBudgets.max(by: { abs($0.amount) < abs($1.amount) }) else {
            return "Chưa có dữ liệu chi tiêu."
        }
        
        let percentOfTotal = (abs(topCategory.amount) / data.summary.totalExpenses * 100).rounded()
        
        return "Chi tiêu \(topCategory.name) chiếm \(Int(percentOfTotal))% tổng chi. Cân nhắc giảm để cải thiện dòng tiền."
    }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    balanceCard
                    quickStatsRow
                    aiInsightCard
                    chartSection
                    tabSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray6).opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .task {
                let initialPeriod = selectedPeriod == 0 ? "week" : "month"
                await dashboardViewModel.loadData(for: initialPeriod)
            }

            if dashboardViewModel.isLoading {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()

                VStack(spacing: 10) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.0)
                    
                    Text("Đang tải...")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.quaternary, lineWidth: 0.5)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: dashboardViewModel.isLoading)
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tổng quan tài chính")
                    .font(.system(size: 22, weight: .bold))
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                ForEach(0..<periods.count, id: \.self) { index in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedPeriod = index
                        }
                        Task {
                            let apiPeriod = periods[index] == "Tuần" ? "week" : "month"
                            await dashboardViewModel.loadData(for: apiPeriod)
                        }
                    } label: {
                        Text(periods[index])
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedPeriod == index ? .white : .secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                selectedPeriod == index ?
                                Capsule().fill(Color.black) :
                                Capsule().fill(Color.clear)
                            )
                    }
                }
            }
            .padding(3)
            .background(Capsule().fill(Color.white))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
        .padding(.top, 8)
    }
    
    private var balanceCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("Số dư hiện tại")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Text(formatCurrency(balance))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 0) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "arrow.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.green)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Thu nhập")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(formatCurrency(totalThu))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1, height: 36)
                
                Spacer()
                
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "arrow.up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Chi tiêu")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text(formatCurrency(totalChi))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
    
    @ViewBuilder
    private var quickStatsRow: some View {
        if let summary = dashboardViewModel.dashboardData?.summary {
            HStack(spacing: 12) {
                QuickStatCard(
                    icon: "arrow.left.arrow.right",
                    title: "Giao dịch",
                    value: "\(summary.transactionCount)",
                    trend: "0",
                    trendUp: true,
                    color: .blue
                )
                
                QuickStatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "TB/ngày",
                    value: formatCurrency(summary.avgPerDay),
                    trend: "0",
                    trendUp: false,
                    color: .orange
                )
                
                QuickStatCard(
                    icon: "target",
                    title: "Ngân sách",
                    value: "\(summary.budgetUsagePercent)%",
                    trend: summary.budgetUsagePercent <= 100 ? "Tốt" : "Vượt",
                    trendUp: summary.budgetUsagePercent <= 100,
                    color: summary.budgetUsagePercent <= 100 ? .green : .red
                )
            }
        } else {
            HStack {
                ProgressView()
            }
            .frame(height: 80)
        }
    }
    
    private var aiInsightCard: some View {
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Insight")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.purple)
                
                Text(aiInsightText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Thu Chi theo ngày")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
            }
            
            if let chartData = dashboardViewModel.dashboardData?.chartData {
                RealBarChartView(data: chartData)
                    .frame(height: 160)
            } else {
                ProgressView()
                    .frame(height: 160)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }
    
    private var tabSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                ForEach(["Danh mục", "Ngân sách"].indices, id: \.self) { index in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = index
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(index == 0 ? "Danh mục" : "Ngân sách")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedTab == index ? .black : .secondary)
                            
                            Rectangle()
                                .fill(selectedTab == index ? Color.black : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            if selectedTab == 0 {
                categoryList
            } else {
                budgetList
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }
    
    private var categoryList: some View {
        VStack(spacing: 0) {
            ForEach(sampleCategories().prefix(showAllCategories ? 10 : 4)) { item in
                CategoryRowNew(item: item, total: totalChi)
                
                if item.id != sampleCategories().last?.id {
                    Divider()
                        .padding(.leading, 52)
                }
            }
            
            if sampleCategories().count > 4 {
                Button {
                    withAnimation {
                        showAllCategories.toggle()
                    }
                } label: {
                    HStack {
                        Text(showAllCategories ? "Thu gọn" : "Xem tất cả")
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: showAllCategories ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                    .padding(.top, 12)
                }
            }
        }
    }
    
    private var budgetList: some View {
        Group {
            if let budgets = dashboardViewModel.dashboardData?.budgets, !budgets.isEmpty {
                VStack(spacing: 12) {
                    ForEach(budgets) { item in
                        BudgetRowNew(item: item)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Đang tải ngân sách...")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
    }
}

struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    let trend: String
    let trendUp: Bool
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                
                Spacer()
                
                if trend != "0" {
                    Text(trend)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(trendUp ? .green : .orange)
                }
            }
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        )
    }
}

struct RealBarChartView: View {
    let data: [ChartDataPoint]
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                if item.income > 0 {
                    BarMark(
                        x: .value("Day", item.label),
                        y: .value("Amount", item.income / 1_000_000)
                    )
                    .foregroundStyle(Color.green.gradient)
                    .position(by: .value("Type", "Thu"))
                }
                
                if item.outcome > 0 {
                    BarMark(
                        x: .value("Day", item.label),
                        y: .value("Amount", -item.outcome / 1_000_000)
                    )
                    .foregroundStyle(Color.red.opacity(0.8).gradient)
                    .position(by: .value("Type", "Chi"))
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 6)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(Color.gray.opacity(0.3))
                AxisValueLabel {
                    if let val = value.as(Double.self) {
                        Text(val >= 0 ? "\(Int(val))M" : "\(Int(-val))M")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartLegend(position: .bottom, alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                LegendItem(color: .green, text: "Thu")
                LegendItem(color: .red.opacity(0.8), text: "Chi")
            }
        }
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

struct CategoryRowNew: View {
    let item: FakeCategoryItem
    let total: Double
    
    private var percent: Double {
        guard total > 0 else { return 0 }
        return item.amount / total
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.name)
                        .font(.system(size: 14, weight: .medium))
                    
                    Spacer()
                    
                    Text(formatCurrency(item.amount))
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
        .padding(.vertical, 10)
    }
}

struct BudgetRowNew: View {
    let item: DashboardBudget
    
    private var isOverBudget: Bool {
        item.percent > 1
    }
    
    private var percentDisplay: Int {
        Int((item.percent * 100).rounded())
    }
    
    private var progressWidthRatio: Double {
        min(item.percent, 1.0)
    }
    
    private var barColor: Color {
        if isOverBudget {
            return .red
        } else if item.percent > 0.8 {
            return .orange
        } else {
            return .blue
        }
    }
    
    private var badgeBackground: Color {
        isOverBudget ? .red : (item.percent > 0.8 ? .orange.opacity(0.15) : .green.opacity(0.15))
    }
    
    private var badgeTextColor: Color {
        isOverBudget ? .white : (item.percent > 0.8 ? .orange : .green)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("\(formatCurrency(item.spent)) / \(formatCurrency(item.limit))")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(isOverBudget ? "Vượt!" : "\(percentDisplay)%")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(badgeTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(badgeBackground)
                    )
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geo.size.width * progressWidthRatio, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

enum CashFlowType: String {
    case income = "Thu"
    case expense = "Chi"
}

struct DailyCashFlowItem: Identifiable {
    let id = UUID()
    let day: String
    let type: CashFlowType
    let amount: Double
}

struct FakeCategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
    let icon: String
}

struct FakeBudgetItem: Identifiable {
    let id = UUID()
    let name: String
    let spent: Double
    let limit: Double
    let color: Color
    let icon: String
    
    var percent: Double {
        guard limit > 0 else { return 0 }
        return spent / limit
    }
}

func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = "."
    formatter.maximumFractionDigits = 0
    return (formatter.string(from: NSNumber(value: value)) ?? "0") + "đ"
}

func sampleDailyCashFlow() -> [DailyCashFlowItem] {
    [
        .init(day: "T2", type: .income, amount: 1_200_000),
        .init(day: "T2", type: .expense, amount: 850_000),
        .init(day: "T3", type: .income, amount: 900_000),
        .init(day: "T3", type: .expense, amount: 1_100_000),
        .init(day: "T4", type: .income, amount: 1_500_000),
        .init(day: "T4", type: .expense, amount: 720_000),
        .init(day: "T5", type: .income, amount: 1_050_000),
        .init(day: "T5", type: .expense, amount: 980_000),
        .init(day: "T6", type: .income, amount: 1_800_000),
        .init(day: "T6", type: .expense, amount: 1_350_000),
        .init(day: "T7", type: .income, amount: 2_200_000),
        .init(day: "T7", type: .expense, amount: 1_750_000),
        .init(day: "CN", type: .income, amount: 700_000),
        .init(day: "CN", type: .expense, amount: 920_000),
    ]
}

func sampleCategories() -> [FakeCategoryItem] {
    [
        .init(name: "Ăn uống", amount: 4_512_300, color: .orange, icon: "fork.knife"),
        .init(name: "Mua sắm", amount: 2_532_500, color: .pink, icon: "bag.fill"),
        .init(name: "Di chuyển", amount: 932_000, color: .blue, icon: "car.fill"),
        .init(name: "Giải trí", amount: 650_000, color: .purple, icon: "gamecontroller.fill"),
        .init(name: "Hoá đơn", amount: 480_000, color: .cyan, icon: "doc.text.fill"),
        .init(name: "Khác", amount: 120_000, color: .gray, icon: "ellipsis")
    ]
}

func sampleBudgets() -> [FakeBudgetItem] {
    [
        .init(name: "Ăn uống", spent: 4_512_300, limit: 5_000_000, color: .orange, icon: "fork.knife"),
        .init(name: "Mua sắm", spent: 3_200_000, limit: 3_000_000, color: .pink, icon: "bag.fill"),
        .init(name: "Di chuyển", spent: 932_000, limit: 2_000_000, color: .blue, icon: "car.fill"),
        .init(name: "Giải trí", spent: 650_000, limit: 1_000_000, color: .purple, icon: "gamecontroller.fill")
    ]
}
