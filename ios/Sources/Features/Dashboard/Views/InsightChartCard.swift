import SwiftUI
import Charts

struct InsightChartCard: View {
    struct SpendingCategory: Identifiable {
        let id = UUID()
        let category: String
        let value: Double
        let color: Color
    }
    
    let spendingData: [SpendingCategory] = [
        .init(category: "Shopping", value: 20, color: .blue),
        .init(category: "Food", value: 30, color: .orange),
        .init(category: "Bills", value: 25, color: .green),
        .init(category: "Entertainment", value: 25, color: .purple)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Phân loại thu chi", systemImage: "lightbulb.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                Text("1/6")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bạn đang dành")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("20%")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.yellow)
                        Text("cho ngân sách mua sắm")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                // Donut Chart
                Chart(spendingData) { item in
                    SectorMark(
                        angle: .value("Value", item.value),
                        innerRadius: .ratio(0.6)
                    )
                    .foregroundStyle(item.color)
                }
                .frame(width: 100, height: 100)
                .chartBackground { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "bag.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.top, 4)
    }
}
