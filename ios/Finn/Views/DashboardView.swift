import SwiftUI
import Charts

enum TimeRange: String, CaseIterable {
    case week = "Tuần"
    case month = "Tháng"
}

struct DashboardView: View {
    @State private var selectedRange: TimeRange = .month
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack {
                Spacer()
                Text("Báo cáo")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Button {
                            selectedRange = range
                        } label: {
                            Text(range.rawValue)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(selectedRange == range ? .white : .primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule()
                                        .fill(selectedRange == range
                                              ? Color.accentColor
                                              : Color(UIColor.secondarySystemBackground))
                                )
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                
                DashboardBox(
                    icon: "arrow.down.circle.fill",
                    iconColor: .green,
                    title: "Biểu đồ Thu"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("45M đ")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                        
                        Chart {
                            ForEach(sampleIncomeBars()) { item in
                                BarMark(
                                    x: .value("Day", item.day),
                                    y: .value("Amount", item.amount)
                                )
                                .cornerRadius(4)
                                .foregroundStyle(.green.gradient)
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .chartXScale(domain: 0.5...7.5)
                        .frame(height: 90)
                    }
                }
                
                DashboardBox(icon: "arrow.up.circle.fill",
                    iconColor: .red,
                    title: "Biểu đồ Chi"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("12,5M đ")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.red)
                        
                        Chart {
                            ForEach(sampleExpenseBars()) { item in
                                BarMark(
                                    x: .value("Day", item.day),
                                    y: .value("Amount", item.amount)
                                )
                                .cornerRadius(4)
                                .foregroundStyle(.red.gradient)
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .chartXScale(domain: 0.5...7.5)
                        .frame(height: 90)
                    }
                }
                
                DashboardBox(
                    icon: "chart.pie.fill",
                    iconColor: .orange,
                    title: "Danh mục chi tiêu"
                ) {
                VStack(spacing: 12) {
                    HStack {
                        Text("12,5M đ")
                            .font(.system(size: 17, weight: .bold))
                        
                        Text("Tổng chi")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                        
                        HStack(alignment: .top, spacing: 20) {
                            Chart {
                                ForEach(sampleCategories()) { cat in
                                    SectorMark(
                                        angle: .value("Amount", cat.amount),
                                        innerRadius: .ratio(0.65)
                                    )
                                    .foregroundStyle(cat.color.gradient)
                                }
                            }
                            .frame(width: 100, height: 100)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(sampleCategories()) { cat in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(cat.color)
                                            .frame(width: 10, height: 10)
                                        
                                        Text(cat.name)
                                            .font(.system(size: 13))
                                        
                                        Spacer()
                                        
                                        Text("30000 VNĐ")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                
                DashboardBox(
                    icon: "creditcard.fill",
                    iconColor: .red,
                    title: "Giới hạn chi tiêu"
                ) {
                    VStack(spacing: 10) {
                        ForEach(sampleSpendLimits()) { item in
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(item.name)
                                        .font(.system(size: 13, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Text("\(Int(item.amount))/\(Int(item.limit))đ")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                
                                ProgressView(value: item.amount / item.limit)
                                    .tint(item.color)
                                    .scaleEffect(x: 1, y: 0.8)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 120)
            }
            .background(
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
            )
        }
}

struct DashboardBox<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                
                Spacer()
            }
            
            content()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

struct BarData: Identifiable {
    let id = UUID()
    let day: Int
    let amount: Double
}

private func sampleIncomeBars() -> [BarData] {
    (1...7).map { .init(day: $0, amount: Double.random(in: 1_000_000...5_000_000)) }
}

private func sampleExpenseBars() -> [BarData] {
    (1...7).map { .init(day: $0, amount: Double.random(in: 500_000...3_000_000)) }
}

private func sampleIncomeExpense() -> [(day: Int, amount: Double)] {
    (1...30).map { d in
        let isIncome = Bool.random()
        return (d, isIncome ? Double.random(in: 500_000...3_000_000)
                            : Double.random(in: -2_000_000 ... -200_000))
    }
}

struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

private func sampleCategories() -> [CategoryItem] {
    [
        .init(name: "Ăn uống", amount: 3_200_000, color: .orange),
        .init(name: "Đi lại", amount: 1_800_000, color: .blue),
        .init(name: "Mua sắm", amount: 2_000_000, color: .pink),
        .init(name: "Giải trí", amount: 1_000_000, color: .green)
    ]
}

struct SpendLimitItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let limit: Double
    let color: Color
}

private func sampleSpendLimits() -> [SpendLimitItem] {
    [
        .init(name: "Ăn uống", amount: 3_200_000, limit: 5_000_000, color: .orange),
        .init(name: "Đi lại", amount: 1_800_000, limit: 3_000_000, color: .blue),
    ]
}

