import SwiftUI

struct TransactionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showCreateNew = false
    @State private var currentWeekOffset = 0
    @State private var selectedBudget: String = "All"
    @State private var showWeekPicker = false
    @State private var selectedDate = Date()
    
    let budgets = ["All", "Shopping", "Saving", "Food", "Transport"]

    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d"
        return df
    }()
    
    var currentWeekText: String {
        let calendar = Calendar.current
        let today = Date()
        if let startOfWeek = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: today),
           let weekInterval = calendar.dateInterval(of: .weekOfYear, for: startOfWeek) {
            let startText = dateFormatter.string(from: weekInterval.start)
            let endText = dateFormatter.string(from: weekInterval.end.addingTimeInterval(-1))
            return "\(startText) - \(endText)"
        }
        return "Current Week"
    }
    
    private func updateWeekOffset(from date: Date) {
        let calendar = Calendar.current
        let today = Date()

        if let weekOfYearToday = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: today).weekOfYear,
           let weekOfYearSelected = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date).weekOfYear,
           let yearToday = calendar.dateComponents([.yearForWeekOfYear], from: today).yearForWeekOfYear,
           let yearSelected = calendar.dateComponents([.yearForWeekOfYear], from: date).yearForWeekOfYear {

            let totalWeeksDiff = (yearSelected - yearToday) * 52 + (weekOfYearSelected - weekOfYearToday)
            withAnimation {
                currentWeekOffset = totalWeeksDiff
            }
        }
    }

    var groupedTransactions: [String: [Transaction]] = [
        "Today": [
            Transaction(
                title: "Shopping",
                amount: "-20,000 VNĐ",
                time: "14:30",
                place: "Trung Yên",
                attachments: 1,
                categoryIcon: "bag.fill",
                categoryColor: .orange
            )
        ],
        "Fri, Aug 30": [
            Transaction(
                title: "Groceries",
                amount: "-120,000 VNĐ",
                time: "16:00",
                place: "Vinmart",
                attachments: 2,
                categoryIcon: "cart.fill",
                categoryColor: .green
            )
        ]
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "CFDBF8"),
                    Color(hex: "FFFFFF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.5)
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        withAnimation {
                            currentWeekOffset -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
                    Button {
                        showWeekPicker = true
                    } label: {
                        Text(currentWeekText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .animation(.easeInOut, value: currentWeekOffset)
                    }
                    .sheet(isPresented: $showWeekPicker) {
                        VStack(spacing: 16) {
                            Text("Select a Week")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.top)

                            DatePicker(
                                "Select Date",
                                selection: $selectedDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .padding()

                            Button(action: {
                                updateWeekOffset(from: selectedDate)
                                showWeekPicker = false
                            }) {
                                Text("Confirm")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }

                            Button("Cancel") {
                                showWeekPicker = false
                            }
                            .foregroundColor(.red)
                            .padding(.bottom)
                        }
                        .presentationDetents([.medium])
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentWeekOffset += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
                .frame(height: 44)
                .padding(.horizontal)

                ScrollView {
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

                       NavigationLink(destination: BudgetView()) {
                           Image(systemName: "gearshape")
                               .font(.system(size: 18, weight: .semibold))
                               .foregroundColor(.gray)
                               .padding(.leading, 4)
                       }
                   }
                   .padding(.horizontal)
                   .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(groupedTransactions.keys.sorted(by: sortDates), id: \.self) { key in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(key)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                    
                                    if let transactions = groupedTransactions[key], !transactions.isEmpty {
                                        HStack(spacing: 12) {
                                            let totalAmount = transactions.reduce(0) { sum, transaction in
                                                let amountStr = transaction.amount.replacingOccurrences(of: "[^0-9-]", with: "", options: .regularExpression)
                                                return sum + (Int(amountStr) ?? 0)
                                            }
                                            Text("\(totalAmount.formattedWithSeparator) VNĐ")
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(totalAmount < 0 ? Color.red : Color.green)
                                                .cornerRadius(8)
                                            
                                            Button(action: { showCreateNew = true }) {
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 8) {
                                    ForEach(groupedTransactions[key] ?? []) { transaction in
                                        NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                                            TransactionItem(
                                                title: transaction.title,
                                                remain: transaction.amount,
                                                time: transaction.time,
                                                place: transaction.place,
                                                attachments: transaction.attachments,
                                                categoryColor: transaction.categoryColor,
                                                categoryIcon: transaction.categoryIcon
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Text("No more transactions")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 16)
                    }
                    .padding(.bottom, 40)
                    .padding(.top, 20)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 12))
        })
        .fullScreenCover(isPresented: $showCreateNew) {
            NavigationStack {
                CreateTransactionView()
            }
        }
    }
    
    private func sortDates(_ d1: String, _ d2: String) -> Bool {
        if d1 == "Today" { return true }
        if d2 == "Today" { return false }
        return d1 > d2
    }
}

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let amount: String
    let time: String
    let place: String
    let attachments: Int
    let categoryIcon: String
    let categoryColor: Color
}

struct TransactionItem: View {
    let title: String
    let remain: String
    var time: String = "14:30"
    var place: String = "Trung Yên"
    var attachments: Int = 1
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
                    Text("•")
                    Text(place)
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
                    .foregroundColor(.red)
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

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
