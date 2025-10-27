import SwiftUI
import Charts

struct BarStat: Identifiable {
    let id = UUID()
    let month: String
    let views: Int
}

struct BudgetDetailView: View {
    let budget: Budget
    let title: String
    let remain: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showCreateNew = false
    @State private var currentWeekOffset = 0
    @State private var selectedBudget: String = "All"
    @State private var showWeekPicker = false
    @State private var selectedDate = Date()
    @State private var selectedMonth: String? = nil
    
    private var userCurrency: String? {
        authViewModel.userProfile?.currency
    }
    
    let budgets = ["All", "Income", "Outgoing"]
    
    let stats: [BarStat] = [
        .init(month: "Jan", views: 60000),
        .init(month: "Feb", views: 95000),
        .init(month: "Mar", views: 75000),
        .init(month: "Apr", views: 140000),
        .init(month: "May", views: 100000),
        .init(month: "Jun", views: 95000),
        .init(month: "Jul", views: 65000),
        .init(month: "Aug", views: 80000),
        .init(month: "Sep", views: 110000),
        .init(month: "Oct", views: 120000),
        .init(month: "Nov", views: 100000),
        .init(month: "Dec", views: 90000)
    ]
    
//    var groupedTransactions: [String: [Transaction]] = [
//        "Today": [
//            Transaction(
//                title: "Shopping",
//                amount: "-20,000 VNĐ",
//                time: "14:30",
//                place: "Trung Yên",
//                attachments: 1,
//                categoryIcon: "bag.fill",
//                categoryColor: .orange
//            )
//        ],
//        "Fri, Aug 30": [
//            Transaction(
//                title: "Groceries",
//                amount: "-120,000 VNĐ",
//                time: "16:00",
//                place: "Vinmart",
//                attachments: 2,
//                categoryIcon: "cart.fill",
//                categoryColor: .green
//            )
//        ]
//    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F04A25"), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.5)
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    titleSection
                    budgetFilter
                    chartSection
                    transactionSection
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            Spacer()
            Menu {
                Button("Edit", systemImage: "pencil") {
                    viewModel.showEdit = true
                }
                Button("Delete", systemImage: "trash", role: .destructive) {
                    viewModel.showDeleteConfirm = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .fullScreenCover(isPresented: $viewModel.showEdit) {
            NavigationStack {
                CreateBudgetView(
                    budget: budget,
                    onSuccess: {
                        dismiss()
                    }
                )
            }
        }
        .alert("Delete Budget", isPresented: $viewModel.showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    let success = await viewModel.deleteBudget(budget)
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(budget.name)\"?")
        }
    }
    
    private var titleSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(budget.name)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.black)
                Text("64 Items")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var budgetFilter: some View {
        HStack(alignment: .center) {
            FlexibleView(data: budgets) { tag in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedBudget = tag
                    }
                } label: {
                    Text(tag)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedBudget == tag ? .black : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedBudget == tag ? Color.white : Color.gray.opacity(0.2))
                        )
                        .shadow(color: selectedBudget == tag ? Color.white.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Amounts")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            Text(String(budget.formattedAmount(using: userCurrency)))
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Chart {
                ForEach(stats) { item in
                    BarMark(
                        x: .value("Month", item.month),
                        y: .value("Views", item.views)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red.opacity(0.8), Color.pink]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(6)
                    .opacity(selectedMonth == nil || selectedMonth == item.month ? 1.0 : 0.3)
                    .annotation(position: .top, alignment: .center) {
                        if selectedMonth == item.month {
                            Text("\(item.views.formatted(.number))")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel()
                }
            }
            .frame(height: 180)
            .chartYScale(domain: 0...150000)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if let month: String = findMonth(value.location, proxy: proxy, geometry: geo) {
                                        selectedMonth = month
                                    }
                                }
                                .onEnded { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        selectedMonth = nil
                                    }
                                }
                        )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var transactionSection: some View {
        VStack(alignment: .leading, spacing: 24) {
//            ForEach(groupedTransactions.keys.sorted(by: sortDates), id: \.self) { key in
//                VStack(alignment: .leading, spacing: 12) {
//                    HStack {
//                        Text(key)
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(.gray)
//                        Spacer()
//                    }
//                    .padding(.horizontal)
//                    
//                    VStack(spacing: 8) {
//                        ForEach(groupedTransactions[key] ?? []) { transaction in
//                            NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
//                                TransactionItem(
//                                    title: transaction.title,
//                                    remain: transaction.amount,
//                                    time: transaction.time,
//                                    place: transaction.place,
//                                    attachments: transaction.attachments,
//                                    categoryColor: transaction.categoryColor,
//                                    categoryIcon: transaction.categoryIcon
//                                )
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//            }
            
            Text("No more transactions")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
        }
        .padding(.top, 20)
    }
    
    private func findMonth(_ location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> String? {
        if let month: String = proxy.value(atX: location.x - geometry[proxy.plotAreaFrame].origin.x) {
            return month
        }
        return nil
    }
    
    private func sortDates(_ d1: String, _ d2: String) -> Bool {
        if d1 == "Today" { return true }
        if d2 == "Today" { return false }
        return d1 > d2
    }
}
