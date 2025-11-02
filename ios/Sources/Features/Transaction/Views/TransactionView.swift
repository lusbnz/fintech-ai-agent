import SwiftUI

struct TransactionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var budgetViewModel: BudgetViewModel
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showCreateNew = false
    @State private var currentWeekOffset = 0
    @State private var showWeekPicker = false
    @State private var selectedDate = Date()
    @State private var selectedBudget: String = "All"
    
    private var budgetTags: [String] {
        ["All"] + budgetViewModel.budgets.map { $0.name }
    }
    
    private var selectedBudgetId: String? {
        guard selectedBudget != "All" else { return nil }
        return budgetViewModel.budgets.first { $0.name == selectedBudget }?.id
    }
    
    private let weekDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d"
        return df
    }()
    
    private let displayDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d"
        return df
    }()
    
    private var currentWeekRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: today),
              let interval = calendar.dateInterval(of: .weekOfYear, for: weekStart) else {
            return today...today
        }
        return interval.start ... interval.end.addingTimeInterval(-1)
    }
    
    var currentWeekText: String {
        let start = weekDateFormatter.string(from: currentWeekRange.lowerBound)
        let end = weekDateFormatter.string(from: currentWeekRange.upperBound)
        return "\(start) - \(end)"
    }
    
    private func updateWeekOffset(from date: Date) {
        let calendar = Calendar.current
        let today = Date()
        let weekToday = calendar.component(.weekOfYear, from: today)
        let yearToday = calendar.component(.yearForWeekOfYear, from: today)
        let weekSel = calendar.component(.weekOfYear, from: date)
        let yearSel = calendar.component(.yearForWeekOfYear, from: date)
        let diff = (yearSel - yearToday) * 52 + (weekSel - weekToday)
        withAnimation { currentWeekOffset = diff }
    }
    
    private var filteredTransactionsThisWeek: [Transaction] {
        transactionViewModel.transactions.filter { tx in
            guard let date = tx.displayDate else { return false }
            return currentWeekRange.contains(date)
        }
    }
    
    private var groupedTransactions: [String: [Transaction]] {
        let grouped = Dictionary(grouping: filteredTransactionsThisWeek) { tx -> String in
            guard let date = tx.displayDate else { return "Unknown" }
            if Calendar.current.isDateInToday(date) { return "Today" }
            if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: date)
        }

        let sortedKeys = grouped.keys.sorted { a, b in
            if a == "Today" { return true }
            if b == "Today" { return false }
            if a == "Yesterday" { return true }
            if b == "Yesterday" { return false }
            guard let da = grouped[a]?.first?.displayDate,
                  let db = grouped[b]?.first?.displayDate else { return a < b }
            return da > db
        }

        return Dictionary(uniqueKeysWithValues: sortedKeys.map { ($0, grouped[$0]!) })
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "CFDBF8"), .white], startPoint: .top, endPoint: .bottom)
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                weekNavigationHeader
                budgetTagsView
                transactionListView
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            loadInitialData()
        }
        .onChange(of: selectedBudget) { oldValue, newValue in
            transactionViewModel.selectedBudgetId = selectedBudgetId
        }
    }
    
    private var weekNavigationHeader: some View {
        HStack {
            Button { currentWeekOffset -= 1 } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 2, y: 1)
            }
            
            Spacer()
            
            Button { showWeekPicker = true } label: {
                Text(currentWeekText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
            .sheet(isPresented: $showWeekPicker) {
                weekPickerSheet
            }
            
            Spacer()
            
            Button { currentWeekOffset += 1 } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 36, height: 36)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 2, y: 1)
            }
        }
        .padding(.horizontal)
        .frame(height: 44)
    }
    
    private var budgetTagsView: some View {
        HStack {
            FlexibleView(data: budgetTags, spacing: 8) { tag in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        selectedBudget = tag
                    }
                } label: {
                    Text(tag)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedBudget == tag ? .black : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedBudget == tag ? .white : .gray.opacity(0.2))
                        )
                        .shadow(color: selectedBudget == tag ? .white.opacity(0.3) : .clear, radius: 4)
                }
            }
            
            Spacer()
            
            NavigationLink(destination: BudgetView()
                .environmentObject(authViewModel)
                .environmentObject(transactionViewModel)
            ) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
    
    private var transactionListView: some View {
        Group {
            if transactionViewModel.isLoading && transactionViewModel.transactions.isEmpty {
                skeletonLoadingView
            } else if let error = transactionViewModel.error {
                errorView(for: error)
            } else if groupedTransactions.isEmpty {
                emptyStateView
            } else {
                realTransactionList
            }
        }
    }
    
    @ViewBuilder
    private func errorView(for error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text(error)
                .font(.system(size: 14))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                Task { await transactionViewModel.refresh() }
            }
            .font(.system(size: 14, weight: .semibold))
            .padding(.horizontal, 32)
            .padding(.vertical, 10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No transactions this week")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    @ViewBuilder
    private var skeletonLoadingView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<5) { _ in
                    SkeletonListItem()
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .disabled(true)
    }
    
    private var realTransactionList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(groupedTransactions.keys.sorted(by: sortDates), id: \.self) { key in
                    daySection(dateKey: key, transactions: groupedTransactions[key] ?? [])
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .refreshable {
            transactionViewModel.error = nil
            transactionViewModel.hasMorePages = true
            transactionViewModel.currentPage = 1
            transactionViewModel.isLoading = false
           await transactionViewModel.refresh()
        }
    }
    
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 12))
        }
    }
    
    private var weekPickerSheet: some View {
        VStack(spacing: 16) {
            Text("Select a Week")
                .font(.system(size: 18, weight: .semibold))
                .padding(.top)
            
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
            
            Button("Confirm") {
                updateWeekOffset(from: selectedDate)
                showWeekPicker = false
            }
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button("Cancel") { showWeekPicker = false }
                .foregroundColor(.red)
                .padding(.bottom)
        }
        .presentationDetents([.medium])
    }
    
    private func daySection(dateKey: String, transactions: [Transaction]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateKey)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray)
                
                Spacer()
                
                let incomeTotal = transactions
                    .filter { $0.type == "income" }
                    .reduce(0) { $0 + $1.amount }

                let outcomeTotal = transactions
                    .filter { $0.type == "outcome" }
                    .reduce(0) { $0 + $1.amount }

                let net = incomeTotal - outcomeTotal
                let isPositive = net >= 0
                let textColor: Color = isPositive ? Color(hex: "2A9D8F") : Color(hex: "E63946")
                let bgGradient = LinearGradient(
                    colors: isPositive
                        ? [Color.green.opacity(0.15), Color.green.opacity(0.05)]
                        : [Color.red.opacity(0.15), Color.red.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Text("\(isPositive ? "+" : "-")\(abs(Int(net)).formattedWithSeparator) VNĐ")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(!isPositive ? .red : .green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(!isPositive ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                    .cornerRadius(8)
                
                Button { showCreateNew = true } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                .fullScreenCover(isPresented: $showCreateNew) {
                    NavigationStack {
                        CreateTransactionView(defaultBudgetId: selectedBudgetId)
                    }
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(transactions) { tx in
                    NavigationLink(destination:
                                    TransactionDetailView(transaction: tx)
                                   
                    ) {
                        TransactionItem(
                            title: tx.name,
                            remain: tx.type == "outcome"
                                ? "-\(Int(abs(tx.amount)).formattedWithSeparator) VNĐ"
                                : "+\(Int(tx.amount).formattedWithSeparator) VNĐ",
                            time: tx.formattedDate,
                            place: (tx.location?.name.isEmpty == false ? tx.location!.name : "Unknown"),
                            attachments: tx.image != nil ? 1 : 0,
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
    
    private func sortDates(_ a: String, _ b: String) -> Bool {
        if a == "Today" { return true }
        if b == "Today" { return false }
        if a == "Yesterday" { return true }
        if b == "Yesterday" { return false }
        return a > b
    }
    
    private func loadInitialData() {
        if budgetViewModel.budgets.isEmpty {
            Task { await budgetViewModel.loadBudgets() }
        }
        if transactionViewModel.transactions.isEmpty {
            Task { await transactionViewModel.refresh() }
        }
    }
}

extension Transaction {
    var displayDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: date_time)
    }

    var formattedDate: String {
        guard let date = displayDate else { return "Invalid Date" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    var timeString: String {
        guard let date = displayDate else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct TransactionItem: View {
    let title: String
    let remain: String
    var time: String
    var place: String
    var attachments: Int
    var categoryColor: Color = .blue
    var categoryIcon: String = "cart.fill"
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: categoryIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(categoryColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Text(time)
                    if !place.isEmpty && place != "Unknown" {
                        Text("•")
                        Text(place)
                    }
                    if attachments > 0 {
                        Text("•")
                        Text("\(attachments) Attachment\(attachments > 1 ? "s" : "")")
                    }
                }
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
            }

            Spacer()

            HStack(alignment: .center, spacing: 4) {
                Text(remain)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(remain.contains("-") ? .red : .green)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
    }
}

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(Array(data), id: \.self) { item in
                    content(item)
                }
            }
            .padding(.trailing)
        }
        .frame(maxWidth: .infinity)
    }
}
