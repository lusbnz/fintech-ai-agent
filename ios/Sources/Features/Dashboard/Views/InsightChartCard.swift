import SwiftUI
import Charts

struct InsightChartCard: View {
    enum ChartType {
        case pie, bar, line
    }
    
    struct SpendingCategory: Identifiable {
        let id = UUID()
        let category: String
        let value: Double
        let color: Color
    }

    let spendingData: [SpendingCategory]
    let index: Int
    let total: Int
    let title: String
    let highlightText: String
    let highlightValue: String
    let icon: String
    let iconColor: Color
    let chartType: ChartType

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: "lightbulb.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                Text("\(index)/\(total)")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bạn đang dành")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.black)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(highlightValue)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(iconColor)
                        Text(highlightText)
                            .font(.system(size: 11))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                chartView
                    .frame(width: 150, height: 100)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 3)
        )
    }

    @ViewBuilder
    private var chartView: some View {
        switch chartType {
        case .pie:
            Chart(spendingData) { item in
                SectorMark(
                    angle: .value("Value", item.value),
                    innerRadius: .ratio(0.6)
                )
                .foregroundStyle(item.color)
            }
            .chartBackground { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
            }

        case .bar:
            Chart(spendingData) { item in
                BarMark(
                    x: .value("Category", item.category),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(item.color)
                .cornerRadius(4)
            }

        case .line:
            Chart(spendingData) { item in
                LineMark(
                    x: .value("Category", item.category),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(iconColor)
                .interpolationMethod(.catmullRom)
            }
        }
    }
}
